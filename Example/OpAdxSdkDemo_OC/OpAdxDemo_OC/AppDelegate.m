//
//  AppDelegate.m
//  OpAdxDemo_OC
//
//  Created by Luan Chen on 2025/12/10.
//

#import "AppDelegate.h"
#import <OpAdxSdk/OpAdxSdk.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // 启用Debug日志（在SDK初始化之前）
    OpAdxLogger.logLevel = OpAdxLogLevelDebug;

    NSString *applicationId = @"pub13423013211200/ep13423013211584/app14170937163904";
    NSString *iOSAppId = @"1444253128";

    OpAdxSdkInitConfig *initConfig = [OpAdxSdkInitConfig createWithApplicationId:applicationId iOSAppId:iOSAppId publisherName:nil];

    [OpAdxLogger info:@"===========================================" tag:@"OpAdx-Init"];
    [OpAdxLogger info:@"📱 Initializing Opera Ads SDK..." tag:@"OpAdx-Init"];
    [OpAdxLogger info:[NSString stringWithFormat:@"   Application ID: %@", applicationId] tag:@"OpAdx-Init"];
    [OpAdxLogger info:[NSString stringWithFormat:@"   iOS App ID: %@", iOSAppId] tag:@"OpAdx-Init"];
    [OpAdxLogger info:@"===========================================" tag:@"OpAdx-Init"];

    [OpAdxSDK initializeWithConfig:initConfig
                         onSuccess:^{
        [OpAdxLogger info:@"✅ SDK initialized successfully" tag:@"OpAdx-Init"];
        NSString *version = [NSString stringWithFormat:@"   SDK Version: %@.%@",
                             [OpAdxSdkCore getVersion], [OpAdxSdkCore getBuildNum]];
        [OpAdxLogger info:version tag:@"OpAdx-Init"];
    }
                           onError:^(NSError * _Nonnull error) {
        [OpAdxLogger logError:@"❌ SDK initialization failed" tag:@"OpAdx-Init"];
        NSString *errorMsg = [NSString stringWithFormat:@"   Error: %@", error.localizedDescription];
        [OpAdxLogger logError:errorMsg tag:@"OpAdx-Init"];
    }];

    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
