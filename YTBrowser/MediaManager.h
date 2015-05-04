#import <UIKit/UIKit.h>
#import "YTPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "VideoModel.h"
@interface MediaManager : NSObject<YTPlayerViewDelegate>{
    
}

+(MediaManager *)sharedInstance;
-(void)playWithVideo:(VideoModel *)video;
-(void)initializeVideoPlayer:(UIView *) playerView;
-(YTPlayerView *)getVideoPlayer;

@end