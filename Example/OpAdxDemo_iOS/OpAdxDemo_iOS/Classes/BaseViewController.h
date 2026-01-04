//
//  BaseViewController.h
//  OpAdxDemo_iOS
//
//  Created by Luan Chen on 2025/12/10.
//

#import <UIKit/UIKit.h>
#import "LogView.h"
#import "AdConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

@property (nonatomic, copy, nullable) NSString *placementId;
@property (nonatomic, strong, readonly) LogView *logView;
@property (nonatomic, strong, readonly) UIView *adContainer;

// MARK: - Properties to override
@property (nonatomic, assign, readonly) BOOL hasVideo;
@property (nonatomic, assign, readonly) AdFormat adFormat;
@property (nonatomic, copy, readonly) NSString *adFormatString;

// MARK: - Methods to override
- (void)loadAd;
- (void)showAd;
- (void)destroyAd;

// MARK: - Button state management
- (void)enableShowAd;
- (void)disableShowAd;
- (void)enableDestroyAd;
- (void)disableDestroyAd;
- (BOOL)isVideoItem;

@end

NS_ASSUME_NONNULL_END
