//
//  ClientBiddingViewController.m
//  OpAdxDemo_OC
//
//  Created by Claude on 2026/03/30.
//

#import "ClientBiddingViewController.h"
#import "AdConfig.h"
#import <OpAdxSdk/OpAdxSdk.h>

// 广告加载项
@interface AdLoadItem : NSObject
@property (nonatomic, strong) OpAdxInterstitialAdBridge *ad;
@property (nonatomic, strong, nullable) id<AdBid> bid;
@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, assign) NSInteger index;
@end

@implementation AdLoadItem
@end

// ============================================================
#pragma mark - ClientBiddingViewController
// ============================================================

@interface ClientBiddingViewController () <OpAdxInterstitialAdDelegate, UITableViewDataSource, UITableViewDelegate>

// 测试用的 Placement IDs
@property (nonatomic, strong) NSArray<NSString *> *testPlacementIds;

// 存储加载的广告
@property (nonatomic, strong) NSMutableArray<AdLoadItem *> *loadedAds;

// 获胜广告索引
@property (nonatomic, strong, nullable) NSNumber *winnerIndex;

// UI Components
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIButton *loadAdsButton;
@property (nonatomic, strong) UIButton *runAuctionButton;
@property (nonatomic, strong) UIButton *showWinnerButton;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UITableView *bidsTableView;
@property (nonatomic, strong) UITextView *logTextView;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation ClientBiddingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Client Bidding Test";

    // 初始化数据
    self.testPlacementIds = @[
        [AdConfig getPlacementIdWithAdFormat:AdFormatInterstitial forceVideo:NO],
        [AdConfig getPlacementIdWithAdFormat:AdFormatInterstitial forceVideo:YES],
        [AdConfig getPlacementIdWithAdFormat:AdFormatReward forceVideo:NO]
    ];

    self.loadedAds = [NSMutableArray array];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"HH:mm:ss"];

    [self setupUI];
    [self setupConstraints];
    [self updateButtonStates];
}

#pragma mark - UI Setup

- (void)setupUI {
    // Scroll View
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];

    // Content View
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];

    // Title Label
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"🎯 Client Bidding 测试";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.titleLabel];

    // Description Label
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.text = @"测试多个广告的 Client Bidding 功能\n1️⃣ 加载广告 → 2️⃣ 运行竞价 → 3️⃣ 展示获胜者";
    self.descriptionLabel.font = [UIFont systemFontOfSize:14];
    self.descriptionLabel.textColor = [UIColor grayColor];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.descriptionLabel];

    // Load Ads Button
    self.loadAdsButton = [self createButtonWithTitle:@"1️⃣ Load Multiple Ads"
                                              action:@selector(loadMultipleAds)
                                     backgroundColor:[UIColor systemBlueColor]];
    [self.contentView addSubview:self.loadAdsButton];

    // Run Auction Button
    self.runAuctionButton = [self createButtonWithTitle:@"2️⃣ Run Auction"
                                                 action:@selector(runAuction)
                                        backgroundColor:[UIColor systemGreenColor]];
    [self.contentView addSubview:self.runAuctionButton];

    // Show Winner Button
    self.showWinnerButton = [self createButtonWithTitle:@"3️⃣ Show Winner"
                                                 action:@selector(showWinner)
                                        backgroundColor:[UIColor systemOrangeColor]];
    [self.contentView addSubview:self.showWinnerButton];

    // Clear Button
    self.clearButton = [self createButtonWithTitle:@"🗑️ Clear All"
                                            action:@selector(clearAllAds)
                                   backgroundColor:[UIColor systemRedColor]];
    [self.contentView addSubview:self.clearButton];

    // Status Label
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"准备就绪";
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.statusLabel];

    // Bids Table View
    self.bidsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.bidsTableView.delegate = self;
    self.bidsTableView.dataSource = self;
    [self.bidsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"BidCell"];
    self.bidsTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.bidsTableView];

    // Log Text View
    self.logTextView = [[UITextView alloc] init];
    self.logTextView.font = [UIFont fontWithName:@"Menlo" size:11];
    self.logTextView.editable = NO;
    self.logTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.logTextView.layer.borderWidth = 1.0;
    self.logTextView.layer.cornerRadius = 8;
    self.logTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.logTextView];
}

