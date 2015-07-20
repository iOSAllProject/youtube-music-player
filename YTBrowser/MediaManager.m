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
    UIImageView *pImage;
    UILabel *pLabel;
    UIImageView *pAction;
    UIActivityIndicatorView *statusSpinner;
    MPMoviePlayerController *mPlayer;
    
    NSArray *currentPlaylist;
    NSMutableSet *songsInLibrary;
    NSInteger  currentSongIndex;
    
    
}
@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;
@end
@implementation MediaManager

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
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appIsInBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillBeInBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];*/
    /*CAGradientLayer *layer = [CAGradientLayer layer];
    layer.colors = [NSArray arrayWithObjects:
                    (id)[[UIColor blackColor] CGColor],
                    (id)[[UIColor grayColor] CGColor],
                    (id)[[UIColor grayColor] CGColor],
                    (id)[[UIColor blackColor] CGColor],
                    nil];
    layer.locations = [NSArray arrayWithObjects:
                       [NSNumber numberWithFloat:0],
                       [NSNumber numberWithFloat:0.4],
                       [NSNumber numberWithFloat:0.6],
                       [NSNumber numberWithFloat:1],
                       nil];
    layer.startPoint = CGPointMake(0, 0);
    layer.frame = miniPlayer.bounds;
    layer.endPoint = CGPointMake(1, 1);
    layer.contentsGravity = kCAGravityResize;
    [miniPlayer.layer addSublayer:layer];*/
    miniPlayer.backgroundColor = RGB(34,34,34);
    pImage = [[UIImageView alloc] init];
    pImage.frame = CGRectMake(0.0, 0.0, 77.0, 45.0);
    [miniPlayer addSubview:pImage];


    
    
    CGFloat TITLE_HEIGHT = 30.0;
    CGFloat TITLE_SPACE = (miniPlayer.frame.size.height - TITLE_HEIGHT )/2;
    
    pLabel = [[UILabel alloc] initWithFrame:CGRectMake(82.0, TITLE_SPACE, miniPlayer.frame.size.width-120, TITLE_HEIGHT)];
    pLabel.textColor = [UIColor whiteColor];
    pLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:13.0f];
    pLabel.numberOfLines = 0;
    [miniPlayer addSubview:pLabel];

    CGFloat ACTION_LENGTH = 22.0;
    CGFloat ACTION_PADDING = (playerView.frame.size.height - ACTION_LENGTH)/2;
    
    pAction = [[UIImageView alloc] init];
    pAction.frame = CGRectMake(miniPlayer.frame.size.width-ACTION_LENGTH-ACTION_PADDING, ACTION_PADDING, ACTION_LENGTH, ACTION_LENGTH);
    UITapGestureRecognizer *buttonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(miniPlayerActionListener)];
    [pAction setUserInteractionEnabled:YES];
    [pAction addGestureRecognizer:buttonTap];
    [miniPlayer addSubview:pAction];
    
    statusSpinner = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    statusSpinner.center = CGPointMake(pAction.frame.size.width / 2, pAction.frame.size.height / 2);
    statusSpinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    statusSpinner.color = UIColor.lightGrayColor;
    [pAction addSubview:statusSpinner];
    isInitialized = YES;
    miniPlayer.hidden = YES;
    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] init];


}

-(void)playWithVideo:(VideoModel *)video{
    [self updateMiniPlayer: video];
    miniPlayer.hidden = NO;
    currentlyPlaying = video;
    [self.videoPlayerViewController.moviePlayer stop];
    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    mPlayer.view.hidden = YES;
    mPlayer = self.videoPlayerViewController.moviePlayer;
    [self.videoPlayerViewController.moviePlayer setControlStyle:MPMovieControlStyleNone];
    
    
    self.videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = YES;
    [self.videoPlayerViewController setVideoIdentifier:video.videoId];
    [self.videoPlayerViewController.moviePlayer setShouldAutoplay:YES];
    [self.videoPlayerViewController.moviePlayer prepareToPlay];
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) { /* handle the error condition */ }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) { /* handle the error condition */ }
    

   
    /*
    currentlyPlaying = video;
    [videoPlayer loadPlayerWithVideoId:video.videoId];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
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
    }*/

}

