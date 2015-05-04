//
//  ViewController.h
//  YoutubePlayer
//
//  Created by Jorge Valbuena on 2014-10-24.
//  Copyright (c) 2014 com.jorgedeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MediaManager.h"
@interface ViewController : UIViewController <YTPlayerViewDelegate>
- (id)initWithImages:(NSArray *)images andContentView:(UIView*)contentView;
-(id) initVideoPlayer:(NSString*)videoId title:(NSString*)title ;
@property (nonatomic, strong) YTPlayerView *player;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *videoId;


@end

