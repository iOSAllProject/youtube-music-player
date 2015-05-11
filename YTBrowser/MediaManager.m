#import "MediaManager.h";



static MediaManager *sharedInstance = nil;

@interface MediaManager (){
    YTPlayerView *videoPlayer;
    BOOL isInBackgroundMode;
    NSTimer *timer;
    BOOL isPlaying;
    VideoModel *currentlyPlaying;
    /*
     Mini player components
     */
    UIView *miniPlayer;
    UIImageView *pImage;
    UILabel *pLabel;
    UIImageView *pAction;
    UIActivityIndicatorView *statusSpinner;
    
}

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
    [self player];
    miniPlayer = playerView;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appIsInBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    pImage = [[UIImageView alloc] init];
    pImage.frame = CGRectMake(0.0, 0.0, 70.0, 40.0);
    [miniPlayer addSubview:pImage];

    CGFloat TITLE_HEIGHT = 30.0;
    CGFloat TITLE_SPACE = (miniPlayer.frame.size.height - TITLE_HEIGHT )/2;
    
    pLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, TITLE_SPACE, miniPlayer.frame.size.width-120, TITLE_HEIGHT)];
    pLabel.textColor = [UIColor whiteColor];
    pLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:10.0f];
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
}

-(void)playWithVideo:(VideoModel *)video{
    [self updateMiniPlayer: video];
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
    }

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
        [videoPlayer pauseVideo];
    } else {
        [videoPlayer playVideo];
    }
}

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
}

#pragma mark -
#pragma mark Notifications

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


- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state{
    switch(state){
        case kYTPlayerStatePlaying:
            if([statusSpinner isAnimating])
                [statusSpinner stopAnimating];
            isPlaying = TRUE;
            pAction.image = [UIImage imageNamed:@"white_pause_128"];
            break;
        case kYTPlayerStatePaused:
            if([statusSpinner isAnimating])
                [statusSpinner stopAnimating];
            isPlaying = FALSE;
            pAction.image = [UIImage imageNamed:@"play_white_128"];
            break;
            
        case kYTPlayerStateEnded:
            if([statusSpinner isAnimating])
                [statusSpinner stopAnimating];
            isPlaying = FALSE;
            currentlyPlaying = nil;
            pAction.image = [UIImage imageNamed:@"play_white_128"];
            break;
        default:
            break;
    }
    pAction.hidden = FALSE;
}



- (YTPlayerView *) getVideoPlayer {
    return videoPlayer;
}



@end