-(void) updateMiniPlayer: (VideoModel *) video {
    pLabel.text = video.title;
    NSURL *url = [NSURL URLWithString:video.thumbnail];
    [self loadThumbnailImage:url];
    pAction.image = nil;
    [statusSpinner startAnimating];
}

-(void) loadThumbnailImage:(NSURL *)url {
    
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(q, ^{
        /* Fetch the image from the server... */
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            /* This is the main thread again, where we set the tableView's image to
             be what we just fetched. */
            pImage.image= img;
            
        });
    });
}

-(void)miniPlayerActionListener{
    [statusSpinner startAnimating];
    pAction.image = nil;
    if(isPlaying){
        [mPlayer pause];
    } else {
        [mPlayer play];
    }
}
/*
-(YTPlayerView*)player
{
    if(!videoPlayer)
    {
        videoPlayer = [[YTPlayerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        videoPlayer.delegate = self;
        videoPlayer.autoplay = YES;
        videoPlayer.modestbranding = YES;
        videoPlayer.showinfo = YES;
        videoPlayer.controls = YES;
        videoPlayer.allowLandscapeMode = NO;
        videoPlayer.forceBackToPortraitMode = YES;
        videoPlayer.allowAutoResizingPlayerFrame = NO;
        videoPlayer.playsinline = NO;
        videoPlayer.fullscreen = NO;
        videoPlayer.playsinline = YES;
    }
    
    return videoPlayer;
}*/

#pragma mark -
#pragma mark Notifications
/*
-(void)appIsInBackground:(NSNotification*)notification{
    if(isPlaying)
        [self.player playVideo];
}



-(void)keepPlaying{
    if(isInBackgroundMode){
        [videoPlayer playVideo];
        isInBackgroundMode = NO;
    }
    else{
        [timer invalidate];
        timer = nil;
    }
}

- (void)playerView:(YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality)quality
{
    [videoPlayer setPlaybackQuality:kYTPlaybackQualityHD720];
}
- (void)appWillBeInBackground:(NSNotification *)notification
{

}*/

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state{
    [self updateMiniPlayerState:state];
}

-(void) updateMiniPlayerState:(MPMoviePlaybackState)state {
    
    if (state == MPMoviePlaybackStatePlaying) { //playing
        
        if([statusSpinner isAnimating])
            [statusSpinner stopAnimating];
        isPlaying = TRUE;
        pAction.image = [UIImage imageNamed:@"white_pause_128"];
    } if (state== MPMoviePlaybackStateStopped) { //stopped

    } if (state == MPMoviePlaybackStatePaused) { //paused
        
        if([statusSpinner isAnimating])
            [statusSpinner stopAnimating];
        isPlaying = FALSE;
        pAction.image = [UIImage imageNamed:@"play_white_128"];
        
    }if (state == MPMoviePlaybackStateInterrupted)
    { //interrupted
    }if (state == MPMoviePlaybackStateSeekingForward)
    { //seeking forward
    }if (state == MPMoviePlaybackStateSeekingBackward)
    { //seeking backward
    }
    pAction.hidden = FALSE;
    self.videoPlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleNone;
}



- (XCDYouTubeVideoPlayerViewController *) getVideoPlayer {
    return self.videoPlayerViewController;
}


-(VideoModel *) getCurrentlyPlaying {
    return currentlyPlaying;
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
    
}

- (void)MPMoviePlayerNowPlayingMovieDidChange:(NSNotification *)notification
{
    if((mPlayer.loadState & MPMovieLoadStatePlayable) == MPMovieLoadStatePlayable)
    {
        //if load state is ready to play
        //if(mPlayer.playbackState == MPMoviePlaybackStatePaused)
          //  [mPlayer play];//play the video
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




@end