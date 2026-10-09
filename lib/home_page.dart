import 'dart:convert';
import 'package:flutter/material.dart';
import 'widgets.dart';
import 'web_scripts.dart';
import 'models.dart';

class HomePage extends StatefulWidget {
  final Future<String> Function(String js) evalJs;
  final Future<void> Function() onReload;

  const HomePage({
    super.key,
    required this.evalJs,
    required this.onReload,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<List<String>> _logs =
      ValueNotifier<List<String>>(<String>[]);

  List<String> _ranges = [];
  String? _selectedRange;
  String _rangeSearch = '';
  bool _loadingRanges = false;

  bool _filtering = false;
  bool _filterApplied = false;

  RangeStats _stats = RangeStats(rangeName: '');
  bool _loadingStats = false;

  int _countToAdd = 10;
  final _userCtrl = TextEditingController();
  bool _adding = false;
  bool _addDone = false;

  static const _countOptions = [10, 25, 50, 100, 200];

  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _logs.dispose();
    super.dispose();
  }

  void _log(String msg) {
    final cur = _logs.value;
    final upd = <String>['${_timeNow()}  $msg', ...cur];
    if (upd.length > 200) upd.removeRange(200, upd.length);
    _logs.value = upd;
  }

  String _timeNow() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')}';
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(seconds: 3));
    _log('جاري قراءة الرنجات…');
    await _loadRanges();
  }

  Future<void> _loadRanges() async {
    setState(() => _loadingRanges = true);
    List<String>? found;

    for (int attempt = 0; attempt < 10; attempt++) {
      await widget.evalJs(WebScripts.openRanges);
      await Future.delayed(const Duration(milliseconds: 500));
      final raw = await widget.evalJs(WebScripts.readRanges);
      if (raw.startsWith('err')) continue;
      try {
        final list = (jsonDecode(raw) as List).cast<String>();
        if (list.isNotEmpty) {
          found = list;
          break;
        }
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 300));
    }

    setState(() {
      _loadingRanges = false;
      if (found != null && found.isNotEmpty) {
        _ranges = found;
        _log('تم تحميل ${found.length} رنج ✅');
      } else {
        _log('مفيش رنجات ظهرت ❌');
      }
    });
  }

  Future<void> _refreshRanges() async {
    setState(() {
      _ranges.clear();
      _selectedRange = null;
      _filterApplied = false;
      _stats = RangeStats(rangeName: '');
    });
    await _loadRanges();
  }

  Future<void> _searchRanges(String q) async {
    setState(() => _rangeSearch = q);
    await widget.evalJs(WebScripts.openRanges);
    await Future.delayed(const Duration(milliseconds: 400));
    final js = WebScripts.searchRanges.replaceAll('%QUERY%', jsonEncode(q));
    await widget.evalJs(js);
    await Future.delayed(const Duration(milliseconds: 600));
    final raw = await widget.evalJs(WebScripts.readRanges);
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      setState(() => _ranges = list);
    } catch (_) {}
  }

  Future<void> _pickRange(String name) async {
    setState(() => _selectedRange = name);
    _log('اختيار الرنج: $name');
    final js = WebScripts.selectRange.replaceAll('%NAME%', jsonEncode(name));
    for (int i = 0; i < 4; i++) {
      final r = await widget.evalJs(js);
      if (r == 'ok') break;
      await Future.delayed(const Duration(milliseconds: 500));
    }
    await Future.delayed(const Duration(milliseconds: 600));
  }

  // ═══════ Apply Filter ═══════
  Future<void> _applyFilter() async {
    if (_selectedRange == null) {
      _log('اختار رنج الأول');
      return;
    }
    setState(() {
      _filtering = true;
      _filterApplied = false;
    });
    _log('═══ جاري تطبيق الفلتر ═══');

    try {
      // 1) دوس على الفلتر
      final r = await widget.evalJs(WebScripts.clickFilter);
      _log('Filter: $r');

      // 2) استنى 3 ثواني للفلترة
      await Future.delayed(const Duration(seconds: 3));

      // 3) اقرا الحالة الحالية
      final info1 = await widget.evalJs(WebScripts.getPageInfo);
      _log('قبل 5000: $info1');

      // 4) غيّر page size لـ 5000 (بنفس applyVueSelect)
      final setRes = await widget.evalJs(WebScripts.setPageSize5000);
      _log('set5000: $setRes');

      // 5) استنى 4 ثواني للتحميل
      _log('⏳ استنى التحميل…');
      await Future.delayed(const Duration(seconds: 4));

      // 6) اقرا الحالة بعد 5000
      final info2 = await widget.evalJs(WebScripts.getPageInfo);
      _log('بعد 5000: $info2');

      int total = 0;
      int rows = 0;
      bool hasNext = false;
      try {
        final m = jsonDecode(info2) as Map;
        total = (m['total'] ?? 0) as int;
        rows = (m['rows'] ?? 0) as int;
        hasNext = (m['hasNext'] ?? false) as bool;
      } catch (_) {}

      // 7) لو لسه فيه Next → يعني الـ 5000 مش كفى
      //    ندوس Next ونكمل قراءة
      int availableTotal = 0;

      // اقرا المتاح من الصفحة الحالية
      final av1 = await widget.evalJs(WebScripts.countAvailableOnPage);
      int av = int.tryParse(av1) ?? 0;
      availableTotal += av;
      _log('الصفحة 1: متاح=$av، صفوف=$rows');

      if (hasNext) {
        _log('⚠️ لسه فيه صفحات تانية، استخدم Next…');
        int pages = 1;
        const maxPages = 50;

        while (hasNext && pages < maxPages) {
          await widget.evalJs(WebScripts.clickNextPage);
          await Future.delayed(const Duration(milliseconds: 1500));
          pages++;

          final avNext = await widget.evalJs(WebScripts.countAvailableOnPage);
          final avN = int.tryParse(avNext) ?? 0;
          availableTotal += avN;

          final infoN = await widget.evalJs(WebScripts.getPageInfo);
          try {
            final m = jsonDecode(infoN) as Map;
            hasNext = (m['hasNext'] ?? false) as bool;
            rows += (m['rows'] ?? 0) as int;
          } catch (_) {}

          if (pages % 3 == 0) {
            _log('صفحة $pages: +$avN (المجموع: $availableTotal)');
          }
        }
      }

      // 8) احسب النتيجة
      final added = total > 0 ? (total - availableTotal).clamp(0, total) : 0;

      setState(() {
        _stats = RangeStats(
          rangeName: _selectedRange ?? '',
          total: total,
          available: availableTotal,
          added: added,
        );
        _filterApplied = true;
      });

      _log('═══ النتيجة ═══');
      _log('كلي=$total | متاح=$availableTotal | مضاف=$added');
    } catch (e) {
      _log('خطأ: $e');
    }

    setState(() => _filtering = false);
    setState(() => _loadingStats = false);
  }

  // ═══════ Add numbers ═══════
  Future<void> _addNumbers() async {
    if (_selectedRange == null) {
      _log('اختار رنج الأول');
      return;
    }
    final user = _userCtrl.text.trim();
    if (user.isEmpty) {
      _log('اكتب اسم اليوزر');
      return;
    }
    if (_stats.available < _countToAdd) {
      _log('العدد المطلوب أكبر من المتاح (${_stats.available})');
      return;
    }

    setState(() {
      _adding = true;
      _addDone = false;
    });
    _log('═══ بدء إضافة $_countToAdd رقم لـ $user ═══');

    try {
      // روح للصفحة الأولى
      await widget.evalJs(WebScripts.goFirstPage);
      await Future.delayed(const Duration(milliseconds: 2000));

      final checkJs = WebScripts.checkAvailable
          .replaceAll('%COUNT%', _countToAdd.toString());
      final checkRes = await widget.evalJs(checkJs);
      _log('اختيار: $checkRes');
      if (!checkRes.startsWith('ok')) {
        _log('فشل اختيار الأرقام');
        setState(() => _adding = false);
        return;
      }
      await Future.delayed(const Duration(milliseconds: 800));

      final r1 = await widget.evalJs(WebScripts.clickAddButton);
      _log('زرار Add: $r1');
      if (r1 != 'ok') {
        setState(() => _adding = false);
        return;
      }
      await Future.delayed(const Duration(milliseconds: 1800));

      final r2 = await widget.evalJs(WebScripts.selectDlr7_1);
      _log('DLR: $r2');
      await Future.delayed(const Duration(milliseconds: 600));

      final r3 = await widget.evalJs(WebScripts.openUserDropdown);
      _log('فتح قائمة اليوزر: $r3');
      await Future.delayed(const Duration(milliseconds: 900));

      final searchJs =
          WebScripts.searchUser.replaceAll('%QUERY%', jsonEncode(user));
      await widget.evalJs(searchJs);
      await Future.delayed(const Duration(milliseconds: 1200));

      final selectJs =
          WebScripts.selectUser.replaceAll('%NAME%', jsonEncode(user));
      final r4 = await widget.evalJs(selectJs);
      _log('اختيار اليوزر: $r4');
      await Future.delayed(const Duration(milliseconds: 800));

      final r5 = await widget.evalJs(WebScripts.confirmAdd);
      _log('تأكيد الإضافة: $r5');
      await Future.delayed(const Duration(milliseconds: 2500));

      setState(() => _addDone = true);
      _log('✅ تم إضافة $_countToAdd رقم لـ $user');
    } catch (e) {
      _log('خطأ: $e');
    }

    setState(() => _adding = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF00D2FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.sms_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'imss',
                          style: kNoDeco.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'أضف أرقام لليوزر بضغطة واحدة',
                          style: kNoDeco.copyWith(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconBtn(
                    icon: Icons.refresh_rounded,
                    spinning: _loadingRanges || _filtering,
                    onTap: (_loadingRanges || _filtering)
                        ? null
                        : _refreshRanges,
                  ),
                  const SizedBox(width: 6),
                  IconBtn(
                    icon: Icons.logout_rounded,
                    onTap: widget.onReload,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildRangeCard(theme),
                      const SizedBox(height: 12),
                      _buildStatsRow(theme),
                      const SizedBox(height: 12),
                      _buildAddCard(theme),
                      const SizedBox(height: 12),
                      LogPanel(logs: _logs, height: 220),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeCard(ThemeData theme) {
    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label(theme, Icons.sim_card_rounded, 'الرنج'),
          const SizedBox(height: 10),
          TextField(
            onChanged: _searchRanges,
            decoration: InputDecoration(
              hintText: 'ابحث عن رنج…',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _rangeSearch.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => _searchRanges(''),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.15),
              ),
            ),
            child: _loadingRanges
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : _ranges.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'مفيش رنجات',
                            style: kNoDeco.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: _ranges.length,
                        itemBuilder: (_, i) {
                          final r = _ranges[i];
                          final sel = r == _selectedRange;
                          return InkWell(
                            onTap: () => _pickRange(r),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              color: sel
                                  ? theme.colorScheme.primary
                                      .withOpacity(0.15)
                                  : Colors.transparent,
                              child: Row(
                                children: [
                                  Icon(
                                    sel
                                        ? Icons.radio_button_checked_rounded
                                        : Icons
                                            .radio_button_unchecked_rounded,
                                    size: 18,
                                    color: sel
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface
                                            .withOpacity(0.4),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      r,
                                      style: kNoDeco.copyWith(
                                        fontSize: 13.5,
                                        fontWeight: sel
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 12),
          ActionBtn(
            label: 'تطبيق الفلتر',
            icon: Icons.filter_alt_rounded,
            gradient: const [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
            busy: _filtering,
            onTap: _filtering ? null : _applyFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    final show = _filterApplied;
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'الكلي',
            value: show ? _stats.total : 0,
            icon: Icons.list_alt_rounded,
            colors: const [Color(0xFF6C5CE7), Color(0xFF8E7CFF)],
            loading: _loadingStats,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            label: 'متاحة',
            value: show ? _stats.available : 0,
            icon: Icons.check_circle_rounded,
            colors: const [Color(0xFF00B894), Color(0xFF00D68F)],
            loading: _loadingStats,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            label: 'مضافة',
            value: show ? _stats.added : 0,
            icon: Icons.person_add_rounded,
            colors: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            loading: _loadingStats,
          ),
        ),
      ],
    );
  }

  Widget _buildAddCard(ThemeData theme) {
    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label(theme, Icons.add_circle_outline_rounded, 'إضافة أرقام'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'عدد الأرقام',
                  style: kNoDeco.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.75),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _countToAdd,
                    dropdownColor: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    style: kNoDeco.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    items: _countOptions
                        .map((v) => DropdownMenuItem<int>(
                              value: v,
                              child: Text('$v'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _countToAdd = v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _userCtrl,
            decoration: const InputDecoration(
              labelText: 'اسم اليوزر',
              hintText: 'مثال: OR1Ahmed',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          ActionBtn(
            label: _adding ? 'جاري الإضافة…' : 'إضافة الأرقام',
            icon: _addDone
                ? Icons.check_circle_rounded
                : Icons.person_add_alt_1_rounded,
            gradient: _addDone
                ? const [Color(0xFF00B894), Color(0xFF00D68F)]
                : const [Color(0xFF6C5CE7), Color(0xFF00D2FF)],
            busy: _adding,
            onTap: _adding ? null : _addNumbers,
          ),
        ],
      ),
    );
  }

  Widget _card(ThemeData theme, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
      ),
      child: child,
    );
  }

  Widget _label(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: kNoDeco.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.85),
          ),
        ),
      ],
    );
  }
}