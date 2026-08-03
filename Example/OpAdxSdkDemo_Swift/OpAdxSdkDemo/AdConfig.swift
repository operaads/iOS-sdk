//
//  AdConfig.swift
//  OperaAdxSDK
//
//  Created by Luan Chen on 2025/11/4.
//

import Foundation
import OpAdxSdk

final class AdConfig {
    static let useAndroidConfig = false //test
    private static let useTestServer = true && useAndroidConfig //test

    public static let applicationId = "pub13423013211200/ep13423013211584/app14170937163904"
    public static let iOSAppId = "1444253128"
    
    private static let nativePlacementId = "s14198263063424"
    private static let nativeVideoPlacementId = "s15559042872128"
    private static let bannerPlacementId = "s14170965187264"
    private static let bannerVideoPlacementId = "s14198605602880"
    private static let interstitialPlacementId = "s14198264979520"
    private static let interstitialVideoPlacementId = "s14198603681728"
    private static let rewardedPlacementId = "s14198592226752"
    private static let rewardedInterstitialPlacementId = "s14496445187904"
    private static let appOpenPlacementId = "s14496438551808"
    
    
    public static let android_applicationId = useTestServer ?
        "pub13124398458816/ep13374306271488/app13336434553408" :
        "pub13423013211200/ep13423013211584/app13423536670400"
    
    private static let android_nativePlacementId = useTestServer ? "s13336452960512" : "s13429368154496"
    private static let android_bannerPlacementId = useTestServer ? "s13336445508160" : "s13423621779136"
    private static let android_bannerVideoPlacementId = useTestServer ? "s13391091037312" : "s13429297184768"
    private static let android_interstitialPlacementId = useTestServer ? "s13391104307072" : "s13423624619200"
    private static let android_interstitialVideoPlacementId = useTestServer ? "s13391097365952" : "s13424442482432"
    private static let android_rewardedPlacementId = useTestServer ? "s13584962043136" : "s13938889680960"
    private static let android_appOpenPlacementId = useTestServer ? "s14364818715776" : "s14352673721856"
    private static let android_rewardedInterstitialPlacementId = useTestServer ? "s14353628765376" : "s14352672069184"
    
    
    public static func getPlacementId(adFormat: AdFormat, forceVideo: Bool) -> String {
        switch adFormat {
        case .native:
            if useAndroidConfig {
                return android_nativePlacementId
            }
            return forceVideo ? nativeVideoPlacementId : nativePlacementId
        case .banner:
            if useAndroidConfig {
                return forceVideo ? android_bannerVideoPlacementId : android_bannerPlacementId
            }
            return forceVideo ? bannerVideoPlacementId : bannerPlacementId
        case .interstitial:
            if useAndroidConfig {
                return forceVideo ? android_interstitialVideoPlacementId : android_interstitialPlacementId
            }
            return forceVideo ? interstitialVideoPlacementId : interstitialPlacementId
        case .rewarded:
            if useAndroidConfig {
                return android_rewardedPlacementId
            }
            return rewardedPlacementId
        case .appOpen:
            if useAndroidConfig {
                return android_appOpenPlacementId
            }
            return appOpenPlacementId
        case .rewardedInterstitial:
            if useAndroidConfig {
                return android_rewardedInterstitialPlacementId
            }
            return rewardedInterstitialPlacementId
        @unknown default:
            fatalError("Unknown ad format: \(adFormat)")
        }
    }
}
