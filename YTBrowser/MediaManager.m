#import "MediaManager.h";



static MediaManager *sharedInstance = nil;

@interface MediaManager (){
    YTPlayerView *videoPlayer;
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

-(void)playWithVideoId:(NSString *)video{
    NSError *error = nil;
    [self player];
    
    [videoPlayer loadPlayerWithVideoId:video];
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

@end