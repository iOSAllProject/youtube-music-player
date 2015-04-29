#import <UIKit/UIKit.h>
#import "YTPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MediaManager : NSObject{
    
}

+(MediaManager *)sharedInstance;
-(void)playWithVideoId:(NSString *)video;

@end