//
//  ViewController.m
//  YoutubePlayer
//
//  Created by Jorge Valbuena on 2014-10-24.
//  Copyright (c) 2014 com.jorgedeveloper. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AHKActionSheet.h"
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
    UILabel *elapsed;
    UILabel *duration;
    UILabel *title;
    UIView *playerContainer;
    VideoModel *currentVideo;
    UISlider *slider;
    BOOL isSeeking;
    MPMoviePlayerController *mPlayer;
    UIImageView *backgroundImage;
    UIButton *playerSpeed;
    AHKActionSheet *actionSheet;
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

    //BACKGROUND IMAGE
/*    backgroundImage = [[UIImageView alloc] init];
    backgroundImage.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:backgroundImage];
    UIView *filter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    filter.backgroundColor = [UIColor blackColor];
    filter.alpha = .9;
    [self.view addSubview:filter];*/
    
    // loading a video by URL
    // [self.player loadPlayerWithVideoURL:@"https://www.youtube.com/watch?v=mIAgmyoAmmc"];
    
    // loading multiple videos from url

    CGFloat topPaddingBar = 64.0;
    playerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, topPaddingBar, self.view.bounds.size.width, 180)];
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, topPaddingBar, self.view.bounds.size.width, 180)];
    // adding to subview
    [self.view addSubview:playerContainer];
    [self.view addSubview:topView];
    
    //pass song info to video view controller

    
    title = [[UILabel alloc] initWithFrame:CGRectMake(10, playerContainer.frame.origin.y + playerContainer.frame.size.height + 10, self.view.frame.size.width-20, 20)];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];

    [self.view addSubview:title];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"play_queue" ] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    CGFloat topPadding = 100.0;
    CGFloat play_height = 40.0;
    CGFloat play_width = 44.0;
    
    CGFloat side_height = 20.0;
    CGFloat side_width = 30.0;
    CGFloat button_padding = 50.0;
    
    playButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-play_width/2, self.view.frame.size.height-topPadding, play_width, play_height)];
    [playButton setBackgroundImage:[UIImage imageNamed:@"play_black2"] forState:UIControlStateNormal];
    [playButton setBackgroundImage:[UIImage imageNamed:@"pause_black"] forState:UIControlStateSelected];
    [playButton setHighlighted:NO];
    [playButton addTarget:self
               action:@selector(controlButtonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    playButton.tag = 1;
    [self.view addSubview:playButton];
    
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)+(play_width/2)+button_padding, self.view.frame.size.height-topPadding+play_height/4, side_width, side_height)];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"next_black2"] forState:UIControlStateNormal];
    [self.view addSubview:nextButton];
    
    prevButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-play_width/2 - side_width - button_padding, self.view.frame.size.height-topPadding+play_height/4, side_width,side_height)];
    [prevButton setBackgroundImage:[UIImage imageNamed:@"prev_black2"] forState:UIControlStateNormal];
    [self.view addSubview:prevButton];
    
    CGFloat h_padding = 10.0;
    CGFloat time_size = 40.0;
    CGFloat bar_size = self.view.frame.size.width-2*h_padding;
    CGRect frame = CGRectMake((self.view.frame.size.width-bar_size)/2,self.view.frame.size.height-topPadding-70, bar_size ,20);
    // sliderAction will respond to the updated slider value
    slider = [[UISlider alloc] initWithFrame:frame];
    [slider setValue:0.00];
    [slider setTintColor:[[UINavigationBar appearance] barTintColor]];
    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [slider setThumbImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    [slider addTarget:self action:@selector(progressBarChangeEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:slider];
    
    elapsed = [[UILabel alloc] initWithFrame:CGRectMake(slider.frame.origin.x, slider.frame.origin.y-10.0, time_size, 20.0)];
    elapsed.text = @"0:00";
    elapsed.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f];
    elapsed.textAlignment = NSTextAlignmentCenter;
    duration = [[UILabel alloc] initWithFrame:CGRectMake(slider.frame.size.width+slider.frame.origin.x-time_size, slider.frame.origin.y-10, time_size, 20.0)];
    duration.text = @"0:00";
    duration.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f];
    duration.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:elapsed];
    [self.view addSubview:duration];
    
    UIColor *fontColor = [[UINavigationBar appearance] barTintColor];
    
    CGFloat speed_button_size = 70.0;
    playerSpeed = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-speed_button_size/2, self.view.frame.size.height-30.0, speed_button_size, 20.0)];
    [playerSpeed setTitle:@"Normal Speed" forState:UIControlStateNormal ];
    playerSpeed.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0f];
    [playerSpeed setTitleColor:fontColor forState:UIControlStateNormal];
    [playerSpeed addTarget:self
                   action:@selector(playbackSpeedChange:)
         forControlEvents:UIControlEventTouchUpInside];
    playerSpeed.titleLabel.textAlignment =NSTextAlignmentCenter;
    [self.view addSubview:playerSpeed];
    
    UIButton *shuffle = [[UIButton alloc] initWithFrame:CGRectMake(10.0, self.view.frame.size.height-30.0, speed_button_size, 20.0)];
    [shuffle setTitle:@"Shuffle" forState:UIControlStateNormal];
    shuffle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0f];
    [shuffle setTitleColor:fontColor forState:UIControlStateNormal];
    [self.view addSubview:shuffle];
    
    UIButton *loop = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-speed_button_size, self.view.frame.size.height-30.0, speed_button_size, 20.0)];
    [loop setTitle:@"Loop" forState:UIControlStateNormal];
    loop.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0f];
    [loop setTitleColor:fontColor forState:UIControlStateNormal];
    [self.view addSubview:loop];
    
    
    CGFloat buttonSize = 40.0;
    UIButton *moreOptions = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - buttonSize/2, title.frame.origin.y +  ((slider.frame.origin.y/2) - title.frame.origin.y/2), buttonSize, buttonSize)];

    
    [moreOptions setBackgroundImage:[UIImage imageNamed:@"internet"] forState:UIControlStateNormal];
    [self.view addSubview:moreOptions];
    [moreOptions addTarget:self
                    action:@selector(showMore:)
          forControlEvents:UIControlEventTouchUpInside];
    
    

}
- (void)updateTime:(NSTimer *)timer {
    NSInteger d = (NSInteger) mPlayer.duration;
    NSInteger c =(NSInteger)  mPlayer.currentPlaybackTime;
    NSInteger seconds = d % 60;
    NSInteger minutes = (d / 60) % 60;
    NSInteger hours = (d / 3600);
    
    NSInteger e_seconds = c % 60;
    NSInteger e_minutes = (c / 60) % 60;
    NSInteger e_hours = c/ 3600;
    

    duration.text =  [NSString stringWithFormat:@"%i:%02i:%02i", hours, minutes, seconds];
    elapsed.text =[NSString stringWithFormat:@"%i:%02i:%02i", e_hours, e_minutes, e_seconds];

    [slider setValue:(CGFloat) c/ d];
    
}
- (IBAction)sliderAction:(UISlider *)sender {
    CGFloat seekTime = (sender.value) * mPlayer.duration;
    isSeeking = YES;
    [mPlayer pause];
    [mPlayer setCurrentPlaybackTime:seekTime];
}
-(IBAction)progressBarChangeEnded:(id)sender{
    if(self.counter == 1)
        [mPlayer play];
    isSeeking = NO;
}



