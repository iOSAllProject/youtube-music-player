#import <UIKit/UIKit.h>
#import "YTPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "VideoModel.h"
#import "ViewController.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "AppConstant.h"
@interface MediaManager : NSObject<YTPlayerViewDelegate>{
    
}

+(MediaManager *)sharedInstance;
-(void)playWithVideo:(VideoModel *)video;
-(void)initializeVideoPlayer:(UIView *) playerView;
-(XCDYouTubeVideoPlayerViewController *)getVideoPlayer;
-(VideoModel*) getCurrentlyPlaying;
-(void) runInBackground;
-(UIView *) getMiniPlayer;

-(void) setPlaylist:(NSArray *)songs andSongIndex:(NSInteger)index ;
-(void) setCurrentLibrary:(NSArray *) songs;
-(BOOL) isInLibrary:(VideoModel*) song;
-(UIViewController *) getVideoPlayerViewController;
- (void)updatePlayerState:(NSString *) state;
@end