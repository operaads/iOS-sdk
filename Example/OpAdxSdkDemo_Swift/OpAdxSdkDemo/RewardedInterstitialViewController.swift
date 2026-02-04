//
//  RewardedInterstitialViewController.swift
//  OpAdxSdkDemo
//
//  Created by Luan Chen on 2026/1/19.
//

import UIKit
import OpAdxSdk

class RewardedInterstitialViewController: BaseViewController {
    
    private var rewardedInterstitialAd: OpAdxRewardedInterstitialAd?
    
    override var hasVideo: Bool {
        return false
    }
    
    override var adFormat: AdFormat {
        return .rewardedInterstitial
    }
    
    override var adFormatString: String {
        return "Rewarded Interstitial Ad"
    }
    
    override func loadAd() {
        guard let placementId = placementId else { return }
        
        logView.print("Loading ...")
        if rewardedInterstitialAd != nil {
            self.destroyAd()
        }
        
        rewardedInterstitialAd = OpAdxRewardedInterstitialAd(placementId: placementId, auctionType: AdAuctionType.regular
        )
        // 创建监听器实例
        let listener = OpAdxRewardedInterstitialAdLoadListenerImp(
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
        
        rewardedInterstitialAd?.load(placementId: placementId, listener: listener)
    }
    
    override func showAd() {
        guard let rewardedInterstitialAd = rewardedInterstitialAd else { return }
        
        if rewardedInterstitialAd.isAdInvalidated() {
            logView.print("Ad is invalidated.")
            destroyAd()
            return
        }
        
        // Set scene ID and SSV options
        // scene id: max length 100 bytes after url encoded, or will be discarded.
        rewardedInterstitialAd.setSceneId("Demo scene #2")
        
        // 创建 SSV 选项
        let rewardSsvOptions = RewardSsvOptions.Builder()
            // user id: max length 100 bytes after url encoded, or will be discarded.
            .userId("Demo user id %:{测试?}")
            // custom data: max length 1KB after url encoded, or will be discarded.
            .customData("Demo user custom data %:{测试?}#2")
            .build()
        
        rewardedInterstitialAd.setRewardSsvOptions(rewardSsvOptions)
        
        // 创建交互监听器
        let interactionListener = OpAdxRewardedInterstitialAdInteractionListenerImp(
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
            },
            onUserRewarded: { [weak self] reward in
                guard let self = self else { return }
                self.logView.print("rewarded: type=\(reward.type), amount=\(reward.amount)")
            }
        )
        
        rewardedInterstitialAd.show(on: self, listener: interactionListener)
        
        enableDestroyAd()
        disableShowAd()
    }
    
    override func destroyAd() {
        super.destroyAd()
        rewardedInterstitialAd?.destroy()
        rewardedInterstitialAd = nil
        logView.print("Destroyed...")
        disableDestroyAd()
        disableShowAd()
    }
    
    deinit {
        destroyAd()
    }
}
