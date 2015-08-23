//
//  JukeboxListViewController.h
//  YTBrowser
//
//  Created by Matan Vardi on 7/19/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGScrollView.h"
#import "MGBox.h"
#import "JukeBoxCell.h"
#import "MediaManager.h"
#import "MediaPlayerViewController.h"
#import "JukeboxPostViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
@interface JukeboxListViewController : UIViewController
@property (nonatomic,strong) MediaPlayerViewController *videoPlayer;
@end
