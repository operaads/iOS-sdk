//
//  NativeViewController.swift
//  OperaAdxSDK
//
//  Created by Luan Chen on 2025/11/4.
//

import UIKit
import OpAdxSdk

class NativeViewController: BaseViewController {
    
    private var nativeAd: OpAdxNativeAd?
    
    override var adFormat: AdFormat {
        return .native
    }
    
    override var adFormatString: String {
        return "Native Ad"
    }
    
    override func loadAd() {

        guard let placementId = self.placementId else {
            logView.print("error, placementId is nil!")
            return
        }
        if nativeAd != nil {
            self.destroyAd()
        }
        logView.print("Loading...")
        OpAdxLogger.logAdLoadStart(adFormat: "Native", placementId: placementId)

        nativeAd = OpAdxNativeAd(placementId: placementId, auctionType: AdAuctionType.regular)

        // 创建监听器实例
        let listener = OpAdxNativeAdListenerImp(
            onAdLoaded: { [weak self] ad in
                guard let self = self, let ad = ad as? OpAdxNativeAd else { return }
                if let title = ad.title() {
                    self.logView.print("Loaded, ad: \(title)")
                } else {
                    self.logView.print("Loaded")
                }
                OpAdxLogger.logAdLoadSuccess(adFormat: "Native", placementId: placementId)
                self.enableShowAd()
                self.enableDestroyAd()
            },
            onAdFailedToLoad: { [weak self] error in
                guard let self = self else { return }
                self.logView.print(error.message)
                OpAdxLogger.logAdLoadFailed(adFormat: "Native", placementId: placementId, error: error)
            },
            onAdImpression: { [weak self] in
                guard let self = self else { return }
                self.logView.print("onAdImpression")
                OpAdxLogger.logAdImpression(adFormat: "Native", placementId: placementId)
            },
            onAdClicked:{ [weak self] in
                guard let self = self else { return }
                self.logView.print("onAdClicked")
                OpAdxLogger.logAdClick(adFormat: "Native", placementId: placementId)
            }
        )

        nativeAd?.loadAd(listener: listener)
    }
    
    override func showAd() {
        guard let nativeAd = nativeAd, !nativeAd.isAdInvalidated() else {
            logView.print("Ad is invalidated.")
            destroyAd()
            return
        }
        
        nativeAd.setAdChoicePosition(.topRight)
        
        // 创建并配置原生广告视图
        let nativeAdView = OpAdxNativeAdView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        nativeAdView.configure(with: nativeAd)
        
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置媒体视图的缩放类型
        nativeAdView.interactionViews.mediaView.setImageScaleType(.scaleAspectFill)
        
        // 将 NativeAdRootView 添加到容器
        adContainer.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nativeAdView.leadingAnchor.constraint(equalTo: adContainer.leadingAnchor),
            nativeAdView.trailingAnchor.constraint(equalTo: adContainer.trailingAnchor),
            nativeAdView.topAnchor.constraint(equalTo: adContainer.topAnchor),
            nativeAdView.bottomAnchor.constraint(equalTo: adContainer.bottomAnchor),
        ])
        
        nativeAd.registerInteractionViews(container: OpAdxNativeAdRootView(root: nativeAdView), interactionViews: nativeAdView.interactionViews, adChoicePosition: .topRight)
        
        disableShowAd()
        enableDestroyAd()
    }
    
    override func destroyAd() {
        super.destroyAd()
        nativeAd?.destroy()
        nativeAd = nil
        disableShowAd()
        disableDestroyAd()
        logView.print("Destroyed...")
    }
    
    deinit {
        destroyAd()
    }
}
