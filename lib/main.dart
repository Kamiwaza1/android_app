import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ekranı immersive (kiosk) moda al
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const KioskBrowserApp());
}

const _prefsKeyUrl = 'kiosk_start_url';
const _defaultUrl = 'https://example.com';

class KioskBrowserApp extends StatelessWidget {
  const KioskBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kiosk Browser',
      theme: ThemeData.dark(),
      home: const _KioskWebViewScreen(),
    );
  }
}

class _KioskWebViewScreen extends StatefulWidget {
  const _KioskWebViewScreen();

  @override
  State<_KioskWebViewScreen> createState() => _KioskWebViewScreenState();
}

class _KioskWebViewScreenState extends State<_KioskWebViewScreen> {
  late final WebViewController _controller;
  String _currentUrl = _defaultUrl;
  bool _showLoading = true;
  int _dpadCenterCount = 0;
  Timer? _dpadTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final startUrl = prefs.getString(_prefsKeyUrl) ?? _defaultUrl;
    setState(() => _currentUrl = startUrl);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _showLoading = true),
        onPageFinished: (_) => setState(() => _showLoading = false),
      ))
      ..loadRequest(Uri.parse(startUrl));
  }

  Future<void> _promptForUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final controller = TextEditingController(text: _currentUrl);
    final newUrl = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Başlangıç URL Ayarla'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'https://'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            TextButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) Navigator.pop(ctx, value);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
    if (newUrl != null && newUrl != _currentUrl) {
      await prefs.setString(_prefsKeyUrl, newUrl);
      setState(() => _currentUrl = newUrl);
      _controller.loadRequest(Uri.parse(newUrl));
    }
  }

  void _onRawKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // DPAD_CENTER veya Enter yakala (Android TV remote)
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
        _dpadCenterCount++;
        _dpadTimer?.cancel();
        _dpadTimer = Timer(const Duration(seconds: 3), () {
          _dpadCenterCount = 0;
        });
        if (_dpadCenterCount >= 5) {
          _dpadCenterCount = 0;
          _promptForUrl();
        }
      }
      // Back tuşu geri gitmesin (kiosk)
      if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.backspace) {
        // ignore back
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: _onRawKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: _showLoading
                  ? const SizedBox.shrink()
                  : WebViewWidget(controller: _controller),
            ),
            if (_showLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dpadTimer?.cancel();
    super.dispose();
  }
}
