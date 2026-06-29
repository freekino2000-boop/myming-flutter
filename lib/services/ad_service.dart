import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;

class AdService {
  AdService._();
  static final instance = AdService._();

  // 테스트 광고 단위 ID
  static String get _rewardedId => defaultTargetPlatform == TargetPlatform.iOS
      ? 'ca-app-pub-3940256099942544/1712485313'
      : 'ca-app-pub-3940256099942544/5224354917';

  static String get _bannerId => defaultTargetPlatform == TargetPlatform.iOS
      ? 'ca-app-pub-3940256099942544/2934735716'
      : 'ca-app-pub-3940256099942544/6300978111';

  RewardedAd? _rewardedAd;
  bool _rewardedLoading = false;

  Future<void> loadRewardedAd() async {
    if (_rewardedLoading || _rewardedAd != null) return;
    _rewardedLoading = true;
    final completer = Completer<void>();
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoading = false;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (_) {
          _rewardedLoading = false;
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    await completer.future;
  }

  // 보상형 광고 표시. 광고 시청 완료 시 onRewarded 콜백 호출.
  Future<bool> showRewardedAd({required VoidCallback onRewarded}) async {
    if (_rewardedAd == null) {
      await loadRewardedAd();
      if (_rewardedAd == null) return false;
    }
    bool rewarded = false;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewardedAd = null;
      },
    );
    await _rewardedAd!.show(
      onUserEarnedReward: (_, __) {
        rewarded = true;
        onRewarded();
      },
    );
    return rewarded;
  }

  BannerAd createBannerAd({VoidCallback? onLoaded}) {
    return BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded?.call(),
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );
  }
}
