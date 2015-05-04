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

@interface SearchViewController () <UITextFieldDelegate>
{
    MGScrollView* scroller;
    //MGBox* tablesGrid;
    NSArray* videos;
    
}

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
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 300.0, 44.0)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 290.0, 44.0)];
    [searchBar setBackgroundColor:[UIColor clearColor]];
    [searchBar setBackgroundImage:[UIImage new]];
    [searchBar setTranslucent:YES];
    searchBarView.autoresizingMask = 0;
    searchBar.delegate = self;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.placeholder = @"Search";
    searchBar.text = @"John Mayer";
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


    //[self.view addSubview:self.playerBar];
    //[self.view addSubview:self.pTitle];
    
    //add search box
   //[scroller.boxes addObject: searchBox];
  //  self.navigationItem.titleView = searchBox;
    //fire up the first search
    [self searchYoutubeVideosForTerm: searchBar.text];
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
    NSString *searchCall2 = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?q=%@&order=relevance&part=snippet&maxResults=50&type=video&videoSyndicated=true&key=AIzaSyBfXPGjGR3V49O30aEMk3VPHVwEQQ_XkN8", term];
    
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
        NSURL *url = [NSURL URLWithString:video.thumbnail];
        PhotoBox *box = [PhotoBox photoBoxForURL:url title:video.title withSize:CGSizeMake(self.view.frame.size.width,80)];
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
@end
