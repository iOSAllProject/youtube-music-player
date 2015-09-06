//
//  AppDelegate.h
//  YTBrowser
//
//  Created by Marin Todorov on 03/01/2013.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <RESideMenu/RESideMenu.h>
#import "LeftMenuViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL videoIsInFullscreen;
@property (nonatomic, strong) UIView *playerBar;
@property (nonatomic, strong) RESideMenu *sideMenuViewController;
@property (nonatomic, strong) LeftMenuViewController *leftMenuViewController;
@end
