//
//  JCLoadMoreView.h
//  JCPullToRefreshView
//
//  Created by 李京城 on 15/5/13.
//  Copyright (c) 2015年 李京城. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LoadMoreCallback)(void);

@interface JCLoadMoreView : UIView

@property (nonatomic, readonly, assign) BOOL isRefreshing;

@property (nonatomic, strong) UIButton *bottomButton;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView;

- (void)setLoadMoreCallback:(LoadMoreCallback)callback;

- (void)startRefresh;
- (void)endRefresh;

@end