- (UIButton *)createButtonWithTitle:(NSString *)title
                            action:(SEL)action
                   backgroundColor:(UIColor *)color {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = color;
    button.layer.cornerRadius = 8;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

- (void)setupConstraints {
    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;

    [NSLayoutConstraint activateConstraints:@[
        // ScrollView
        [self.scrollView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        // ContentView
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],

        // TitleLabel
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:20],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],

        // DescriptionLabel
        [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8],
        [self.descriptionLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.descriptionLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],

        // Load Ads Button
        [self.loadAdsButton.topAnchor constraintEqualToAnchor:self.descriptionLabel.bottomAnchor constant:20],
        [self.loadAdsButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.loadAdsButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.loadAdsButton.heightAnchor constraintEqualToConstant:50],

        // Run Auction Button
        [self.runAuctionButton.topAnchor constraintEqualToAnchor:self.loadAdsButton.bottomAnchor constant:12],
        [self.runAuctionButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.runAuctionButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.runAuctionButton.heightAnchor constraintEqualToConstant:50],

        // Show Winner Button
        [self.showWinnerButton.topAnchor constraintEqualToAnchor:self.runAuctionButton.bottomAnchor constant:12],
        [self.showWinnerButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.showWinnerButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.showWinnerButton.heightAnchor constraintEqualToConstant:50],

        // Clear Button
        [self.clearButton.topAnchor constraintEqualToAnchor:self.showWinnerButton.bottomAnchor constant:12],
        [self.clearButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.clearButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.clearButton.heightAnchor constraintEqualToConstant:50],

        // Status Label
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.clearButton.bottomAnchor constant:20],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],

        // Bids Table View
        [self.bidsTableView.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:12],
        [self.bidsTableView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.bidsTableView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.bidsTableView.heightAnchor constraintEqualToConstant:150],

        // Log Text View
        [self.logTextView.topAnchor constraintEqualToAnchor:self.bidsTableView.bottomAnchor constant:20],
        [self.logTextView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.logTextView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.logTextView.heightAnchor constraintEqualToConstant:250],
        [self.logTextView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-20]
    ]];
}

#pragma mark - Actions

- (void)loadMultipleAds {
    [self.loadedAds removeAllObjects];
    self.winnerIndex = nil;

    self.statusLabel.text = [NSString stringWithFormat:@"正在加载 %lu 个广告...", (unsigned long)self.testPlacementIds.count];
    [self addLog:[NSString stringWithFormat:@"🎯 开始加载 %lu 个 Client Bidding 广告", (unsigned long)self.testPlacementIds.count]];
    [self addLog:@"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"];

    [self.testPlacementIds enumerateObjectsUsingBlock:^(NSString *placementId, NSUInteger idx, BOOL *stop) {
        [self addLog:[NSString stringWithFormat:@"📍 Placement #%lu: %@", (unsigned long)idx, placementId]];

        // 创建插屏广告实例（使用 clientBidding 类型）
        OpAdxInterstitialAdBridge *ad = [[OpAdxInterstitialAdBridge alloc] initWithPlacementId:placementId
                                                                                   auctionType:AdAuctionTypeClientBidding];
        ad.delegate = self;

        // 创建加载项
        AdLoadItem *item = [[AdLoadItem alloc] init];
        item.ad = ad;
        item.placementId = placementId;
        item.index = idx;

        // 🔑 关键：使用 loadC2SBid() 方法进行 client bidding
        [ad loadC2SBid];
    }];

    [self updateButtonStates];
}

