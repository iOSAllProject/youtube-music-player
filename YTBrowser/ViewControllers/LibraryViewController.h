#import <UIKit/UIKit.h>
#import "MediaPlayerViewController.h"
#import "JBCoreDataStack.h"
#import "Song.h"
#import "MGBox.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "JSONModelLib.h"
#import "VideoModel.h"
#import "MGLine.h"
#import "MediaManager.h"
#import "SongCell.h"
@interface LibraryViewController : UIViewController
@property (nonatomic,strong) MediaPlayerViewController *videoPlayer;
+(VideoModel *) createVideo:(Song*) song;
@end