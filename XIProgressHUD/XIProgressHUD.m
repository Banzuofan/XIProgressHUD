//
//  XIProgressHUD.m
//  XIProgressHUD
//
//  Created by YXLONG on 2016/12/14.
//  Copyright © 2016年 yxlong. All rights reserved.
//

#import "XIProgressHUD.h"
#import "OCInsetLabelView.h"

#define kDefaultBackgroundCornerRadius 6.0
#define kDefaultPreferredMaxLayoutWidth 280.0
#define kAppearAnimationDuration 0.25
#define kDisappearAnimationDuration 0.15
#define LoadingWithTextMargin 15
#define LoadingWithTextSpacer 2
#define ProgressHUDLoadingMinLen 90
#define ProgressHUDLoadingWithTextMinLen 120
#define ProgressHUDToastMinLen 120


@interface XIProgressHUDQueue : NSObject
@property(nonatomic, weak) XIProgressHUD *currentProgressHUD;
@property(nonatomic, assign, getter=isAnimating) BOOL animating;
+ (instancetype)sharedQueue;
- (BOOL)contains:(UIView *)aView;
- (UIView *)dequeue;
- (void)enqueue:(UIView *)aView;
- (void)removeAll;
- (void)remove:(UIView *)aView;
@end

@interface XIProgressHUD ()
{
    OCInsetLabelView *labelView;
    UIActivityIndicatorView *indicatorView;
}
@property(nonatomic) NSTimeInterval dismissAfter;
@property(nonatomic) XIProgressHUDStyle style;
@end

@implementation XIProgressHUD

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text style:(XIProgressHUDStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _style = style;
        
        if((text && text.length>0) || style==XIProgressHUDStyleToast){
            labelView = [[OCInsetLabelView alloc] initWithFrame:CGRectZero];
            labelView.textAlignment = NSTextAlignmentCenter;
            labelView.textColor = [UIColor whiteColor];
            labelView.font = [UIFont systemFontOfSize:16.0];
            labelView.text = text;
            labelView.preferredMaxLayoutWidth = kDefaultPreferredMaxLayoutWidth;
            labelView.contentInsets = UIEdgeInsetsMake(15, 20, 15, 20);
            [self addSubview:labelView];
            labelView.translatesAutoresizingMaskIntoConstraints = NO;
            [labelView setContentHuggingPriority:751 forAxis:0];
            [labelView setContentHuggingPriority:751 forAxis:1];
        }
        
        if(style==XIProgressHUDStyleToast){
            if(labelView){
                labelView.contentInsets = UIEdgeInsetsMake(15, 20, 15, 20);
                
                NSArray *arr = @[[NSLayoutConstraint constraintWithItem:labelView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0],
                                 [NSLayoutConstraint constraintWithItem:labelView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0]];
                [self addConstraints:arr];
            }
        }
        else if(style==XIProgressHUDStyleLoading){
            
            indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [self addSubview:indicatorView];
            [indicatorView startAnimating];
            indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
            [indicatorView setContentHuggingPriority:751 forAxis:0];
            [indicatorView setContentHuggingPriority:751 forAxis:1];
            
            NSMutableArray *arr = @[].mutableCopy;
            
            if(labelView){
                labelView.contentInsets = UIEdgeInsetsMake(0, LoadingWithTextMargin, LoadingWithTextMargin, LoadingWithTextMargin);
                
                [arr addObjectsFromArray:@[[NSLayoutConstraint constraintWithItem:indicatorView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1
                                                                         constant:LoadingWithTextMargin],
                                           [NSLayoutConstraint constraintWithItem:indicatorView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1
                                                                         constant:0],
                                           [NSLayoutConstraint constraintWithItem:labelView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:indicatorView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:LoadingWithTextSpacer],
                                           [NSLayoutConstraint constraintWithItem:labelView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1
                                                                         constant:0]]];
                
            }
            else{
                [arr addObjectsFromArray:@[[NSLayoutConstraint constraintWithItem:indicatorView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1
                                                                         constant:0],
                                           [NSLayoutConstraint constraintWithItem:indicatorView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1
                                                                         constant:0]]];
            }
            [self addConstraints:arr];
        }
        
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    if(_style==XIProgressHUDStyleToast){
        if(labelView){
            CGFloat width = labelView.intrinsicContentSize.width>ProgressHUDToastMinLen?labelView.intrinsicContentSize.width:ProgressHUDToastMinLen;
            return CGSizeMake(width, labelView.intrinsicContentSize.height);
        }
    }
    else if(_style==XIProgressHUDStyleLoading){
        if(labelView){
            CGFloat width = labelView.intrinsicContentSize.width>ProgressHUDLoadingWithTextMinLen?labelView.intrinsicContentSize.width:ProgressHUDLoadingWithTextMinLen;
            
            CGFloat height = LoadingWithTextMargin+indicatorView.intrinsicContentSize.height+LoadingWithTextSpacer+labelView.intrinsicContentSize.height;
            
            return CGSizeMake(width, height);
        }
        else{
            return CGSizeMake(ProgressHUDLoadingMinLen, ProgressHUDLoadingMinLen);
        }
    }
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}

