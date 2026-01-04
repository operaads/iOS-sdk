//
//  RewardedViewController.m
//  OpAdxDemo_iOS
//
//  Created by Luan Chen on 2025/12/10.
//

#import "RewardedViewController.h"
#import <OpAdxSdk/OpAdxSdk-Swift.h>


@interface RewardedViewController ()<OpAdxRewardedAdDelegate>

@property (nonatomic, strong, nullable) OpAdxRewardedAdBridge *rewardedAd;

@end

@implementation RewardedViewController

- (BOOL)hasVideo {
    return NO;
}

- (AdFormat)adFormat {
    return AdFormatReward;
}

- (NSString *)adFormatString {
    return @"Rewarded Ad";
}

- (void)loadAd {
    if (!self.placementId) return;
    
    [self.logView print:@"Loading ..."];
    if (self.rewardedAd != nil) {
        [self destroyAd];
    }
    
    OpAdxRewardedAdBridge *rewardedAd = [[OpAdxRewardedAdBridge alloc] initWithPlacementId:self.placementId];
    self.rewardedAd = rewardedAd;
    rewardedAd.delegate = self;
    [rewardedAd loadAd];
    
}

- (void)showAd {
    if (!self.rewardedAd) return;
    
    if (![self.rewardedAd isAdValid]) {
        [self.logView print:@"Ad is invalidated."];
        [self destroyAd];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.rewardedAd showAdFrom:weakSelf];
    });
    
    [self enableDestroyAd];
    [self disableShowAd];
}

- (void)destroyAd {
    [super destroyAd];
    self.rewardedAd = nil;
    [self disableDestroyAd];
    [self disableShowAd];
}

#pragma mark - OpAdxRewardedAdDelegate

- (void)rewardedAdDidLoad:(OpAdxRewardedAdBridge *)rewardedAd {
    NSLog(@"[ADX] Reward广告加载成功: %@", rewardedAd.placementID);
    [self.logView print:[NSString stringWithFormat:@"Loaded."]];
   
    [self enableShowAd];
    [self enableDestroyAd];    

}

- (void)rewardedAd:(OpAdxRewardedAdBridge *)rewardedAd didFailWithError:(OpAdxAdError *)error {
    NSLog(@"[ADX] Reward广告加载失败: %@", error);
    [self.logView print:error.message];
    
}

- (void)rewardedAdDidClick:(OpAdxRewardedAdBridge *)rewardedAd {
    NSLog(@"[ADX] Reward广告被点击: %@", rewardedAd.placementID);
    [self.logView print:@"onAdDidClick"];
    
}

- (void)rewardedAdDidClose:(OpAdxRewardedAdBridge *)rewardedAd {
    NSLog(@"[ADX] Reward广告关闭: %@", rewardedAd.placementID);
    [self.logView print:@"onAdDidClose"];
    
    // 清理
    self.rewardedAd = nil;
}

- (void)rewardedAd:(OpAdxRewardedAdBridge *)rewardedAd didRewardUserWithItem:(OpAdxRewardItem *)rewardItem {
    NSLog(@"[ADX] Reward广告发放奖励: %@, 奖励类型: %@, 数量: %ld",
          rewardedAd.placementID,
          rewardItem.type,
          (long)rewardItem.amount);
    [self.logView print:@"onAdReward"];
    
}

- (void)rewardedAdWillLogImpression:(OpAdxRewardedAdBridge *)rewardedAd {
    NSLog(@"[ADX] Reward广告展示: %@", rewardedAd.placementID);
    [self.logView print:@"onAdImpression"];
    
}
@end
