//
//  JCPullToRefreshView.h
//  JCPullToRefreshView
//
//  Created by 李京城 on 15/5/13.
//  Copyright (c) 2015年 李京城. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PullToRefreshCallback)(void);

@interface JCPullToRefreshView : UIView

@property (nonatomic, readonly, assign) BOOL isRefreshing;

//when pull-to-refresh display image
@property (nonatomic, strong) UIImageView *imageView;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView;

- (void)setPullToRefreshCallback:(PullToRefreshCallback)callback;

- (void)startRefresh;
- (void)endRefresh;

@end
