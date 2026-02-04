//
//  BaseViewController.h
//  OpAdxDemo_OC
//
//  Created by Luan Chen on 2025/12/10.
//

#import <UIKit/UIKit.h>
#import <OpAdxSdk/OpAdxSdk.h>
#import "LogView.h"
#import "AdConfig.h"

@interface BaseViewController : UIViewController

@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, strong, readonly) LogView *logView;
@property (nonatomic, strong, readonly) UIView *adContainer;

// Properties to override
@property (nonatomic, readonly) BOOL hasVideo;
@property (nonatomic, readonly) AdFormat adFormat;
@property (nonatomic, readonly) NSString *adFormatString;

// Methods to override
- (void)loadAd;
- (void)showAd;
- (void)destroyAd;

// Button state management
- (void)enableShowAd;
- (void)disableShowAd;
- (void)enableDestroyAd;
- (void)disableDestroyAd;

// Video related
- (BOOL)isVideoItem;

@end
