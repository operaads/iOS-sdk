//
//  MainViewController.m
//  OpAdxDemo_OC
//
//  Created by Luan Chen on 2025/12/10.
//

#import "MainViewController.h"
#import "MainTableViewCell.h"
#import "AdConfig.h"
#import "NativeViewController.h"
#import "BannerViewController.h"
#import "InterstitialViewController.h"
#import "RewardedViewController.h"
#import "AppOpenViewController.h"
#import "RewardedInterstitialViewController.h"
#import "ClientBiddingViewController.h"

#import <OpAdxSdk/OpAdxSdk.h>


@interface MainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *sdkVersionLabel;
@property (nonatomic, strong) NSArray<MainItem *> *items;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 启用Debug日志（在SDK初始化之前）
    OpAdxLogger.logLevel = OpAdxLogLevelDebug;
    [OpAdxLogger info:@"=== Opera Ads SDK Demo (OC) Started ===" tag:@"OpAdxSDK"];

    NSString *sdkVersion = [NSString stringWithFormat:@"SDK Version: %@.%@",
                            [OpAdxSdkCore getVersion], [OpAdxSdkCore getBuildNum]];
    [OpAdxLogger info:sdkVersion tag:@"OpAdxSDK"];

    [self setupItems];
    [self setupUI];
    [self setupConstraints];
}

- (void)setupItems {
    // 假设 AdConfig 类和 AdFormat 枚举在 OC 中有对应或已桥接
    self.items = @[
        [[MainItem alloc] initWithFormat:@"Native" placementId:[AdConfig getPlacementIdWithAdFormat:AdFormatNative forceVideo:NO]],
        [[MainItem alloc] initWithFormat:@"Banner" placementId:[AdConfig getPlacementIdWithAdFormat:AdFormatBanner forceVideo:NO]],
        [[MainItem alloc] initWithFormat:@"Interstitial" placementId:[AdConfig getPlacementIdWithAdFormat:AdFormatInterstitial forceVideo:NO]],
        [[MainItem alloc] initWithFormat:@"Rewarded" placementId:[AdConfig getPlacementIdWithAdFormat:AdFormatReward forceVideo:NO]],
        [[MainItem alloc] initWithFormat:@"AppOpen" placementId:[AdConfig getPlacementIdWithAdFormat:AdFormatAppOpen forceVideo:NO]],
        [[MainItem alloc] initWithFormat:@"RewardedInterstitial" placementId:[AdConfig getPlacementIdWithAdFormat:AdFormatRewardedInterstitial forceVideo:NO]],
        [[MainItem alloc] initWithFormat:@"🎯 Client Bidding Test" placementId:@"C2S Bidding - Header Bidding 测试"],
        [[MainItem alloc] initWithFormat:@"Bid Response Debugging" placementId:@"Debug custom bid responses"]
    ];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Opera Ads Demo oc";
    
    // SDK Version Label
    self.sdkVersionLabel = [[UILabel alloc] init];
    NSString *versionText = [NSString stringWithFormat:@"SDK Version: %@.%@",
                             [OpAdxSdkCore getVersion],[OpAdxSdkCore getBuildNum]];
    self.sdkVersionLabel.text = versionText;
    self.sdkVersionLabel.textAlignment = NSTextAlignmentCenter;
    
    // Table View
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[MainTableViewCell class] forCellReuseIdentifier:@"MainCell"];
    self.tableView.scrollEnabled = NO;
    
    [self.view addSubview:self.sdkVersionLabel];
    [self.view addSubview:self.tableView];
    
    self.sdkVersionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setupConstraints {
    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.sdkVersionLabel.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:20],
        [self.sdkVersionLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.sdkVersionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        [self.tableView.topAnchor constraintEqualToAnchor:self.sdkVersionLabel.bottomAnchor constant:20],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor]
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell" forIndexPath:indexPath];
    MainItem *item = self.items[indexPath.row];
    // 假设 MainTableViewCell 有一个 - (void)configureWithItem:(MainItem *)item 方法
    [cell configureWithItem:item];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MainItem *item = self.items[indexPath.row];
    UIViewController *viewController = nil;
    
    NSString *format = item.format;
    if ([format isEqualToString:@"Native"]) {
        viewController = [[NativeViewController alloc] init];
    } else if ([format isEqualToString:@"Banner"]) {
        viewController = [[BannerViewController alloc] init];
    } else if ([format isEqualToString:@"Interstitial"]) {
        viewController = [[InterstitialViewController alloc] init];
    } else if ([format isEqualToString:@"Rewarded"]) {
        viewController = [[RewardedViewController alloc] init];
    } else if ([format isEqualToString:@"AppOpen"]) {
        viewController = [[AppOpenViewController alloc] init];
    } else if ([format isEqualToString:@"RewardedInterstitial"]) {
        viewController = [[RewardedInterstitialViewController alloc] init];
    } else if ([format isEqualToString:@"🎯 Client Bidding Test"]) {
        viewController = [[ClientBiddingViewController alloc] init];
    } else if ([format isEqualToString:@"Bid Response Debugging"]) {
        viewController = [[BidRespDebugViewController alloc] init];
    }
    
    if (viewController) {
        // 检查是否是 BaseViewController，并设置 placementId
        if ([viewController isKindOfClass:[BaseViewController class]]) {
            BaseViewController *baseVC = (BaseViewController *)viewController;
            baseVC.placementId = item.placementId;
        }
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

@end
