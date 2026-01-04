//
//  RewardedViewController.swift
//  OperaAdxSDK
//
//  Created by Luan Chen on 2025/11/4.
//

import UIKit
import OpAdxSdk

class RewardedViewController: BaseViewController {
    
    private var rewardedAd: OpAdxRewardedAd?
    
    override var hasVideo: Bool {
        return false
    }
    
    override var adFormat: AdFormat {
        return .rewarded
    }
    
    override var adFormatString: String {
        return "Rewarded Ad"
    }
    
    override func loadAd() {
        guard let placementId = placementId else { return }
        
        logView.print("Loading ...")
        if rewardedAd != nil {
            self.destroyAd()
        }
        rewardedAd = OpAdxRewardedAd(placementId: placementId)
        
        // 创建监听器实例
        let listener = OpAdxRewardedAdLoadListenerImp(
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
        
        rewardedAd?.load(placementId: placementId, listener: listener)
    }
    
    override func showAd() {
        guard let rewardedAd = rewardedAd else { return }
        
        if rewardedAd.isAdInvalidated() {
            logView.print("Ad is invalidated.")
            destroyAd()
            return
        }
        
        // 创建交互监听器
        let interactionListener = OpAdxRewardedAdInteractionListenerImp(
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
            },
            onUserRewarded: { [weak self] reward in
                guard let self = self else { return }
                self.logView.print("rewarded: type=\(reward.type), amount=\(reward.amount)")
            }
        )
        
        rewardedAd.show(on: self, listener: interactionListener)
        
        enableDestroyAd()
        disableShowAd()
    }
    
    override func destroyAd() {
        super.destroyAd()
        rewardedAd?.destroy()
        rewardedAd = nil
        disableDestroyAd()
        disableShowAd()
    }
}
