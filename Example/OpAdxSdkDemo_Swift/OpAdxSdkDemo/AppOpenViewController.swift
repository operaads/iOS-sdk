//
//  AppOpenViewController.swift
//  OpAdxSdkDemo
//
//  Created by Luan Chen on 2026/1/19.
//

import UIKit
import OpAdxSdk

class AppOpenViewController: BaseViewController {
    
    private var appOpenAd: OpAdxAppOpenAd?
    
    override var hasVideo: Bool {
        return false
    }
    
    override var adFormat: AdFormat {
        return .appOpen
    }
    
    override var adFormatString: String {
        return "App Open Ad"
    }
    
    override func loadAd() {
        guard let placementId = placementId else { return }
        
        logView.print("Loading ...")
        if appOpenAd != nil {
            self.destroyAd()
        }
        appOpenAd = OpAdxAppOpenAd(placementId: placementId, auctionType: AdAuctionType.regular)
        
        // 创建监听器实例
        let listener = OpAdxAppOpenAdLoadListenerImp(
            onAdLoaded: { [weak self] ad in
                guard let self = self, let ad = ad as? OpAdxAppOpenAd else { return }
                self.appOpenAd = ad
                self.logView.print("Loaded")
                self.enableShowAd()
                self.enableDestroyAd()
            },
            onAdFailedToLoad: { [weak self] error in
                guard let self = self else { return }
                self.logView.print(error.message)
            }
        )
        
        appOpenAd?.load(placementId: placementId, listener: listener)
    }
    
    override func showAd() {
        guard let appOpenAd = appOpenAd else { return }
        
        if appOpenAd.isAdInvalidated() {
            logView.print("Ad is invalidated.")
            destroyAd()
            return
        }
        
        // 创建交互监听器
        let interactionListener = OpAdxAppOpenAdInteractionListenerImp(
            onAdClicked: { [weak self] in
                guard let self = self else { return }
                self.logView.print("Clicked!")
            },
            onAdDisplayed: { [weak self] in
                guard let self = self else { return }
                self.logView.print("Displayed!")
            },
            onAdDismissed: { [weak self] in
                guard let self = self else { return }
                self.logView.print("Dismissed")
                self.destroyAd()
            },
            onAdFailedToShow: { [weak self] error in
                guard let self = self else { return }
                self.logView.print(error.message)
            }
        )
        
        appOpenAd.show(on: self, listener: interactionListener)
        
        enableDestroyAd()
        disableShowAd()
    }
    
    override func destroyAd() {
        super.destroyAd()
        appOpenAd?.destroy()
        appOpenAd = nil
        logView.print("Destroyed...")
        disableDestroyAd()
        disableShowAd()
    }
    
    deinit {
        destroyAd()
    }
}
