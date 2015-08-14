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
#import "RMSaveButton.h"
#import "SearchYoutubeViewController.h"

#define HEADER_HEIGHT 320.0f
#define THUMB_SIZE 100.0f
#define HEADER_INIT_FRAME CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)
#define TOOLBAR_INIT_FRAME CGRectMake (0, 292, 320, 22)
#define THUMBNAIL_INIT_FRAME CGRectMake (self.view.frame.size.width/2 - THUMB_SIZE/2,HEADER_HEIGHT/3.5, THUMB_SIZE,THUMB_SIZE)
#define TITLE_INIT_FRAME CGRectMake(0, THUMBNAIL_INIT_FRAME.origin.y + THUMBNAIL_INIT_FRAME.size.height + 10, self.view.frame.size.width, 40.0)
#define USERNAME_INIT_FRAME CGRectMake(0, TITLE_INIT_FRAME.origin.y + TITLE_INIT_FRAME.size.height, self.view.frame.size.width, 20.0)
#define ADD_SONG_BUTTON_SIZE = CGSizeMake(140,50)
#define ADD_SONG_INIT_FRAME CGRectMake(self.view.frame.size.width/2 - 70,HEADER_HEIGHT-25,140,50)
const CGFloat kBarHeight = 88.0f;
const CGFloat kBackgroundParallexFactor = 0.95f;
const CGFloat kBlurFadeInFactor = 0.05f;
const CGFloat kTextFadeOutFactor = 0.007f;
const CGFloat kCommentCellHeight = 50.0f;

@interface RootViewController () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation RootViewController {
    UIScrollView *_mainScrollView;
    UIScrollView *_backgroundScrollView;
    UIImageView *_blurImageView;
    UILabel *_titleSmallLabel;
    UILabel *_textLabel;
    UILabel *_userLabel;
    UIView *_postContainer;
    UIImageView *_thumbImageView;
    ToolBarView *_toolBarView;
    UIView *_commentsViewContainer;
    UITableView *_commentsTableView;
    JukeboxEntry *jukeboxEntry;
    MGScrollView *_scroller;
    UIView *playerBar;
    UIButton *dismissButton;
    UIButton *queue;
    // TODO: Implement these
    UIGestureRecognizer *_leftSwipeGestureRecognizer;
    UIGestureRecognizer *_rightSwipeGestureRecognizer;
    CGFloat listViewHeight;
    RMSaveButton *_addButton;
    
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
        

        _postContainer = [[UIView alloc] initWithFrame:HEADER_INIT_FRAME];
        _postContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        _thumbImageView = [[UIImageView alloc] initWithFrame:THUMBNAIL_INIT_FRAME];
        _thumbImageView.image = jukeboxEntry.image;
        _thumbImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        _textLabel = [[UILabel alloc] initWithFrame:TITLE_INIT_FRAME];
        [_textLabel setText:@"Jukebox Title"];
        [_textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:22.0f]];
        [_textLabel setTextAlignment:NSTextAlignmentCenter];
        [_textLabel setTextColor:[UIColor whiteColor]];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _textLabel.layer.shadowRadius = 10.0f;
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        CGFloat smallTitleSize = self.view.size.width - 70;
        _titleSmallLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 25, smallTitleSize, 25)];
        _titleSmallLabel.text = @"Jukebox Title";
        [_titleSmallLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleSmallLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f]];
        _titleSmallLabel.backgroundColor = [UIColor clearColor];
        _titleSmallLabel.textColor = [UIColor whiteColor];
        _titleSmallLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _titleSmallLabel.layer.shadowRadius = 10.0f;
        _titleSmallLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        
        _userLabel = [[UILabel alloc] initWithFrame:USERNAME_INIT_FRAME];
        [_userLabel setText:@"Username"];
        [_userLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
        [_userLabel setTextAlignment:NSTextAlignmentCenter];
        [_userLabel setTextColor:[UIColor whiteColor]];
        _userLabel.backgroundColor = [UIColor clearColor];
        _userLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _userLabel.layer.shadowRadius = 10.0f;
        _userLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        _toolBarView = [[ToolBarView alloc] initWithFrame:TOOLBAR_INIT_FRAME];
        _toolBarView.autoresizingMask =   UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
        [_backgroundScrollView addSubview:imageView];
        [_backgroundScrollView addSubview:fadeView];
        //[_backgroundScrollView addSubview:_toolBarView];

        
        // Take a snapshot of the background scroll view and apply a blur to that image
        // Then add the blurred image on top of the regular image and slowly fade it in
        // in scrollViewDidScroll
        UIGraphicsBeginImageContextWithOptions(_backgroundScrollView.bounds.size, _backgroundScrollView.opaque, 0.0);
        [_backgroundScrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _blurImageView = [[UIImageView alloc] initWithFrame:HEADER_INIT_FRAME];
        _blurImageView.image = [img applyBlurWithRadius:12 tintColor:[UIColor colorWithWhite:0.8 alpha:0.0] saturationDeltaFactor:1.8 maskImage:nil];
        _blurImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blurImageView.alpha = 0;
        _blurImageView.backgroundColor = [UIColor clearColor];
        [_backgroundScrollView addSubview:_postContainer];
        [_postContainer addSubview:_blurImageView];
         [_postContainer addSubview:_textLabel];
        [_postContainer addSubview:_userLabel];
        [_postContainer addSubview:_thumbImageView];
        
        
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
        [_commentsViewContainer addSubview:_commentsTableView];
        [_mainScrollView addSubview:_commentsViewContainer];
        [self.view addSubview:_titleSmallLabel];
        // Let's put in some fake data!
        comments = [@[@"Oh my god! Me too!", @"No way! I love secrets too!", @"I for some reason really like sharing my deepest darkest secrest to the entire world", @"More comments", @"Go Toronto Blue Jays!", @"I rather use Twitter", @"I don't get Secret", @"I don't have an iPhone", @"How are you using this then?"] mutableCopy];
        [_toolBarView setNumberOfComments:[comments count]];
        
        
        _addButton = [[RMSaveButton alloc] initWithFrame: ADD_SONG_INIT_FRAME];
        _addButton.label = @"Queue Song";
        [_mainScrollView addSubview:_addButton];
        _addButton.startHandler = ^void() { [self searchForSong]; };
        _addButton.interruptHandler = ^void() {};
        _addButton.completionHandler = ^void() {};
        
        
        dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 25.0, 25.0)];
        [dismissButton addTarget:self
                          action:@selector(done)
                forControlEvents:UIControlEventTouchUpInside];
        [dismissButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [self.view addSubview: dismissButton];
        
        queue = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-10-25, 20, 25.0, 25.0)];
        [queue setBackgroundImage:[UIImage imageNamed:@"more_juke"] forState:UIControlStateNormal];
        [self.view addSubview:queue];
        
    }
    return self;
}

