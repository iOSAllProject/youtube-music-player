//
//  ViewController.h
//  YTBrowser
//
//  Created by Marin Todorov on 03/01/2013.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
@interface SearchViewController : UIViewController
@property (nonatomic,strong) ViewController *videoPlayer;
@property (nonatomic, strong) UIView *playerBar;
@property (nonatomic,strong) UIImageView *pThumb;
@property (nonatomic, strong) UILabel *pTitle;
@end
