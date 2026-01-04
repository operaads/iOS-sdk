//
//  MainTableViewCell.m
//  OpAdxDemo_iOS
//
//  Created by Luan Chen on 2025/12/10.
//

#import "MainTableViewCell.h"
#import "MainViewController.h" // 引入 MainItem 的定义

@implementation MainItem

- (instancetype)initWithFormat:(NSString *)format placementId:(NSString *)placementId {
    self = [super init];
    if (self) {
        _format = format;
        _placementId = placementId;
    }
    return self;
}

@end

@interface MainTableViewCell ()

@property (nonatomic, strong) UILabel *formatLabel;
@property (nonatomic, strong) UILabel *placementLabel;

@end

@implementation MainTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.formatLabel = [[UILabel alloc] init];
    self.formatLabel.font = [UIFont boldSystemFontOfSize:16];
    
    self.placementLabel = [[UILabel alloc] init];
    self.placementLabel.font = [UIFont systemFontOfSize:12];
    self.placementLabel.textColor = [UIColor grayColor];
    self.placementLabel.numberOfLines = 2;
    
    // Objective-C 中使用 UIStackView 需要 iOS 9+，此处采用 UIView 和 AutoLayout 替代
    UIView *stackView = [[UIView alloc] init];
    [stackView addSubview:self.formatLabel];
    [stackView addSubview:self.placementLabel];
    
    self.formatLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.placementLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:stackView];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;

    // 模拟 StackView 的垂直布局和间距
    [NSLayoutConstraint activateConstraints:@[
        // StackView 约束
        [stackView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [stackView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [stackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
        [stackView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
        
        // 内部 Label 约束
        [self.formatLabel.topAnchor constraintEqualToAnchor:stackView.topAnchor],
        [self.formatLabel.leadingAnchor constraintEqualToAnchor:stackView.leadingAnchor],
        [self.formatLabel.trailingAnchor constraintEqualToAnchor:stackView.trailingAnchor],
        
        [self.placementLabel.topAnchor constraintEqualToAnchor:self.formatLabel.bottomAnchor constant:4], // 间距 4
        [self.placementLabel.leadingAnchor constraintEqualToAnchor:stackView.leadingAnchor],
        [self.placementLabel.trailingAnchor constraintEqualToAnchor:stackView.trailingAnchor],
        [self.placementLabel.bottomAnchor constraintLessThanOrEqualToAnchor:stackView.bottomAnchor]
    ]];
}

- (void)configureWithItem:(MainItem *)item {
    self.formatLabel.text = item.format;
    self.placementLabel.text = item.placementId;
}

@end
