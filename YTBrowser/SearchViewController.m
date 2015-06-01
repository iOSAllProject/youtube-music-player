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
    

    CarbonTabSwipeNavigation *tabSwipe;
    UILabel *titleLabel;
    UIView *playerBar;
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
    NSArray *names = @[@"SONGS",@"PLAYLISTS"];
    UIColor *color = [UIColor whiteColor];
    UIFont *tabFont = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    tabSwipe = [[CarbonTabSwipeNavigation alloc] createWithRootViewController:self tabNames:names tintColor:color delegate:self];
    
    [tabSwipe setNormalColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:.8] font:tabFont]; // default tintColor with alpha 0.8
    [tabSwipe setSelectedColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:1] font:tabFont]; // default tintColor
    [tabSwipe setIndicatorHeight:3.f]; // default 3.f
    [tabSwipe addShadow];
    
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.size.width/2 -30.0, 0.0, 60.0, 44.0)];
    titleLabel.text = @"YOUR MUSIC";
    titleLabel.textColor = [UIColor blackColor];
    
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    self.navigationItem.titleView = titleLabel;


    
    

    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"menu" ] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:nil];
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

@end
