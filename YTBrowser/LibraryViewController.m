
#import "LibraryViewController.h"

@interface LibraryViewController ()
{
    MGScrollView* scroller;
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation LibraryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat navBarPadding = self.navigationController.navigationBar.frame.size.height+20;
    // Do any additional setup after loading the view, typically from a nib.
    scroller = [MGScrollView scrollerWithSize:self.view.size];
    //setup the scroll view
    scroller.contentLayoutMode = MGLayoutGridStyle;
    scroller.frame = CGRectMake(0.0, 0.0, self.view.size.width, self.view.size.height - 100.0 - 40.0 );
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
    NSLog(@"%d", numRows);
    
    [self showLibrary];
    //re-layout the scroll view
    
    
}
-(void) showLibrary {
    int counter = 0;
    BOOL drawLine = YES;
    for (Song *song in _fetchedResultsController.fetchedObjects){
        //get the data
        VideoModel *video = [self createVideo:song];
        counter++;
        if(counter == [_fetchedResultsController.fetchedObjects count])
            drawLine = NO;
        //create a box
        PhotoBox *box = [PhotoBox photoBoxForVideo:video withSize:CGSizeMake(self.view.frame.size.width-20,80) withLine:drawLine];
        box.frame = CGRectIntegral(box.frame);
        box.onTap = ^{
            [[MediaManager sharedInstance] playWithVideo:video];
            
        };
        
        //add the box
        [scroller.boxes addObject:box];
        [scroller layout];
    }
    
}

-(VideoModel *) createVideo:(Song*) song {
    VideoModel *video = [[VideoModel alloc] init];
    video.title = song.title;
    video.videoId = song.videoId;
    video.thumbnail = song.url;
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
@end