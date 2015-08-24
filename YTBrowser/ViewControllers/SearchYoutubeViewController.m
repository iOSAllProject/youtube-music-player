//
//  SearchYoutubeViewController.m
//  YTBrowser
//
//  Created by Matan Vardi on 5/31/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//
#import "UIViewController+ScrollingNavbar.h"
#import "PXAlertView+Customization.h"
#import "SearchYoutubeViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Parse/Parse.h>
static NSString *const searchQuery = @"https://www.googleapis.com/youtube/v3/search?q=%@&order=relevance&part=snippet&maxResults=50&type=video&key=AIzaSyBfXPGjGR3V49O30aEMk3VPHVwEQQ_XkN8";


@interface SearchYoutubeViewController () <AMScrollingNavbarDelegate>
{
    MGScrollView* scroller;
    NSArray* videos;
    UISearchBar *searchBar;
    UIView *playerBar;
    UIBarButtonItem *searchButton;
    NSMutableArray *currentLibrary;
    UIImageView *searchIcon;
    UILabel *searchLabel;
    
    JukeboxEntry *_jukeboxEntry;
    //Flag for whether music should be played when a result is clicked on
    BOOL playMusic;
    
}
@end

@implementation SearchYoutubeViewController

- (id) initForJukeBoxSearch: (JukeboxEntry*) jukeboxEntry {
    self = [super init];
    if(self){

        [self basicSetup];
        _jukeboxEntry = jukeboxEntry;
        
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
        playMusic = NO;
            
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
        searchBar.placeholder = @"Search";
        [searchBarView addSubview:searchBar];
        self.navigationItem.titleView = searchBarView;
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"menu" ] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
        playMusic = YES;
    }
    return self;
    
    

}