- (void)runAuction {
    if (self.loadedAds.count == 0) {
        [self addLog:@"⚠️  没有已加载的广告，请先加载广告"];
        return;
    }

    [self addLog:@"🏁 开始客户端竞价..."];
    [self addLog:@"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"];

    // 收集所有有效的 bid
    NSMutableArray<NSDictionary *> *bidsWithIndex = [NSMutableArray array];

    for (AdLoadItem *item in self.loadedAds) {
        if (item.bid) {
            double ecpm = [item.bid getEcpm];
            [self addLog:[NSString stringWithFormat:@"💵 广告 #%ld: eCPM = $%.4f", (long)item.index, ecpm]];
            [bidsWithIndex addObject:@{
                @"index": @(item.index),
                @"ecpm": @(ecpm),
                @"bid": item.bid
            }];
        }
    }

    if (bidsWithIndex.count == 0) {
        [self addLog:@"❌ 没有有效的出价"];
        return;
    }

    // 按 eCPM 降序排序
    [bidsWithIndex sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        double ecpm1 = [obj1[@"ecpm"] doubleValue];
        double ecpm2 = [obj2[@"ecpm"] doubleValue];
        if (ecpm1 > ecpm2) return NSOrderedAscending;
        if (ecpm1 < ecpm2) return NSOrderedDescending;
        return NSOrderedSame;
    }];

    // 获胜者是第一名
    NSDictionary *winnerDict = bidsWithIndex.firstObject;
    NSInteger winnerIdx = [winnerDict[@"index"] integerValue];
    double winnerEcpm = [winnerDict[@"ecpm"] doubleValue];

    // 第二价格（用于 notifyWin）
    double secondPrice = bidsWithIndex.count > 1 ? [bidsWithIndex[1][@"ecpm"] doubleValue] : 0;

    self.winnerIndex = @(winnerIdx);

    [self addLog:@""];
    [self addLog:@"🏆 竞价结果:"];
    [self addLog:[NSString stringWithFormat:@"   获胜者: 广告 #%ld", (long)winnerIdx]];
    [self addLog:[NSString stringWithFormat:@"   获胜价格: $%.4f", winnerEcpm]];
    [self addLog:[NSString stringWithFormat:@"   第二高价: $%.4f", secondPrice]];
    [self addLog:@"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"];

    // 通知所有广告竞价结果
    [self addLog:@"📢 通知竞价结果..."];

    for (NSDictionary *bidDict in bidsWithIndex) {
        NSInteger idx = [bidDict[@"index"] integerValue];
        id<AdBid> bid = bidDict[@"bid"];

        if (idx == winnerIdx) {
            // 通知获胜（第二价格拍卖）
            [bid notifyWinWithSecondPrice:secondPrice bidderName:@"OpAdx"];
            [self addLog:[NSString stringWithFormat:@"✅ 通知广告 #%ld 获胜 (第二价格: $%.4f)", (long)idx, secondPrice]];
        } else {
            // 通知失败
            [bid notifyLoseWithLossReason:LossReasonLowerThanHighestPrice
                              winnerPrice:winnerEcpm
                            winnerBidder:@"OpAdx"];
            [self addLog:[NSString stringWithFormat:@"📉 通知广告 #%ld 失败 (原因: 价格低于最高价)", (long)idx]];
        }
    }

    [self addLog:@"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"];
    [self addLog:@""];

    self.statusLabel.text = [NSString stringWithFormat:@"✅ 竞价完成！获胜者: 广告 #%ld", (long)winnerIdx];
    [self.bidsTableView reloadData];
    [self updateButtonStates];
}

- (void)showWinner {
    if (!self.winnerIndex) {
        [self addLog:@"⚠️  请先运行竞价"];
        return;
    }

    NSInteger winnerIdx = self.winnerIndex.integerValue;
    AdLoadItem *winnerItem = nil;

    for (AdLoadItem *item in self.loadedAds) {
        if (item.index == winnerIdx) {
            winnerItem = item;
            break;
        }
    }

    if (!winnerItem || !winnerItem.ad) {
        [self addLog:@"❌ 无法找到获胜广告"];
        return;
    }

    [self addLog:[NSString stringWithFormat:@"🎬 展示获胜广告 #%ld...", (long)winnerIdx]];
    [winnerItem.ad showAdFrom:self];
}

- (void)clearAllAds {
    [self.loadedAds removeAllObjects];
    self.winnerIndex = nil;

    self.logTextView.text = @"";
    self.statusLabel.text = @"✅ 已清除所有广告";

    [self.bidsTableView reloadData];
    [self updateButtonStates];

    [self addLog:@"🗑️  已清除所有广告"];
}

#pragma mark - Helper Methods

- (void)addLog:(NSString *)message {
    NSString *timestamp = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *logMessage = [NSString stringWithFormat:@"[%@] %@\n", timestamp, message];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.logTextView.text = [self.logTextView.text stringByAppendingString:logMessage];

        // Auto-scroll to bottom
        NSRange bottom = NSMakeRange(self.logTextView.text.length - 1, 1);
        [self.logTextView scrollRangeToVisible:bottom];
    });
}

- (void)updateButtonStates {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL hasLoadedAds = self.loadedAds.count > 0;
        BOOL allAdsLoaded = self.loadedAds.count == self.testPlacementIds.count;
        BOOL hasWinner = self.winnerIndex != nil;

        self.runAuctionButton.enabled = allAdsLoaded;
        self.runAuctionButton.alpha = allAdsLoaded ? 1.0 : 0.5;

        self.showWinnerButton.enabled = hasWinner;
        self.showWinnerButton.alpha = hasWinner ? 1.0 : 0.5;

        self.clearButton.enabled = hasLoadedAds;
        self.clearButton.alpha = hasLoadedAds ? 1.0 : 0.5;
    });
}

#pragma mark - OpAdxInterstitialAdDelegate

