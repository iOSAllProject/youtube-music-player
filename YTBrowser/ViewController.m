//
//  ViewController.m
//  YoutubePlayer
//
//  Created by Jorge Valbuena on 2014-10-24.
//  Copyright (c) 2014 com.jorgedeveloper. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


static NSString const *api_key =@"AIzaSyAnNzksYIn-iEWWIvy8slUZM44jH6WjtP8"; // public youtube api key

@interface ViewController ()

@property (nonatomic) int counter;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL isInBackgroundMode;

@end

@implementation ViewController

-(id) initVideoPlayer:(NSString*)videoId title:(NSString*)title {
    self.videoId = videoId;
    self.title = title;
    return self;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    


    self.view.backgroundColor = [UIColor whiteColor];

    // loading a video by URL
    // [self.player loadPlayerWithVideoURL:@"https://www.youtube.com/watch?v=mIAgmyoAmmc"];
    
    // loading multiple videos from url
    [self.player loadPlayerWithVideoId:self.videoId];
     UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 220)];
    

    // loading videoId
    // [self.player loadPlayerWithVideoId:@"O8TiugM6Jg"];

    // loading playlist to video player
    // [self.player loadPlayerWithPlaylistId:@"PLEE58C6029A8A6ADE"];
    
    // loading a set of videos to the player
//    NSArray *videoList = @[@"m2d0ID-V9So", @"c7lNU4IPYlk"];
//    [self.player loadPlayerWithVideosId:videoList];
    
    // adding to subview
    [self.view addSubview:self.player];
    [self.view addSubview:topView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, self.player.frame.origin.y + self.player.frame.size.height + 10, self.view.frame.size.width, 20)];
    title.text = self.title;
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];

    [self.view addSubview:title];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    NSError *sessionError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    if (!success){
        NSLog(@"setCategory error %@", sessionError);
    }
    success = [audioSession setActive:YES error:&sessionError];
    if (!success){
        NSLog(@"setActive error %@", sessionError);
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appIsInBakcground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillBeInBakcground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Turn on remote control event delivery
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // Set itself as the first responder
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // Turn off remote control event delivery
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    // Resign as first responder
    [self resignFirstResponder];
    
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if(self.counter == 0) {
                    [self.player playVideo];
                    self.counter = 1;
                }
                else {
                    [self.player pauseVideo];
                    self.counter = 0;
                }
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self.player previousVideo];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self.player nextVideo];
                break;
                
            default:
                break;
        }
    }
}


#pragma mark -
#pragma mark Getters and Setters

-(YTPlayerView*)player
{
    if(!_player)
    {
        _player = [[YTPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 220)];
        _player.delegate = self;
        _player.autoplay = YES;
        _player.modestbranding = YES;
        _player.showinfo = YES;
        _player.controls = YES;
        _player.allowLandscapeMode = NO;
        _player.forceBackToPortraitMode = YES;
        _player.allowAutoResizingPlayerFrame = NO;
        _player.playsinline = NO;
        _player.fullscreen = NO;
        _player.playsinline = YES;
    }
    
    return _player;
}


#pragma mark -
#pragma mark Player delegates

- (void)playerView:(YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality)quality
{
    [_player setPlaybackQuality:kYTPlaybackQualityHD720];
}

//- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error
//{
//    [self.player nextVideo];
//}


#pragma mark -
#pragma mark Helper Functions

- (void)sphereDidSelected:(int)index
{
//    NSLog(@"sphere %d selected", index);
    if(index == 1) {
        if(self.counter == 0) {
            [self.player playVideo];
            self.counter = 1;
        }
        else {
            [self.player pauseVideo];
            self.counter = 0;
        }
    }
    else if(index == 0) {
        [self.player previousVideo];
    }
    else {
        [self.player nextVideo];    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    // loading a set of videos to the player after the player has finished loading
//    NSArray *videoList = @[@"m2d0ID-V9So", @"c7lNU4IPYlk"];
//    [self.player loadPlaylistByVideos:videoList index:0 startSeconds:0.0 suggestedQuality:kYTPlaybackQualityHD720];
}

#pragma mark -
#pragma mark Notifications

-(void)appIsInBakcground:(NSNotification*)notification{
    [self.player playVideo];
}

-(void)appWillBeInBakcground:(NSNotification*)notification{
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(keepPlaying) userInfo:nil repeats:YES];
//    self.isInBackgroundMode = YES;
//    [self.player playVideo];
}

-(void)keepPlaying{
    if(self.isInBackgroundMode){
        [self.player playVideo];
        self.isInBackgroundMode = NO;
    }
    else{
        [self.timer invalidate];
        self.timer = nil;
    }
}


-(void)done{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
