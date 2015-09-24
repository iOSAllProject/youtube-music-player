#import "MediaManager.h"
#import "MPMoviePlayerController+BackgroundPlayback.h"
#import "AppConstant.h"
#import "UIImage+ImageEffects.h"
#import "UIView+GradientMask.h"
#import <AutoScrollLabel/CBAutoScrollLabel.h>
static MediaManager *sharedInstance = nil;

@interface MediaManager (){
    //YTPlayerView *videoPlayer;
    BOOL isInBackgroundMode;
    NSTimer *timer;
    BOOL isPlaying;
    VideoModel *currentlyPlaying;
    /*
     Mini player components
     */
    BOOL isInitialized;
    UIView *miniPlayer;
    //UIImageView *pImage;
    CBAutoScrollLabel *pLabel;
    UIImageView *pAction;
    UIActivityIndicatorView *statusSpinner;

    MediaPlayerViewController *videoPlayer;
    NSArray *currentPlaylist;
    NSMutableSet *songsInLibrary;
    NSInteger  currentSongIndex;
    UISlider *slider;
    AVQueuePlayer *audioStremarPlayer;
    
    BOOL AUDIO_ENABLED;
    
}
@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;
@end
@implementation MediaManager
static void *MoviePlayerContentURLContext = &MoviePlayerContentURLContext;
-(id)init{
    if(self = [super init]){
        
    }
    return self;
}

+(MediaManager *)sharedInstance{
    //create an instance if not already else return
    if(!sharedInstance){
        sharedInstance = [[[self class] alloc] init];
        
    }
    return sharedInstance;
}
-(void)initializeVideoPlayer:(UIView *) playerView{
   // [self player];
    miniPlayer = playerView;
    self.userPaused = NO;
    AUDIO_ENABLED = NO;
    miniPlayer.backgroundColor = [UIColor blackColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"player_bar"]];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = miniPlayer.frame;
    [miniPlayer addSubview:visualEffectView];

    UITapGestureRecognizer *playerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayDetailedPlayer)];
    [miniPlayer addGestureRecognizer:playerTap];

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:miniPlayer.bounds];
    miniPlayer.layer.masksToBounds = NO;
    miniPlayer.layer.shadowColor = [UIColor blackColor].CGColor;
    miniPlayer.layer.shadowOffset = CGSizeMake(3, -1);
    miniPlayer.layer.shadowOpacity = 0.5f;
    miniPlayer.layer.shadowPath = shadowPath.CGPath;
    UIView *playerBlackFilter = [[UIView alloc] initWithFrame: CGRectMake(0, 0, miniPlayer.frame.size.width, miniPlayer.frame.size.height)];
    playerBlackFilter.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [miniPlayer addSubview:playerBlackFilter];
    
    
    
    CGFloat ACTION_LENGTH = 26.0;
    CGFloat ACTION_PADDING = miniPlayer.frame.size.height/2 - ACTION_LENGTH/2;
    CGFloat TITLE_HEIGHT = 30.0;
    CGFloat TITLE_WIDTH =  miniPlayer.frame.size.width-120;
    CGFloat TITLE_SPACE = (miniPlayer.frame.size.height - TITLE_HEIGHT )/2;
    

    pLabel = [[CBAutoScrollLabel alloc] initWithFrame:CGRectMake(miniPlayer.frame.size.width/2 - TITLE_WIDTH/2, TITLE_SPACE, TITLE_WIDTH, TITLE_HEIGHT)];
    pLabel.textColor = [UIColor whiteColor];
    pLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    pLabel.textAlignment = NSTextAlignmentCenter;
    pLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    pLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    pLabel.layer.shadowRadius = 3.0;
    pLabel.layer.shadowOpacity = 0.5;
    pLabel.textAlignment = NSTextAlignmentCenter;
    pLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    pLabel.labelSpacing = 30; // distance between start and end labels
    pLabel.pauseInterval = 1.7; // seconds of pause before scrolling starts again
    pLabel.scrollSpeed = 30; // pixels per second
    pLabel.fadeLength = 12.f; // length of the left and right edge fade, 0 to disable
    pLabel.scrollDirection = CBAutoScrollDirectionLeft;
    [pLabel observeApplicationNotifications];
    
    
    
    [miniPlayer addSubview:pLabel];
    

    
    pAction = [[UIImageView alloc] init];
    pAction.frame = CGRectMake(ACTION_PADDING, ACTION_PADDING, ACTION_LENGTH, ACTION_LENGTH);
    UITapGestureRecognizer *buttonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(miniPlayerActionListener)];
    [pAction setUserInteractionEnabled:YES];
    [pAction addGestureRecognizer:buttonTap];
    [miniPlayer addSubview:pAction];
    /*
    CGFloat buttonSize = 18.0;
    CGFloat buttonPadding = (miniPlayer.frame.size.height - buttonSize)/2;
    UIButton *moreOptions = [[UIButton alloc] initWithFrame:CGRectMake(miniPlayer.frame.size.width-buttonSize-10, buttonPadding, buttonSize, buttonSize)];
    
    [moreOptions setBackgroundImage:[UIImage imageNamed:@"internet_white"] forState:UIControlSta©teNormal];
    [miniPlayer addSubview:moreOptions];
    [moreOptions addTarget:self
                    action:nil
          forControlEvents:UIControlEventTouchUpInside];

    */
    statusSpinner = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    statusSpinner.center = CGPointMake(pAction.frame.size.width / 2, pAction.frame.size.height / 2);
    statusSpinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    statusSpinner.color = UIColor.lightGrayColor;
    [pAction addSubview:statusSpinner];
    
    CGRect frame = CGRectMake(-2,-2, miniPlayer.frame.size.width+10 ,5);
    // sliderAction will respond to the updated slider value
    slider = [[UISlider alloc] initWithFrame:frame];
    [slider setValue:0.00];
    [slider setMaximumTrackTintColor:[UIColor clearColor]];
    [slider setTintColor: [UIColor whiteColor]];
    [slider setThumbImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    [miniPlayer addSubview:slider];
    isInitialized = YES;
    miniPlayer.hidden = YES;

    
    
    
    if(AUDIO_ENABLED){
        
        audioStremarPlayer= [[AVQueuePlayer alloc] init];
        [audioStremarPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];

    } else {
        self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] init];
        videoPlayer = [[MediaPlayerViewController alloc] initVideoPlayer:nil title:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(MPMoviePlayerLoadStateDidChange:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self.videoPlayerViewController name:MPMoviePlayerPlaybackDidFinishNotification object:self.videoPlayerViewController.moviePlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.videoPlayerViewController.moviePlayer];
        [self.videoPlayerViewController addObserver:self forKeyPath:@"moviePlayer.contentURL" options:(NSKeyValueObservingOptions)0 context:MoviePlayerContentURLContext];
        
        
        [self.mPlayer setControlStyle:MPMovieControlStyleNone];
        
        self.mPlayer.view.hidden = YES;
        self.mPlayer = self.videoPlayerViewController.moviePlayer;
        self.videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = YES;
        [self.videoPlayerViewController.moviePlayer setShouldAutoplay:YES];
        [self.videoPlayerViewController.moviePlayer prepareToPlay];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        NSError *setCategoryError = nil;
        BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
        if (!success) { /* handle the error condition */ }
        
        NSError *activationError = nil;
        success = [audioSession setActive:YES error:&activationError];
        if (!success) { /* handle the error condition */ }
    
    }


}

