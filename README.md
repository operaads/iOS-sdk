# OpAdxSdk iOS Change Log (Object-C)

(2.2.13) - 更准确区分广告页面自动跳转和用户点击

(2.2.12) - fix激励回调

(2.2.10) - 支持最低版本降至iOS13

(2.2.9)  - 适配Topon Adapter

(2.2.6)  - 迁移至https://github.com/operaads/iOS-sdk

(2.2.5)  - 由动态库转为静态库，只需要pod集成，不需要额外设置embed

# OpAdxSdk iOS Integration Guide (Object-C)

OpAdxSdk 是一个高性能的 iOS 移动广告 SDK，支持 Banner、插屏、激励视频以及原生广告等多种格式，提供先进的广告定位和报表能力。


## Requirements

  * **iOS 13+** 
  * **CocoaPods**
  * **Xcode 16.4+**
  * **Swift 5.0+** 
  
---  
## 回调处理模式 (Event Handling)

OpAdxSdk 根据语言特性提供了两种不同的事件回调方式：

* **Objective-C**: 使用标准的 **Delegate (代理)** 模式。你需要遵守相应的协议（如 `OpAdxBannerAdDelegate`）并实现代理方法。
* **Swift**: 使用 **Listener (监听器)** 模式。通过创建 Listener 实现类（如 `OpAdxBannerAdListenerImp`），你可以直接使用闭包 (Closures) 来处理回调，代码更加紧凑。

---
## Installation

### CocoaPods

在你的 `Podfile` 中添加以下依赖：

```ruby
target 'YourAppTarget' do
  use_frameworks!
  pod 'OpAdxSdk'
end
```

然后运行：

```bash
pod install
```

重要: OpAdxSdk(2.2.5)版本以后,库由动态库转为静态库，不在需要以下设置。
重要: (2.2.5)版本以前,在你的工程中target-General-Framework，添加OpAdxSdk.xcframework，并设置为 **Embed & Sign**。

## Initialization

在 `AppDelegate.m` 中初始化 SDK。你需要提供 `Application ID` 和 `iOS App ID`。

> **注意**: 如果你的项目是 Objective-C 工程，需要引入 Swift 桥接头文件 `<OpAdxSdk/OpAdxSdk-Swift.h>`。

```objective-c
#import "AppDelegate.h"
#import <OpAdxSdk/OpAdxSdk-Swift.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 配置初始化参数
    NSString *applicationId = @"YOUR_APPLICATION_ID";
    NSString *iOSAppId = @"YOUR_IOS_APP_ID";
    
    OpAdxSdkInitConfig *initConfig = [OpAdxSdkInitConfig createWithApplicationId:applicationId 
                                                                        iOSAppId:iOSAppId 
                                                                   publisherName:nil];
        
    // (可选) 设置测试模式 
    //initConfig.useTestAd = YES;
    
    // 初始化 SDK
    [OpAdxSdkCore.shared initializeSDKWithConfig:initConfig];
    
    return YES;
}
```

-----

## Ad Formats

### 1\. Banner Ad (横幅广告)

Banner 广告通常显示在应用界面的顶部或底部。

**加载与展示:**

```objective-c
#import <OpAdxSdk/OpAdxSdk-Swift.h>

@interface ViewController () <OpAdxBannerAdDelegate>
@property (nonatomic, strong) OpAdxBannerAdBridge *bannerAdView;
@end

@implementation ViewController

- (void)loadBannerAd {
    // 1. 初始化 Banner 广告对象
    // OpAdxAdSize.BANNER_MREC 或其他尺寸
    self.bannerAdView = [[OpAdxBannerAdBridge alloc] initWithPlacementId:@"YOUR_PLACEMENT_ID" 
                                                                  adSize:OpAdxAdSize.BANNER_MREC];
    
    // 2. 设置代理和视图控制器提供者
    self.bannerAdView.delegate = self;
    
    // 3. 加载广告
    [self.bannerAdView loadAd];
}

// 4. 在加载成功后展示
- (void)bannerAdDidLoad:(OpAdxBannerAdBridge *)bannerAd {
    // 检查广告有效性 (可选)
    if (self.bannerAdView.isAdInvalidated) { return; }

    UIView *adView = self.bannerAdView;
    adView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:adView];
    
    // 添加布局约束 (示例: 居中显示)
    [NSLayoutConstraint activateConstraints:@[
        [adView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [adView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [adView.widthAnchor constraintEqualToConstant:300], // 根据 AdSize 调整
        [adView.heightAnchor constraintEqualToConstant:250]
    ]];
}
@end
```

