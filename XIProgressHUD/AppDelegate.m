//
//  AppDelegate.m
//  XIProgressHUD
//
//  Created by YXLONG on 2016/12/14.
//  Copyright © 2016年 yxlong. All rights reserved.
//

#import "AppDelegate.h"
#import "XIProgressHUD.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
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
    
//    [XIProgressHUD showToast:@"didFinishLaunchingWithOptions" onView:self.window dismissAfter:2];
//    [XIProgressHUD showToast:@"applicationWillResignActive" onView:self.window dismissAfter:-1];
//    [XIProgressHUD showStatus:@"applicationDidEnterBackground" onView:self.window];
//    [XIProgressHUD showStatus:@"applicationWillEnterForeground" onView:self.window];
//    [XIProgressHUD showToast:@"applicationWillTerminate" onView:self.window dismissAfter:1.5];
    
    [XIProgressHUD showProgressHUDOnView:self.window
                            toastGravity:ToastGravityTop
                                  status:@"applicationDidBecomeActive1"
                                   style:XIProgressHUDStyleToast
                            dismissAfter:1.5];
    [XIProgressHUD showProgressHUDOnView:self.window
                            toastGravity:ToastGravityCenter
                                  status:@"applicationDidBecomeActive2"
                                   style:XIProgressHUDStyleToast
                            dismissAfter:1.5];
    [XIProgressHUD showProgressHUDOnView:self.window
                            toastGravity:ToastGravityTop
                                  status:@"applicationDidBecomeActive3"
                                   style:XIProgressHUDStyleToast
                            dismissAfter:1.5];
    
    [XIProgressHUD showProgressHUDOnView:self.window
                            toastGravity:ToastGravityTop
                                  status:@"applicationDidBecomeActive4"
                                   style:XIProgressHUDStyleToast
                            dismissAfter:-1];
    
    [XIProgressHUD showProgressHUDOnView:self.window
                            toastGravity:ToastGravityTop
                                  status:@"applicationDidBecomeActive5-3"
                                   style:XIProgressHUDStyleToast
                            dismissAfter:3];
    
    [XIProgressHUD showToast:@"applicationDidBecomeActive6"
                toastGravity:ToastGravityCenter
                      onView:self.window
                dismissAfter:-1];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [XIProgressHUD showToast:@"applicationDidBecomeActive7"
                    toastGravity:ToastGravityTop
                          onView:self.window
                    dismissAfter:2];
    });
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
