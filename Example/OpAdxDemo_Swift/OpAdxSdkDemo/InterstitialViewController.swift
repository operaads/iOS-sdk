//
//  InterstitialViewController.swift
//  OperaAdxSDK
//
//  Created by Luan Chen on 2025/11/4.
//

import UIKit
import OpAdxSdk

class InterstitialViewController: BaseViewController {
    
    var interstitialAd: OpAdxInterstitialAd?
    
    override var hasVideo: Bool {
        return true
    }
    
    override var adFormat: AdFormat {
        return .interstitial
    }
    
    override var adFormatString: String {
        return "Interstitial Ad"
    }
    
    override func loadAd() {
        guard let placementId = placementId else { return }
        
        logView.print("Loading ...")
        if interstitialAd != nil {
            self.destroyAd()
        }
        interstitialAd = OpAdxInterstitialAd(placementId: placementId)

        // 创建监听器实例
        let listener = OpAdxInterstitialAdLoadListenerImp(
            onAdLoaded: { [weak self] ad in
                guard let self = self else { return }
                
                self.logView.print("Loaded")
                self.enableShowAd()
                self.enableDestroyAd()
            },
            onAdFailedToLoad: { [weak self] error in
                guard let self = self else { return }
                self.logView.print(error.message)
            }
        )
        
        interstitialAd?.load(placementId: placementId, listener: listener)
    }
    
    override func showAd() {
        guard let interstitialAd = interstitialAd else { return }
        
        if interstitialAd.isAdInvalidated() {
            logView.print("Ad is invalidated.")
            destroyAd()
            return
        }
        
        // 创建交互监听器
        let interactionListener = OpAdxInterstitialAdInteractionListenerImp(
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
            },
            onAdFailedToShow: { [weak self] error in
                guard let self = self else { return }
                self.logView.print(error.message)
            }
        )
        
        interstitialAd.show(on: self, listener: interactionListener)
        
        enableDestroyAd()
        disableShowAd()
    }
    
    override func destroyAd() {
        super.destroyAd()
        interstitialAd?.destroy()
        interstitialAd = nil
        disableDestroyAd()
        disableShowAd()
    }
}
