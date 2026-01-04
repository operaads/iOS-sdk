//
//  LogView.m
//  OpAdxDemo_iOS
//
//  Created by Luan Chen on 2025/12/10.
//

#import "LogView.h"

@interface LogView ()

@property (nonatomic, strong, nullable) UITextView *textView;
@property (nonatomic, strong, nullable) UIScrollView *scrollView;

@end

@implementation LogView

- (void)setupInView:(UIView *)view {
    self.scrollView = [[UIScrollView alloc] init];
    self.textView = [[UITextView alloc] init];
    
    self.textView.editable = NO;
    self.textView.scrollEnabled = NO;
    self.textView.font = [UIFont systemFontOfSize:12];
    self.textView.backgroundColor = [UIColor systemGray6Color];
    
    [self.scrollView addSubview:self.textView];
    [view addSubview:self.scrollView];
}

- (void)setupConstraintsInView:(UIView *)view belowAnchorView:(UIView *)anchorView {
    if (!self.scrollView || !self.textView) return;
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILayoutGuide *safeArea = view.safeAreaLayoutGuide;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:anchorView.bottomAnchor constant:20],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:20],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-20],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor constant:-20],
        
        [self.textView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.textView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.textView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.textView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.textView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor]
    ]];
}

- (void)print:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.textView || !self.scrollView) return;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm:ss";
        NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *logMessage = [NSString stringWithFormat:@"[%@] %@\n", timestamp, message];
        
        // 保存当前文本并追加新内容
        NSString *oldText = self.textView.text ?: @"";
        self.textView.text = [oldText stringByAppendingString:logMessage];
        
        // 强制布局更新
        [self.textView layoutIfNeeded];
        
        // 计算并设置滚动位置
        CGFloat textHeight = self.textView.contentSize.height;
        CGFloat scrollHeight = self.scrollView.bounds.size.height;
        
        if (textHeight > scrollHeight) {
            CGPoint bottomOffset = CGPointMake(0, textHeight - scrollHeight + 20);
            [self.scrollView setContentOffset:bottomOffset animated:NO];
        }
    });
}

@end
