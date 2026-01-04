//
//  OpAdxNativeAdView.m
//  OPNews
//
//  Created by Luan Chen on 2025/12/8.
//  Copyright © 2025 Luan Chen. All rights reserved.
//

#import "OpAdxNativeAdView.h"

@interface OpAdxNativeAdView ()

// MARK: - UI Components
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UILabel *starRatingLabel;
@property (nonatomic, strong) UIButton *callToActionButton;
@property (nonatomic, strong) OpAdxMediaView *mediaView;
@property (nonatomic, strong) UIImageView *iconView;

// MARK: - Properties
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *starRatingConstraints;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *titleConstraints;
//@property (nonatomic, strong, readonly) OpAdxInteractionViews *interactionViews;

@end

@implementation OpAdxNativeAdView

@synthesize interactionViews = _interactionViews;

// MARK: - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupNativeAdView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupNativeAdView];
    }
    return self;
}

// MARK: - Setup

- (void)setupNativeAdView {
    [self setupAppearance];
    [self createSubviews];
    [self addSubviews];
    [self setupConstraints];
}

- (void)createSubviews {
    // 创建子视图
    _titleLabel = [[UILabel alloc] init];
    _bodyLabel = [[UILabel alloc] init];
    _starRatingLabel = [[UILabel alloc] init];
    _callToActionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _mediaView = [[OpAdxMediaView alloc] init];
    _iconView = [[UIImageView alloc] init];
}