### 2\. Interstitial Ad (插屏广告)

插屏广告是覆盖全屏的广告形式，通常在应用流程的自然停顿点展示。

```objective-c
#import <OpAdxSdk/OpAdxSdk-Swift.h>

@interface ViewController () <OpAdxInterstitialAdDelegate>
@property (nonatomic, strong) OpAdxInterstitialAdBridge *interstitialAd;
@end

@implementation ViewController

- (void)loadInterstitialAd {
    // 1. 初始化并加载
    self.interstitialAd = [[OpAdxInterstitialAdBridge alloc] initWithPlacementId:@"YOUR_PLACEMENT_ID"];
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadAd];
}

- (void)showInterstitialAd {
    // 2. 检查广告是否有效并展示
    if (self.interstitialAd && [self.interstitialAd isAdValid]) {
        [self.interstitialAd showAdFrom:self];
    }
}

#pragma mark - Delegate
- (void)interstitialAdDidLoad:(OpAdxInterstitialAdBridge *)interstitialAd {
    NSLog(@"插屏广告加载成功");
    // 此时可以调用 showInterstitialAd
}

- (void)interstitialAdDidClose:(OpAdxInterstitialAdBridge *)interstitialAd {
    // 广告关闭后清理资源
    self.interstitialAd = nil;
}
@end
```

### 3\. Rewarded Video Ad (激励视频广告)

激励视频广告允许用户通过观看视频换取应用内奖励。

```objective-c
#import <OpAdxSdk/OpAdxSdk-Swift.h>

@interface ViewController () <OpAdxRewardedAdDelegate>
@property (nonatomic, strong) OpAdxRewardedAdBridge *rewardedAd;
@end

@implementation ViewController

- (void)loadRewardedAd {
    // 1. 初始化并加载
    self.rewardedAd = [[OpAdxRewardedAdBridge alloc] initWithPlacementId:@"YOUR_PLACEMENT_ID"];
    self.rewardedAd.delegate = self;
    [self.rewardedAd loadAd];
}

- (void)showRewardedAd {
    // 2. 展示广告
    if (self.rewardedAd && [self.rewardedAd isAdValid]) {
        [self.rewardedAd showAdFrom:self];
    }
}

#pragma mark - Delegate
- (void)rewardedAd:(OpAdxRewardedAdBridge *)rewardedAd didRewardUserWithItem:(OpAdxRewardItem *)rewardItem {
    // 3. 发放奖励
    NSLog(@"奖励类型: %@, 数量: %ld", rewardItem.type, (long)rewardItem.amount);
}

- (void)rewardedAdDidClose:(OpAdxRewardedAdBridge *)rewardedAd {
    self.rewardedAd = nil;
}
@end
```

### 4\. Native Ad (原生广告)

原生广告允许你自定义广告的 UI 布局，使其与应用外观完美融合。

**关键步骤：**

1.  创建自定义 View (`OpAdxNativeAdView`) 布局 UI 元素。
2.  加载广告数据。
3.  使用 `OpAdxNativeAdRootView` 和 `OpAdxInteractionViews` 注册交互。

<!-- end list -->

```objective-c
#import <OpAdxSdk/OpAdxSdk-Swift.h>
#import "OpAdxNativeAdView.h" // 你的自定义广告视图类

@interface ViewController () <OpAdxNativeAdDelegate>
@property (nonatomic, strong) OpAdxNativeAdBridge *nativeAd;
@end

@implementation ViewController

- (void)loadNativeAd {
    self.nativeAd = [[OpAdxNativeAdBridge alloc] initWithPlacementID:@"YOUR_PLACEMENT_ID"];
    self.nativeAd.delegate = self;
    [self.nativeAd loadAd];
}

- (void)nativeAdDidLoad:(OpAdxNativeAdBridge *)nativeAd {
    // 1. 配置自定义视图的数据
    OpAdxNativeAdView *adView = [[OpAdxNativeAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
    [adView configureWithNativeAd:nativeAd]; // 设置 Title, Body, Icon 等
    
    // 2. 设置广告选择图标位置 (AdChoices)
    [self.nativeAd setAdChoicePosition:AdChoicePositionTopRight];
    
    // 3. 添加到父视图
    [self.view addSubview:adView];
    
    // 4. 注册视图以处理交互 (点击、展示统计)
    // 必须使用 OpAdxNativeAdRootView 包裹你的自定义 View
    OpAdxNativeAdRootView *rootView = [[OpAdxNativeAdRootView alloc] initWithRoot:adView];
    
    // 获取交互组件 (Title, Icon, CTA Button, MediaView 等)
    [self.nativeAd registerViewForInteractionWithRootView:rootView 
                                         interactionViews:adView.interactionViews];
}
@end
```

