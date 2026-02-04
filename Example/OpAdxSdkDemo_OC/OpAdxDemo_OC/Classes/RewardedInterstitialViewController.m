//
//  RewardedInterstitialViewController.m
//  OpAdxSdkDemo_OC
//
//  Created by Luan Chen on 2026/1/26.
//

#import "RewardedInterstitialViewController.h"
#import <OpAdxSdk/OpAdxSdk.h>

@interface RewardedInterstitialViewController ()<OpAdxRewardedInterstitialAdDelegate>

@property (nonatomic, strong, nullable) OpAdxRewardedInterstitialAdBridge *rewardedInterstitialAd;

@end

@implementation RewardedInterstitialViewController

- (BOOL)hasVideo {
    return YES;
}

- (AdFormat)adFormat {
    return AdFormatRewardedInterstitial;
}

- (NSString *)adFormatString {
    return @"RewardedInterstitial Ad";
}

- (void)loadAd {
    if (!self.placementId) return;
    
    [self.logView print:@"Loading ..."];
    if (self.rewardedInterstitialAd != nil) {
        [self destroyAd];
    }
    
    OpAdxRewardedInterstitialAdBridge *rewardedInterstitialAd = [[OpAdxRewardedInterstitialAdBridge alloc] initWithPlacementId:self.placementId auctionType: AdAuctionTypeRegular];
    self.rewardedInterstitialAd = rewardedInterstitialAd;
    rewardedInterstitialAd.delegate = self;
    [rewardedInterstitialAd loadAd];
}

- (void)showAd {
    if (!self.rewardedInterstitialAd) return;
    
    if (![self.rewardedInterstitialAd isAdValid]) {
        [self.logView print:@"Ad is invalidated."];
        [self destroyAd];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.rewardedInterstitialAd showAdFrom:weakSelf];
    });
    
    [self enableDestroyAd];
    [self disableShowAd];
}

- (void)destroyAd {
    [super destroyAd];
    self.rewardedInterstitialAd = nil;
    [self disableDestroyAd];
    [self disableShowAd];
}

#pragma mark - OpAdxRewardedInterstitialAdDelegate

- (void)rewardedInterstitialAdDidLoad:(OpAdxRewardedInterstitialAdBridge *)rewardedInterstitialAd {
    NSLog(@"[ADX] RewardedInterstitial广告加载成功: %@", rewardedInterstitialAd.placementID);
    [self.logView print:[NSString stringWithFormat:@"Loaded."]];
   
    [self enableShowAd];
    [self enableDestroyAd];
    
}

- (void)rewardedInterstitialAd:(OpAdxRewardedInterstitialAdBridge *)rewardedInterstitialAd didFailWithError:(OpAdxAdError *)error {
    NSLog(@"[ADX] RewardedInterstitial广告加载失败: %@ %@", rewardedInterstitialAd.placementID, error);
    [self.logView print:error.message];
    
}

- (void)rewardedInterstitialAdDidClick:(OpAdxRewardedInterstitialAdBridge *)rewardedInterstitialAd {
    NSLog(@"[ADX] RewardedInterstitial广告被点击: %@", rewardedInterstitialAd.placementID);
    [self.logView print:@"onAdDidClick"];
    
}

- (void)rewardedInterstitialAdDidClose:(OpAdxRewardedInterstitialAdBridge *)rewardedInterstitialAd {
    NSLog(@"[ADX] RewardedInterstitial广告关闭: %@", rewardedInterstitialAd.placementID);
    [self.logView print:@"onAdDidClose"];
    // 清理
    self.rewardedInterstitialAd = nil;

}

- (void)rewardedInterstitialAdWillLogImpression:(OpAdxRewardedInterstitialAdBridge *)rewardedInterstitialAd {
    NSLog(@"[ADX] RewardedInterstitial广告展示: %@", rewardedInterstitialAd.placementID);
    [self.logView print:@"onAdImpression"];
    
}

@end
