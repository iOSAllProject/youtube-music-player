
#import "LibraryViewController.h"
#import "AppConstant.h"
#import <Parse/Parse.h>
@interface LibraryViewController ()
{
    MGScrollView* scroller;
    UILabel *titleLabel;
    UIView *playerBar;
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *currentLibrary;
@end

@implementation LibraryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.size.width/2 -30.0, 0.0, 60.0, 44.0)];
    titleLabel.text = @"MY MUSIC";
    titleLabel.textColor = [[UINavigationBar appearance] tintColor];
    
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
    self.navigationItem.titleView = titleLabel;
    

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"menu" ] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:nil];
    
    CGFloat navBarPadding = self.navigationController.navigationBar.frame.size.height+20;
    // Do any additional setup after loading the view, typically from a nib.
    scroller = [MGScrollView scrollerWithSize:self.view.size];
    //setup the scroll view
    scroller.contentLayoutMode = MGLayoutGridStyle;
    scroller.frame = CGRectMake(0.0, 0.0, self.view.size.width, self.view.size.height  );
    scroller.sizingMode = MGResizingShrinkWrap;
    scroller.bottomPadding = 0;
    
    scroller.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scroller];
    [self setupLibraryView];
    
}

-(void) setupLibraryView {
    [self fetchedResultsController];
    [_fetchedResultsController performFetch:nil];
    
    //TODO DEBUGGING
    NSInteger *numRows = [_fetchedResultsController.fetchedObjects count];
    
    [self showLibrary];
    //re-layout the scroll view
    
    
}

-(void) showLibrary {
    //clean the old videos
    if([scroller.boxes count] > 0)
        [scroller.boxes removeObjectsInRange:NSMakeRange(0, scroller.boxes.count)];
    self.currentLibrary = [[NSMutableArray alloc] init];
    NSInteger counter = 0;
    BOOL drawLine = YES;
    for (Song *song in _fetchedResultsController.fetchedObjects){
        //get the data
        VideoModel *video = [LibraryViewController createVideo:song];
        [self.currentLibrary addObject:video];
        if(counter == [_fetchedResultsController.fetchedObjects count] -1)
            drawLine = NO;
        //create a box
        SongCell *box = [SongCell photoBoxForVideo:video withSize:CGSizeMake(self.view.frame.size.width-20,65) withLine:drawLine];
        box.frame = CGRectIntegral(box.frame);
        box.onTap = ^{
            if(playerBar.isHidden){
                scroller.frame = (CGRect){0,0,self.view.frame.size.width, self.view.frame.size.height-44};
                playerBar.hidden= NO;
            }
            [[MediaManager sharedInstance] setCurrentJukebox: nil];
            [[MediaManager sharedInstance] setPlaylist:self.currentLibrary andSongIndex:counter];
            [[MediaManager sharedInstance] playWithVideo:video];
           
            
        };
        counter++;
        
        //add the box
        [scroller.boxes addObject:box];
    }
    [scroller layout];
    
}

+(VideoModel *) createVideo:(Song*) song {
    VideoModel *video = [[VideoModel alloc] init];
    video.title = song.title;
    video.videoId = song.videoId;
    video.thumbnail = song.url;
    return video;
}
+(VideoModel *) createVideoForParse:(PFObject *) song {
    
    VideoModel *video = [[VideoModel alloc] init];
    video.title = song[@"title"];
    video.videoId = song[@"vid"];
    video.thumbnail = song[@"thumbnail"];

    return video;
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


-(void) displayDetailedPlayer {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[MediaManager sharedInstance] getVideoPlayerViewController]];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //setup music player at bottom of screen
    playerBar = [[MediaManager sharedInstance] getMiniPlayer];
    
    UITapGestureRecognizer *playerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayDetailedPlayer)];
    [playerBar addGestureRecognizer:playerTap];
    if(playerBar.isHidden){
        scroller.frame = (CGRect){0,0,self.view.frame.size.width, self.view.frame.size.height};
    } else {
        scroller.frame = (CGRect){0,0,self.view.frame.size.width, self.view.frame.size.height-44};
        
    }
    [self.view addSubview:playerBar];
    

}
-(void)viewWillDisappear {
    [playerBar removeFromSuperview];
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

@end