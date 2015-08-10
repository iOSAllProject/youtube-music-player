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
    NSMutableArray *currentLibrary;
    UIImageView *searchIcon;
}
@end

@implementation SearchYoutubeViewController

- (id) initForJukeBoxSearch {
    self = [super init];
    if(self){

        [self basicSetup];
        
        
        //Setup search bar
        
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0.0, 295.0, 44.0)];
        searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 305.0, 44.0)];
        [searchBar setBackgroundColor:[UIColor clearColor]];
        [searchBar setBackgroundImage:[UIImage new]];
        [searchBar setTranslucent:YES];
        searchBarView.autoresizingMask = 0;
        searchBar.delegate = self;
        searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        searchBar.placeholder = @"Search for songs, artists, and albums";
        [searchBarView addSubview:searchBar];
        self.navigationItem.titleView = searchBarView;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(popViewController:)];
            
    }
    return self;
}

-(id) initForSongSearch {
    self = [super init];
    if (self) {


                                   ///[UIImage imageNamed:@"search"]];
        //Setup search bar
        [self basicSetup];
        
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 320.0, 44.0)];
        searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 310.0, 44.0)];
        [searchBar setBackgroundColor:[UIColor clearColor]];
        [searchBar setBackgroundImage:[UIImage new]];
        [searchBar setTranslucent:YES];
        searchBarView.autoresizingMask = 0;
        searchBar.delegate = self;
        searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        searchBar.placeholder = @"Search for songs, artists, and albums";
        [searchBarView addSubview:searchBar];
        self.navigationItem.titleView = searchBarView;
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"menu" ] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    }
    return self;
    
    

}

-(void) basicSetup {
    
    //bottom music player constants
    CGFloat barHeight = 40.0f;
    CGFloat barWidth = self.view.frame.size.width;
    
    
    CGFloat imageSize = 150.0f;
    searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - imageSize/2, self.view.frame.size.height/2 - imageSize, imageSize, imageSize)];
    searchIcon.image = [UIImage imageNamed:@"search"];
    
    
    
    scroller = [MGScrollView scrollerWithSize:self.view.size];
    //setup the scroll view
    scroller.contentLayoutMode = MGLayoutTableStyle;
    scroller.sizingMode = MGResizingShrinkWrap;
    scroller.bottomPadding = 8;
    scroller.backgroundColor = [UIColor whiteColor];
    scroller.delegate = self;
    scroller.frame = CGRectMake(0.0, 0.0, self.view.size.width, self.view.size.height - barHeight );
    [self.view addSubview:scroller];
    

    
    [self.view addSubview:searchIcon];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) displayDetailedPlayer {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[MediaManager sharedInstance] getVideoPlayerViewController]];
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
    [scroller setContentOffset:CGPointMake(0, -64)];
    currentLibrary = [[NSMutableArray alloc] init];
    BOOL drawLine = YES;
    //create now playing label
    MGLine *layoutLine = [MGLine lineWithLeft:@"TOP RESULTS" right:nil
                                         size:(CGSize){self.view.frame.size.width, 44}];
    layoutLine.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    layoutLine.leftPadding = layoutLine.rightPadding = 16;
    [scroller.boxes addObject:layoutLine];
    
    //add boxes for all videos
    for (int i=0;i<videos.count;i++) {
        
        //get the data
        VideoModel* video = videos[i];
        //create a box
        SongCell *box = [SongCell photoBoxForVideo:video withSize:CGSizeMake(self.view.frame.size.width-20,65) withLine:YES];
        if(i == videos.count - 1)
            drawLine = NO;
        [currentLibrary addObject:video];
        box.frame = CGRectIntegral(box.frame);
        box.onTap = ^{
            if(playerBar.isHidden){
                scroller.frame = (CGRect){0,0,self.view.frame.size.width, self.view.frame.size.height-44};
                playerBar.hidden =  NO;
            }
            [[MediaManager sharedInstance] setPlaylist:currentLibrary andSongIndex:i];
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
    searchIcon.alpha = 0.0;
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
    if(playerBar.isHidden){
        scroller.frame = (CGRect){0,0,self.view.frame.size.width, self.view.frame.size.height};
    } else {
        scroller.frame = (CGRect){0,0,self.view.frame.size.width, self.view.frame.size.height-44};
    }
    
}
-(void)viewWillDisappear {
    [playerBar removeFromSuperview];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   [searchBar resignFirstResponder];
}

-(void) popViewController:(id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