-(void) searchForSong {
    SearchYoutubeViewController *searchViewController = [[SearchYoutubeViewController alloc] initForJukeBoxSearch];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    [self presentViewController:navController animated:YES completion:nil];
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
    BOOL drawLine = NO;
    int i = 1;
    //create now playing label
    MGLine *layoutLine = [MGLine lineWithLeft:@"NOW PLAYING" right:nil
                                         size:(CGSize){self.view.frame.size.width, 44}];
    layoutLine.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    layoutLine.leftPadding = layoutLine.rightPadding = 16;
    [_scroller.boxes addObject:layoutLine];
    
    for (Song *song in _fetchedResultsController.fetchedObjects){
        if(counter == 0){
            drawLine = NO;
        }
        else if(counter == 1){
            MGLine *emptyLine = [MGLine lineWithSize:(CGSize){self.view.frame.size.width, 1}];
            [_scroller.boxes addObject:emptyLine];
            MGLine *layoutLine = [MGLine lineWithLeft:@"PLAY QUEUE" right:nil
                                                 size:(CGSize){self.view.frame.size.width, 44}];
            layoutLine.leftPadding = layoutLine.rightPadding = 16;
            layoutLine.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
            [_scroller.boxes addObject:layoutLine];
            drawLine = YES;
        }else if(counter == [_fetchedResultsController.fetchedObjects count] -1){
            drawLine = NO;
        } else {
            drawLine= YES;
        }

        //get the data
        VideoModel *video = [LibraryViewController createVideo:song];
        [self.currentLibrary addObject:video];

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
    CGRect thumbRect = THUMBNAIL_INIT_FRAME;
    CGRect titleRect = TITLE_INIT_FRAME;
    CGRect userRect = USERNAME_INIT_FRAME;
    _titleSmallLabel.alpha =0;
    // Here is where I do the "Zooming" image and the quick fade out the text and toolbar
    if (scrollView.contentOffset.y < 0.0f) {
        delta = fabs(MIN(0.0f, _mainScrollView.contentOffset.y));
        _backgroundScrollView.frame = CGRectMake(CGRectGetMinX(rect) - delta / 2.0f, CGRectGetMinY(rect) - delta, CGRectGetWidth(rect) + delta, CGRectGetHeight(rect) + delta);
        _toolBarView.frame = CGRectMake(CGRectGetMinX(toolbarRect) + delta / 2.0f, CGRectGetMinY(toolbarRect) + delta, CGRectGetWidth(toolbarRect), CGRectGetHeight(toolbarRect));

        [_scroller setContentOffset:(CGPoint){0,0} animated:NO];

      //  _blurImageView.alpha = MIN(1.0f, 1.0f - delta * kTextFadeOutFactor);
        
        if(delta < 32){
            _textLabel.alpha = 1.0f;
            _userLabel.alpha = 1.0f;
            queue.alpha = 1.0f;
            dismissButton.alpha = 1.0;
            _thumbImageView.alpha = 1.0f;
            _thumbImageView.frame = CGRectMake(CGRectGetMinX(thumbRect) + delta / 2.0f, CGRectGetMinY(thumbRect) + delta,CGRectGetWidth(thumbRect), CGRectGetHeight(thumbRect));
            _textLabel.frame = CGRectMake(CGRectGetMinX(titleRect) + delta / 2.0f, CGRectGetMinY(titleRect) + delta,CGRectGetWidth(titleRect), CGRectGetHeight(titleRect));
            _blurImageView.alpha = MIN(1 , 64+delta * kBlurFadeInFactor);
            _userLabel.frame =CGRectMake(CGRectGetMinX(userRect) + delta / 2.0f, CGRectGetMinY(userRect) + delta,CGRectGetWidth(userRect), CGRectGetHeight(userRect));
        } else {
            NSLog(@"scroll is: %f   delta is: %f ", _mainScrollView.contentOffset.y,delta);
                _blurImageView.alpha = MIN(1.0f, 1.0f - delta * kTextFadeOutFactor);
                _textLabel.alpha = MIN(1.0f, 1.0f - delta * kTextFadeOutFactor)/8;
                _toolBarView.alpha = _textLabel.alpha;
                _thumbImageView.alpha = _textLabel.alpha;
                _userLabel.alpha = _textLabel.alpha;

            
        }
        if(delta > 64){
            queue.alpha = _textLabel.alpha;
            dismissButton.alpha = _textLabel.alpha;
        }
    } else {
        delta = _mainScrollView.contentOffset.y;
        CGFloat playerBarOffset = 0;//playerBar.isHidden ? 0 : 44;
        _textLabel.alpha = 1.0f;
        _userLabel.alpha = 1.0f;
        _thumbImageView.alpha = 1.0f;
        _toolBarView.alpha = _textLabel.alpha;
        _blurImageView.alpha = MIN(1 , 1+delta * kBlurFadeInFactor);
        _toolBarView.frame = TOOLBAR_INIT_FRAME;
        CGFloat backgroundScrollViewLimit = _backgroundScrollView.frame.size.height - kBarHeight;
        // Here I check whether or not the user has scrolled passed the limit where I want to stick the header, if they have then I move the frame with the scroll view
        // to give it the sticky header look
        if (delta > backgroundScrollViewLimit) {
            _backgroundScrollView.frame = (CGRect) {.origin = {0, delta - _backgroundScrollView.frame.size.height + kBarHeight -playerBarOffset}, .size = {self.view.frame.size.width, HEADER_HEIGHT}};
            _commentsViewContainer.frame = (CGRect){.origin = {0, CGRectGetMinY(_backgroundScrollView.frame) + CGRectGetHeight(_backgroundScrollView.frame)}, .size = _commentsViewContainer.frame.size };
            
            _addButton.frame = (CGRect){.origin = {ADD_SONG_INIT_FRAME.origin.x, CGRectGetMinY(_backgroundScrollView.frame) + CGRectGetHeight(_backgroundScrollView.frame) - ADD_SONG_INIT_FRAME.size.height/2}, .size = _addButton.frame.size };
            
            _scroller.contentOffset = CGPointMake (0, delta - backgroundScrollViewLimit);
            CGFloat contentOffsetY = -backgroundScrollViewLimit * kBackgroundParallexFactor;
            [_backgroundScrollView setContentOffset:(CGPoint){0,contentOffsetY} animated:NO];
            _titleSmallLabel.alpha = 1;
  
        }
        else {
            _backgroundScrollView.frame = rect;
            _commentsViewContainer.frame = (CGRect){.origin = {0, CGRectGetMinY(rect) + CGRectGetHeight(rect)}, .size = _commentsViewContainer.frame.size };
            [_scroller setContentOffset:(CGPoint){0,0} animated:NO];
            _addButton.frame = (CGRect){.origin = {ADD_SONG_INIT_FRAME.origin.x, CGRectGetMinY(_backgroundScrollView.frame) + CGRectGetHeight(_backgroundScrollView.frame) - ADD_SONG_INIT_FRAME.size.height/2}, .size = _addButton.frame.size };

            [_backgroundScrollView setContentOffset:CGPointMake(0, -delta * kBackgroundParallexFactor)animated:NO];
           
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
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
