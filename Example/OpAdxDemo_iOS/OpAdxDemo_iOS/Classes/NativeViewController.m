//
//  NativeViewController.m
//  OpAdxDemo_iOS
//
//  Created by Luan Chen on 2025/12/10.
//

#import "NativeViewController.h"
#import "OpAdxNativeAdView.h"
#import <OpAdxSdk/OpAdxSdk-Swift.h>


@interface NativeViewController ()<OpAdxNativeAdDelegate>

@property (nonatomic, strong, nullable) OpAdxNativeAdBridge *nativeAd;

@end

@implementation NativeViewController

- (AdFormat)adFormat {
    return AdFormatNative;
}

- (NSString *)adFormatString {
    return @"Native Ad";
}

- (void)loadAd {
    if (!self.placementId) {
        [self.logView print:@"error, placementId is nil!"];
        return;
    }
    if (self.nativeAd != nil) {
        [self destroyAd];
    }
    
    [self.logView print:@"Loading..."];
    
    OpAdxNativeAdBridge *nativeAd = [[OpAdxNativeAdBridge alloc] initWithPlacementID:self.placementId];
    self.nativeAd = nativeAd;
    nativeAd.delegate = self;
    [nativeAd loadAd];
}

- (void)showAd {
    if (!self.nativeAd || [self.nativeAd isAdInvalidated]) {
        [self.logView print:@"Ad is invalidated."];
        [self destroyAd];
        return;
    }
    OpAdxNativeAdView *nativeAdView = [[OpAdxNativeAdView alloc]initWithFrame: CGRectMake(0, 0, 400, self.view.bounds.size.height-12*2)];
    
    // 创建并配置原生广告视图
    
    [nativeAdView configureWithNativeAd:self.nativeAd];
    
    nativeAdView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 设置媒体视图的缩放类型
    [nativeAdView.interactionViews.mediaView setImageScaleType: UIViewContentModeScaleAspectFill];
    
    // 将 NativeAdRootView 添加到容器
    [self.adContainer addSubview: nativeAdView];
    NSArray<NSLayoutConstraint *> *constraints = @[
        // 图标
        [nativeAdView.topAnchor constraintEqualToAnchor:self.adContainer.topAnchor],
        [nativeAdView.leadingAnchor constraintEqualToAnchor:self.adContainer.leadingAnchor],
        [nativeAdView.widthAnchor constraintEqualToAnchor:self.adContainer.widthAnchor],
        [nativeAdView.heightAnchor constraintEqualToAnchor:self.adContainer.heightAnchor],
    ];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    OpAdxNativeAdRootView *rootView = [[OpAdxNativeAdRootView alloc]initWithRoot:nativeAdView];
    [self.nativeAd registerViewForInteractionWithRootView:rootView interactionViews:nativeAdView.interactionViews adChoicePosition: AdChoicePositionTopRight];
    
    [self disableShowAd];
    [self enableDestroyAd];
}

- (void)destroyAd {
    [super destroyAd];
    [self.nativeAd destroy];
    self.nativeAd = nil;
    [self disableShowAd];
    [self disableDestroyAd];
    [self.logView print:@"Destroyed..."];
}

#pragma mark - OpAdxNativeAdDelegate

- (void)nativeAdDidLoad:(OpAdxNativeAdBridge *)nativeAd {
    NSLog(@"[ADX] Native广告加载成功: %@", nativeAd.placementID);
    NSString *title = nativeAd.title;
    if (title && title.length) {
        [self.logView print:[NSString stringWithFormat:@"Loaded, ad: %@",title]];
    } else {
        [self.logView print:@"Loaded"];
    }
    [self enableShowAd];
    [self enableDestroyAd];
    
}

- (void)nativeAd:(OpAdxNativeAdBridge *)nativeAd didFailWithError:(OpAdxAdError *)error {
    NSLog(@"[ADX] Native广告加载失败: %@ %@", nativeAd.placementID, error);
    [self.logView print:error.message];
    
}

- (void)nativeAdDidClick:(OpAdxNativeAdBridge *)nativeAd {
    NSLog(@"[ADX] Native广告被点击: %@", nativeAd.placementID);
    [self.logView print:@"onAdClicked"];
}

- (void)nativeAdWillLogImpression:(OpAdxNativeAdBridge *)nativeAd {
    NSLog(@"[ADX] Native广告展示: %@", nativeAd.placementID);
    [self.logView print:@"onAdImpression"];
    
}

@end
