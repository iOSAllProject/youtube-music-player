//
//  ViewController.m
//  YoutubePlayer
//
//  Created by Jorge Valbuena on 2014-10-24.
//  Copyright (c) 2014 com.jorgedeveloper. All rights reserved.
//

#import "MediaPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AHKActionSheet.h"
#import "AppConstant.h"
#import <VBFPopFlatButton/VBFPopFlatButton.h>
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


static NSString const *api_key =@"AIzaSyAnNzksYIn-iEWWIvy8slUZM44jH6WjtP8"; // public youtube api key

@interface MediaPlayerViewController ()
{
    UIButton *playButton;
    UIButton *nextButton;
    UIButton *prevButton;
    UIProgressView *progress;
    UILabel *elapsed;
    UILabel *duration;
    UILabel *titleLabel;
    UIView *playerContainer;
    VideoModel *currentVideo;
    UISlider *slider;
    BOOL isSeeking;
    MPMoviePlayerController *mPlayer;
    UIImageView *backgroundImage;
    UIButton *playerSpeed;
    AHKActionSheet *actionSheet;
    UIColor *textColor;
    UIColor *backgroundColor;
    XCDYouTubeVideoPlayerViewController *player;
    UIActivityIndicatorView *videoSpinner;
    UIView *playerBg;
    UIView *topView;
}
@property (nonatomic) int counter;

@end

@implementation MediaPlayerViewController

-(id) initVideoPlayer:(NSString*)videoId title:(NSString*)title {
    self = [super init];
    if (self) {
        self.videoId = videoId;
        self.title = title;

        backgroundColor = [UIColor whiteColor];
        textColor = [UIColor blackColor];
        self.view.backgroundColor = backgroundColor;//RGB(34,34,34);
        CGFloat topPaddingBar = 170.0;
        playerBg = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, topPaddingBar + 211)];
        [playerBg setBackgroundColor:[UIColor blackColor]];
        playerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, playerBg.frame.size.height/2 - 211/2, self.view.frame.size.width, 211)];
        UIView *topView = [[UIView alloc] initWithFrame:playerContainer.frame];
        // adding to subview
        [self.view addSubview:playerBg];
        [self.view addSubview:playerContainer];
        [self.view addSubview:topView];

        CGFloat h_padding = 10.0;
        CGFloat time_size = 40.0;
        CGFloat bar_size = self.view.frame.size.width;
        CGRect frame = CGRectMake((self.view.frame.size.width-bar_size)/2,playerBg.frame.origin.y + playerBg.frame.size.height-2, bar_size ,5);
        // sliderAction will respond to the updated slider value
        slider = [[UISlider alloc] initWithFrame:frame];
        //  slider.backgroundColor = [UIColor redColor];
        [slider setValue:0.00];
        [slider setTintColor: RGB(19, 143, 213)];
        [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        [slider setThumbImage:[[UIImage alloc] init] forState:UIControlStateNormal];
        [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        [slider addTarget:self action:@selector(progressBarChangeEnded:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:slider];

        elapsed = [[UILabel alloc] initWithFrame:CGRectMake(slider.frame.origin.x+10, slider.frame.origin.y+10.0, time_size, 20.0)];
        elapsed.text = @"0:00";
        elapsed.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f];
        elapsed.textAlignment = NSTextAlignmentCenter;
        elapsed.textColor = textColor;
        duration = [[UILabel alloc] initWithFrame:CGRectMake(slider.frame.size.width+slider.frame.origin.x-time_size-10, slider.frame.origin.y+10, time_size, 20.0)];
        duration.text = @"0:00";
        duration.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f];
        duration.textAlignment = NSTextAlignmentCenter;
        duration.textColor = textColor;
        [self.view addSubview:elapsed];
        [self.view addSubview:duration];

        //pass song info to video view controller


        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, slider.frame.origin.y + slider.frame.size.height + 40, self.view.frame.size.width-20, 30)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
        titleLabel.textColor = textColor;

        [self.view addSubview:titleLabel];

        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];

        UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 25.0, 25.0)];
        [dismissButton addTarget:self
                          action:@selector(done)
                forControlEvents:UIControlEventTouchUpInside];
        [dismissButton setBackgroundImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        [self.view addSubview:dismissButton];

        UIButton *queue = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-10-25, 25, 25.0, 25.0)];
        [queue setBackgroundImage:[UIImage imageNamed:@"minus"] forState:UIControlStateNormal];
        [self.view addSubview:queue];
        player = [[MediaManager sharedInstance] getVideoPlayer];
        [player presentInView:playerContainer];
        [self setupPlayerControls];
        
        // add a loading spinner
        videoSpinner = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        videoSpinner.center = CGPointMake(playerContainer.frame.size.width / 2, playerContainer.frame.size.height / 2);
        videoSpinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
        | UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleLeftMargin;
        CGAffineTransform transform = CGAffineTransformMakeScale(2.5f, 2.5f);
        videoSpinner.transform = transform;
        
        videoSpinner.color = UIColor.whiteColor;
        [playerContainer addSubview:videoSpinner];
        
    }
    return self;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];

}

