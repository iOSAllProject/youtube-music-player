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
#import <INTULocationManager/INTULocationManager.h>
#import "MapPin.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
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
    MKMapView *mapView;
    UILabel *titleLabel;
    UIView *playerBar;
    BOOL animateOnce;
    BOOL list;
    CLLocationManager *locationManager;
    NSMutableArray *_jukeboxes;
    NSMutableArray *_jukeboxCells;
    JukeBoxCell *mapCell;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    list = true;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.size.width/2 -30.0, 0.0, 60.0, 44.0)];
    titleLabel.text = @"JUKEBOXES";
    titleLabel.textColor = [[UINavigationBar appearance] tintColor];
    
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
    self.navigationItem.titleView = titleLabel;

    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"menu" ] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"location" ] style:UIBarButtonItemStylePlain target:self action:@selector(presentMapView)];
    
    //setup mapview
    mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    mapView.delegate = self;
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
    scroller = [MGScrollView scrollerWithSize:self.view.size];
    //setup the scroll view
    scroller.contentLayoutMode = MGLayoutGridStyle;
    scroller.frame = CGRectMake(0.0, 0.0, self.view.size.width, self.view.size.height - 45 );
    scroller.sizingMode = MGResizingShrinkWrap;
    scroller.bottomPadding = 0;
    
    scroller.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scroller];
    [self.view addSubview:mapView];
    [mapView setHidden:YES];
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
                NSLog(@"Successfully retrieved %d jukeboxes.", objects.count);
                // Do something with the found objects
                [self createJukeboxListView:objects];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    

    
    

}

-(void) createJukeboxListView: (NSArray *) jukeboxes {
    _jukeboxes = [[NSMutableArray alloc] init];
    _jukeboxCells = [[NSMutableArray alloc] init];
    for (PFObject *j in jukeboxes){
        JukeboxEntry *entry = [[JukeboxEntry alloc] init];
        [entry setTitle:j[@"name"]];
        [entry setAuthor:j[@"username"]];
        [entry setImageURL:j[@"image"]];
        [entry setCurrentlyPlaying:j[@"currentlyPlaying"]];
        [entry setObjectId:j.objectId];
        PFGeoPoint *gp = j[@"location"];
        if(gp){
            entry.location = CLLocationCoordinate2DMake(gp.latitude, gp.longitude);
        }
        JukeBoxCell *cell = [self photoBoxFor:entry];
        [photosGrid.boxes addObject:cell];
        [_jukeboxes addObject:entry];
        [_jukeboxCells addObject: cell];
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
    
    //Create map view with jukeboxes
    [self setupLocationManager];
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

- (JukeBoxCell *)photoBoxFor:(JukeboxEntry *) entry {
    
    // make the photo box
    JukeBoxCell *box = [JukeBoxCell photoBoxFor:entry size:IPHONE_PORTRAIT_CELL];
       
    // remove the box when tapped
    __block id bbox = box;
    box.onTap = ^{
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
        [mapCell setY:mapView.frame.size.height-100];
    } else {
        scroller.frame = (CGRect){0,0,self.view.frame.size.width, self.view.frame.size.height-44};
        [mapCell setY:mapView.frame.size.height-100-44];
        
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


-(void) setupLocationManager {
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                       timeout:10.0
                          delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             if (status == INTULocationStatusSuccess) {
                                                 // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                 // currentLocation contains the device's current location.
                                                 MKCoordinateRegion region;
                                                 MKCoordinateSpan span;
                                                 
                                                 

                                                 CLLocationCoordinate2D location;
                                                 location.latitude = currentLocation.coordinate.latitude;
                                                 location.longitude = currentLocation.coordinate.longitude;
                                                 region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000);
                                                 
                                                 
                                                // [mapView setRegion:region animated:YES];
                                                 mapView.showsBuildings = true;
                                                 mapView.mapType = MKMapTypeStandard;
                                                 MKMapCamera *mapCamera = [[MKMapCamera alloc] init];
                                                 mapCamera.centerCoordinate = location;
                                                 mapCamera.pitch = 45;
                                                 mapCamera.altitude = 40000;
                                                 mapCamera.heading = 45;
                                                 mapView.region = region;
                                                 mapView.camera = mapCamera;
                                                 
                                                 [self addJukeboxesToMap];
                                             }
                                             else if (status == INTULocationStatusTimedOut) {
                                                 // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                 // However, currentLocation contains the best location available (if any) as of right now,
                                                 // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                             }
                                             else {
                                                 // An error occurred, more info is available by looking at the specific status returned.
                                             }
                                         }];

    
}

-(void) addJukeboxesToMap {
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    for (JukeboxEntry* j in _jukeboxes){
        CLLocationCoordinate2D centralParkLoc;

        //create a location pin for central park
        MapPin *locationPin = [[MapPin alloc] init];
        
        locationPin.coordinate = j.location;
        locationPin.title = j.title;
        locationPin.subtitle = j.author;
        locationPin.objectId = j.objectId;
        

        
        [locations addObject:locationPin];
    }

    [mapView addAnnotations:locations];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MapPin *a = ((MapPin *)view.annotation);
    NSString *id = a.objectId;
    /*for (JukeBoxCell *jc in _jukeboxCells){
        if(jc.jukeBoxEntry.objectId == id){
            //insert the jukebox cell at bottom of screen
            CGFloat *bottomOffset = 0;
            if(![playerBar isHidden])
                bottomOffset = 44;
            
            
        }
    }*/
    for (JukeboxEntry *j in _jukeboxes){
        
        
        if(j.objectId == id){
            CGFloat bottomOffset = 0.00;
            if(![playerBar isHidden])
                bottomOffset = 44.0;
            if(mapCell){
                [mapCell removeFromSuperview ];
            }
            mapCell = [self photoBoxFor:j];
            mapCell.frame = CGRectMake(0,mapView.frame.size.height - 100 -bottomOffset, mapCell.frame.size.width, mapCell.frame.size.height);
            [self.view addSubview: mapCell];
            /*JukeboxPostViewController *jukeboxPost = [[JukeboxPostViewController alloc] initWithJukeBox:j];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:jukeboxPost];
            [self presentViewController:navigationController animated:YES completion:nil];*/
        }
    }
    
    
    
    //[self performSegueWithIdentifier:@"DetailsIphone" sender:view];
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000, 1000);
    [mapView setRegion:[mapView regionThatFits:region] animated:YES];
}
-(void) presentMapView{
    if(list == true){
        [scroller setHidden: YES];
        [mapView setHidden: NO];
        [mapCell setHidden:NO];
        list = false;
    }else{
        [scroller setHidden: NO];
        [mapView setHidden: YES];
        [mapCell setHidden:YES];
        if([playerBar isHidden]){
            [mapCell setY:mapView.frame.size.height-100];
        } else{
            [mapCell setY:mapView.frame.size.height-100-44];
        }
        list = true;
    }
    
}
@end