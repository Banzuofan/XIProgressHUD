//
//  OCInsetLabelView.h
//  XIProgressHUD
//
//  Created by YXLONG on 2016/12/13.
//  Copyright © 2016年 yxlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OCInsetLabelView : UIView
{
    @private
    UILabel *_label;
}
@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, assign) UIEdgeInsets contentInsets;
@property(nonatomic) NSTextAlignment textAlignment;
@property(nonatomic) CGFloat preferredMaxLayoutWidth;
@end
