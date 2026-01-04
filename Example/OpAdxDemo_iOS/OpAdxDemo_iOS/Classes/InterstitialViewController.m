//
//  InterstitialViewController.m
//  OpAdxDemo_iOS
//
//  Created by Luan Chen on 2025/12/10.
//

#import "InterstitialViewController.h"
#import <OpAdxSdk/OpAdxSdk-Swift.h>


@interface InterstitialViewController ()<OpAdxInterstitialAdDelegate>

@property (nonatomic, strong, nullable) OpAdxInterstitialAdBridge *interstitialAd;

@end

@implementation InterstitialViewController

- (BOOL)hasVideo {
    return YES;
}

- (AdFormat)adFormat {
    return AdFormatInterstitial;
}

- (NSString *)adFormatString {
    return @"Interstitial Ad";
}

- (void)loadAd {
    if (!self.placementId) return;
    
    [self.logView print:@"Loading ..."];
    if (self.interstitialAd != nil) {
        [self destroyAd];
    }
    
    OpAdxInterstitialAdBridge *interstitialAd = [[OpAdxInterstitialAdBridge alloc] initWithPlacementId:self.placementId];
    self.interstitialAd = interstitialAd;
    interstitialAd.delegate = self;
    [interstitialAd loadAd];
}

- (void)showAd {
    if (!self.interstitialAd) return;
    
    if (![self.interstitialAd isAdValid]) {
        [self.logView print:@"Ad is invalidated."];
        [self destroyAd];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.interstitialAd showAdFrom:weakSelf];
    });
    
    [self enableDestroyAd];
    [self disableShowAd];
}

- (void)destroyAd {
    [super destroyAd];
    self.interstitialAd = nil;
    [self disableDestroyAd];
    [self disableShowAd];
}

#pragma mark - OpAdxInterstitialAdDelegate

- (void)interstitialAdDidLoad:(OpAdxInterstitialAdBridge *)interstitialAd {
    NSLog(@"[ADX] Interstitial广告加载成功: %@", interstitialAd.placementID);
    [self.logView print:[NSString stringWithFormat:@"Loaded."]];
   
    [self enableShowAd];
    [self enableDestroyAd];
    
}

- (void)interstitialAd:(OpAdxInterstitialAdBridge *)interstitialAd didFailWithError:(OpAdxAdError *)error {
    NSLog(@"[ADX] Interstitial广告加载失败: %@ %@", interstitialAd.placementID, error);
    [self.logView print:error.message];
    
}

- (void)interstitialAdDidClick:(OpAdxInterstitialAdBridge *)interstitialAd {
    NSLog(@"[ADX] Interstitial广告被点击: %@", interstitialAd.placementID);
    [self.logView print:@"onAdDidClick"];
    
}

- (void)interstitialAdDidClose:(OpAdxInterstitialAdBridge *)interstitialAd {
    NSLog(@"[ADX] Interstitial广告关闭: %@", interstitialAd.placementID);
    [self.logView print:@"onAdDidClose"];
    // 清理
    self.interstitialAd = nil;

}

- (void)interstitialAdWillLogImpression:(OpAdxInterstitialAdBridge *)interstitialAd {
    NSLog(@"[ADX] Interstitial广告展示: %@", interstitialAd.placementID);
    [self.logView print:@"onAdImpression"];
    
}

@end
