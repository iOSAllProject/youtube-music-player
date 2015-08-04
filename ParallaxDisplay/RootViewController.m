//
//  RootViewController.m
//  SecretTestApp
//
//  Created by Aaron Pang on 3/28/14.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import "RootViewController.h"
#import "UIImage+ImageEffects.h"
#import "ToolBarView.h"
#import "UIFont+SecretFont.h"
#import "CommentCell.h"
#import "UIView+GradientMask.h"
#import "MediaManager.h"
#import "JukeboxEntry.h"
#import "MGScrollView.h"
#import <QuartzCore/QuartzCore.h>
#import "VoteCell.h"
#import "LibraryViewController.h"
#import "Song.h"

#define HEADER_HEIGHT 320.0f
#define HEADER_INIT_FRAME CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)
#define TITLE_INIT_FRAME CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width/4, 0, self.view.frame.size.width/2, 44.0f)
#define TOOLBAR_INIT_FRAME CGRectMake (0, 292, 320, 22)

const CGFloat kBarHeight = 44.0f;
const CGFloat kBackgroundParallexFactor = 0.5f;
const CGFloat kBlurFadeInFactor = 0.005f;
const CGFloat kTextFadeOutFactor = 0.05f;
const CGFloat kCommentCellHeight = 50.0f;

@interface RootViewController () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation RootViewController {
    UIScrollView *_mainScrollView;
    UIScrollView *_backgroundScrollView;
    UIImageView *_blurImageView;
    UILabel *_textLabel;
    ToolBarView *_toolBarView;
    UIView *_commentsViewContainer;
    UITableView *_commentsTableView;
    JukeboxEntry *jukeboxEntry;
    MGScrollView *_scroller;
    UIView *playerBar;
    UILabel *titleLabel;
    // TODO: Implement these
    UIGestureRecognizer *_leftSwipeGestureRecognizer;
    UIGestureRecognizer *_rightSwipeGestureRecognizer;
    CGFloat listViewHeight;
    
    NSMutableArray *comments;
}

