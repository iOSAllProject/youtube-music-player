//
//  JCPullToRefreshView.m
//  JCPullToRefreshView
//
//  Created by 李京城 on 15/5/13.
//  Copyright (c) 2015年 李京城. All rights reserved.
//

#import "JCPullToRefreshView.h"
#import "FBKVOController.h"

#define kDefaultDistance 70.0f

@interface JCPullToRefreshView()

@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, copy) PullToRefreshCallback callback;

@end

@implementation JCPullToRefreshView

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    if (self = [super init]) {
        self.layer.masksToBounds = YES;
        
        self.scrollView = scrollView;
        self.contentInset = UIEdgeInsetsMake(-1, -1, -1, -1);
        
        CGFloat width = 40.0f;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-width)/2, (kDefaultDistance-width)/2, width, width)];
        self.imageView.image = [UIImage imageNamed:@"logo"];
        
        [self addSubview:self.imageView];
        
        [self.KVOController observe:self.scrollView keyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld action:@selector(observeContentOffset:)];
    }
    
    return self;
}

- (void)layoutSubviews
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.contentInset, UIEdgeInsetsMake(-1, -1, -1, -1))) {
        self.contentInset = self.scrollView.contentInset;
    }
}

- (void)startRefresh
{
    [self startAnimation];
    
    [UIView animateWithDuration:.6f delay:0.f usingSpringWithDamping:0.6f initialSpringVelocity:0.2f options:UIViewAnimationOptionCurveLinear animations:^{
        [self.scrollView setContentOffset:CGPointMake(0.f, -(self.contentInset.top + kDefaultDistance)) animated:NO];
        
        UIEdgeInsets inset = self.contentInset;
        inset.top += kDefaultDistance;
        self.scrollView.contentInset = inset;
    } completion:^(BOOL finished) {
        _isRefreshing = YES;
        
        if (self.callback) {
            self.callback();
        }
    }];
}

- (void)endRefresh
{
    [self stopAnimation];
    
    [UIView animateWithDuration:.8f delay:0.f usingSpringWithDamping:0.4f initialSpringVelocity:0.8f options:UIViewAnimationOptionCurveLinear animations:^{
        self.scrollView.contentInset = self.contentInset;
    } completion:^(BOOL finished) {
        _isRefreshing = NO;
        
        self.frame = CGRectZero;
    }];
}

- (void)setPullToRefreshCallback:(PullToRefreshCallback)callback
{
    self.callback = callback;
}

#pragma mark - private method

- (void)observeContentOffset:(NSDictionary *)change
{
    if (!self.isRefreshing) {
        if (self.scrollView.contentOffset.y < 0) {
            self.frame = CGRectMake(0.0f, 0.0f, self.scrollView.frame.size.width, self.scrollView.contentOffset.y + self.contentInset.top);
            
            CGFloat scale = MIN((-(self.scrollView.contentOffset.y + self.contentInset.top) + (100 - kDefaultDistance))/100, 1);
            self.imageView.transform = CGAffineTransformMakeScale(scale, scale);
            
            if(!self.scrollView.dragging && self.scrollView.decelerating && self.scrollView.contentOffset.y <= -(kDefaultDistance + self.contentInset.top - 10)) {
                [self startRefresh];
            }
        }
    }
}

- (void)startAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    NSValue *minScale = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.6, 0.6, 1)];
    NSValue *maxScale = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    animation.values = @[maxScale, minScale, maxScale];
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 1.0f;
    animation.repeatCount = HUGE_VALF;
    
    [self.imageView.layer addAnimation:animation forKey:@"refreshAnimation"];
}

- (void)stopAnimation
{
    [self.imageView.layer removeAnimationForKey:@"refreshAnimation"];
}

@end