- (void)setupAppearance {
    self.backgroundColor = [UIColor systemGray6Color];
    self.layer.cornerRadius = 8;
    
    // 标题标签
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = [UIColor labelColor];
    self.titleLabel.numberOfLines = 2;
    
    // 正文标签
    self.bodyLabel.font = [UIFont systemFontOfSize:14];
    self.bodyLabel.textColor = [UIColor secondaryLabelColor];
    self.bodyLabel.numberOfLines = 2;
    
    // 星级评分标签
    self.starRatingLabel.font = [UIFont systemFontOfSize:12];
    self.starRatingLabel.textColor = [UIColor systemYellowColor];
    self.starRatingLabel.hidden = YES;
    
    // 行动按钮
    self.callToActionButton.backgroundColor = [UIColor systemBlueColor];
    [self.callToActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.callToActionButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.callToActionButton.layer.cornerRadius = 4;
    self.callToActionButton.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
    self.callToActionButton.hidden = YES;
    
    // 媒体视图
    self.mediaView.backgroundColor = [UIColor systemGray4Color];
    self.mediaView.contentMode = UIViewContentModeScaleAspectFill;
    self.mediaView.clipsToBounds = YES;
    
    // 图标视图
    self.iconView.backgroundColor = [UIColor systemGray3Color];
    self.iconView.layer.cornerRadius = 4;
    self.iconView.clipsToBounds = YES;
    self.iconView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)addSubviews {
    [self addSubview:self.mediaView];
    [self addSubview:self.iconView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.bodyLabel];
    [self addSubview:self.starRatingLabel];
    [self addSubview:self.callToActionButton];
}

- (void)setupConstraints {
    // 禁用自动转换
    NSArray<UIView *> *subviews = @[
        self.mediaView,
        self.iconView,
        self.titleLabel,
        self.bodyLabel,
        self.starRatingLabel,
        self.callToActionButton
    ];
    
    for (UIView *view in subviews) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    // 基本约束
    NSArray<NSLayoutConstraint *> *baseConstraints = @[
        // 图标
        [self.iconView.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:12],
        [self.iconView.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor constant:12],
        [self.iconView.widthAnchor constraintEqualToConstant:40],
        [self.iconView.heightAnchor constraintEqualToConstant:40],
        
        // 媒体视图
        [self.mediaView.topAnchor constraintEqualToAnchor:self.iconView.bottomAnchor constant:12],
        [self.mediaView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.mediaView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.mediaView.heightAnchor constraintGreaterThanOrEqualToAnchor:self.mediaView.widthAnchor multiplier:0.5],
        
        // 正文
        [self.bodyLabel.topAnchor constraintEqualToAnchor:self.mediaView.bottomAnchor constant:12],
        [self.bodyLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12],
        [self.bodyLabel.trailingAnchor constraintEqualToAnchor:self.callToActionButton.leadingAnchor constant:-8],
        [self.bodyLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8],
        
        // 行动按钮
        [self.callToActionButton.topAnchor constraintEqualToAnchor:self.mediaView.bottomAnchor constant:12],
        [self.callToActionButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12],
        [self.callToActionButton.widthAnchor constraintGreaterThanOrEqualToConstant:100],
        [self.callToActionButton.heightAnchor constraintEqualToConstant:36],
        [self.callToActionButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8]
    ];
    
    [NSLayoutConstraint activateConstraints:baseConstraints];
    
    // 初始化标题约束
    [self updateTitleLabelConstraints];
}

// MARK: - Public API

- (OpAdxInteractionViews *)interactionViews {
    if (!_interactionViews) {
        _interactionViews = [[OpAdxInteractionViews alloc] initWithMediaView:self.mediaView
                                                                   titleView:self.titleLabel
                                                                    bodyView:self.bodyLabel
                                                            callToActionView:self.callToActionButton
                                                                    iconView:self.iconView];
    }
    return _interactionViews;
}

- (void)configureWithNativeAd:(OpAdxNativeAdBridge *)nativeAd {
    self.titleLabel.text = [nativeAd title];
    self.bodyLabel.text = [nativeAd adDescription];
    
    // 配置星级评分
    NSNumber *rating = [nativeAd starRating];
    if (rating != nil) {
        self.starRatingLabel.text = [NSString stringWithFormat:@"★ %.1f", rating.floatValue];
        self.starRatingLabel.hidden = NO;
    } else {
        self.starRatingLabel.hidden = YES;
    }
    
    // 配置行动按钮
    NSString *ctaText = [nativeAd callToAction];
    if (ctaText != nil && ctaText.length > 0) {
        [self.callToActionButton setTitle:ctaText forState:UIControlStateNormal];
        self.callToActionButton.hidden = NO;
    } else {
        self.callToActionButton.hidden = YES;
    }
    
    // 更新布局约束
    [self updateTitleLabelConstraints];
}

- (void)clearContent {
    self.titleLabel.text = nil;
    self.bodyLabel.text = nil;
    self.starRatingLabel.text = nil;
    self.starRatingLabel.hidden = YES;
    [self.callToActionButton setTitle:nil forState:UIControlStateNormal];
    self.callToActionButton.hidden = YES;
    [self updateTitleLabelConstraints];
}

// MARK: - Layout

- (void)updateTitleLabelConstraints {
    // 移除旧的约束
    if (self.titleConstraints) {
        [NSLayoutConstraint deactivateConstraints:self.titleConstraints];
    }
    
    NSMutableArray<NSLayoutConstraint *> *newConstraints = [NSMutableArray array];
    
    if (self.starRatingLabel.hidden) {
        // 无星级评分时，标题居中于图标
        [newConstraints addObjectsFromArray:@[
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.iconView.trailingAnchor constant:8],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12-24],
            [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.iconView.centerYAnchor]
        ]];
    } else {
        // 有星级评分时，标题在图标顶部
        [newConstraints addObjectsFromArray:@[
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.iconView.trailingAnchor constant:8],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12-24],
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.iconView.topAnchor],
            [self.titleLabel.heightAnchor constraintEqualToConstant:20],
            
            // 星级评分在标题下方
            [self.starRatingLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
            [self.starRatingLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],
            [self.starRatingLabel.bottomAnchor constraintEqualToAnchor:self.iconView.bottomAnchor],
            [self.starRatingLabel.heightAnchor constraintEqualToConstant:16]
        ]];
    }
    
    self.titleConstraints = [newConstraints copy];
    [NSLayoutConstraint activateConstraints:self.titleConstraints];
    
    // 更新布局
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 确保隐私图标在最上层
    // if (self.hasAdChoiceView) {
    //     [self bringSubviewToFront:self.subviews.lastObject];
    // }
}

// MARK: - Memory Management

- (void)dealloc {
    NSLog(@"OpAdxNativeAdView dealloc");
}

@end