- (id)initWithJukeBox: (JukeboxEntry*) entry {
    self = [super init];
    if (self) {
        jukeboxEntry = entry;
        _mainScrollView = [[UIScrollView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
        _mainScrollView.delegate = self;
        _mainScrollView.bounces = YES;
        _mainScrollView.alwaysBounceVertical = YES;
        _mainScrollView.contentSize = CGSizeZero;
        _mainScrollView.showsVerticalScrollIndicator = YES;
        _mainScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(kBarHeight, 0, 0, 0);
        _mainScrollView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_mainScrollView];
        
        _backgroundScrollView = [[UIScrollView alloc] initWithFrame:HEADER_INIT_FRAME];
        _backgroundScrollView.scrollEnabled = NO;
        _backgroundScrollView.contentSize = CGSizeMake(320, 1000);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:HEADER_INIT_FRAME];
        imageView.image = jukeboxEntry.image;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UIView *fadeView = [[UIView alloc] initWithFrame:imageView.frame];
        fadeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
        fadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        titleLabel = [[UILabel alloc] initWithFrame:TITLE_INIT_FRAME];
        titleLabel.text = @"Jukebox Title";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:titleLabel];
        
        _textLabel = [[UILabel alloc] initWithFrame:HEADER_INIT_FRAME];
        [_textLabel setText:@"Jukebox Title"];
        [_textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f]];
        [_textLabel setTextAlignment:NSTextAlignmentCenter];
        [_textLabel setTextColor:[UIColor whiteColor]];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _textLabel.layer.shadowRadius = 10.0f;
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        
        
        
        _toolBarView = [[ToolBarView alloc] initWithFrame:TOOLBAR_INIT_FRAME];
        _toolBarView.autoresizingMask =   UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
        [_backgroundScrollView addSubview:imageView];
        [_backgroundScrollView addSubview:fadeView];
        //[_backgroundScrollView addSubview:_toolBarView];
        [_backgroundScrollView addSubview:_textLabel];
        
        // Take a snapshot of the background scroll view and apply a blur to that image
        // Then add the blurred image on top of the regular image and slowly fade it in
        // in scrollViewDidScroll
        UIGraphicsBeginImageContextWithOptions(_backgroundScrollView.bounds.size, _backgroundScrollView.opaque, 0.0);
        [_backgroundScrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _blurImageView = [[UIImageView alloc] initWithFrame:HEADER_INIT_FRAME];
        _blurImageView.image = [img applyBlurWithRadius:12 tintColor:[UIColor colorWithWhite:0.8 alpha:0.4] saturationDeltaFactor:1.8 maskImage:nil];
        _blurImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blurImageView.alpha = 0;
        _blurImageView.backgroundColor = [UIColor clearColor];
        [_backgroundScrollView addSubview:_blurImageView];
 
        
        listViewHeight = CGRectGetHeight(self.view.frame) - kBarHeight;
        _commentsViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_backgroundScrollView.frame), CGRectGetWidth(self.view.frame),listViewHeight )];
        [_commentsViewContainer addGradientMaskWithStartPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 0.03)];
        
        _scroller = [MGScrollView scrollerWithSize:self.view.size];
        //setup the scroll view
        _scroller.contentLayoutMode = MGLayoutGridStyle;
        _scroller.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame),listViewHeight);
        _scroller.sizingMode = MGResizingShrinkWrap;
        _scroller.bottomPadding = 0;
        
        _scroller.backgroundColor = [UIColor whiteColor];
        [_commentsViewContainer addSubview:_scroller];
        [self setupLibraryView];
        /*
        _commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - kBarHeight ) style:UITableViewStylePlain];
        _commentsTableView.scrollEnabled = NO;
        _commentsTableView.delegate = self;
        _commentsTableView.dataSource = self;
        _commentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _commentsTableView.separatorColor = [UIColor clearColor];
        */
        [_mainScrollView addSubview:_backgroundScrollView];
      //  [_commentsViewContainer addSubview:_commentsTableView];
        [_mainScrollView addSubview:_commentsViewContainer];
        
        // Let's put in some fake data!
        comments = [@[@"Oh my god! Me too!", @"No way! I love secrets too!", @"I for some reason really like sharing my deepest darkest secrest to the entire world", @"More comments", @"Go Toronto Blue Jays!", @"I rather use Twitter", @"I don't get Secret", @"I don't have an iPhone", @"How are you using this then?"] mutableCopy];
        [_toolBarView setNumberOfComments:[comments count]];
        
        UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 25.0, 25.0)];
        [dismissButton addTarget:self
                          action:@selector(done)
                forControlEvents:UIControlEventTouchUpInside];
        [dismissButton setBackgroundImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
        [self.view addSubview: dismissButton];
        
        UIButton *queue = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-10-20, 10, 20.0, 20.0)];
        [queue setBackgroundImage:[UIImage imageNamed:@"queue"] forState:UIControlStateNormal];
        [self.view addSubview:queue];
        
    }
    return self;
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
    if([_scroller.boxes count] > 0)
        [_scroller.boxes removeObjectsInRange:NSMakeRange(0, _scroller.boxes.count)];
    self.currentLibrary = [[NSMutableArray alloc] init];
    int counter = 0;
    BOOL drawLine = YES;
    int i = 1;
    for (Song *song in _fetchedResultsController.fetchedObjects){
        //get the data
        VideoModel *video = [LibraryViewController createVideo:song];
        [self.currentLibrary addObject:video];
        if(counter == [_fetchedResultsController.fetchedObjects count] -1)
            drawLine = NO;
        //create a box
        VoteCell *box = [VoteCell photoBoxForVideo:video withSize:CGSizeMake(self.view.frame.size.width-20,85) withLine:drawLine atIndex:i++];
        
        box.frame = CGRectIntegral(box.frame);
        box.onTap = ^{
            [[MediaManager sharedInstance] setPlaylist:self.currentLibrary andSongIndex:counter];
            [[MediaManager sharedInstance] playWithVideo:video];
        };
        counter++;
        //add the box
        [_scroller.boxes addObject:box];
    }
    [_scroller layout];
    [[MediaManager sharedInstance] setCurrentLibrary:self.currentLibrary];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat delta = 0.0f;
    CGRect rect = HEADER_INIT_FRAME;
    CGRect toolbarRect = TOOLBAR_INIT_FRAME;
    // Here is where I do the "Zooming" image and the quick fade out the text and toolbar
    if (scrollView.contentOffset.y < 0.0f) {
        delta = fabs(MIN(0.0f, _mainScrollView.contentOffset.y));
        _backgroundScrollView.frame = CGRectMake(CGRectGetMinX(rect) - delta / 2.0f, CGRectGetMinY(rect) - delta, CGRectGetWidth(rect) + delta, CGRectGetHeight(rect) + delta);
        _textLabel.alpha = MIN(1.0f, 1.0f - delta * kTextFadeOutFactor);
        _toolBarView.alpha = _textLabel.alpha;
        _toolBarView.frame = CGRectMake(CGRectGetMinX(toolbarRect) + delta / 2.0f, CGRectGetMinY(toolbarRect) + delta, CGRectGetWidth(toolbarRect), CGRectGetHeight(toolbarRect));
        [_scroller setContentOffset:(CGPoint){0,0} animated:NO];
        titleLabel.alpha = 0.0;
        if(scrollView.contentOffset.y < -128){
            [self done];
        }
    } else {
        delta = _mainScrollView.contentOffset.y;
        CGFloat playerBarOffset = 0;//playerBar.isHidden ? 0 : 44;
        _textLabel.alpha = 1.0f;
        _toolBarView.alpha = _textLabel.alpha;
        _blurImageView.alpha = MIN(1 , delta * kBlurFadeInFactor);
        _toolBarView.frame = TOOLBAR_INIT_FRAME;
        CGFloat backgroundScrollViewLimit = _backgroundScrollView.frame.size.height - kBarHeight;
        // Here I check whether or not the user has scrolled passed the limit where I want to stick the header, if they have then I move the frame with the scroll view
        // to give it the sticky header look
        if (delta > backgroundScrollViewLimit) {
            _backgroundScrollView.frame = (CGRect) {.origin = {0, delta - _backgroundScrollView.frame.size.height + kBarHeight -playerBarOffset}, .size = {self.view.frame.size.width, HEADER_HEIGHT}};
            _commentsViewContainer.frame = (CGRect){.origin = {0, CGRectGetMinY(_backgroundScrollView.frame) + CGRectGetHeight(_backgroundScrollView.frame)}, .size = _commentsViewContainer.frame.size };
            _scroller.contentOffset = CGPointMake (0, delta - backgroundScrollViewLimit);
            CGFloat contentOffsetY = -backgroundScrollViewLimit * kBackgroundParallexFactor;
            [_backgroundScrollView setContentOffset:(CGPoint){0,contentOffsetY} animated:NO];
            titleLabel.alpha = 1;
        }
        else {
            _backgroundScrollView.frame = rect;
            _commentsViewContainer.frame = (CGRect){.origin = {0, CGRectGetMinY(rect) + CGRectGetHeight(rect)}, .size = _commentsViewContainer.frame.size };
            [_scroller setContentOffset:(CGPoint){0,0} animated:NO];
            [_backgroundScrollView setContentOffset:CGPointMake(0, -delta * kBackgroundParallexFactor)animated:NO];
            titleLabel.alpha = 0.0;
        }
        
    }
}