- (void) setupPlayerControls {
    
    CGFloat bar_size = self.view.frame.size.width-80;
    
    CGFloat buttonSize = 20.0;
    
    CGFloat speed_button_size = 75.0;
    playerSpeed = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height-buttonSize - 10, speed_button_size, buttonSize)];
    [playerSpeed setTitle:@"Normal Speed" forState:UIControlStateNormal];
    playerSpeed.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    [playerSpeed setTitleColor:textColor forState:UIControlStateNormal];
    [playerSpeed addTarget:self
                    action:@selector(playbackSpeedChange:)
          forControlEvents:UIControlEventTouchUpInside];
    playerSpeed.titleLabel.textAlignment =NSTextAlignmentCenter;
    [self.view addSubview:playerSpeed];
    
   /* UIButton *moreOptions = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - buttonSize - 10, self.view.frame.size.height - buttonSize - 10 , buttonSize, buttonSize)];
    [playButton setTintColor:textColor];
    
    [moreOptions setBackgroundImage:[UIImage imageNamed:@"internet"] forState:UIControlStateNormal];*/
    VBFPopFlatButton *moreOptions = [[VBFPopFlatButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - buttonSize - 10, self.view.frame.size.height - buttonSize - 10 , buttonSize, buttonSize)   buttonType:buttonSquareType
                                                                buttonStyle:buttonRoundedStyle
                                                      animateToInitialState:YES];
    moreOptions.tintColor = [UIColor blackColor];
    moreOptions.lineThickness = 2;
    moreOptions.roundBackgroundColor = [UIColor whiteColor];
    [self.view addSubview:moreOptions];
    [moreOptions addTarget:self
                    action:@selector(showMore:)
          forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = CGRectMake((self.view.frame.size.width-bar_size)/2,playerSpeed.frame.origin.y - 40, bar_size ,5);
    // sliderAction will respond to the updated slider value
   /* vSlider = [[UISlider alloc] initWithFrame:frame];
    //  slider.backgroundColor = [UIColor redColor];
    [vSlider setValue:0.00];
    [vSlider setTintColor: textColor];
    [vSlider addTarget:self action:@selector(vSliderAction:) forControlEvents:UIControlEventValueChanged];
    
    [vSlider addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    */
    MPVolumeView *vSlider =
    [[MPVolumeView alloc] initWithFrame: frame];
    [vSlider setTintColor: textColor];
    vSlider.showsVolumeSlider = YES;
    [self.view addSubview:vSlider];

    
    CGFloat play_height = 30.0;
    CGFloat play_width = 33.0;
    CGFloat play_y = vSlider.frame.origin.y - play_height - 40;
    
    CGFloat side_height = 20.0;
    CGFloat side_width = 30.0;
    CGFloat side_button_y =play_y + (play_height-side_height)/2 ;
    CGFloat button_padding = 50.0;
    
    playButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-play_width/2,play_y , play_width, play_height)];
    [playButton setBackgroundImage:[UIImage imageNamed:@"play_black2"] forState:UIControlStateNormal];
    [playButton setBackgroundImage:[UIImage imageNamed:@"pause_black"] forState:UIControlStateSelected];
    [playButton setHighlighted:NO];
    [playButton addTarget:self
                   action:@selector(controlButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    playButton.tag = 1;
    [self.view addSubview:playButton];
    
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)+(play_width/2)+button_padding, side_button_y, side_width, side_height)];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"next_black2"] forState:UIControlStateNormal];
    [nextButton addTarget:self
                   action:@selector(nextSong)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    prevButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-play_width/2 - side_width - button_padding, side_button_y, side_width,side_height)];
    [prevButton setBackgroundImage:[UIImage imageNamed:@"prev_black2"] forState:UIControlStateNormal];
    [prevButton addTarget:self
                   action:@selector(prevSong)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:prevButton];
    
    UIColor *fontColor = [[UINavigationBar appearance] barTintColor];
}

