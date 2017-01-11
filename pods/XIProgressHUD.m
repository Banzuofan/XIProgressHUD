//
//  XIProgressHUD.m
//  XIProgressHUD
//
//  Created by YXLONG on 2016/12/14.
//  Copyright © 2016年 yxlong. All rights reserved.
//

#import "XIProgressHUD.h"
#import "OCInsetLabelView.h"

#define kDefaultBackgroundCornerRadius 8.0
#define kDefaultPreferredMaxLayoutWidth 280.0
#define kAppearAnimationDuration 0.25
#define kDisappearAnimationDuration 0.20
#define LoadingWithTextMargin 15
#define LoadingWithTextSpacer 2
#define ProgressHUDLoadingMinLen 90
#define ProgressHUDLoadingWithTextMinLen 120
#define ProgressHUDToastMinLen 120
#define kToastGravityTopMargin 64
#define kToastGravityAnimatedTopMargin 94
#define kDefaultDamping 0.8
#define kDefaultSpringVelocity 20

@interface __ProgressHUDQueue : NSObject
@property(nonatomic, weak) XIProgressHUD *currentProgressHUD;
@property(nonatomic, assign, getter=isAnimating) BOOL animating;
+ (instancetype)sharedQueue;
- (BOOL)isEmpty;
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
@property(nonatomic) XIToastGravity toastGravity;
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
    if([__ProgressHUDQueue sharedQueue].currentProgressHUD && ![__ProgressHUDQueue sharedQueue].isEmpty){
        
        XIProgressHUD *dismissingView = [__ProgressHUDQueue sharedQueue].currentProgressHUD;
        [__ProgressHUDQueue sharedQueue].animating = YES;
        [UIView animateWithDuration:kDisappearAnimationDuration animations:^{
            dismissingView.alpha = 0;
        } completion:^(BOOL finished) {
            [__ProgressHUDQueue sharedQueue].animating = NO;
            
            [[__ProgressHUDQueue sharedQueue] remove:dismissingView];
            
            [dismissingView removeFromSuperview];
            [__ProgressHUDQueue sharedQueue].currentProgressHUD = nil;
            
            [self showProgressHUDInQueueOnView:aView];
        }];
        return;
    }
    
    XIProgressHUD *nextView = (XIProgressHUD *)[[__ProgressHUDQueue sharedQueue] dequeue];
    if(nextView){
        [aView addSubview:nextView];
        nextView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *topMarginConstraint = nil;
        if(nextView.style==XIProgressHUDStyleToast && nextView.toastGravity==ToastGravityTop){
            topMarginConstraint = [NSLayoutConstraint constraintWithItem:nextView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:aView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:kToastGravityTopMargin];
            
            [aView addConstraints:@[[NSLayoutConstraint constraintWithItem:nextView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:aView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0],topMarginConstraint]];
        }
        else{
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
        }
        
        nextView.alpha = 0;
        [__ProgressHUDQueue sharedQueue].animating = YES;
        
        // Ensures that all pending layout operations have been completed
        [aView layoutIfNeeded];
        
        [UIView animateWithDuration:kAppearAnimationDuration delay:0 usingSpringWithDamping:kDefaultDamping initialSpringVelocity:kDefaultSpringVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
            nextView.alpha = 1;
            
            if(topMarginConstraint){
                topMarginConstraint.constant = kToastGravityAnimatedTopMargin;
                [aView layoutIfNeeded];
            }
        } completion:^(BOOL finished) {
            [__ProgressHUDQueue sharedQueue].animating = NO;
            if(nextView.dismissAfter<0){
                
                [__ProgressHUDQueue sharedQueue].currentProgressHUD = nextView;
                [[__ProgressHUDQueue sharedQueue] remove:nextView];// remove currentProgressHUD from queue
                
                [self showProgressHUDInQueueOnView:aView];
            }
            else{
                [__ProgressHUDQueue sharedQueue].animating = YES;
                [UIView animateWithDuration:kDisappearAnimationDuration delay:nextView.dismissAfter options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    nextView.alpha = 0;
                    
                    if(topMarginConstraint){
                        topMarginConstraint.constant = kToastGravityTopMargin;
                        [aView layoutIfNeeded];
                    }
                    
                } completion:^(BOOL finished) {
                    [__ProgressHUDQueue sharedQueue].animating = NO;
                    [nextView removeFromSuperview];
                    [[__ProgressHUDQueue sharedQueue] remove:nextView];
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
                 toastGravity:(XIToastGravity)toastGravity
                       status:(NSString *)status
                        style:(XIProgressHUDStyle)style
                 dismissAfter:(NSTimeInterval)dismissAfter
{
    XIProgressHUD *view = [[XIProgressHUD alloc] initWithFrame:CGRectZero text:status style:style];
    view.dismissAfter = dismissAfter;
    view.toastGravity = toastGravity;
    view.style = style;
    
    if([__ProgressHUDQueue sharedQueue].currentProgressHUD){
        
        if(![[__ProgressHUDQueue sharedQueue] contains:view]){
            [[__ProgressHUDQueue sharedQueue] enqueue:view];
        }
        
        XIProgressHUD *dismissingView = [__ProgressHUDQueue sharedQueue].currentProgressHUD;
        [__ProgressHUDQueue sharedQueue].animating = YES;
        [UIView animateWithDuration:kDisappearAnimationDuration animations:^{
            dismissingView.alpha = 0;
        } completion:^(BOOL finished) {
            [__ProgressHUDQueue sharedQueue].animating = NO;
            
            [[__ProgressHUDQueue sharedQueue] remove:dismissingView];
            
            [dismissingView removeFromSuperview];
            [__ProgressHUDQueue sharedQueue].currentProgressHUD = nil;
            
            [self showProgressHUDInQueueOnView:aView];
        }];
        
        return;
    }
    
    if([__ProgressHUDQueue sharedQueue].isAnimating){
        
        if(![[__ProgressHUDQueue sharedQueue] contains:view]){
            [[__ProgressHUDQueue sharedQueue] enqueue:view];
        }
        return;
    }
    
    [aView addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *topMarginConstraint = nil;
    if(style==XIProgressHUDStyleToast && toastGravity==ToastGravityTop){
        
        topMarginConstraint = [NSLayoutConstraint constraintWithItem:view
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:aView
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1
                                                            constant:kToastGravityTopMargin];
        
        [aView addConstraints:@[[NSLayoutConstraint constraintWithItem:view
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:aView
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1
                                                              constant:0],topMarginConstraint]];
    }
    else{
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
    }
    
    [__ProgressHUDQueue sharedQueue].animating = YES;
    view.alpha = 0;
    // Ensures that all pending layout operations have been completed
    [aView layoutIfNeeded];
    
    [UIView animateWithDuration:kAppearAnimationDuration delay:0 usingSpringWithDamping:kDefaultDamping initialSpringVelocity:kDefaultSpringVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.alpha = 1;
        
        if(topMarginConstraint){
            topMarginConstraint.constant = kToastGravityAnimatedTopMargin;
            [aView layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        [__ProgressHUDQueue sharedQueue].animating = NO;
        if(dismissAfter<0){
            [__ProgressHUDQueue sharedQueue].currentProgressHUD = view;
            [[__ProgressHUDQueue sharedQueue] remove:view];// remove currentProgressHUD from queue
            
            [self showProgressHUDInQueueOnView:aView];
        }
        else{
            [__ProgressHUDQueue sharedQueue].animating = YES;
            
            [UIView animateWithDuration:kDisappearAnimationDuration delay:view.dismissAfter options:UIViewAnimationOptionCurveEaseInOut animations:^{
                view.alpha = 0.0;
                
                if(topMarginConstraint){
                    topMarginConstraint.constant = kToastGravityTopMargin;
                    [aView layoutIfNeeded];
                }
                
            } completion:^(BOOL finished) {
                [__ProgressHUDQueue sharedQueue].animating = NO;
                [view removeFromSuperview];
                [self showProgressHUDInQueueOnView:aView];
            }];
        }
    }];
}

+ (void)showProgressHUDOnView:(UIView *)aView
                       status:(NSString *)status
                        style:(XIProgressHUDStyle)style
                 dismissAfter:(NSTimeInterval)dismissAfter
{
    [XIProgressHUD showProgressHUDOnView:aView
                            toastGravity:ToastGravityCenter
                                  status:status
                                   style:style
                            dismissAfter:dismissAfter];
}

+ (void)showStatus:(NSString *)status onView:(UIView *)aView
{
    [self showProgressHUDOnView:aView status:status style:XIProgressHUDStyleLoading dismissAfter:-1];
}

+ (void)showToast:(NSString *)message onView:(UIView *)aView dismissAfter:(NSTimeInterval)dismissAfter
{
    [self showProgressHUDOnView:aView status:message style:XIProgressHUDStyleToast dismissAfter:dismissAfter];
}

+ (void)showToast:(NSString *)message toastGravity:(XIToastGravity)toastGravity onView:(UIView *)aView dismissAfter:(NSTimeInterval)dismissAfter
{
    [XIProgressHUD showProgressHUDOnView:aView
                            toastGravity:toastGravity
                                  status:message
                                   style:XIProgressHUDStyleToast
                            dismissAfter:dismissAfter];
}

+ (void)dismissVisibleProgressHUDsOnView:(UIView *)aView animated:(BOOL)animated
{
    [[__ProgressHUDQueue sharedQueue] removeAll];
    
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

+ (void)clears
{
    XIProgressHUD *view = (XIProgressHUD *)[[__ProgressHUDQueue sharedQueue] dequeue];
    while (view) {
        [XIProgressHUD dismissVisibleProgressHUDsOnView:view.superview animated:NO];
        [[__ProgressHUDQueue sharedQueue] remove:view];
        
        view = (XIProgressHUD *)[[__ProgressHUDQueue sharedQueue] dequeue];
    }
    
    if([__ProgressHUDQueue sharedQueue].currentProgressHUD){
        [[__ProgressHUDQueue sharedQueue].currentProgressHUD removeFromSuperview];
        [__ProgressHUDQueue sharedQueue].currentProgressHUD = nil;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.cornerRadius = kDefaultBackgroundCornerRadius;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:kDefaultBackgroundCornerRadius].CGPath;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = 3.0;
    self.layer.shadowOpacity = 0.5;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:kDefaultBackgroundCornerRadius];
    [[UIColor colorWithWhite:0. alpha:0.8] setFill];
    [path fill];
}

@end

@implementation __ProgressHUDQueue
{
    NSMutableArray *_queuePool;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedQueue{
    static __ProgressHUDQueue *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[__ProgressHUDQueue alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if(self=[super init]){
        _queuePool = @[].mutableCopy;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeAllPendingViews)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)removeAllPendingViews
{
    [XIProgressHUD clears];
}

- (BOOL)isEmpty
{
    return _queuePool.count==0;
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