-(void)playWithVideo:(VideoModel *)video{
    [self updateMiniPlayer: video];
    [videoPlayer updatePlayerTrack];
    miniPlayer.hidden = NO;
    currentlyPlaying = video;
    if(!AUDIO_ENABLED){
        
        self.videoPlayerViewController.videoIdentifier = video.videoId;
    }
    else{
        [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:video.videoId completionHandler:^(XCDYouTubeVideo *video, NSError *error) {
            if (video)
            {
                // Do something with the `video` object, in this case the audio url
                
                NSString *XCDYouTubeVideoQualityAudioString = [NSString    stringWithFormat:@"%@",video.streamURLs[@(XCDYouTubeVideoQualityHD720)]];
                 NSURL *url = [[NSURL alloc] initWithString:XCDYouTubeVideoQualityAudioString];
                AVPlayerItem *thePlayerItem = [AVPlayerItem playerItemWithURL:url];

                // stremar player
                [audioStremarPlayer removeAllItems];
                [audioStremarPlayer insertItem:thePlayerItem afterItem:nil];

                [audioStremarPlayer play];
                NSString * const kStatusKey         = @"status";
                [thePlayerItem addObserver:self
                               forKeyPath:kStatusKey
                                  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                  context:@"AVPlayerStatus"];
            }
            else
            {
                // Handle error
            }
        }];
    }

}


