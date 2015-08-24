#import "MediaManager.h"
#import "MPMoviePlayerController+BackgroundPlayback.h"
#import "AppConstant.h"


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
    UILabel *pLabel;
    UIImageView *pAction;
    UIActivityIndicatorView *statusSpinner;
    MPMoviePlayerController *mPlayer;
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

    AUDIO_ENABLED = NO;
    miniPlayer.backgroundColor = [UIColor blackColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"player_bar"]];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
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
    
    CGFloat TITLE_HEIGHT = 30.0;
    CGFloat TITLE_WIDTH =  miniPlayer.frame.size.width-120;
    CGFloat TITLE_SPACE = (miniPlayer.frame.size.height - TITLE_HEIGHT )/2;
    

    pLabel = [[UILabel alloc] initWithFrame:CGRectMake(miniPlayer.frame.size.width/2 - TITLE_WIDTH/2, TITLE_SPACE, TITLE_WIDTH, TITLE_HEIGHT)];
    pLabel.textColor = [UIColor whiteColor];
    pLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    pLabel.numberOfLines = 0;
    pLabel.textAlignment = NSTextAlignmentCenter;
    pLabel.layer.shadowColor = [pLabel.textColor CGColor];
    pLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    pLabel.layer.shadowRadius = 3.0;
    pLabel.layer.shadowOpacity = 0.5;
    [miniPlayer addSubview:pLabel];


    CGFloat ACTION_LENGTH = 26.0;
    CGFloat ACTION_PADDING = miniPlayer.frame.size.height/2 - ACTION_LENGTH/2;

    
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
    
    [moreOptions setBackgroundImage:[UIImage imageNamed:@"internet_white"] forState:UIControlStateNormal];
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
   // miniPlayer.hidden = YES;

    
    
     videoPlayer = [[MediaPlayerViewController alloc] initVideoPlayer:nil title:nil];
    if(AUDIO_ENABLED){
        
        audioStremarPlayer= [[AVQueuePlayer alloc] init];
        [audioStremarPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];

    } else {
        self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] init];
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
        
        
        [mPlayer setControlStyle:MPMovieControlStyleNone];
        
        mPlayer.view.hidden = YES;
        mPlayer = self.videoPlayerViewController.moviePlayer;
        self.videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = YES;
        [self.videoPlayerViewController.moviePlayer setShouldAutoplay:YES];
        [self.videoPlayerViewController.moviePlayer prepareToPlay];
    
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) { /* handle the error condition */ }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) { /* handle the error condition */ }

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
    //NSURL *url = [NSURL URLWithString:video.thumbnail];
    //[self loadThumbnailImage:url];
    pAction.image = nil;
    [statusSpinner startAnimating];
    
}

-(void) loadThumbnailImage:(NSURL *)url {
    
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(q, ^{
 
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [miniPlayer setBackgroundColor:[UIColor colorWithPatternImage:img]];
            UIVisualEffect *blurEffect;
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            
            UIVisualEffectView *visualEffectView;
            visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            visualEffectView.frame = miniPlayer.frame;
            [miniPlayer addSubview:visualEffectView];
            
            
        });
    });
}

-(void)miniPlayerActionListener{
    if(isPlaying){
        [mPlayer pause];
    } else {
        [mPlayer play];
    }
}

- (void)updatePlayerState:(NSString *) state {
    if([state isEqualToString:PLAY]){
        [mPlayer play];
    } else if([state isEqualToString:PAUSE]){
        [mPlayer pause];
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
        NSLog(@"%@", nextSong.title);
    }
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

    [self updateMiniPlayerState:mPlayer.playbackState];
    
}

- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    if([mPlayer.view isHidden])
       [mPlayer.view setHidden:NO];
    [self updateMiniPlayerState:mPlayer.playbackState];
    [videoPlayer updatePlayerState:mPlayer.playbackState];
    
}

- (void)MPMoviePlayerLoadStateDidChange:(NSNotification *)notification
{
    if((mPlayer.loadState & MPMovieLoadStatePlayable) == MPMovieLoadStatePlayable)
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
    songsInLibrary = [[NSMutableSet alloc] initWithCapacity:[songs count]];
    for (VideoModel *song in songs){
        [songsInLibrary addObject:song];
    }
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
        d = (NSInteger) mPlayer.duration;
        c =(NSInteger)  mPlayer.currentPlaybackTime;
    }

    if(d < 0 ){
        d = 0;
    }
    
    [slider setValue:(CGFloat) c/ d];
    
}

@end