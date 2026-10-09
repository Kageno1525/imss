import 'widgets.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'web_scripts.dart';
import 'home_page.dart';

const String kLoginUrl = 'https://imssms.org/login';
const String kNumbersUrl = 'https://imssms.org/numbers';

enum Stage { loading, ready, error }

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
      },
      onLoadStop: (c, url) async {
        final u = url?.toString() ?? '';
        if (u.contains('/login')) {
          await _tryLogin();
        } else if (u.contains('/numbers')) {
          // تمام، إحنا في صفحة الأرقام
          if (mounted) {
            setState(() {
              _stage = Stage.ready;
              _statusMsg = 'جاهز';
            });
          }
        }
      },
    );
  }

  Future<void> _tryLogin() async {
    if (!mounted) return;
    setState(() => _statusMsg = 'جاري تسجيل الدخول…');

    // جرّب 10 مرات لحد ما الفورم يظهر
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_web == null) continue;

      final r = await _eval(WebScripts.fillLogin);
      if (r == 'ok') break;
    }

    // استنى الصفحة تتغير
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;
    setState(() => _statusMsg = 'جاري فتح صفحة الأرقام…');

    // روح على صفحة الأرقام
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

  // ═══════ API للصفحة الرئيسية ═══════
  Future<String> evalJs(String js) => _eval(js);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // WebView
          Positioned.fill(child: _webView),

          // الواجهة
          if (_stage == Stage.loading)
            Positioned.fill(
              child: Container(
                color: theme.scaffoldBackgroundColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C5CE7), Color(0xFF00D2FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C5CE7).withOpacity(0.5),
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
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.15),
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
                    ],
                  ),
                ),
              ),
            ),

          if (_stage == Stage.ready)
            Positioned.fill(
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
              ),
            ),
        ],
      ),
    );
  }
}