#pragma mark

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [comments objectAtIndex:[indexPath row]];
    CGSize requiredSize;
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        CGRect rect = [text boundingRectWithSize:(CGSize){225, MAXFLOAT}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont secretFontLightWithSize:16.f]}
                                                   context:nil];
        requiredSize = rect.size;
    } else {
        requiredSize = [text sizeWithFont:[UIFont secretFontLightWithSize:16.f] constrainedToSize:(CGSize){225, MAXFLOAT} lineBreakMode:NSLineBreakByWordWrapping];
    }
    return kCommentCellHeight + requiredSize.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Cell %d", indexPath.row]];
    if (!cell) {
        cell = [[CommentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"Cell %d", indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.commentLabel.frame = (CGRect) {.origin = cell.commentLabel.frame.origin, .size = {CGRectGetMinX(cell.likeButton.frame) - CGRectGetMaxY(cell.iconView.frame) - kCommentPaddingFromLeft - kCommentPaddingFromRight,[self tableView:tableView heightForRowAtIndexPath:indexPath] - kCommentCellHeight}};
        cell.commentLabel.text = comments[indexPath.row];
        cell.timeLabel.frame = (CGRect) {.origin = {CGRectGetMinX(cell.commentLabel.frame), CGRectGetMaxY(cell.commentLabel.frame)}};
        cell.timeLabel.text = @"1d ago";
        [cell.timeLabel sizeToFit];
        
        // Don't judge my magic numbers or my crappy assets!!!
        cell.likeCountImageView.frame = CGRectMake(CGRectGetMaxX(cell.timeLabel.frame) + 7, CGRectGetMinY(cell.timeLabel.frame) + 3, 10, 10);
        cell.likeCountImageView.image = [UIImage imageNamed:@"like_greyIcon.png"];
        cell.likeCountLabel.frame = CGRectMake(CGRectGetMaxX(cell.likeCountImageView.frame) + 3, CGRectGetMinY(cell.timeLabel.frame), 0, CGRectGetHeight(cell.timeLabel.frame));
    }

    return cell;
}


- (void)viewDidAppear:(BOOL)animated {
    _mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), _scroller.contentSize.height + CGRectGetHeight(_backgroundScrollView.frame));
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


-(void) displayDetailedPlayer {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[MediaManager sharedInstance] getVideoPlayerViewController]];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}


-(void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
- (BOOL)prefersStatusBarHidden {
    return YES;
}
-(void)done{
    [[MediaManager sharedInstance] runInBackground];
    [self dismissViewControllerAnimated:YES completion:nil];
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
