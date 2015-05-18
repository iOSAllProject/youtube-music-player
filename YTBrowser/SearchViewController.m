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
#import "CarbonKit.h"
#import "LibraryViewController.h"
static NSString *const searchQuery = @"https://www.googleapis.com/youtube/v3/search?q=%@&order=relevance&part=snippet&maxResults=50&type=video&videoSyndicated=true&key=AIzaSyBfXPGjGR3V49O30aEMk3VPHVwEQQ_XkN8";

@interface SearchViewController () <UITextFieldDelegate, CarbonTabSwipeDelegate, UISearchBarDelegate>
{
    
    MGScrollView* scroller;
    NSArray* videos;
    UISearchBar *searchBar;
    CarbonTabSwipeNavigation *tabSwipe;
    UIBarButtonItem *searchButton;
    UILabel *titleLabel;
    
}
@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    //bottom music player constants
    CGFloat barHeight = 40.0f;
    CGFloat barWidth = self.view.frame.size.width;
    
    
    //Set up Tabs
    NSArray *names = @[@"SONGS",@"PLAYLISTS", @"JUKEBOXES"];
    UIColor *color = [UIColor whiteColor];
    UIFont *tabFont = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    tabSwipe = [[CarbonTabSwipeNavigation alloc] createWithRootViewController:self tabNames:names tintColor:color delegate:self];
    
    [tabSwipe setNormalColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:.8] font:tabFont]; // default tintColor with alpha 0.8
    [tabSwipe setSelectedColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:1] font:tabFont]; // default tintColor
    [tabSwipe setIndicatorHeight:3.f]; // default 3.f
    [tabSwipe addShadow];
    
    //Add search scrollview
    CGFloat navBarPadding = self.navigationController.navigationBar.frame.size.height+20;
    scroller = [MGScrollView scrollerWithSize:self.view.size];
    //setup the scroll view
    scroller.contentLayoutMode = MGLayoutTableStyle;
    scroller.sizingMode = MGResizingShrinkWrap;
    scroller.bottomPadding = 8;
    scroller.backgroundColor = [UIColor whiteColor];
    scroller.frame = CGRectMake(0.0, navBarPadding, self.view.size.width, self.view.size.height - navBarPadding - barHeight );
    [self.view addSubview:scroller];
    scroller.hidden = YES;
    
    
    //Setup search bar
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
    searchBar.hidden = YES;
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.size.width/2 -30.0, 0.0, 60.0, 44.0)];
    titleLabel.text = @"YOUTIFY";
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];

    [searchBarView addSubview:titleLabel];
    
    
    //Setup search icon
    searchButton = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                       target:self action:@selector(searchClicked:)];
    [searchButton  setTintColor:[UIColor redColor]];
    self.navigationItem.rightBarButtonItem = searchButton;
    


    
    
    
    //setup music player at bottom of screen
    self.playerBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-barHeight, self.view.frame.size.width, barHeight)];
    self.playerBar.backgroundColor =  [UIColor blackColor];
    
    UITapGestureRecognizer *playerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayDetailedPlayer)];
    [self.playerBar addGestureRecognizer:playerTap];
    
    [self.view addSubview:self.playerBar];
    [[MediaManager sharedInstance] initializeVideoPlayer:self.playerBar];

    
    //[self.view addSubview:self.playerBar];
    //[self.view addSubview:self.pTitle];
    
    //add search box
   //[scroller.boxes addObject: searchBox];
  //  self.navigationItem.titleView = searchBox;
    //fire up the first search
    //[self searchYoutubeVideosForTerm: searchBar.text];
}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.hidden = YES;
    titleLabel.hidden = NO;
    self.navigationItem.rightBarButtonItem = searchButton;
    scroller.hidden = YES;
    
}


-(void) searchClicked:(id) sender{
    searchBar.hidden = NO;
    searchBar.showsCancelButton = YES;
    titleLabel.hidden= YES;
    self.navigationItem.rightBarButtonItem = nil;
    [searchBar becomeFirstResponder];
    scroller.hidden = NO;
    
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
        PhotoBox *box = [PhotoBox photoBoxForVideo:video withSize:CGSizeMake(self.view.frame.size.width-20,80) withLine:YES];
        
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchYoutubeVideosForTerm:searchBar.text];
}


-(void) displayDetailedPlayer {
    if(!self.videoPlayer) {
        self.videoPlayer = [[ViewController alloc] init];
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.videoPlayer];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

// delegate
- (UIViewController *)tabSwipeNavigation:(CarbonTabSwipeNavigation *)tabSwipe viewControllerAtIndex:(NSUInteger)index {
    LibraryViewController *vc = [[LibraryViewController alloc] init];
    return  vc;// return viewController at index
}


@end
