// ════════════════════════════════════════════════════════
// webview_game_page.dart — WebView HTML 게임 공통 래퍼
// JavaScript Channel "GameChannel"으로 점수 전달
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import '../../../models/app_state.dart';
import '../../../services/game_service.dart';
import '../../../theme/app_theme.dart';

class WebViewGamePage extends StatefulWidget {
  final String gameId;
  final String emoji;
  final String title;
  final String assetPath; // assets/games/xxx.html

  const WebViewGamePage({
    super.key,
    required this.gameId,
    required this.emoji,
    required this.title,
    required this.assetPath,
  });

  @override
  State<WebViewGamePage> createState() => _WebViewGamePageState();
}

class _WebViewGamePageState extends State<WebViewGamePage> {
  late WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF05091A))
      ..addJavaScriptChannel(
        'GameChannel',
        onMessageReceived: (msg) => _onMessage(msg.message),
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadFlutterAsset(widget.assetPath);
  }

  void _onMessage(String msg) {
    if (msg == 'back') {
      Navigator.pop(context);
      return;
    }
    final earn = int.tryParse(msg);
    if (earn != null && earn > 0) {
      final state = context.read<AppState>();
      if (state.apiEnabled) {
        GameService.instance.submitScore(widget.gameId, earn).then((res) {
          state.walletAmount = res.balance;
          state.addLedger(widget.emoji, '${widget.title} 보상', res.reward, 'earn');
          state.notifyListeners();
        }).catchError((_) => state.earn(widget.emoji, '${widget.title} 보상', earn));
      } else {
        state.earn(widget.emoji, '${widget.title} 보상', earn);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05091A),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 12),
                    Text('로딩 중...', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
