//
//  OpAdxNativeAdView.h
//  OPNews
//
//  Created by Luan Chen on 2025/12/8.
//  Copyright © 2025 Luan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpAdxSdk/OpAdxSdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpAdxNativeAdView : UIView

// MARK: - UI Components
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *bodyLabel;
@property (nonatomic, strong, readonly) UILabel *starRatingLabel;
@property (nonatomic, strong, readonly) UIButton *callToActionButton;
@property (nonatomic, strong, readonly) OpAdxMediaView *mediaView;
@property (nonatomic, strong, readonly) UIImageView *iconView;

// MARK: - Public API

/// 获取交互视图，用于注册广告点击
@property (nonatomic, strong) OpAdxInteractionViews *interactionViews;

/// 配置广告内容
/// - Parameter nativeAd: 原生广告数据
- (void)configureWithNativeAd:(OpAdxNativeAdBridge *)nativeAd;

/// 清理视图状态
- (void)clearContent;

@end

NS_ASSUME_NONNULL_END