-(void)playerItemDidReachEnd:(NSNotification *)notification
{
    
    currentSongIndex = (currentSongIndex+1) % [currentPlaylist count];
    VideoModel *nextSong = [currentPlaylist objectAtIndex:currentSongIndex];
    [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:nextSong.videoId completionHandler:^(XCDYouTubeVideo *video, NSError *error) {
        if (video)
        {
            // Do something with the `video` object, in this case the audio url
            
            NSString *XCDYouTubeVideoQualityAudioString = [NSString    stringWithFormat:@"%@",video.streamURLs[@(XCDYouTubeVideoQualityHD720)]];
            NSURL *url = [[NSURL alloc] initWithString:XCDYouTubeVideoQualityAudioString];
            AVPlayerItem *thePlayerItem = [AVPlayerItem playerItemWithURL:url];
            
            // stremar player
            [audioStremarPlayer insertItem:thePlayerItem afterItem:nil];
            
            
            
        }
        else
        {
            // Handle error
        }
    }];
}


-(void) updateMiniPlayer: (VideoModel *) video {
    pLabel.text = video.title;
    NSURL *url = [NSURL URLWithString:video.largeImg];
    if(!url)
        url = [NSURL URLWithString:video.thumbnail];
    [self loadThumbnailImage:url];
    pAction.image = nil;
    [statusSpinner startAnimating];
    
}

-(void) loadThumbnailImage:(NSURL *)url {
    
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(q, ^{
 
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *imgBlur = [self croppIngimageByImageName:img toRect:CGRectMake(0,180,miniPlayer.frame.size.width, miniPlayer.frame.size.height)];
            UIImage *blurredImg = [imgBlur applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:0.0 alpha:0.0] saturationDeltaFactor:1.8 maskImage:nil];
            miniPlayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            miniPlayer.backgroundColor = [UIColor colorWithPatternImage:blurredImg];
            
            videoPlayer.bgImg = img;
            
            
        });
    });
}
- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    //CGRect CropRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height+15);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

-(void)miniPlayerActionListener{
    
    if(isPlaying){
        self.currentJukebox.isPlaying = NO;
        self.userPaused = YES;
        [self.mPlayer pause];
    } else {
        self.currentJukebox.isPlaying = YES;
        self.userPaused = NO;
        [self.mPlayer play];
    }
    if(self.currentJukebox){
        
        NSString *currentUser =[[PFUser currentUser] objectId];
        if([currentUser isEqualToString:self.currentJukebox.authorId])
            [self updateJukeboxPlayState];
    }
    
}

- (void)updatePlayerState:(NSString *) state {
    if([state isEqualToString:PLAY]){
        [self.mPlayer play];
    } else if([state isEqualToString:PAUSE]){
        [self.mPlayer pause];
    }
}

-(void) updateMiniPlayerState:(MPMoviePlaybackState)state {
    [statusSpinner stopAnimating];
    if (state == MPMoviePlaybackStatePlaying) { //playing
        isPlaying = TRUE;
        pAction.image = [UIImage imageNamed:@"pause_white_128"];
    } if (state== MPMoviePlaybackStateStopped) { //stopped
    } if (state == MPMoviePlaybackStatePaused) { //paused
        isPlaying = FALSE;
        pAction.image = [UIImage imageNamed:@"play_white_128"];
        
    }if (state == MPMoviePlaybackStateInterrupted)
    { //interrupted
    }if (state == MPMoviePlaybackStateSeekingForward)
    { //seeking forward
    }if (state == MPMoviePlaybackStateSeekingBackward)
    { //seeking backward
    }

}

- (void) moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    if (finishReason == MPMovieFinishReasonPlaybackEnded) {
        currentSongIndex = (currentSongIndex+1) % [currentPlaylist count];
        VideoModel *nextSong = [currentPlaylist objectAtIndex:currentSongIndex];
        self.videoPlayerViewController.videoIdentifier = nextSong.videoId;
        [videoPlayer updatePlayerTrack];
        [self updateMiniPlayer:nextSong];
        NSString *currentUser = [[PFUser currentUser] objectId];
        if([self.currentJukebox.authorId isEqualToString:currentUser])
            [self updateJukeboxSong];
        NSLog(@"%@", nextSong.title);
    }
}


-(void) updateJukeboxSong {
    [self updateJukeboxForSong: YES andState:NO];
    
}
-(void) updateJukeboxPlayState {
    [self updateJukeboxForSong: NO andState:YES];
}

