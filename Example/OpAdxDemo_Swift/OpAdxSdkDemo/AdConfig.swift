//
//  AdConfig.swift
//  OperaAdxSDK
//
//  Created by Luan Chen on 2025/11/4.
//

import Foundation
import OpAdxSdk

final class AdConfig {
    static let useTestAd = true //test // only use for test demo, it will false when app is realsed.
    
    public static let applicationId = "pub13423013211200/ep13423013211584/app14170937163904"
    public static let iOSAppId = "1444253128"
    
    private static let nativePlacementId = "s14198263063424"
    private static let bannerPlacementId = "s14170965187264"
    private static let bannerVideoPlacementId = "s14198605602880"
    private static let interstitialPlacementId = "s14198264979520"
    private static let interstitialVideoPlacementId = "s14198603681728"
    private static let rewardedPlacementId = "s14198592226752"
    
    
    public static func getPlacementId(adFormat: AdFormat, forceVideo: Bool) -> String {
        switch adFormat {
        case .native:
            return nativePlacementId
        case .banner:
            return forceVideo ? bannerVideoPlacementId : bannerPlacementId
        case .interstitial:
            return forceVideo ? interstitialVideoPlacementId : interstitialPlacementId
        case .rewarded:
            return rewardedPlacementId
        case .other:
            return ""
        @unknown default:
            fatalError("Unknown ad format: \(adFormat)")
        }
    }
}