- (void)interstitialAdDidLoad:(OpAdxInterstitialAdBridge *)interstitialAd {
    // 找到对应的加载项
    __block AdLoadItem *targetItem = nil;
    [self.testPlacementIds enumerateObjectsUsingBlock:^(NSString *placementId, NSUInteger idx, BOOL *stop) {
        if ([placementId isEqualToString:interstitialAd.placementId]) {
            targetItem = [[AdLoadItem alloc] init];
            targetItem.ad = interstitialAd;
            targetItem.bid = [interstitialAd getBid];
            targetItem.placementId = placementId;
            targetItem.index = idx;
            *stop = YES;
        }
    }];

    if (targetItem) {
        if (targetItem.bid) {
            double ecpm = [targetItem.bid getEcpm];
            [self addLog:[NSString stringWithFormat:@"✅ 广告 #%ld 加载成功", (long)targetItem.index]];
            [self addLog:[NSString stringWithFormat:@"   💰 eCPM: $%.4f", ecpm]];
        } else {
            [self addLog:[NSString stringWithFormat:@"⚠️  广告 #%ld 加载成功，但没有 bid 信息", (long)targetItem.index]];
        }

        [self.loadedAds addObject:targetItem];
        [self.bidsTableView reloadData];

        if (self.loadedAds.count == self.testPlacementIds.count) {
            [self addLog:@"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"];
            [self addLog:@"🎉 所有广告加载完成！"];
            [self addLog:[NSString stringWithFormat:@"📊 共 %lu 个广告可参与竞价", (unsigned long)self.loadedAds.count]];
            self.statusLabel.text = [NSString stringWithFormat:@"✅ 已加载 %lu 个广告，可以开始竞价", (unsigned long)self.loadedAds.count];
        } else {
            self.statusLabel.text = [NSString stringWithFormat:@"正在加载... (%lu/%lu)",
                                     (unsigned long)self.loadedAds.count,
                                     (unsigned long)self.testPlacementIds.count];
        }

        [self updateButtonStates];
    }
}

- (void)interstitialAd:(OpAdxInterstitialAdBridge *)interstitialAd didFailWithError:(OpAdxAdError *)error {
    // 找到对应的索引
    __block NSInteger failedIndex = -1;
    [self.testPlacementIds enumerateObjectsUsingBlock:^(NSString *placementId, NSUInteger idx, BOOL *stop) {
        if ([placementId isEqualToString:interstitialAd.placementId]) {
            failedIndex = idx;
            *stop = YES;
        }
    }];

    if (failedIndex >= 0) {
        [self addLog:[NSString stringWithFormat:@"❌ 广告 #%ld 加载失败", (long)failedIndex]];
        [self addLog:[NSString stringWithFormat:@"   错误: %@", error.message]];

        // 添加占位
        AdLoadItem *placeholderItem = [[AdLoadItem alloc] init];
        placeholderItem.ad = interstitialAd;
        placeholderItem.bid = nil;
        placeholderItem.placementId = interstitialAd.placementId;
        placeholderItem.index = failedIndex;

        [self.loadedAds addObject:placeholderItem];
        [self.bidsTableView reloadData];

        if (self.loadedAds.count == self.testPlacementIds.count) {
            [self addLog:@"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"];
            NSInteger successCount = 0;
            for (AdLoadItem *item in self.loadedAds) {
                if (item.bid) successCount++;
            }
            [self addLog:@"⚠️  加载完成，但有失败项"];
            [self addLog:[NSString stringWithFormat:@"📊 成功: %ld / 总数: %lu", (long)successCount, (unsigned long)self.loadedAds.count]];
            self.statusLabel.text = [NSString stringWithFormat:@"⚠️  部分广告加载失败 (%ld/%lu)", (long)successCount, (unsigned long)self.testPlacementIds.count];
        }

        [self updateButtonStates];
    }
}

- (void)interstitialAdDidDisplay:(OpAdxInterstitialAdBridge *)interstitialAd {
    [self addLog:@"👁️  广告已展示（Impression）"];
}

- (void)interstitialAdDidClick:(OpAdxInterstitialAdBridge *)interstitialAd {
    [self addLog:@"👆 广告被点击"];
}

- (void)interstitialAdDidClose:(OpAdxInterstitialAdBridge *)interstitialAd {
    [self addLog:@"🚪 广告已关闭"];
}

- (void)interstitialAd:(OpAdxInterstitialAdBridge *)interstitialAd didFailToDisplayWithError:(OpAdxAdError *)error {
    [self addLog:[NSString stringWithFormat:@"❌ 广告展示失败: %@", error.message]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.loadedAds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BidCell" forIndexPath:indexPath];

    AdLoadItem *item = self.loadedAds[indexPath.row];

    NSString *statusText = @"";
    if (self.winnerIndex && self.winnerIndex.integerValue == item.index) {
        statusText = @"🏆 获胜";
    } else if (item.bid) {
        statusText = @"✅ 已加载";
    } else {
        statusText = @"❌ 失败";
    }

    if (item.bid) {
        double ecpm = [item.bid getEcpm];
        cell.textLabel.text = [NSString stringWithFormat:@"广告 #%ld - $%.4f - %@",
                               (long)item.index, ecpm, statusText];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"广告 #%ld - %@",
                               (long)item.index, statusText];
    }

    cell.textLabel.font = [UIFont fontWithName:@"Menlo" size:12];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

@end