## Resource Management

建议在 `ViewController` 销毁或不再需要广告时，手动调用 `destroy` 方法以释放资源，特别是对于包含视频内容的广告。

```objective-c
- (void)dealloc {
    [self.bannerAdView destroy];
    [self.nativeAd destroy];
    self.bannerAdView = nil;
    self.nativeAd = nil;
}
```

---  
# OpAdxSdk iOS (2.2.1) Integration Guide (Swift)

重要: 在你的工程中target-General-Framework,添加OpAdxSdk.xcframework,并设置Embed&Sign

## Initialization

在应用启动时（例如 `AppDelegate` 或首个 ViewController 的 `viewDidLoad` 中）初始化 SDK。你需要提供 `Application ID` 和 `iOS App ID`。

```swift
import OpAdxSdk

func initializeSDK() {
    // 1. 创建配置对象
    let initConfig = OpAdxSdkInitConfig.create(
        applicationId: "YOUR_APPLICATION_ID", 
        iOSAppId: "YOUR_IOS_APP_ID"
    )
    
    // (可选) 设置测试模式 
    // initConfig.useTestAd = true 
    
    // 2. 初始化 SDK
    OpAdxSdkCore.shared.initialize(initConfig: initConfig)
}
```

-----

## Ad Formats

### 1\. Banner Ad (横幅广告)

Banner 广告通常显示在应用界面的顶部或底部。

**加载与展示:**

```swift
import OpAdxSdk

class BannerViewController: UIViewController {
    
    var bannerAdView: OpAdxBannerAdView?
    
    func loadBannerAd() {
        // 1. 初始化 Banner View
        bannerAdView = OpAdxBannerAdView()
        
        // 2. 配置参数
        bannerAdView?.setPlacementId("YOUR_PLACEMENT_ID")
        bannerAdView?.setAdSize(.BANNER_MREC) // 设置尺寸
        
        // 3. 创建监听器并加载
        let listener = OpAdxBannerAdListenerImp(
            onAdLoaded: { [weak self] bannerAdInfo in
                print("Banner Loaded")
                self?.showBanner()
            },
            onAdFailedToLoad: { error in
                print("Failed to load: \(error.message)")
            },
            onAdImpression: {
                print("Impression recorded")
            },
            onAdClicked: {
                print("Ad Clicked")
            }
        )
        
        bannerAdView?.loadAd(listener: listener)
    }
    
    func showBanner() {
        guard let bannerView = bannerAdView else { return }
        
        // 添加到视图层级并设置约束
        view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.widthAnchor.constraint(equalToConstant: 300),
            bannerView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    // MARK: - Lifecycle Management
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bannerAdView?.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bannerAdView?.resume()
    }
    
    deinit {
        bannerAdView?.destroy()
    }
}
```

### 2\. Interstitial Ad (插屏广告)

插屏广告是覆盖全屏的广告形式，通常在应用流程的自然停顿点展示。

```swift
import OpAdxSdk

class InterstitialViewController: UIViewController {
    
    var interstitialAd: OpAdxInterstitialAd?
    
    func loadInterstitialAd() {
        let placementId = "YOUR_PLACEMENT_ID"
        interstitialAd = OpAdxInterstitialAd(placementId: placementId)
        
        // 1. 加载广告
        let loadListener = OpAdxInterstitialAdLoadListenerImp(
            onAdLoaded: { ad in
                print("Interstitial Loaded")
                // 此时可以启用展示按钮
            },
            onAdFailedToLoad: { error in
                print("Failed to load: \(error.message)")
            }
        )
        
        interstitialAd?.load(placementId: placementId, listener: loadListener)
    }
    
    func showInterstitialAd() {
        guard let ad = interstitialAd, !ad.isAdInvalidated() else { return }
        
        // 2. 展示广告并监听交互
        let interactionListener = OpAdxInterstitialAdInteractionListenerImp(
            onAdClicked: { print("Clicked") },
            onAdDisplayed: { print("Displayed") },
            onAdDismissed: { [weak self] in
                print("Dismissed")
                // 销毁广告
                self?.interstitialAd?.destroy()
                self?.interstitialAd = nil
            },
            onAdFailedToShow: { error in print("Show failed: \(error.message)") }
        )
        
        ad.show(on: self, listener: interactionListener)
    }
}
```

