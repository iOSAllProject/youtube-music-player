//
//  UIButton+JCAdditions.m
//  JCPullToRefreshView
//
//  Created by 李京城 on 15/7/9.
//  Copyright (c) 2015年 李京城. All rights reserved.
//

#import "UIButton+JCAdditions.h"
#import <objc/runtime.h>

static const void *activityViewKey;

@implementation UIButton (JCAdditions)

- (void)setActivityView:(UIActivityIndicatorView *)activityView
{
    objc_setAssociatedObject(self, &activityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIActivityIndicatorView *)activityView
{
    if (objc_getAssociatedObject(self, &activityViewKey) == nil) {
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityView.frame = CGRectMake(self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width, (self.frame.size.height-16)/2, 16, 16);
        [self addSubview:self.activityView];
    }
    
    return objc_getAssociatedObject(self, &activityViewKey);
}

@end
