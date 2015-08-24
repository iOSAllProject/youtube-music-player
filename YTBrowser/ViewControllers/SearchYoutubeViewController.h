//
//  SearchYoutubeViewController.h
//  YTBrowser
//
//  Created by Matan Vardi on 5/31/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGBox.h"
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
#import "JukeboxEntry.h"
@interface SearchYoutubeViewController : UIViewController
@property (nonatomic,strong) MediaPlayerViewController *videoPlayer;
-(id) initForSongSearch;
-(id) initForJukeBoxSearch:(JukeboxEntry*) jukeboxEntry;
@end
