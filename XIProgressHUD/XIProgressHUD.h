//
//  XIProgressHUD.h
//  XIProgressHUD
//
//  Created by YXLONG on 2016/12/14.
//  Copyright © 2016年 yxlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XIProgressHUDStyle) {
    XIProgressHUDStyleLoading,
    XIProgressHUDStyleToast
};

@interface XIProgressHUD : UIView

/**
 * @param aView the superview of XIProgressHUD.
 * @param status the hint for the process or message to toast.
 * @param dismissAfter if the value of dismissAfter is negative , XIProgressHUD view would be on aView for ever.
 */
+ (void)showProgressHUDOnView:(UIView *)aView
                       status:(NSString *)status
                        style:(XIProgressHUDStyle)style
                 dismissAfter:(NSTimeInterval)dismissAfter;

+ (void)showStatus:(NSString *)status onView:(UIView *)aView;
+ (void)showToast:(NSString *)message onView:(UIView *)aView dismissAfter:(NSTimeInterval)dismissAfter;

/**
 * Remove the pending message in queue and remove the visible on aView.
 */
+ (void)dismissVisibleProgressHUDsOnView:(UIView *)aView animated:(BOOL)animated;
@end
