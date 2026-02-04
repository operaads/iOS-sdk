//
//  BaseViewController.m
//  OpAdxDemo_OC
//
//  Created by Luan Chen on 2025/12/10.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property (nonatomic, strong, readwrite) LogView *logView;
@property (nonatomic, strong, readwrite) UIView *adContainer;

@property (nonatomic, strong) UILabel *adFormatLabel;
@property (nonatomic, strong) UILabel *placementIdLabel;
@property (nonatomic, strong) UILabel *videoMutedLabel;
@property (nonatomic, strong) UISegmentedControl *videoMutedSegmentedControl;
@property (nonatomic, strong) UIButton *loadAdButton;
@property (nonatomic, strong) UIButton *showAdButton;
@property (nonatomic, strong) UIButton *destroyAdButton;
@property (nonatomic, strong, nullable) UISwitch *videoToggle;
@property (nonatomic, strong, nullable) UIStackView *videoStackView;

@end

@implementation BaseViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _logView = [[LogView alloc] init];
        _adContainer = [[UIView alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupConstraints];
    
    [self.loadAdButton addTarget:self action:@selector(loadAdTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.showAdButton addTarget:self action:@selector(showAdTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.destroyAdButton addTarget:self action:@selector(destroyAdTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self disableShowAd];
    [self disableDestroyAd];
    
    if (self.hasVideo) {
        [self setupVideoToggle];
    }
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.adFormatLabel = [[UILabel alloc] init];
    self.adFormatLabel.text = self.adFormatString;
    
    self.placementIdLabel = [[UILabel alloc] init];
    self.placementIdLabel.text = self.placementId;
    self.placementIdLabel.numberOfLines = 0;
    
    // 只有非banner格式才创建Video Muted控件
    if (self.adFormat != AdFormatBanner) {
        self.videoMutedLabel = [[UILabel alloc] init];
        self.videoMutedLabel.text = @"Video Muted:";
        
        self.videoMutedSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Default", @"Yes", @"No"]];
        NSNumber * mute = OpAdxSdkCore.getOpAdxSdkMuted;
        if (mute != nil) {
            if (mute.boolValue) {
                self.videoMutedSegmentedControl.selectedSegmentIndex = 1;
            }else {
                self.videoMutedSegmentedControl.selectedSegmentIndex = 2;
            }
        } else {
            self.videoMutedSegmentedControl.selectedSegmentIndex = 0;
        }
        [self.videoMutedSegmentedControl addTarget:self
                                             action:@selector(videoMutedChanged:)
                                   forControlEvents:UIControlEventValueChanged];
        
    }
    
    self.loadAdButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loadAdButton setTitle:@"Load Ad" forState:UIControlStateNormal];
    [self.loadAdButton setBackgroundColor:[UIColor systemBlueColor]];
    [self.loadAdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.showAdButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.showAdButton setTitle:@"Show Ad" forState:UIControlStateNormal];
    [self.showAdButton setBackgroundColor:[UIColor systemGreenColor]];
    [self.showAdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.destroyAdButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.destroyAdButton setTitle:@"Destroy Ad" forState:UIControlStateNormal];
    [self.destroyAdButton setBackgroundColor:[UIColor systemRedColor]];
    [self.destroyAdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.adContainer.backgroundColor = [UIColor systemGray5Color];
    
    // 添加基本控件
    NSMutableArray<UIView *> *subviews = [@[
        self.adFormatLabel,
        self.placementIdLabel,
        self.loadAdButton,
        self.showAdButton,
        self.destroyAdButton,
        self.adContainer
    ] mutableCopy];
    
    // 只有非banner格式才添加Video Muted控件
    if (self.adFormat != AdFormatBanner) {
        [subviews addObject:self.videoMutedLabel];
        [subviews addObject:self.videoMutedSegmentedControl];
    }
    
    for (UIView *subview in subviews) {
        [self.view addSubview:subview];
        subview.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self.logView setupInView:self.view];
}

- (void)videoMutedChanged:(UISegmentedControl *)sender {
    // 根据分段控制器的选择设置 videoAdMuted
    NSInteger selectedIndex = sender.selectedSegmentIndex;
    
    switch (selectedIndex) {
        case 0: // Default
            [OpAdxSdkCore setOpAdxSdkMuted:nil];
            break;
        case 1: // Yes
            [OpAdxSdkCore setOpAdxSdkMuted:@YES];
            break;
        case 2: // No
            [OpAdxSdkCore setOpAdxSdkMuted:@NO];
            break;
        default:
            [OpAdxSdkCore setOpAdxSdkMuted:nil];
            break;
    }
}

- (void)setupConstraints {
    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    
    if (self.adFormat == AdFormatBanner) {
        // Banner格式的约束（不显示Video Muted）
        [NSLayoutConstraint activateConstraints:@[
            [self.adFormatLabel.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:20],
            [self.adFormatLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            
            [self.placementIdLabel.topAnchor constraintEqualToAnchor:self.adFormatLabel.bottomAnchor constant:10],
            [self.placementIdLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [self.placementIdLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            
            [self.loadAdButton.topAnchor constraintEqualToAnchor:self.placementIdLabel.bottomAnchor constant:20],
            [self.loadAdButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [self.loadAdButton.widthAnchor constraintEqualToConstant:100],
            [self.loadAdButton.heightAnchor constraintEqualToConstant:44],
            
            [self.showAdButton.topAnchor constraintEqualToAnchor:self.loadAdButton.topAnchor],
            [self.showAdButton.leadingAnchor constraintEqualToAnchor:self.loadAdButton.trailingAnchor constant:10],
            [self.showAdButton.widthAnchor constraintEqualToConstant:100],
            [self.showAdButton.heightAnchor constraintEqualToConstant:44],
            
            [self.destroyAdButton.topAnchor constraintEqualToAnchor:self.loadAdButton.topAnchor],
            [self.destroyAdButton.leadingAnchor constraintEqualToAnchor:self.showAdButton.trailingAnchor constant:10],
            [self.destroyAdButton.widthAnchor constraintEqualToConstant:100],
            [self.destroyAdButton.heightAnchor constraintEqualToConstant:44],
            
            [self.adContainer.topAnchor constraintEqualToAnchor:self.loadAdButton.bottomAnchor constant:20],
            [self.adContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [self.adContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            [self.adContainer.heightAnchor constraintEqualToConstant:340]
        ]];
    } else {
        // 非Banner格式的约束（显示Video Muted）
        [NSLayoutConstraint activateConstraints:@[
            [self.adFormatLabel.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:20],
            [self.adFormatLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            
            [self.placementIdLabel.topAnchor constraintEqualToAnchor:self.adFormatLabel.bottomAnchor constant:10],
            [self.placementIdLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [self.placementIdLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            
            [self.videoMutedLabel.topAnchor constraintEqualToAnchor:self.placementIdLabel.bottomAnchor constant:20],
            [self.videoMutedLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            
            [self.videoMutedSegmentedControl.centerYAnchor constraintEqualToAnchor:self.videoMutedLabel.centerYAnchor],
            [self.videoMutedSegmentedControl.leadingAnchor constraintEqualToAnchor:self.videoMutedLabel.trailingAnchor constant:10],
            [self.videoMutedSegmentedControl.widthAnchor constraintEqualToConstant:200],
            
            [self.loadAdButton.topAnchor constraintEqualToAnchor:self.videoMutedLabel.bottomAnchor constant:20],
            [self.loadAdButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [self.loadAdButton.widthAnchor constraintEqualToConstant:100],
            [self.loadAdButton.heightAnchor constraintEqualToConstant:44],
            
            [self.showAdButton.topAnchor constraintEqualToAnchor:self.loadAdButton.topAnchor],
            [self.showAdButton.leadingAnchor constraintEqualToAnchor:self.loadAdButton.trailingAnchor constant:10],
            [self.showAdButton.widthAnchor constraintEqualToConstant:100],
            [self.showAdButton.heightAnchor constraintEqualToConstant:44],
            
            [self.destroyAdButton.topAnchor constraintEqualToAnchor:self.loadAdButton.topAnchor],
            [self.destroyAdButton.leadingAnchor constraintEqualToAnchor:self.showAdButton.trailingAnchor constant:10],
            [self.destroyAdButton.widthAnchor constraintEqualToConstant:100],
            [self.destroyAdButton.heightAnchor constraintEqualToConstant:44],
            
            [self.adContainer.topAnchor constraintEqualToAnchor:self.loadAdButton.bottomAnchor constant:20],
            [self.adContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
            [self.adContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
            [self.adContainer.heightAnchor constraintEqualToConstant:340]
        ]];
    }
    
    [self.logView setupConstraintsInView:self.view belowAnchorView:self.adContainer];
}

- (void)setupVideoToggle {
    UILabel *videoLabel = [[UILabel alloc] init];
    videoLabel.text = @"isVideo";
    
    UISwitch *toggle = [[UISwitch alloc] init];
    [toggle addTarget:self action:@selector(videoToggleChanged:) forControlEvents:UIControlEventValueChanged];
    self.videoToggle = toggle;
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[videoLabel, toggle]];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.spacing = 10;
    self.videoStackView = stackView;
    
    [self.view addSubview:stackView];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [stackView.centerYAnchor constraintEqualToAnchor:self.placementIdLabel.centerYAnchor constant:0],
        [stackView.leadingAnchor constraintEqualToAnchor:self.placementIdLabel.centerXAnchor constant:20]
    ]];
}

- (void)setPlacementId:(NSString *)placementId {
    _placementId = [placementId copy];
    self.placementIdLabel.text = placementId;
}

#pragma mark - Actions

- (void)videoToggleChanged:(UISwitch *)sender {
    self.placementId = [AdConfig getPlacementIdWithAdFormat:self.adFormat forceVideo:sender.isOn];
    self.placementIdLabel.text = self.placementId;
}

- (void)loadAdTapped {
    [self loadAd];
}

- (void)showAdTapped {
    [self showAd];
}

- (void)destroyAdTapped {
    [self destroyAd];
}

#pragma mark - Properties to override (Default Implementations)

- (BOOL)hasVideo {
    return NO;
}

- (AdFormat)adFormat {
    return AdFormatBanner; // Default to Banner, should be overridden
}

- (NSString *)adFormatString {
    return @"";
}

#pragma mark - Methods to override (Default Implementations)

- (void)loadAd {
    // Should be overridden by subclasses
}

- (void)showAd {
    // Should be overridden by subclasses
}

- (void)destroyAd {
    for (UIView *subview in self.adContainer.subviews) {
        [subview removeFromSuperview];
    }
}

#pragma mark - Button state management

- (void)enableShowAd {
    self.showAdButton.enabled = YES;
    self.showAdButton.alpha = 1.0;
}

- (void)disableShowAd {
    self.showAdButton.enabled = NO;
    self.showAdButton.alpha = 0.5;
}

- (void)enableDestroyAd {
    self.destroyAdButton.enabled = YES;
    self.destroyAdButton.alpha = 1.0;
}

- (void)disableDestroyAd {
    self.destroyAdButton.enabled = NO;
    self.destroyAdButton.alpha = 0.5;
}

- (BOOL)isVideoItem {
    return self.videoToggle.isOn;
}

@end
