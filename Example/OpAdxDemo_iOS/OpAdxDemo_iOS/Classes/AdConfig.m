//
//  AdConfig.m
//  OpAdxDemo_iOS
//
//  Created by Luan Chen on 2025/12/10.
//

#import "AdConfig.h"


@implementation AdConfig

+ (BOOL)useTestAd {
    return YES; //test // only use for test demo, it will false when app is realsed.
}

+ (NSString *)applicationId {
    return @"pub13423013211200/ep13423013211584/app14170937163904";
}

+ (NSString *)iOSAppId {
    return @"1444253128";
}

// iOS Placement IDs
static NSString *const nativePlacementId = @"s14198263063424";
static NSString *const bannerPlacementId = @"s14170965187264";
static NSString *const bannerVideoPlacementId = @"s14198605602880";
static NSString *const interstitialPlacementId = @"s14198264979520";
static NSString *const interstitialVideoPlacementId = @"s14198603681728";
static NSString *const rewardedPlacementId = @"s14198592226752";

+ (NSString *)getPlacementIdWithAdFormat:(AdFormat)adFormat forceVideo:(BOOL)forceVideo {
    
    switch (adFormat) {
        case AdFormatNative:
            return nativePlacementId;
        case AdFormatBanner:
            return forceVideo ? bannerVideoPlacementId : bannerPlacementId;
        case AdFormatInterstitial:
            return forceVideo ? interstitialVideoPlacementId : interstitialPlacementId;
        case AdFormatReward:
            return rewardedPlacementId;
        default:
            return @"";
    }
}

@end