- (UIImage *)blurredImageWithImage:(UIImage *)sourceImage{
    
    //  Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:80.0f] forKey:@"inputRadius"];
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
    currentVideo =  [[MediaManager sharedInstance] getCurrentlyPlaying];
    self.player = [[MediaManager sharedInstance] getVideoPlayer];
    mPlayer = self.player.moviePlayer;
    [self.player presentInView:playerContainer];
    [self updatePlayerState:mPlayer.playbackState];
    title.text = currentVideo.title;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    //backgroundImage.image = [self blurredImageWithImage:[UIImage imageNamed:@"Stars"]];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    

    
    // Resign as first responder
    [self resignFirstResponder];
    
    [super viewWillDisappear:animated];
}



-(void) controlButtonPressed:(UIButton *)button{
    switch(button.tag) {
        case 1:
            if(self.counter == 0) {
                [mPlayer play];
            }
            else {
                [mPlayer pause];
            }
            break;
            
    }
}

-(void)done{
    [[MediaManager sharedInstance] runInBackground];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void) playbackSpeedChange:(id)sender{
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:nil];
    actionSheet.blurTintColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    actionSheet.blurRadius = 8.0f;
    actionSheet.buttonHeight = 50.0f;
    actionSheet.cancelButtonHeight = 50.0f;
    actionSheet.animationDuration = 0.5f;
    actionSheet.cancelButtonShadowColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
    actionSheet.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
    actionSheet.selectedBackgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    UIFont *defaultFont = [UIFont fontWithName:@"Avenir" size:17.0f];
    actionSheet.buttonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                          NSForegroundColorAttributeName : [UIColor whiteColor] };
    actionSheet.disabledButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                                  NSForegroundColorAttributeName : [UIColor grayColor] };
    actionSheet.destructiveButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                                     NSForegroundColorAttributeName : [UIColor redColor] };
    actionSheet.cancelButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                                NSForegroundColorAttributeName : [UIColor whiteColor] };
    CGFloat playBackspeed = 1.0;
    [actionSheet addButtonWithTitle:NSLocalizedString(@".5x", nil)
                              image:nil
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *as) {
                                [self updatePlayBackSpeed:0.5];
                            }];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@".75x", nil)
                              image:nil
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *as) {
                                [self updatePlayBackSpeed:0.75];
                            }];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Normal Speed", nil)
                              image:nil
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *as) {
                              [self updatePlayBackSpeed:1];
                            }];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"1.25x", nil)
                              image:nil
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *as) {
                                [self updatePlayBackSpeed:1.25];
                            }];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"1.50x", nil)
                              image:nil
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *as) {
                                [self updatePlayBackSpeed:1.5];
                            }];
    
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"1.75x", nil)
                              image:nil
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *as) {
                               [self updatePlayBackSpeed:1.75];
                            }];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"2.00x", nil)
                              image:nil
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *as) {
                                [self updatePlayBackSpeed:2.0];
                            }];
    
                                
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    // do UI stuff back in UI land

    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 200, 20)];
    label1.text = @"Playback Speed";
    label1.textColor = [UIColor whiteColor];
    label1.font = [UIFont fontWithName:@"Avenir" size:17.0f];
    label1.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label1];
    actionSheet.headerView = headerView;
    
    [actionSheet show];
}
-(void) updatePlayBackSpeed:(CGFloat)speed {
    [mPlayer setCurrentPlaybackRate:speed];
    if(speed == 1.0f){
        playerSpeed.titleLabel.text = @"Normal Speed";
    } else {
        playerSpeed.titleLabel.text = [NSString stringWithFormat:@"%.02fx", speed];
    }
     
}


- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    [self updatePlayerState: mPlayer.playbackState];
}

- (void) updatePlayerState:(MPMoviePlaybackState) playerState {
    if (playerState == MPMoviePlaybackStatePlaying) { //playing
        playButton.selected = YES;
        if(!isSeeking)
            self.counter = 1;
    } if (playerState== MPMoviePlaybackStateStopped) { //stopped
        playButton.selected = NO;
        if(!isSeeking)
            self.counter = 0;
    } if (playerState == MPMoviePlaybackStatePaused) { //paused
        playButton.selected = NO;
        if(!isSeeking)
            self.counter = 0;

        
    }if (playerState == MPMoviePlaybackStateInterrupted)
    { //interrupted
    }if (playerState == MPMoviePlaybackStateSeekingForward)
    { //seeking forward
    }if (playerState == MPMoviePlaybackStateSeekingBackward)
    { //seeking backward
    }
    
}
-(void) showMore:(id) sender{
    currentVideo =  [[MediaManager sharedInstance] getCurrentlyPlaying];
    BOOL isInLibrary = [[MediaManager sharedInstance] isInLibrary:currentVideo];
    actionSheet = [[AHKActionSheet alloc] initWithTitle:nil];
    
    actionSheet.blurTintColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    actionSheet.blurRadius = 8.0f;
    actionSheet.buttonHeight = 50.0f;
    actionSheet.cancelButtonHeight = 50.0f;
    actionSheet.animationDuration = 0.5f;
    actionSheet.cancelButtonShadowColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
    actionSheet.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
    actionSheet.selectedBackgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    UIFont *defaultFont = [UIFont fontWithName:@"Avenir" size:17.0f];
    actionSheet.buttonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                          NSForegroundColorAttributeName : [UIColor whiteColor] };
    actionSheet.disabledButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                                  NSForegroundColorAttributeName : [UIColor grayColor] };
    actionSheet.destructiveButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                                     NSForegroundColorAttributeName : [UIColor redColor] };
    actionSheet.cancelButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                                NSForegroundColorAttributeName : [UIColor whiteColor] };
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    // do UI stuff back in UI land
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(10, 10, 71, 40);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL URLWithString:currentVideo.thumbnail];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (!data) {
            //self.alpha = 0.3;
            // got the photo, so lets show it
            UIImage *image = [UIImage imageNamed:@"album-art-missing"];
            UIImageView *imageViewDefault = [[UIImageView alloc] initWithImage:image];
            
            imageViewDefault.frame = CGRectMake(71/4+10,10,41, 41);
            UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 71, 40)];
            emptyView.backgroundColor = [UIColor blackColor];
            [headerView addSubview:emptyView];
            [headerView addSubview:imageViewDefault];
            return;
        }
        
        UIImage *image = [UIImage imageWithData:data];
        imageView.image = image;
        [headerView addSubview:imageView];
    });
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(91, 20, 200, 20)];
    label1.text = currentVideo.title;
    label1.textColor = [UIColor whiteColor];
    label1.font = [UIFont fontWithName:@"Avenir" size:17.0f];
    label1.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label1];
    actionSheet.headerView = headerView;
    
    if(!isInLibrary){
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Add to Favorites", nil)
                              image:[UIImage imageNamed:@"Icon2"]
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *as) {
                                [self insertSongToLibrary:currentVideo];
                            }];
    } else {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Remove from Library", nil)
                                  image:[UIImage imageNamed:@"icon4"]
                                   type:AHKActionSheetButtonTypeDestructive
                                handler:^(AHKActionSheet *as) {
                                    NSLog(@"Delete tapped");
                                }];
    }
    
    [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Share with Jukebox"]
                              image:[UIImage imageNamed:@"Icon3"]
                               type:AHKActionSheetButtonTypeDefault
                            handler:nil];
    
    [actionSheet show];
    
}

-(void) insertSongToLibrary:(VideoModel*)video {
    JBCoreDataStack *coreDataStack = [JBCoreDataStack defaultStack];
    Song *song = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:coreDataStack.managedObjectContext];
    song.videoId = video.videoId;
    song.title = video.title;
    song.url = video.thumbnail;
    NSLog(@"Saved %@ %@ %@", song.videoId, song.title, song.url);
    [coreDataStack saveContext];
    
}

@end