+ (void)showProgressHUDInQueueOnView:(UIView *)aView
{
    if([XIProgressHUDQueue sharedQueue].currentProgressHUD){
        
        XIProgressHUD *dismissingView = [XIProgressHUDQueue sharedQueue].currentProgressHUD;
        [XIProgressHUDQueue sharedQueue].animating = YES;
        [UIView animateWithDuration:kDisappearAnimationDuration animations:^{
            dismissingView.alpha = 0;
        } completion:^(BOOL finished) {
            [XIProgressHUDQueue sharedQueue].animating = NO;
            
            [[XIProgressHUDQueue sharedQueue] remove:dismissingView];
            
            [dismissingView removeFromSuperview];
            [XIProgressHUDQueue sharedQueue].currentProgressHUD = nil;
            
            [self showProgressHUDInQueueOnView:aView];
        }];
        return;
    }
    
    XIProgressHUD *nextView = (XIProgressHUD *)[[XIProgressHUDQueue sharedQueue] dequeue];
    if(nextView){
        [aView addSubview:nextView];
        nextView.translatesAutoresizingMaskIntoConstraints = NO;
        [aView addConstraints:@[[NSLayoutConstraint constraintWithItem:nextView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:aView
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:nextView
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:aView
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1
                                                              constant:0]]];
        nextView.alpha = 0;
        [XIProgressHUDQueue sharedQueue].animating = YES;
        [UIView animateWithDuration:kAppearAnimationDuration animations:^{
            nextView.alpha = 1;
        } completion:^(BOOL finished) {
            [XIProgressHUDQueue sharedQueue].animating = NO;
            if(nextView.dismissAfter<0){
                [XIProgressHUDQueue sharedQueue].currentProgressHUD = nextView;
                [self showProgressHUDInQueueOnView:aView];
            }
            else{
                [XIProgressHUDQueue sharedQueue].animating = YES;
                [UIView animateWithDuration:kDisappearAnimationDuration delay:nextView.dismissAfter options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    nextView.alpha = 0;
                } completion:^(BOOL finished) {
                    [XIProgressHUDQueue sharedQueue].animating = NO;
                    [nextView removeFromSuperview];
                    [[XIProgressHUDQueue sharedQueue] remove:nextView];
                    [self showProgressHUDInQueueOnView:aView];
                }];
            }
        }];
    }
    else{
        NSLog(@"Queue is empty.");
    }
}

