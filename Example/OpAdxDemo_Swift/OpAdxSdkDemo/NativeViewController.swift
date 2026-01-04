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
//        
//        UIApplication.shared.open(URL(string: "op-news://newsfeed/article?country=fr&lang=fr&news_entry_id=1441a8a8200828fr_fr&ch=entertainment")!, options: [:])
//        return
        
        guard let placementId = self.placementId else {
            logView.print("error, placementId is nil!")
            return
        }
        if nativeAd != nil {
            self.destroyAd()
        }
        logView.print("Loading...")
        nativeAd = OpAdxNativeAd(placementId: placementId)
        
        // 创建监听器实例
        let listener = OpAdxNativeAdListenerImp(
            onAdLoaded: { [weak self] ad in
                guard let self = self, let ad = ad as? OpAdxNativeAd else { return }
                if let title = ad.title() {
                    self.logView.print("Loaded, ad: \(title)")
                } else {
                    self.logView.print("Loaded")
                }
                self.enableShowAd()
                self.enableDestroyAd()
            },
            onAdFailedToLoad: { [weak self] error in
                guard let self = self else { return }
                self.logView.print(error.message)
            },
            onAdImpression: { [weak self] in
                guard let self = self else { return }
                self.logView.print("onAdImpression")
            },
            onAdClicked:{ [weak self] in
                guard let self = self else { return }
                self.logView.print("onAdClicked")
            }
        )
        
        nativeAd?.loadAd(placementId: placementId, listener: listener)
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
        
        nativeAd.registerInteractionViews(container: OpAdxNativeAdRootView(root: nativeAdView), interactionViews: nativeAdView.interactionViews, adChoicePosition: .topRight)//akai
        
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
}