-(void) basicSetup {
    
    //bottom music player constants
    CGFloat barHeight = 40.0f;
    CGFloat barWidth = self.view.frame.size.width;
    
    
    CGFloat imageSize = 100.0f;
    searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - imageSize/2, self.view.frame.size.height/2 - imageSize, imageSize, imageSize)];
    searchIcon.image = [UIImage imageNamed:@"search"];
    
    CGFloat labelSize = 200;
    
    searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(searchIcon.frame.origin.x - labelSize/2 + imageSize/2, searchIcon.frame.origin.y + searchIcon.frame.size.height, labelSize,40.0)];
    searchLabel.text = @"Find your favorite music";
    searchLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
    searchLabel.textColor = [UIColor blackColor];
    searchLabel.textAlignment = NSTextAlignmentCenter;

    scroller = [MGScrollView scrollerWithSize:self.view.size];
    //setup the scroll view
    scroller.contentLayoutMode = MGLayoutTableStyle;
    scroller.sizingMode = MGResizingShrinkWrap;
    scroller.bottomPadding = 0;
    scroller.backgroundColor = [UIColor whiteColor];
    scroller.delegate = self;
    scroller.frame = CGRectMake(0.0, 0.0, self.view.size.width, self.view.size.height - barHeight );
    [self.view addSubview:scroller];

    
    [self.view addSubview:searchIcon];
    [self.view addSubview:searchLabel];
    
    // Just call this line to enable the scrolling navbar
    [self followScrollView:scroller withDelay:100];
    
    // Set it to YES if the scrollview being watched is contained in the main view
    // Set it to NO if the scrollview IS the main view (e.g.: subclasses of UITableViewController)
    [self setUseSuperview:NO];
    
    // Enable the autolayout-friendly handling of the view
    //[self setScrollableViewConstraint:self.headerConstraint withOffset:60];
    
    // Stops the scrolling if the content fits inside the frame
    [self setShouldScrollWhenContentFits:NO];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    


}


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
            if(playMusic) {
                if(playerBar.isHidden){
                    scroller.frame = (CGRect){0,0,self.view.frame.size.width, self.view.frame.size.height-44};
                    playerBar.hidden =  NO;
                }
                [[MediaManager sharedInstance] setPlaylist:currentLibrary andSongIndex:i];
                [[MediaManager sharedInstance] playWithVideo:video];
            } else {
                
                [self showSongAlertView:video andThumb:box.image];
            }
        };
        
        //add the box
        [scroller.boxes addObject:box];
    }
    
    //re-layout the scroll view
    [scroller layout];
    
    for(int i = 0; i <[scroller.boxes count]; i++){
        CGFloat tableHeight = scroller.frame.size.height;
        MGBox *box =[scroller.boxes objectAtIndex:i];
        box.transform = CGAffineTransformMakeTranslation(0, tableHeight);
    }
    
    for (int i = 0; i < [scroller.boxes count]; i++){
        // fade the image in
        [UIView animateWithDuration:1.5 delay:(0.02 * i) usingSpringWithDamping:.8 initialSpringVelocity:0 options:nil animations:^{
            MGBox *box = [scroller.boxes objectAtIndex:i];
            box.transform = CGAffineTransformMakeTranslation(0, 0);
        } completion:nil];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchIcon.alpha = 0.0;
    searchLabel.alpha = 0.0;
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

- (void)viewWillLayoutSubviews {
    // Your adjustments accd to
    // viewController.bounds
    playerBar.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
    if(playerBar.isHidden){
        scroller.frame = (CGRect){0,0,self.view.frame.size.width, self.view.frame.size.height};
    } else {
        scroller.frame = (CGRect){0,0,self.view.frame.size.width, self.view.frame.size.height-44};
        
    }
    [super viewWillLayoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self showNavBarAnimated:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self showNavBarAnimated:NO];
}


# pragma jukebox functionality
-(void) showSongAlertView:(VideoModel *) song andThumb:(UIImage *) thumb
{
    PXAlertView *alert =  [PXAlertView showAlertWithTitle:@"Add Song to Jukebox"
                            message:[NSString stringWithFormat:@"%@", song.title]
                        cancelTitle:@"Cancel"
                         otherTitle:@"Yes!"
                        contentView:[[UIImageView alloc] initWithImage:thumb]
                         completion:^(BOOL cancelled, NSInteger buttonIndex) {
                             if(!cancelled){
                                 [self submitSongToJukebox:song];
                             }
                         }];
    
   [alert setBackgroundColor:[UIColor whiteColor]];
    [alert setMessageColor:[UIColor blackColor]];
    [alert setTitleColor:[UIColor blackColor]];

    
    
    UIColor *cNormal = [UIColor colorWithRed:43/255.0 green:189/255.0 blue:224/255.0 alpha:1.0];
    UIColor *cSelected =  [UIColor colorWithRed:108/255.0 green:164/255.0 blue:176/255.0 alpha:1.0];
    UIColor *oNormal = [UIColor whiteColor];
    UIColor *oSelected = [UIColor whiteColor];
    
    [alert setCancelButtonNonSelectedBackgroundColor:oNormal];
    [alert setCancelButtonBackgroundColor:oSelected];

    [alert setOtherButtonNonSelectedBackgroundColor:cNormal];
    [alert setOtherButtonBackgroundColor:cSelected];
    [alert setTitleFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [alert setMessageFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f]];
    [alert setCancelButtonTextColor:[UIColor blackColor]];
    [alert setOtherButtonTextColor:[UIColor whiteColor]];
    
}

-(void) submitSongToJukebox:(VideoModel *) song {
    //save pictures
    UIColor *color = [UIColor grayColor];
    [SVProgressHUD setBackgroundColor:[color colorWithAlphaComponent:0.7f]];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updateJukebox:song];
    });
}
         
-(void) updateJukebox:(VideoModel*) song {
    // time-consuming task
    PFQuery *query = [PFQuery queryWithClassName:@"Jukeboxes"];
    [query getObjectInBackgroundWithId:_jukeboxEntry.objectId block:^(PFObject *jukebox, NSError *error) {
        NSLog(@"%@", jukebox);

        PFObject *mySong = [PFObject objectWithClassName:@"Songs"];
        mySong[@"title"] = song.title;
        mySong[@"thumbnail"] = song.thumbnail;
        mySong[@"vid"] = song.videoId;
        [jukebox addObject:mySong forKey:@"playQueue"];
        [jukebox saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            if(succeeded){
                [self popViewController:nil];
            }
            else{
                //  [self displayAlertView:[error localizedDescription] withTitle: @"Something went wrong."];
            }
            
        }];
    
    }];
}

@end
