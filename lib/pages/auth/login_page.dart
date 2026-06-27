// ════════════════════════════════════════════════════════
// login_page.dart — 소셜 로그인 화면
// 카카오 / 네이버 / 구글 / 애플
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;

  Future<void> _login(String type) async {
    setState(() => _loading = true);
    try {
      // TODO: 실제 OAuth SDK로 socialId/nickname 취득
      // 임시: 데모용 소셜 로그인 (서버에 demo 계정 생성)
      await AuthService.instance.socialLogin(
        provider: type,
        socialId: 'demo_${type}_001',
        nickname: '마이밍유저',
      );
      if (!mounted) return;
      await context.read<AppState>().enableApi();
    } catch (_) {
      // API 연결 불가 시 게스트 모드로 진입
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _guestLogin() async {
    // 게스트: API 비활성화 상태로 진입
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 로고
              Column(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(24)),
                  child: const Center(child: Text('🏠', style: TextStyle(fontSize: 40))),
                ),
                const SizedBox(height: 16),
                Text('마이밍', style: AppTheme.headline1.copyWith(color: AppColors.primary, fontSize: 28)),
                const SizedBox(height: 6),
                Text('걸을수록 월세가 내려가는\n만보기 리워드 서비스', style: AppTheme.caption.copyWith(fontSize: 13, height: 1.6), textAlign: TextAlign.center),
              ]),

              const Spacer(flex: 2),

              // 가입 혜택 배너
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primaryDim, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const Text('🎁', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('신규 가입 혜택', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primary)),
                    const SizedBox(height: 2),
                    Text('첫 회원가입 시 ₩100 즉시 지급 + 만보 부스트 1일 무료', style: AppTheme.caption.copyWith(height: 1.4)),
                  ])),
                ]),
              ),

              const SizedBox(height: 24),

              // 소셜 로그인 버튼들
              if (_loading)
                const CircularProgressIndicator(color: AppColors.primary)
              else ...[
                _SocialBtn(
                  color: const Color(0xFFFEE500), textColor: const Color(0xFF191600),
                  icon: '💬', label: '카카오로 시작하기',
                  onTap: () => _login('kakao'),
                ),
                const SizedBox(height: 10),
                _SocialBtn(
                  color: const Color(0xFF03C75A), textColor: Colors.white,
                  icon: 'N', label: '네이버로 시작하기',
                  onTap: () => _login('naver'), iconText: true,
                ),
                const SizedBox(height: 10),
                _SocialBtn(
                  color: Colors.white, textColor: AppColors.text,
                  icon: '🔵', label: 'Google로 시작하기',
                  onTap: () => _login('google'),
                ),
                const SizedBox(height: 10),
                _SocialBtn(
                  color: Colors.black, textColor: Colors.white,
                  icon: '', label: 'Apple로 시작하기',
                  onTap: () => _login('apple'), iconText: true, appleIcon: true,
                ),
              ],

              const SizedBox(height: 16),

              // 게스트 체험
              TextButton(
                onPressed: _guestLogin,
                child: const Text('로그인 없이 체험하기 ›', style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ),

              const Spacer(),

              // 약관
              Text('로그인 시 이용약관 및 개인정보처리방침에 동의합니다', style: AppTheme.caption.copyWith(fontSize: 10), textAlign: TextAlign.center),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool iconText;
  final bool appleIcon;

  const _SocialBtn({
    required this.color, required this.textColor, required this.icon,
    required this.label, required this.onTap, this.iconText = false, this.appleIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color == Colors.white ? AppColors.border : Colors.transparent),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            const SizedBox(width: 18),
            appleIcon
                ? Icon(Icons.apple, color: textColor, size: 20)
                : iconText
                    ? Text(icon, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16))
                    : Text(icon, style: const TextStyle(fontSize: 20)),
            const Spacer(),
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textColor)),
            const Spacer(),
            const SizedBox(width: 38),
          ],
        ),
      ),
    );
  }
}
