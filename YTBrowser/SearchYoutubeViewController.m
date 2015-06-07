//
//  SearchYoutubeViewController.m
//  YTBrowser
//
//  Created by Matan Vardi on 5/31/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

#import "SearchYoutubeViewController.h"
static NSString *const searchQuery = @"https://www.googleapis.com/youtube/v3/search?q=%@&order=relevance&part=snippet&maxResults=50&type=video&key=AIzaSyBfXPGjGR3V49O30aEMk3VPHVwEQQ_XkN8";

@interface SearchYoutubeViewController ()
{
    MGScrollView* scroller;
    NSArray* videos;
    UISearchBar *searchBar;
    UIView *playerBar;
    UIBarButtonItem *searchButton;

}
@end

@implementation SearchYoutubeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //bottom music player constants
    CGFloat barHeight = 40.0f;
    CGFloat barWidth = self.view.frame.size.width;
    
    //Add search scrollview

    scroller = [MGScrollView scrollerWithSize:self.view.size];
    //setup the scroll view
    scroller.contentLayoutMode = MGLayoutTableStyle;
    scroller.sizingMode = MGResizingShrinkWrap;
    scroller.bottomPadding = 8;
    scroller.backgroundColor = [UIColor whiteColor];
    scroller.delegate = self;
    scroller.frame = CGRectMake(0.0, 0.0, self.view.size.width, self.view.size.height - barHeight );
    [self.view addSubview:scroller];

    
    
    //Setup search bar
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 260.0, 44.0)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 44.0)];
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


    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"menu" ] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) displayDetailedPlayer {
    if(!self.videoPlayer) {
        self.videoPlayer = [[ViewController alloc] init];
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.videoPlayer];
    [self presentViewController:navigationController animated:YES completion:nil];
}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    self.navigationItem.rightBarButtonItem = searchButton;
    scroller.hidden = YES;
    
}


-(void) searchClicked:(id) sender{
    searchBar.hidden = NO;
    searchBar.showsCancelButton = YES;
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
        PhotoBox *box = [PhotoBox photoBoxForVideo:video withSize:CGSizeMake(self.view.frame.size.width-20,65) withLine:YES];
        
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //setup music player at bottom of screen
    playerBar = [[MediaManager sharedInstance] getMiniPlayer];
    
    UITapGestureRecognizer *playerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayDetailedPlayer)];
    [playerBar addGestureRecognizer:playerTap];
    
    [self.view addSubview:playerBar];
    
}
-(void)viewWillDisappear {
    [playerBar removeFromSuperview];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   [searchBar resignFirstResponder];
}

@end