+ (void)showProgressHUDOnView:(UIView *)aView
                       status:(NSString *)status
                        style:(XIProgressHUDStyle)style
                 dismissAfter:(NSTimeInterval)dismissAfter
{
    
    XIProgressHUD *view = [[XIProgressHUD alloc] initWithFrame:CGRectZero text:status style:style];
    view.dismissAfter = dismissAfter;
    
    if([XIProgressHUDQueue sharedQueue].currentProgressHUD){
        
        if(![[XIProgressHUDQueue sharedQueue] contains:view]){
            [[XIProgressHUDQueue sharedQueue] enqueue:view];
        }
        
        XIProgressHUD *dismissingView = [XIProgressHUDQueue sharedQueue].currentProgressHUD;
        [XIProgressHUDQueue sharedQueue].animating = YES;
        [UIView animateWithDuration:kDisappearAnimationDuration animations:^{
            dismissingView.alpha = 0;
        } completion:^(BOOL finished) {
            [XIProgressHUDQueue sharedQueue].animating = NO;
            
            [[XIProgressHUDQueue sharedQueue] remove:dismissingView];
            
            [dismissingView removeFromSuperview];
            [XIProgressHUDQueue sharedQueue].currentProgressHUD = nil;
            
            [self showProgressHUDInQueueOnView:aView];
        }];
        
        return;
    }
    
    if([XIProgressHUDQueue sharedQueue].isAnimating){
        
        if(![[XIProgressHUDQueue sharedQueue] contains:view]){
            [[XIProgressHUDQueue sharedQueue] enqueue:view];
        }
        return;
    }
    
    [aView addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [aView addConstraints:@[[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:aView
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0],
                            [NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:aView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]]];
    
    [XIProgressHUDQueue sharedQueue].animating = YES;
    view.alpha = 0;
    [UIView animateWithDuration:kAppearAnimationDuration animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) {
        [XIProgressHUDQueue sharedQueue].animating = NO;
        if(dismissAfter<0){
            [XIProgressHUDQueue sharedQueue].currentProgressHUD = view;
            [self showProgressHUDInQueueOnView:aView];
        }
        else{
            [XIProgressHUDQueue sharedQueue].animating = YES;
            [UIView animateWithDuration:kDisappearAnimationDuration delay:view.dismissAfter options:UIViewAnimationOptionCurveEaseInOut animations:^{
                view.alpha = 0;
            } completion:^(BOOL finished) {
                [XIProgressHUDQueue sharedQueue].animating = NO;
                [view removeFromSuperview];
                [self showProgressHUDInQueueOnView:aView];
            }];
        }
    }];
}

+ (void)showStatus:(NSString *)status onView:(UIView *)aView
{
    [self showProgressHUDOnView:aView status:status style:XIProgressHUDStyleLoading dismissAfter:-1];
}

+ (void)showToast:(NSString *)message onView:(UIView *)aView dismissAfter:(NSTimeInterval)dismissAfter
{
    [self showProgressHUDOnView:aView status:message style:XIProgressHUDStyleToast dismissAfter:dismissAfter];
}

+ (void)dismissVisibleProgressHUDsOnView:(UIView *)aView animated:(BOOL)animated
{
    [[XIProgressHUDQueue sharedQueue] removeAll];
    
    __block XIProgressHUD *viewToRemove = nil;
    for(UIView *subview in aView.subviews){
        if([subview isKindOfClass:[XIProgressHUD class]]){
            XIProgressHUD *activeView = (XIProgressHUD *)subview;
            if(activeView.dismissAfter<0){
                
                viewToRemove = activeView;
                
            }
        }
    }
    if(viewToRemove){
        if(!animated){
            [viewToRemove removeFromSuperview];
            viewToRemove = nil;
        }
        [UIView animateWithDuration:kDisappearAnimationDuration animations:^{
            viewToRemove.alpha = 0;
        } completion:^(BOOL finished) {
            [viewToRemove removeFromSuperview];
            viewToRemove = nil;
        }];
    }
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kDefaultBackgroundCornerRadius];
    [[UIColor colorWithWhite:0. alpha:0.8] setFill];
    [path fill];
}

@end

@implementation XIProgressHUDQueue
{
    NSMutableArray *_queuePool;
}

+ (instancetype)sharedQueue{
    static XIProgressHUDQueue *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XIProgressHUDQueue alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if(self=[super init]){
        _queuePool = @[].mutableCopy;
    }
    return self;
}

- (BOOL)contains:(UIView *)aView
{
    return [_queuePool containsObject:aView];
}

- (UIView *)dequeue
{
    if(_queuePool.count>0){
        return [_queuePool firstObject];
    }
    return nil;
}

- (void)enqueue:(UIView *)aView
{
    [_queuePool addObject:aView];
}

- (void)removeAll
{
    if(_queuePool.count>0){
        [_queuePool removeAllObjects];
    }
}

- (void)remove:(UIView *)aView
{
    if(_queuePool.count>0){
        if([self contains:aView]){
            [_queuePool removeObject:aView];
        }
    }
}

@end

