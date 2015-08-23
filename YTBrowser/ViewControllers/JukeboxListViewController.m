//
//  JukeboxListViewController.m
//  YTBrowser
//
//  Created by Matan Vardi on 7/19/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

#import "JukeboxListViewController.h"
#import "AppConstant.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>

#define TOTAL_IMAGES           28
#define IPHONE_INITIAL_IMAGES  28
#define IPAD_INITIAL_IMAGES    11

#define ROW_SIZE               (CGSize){375, 180}

#define IPHONE_PORTRAIT_PHOTO  (CGSize){self.view.frame.size.width, 100}
#define IPHONE_PORTRAIT_CELL  (CGSize){self.view.frame.size.width, 100}
#define IPHONE_LANDSCAPE_PHOTO (CGSize){152, 152}

#define IPHONE_PORTRAIT_GRID   (CGSize){375, 180}
#define IPHONE_LANDSCAPE_GRID  (CGSize){160, 0}
#define IPHONE_TABLES_GRID     (CGSize){375, 180}

#define IPAD_PORTRAIT_PHOTO    (CGSize){128, 128}
#define IPAD_LANDSCAPE_PHOTO   (CGSize){122, 122}

#define IPAD_PORTRAIT_GRID     (CGSize){136, 0}
#define IPAD_LANDSCAPE_GRID    (CGSize){390, 0}
#define IPAD_TABLES_GRID       (CGSize){624, 0}

#define HEADER_FONT            [UIFont fontWithName:@"HelveticaNeue" size:18]

@implementation JukeboxListViewController {
    MGBox *photosGrid, *tablesGrid;
    UIImage *arrow;
    BOOL phone;
    MGScrollView *scroller;
    UILabel *titleLabel;
    UIView *playerBar;
    BOOL animateOnce;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.size.width/2 -30.0, 0.0, 60.0, 44.0)];
    titleLabel.text = @"JUKEBOXES";
    titleLabel.textColor = [[UINavigationBar appearance] tintColor];
    
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
    self.navigationItem.titleView = titleLabel;

    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"menu" ] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"location" ] style:UIBarButtonItemStylePlain target:self action:nil];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
    scroller = [MGScrollView scrollerWithSize:self.view.size];
    //setup the scroll view
    scroller.contentLayoutMode = MGLayoutGridStyle;
    scroller.frame = CGRectMake(0.0, 0.0, self.view.size.width, self.view.size.height - 45 );
    scroller.sizingMode = MGResizingShrinkWrap;
    scroller.bottomPadding = 0;
    
    scroller.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scroller];
    
    // iPhone or iPad?
    UIDevice *device = UIDevice.currentDevice;
    phone = device.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    
    // i'll be using this a lot
    arrow = [UIImage imageNamed:@"arrow"];
    
    // setup the main scroller (using a grid layout)
    scroller.contentLayoutMode = MGLayoutGridStyle;
    scroller.bottomPadding = 8;
    
    // iPhone or iPad grid?
    CGSize photosGridSize = CGSizeMake(self.view.frame.size.width,0);
    
    // the photos grid
    photosGrid = [MGBox boxWithSize:photosGridSize];
    photosGrid.contentLayoutMode = MGLayoutGridStyle;
    [scroller.boxes addObject:photosGrid];
    //[photosGrid layout];
    
    // the tables grid
    CGSize tablesGridSize = phone ? IPHONE_TABLES_GRID : IPAD_TABLES_GRID;
    tablesGrid = [MGBox boxWithSize:tablesGridSize];
    
    tablesGrid.contentLayoutMode = MGLayoutGridStyle;
    [scroller.boxes addObject:tablesGrid];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Jukeboxes"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            [self createJukeboxListView:objects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
/*
    // add photo boxes to the grid
    int initialImages = phone ? IPHONE_INITIAL_IMAGES : IPAD_INITIAL_IMAGES;
    for (int i = 1; i <= initialImages; i++) {
        int photo = [self randomMissingPhoto];
        [photosGrid.boxes addObject:[self photoBoxFor:photo]];
    }
    animateOnce = YES;

    [tablesGrid layout];*/
    
    

}
-(void) createJukeboxListView: (NSArray *) jukeboxes {
    for (PFObject *j in jukeboxes){
        JukeboxEntry *entry = [[JukeboxEntry alloc] init];
        [entry setTitle:j[@"name"]];
        [entry setAuthor:j[@"username"]];
        [entry setImageURL:j[@"image"]];
        [entry setCurrentlyPlaying:j[@"currentlyPlaying"]];
        [photosGrid.boxes addObject:[self photoBoxFor:entry]];
    }
    animateOnce = YES;
    [photosGrid layout];
    [tablesGrid layout];
    
    //Animate table view rows
    if(animateOnce){
        for(int i = 0; i <[photosGrid.boxes count]; i++){
            CGFloat tableHeight = scroller.frame.size.height;
            MGBox *box =[photosGrid.boxes objectAtIndex:i];
            box.transform = CGAffineTransformMakeTranslation(0, tableHeight);
        }
        
        for (int i = 0; i < [photosGrid.boxes count]; i++){
            // fade the image in
            [UIView animateWithDuration:1.5 delay:(0.05 * i) usingSpringWithDamping:.8 initialSpringVelocity:0 options:nil animations:^{
                MGBox *box = [photosGrid.boxes objectAtIndex:i];
                box.transform = CGAffineTransformMakeTranslation(0, 0);
            } completion:nil];
        }
        
        animateOnce = NO;
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation
                                           duration:1];
    [self didRotateFromInterfaceOrientation:UIInterfaceOrientationPortrait];

}

