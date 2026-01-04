//
//  LogView.h
//  OpAdxDemo_iOS
//
//  Created by Luan Chen on 2025/12/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogView : NSObject

- (void)setupInView:(UIView *)view;
- (void)setupConstraintsInView:(UIView *)view belowAnchorView:(UIView *)anchorView;
- (void)print:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
