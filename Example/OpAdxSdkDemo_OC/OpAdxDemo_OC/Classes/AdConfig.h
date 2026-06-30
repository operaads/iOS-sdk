//
//  AdConfig.h
//  OpAdxDemo_OC
//
//  Created by Luan Chen on 2025/12/10.
//

#import <Foundation/Foundation.h>
#import <OpAdxSdk/OpAdxSdk.h>

NS_ASSUME_NONNULL_BEGIN

// 广告类型枚举
typedef NS_ENUM(NSInteger, AdFormat) {
    AdFormatNative = 0,
    AdFormatBanner,
    AdFormatInterstitial,
    AdFormatReward,
    AdFormatAppOpen,
    AdFormatRewardedInterstitial,
};

@interface AdConfig : NSObject

+ (NSString *)applicationId;
+ (NSString *)iOSAppId;

+ (NSString *)getPlacementIdWithAdFormat:(AdFormat)adFormat forceVideo:(BOOL)forceVideo;

@end

NS_ASSUME_NONNULL_END