#pragma mark - Rotation and resizing

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orient
                                         duration:(NSTimeInterval)duration {
    
    BOOL portrait = UIInterfaceOrientationIsPortrait(orient);
    
    // grid size
    photosGrid.size = phone ? portrait
    ? IPHONE_PORTRAIT_GRID
    : IPHONE_LANDSCAPE_GRID : portrait
    ? IPAD_PORTRAIT_GRID
    : IPAD_LANDSCAPE_GRID;
    
    // photo sizes
    CGSize size = phone
    ? portrait ? IPHONE_PORTRAIT_PHOTO : IPHONE_LANDSCAPE_PHOTO
    : portrait ? IPAD_PORTRAIT_PHOTO : IPAD_LANDSCAPE_PHOTO;
    
    // apply to each photo
    for (MGBox *photo in photosGrid.boxes) {
        photo.size = size;
        photo.layer.shadowPath
        = [UIBezierPath bezierPathWithRect:photo.bounds].CGPath;
        photo.layer.shadowOpacity = 0;
    }
    
    // relayout the sections
    [scroller layoutWithSpeed:duration completion:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orient {
    for (MGBox *photo in photosGrid.boxes) {
        photo.layer.shadowOpacity = 0;
    }
}

#pragma mark - Photo Box factories

- (CGSize)photoBoxSize {
    BOOL portrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    
    // what size plz?
    return (CGSize){self.view.frame.size.width/2 - 2, self.view.frame.size.width/2 + 60};
    /*return phone
    ? portrait ? IPHONE_PORTRAIT_CELL : IPHONE_LANDSCAPE_PHOTO
    : portrait ? IPAD_PORTRAIT_PHOTO : IPAD_LANDSCAPE_PHOTO;*/
}

- (MGBox *)photoBoxFor:(JukeboxEntry *) entry {
    
    // make the photo box
    JukeBoxCell *box = [JukeBoxCell photoBoxFor:entry size:IPHONE_PORTRAIT_CELL];
       
    // remove the box when tapped
    __block id bbox = box;
    box.onTap = ^{
        /*MGBox *section = (id)box.parentBox;
        
        // remove
        [section.boxes removeObject:bbox];
        
        // if we don't have an add box, and there's photos left, add one
        if (![self photoBoxWithTag:-1] && [self randomMissingPhoto]) {
            [section.boxes addObject:self.photoAddBox];
        }
        
        // animate
        [section layoutWithSpeed:0.3 completion:nil];
        [scroller layoutWithSpeed:0.3 completion:nil];*/
        JukeboxPostViewController *jukeboxPost = [[JukeboxPostViewController alloc] initWithJukeBox:box.jukeBoxEntry];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:jukeboxPost];
        [self presentViewController:navigationController animated:YES completion:nil];
    };
    
    
    
    
    return box;
}


#pragma mark - Photo Box helpers

- (int)randomMissingPhoto {
    int photo;
    id existing;
    
    do {
        if (self.allPhotosLoaded) {
            return 0;
        }
        photo = arc4random_uniform(TOTAL_IMAGES) + 1;
        existing = [self photoBoxWithTag:photo];
    } while (existing);
    
    return photo;
}

- (MGBox *)photoBoxWithTag:(int)tag {
    for (MGBox *box in photosGrid.boxes) {
        if (box.tag == tag) {
            return box;
        }
    }
    return nil;
}

- (BOOL)allPhotosLoaded {
    return photosGrid.boxes.count == TOTAL_IMAGES && ![self photoBoxWithTag:-1];
}

-(void) displayDetailedPlayer {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[MediaManager sharedInstance] getVideoPlayerViewController]];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //setup music player at bottom of screen
    playerBar = [[MediaManager sharedInstance] getMiniPlayer];
    if(![PFUser currentUser]){
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
        [self presentViewController:navController animated:NO completion:nil];
        
    }
    
    UITapGestureRecognizer *playerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayDetailedPlayer)];
    [playerBar addGestureRecognizer:playerTap];
    
    [self.view addSubview:playerBar];
    if(playerBar.isHidden){
        scroller.frame = (CGRect){0,0,self.view.frame.size.width, self.view.frame.size.height};
    } else {
        scroller.frame = (CGRect){0,0,self.view.frame.size.width, self.view.frame.size.height-44};
        
    }
    

    
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

-(void)viewWillDisappear {
    [playerBar removeFromSuperview];
}


@end