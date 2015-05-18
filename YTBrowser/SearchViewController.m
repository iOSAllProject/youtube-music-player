//
//  ViewController.m
//  YTBrowser
//
//  Created by Marin Todorov on 03/01/2013.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "SearchViewController.h"
#import "ViewController.h"
#import "MGBox.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "JSONModelLib.h"
#import "VideoModel.h"
#import "MGLine.h"
#import "MediaManager.h"
#import "PhotoBox.h"
#import "WebVideoViewController.h"

static NSString *const searchQuery = @"https://www.googleapis.com/youtube/v3/search?q=%@&order=relevance&part=snippet&maxResults=50&type=video&videoSyndicated=true&key=AIzaSyBfXPGjGR3V49O30aEMk3VPHVwEQQ_XkN8";

@interface SearchViewController () <UITextFieldDelegate>
{
    
    MGScrollView* scroller;
    MGBox *libraryView;
    //MGBox* tablesGrid;
    NSArray* videos;
    UISearchBar *searchBar;
    
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    scroller = [MGScrollView scrollerWithSize:self.view.size];
    //setup the scroll view
    scroller.contentLayoutMode = MGLayoutTableStyle;
    
    scroller.sizingMode = MGResizingShrinkWrap;
    scroller.bottomPadding = 8;
    scroller.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scroller];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 300.0, 44.0)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 290.0, 44.0)];
    [searchBar setBackgroundColor:[UIColor clearColor]];
    [searchBar setBackgroundImage:[UIImage new]];
    [searchBar setTranslucent:YES];
    searchBarView.autoresizingMask = 0;
    searchBar.delegate = self;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.placeholder = @"Search";
    searchBar.text = @"Maroon 5 Live";
    [searchBarView addSubview:searchBar];
    self.navigationItem.titleView = searchBarView;
    CGFloat barHeight = 40.0f;
    CGFloat barWidth = self.view.frame.size.width;
    self.playerBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-barHeight, self.view.frame.size.width, barHeight)];
    self.playerBar.backgroundColor =  [UIColor blackColor];
    
    UITapGestureRecognizer *playerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayDetailedPlayer)];
    [self.playerBar addGestureRecognizer:playerTap];
    
    [self.view addSubview:self.playerBar];
    [[MediaManager sharedInstance] initializeVideoPlayer:self.playerBar];

    libraryView = [MGBox boxWithSize:(CGSize) {self.view.frame.size.width, 40}];
    [self setupLibraryView];

    //[self.view addSubview:self.playerBar];
    //[self.view addSubview:self.pTitle];
    
    //add search box
   //[scroller.boxes addObject: searchBox];
  //  self.navigationItem.titleView = searchBox;
    //fire up the first search
    //[self searchYoutubeVideosForTerm: searchBar.text];
}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
}

-(void) setupLibraryView {
    MGBox *titleBox = [MGBox boxWithSize:(CGSize) {self.view.frame.size.width, 40}];
    CGFloat hPad = 20.0;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(hPad/2, 5.0, titleBox.size.width-hPad, titleBox.size.height)];
    titleLabel.text = @"LIBRARY";
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
    titleLabel.textColor = [UIColor blackColor];
    [titleBox addSubview:titleLabel];
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(hPad/2, titleBox.size.height-1, titleBox.size.width-hPad, 0.5)];
    border.backgroundColor = [UIColor grayColor];
    [titleBox addSubview:border];
    [libraryView.boxes addObject:titleBox];
    [self fetchedResultsController];
    [_fetchedResultsController performFetch:nil];
    NSInteger *numRows = [_fetchedResultsController.fetchedObjects count];
    NSLog(@"%d", numRows);
    [self showLibrary];
    [scroller.boxes addObject:libraryView];
    //re-layout the scroll view
    [scroller layout];
    
}
-(void) showLibrary {
    for (Song *song in _fetchedResultsController.fetchedObjects){
        //get the data
        VideoModel *video = [self createVideo:song];
        //create a box
        PhotoBox *box = [PhotoBox photoBoxForVideo:video withSize:CGSizeMake(self.view.frame.size.width-20,80)];
        box.frame = CGRectIntegral(box.frame);
        box.onTap = ^{
            [[MediaManager sharedInstance] playWithVideo:video];
            
        };
        
        //add the box
        [libraryView.boxes addObject:box];
    }

}

-(VideoModel *) createVideo:(Song*) song {
    VideoModel *video = [[VideoModel alloc] init];
    video.title = song.title;
    video.videoId = song.videoId;
    video.thumbnail = song.url;
    return video;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchYoutubeVideosForTerm:searchBar.text];
}

-(void)searchYoutubeVideosForTerm:(NSString*)term
{
    NSLog(@"Searching for '%@' ...", term);
    
    //URL escape the term
    term = [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //make HTTP call
    NSString *searchCall2 = [NSString stringWithFormat:searchQuery, term];
    
    NSLog(@"%@", searchCall2);

    
    [JSONHTTPClient getJSONFromURLWithString: searchCall2
                                  completion:^(NSDictionary *json, JSONModelError *err) {
                                      
                                      //got JSON back
                                      NSLog(@"Got JSON from web: %@", json);
                                      
                                      if (err) {
                                          [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:[err localizedDescription]
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Close"
                                                            otherButtonTitles: nil] show];
                                          return;
                                      }
                                      
                                      //initialize the models
                                      videos = [VideoModel arrayOfModelsFromDictionaries:
                                                json[@"items"]
                                                ];
                                      
                                      if (videos) NSLog(@"Loaded successfully models");

                                      //show the videos
                                      [self showVideos];
                                      
                                  }];
}

-(void)showVideos
{
    //clean the old videos
    if([scroller.boxes count] > 0)
        [scroller.boxes removeObjectsInRange:NSMakeRange(0, scroller.boxes.count)];
    
    
    //add boxes for all videos
    for (int i=0;i<videos.count;i++) {
        
        //get the data
        VideoModel* video = videos[i];
        //create a box
        PhotoBox *box = [PhotoBox photoBoxForVideo:video withSize:CGSizeMake(self.view.frame.size.width-20,80)];
        box.frame = CGRectIntegral(box.frame);
        box.onTap = ^{
            [[MediaManager sharedInstance] playWithVideo:video];

        };
        
        //add the box
        [scroller.boxes addObject:box];
    }

    //re-layout the scroll view
    [scroller layout];
}


-(void) displayDetailedPlayer {
    if(!self.videoPlayer) {
        self.videoPlayer = [[ViewController alloc] init];
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.videoPlayer];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}


#pragma coreData


- (NSFetchedResultsController * ) fetchedResultsController {
    if(_fetchedResultsController != nil){
        return self.fetchedResultsController;
    }
    
    JBCoreDataStack *coreDataStack = [JBCoreDataStack defaultStack];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"videoId" ascending:true]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:coreDataStack.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    return _fetchedResultsController;
}
@end