-(void) updateJukeboxForSong:(BOOL) song andState:(BOOL) state{
    PFQuery *query = [PFQuery queryWithClassName:@"Jukeboxes"];
    [query getObjectInBackgroundWithId:self.currentJukebox.objectId block:^(PFObject *jukebox, NSError *error) {
       // NSLog(@"%@", jukebox);
        if(state){
            
            [jukebox setValue:[NSNumber numberWithBool:self.currentJukebox.isPlaying]  forKey:@"isPlaying" ];
            NSInteger elapsed = (NSInteger)self.mPlayer.currentPlaybackTime;
            [jukebox setValue:@(elapsed) forKey:@"time"];
            
        } else if(song){
            PFObject *lastPlayed = jukebox[@"playQueue"][0];
            if(lastPlayed != nil){
                [jukebox addObject:lastPlayed forKey:@"playedSongs"];
                [jukebox removeObject:lastPlayed forKey:@"playQueue"];
            }
            [jukebox setValue:@0 forKey:@"time"];
        }
        [jukebox saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

            if(succeeded){
                
            }
            else{
                
            }
            
        }];
        
    }];

}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if(AUDIO_ENABLED){
        if (object == audioStremarPlayer && [keyPath isEqualToString:@"status"]) {
            if (audioStremarPlayer.status == AVPlayerStatusFailed)
            {
                //  //NSLog(@"AVPlayer Failed");
            }
            else if (audioStremarPlayer.status == AVPlayerStatusReadyToPlay)
            {
                [audioStremarPlayer play];
            }
            else if (audioStremarPlayer.status == AVPlayerItemStatusUnknown)
            {
                //  //NSLog(@"AVPlayer Unknown");
                
            }
        }
        
        if (context == @"AVPlayerStatus") {
            
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status) {
                case AVPlayerStatusUnknown: {
                    
                }
                    break;
                    
                case AVPlayerStatusReadyToPlay: {
                    
                    [statusSpinner stopAnimating];
                    
                    
                }
                    break;
            }
        }
        
    }
    else{
    if (context == MoviePlayerContentURLContext) {
        [videoPlayer showVideoSpinner];
        [self.videoPlayerViewController.moviePlayer play];
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (XCDYouTubeVideoPlayerViewController *) getVideoPlayer {
    return self.videoPlayerViewController;
}


-(VideoModel *) getCurrentlyPlaying {
    return [currentPlaylist objectAtIndex:currentSongIndex];
}

-(void) runInBackground {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];

    [self updateMiniPlayerState:self.mPlayer.playbackState];
    
}

- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    if([self.mPlayer.view isHidden])
       [self.mPlayer.view setHidden:NO];
    [self updateMiniPlayerState:self.mPlayer.playbackState];
    [videoPlayer updatePlayerState:self.mPlayer.playbackState];
    NSString *currentUser =[[PFUser currentUser] objectId];
    if(self.currentJukebox && ![currentUser isEqualToString:self.currentJukebox.authorId] ){
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        NSInteger diff = currentTime - self.currentJukebox.updatedAt;
        if(diff < 20)
            diff = 0;
        [self.mPlayer setCurrentPlaybackTime:self.currentJukebox.elapsedTime +diff];
    }
    
}

- (void)MPMoviePlayerLoadStateDidChange:(NSNotification *)notification
{
    if((self.mPlayer.loadState & MPMovieLoadStatePlayable) == MPMovieLoadStatePlayable)
    {
        [videoPlayer hideVideoSpinner];

        [statusSpinner stopAnimating];
        
        
    } else {
        
        [videoPlayer showVideoSpinner];
        [statusSpinner startAnimating];
        
    }
    
}

-(UIView *) getMiniPlayer {
    return miniPlayer;
}

-(void) setPlaylist:(NSArray *) songs andSongIndex:(NSInteger) index {
    currentPlaylist = songs;
    currentSongIndex = index;
}

-(void) setCurrentLibrary:(NSArray *)songs {
    songsInLibrary = [[NSMutableSet alloc] initWithArray:songs];
    currentPlaylist = songs;

}
-(BOOL) isInLibrary:(VideoModel *)song {
    if([songsInLibrary containsObject:song])
        return YES;
    return NO;
}

-(UIViewController *) getVideoPlayerViewController{
    return videoPlayer;

}

-(void) skipToNextSong {
    currentSongIndex = (currentSongIndex +1)% [currentPlaylist count];
    [self playWithVideo:[currentPlaylist objectAtIndex:currentSongIndex]];
}
-(void) skipToPrevSong {
    currentSongIndex = (currentSongIndex -1)% [currentPlaylist count];
    [self playWithVideo:[currentPlaylist objectAtIndex:currentSongIndex]];
}

- (void)updateTime:(NSTimer *)timer {
    NSInteger d;
    NSInteger c;
    if(AUDIO_ENABLED){
        d = (NSInteger) CMTimeGetSeconds(audioStremarPlayer.currentItem.duration);
        c = (NSInteger) CMTimeGetSeconds(audioStremarPlayer.currentItem.currentTime);
    } else {
        d = (NSInteger) self.mPlayer.duration;
        c =(NSInteger)  self.mPlayer.currentPlaybackTime;
    }

    if(d < 0 ){
        d = 0;
    }
    
    [slider setValue:(CGFloat) c/ d];
    
}

@end