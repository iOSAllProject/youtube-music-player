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
{
    UIButton *playButton;
    UIButton *nextButton;
    UIButton *prevButton;
    UIProgressView *progress;
    VideoModel *currentVideo;
    UISlider *slider;
}
@property (nonatomic) int counter;

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
    self.player = [[MediaManager sharedInstance] getVideoPlayer];
    self.player.frame = CGRectMake(0, 0, self.view.bounds.size.width, 220);
     UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 220)];
    // adding to subview
    [self.view addSubview:self.player];
    [self.view addSubview:topView];
    
    //pass song info to video view controller
    currentVideo =  [[MediaManager sharedInstance] getCurrentlyPlaying];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, self.player.frame.origin.y + self.player.frame.size.height + 10, self.view.frame.size.width, 20)];
    title.text = currentVideo.title;
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];

    [self.view addSubview:title];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
    CGFloat topPadding = 60.0;
    
    playButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-11.0, self.view.frame.size.height-topPadding, 22.0, 20.0)];
    [playButton setBackgroundImage:[UIImage imageNamed:@"play_black2"] forState:UIControlStateNormal];
    [self.view addSubview:playButton];
    
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)+10 + 30.0, self.view.frame.size.height-topPadding, 30.0, 20.0)];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"next_black2"] forState:UIControlStateNormal];
    [self.view addSubview:nextButton];
    
    prevButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-10.0 - 30.0 - 30, self.view.frame.size.height-topPadding, 30.0, 20.0)];
    [prevButton setBackgroundImage:[UIImage imageNamed:@"prev_black2"] forState:UIControlStateNormal];
    [self.view addSubview:prevButton];
    

    CGRect frame = CGRectMake(40.0,self.view.frame.size.height-topPadding-50, self.view.frame.size.width-80.0 ,20);
    // sliderAction will respond to the updated slider value
    slider = [[UISlider alloc] initWithFrame:frame];
    [slider setValue:0.00];
    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];

    
    [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    [self.view addSubview:slider];
    
    
    
}
- (void)updateTime:(NSTimer *)timer {
    CGFloat d = self.player.duration;
    CGFloat c = self.player.currentTime;
    [slider setValue:(self.player.currentTime/self.player.duration)];
}


- (UIImage *)blurredImageWithImage:(UIImage *)sourceImage{
    
    //  Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:50.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    /*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
     *  up exactly to the bounds of our original image */
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *retVal = [UIImage imageWithCGImage:cgImage];
    return retVal;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    

    
    // Resign as first responder
    [self resignFirstResponder];
    
    [super viewWillDisappear:animated];
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


-(void)done{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