### 3\. Rewarded Video Ad (激励视频广告)

激励视频广告允许用户通过观看视频换取应用内奖励。

```swift
import OpAdxSdk

class RewardedViewController: UIViewController {
    
    var rewardedAd: OpAdxRewardedAd?
    
    func loadRewardedAd() {
        let placementId = "YOUR_PLACEMENT_ID"
        rewardedAd = OpAdxRewardedAd(placementId: placementId)
        
        // 1. 加载广告
        let loadListener = OpAdxRewardedAdLoadListenerImp(
            onAdLoaded: { ad in
                print("Rewarded Ad Loaded")
            },
            onAdFailedToLoad: { error in
                print("Failed: \(error.message)")
            }
        )
        
        rewardedAd?.load(placementId: placementId, listener: loadListener)
    }
    
    func showRewardedAd() {
        guard let ad = rewardedAd, !ad.isAdInvalidated() else { return }
        
        // 2. 展示广告
        let interactionListener = OpAdxRewardedAdInteractionListenerImp(
            onAdClicked: { print("Clicked") },
            onAdDisplayed: { print("Displayed") },
            onAdDismissed: { [weak self] in
                self?.rewardedAd?.destroy()
                self?.rewardedAd = nil
            },
            onAdFailedToShow: { error in print("Show failed") },
            onUserRewarded: { reward in
                // 3. 发放奖励
                print("User rewarded: \(reward.amount) \(reward.type)")
            }
        )
        
        ad.show(on: self, listener: interactionListener)
    }
}
```

### 4\. Native Ad (原生广告)

原生广告允许你自定义广告的 UI 布局，使其与应用外观完美融合。

**关键步骤：**

1.  创建自定义 View (`OpAdxNativeAdView`) 并布局 UI 元素（Title, Icon, MediaView 等）。
2.  加载广告数据。
3.  注册交互视图以启用点击和曝光统计。

<!-- end list -->

```swift
import OpAdxSdk

class NativeViewController: UIViewController {
    
    var nativeAd: OpAdxNativeAd?
    
    func loadNativeAd() {
        let placementId = "YOUR_PLACEMENT_ID"
        nativeAd = OpAdxNativeAd(placementId: placementId)
        
        let listener = OpAdxNativeAdListenerImp(
            onAdLoaded: { [weak self] ad in
                if let nativeAd = ad as? OpAdxNativeAd {
                    self?.showNativeAd(nativeAd)
                }
            },
            onAdFailedToLoad: { error in
                print("Failed: \(error.message)")
            },
            onAdImpression: { print("Impression") },
            onAdClicked: { print("Clicked") }
        )
        
        nativeAd?.loadAd(placementId: placementId, listener: listener)
    }
    
    func showNativeAd(_ ad: OpAdxNativeAd) {
        // 1. 创建并配置自定义视图 (OpAdxNativeAdView 是用户自定义的 UIView 子类)
        let nativeAdView = OpAdxNativeAdView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        nativeAdView.configure(with: ad) // 填充 Title, Body 等数据
        
        // 2. 设置广告隐私图标位置
        ad.setAdChoicePosition(.topRight)
        
        view.addSubview(nativeAdView)
        // ... 设置 nativeAdView 的布局约束 ...
        
        // 3. 注册交互
        // OpAdxNativeAdRootView 是 SDK 提供的容器，interactionViews 包含了可点击的视图集合
        let rootView = OpAdxNativeAdRootView(root: nativeAdView)
        ad.registerInteractionViews(container: rootView, interactionViews: nativeAdView.interactionViews)
    }
    
    deinit {
        nativeAd?.destroy()
    }
}
```

## Resource Management

建议在 `ViewController` 销毁或不再需要广告时，手动调用 `destroy` 方法以释放资源，特别是对于包含视频内容的广告。

```swift
override func destroyAd() {
    interstitialAd?.destroy()
    interstitialAd = nil
    
    rewardedAd?.destroy()
    rewardedAd = nil
    
    bannerAdView?.destroy()
    bannerAdView = nil
    
    nativeAd?.destroy()
    nativeAd = nil
}
```

## License

OpAdxSdk is available under the Commercial license. See the [LICENSE](https://www.google.com/search?q=LICENSE) file for more info. 

## Author

Opera , chenl@opera.com 
