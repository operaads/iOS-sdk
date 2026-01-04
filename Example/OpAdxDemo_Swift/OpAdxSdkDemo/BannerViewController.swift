//
//  BannerViewController.swift
//  OperaAdxSDK
//
//  Created by Luan Chen on 2025/11/4.
//

import UIKit
import OpAdxSdk

class BannerViewController: BaseViewController {
    
    private var bannerAdView: OpAdxBannerAdView?
    
    override var hasVideo: Bool {
        return true
    }
    
    override var adFormatString: String {
        return "Banner Ad"
    }
    
    override func loadAd() {
        destroyAd()
        
        if bannerAdView == nil {
            bannerAdView = OpAdxBannerAdView()
        }
        
        logView.print("Loading ...")
        
        bannerAdView?.setPlacementId(placementId!)
        bannerAdView?.setAdSize(.BANNER_MREC)

        // 创建遵循 BannerAdListener 协议的实例
        let listener = OpAdxBannerAdListenerImp(
           onAdLoaded: { [weak self] bannerAdInfo in
               guard let self = self, let bannerAdInfo = bannerAdInfo as? OpAdxBannerAdInfo else { return }
               self.logView.print("Loaded \(bannerAdInfo.adSize), refreshCount: \(bannerAdInfo.refreshCount)")
               self.enableShowAd()
               self.enableDestroyAd()
           },
           onAdFailedToLoad: { [weak self] error in
               guard let self = self else { return }
               self.logView.print(error.message)
           },
           onAdImpression: { [weak self] in
               guard let self = self else { return }
               self.logView.print("Impression!")
           },
           onAdClicked: { [weak self] in
               guard let self = self else { return }
               self.logView.print("Clicked!")
           }
        )
        bannerAdView?.loadAd(listener: listener)
    }
    
    override func showAd() {
        guard let bannerAdView = bannerAdView else { return }
#if DEBUG
#else
        if bannerAdView.isAdInvalidated {
            logView.print("Ad is invalidated")
            destroyAd()
            return
        }
#endif
        
        bannerAdView.translatesAutoresizingMaskIntoConstraints = false
        adContainer.addSubview(bannerAdView)
        
        NSLayoutConstraint.activate([
            bannerAdView.centerXAnchor.constraint(equalTo: adContainer.centerXAnchor),
            bannerAdView.centerYAnchor.constraint(equalTo: adContainer.centerYAnchor),
            bannerAdView.widthAnchor.constraint(equalToConstant: 300),
            bannerAdView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        enableDestroyAd()
        disableShowAd()
    }
    
    override func destroyAd() {
        super.destroyAd()
        bannerAdView?.destroy()
        bannerAdView = nil
        
        adContainer.subviews.forEach { $0.removeFromSuperview() }
        disableShowAd()
        disableDestroyAd()
    }
    
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
        bannerAdView = nil
    }
}

