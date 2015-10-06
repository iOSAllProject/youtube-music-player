#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "VideoModel.h"
#import "MediaPlayerViewController.h"
#import "XCDYouTubeKit.h"
#import "AppConstant.h"
#import <QuartzCore/QuartzCore.h>
#import "JukeboxEntry.h"
#import <MMX/MMX.h>
@interface MediaManager : NSObject{
    
}

+(MediaManager *)sharedInstance;
-(void)playWithVideo:(VideoModel *)video;
-(void)initializeVideoPlayer:(UIView *) playerView;
-(XCDYouTubeVideoPlayerViewController *)getVideoPlayer;
-(VideoModel*) getCurrentlyPlaying;
-(void) runInBackground;
-(UIView *) getMiniPlayer;
//@property(nonatomic,strong) JukeboxEntry *jukeBox;
-(void) setPlaylist:(NSArray *)songs andSongIndex:(NSInteger)index ;
-(void) setCurrentLibrary:(NSArray *) songs;
-(BOOL) isInLibrary:(VideoModel*) song;
-(UIViewController *) getVideoPlayerViewController;
- (void)updatePlayerState:(NSString *) state;
-(void) skipToNextSong;
-(void) skipToPrevSong;
-(void) updateJukeboxPlayState;

@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, strong) NSArray *currentPlaylist;

@property(nonatomic, strong) JukeboxEntry* currentJukebox;
@property(nonatomic,strong)     MPMoviePlayerController *mPlayer;
@property(nonatomic, strong) MMXChannel *currentChannel;
@property NSInteger elapsed;
@property NSInteger lastTimeStamp;
@property NSInteger latency;
@property BOOL userPaused;
@end