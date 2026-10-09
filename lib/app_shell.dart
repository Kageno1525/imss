import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'web_scripts.dart';
import 'home_page.dart';
import 'widgets.dart';

const String kLoginUrl = 'https://imssms.org/login';
const String kNumbersUrl = 'https://imssms.org/numbers';

enum Stage { loading, ready }

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  InAppWebViewController? _web;
  late final Widget _webView;

  Stage _stage = Stage.loading;
  String _statusMsg = 'جاري فتح الموقع…';
  String _currentUrl = '';
  bool _showWeb = false;

  @override
  void initState() {
    super.initState();
    _webView = InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(kLoginUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        cacheEnabled: true,
        thirdPartyCookiesEnabled: true,
        sharedCookiesEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      onWebViewCreated: (c) {
        _web = c;
        debugPrint('WebView created');
      },
      onLoadStart: (c, url) {
        debugPrint('loadStart: ${url?.toString()}');
        if (mounted) setState(() => _currentUrl = url?.toString() ?? '');
      },
      onLoadStop: (c, url) async {
        final u = url?.toString() ?? '';
        debugPrint('loadStop: $u');
        if (mounted) setState(() => _currentUrl = u);

        // لو في صفحة login → سجّل
        if (u.contains('/login')) {
          await _tryLogin();
        }
        // لو في صفحة numbers → تمام
        else if (u.contains('/numbers')) {
          if (mounted) {
            setState(() {
              _stage = Stage.ready;
              _statusMsg = 'جاهز';
            });
          }
        }
        // لو في صفحة تانية (home مثلاً) → روح numbers
        else if (u.contains('imssms.org') &&
            !u.contains('/numbers') &&
            !u.contains('/login')) {
          try {
            await _web?.loadUrl(
                urlRequest: URLRequest(url: WebUri(kNumbersUrl)));
          } catch (_) {}
        }
      },
      onReceivedError: (c, req, err) {
        debugPrint('error: ${err.description}');
      },
    );
  }

  Future<void> _tryLogin() async {
    if (!mounted) return;
    setState(() => _statusMsg = 'جاري تسجيل الدخول…');

    for (int i = 0; i < 15; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_web == null) continue;
      final r = await _eval(WebScripts.fillLogin);
      debugPrint('fillLogin[$i]: $r');
      if (r == 'ok') break;
    }

    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;
    setState(() => _statusMsg = 'جاري فتح صفحة الأرقام…');

    try {
      await _web?.loadUrl(urlRequest: URLRequest(url: WebUri(kNumbersUrl)));
    } catch (_) {}
  }

  Future<String> _eval(String js) async {
    if (_web == null) return 'no-web';
    try {
      final raw = await _web!.evaluateJavascript(source: js);
      return _unwrap(raw);
    } catch (e) {
      return 'err:$e';
    }
  }

  String _unwrap(dynamic raw) {
    if (raw == null) return '';
    var s = raw.toString().trim();
    if (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) {
      s = s.substring(1, s.length - 1)
          .replaceAll(r'\"', '"')
          .replaceAll(r'\\', r'\');
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ═══ 1) شاشة التحميل ═══
    if (_stage == Stage.loading) {
      return Scaffold(
        body: Stack(
          children: [
            // WebView دايماً موجود (مخفي تحت)
            Positioned.fill(child: _webView),

            // شاشة التحميل فوق
            Positioned.fill(
              child: Container(
                color: theme.scaffoldBackgroundColor,
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6C5CE7),
                                Color(0xFF00D2FF)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C5CE7)
                                    .withOpacity(0.5),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.sms_rounded,
                              color: Colors.white, size: 44),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'imss',
                          style: kNoDeco.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.15),
                            color: theme.colorScheme.primary,
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _statusMsg,
                          style: kNoDeco.copyWith(
                            fontSize: 13,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // ⭐ نشوف الويندو بدل ما نفضل نستنى
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _showWeb = true),
                          icon: const Icon(Icons.visibility_rounded, size: 18),
                          label: const Text('شوف الموقع'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // زر "إخفاء" لو المستخدم فتح الـ WebView
            if (_showWeb)
              Positioned(
                top: 40,
                right: 16,
                child: SafeArea(
                  child: Material(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => setState(() => _showWeb = false),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_off_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text('إخفاء',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // ═══ 2) الصفحة الرئيسية ═══
    if (_showWeb) {
      // WebView ظاهر
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: _webView),
            Positioned(
              top: 40,
              right: 16,
              child: SafeArea(
                child: Material(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => setState(() => _showWeb = false),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_off_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text('إخفاء',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // HomePage ظاهر فوق الـ WebView
    return Scaffold(
      body: Stack(
        children: [
          // WebView تحت (مخفي بس شغال)
          Positioned.fill(child: _webView),

          // HomePage فوق
          Positioned.fill(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: HomePage(
                evalJs: _eval,
                onReload: () async {
                  setState(() {
                    _stage = Stage.loading;
                    _statusMsg = 'جاري إعادة التحميل…';
                  });
                  try {
                    await _web?.loadUrl(
                        urlRequest: URLRequest(url: WebUri(kLoginUrl)));
                  } catch (_) {}
                },
                onToggleWeb: () => setState(() => _showWeb = true),
                currentUrl: _currentUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}