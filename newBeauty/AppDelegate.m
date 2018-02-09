//
//  AppDelegate.m
//  newBeauty
//
//  Created by air on 2018/1/12.
//  Copyright © 2018年 com.xinfeng. All rights reserved.
//

#import "AppDelegate.h"
#import "WebViewController.h"
#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>
#import <UMPush/UMessage.h>
#import <UserNotifications/UserNotifications.h>
#import <UMShare/UMShare.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UMConfigure setLogEnabled:YES];
    [UMConfigure initWithAppkey:@"5a66ab7ea40fa3294000003d" channel:@"App Store"];
    [MobClick setScenarioType:E_UM_NORMAL];
    
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate=self;
    } else {
        // Fallback on earlier versions
    }
    UMessageRegisterEntity *entity=[[UMessageRegisterEntity alloc]init];
    entity.types=UMessageAuthorizationOptionAlert|UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionSound;
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {//通知授权
            
        }else{
            
        }
    }];
    [UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    
    [[UMSocialManager defaultManager]setPlaform:UMSocialPlatformType_WechatFavorite appKey:@"wxf973a8d29798de66" appSecret:@"cecea9aa8de046213d4c1ed32fb82f4e" redirectURL:nil];
    [[UMSocialManager defaultManager]setPlaform:UMSocialPlatformType_QQ appKey:@"1106685970" appSecret:nil   redirectURL:@"http://mobile.umeng.com/social"];
    [[UMSocialManager defaultManager]setPlaform:UMSocialPlatformType_Sina appKey:@"3729738588" appSecret:@"c58a55f14e9d40a369b75fd72c8b821f" redirectURL:@"https://api.weibo.com/oauth2/default.html"];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformType:UMSocialPlatformType_WechatFavorite];

    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    WebViewController *viewController=[[WebViewController alloc]init];
    
//    viewController.hidesBottomBarWhenPushed = YES;
//    viewController.tabBarController.tabBar.hidden = YES;
//
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:viewController];
    
    self.window.rootViewController=nav;
    
    NSString *appCurVersionNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newUserAgent = [userAgent stringByAppendingString: [NSString stringWithFormat:@"%@%@", @"|app_ios|v",appCurVersionNum]];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    [self.window makeKeyAndVisible];
    
//    if([CLLocationManager locationServicesEnabled]){
//       CLLocationManager *manager = [[CLLocationManager alloc] init];
//        [manager requestWhenInUseAuthorization];
//        [manager requestAlwaysAuthorization];
//    };
    

    [NSThread sleepForTimeInterval:1];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];

}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    if (@available(iOS 10.0, *)) {
        if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [UMessage setAutoAlert:NO];
            [UMessage didReceiveRemoteNotification:userInfo];
        }
    } else {
        // Fallback on earlier versions
    }
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if (@available(iOS 10.0, *)) {
        if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [UMessage didReceiveRemoteNotification:userInfo];
        }
    } else {
        // Fallback on earlier versions
    }
}



// 支持所有iOS系统
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager]  handleOpenURL:url options:options];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

@end