- (void)updateTime:(NSTimer *)timer {
    
    NSInteger d = (NSInteger) mPlayer.duration;
    NSInteger c =(NSInteger)  mPlayer.currentPlaybackTime;
    if(d < 0 ){
        d = 0;
    }
    NSInteger seconds = d % 60;
    NSInteger minutes = (d / 60) % 60;
    NSInteger hours = (d / 3600);
    
    NSInteger e_seconds = c % 60;
    NSInteger e_minutes = (c / 60) % 60;
    NSInteger e_hours = c/ 3600;
    if(hours > 0){
        duration.text =  [NSString stringWithFormat:@"%li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
        elapsed.text =[NSString stringWithFormat:@"%li:%02li:%02li", (long)e_hours, (long)e_minutes, (long)e_seconds];
    } else {
        duration.text =  [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];
        elapsed.text =[NSString stringWithFormat:@"%02li:%02li", (long)e_minutes, (long)e_seconds];
    }

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
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [[self navigationController] setNavigationBarHidden:YES animated:NO];

    player = [[MediaManager sharedInstance] getVideoPlayer];
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];*/
   // [mPlayer setControlStyle:MPMovieControlStyleNone];
    mPlayer = player.moviePlayer;
  //  [self updatePlayerState:mPlayer.playbackState];
  //  titleLabel.text = currentVideo.title;
}
-(void) updatePlayerTrack{
    currentVideo =  [[MediaManager sharedInstance] getCurrentlyPlaying];
    titleLabel.text = currentVideo.title;
    
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    
    
    //[player.moviePlayer setControlStyle:MPMovieControlStyleNone];

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
        [playerSpeed setTitle:@"Normal Speed" forState:UIControlStateNormal];
    } else {
        [playerSpeed setTitle:[NSString stringWithFormat:@"%.02fx", speed] forState:UIControlStateNormal];
    }
     
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
    /*    [actionSheet addButtonWithTitle:NSLocalizedString(@"Remove from Library", nil)
                                  image:[UIImage imageNamed:@"icon4"]
                                   type:AHKActionSheetButtonTypeDestructive
                                handler:^(AHKActionSheet *as) {
                                    NSLog(@"Delete tapped");
                                }];*/
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

- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{

    [self updatePlayerState:mPlayer.playbackState];
    
}

-(void) nextSong {
    [[MediaManager sharedInstance] skipToNextSong];
}

-(void) prevSong {
    [[MediaManager sharedInstance] skipToPrevSong];
}

-(void) showVideoSpinner {
    [videoSpinner startAnimating];
}
-(void) hideVideoSpinner {
    [videoSpinner stopAnimating];
}
@end
