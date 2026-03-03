//
//  AppOpenViewController.m
//  OpAdxSdkDemo_OC
//
//  Created by Luan Chen on 2026/1/26.
//

#import "AppOpenViewController.h"
#import <OpAdxSdk/OpAdxSdk.h>

@interface AppOpenViewController ()<OpAdxAppOpenAdDelegate>

@property (nonatomic, strong, nullable) OpAdxAppOpenAdBridge *appOpenAd;

@end

@implementation AppOpenViewController

- (BOOL)hasVideo {
    return YES;
}

- (AdFormat)adFormat {
    return AdFormatAppOpen;
}

- (NSString *)adFormatString {
    return @"AppOpen Ad";
}

- (void)loadAd {
    if (!self.placementId) return;
    
    [self.logView print:@"Loading ..."];
    if (self.appOpenAd != nil) {
        [self destroyAd];
    }
    
    OpAdxAppOpenAdBridge *appOpenAd = [[OpAdxAppOpenAdBridge alloc] initWithPlacementId:self.placementId auctionType: AdAuctionTypeRegular];
    self.appOpenAd = appOpenAd;
    appOpenAd.delegate = self;
    [appOpenAd loadAd];
}

- (void)showAd {
    if (!self.appOpenAd) return;
    
    if (![self.appOpenAd isAdValid]) {
        [self.logView print:@"Ad is invalidated."];
        [self destroyAd];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.appOpenAd showAdFrom:weakSelf];
    });
    
    [self enableDestroyAd];
    [self disableShowAd];
}

- (void)destroyAd {
    [super destroyAd];
    self.appOpenAd = nil;
    [self disableDestroyAd];
    [self disableShowAd];
}

#pragma mark - OpAdxAppOpenAdDelegate

- (void)appOpenAdDidLoad:(OpAdxAppOpenAdBridge *)appOpenAd {
    NSLog(@"[ADX] AppOpen广告加载成功: %@", appOpenAd.placementId);
    [self.logView print:[NSString stringWithFormat:@"Loaded."]];
   
    [self enableShowAd];
    [self enableDestroyAd];
    
}

- (void)appOpenAd:(OpAdxAppOpenAdBridge *)appOpenAd didFailWithError:(OpAdxAdError *)error {
    NSLog(@"[ADX] AppOpen广告加载失败: %@ %@", appOpenAd.placementId, error);
    [self.logView print:error.message];
    
}

- (void)appOpenAdDidClick:(OpAdxAppOpenAdBridge *)appOpenAd {
    NSLog(@"[ADX] AppOpen广告被点击: %@", appOpenAd.placementId);
    [self.logView print:@"onAdDidClick"];
    
}

- (void)appOpenAdDidClose:(OpAdxAppOpenAdBridge *)appOpenAd {
    NSLog(@"[ADX] AppOpen广告关闭: %@", appOpenAd.placementId);
    [self.logView print:@"onAdDidClose"];
    // 清理
    self.appOpenAd = nil;

}

- (void)appOpenAdWillLogImpression:(OpAdxAppOpenAdBridge *)appOpenAd {
    NSLog(@"[ADX] AppOpen广告展示: %@", appOpenAd.placementId);
    [self.logView print:@"onAdImpression"];
    
}

@end
