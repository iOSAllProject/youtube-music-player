//
//  RootViewController.m
//  SecretTestApp
//
//  Created by Aaron Pang on 3/28/14.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import "JukeboxPostViewController.h"
#import "UIImage+ImageEffects.h"
#import "AppConstant.h"
#import "UIView+GradientMask.h"
#import "MediaManager.h"
#import "JukeboxEntry.h"
#import "MGScrollView.h"
#import <QuartzCore/QuartzCore.h>
#import "VoteCell.h"
#import "LibraryViewController.h"
#import "Song.h"
#import <Parse/Parse.h>
#import "RMSaveButton.h"
#import "SearchYoutubeViewController.h"
#import "MusicApp-Swift.h"
#import <MMX/MMX.h>
#import "QuickStartUtils.h"
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define HEADER_HEIGHT 320.0f
#define THUMB_SIZE 100.0f
#define HEADER_INIT_FRAME CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)
#define TOOLBAR_INIT_FRAME CGRectMake (0, 292, 320, 22)
#define THUMBNAIL_INIT_FRAME CGRectMake (self.view.frame.size.width/2 - THUMB_SIZE/2,HEADER_HEIGHT/3.5, THUMB_SIZE,THUMB_SIZE)
#define TITLE_INIT_FRAME CGRectMake(0, THUMBNAIL_INIT_FRAME.origin.y + THUMBNAIL_INIT_FRAME.size.height + 10, self.view.frame.size.width, 40.0)
#define USERNAME_INIT_FRAME CGRectMake(0, TITLE_INIT_FRAME.origin.y + TITLE_INIT_FRAME.size.height, self.view.frame.size.width, 20.0)
#define ADD_SONG_BUTTON_SIZE = CGSizeMake(140,50)
#define ADD_SONG_INIT_FRAME CGRectMake(self.view.frame.size.width/2 - 70,HEADER_HEIGHT-25,140,50)
#define SMALL_TITLE_SIZE  self.view.size.width - 110
const CGFloat kBarHeight = 88.0f;
const CGFloat kBackgroundParallexFactor = 0.95f;
const CGFloat kBlurFadeInFactor = 0.05f;
const CGFloat kTextFadeOutFactor = 0.007f;
const CGFloat kCommentCellHeight = 50.0f;

@class PeriscommentView;
@interface JukeboxPostViewController () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@end



@implementation JukeboxPostViewController {
    UIScrollView *_mainScrollView;
    UIScrollView *_backgroundScrollView;
    UIImageView *_blurImageView;
    UILabel *_titleSmallLabel;
    UILabel *_textLabel;
    UILabel *_userLabel;
    UIView *_postContainer;
    UIImageView *_thumbImageView;
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
    BOOL isLoading;
    NSMutableArray *comments;
    NSTimer *timer;
    UIView *liveChatView;
    NSInteger lastUpdated;
    UIImageView *liveChatBg;
    UITextField *textView;
    NSString *id;
    PeriscommentView *liveChatMessages;
    
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
        fadeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
        fadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        

        _postContainer = [[UIView alloc] initWithFrame:HEADER_INIT_FRAME];
        _postContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        _thumbImageView = [[UIImageView alloc] initWithFrame:THUMBNAIL_INIT_FRAME];
        _thumbImageView.image = jukeboxEntry.image;
        _thumbImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _thumbImageView.layer.cornerRadius = 10;
        _thumbImageView.layer.masksToBounds = YES;
        
        
        _textLabel = [[UILabel alloc] initWithFrame:TITLE_INIT_FRAME];
        [_textLabel setText:entry.title];
        [_textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:22.0f]];
        [_textLabel setTextAlignment:NSTextAlignmentCenter];
        [_textLabel setTextColor:[UIColor whiteColor]];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _textLabel.layer.shadowRadius = 10.0f;
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        CGFloat smallTitleSize = SMALL_TITLE_SIZE;
        _titleSmallLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 30, smallTitleSize, 25)];
        _titleSmallLabel.text = entry.title;
        [_titleSmallLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleSmallLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f]];
        _titleSmallLabel.backgroundColor = [UIColor clearColor];
        _titleSmallLabel.textColor = [UIColor whiteColor];
        _titleSmallLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _titleSmallLabel.layer.shadowRadius = 10.0f;
        _titleSmallLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        
        _userLabel = [[UILabel alloc] initWithFrame:USERNAME_INIT_FRAME];
        [_userLabel setText:entry.author];
        [_userLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
        [_userLabel setTextAlignment:NSTextAlignmentCenter];
        [_userLabel setTextColor:[UIColor whiteColor]];
        _userLabel.backgroundColor = [UIColor clearColor];
        _userLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _userLabel.layer.shadowRadius = 10.0f;
        _userLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

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
 

        [_mainScrollView addSubview:_backgroundScrollView];
        [_commentsViewContainer addSubview:_commentsTableView];
        [_mainScrollView addSubview:_commentsViewContainer];
        [self.view addSubview:_titleSmallLabel];
/*
        _addButton = [[RMSaveButton alloc] initWithFrame: ADD_SONG_INIT_FRAME];
        _addButton.label = @"Queue Song";
        [_mainScrollView addSubview:_addButton];
        _addButton.startHandler = ^void() { [self searchForSong]; };
        _addButton.interruptHandler = ^void() {};
        _addButton.completionHandler = ^void() {};
        */
        
        UIImageView *dismissButtonIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 25.0, 25.0)];
        dismissButtonIcon.image = [UIImage imageNamed:@"close"];
        [self.view addSubview:dismissButtonIcon];
        
        dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 75.0, 75.0)];
        [dismissButton addTarget:self
                          action:@selector(done)
                forControlEvents:UIControlEventTouchUpInside];
        //[dismissButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [self.view addSubview: dismissButton];
        
        UIImageView *queueButtonIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-10-22, 30, 20.0, 20.0)];
        queueButtonIcon.image = [UIImage imageNamed:@"Plus"];
        [self.view addSubview:queueButtonIcon];
        queue = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 0, 75.0, 75.0)];
       // [queue setBackgroundImage:[UIImage imageNamed:@"Plus"] forState:UIControlStateNormal];
        queue.backgroundColor = [UIColor clearColor];
        [queue addTarget:self
                          action:@selector(searchForSong)
                forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:queue];

        
        [[MediaManager sharedInstance] setCurrentJukebox: jukeboxEntry];
        [[MediaManager sharedInstance] setUserPaused:NO];
        [self loadSongs];
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(loadSongs) userInfo:nil repeats:YES];
        liveChatView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];
        liveChatBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];
        liveChatBg.image = jukeboxEntry.image;
        liveChatBg.contentMode = UIViewContentModeScaleAspectFill;
      //  liveChatView.backgroundColor = [UIColor colorWithPatternImage: jukeboxEntry.image];
        CGPoint centerImageView = self.view.center;
        [liveChatBg setCenter:CGPointMake(centerImageView.x, liveChatBg.center.y)];
        [liveChatView addSubview:liveChatBg];
        UITapGestureRecognizer *gesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendRemoteAnimation)]; // Declare the Gesture.
        gesRecognizer.delegate = self;
        [liveChatView addGestureRecognizer:gesRecognizer]; // Add Gesture to your view.

        [self.view addSubview:liveChatView];
        self.isLiveChatShowing = NO;
        [liveChatView setHidden:YES];
        liveChatMessages =[[PeriscommentView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height-44-44-5)];
        [liveChatView addSubview:liveChatMessages];
        

        textView = [[UITextField alloc] initWithFrame:CGRectMake(5, self.view.frame.size.height - 44 - 44 - 5, self.view.frame.size.width-10, 44)];
        textView.placeholder = @"Say something";
        [textView.layer setCornerRadius:5.0f];
        textView.textAlignment = UITextAlignmentLeft;          //for text Alignment
        textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]; // text font
        textView.adjustsFontSizeToFitWidth = YES;     //adjust the font size to fit width.
        textView.backgroundColor = [UIColor whiteColor];
        textView.textColor = [UIColor blackColor];             //text color
        textView.keyboardType = UIKeyboardTypeAlphabet;        //keyboard type of ur choice
        textView.returnKeyType = UIReturnKeySend;              //returnKey type for keyboard
        textView.delegate = self;
        UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [textView setLeftViewMode:UITextFieldViewModeAlways];
        [textView setLeftView:spacerView];
        
         [liveChatView addSubview:textView];
        UIButton *closeChatButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 30, 25.0, 25.0)];
        [closeChatButton addTarget:self
                          action:@selector(closeChat)
                forControlEvents:UIControlEventTouchUpInside];
        [closeChatButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [liveChatView addSubview:closeChatButton];
       //sa [self.view endEditing:YES];

           self.concurrentPhotoQueue = dispatch_queue_create("live_chat_loading",DISPATCH_QUEUE_CONCURRENT);
  
        
    }
    return self;
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer{
        [textView resignFirstResponder];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}


    
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}




- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 210; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    textField.frame = CGRectOffset(textView.frame, 0, movement);
    liveChatMessages.frame = CGRectOffset(liveChatMessages.frame, 0, movement);
    [UIView commitAnimations];
}

-(void) closeChat {
    [textView resignFirstResponder];
    @synchronized(self){
        self.isLiveChatShowing = NO;
        [liveChatView setHidden:YES];
    }
    
}

-(void) searchForSong {
    SearchYoutubeViewController *searchViewController = [[SearchYoutubeViewController alloc] initForJukeBoxSearch: jukeboxEntry];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    [self presentViewController:navController animated:YES completion:nil];
}


- (BOOL)updatePlaylist: (PFObject*) jukebox {

    NSInteger parseUpdatedTime = [jukebox.updatedAt timeIntervalSince1970];
    if([_scroller.boxes count] == 0){
        //Always fetch the first time
    }
    else if([jukebox[@"playQueue"] count] == [self.currentLibrary count]){
        PFObject *videoObj =[jukebox[@"playQueue"] objectAtIndex:0];
        NSString *objectId = videoObj[@"vid"];
        NSString *libraryObjectId =[[self.currentLibrary objectAtIndex:0] videoId];
        if([objectId isEqualToString:libraryObjectId])
            return NO;
        
    }
    
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
    NSArray *songs = jukebox[@"playQueue"];
    for (PFObject *s in songs){
        if(counter == 0){
            drawLine = NO;
        }
        else if(counter == 1){
            MGLine *emptyLine = [MGLine lineWithSize:(CGSize){self.view.frame.size.width, 1}];
            [_scroller.boxes addObject:emptyLine];
            MGLine *layoutLine = [MGLine lineWithLeft:@"UP NEXT" right:nil
                                                 size:(CGSize){self.view.frame.size.width, 44}];
            layoutLine.leftPadding = layoutLine.rightPadding = 16;
            layoutLine.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
            [_scroller.boxes addObject:layoutLine];
            drawLine = YES;
        }else if(counter == [songs count] -1){
            drawLine = NO;
        } else {
            drawLine= YES;
        }
        
        //get the data
        VideoModel *video = [LibraryViewController createVideoForParse:s];
        [self.currentLibrary addObject:video];
        
        //create a box
        VoteCell *box = [VoteCell photoBoxForVideo:video withSize:CGSizeMake(self.view.frame.size.width-20,85) withLine:drawLine atIndex:i++];
        
        box.frame = CGRectIntegral(box.frame);
        box.onTap = ^{
            
            
            JukeboxEntry *entry = [self createJukeBoxEntry:jukebox];
            NSString *authorId = entry.authorId;
            NSString *currentUser =[[PFUser currentUser] objectId];
            if(![authorId isEqualToString:currentUser]){
                [self sendRemoteAnimation];
            }
        };
        counter++;
        //add the box
        [_scroller.boxes addObject:box];
    }
    [_scroller layout];
    lastUpdated = parseUpdatedTime;
    return YES;
}

-(void) loadSongs {
    dispatch_async(dispatch_get_main_queue(), ^{


        //if(isLoading) return;
        JukeboxEntry *playJukebox = [[MediaManager sharedInstance] currentJukebox];

        if((playJukebox != nil && ![jukeboxEntry.objectId isEqualToString:playJukebox.objectId]) || playJukebox == nil){
            [timer invalidate];
            return;
        }
        if([[MediaManager sharedInstance] userPaused])
            return;
        @synchronized(self) {
            isLoading = YES;
        //clean the old videos


        PFQuery *query = [PFQuery queryWithClassName:@"Jukeboxes"];
        [query includeKey:@"playQueue"];
        //if (lastUpdated != nil)
         //   [query whereKey:@"updatedAt" greaterThan:lastUpdated];
        [query getObjectInBackgroundWithId:jukeboxEntry.objectId block:^(PFObject *jukebox, NSError *error) {
            //NSLog(@"%@", jukebox[@"isPlaying"]);

            
            
            BOOL songChange = [self updatePlaylist: jukebox];
            //update the current song
            jukeboxEntry = [self createJukeBoxEntry:jukebox];
            [[MediaManager sharedInstance] setCurrentJukebox: jukeboxEntry];
            [self startChannel];
            [self updateCurrentPlayBack];
            
            if(songChange){
                [[MediaManager sharedInstance] setCurrentLibrary:self.currentLibrary];
            }
            isLoading = NO;
        }];
            
        }
    });
    
    
}
-(void) updateCurrentPlayBack {
    JukeboxEntry *currentJukeBox = [[MediaManager sharedInstance] currentJukebox];
    NSString *currentUser =[[PFUser currentUser] objectId];
    if([self.currentLibrary count] == 0) {
        playerBar.hidden = YES;
        return;
    }
    if([currentUser isEqualToString:currentJukeBox.authorId]){
        //Broadcast to other listeners current song details
        BOOL miniPlayerOff = playerBar.isHidden;
        VideoModel *currentSong = nil;
        if([[[MediaManager sharedInstance] currentPlaylist] count] > 0)
            currentSong = [[MediaManager sharedInstance] getCurrentlyPlaying];
        VideoModel *video = [self.currentLibrary objectAtIndex:0];
        MPMoviePlayerController *moviePlayer = [[MediaManager sharedInstance] mPlayer];
        if((![video.videoId isEqualToString:currentSong.videoId] && [jukeboxEntry.authorId isEqualToString:currentJukeBox.authorId]) || miniPlayerOff){
            
            [[MediaManager sharedInstance] setPlaylist:self.currentLibrary andSongIndex:0];
            [[MediaManager sharedInstance] playWithVideo:video];
            
            //  [moviePlayer pause];
            //[moviePlayer setCurrentPlaybackTime:jukeboxEntry.elapsedTime];
            [self adjustScrollViewToPlayer];
        }
        [[MediaManager sharedInstance] updateJukeboxPlayState];
    }
        /*
    VideoModel *video = [self.currentLibrary objectAtIndex:0];
    VideoModel *currentSong = [[MediaManager sharedInstance] getCurrentlyPlaying];
    JukeboxEntry *currentJukeBox = [[MediaManager sharedInstance] currentJukebox];
    BOOL miniPlayerOff = playerBar.isHidden;
    MPMoviePlayerController *moviePlayer = [[MediaManager sharedInstance] mPlayer];
    
    if((![currentSong.videoId isEqualToString:video.videoId] && [jukeboxEntry.authorId isEqualToString:currentJukeBox.authorId]) || miniPlayerOff){
        
        [[MediaManager sharedInstance] setPlaylist:self.currentLibrary andSongIndex:0];
        [[MediaManager sharedInstance] playWithVideo:video];
       [self adjustScrollViewToPlayer];
      //  [moviePlayer pause];
        //[moviePlayer setCurrentPlaybackTime:jukeboxEntry.elapsedTime];
        [moviePlayer play];
        [self adjustScrollViewToPlayer];
    }
    
    NSString *currentUser =[[PFUser currentUser] objectId];
    if(![currentUser isEqualToString:currentJukeBox.authorId]){
        MPMoviePlaybackState state = [[[MediaManager sharedInstance] mPlayer] playbackState];
        BOOL myIsPlaying = (state == MPMoviePlaybackStatePlaying);
        if(myIsPlaying != currentJukeBox.isPlaying) {
          
           // [moviePlayer pause];
           // [moviePlayer setCurrentPlaybackTime:jukeboxEntry.elapsedTime];
            if(!currentJukeBox.isPlaying)
                [[[MediaManager sharedInstance] mPlayer] pause];
            else
                [[[MediaManager sharedInstance] mPlayer] play];
        }
    } else {
        [[MediaManager sharedInstance] updateJukeboxPlayState];
    }*/
}

-(JukeboxEntry*) createJukeBoxEntry: (PFObject *) pf{
    JukeboxEntry *jbe = [[JukeboxEntry alloc] init];
    jbe.title = pf[@"name"];
    jbe.author = pf[@"username"];
    jbe.objectId = pf.objectId;
    
    jbe.imageURL = pf[@"image"];
    jbe.authorId = pf[@"userId"];
    jbe.isPlaying = [pf[@"isPlaying"] boolValue];
    jbe.elapsedTime = [pf[@"time"] integerValue];
    jbe.updatedAt = [pf.updatedAt timeIntervalSince1970];
    return jbe;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat delta = 0.0f;
    CGRect rect = HEADER_INIT_FRAME;
    CGRect toolbarRect = TOOLBAR_INIT_FRAME;
    CGRect thumbRect = THUMBNAIL_INIT_FRAME;
    CGRect titleRect = TITLE_INIT_FRAME;
    CGRect userRect = USERNAME_INIT_FRAME;
    // Here is where I do the "Zooming" image and the quick fade out the text and toolbar
    if (scrollView.contentOffset.y < 0.0f) {
        delta = fabs(MIN(0.0f, _mainScrollView.contentOffset.y));
        _backgroundScrollView.frame = CGRectMake(CGRectGetMinX(rect) - delta / 2.0f, CGRectGetMinY(rect) - delta, CGRectGetWidth(rect) + delta, CGRectGetHeight(rect) + delta);

        [_scroller setContentOffset:(CGPoint){0,0} animated:NO];

      //  _blurImageView.alpha = MIN(1.0f, 1.0f - delta * kTextFadeOutFactor);
        
        if(delta < 64){
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
         //   NSLog(@"scroll is: %f   delta is: %f ", _mainScrollView.contentOffset.y,delta);
                _blurImageView.alpha = MIN(1.0f, 1.0f - delta * kTextFadeOutFactor);
                _textLabel.alpha = MIN(1.0f, 1.0f - delta * kTextFadeOutFactor)/8;
                _thumbImageView.alpha = _textLabel.alpha;
                _userLabel.alpha = _textLabel.alpha;

            
        }
        if(delta > 128){
            queue.alpha = _textLabel.alpha;
            dismissButton.alpha = _textLabel.alpha;
            [self showLiveChat: delta];
        }

    } else {
        delta = _mainScrollView.contentOffset.y;
        CGFloat playerBarOffset = 0;//playerBar.isHidden ? 0 : 44;
        _textLabel.alpha = 1.0f;
        _userLabel.alpha = 1.0f;
        _thumbImageView.alpha = 1.0f;
        _blurImageView.alpha = MIN(1 , 1+delta * kBlurFadeInFactor);
        CGFloat backgroundScrollViewLimit = _backgroundScrollView.frame.size.height - kBarHeight;
        // Here I check whether or not the user has scrolled passed the limit where I want to stick the header, if they have then I move the frame with the scroll view
        // to give it the sticky header look
        if (delta >= backgroundScrollViewLimit) {
            _backgroundScrollView.frame = (CGRect) {.origin = {0, delta - _backgroundScrollView.frame.size.height + kBarHeight -playerBarOffset}, .size = {self.view.frame.size.width, HEADER_HEIGHT}};
            _commentsViewContainer.frame = (CGRect){.origin = {0, CGRectGetMinY(_backgroundScrollView.frame) + CGRectGetHeight(_backgroundScrollView.frame)}, .size = _commentsViewContainer.frame.size };
            
            _addButton.frame = (CGRect){.origin = {ADD_SONG_INIT_FRAME.origin.x, CGRectGetMinY(_backgroundScrollView.frame) + CGRectGetHeight(_backgroundScrollView.frame) - ADD_SONG_INIT_FRAME.size.height/2}, .size = _addButton.frame.size };
            
            _scroller.contentOffset = CGPointMake (0, delta - backgroundScrollViewLimit);
            CGFloat contentOffsetY = -backgroundScrollViewLimit * kBackgroundParallexFactor;
            [_backgroundScrollView setContentOffset:(CGPoint){0,contentOffsetY} animated:NO];
            _titleSmallLabel.alpha =1;
            _thumbImageView.alpha = 0;
            _textLabel.alpha = 0;
            _userLabel.alpha = 0;
  
        }
        else {
            _backgroundScrollView.frame = rect;
            _commentsViewContainer.frame = (CGRect){.origin = {0, CGRectGetMinY(rect) + CGRectGetHeight(rect)}, .size = _commentsViewContainer.frame.size };
            [_scroller setContentOffset:(CGPoint){0,0} animated:NO];
            _addButton.frame = (CGRect){.origin = {ADD_SONG_INIT_FRAME.origin.x, CGRectGetMinY(_backgroundScrollView.frame) + CGRectGetHeight(_backgroundScrollView.frame) - ADD_SONG_INIT_FRAME.size.height/2}, .size = _addButton.frame.size };

            [_backgroundScrollView setContentOffset:CGPointMake(0, -delta * kBackgroundParallexFactor)animated:NO];
           
            _titleSmallLabel.alpha =0;
            _thumbImageView.alpha = 1;
            _textLabel.alpha = 1;
            _userLabel.alpha = 1;
        }
        
    }


    
}

- (void)viewDidAppear:(BOOL)animated {
    _mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), _scroller.contentSize.height + CGRectGetHeight(_backgroundScrollView.frame));
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:MMXDidReceiveMessageNotification object:nil];

}

-(void) startChannel {
    // Delay 2 seconds
    if(!self.currentChannel){
        [MMX start];
        JukeboxEntry *currentJukebox = [[MediaManager sharedInstance] currentJukebox];
        [MMXChannel channelsStartingWith: currentJukebox.objectId
                                   limit:10
                                 success:^(int totalCount, NSArray *channels) {
                                     MMXChannel *channel = channels[0];
                                     self.currentChannel = channel;
                                     [[MediaManager sharedInstance] setCurrentChannel:self.currentChannel];
                                     NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                                     dateComponents.hour = -1;
                                     
                                     NSCalendar *theCalendar = [NSCalendar currentCalendar];
                                     NSDate *now = [NSDate date];
                                     // NSDate *anHourAgo = [theCalendar dateByAddingComponents:dateComponents toDate:now options:0];
                                     /*
                                      [channel fetchMessagesBetweenStartDate:anHourAgo
                                      endDate:now
                                      limit:10
                                      ascending:NO
                                      success:^(int totalCount, NSArray *messages) {
                                      self.messages = messages;
                                      for (MMXMessage *msg in self.messages){
                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                      NSDictionary *dict = msg.messageContent;
                                      [liveChatMessages addCell:[UIImage imageNamed:@"unknown"] name:@"Meir" comment:[dict objectForKey:@"textContent"]];
                                      });
                                      }
                                      
                                      } failure:^(NSError *error) {
                                      
                                      }];*/
                                 }
                                 failure:^(NSError *error) {
                                     NSLog(@"Error creating channel");
                                 }];
        
    }
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
    [self adjustScrollViewToPlayer];
    [self.view addSubview:playerBar];
    
}
-(void) adjustScrollViewToPlayer{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if(playerBar.isHidden){
        _scroller.frame = (CGRect){_scroller.frame.origin.x,_scroller.origin.y,self.view.frame.size.width, listViewHeight};
        _commentsViewContainer.frame = (CGRect){_commentsViewContainer.frame.origin.x,_commentsViewContainer.origin.y,self.view.frame.size.width, listViewHeight};

        _mainScrollView.frame = window.frame;
        
    } else {
        _scroller.frame = (CGRect){_scroller.frame.origin.x,_scroller.origin.y,self.view.frame.size.width, listViewHeight-44};
        _commentsViewContainer.frame = (CGRect){_commentsViewContainer.frame.origin.x,_commentsViewContainer.origin.y,self.view.frame.size.width, listViewHeight-44};
        _mainScrollView.frame = CGRectMake(window.frame.origin.x, window.frame.origin.y, window.frame.size.width, window.frame.size.height-44);
        
        
    }
    [_scroller layout];
}

-(void)viewWillDisappear {
    [playerBar removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

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
-(void) showLiveChat:(CGFloat) delta {
    dispatch_sync( self.concurrentPhotoQueue, ^{
        // Critical section

        if(!self.isLiveChatShowing && delta != 450){
             NSLog(@"Delta is %f", delta);
            [_mainScrollView setContentOffset:(CGPointMake(0, -450))];
            self.isLiveChatShowing = YES;
            [liveChatView setHidden:NO];
            [_mainScrollView setContentOffset:(CGPointMake(0, 0))];
        }
    });
    
}

- (void)viewWillLayoutSubviews {
    // Your adjustments accd to
    // viewController.bounds
    playerBar.frame = CGRectMake(0.0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
    _titleSmallLabel.frame = CGRectMake(50, 30, SMALL_TITLE_SIZE, 25);
    
    [super viewWillLayoutSubviews];
}


- (void)addHeart {
    UIImageView *heartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth / 2.0 - 14, textView.frame.origin.y +5 , 28, 26)];
    
    heartImageView.image = [UIImage imageNamed:@"happy_face"];
    heartImageView.transform = CGAffineTransformMakeScale(0, 0);
    [self.view addSubview:heartImageView];
    
    CGFloat duration = 5 + (arc4random() % 5 - 2);
    [UIView animateWithDuration:0.3 animations:^{
        heartImageView.transform = CGAffineTransformMakeScale(1, 1);
        heartImageView.transform = CGAffineTransformMakeRotation(-0.01 * (arc4random() % 20));
    }];
    [UIView animateWithDuration:duration animations:^{
        heartImageView.alpha = 0;
    }];
    CAKeyframeAnimation *animation = [self createAnimation:heartImageView.frame];
    animation.duration = duration;
    [heartImageView.layer addAnimation:animation forKey:@"position"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration + 0.5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [heartImageView removeFromSuperview];
    });
}

- (CAKeyframeAnimation *)createAnimation:(CGRect)frame {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    
    int height = -100 + arc4random() % 40 - 20;
    int xOffset = frame.origin.x;
    int yOffset = frame.origin.y;
    int waveWidth = 50;
    CGPoint p1 = CGPointMake(xOffset, height * 0 + yOffset);
    CGPoint p2 = CGPointMake(xOffset, height * 1 + yOffset);
    CGPoint p3 = CGPointMake(xOffset, height * 2 + yOffset);
    CGPoint p4 = CGPointMake(xOffset, height * 2 + yOffset);
    
    CGPathMoveToPoint(path, NULL, p1.x,p1.y);
    
    if (arc4random() % 2) {
        CGPathAddQuadCurveToPoint(path, NULL, p1.x - arc4random() % waveWidth, p1.y + height / 2.0, p2.x, p2.y);
        CGPathAddQuadCurveToPoint(path, NULL, p2.x + arc4random() % waveWidth, p2.y + height / 2.0, p3.x, p3.y);
        CGPathAddQuadCurveToPoint(path, NULL, p3.x - arc4random() % waveWidth, p3.y + height / 2.0, p4.x, p4.y);
    } else {
        CGPathAddQuadCurveToPoint(path, NULL, p1.x + arc4random() % waveWidth, p1.y + height / 2.0, p2.x, p2.y);
        CGPathAddQuadCurveToPoint(path, NULL, p2.x - arc4random() % waveWidth, p2.y + height / 2.0, p3.x, p3.y);
        CGPathAddQuadCurveToPoint(path, NULL, p3.x + arc4random() % waveWidth, p3.y + height / 2.0, p4.x, p4.y);
    }
    animation.path = path;
    animation.calculationMode = kCAAnimationCubicPaced;
    CGPathRelease(path);
    return animation;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == textView) {
        if([textView.text isEqualToString:@""])
            return YES;
        NSString *name = [PFUser currentUser][@"profile"][@"name"];
        NSString *imageURL = [PFUser currentUser][@"profile"][@"pictureURL"];
        MMXMessage *msg = [MMXMessage messageToChannel:self.currentChannel messageContent:@{@"textContent":textView.text, @"sender":name, @"imageURL":imageURL, @"type":@"text"}];
        
        [msg sendWithSuccess:nil failure:nil];
        
        NSDictionary *messageDict = @{@"messageContent":textView.text, @"timestampString":[[QuickStartUtils friendlyDateFormatter] stringFromDate:[NSDate date]],@"senderUsername": [[PFUser currentUser] objectId] ,@"isOutboundMessage":@(YES)};
        
        NSMutableArray *tempMessageList = self.messages.mutableCopy;
        [tempMessageList insertObject:messageDict atIndex:0];
        self.messages = tempMessageList.copy;
        textView.text = @"";
        [textField resignFirstResponder];
        
        return NO;
    }
    return YES;
}
- (void)didReceiveMessage:(NSNotification*) noti {
    if (noti.userInfo) {
        NSDictionary *notificationDict =  noti.userInfo;
        MMXMessage *message = notificationDict[MMXMessageKey];
        NSString *msgType = message.messageContent[@"type"];
        if (message) {
            if(msgType && [msgType isEqualToString:@"text"]){
                NSDictionary *messageDict = @{@"messageContent":message.messageContent[@"textContent"] ?: @"Message content missing",
                                              @"timestampString":[[QuickStartUtils friendlyDateFormatter] stringFromDate:message.timestamp],
                                              @"senderUsername":message.messageContent[@"sender"],
                                              @"imageURL":message.messageContent[@"imageURL"],
                                              @"isOutboundMessage":@(NO)};
                
                NSMutableArray *tempMessageList = self.messages.mutableCopy;
                [tempMessageList insertObject:messageDict atIndex:0];
                self.messages= tempMessageList.copy;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSString *textContent = [messageDict objectForKey:@"messageContent"];
                    NSString *sender = [messageDict objectForKey:@"senderUsername"];
                    NSString *userProfilePhotoURLString = [messageDict objectForKey:@"imageURL"];
                    // Download the user's facebook profile picture
                    if (userProfilePhotoURLString) {
                        NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
                        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
                        
                        [NSURLConnection sendAsynchronousRequest:urlRequest
                                                           queue:[NSOperationQueue mainQueue]
                                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                                   if (connectionError == nil && data != nil) {
                                                       [liveChatMessages addCell:[UIImage imageWithData:data] name:sender comment:textContent];
                                                   } else {
                                                       NSLog(@"Failed to load profile photo.");
                                                   }
                                               }];
                    }
                    
                });
                
            }else if(msgType && [msgType isEqualToString:@"like"]){
                NSDictionary *messageDict = @{
                                              @"timestampString":[[QuickStartUtils friendlyDateFormatter] stringFromDate:message.timestamp],
                                              @"senderUsername":message.messageContent[@"sender"],
                                              @"isOutboundMessage":@(NO)};
                NSString *sender = [messageDict objectForKey:@"senderUsername"];
                if(![sender isEqualToString:[[PFUser currentUser] objectId]]){
                    [self addHeart];
                }
                
            } else if(msgType && [msgType isEqualToString:@"audio"]){
                JukeboxEntry *currentJukeBox = [[MediaManager sharedInstance] currentJukebox];
                NSString *currentUser =[[PFUser currentUser] objectId];
                NSInteger timestamp = [message.messageContent[@"timestamp"] intValue];
                NSInteger elapsed = [message.messageContent[@"elapsed"] intValue];
                NSInteger currentTimeCalculation = elapsed + (timestamp - [[NSDate date] timeIntervalSince1970]);
              
                XCDYouTubeVideoPlayerViewController *t = [[MediaManager sharedInstance] videoPlayerViewController];
                NSInteger latency = 4;
               // NSLog(@"Testing: the time i sent out was %i and my time is %i. Our latency is: %i\n", currentTimeCalculation, (NSInteger)t.moviePlayer.currentPlaybackTime, latency) ;
                if([jukeboxEntry.authorId isEqualToString:currentUser])
                    return;
                VideoModel *receivedSong = [self convertMessageToModel: message.messageContent];

                BOOL isPlaying = [message.messageContent[@"state"] boolValue];
                [[MediaManager sharedInstance] setElapsed:elapsed];
                [[MediaManager sharedInstance] setLastTimeStamp:timestamp];
                [[MediaManager sharedInstance] setLatency:latency];
                BOOL miniPlayerOff = playerBar.isHidden;

                VideoModel *currentSong = [self.currentLibrary objectAtIndex:0];
            
                
                
                //Update current song
                if((![currentSong.videoId isEqualToString:receivedSong.videoId] && [self.currentChannel.name isEqualToString:jukeboxEntry.objectId]) || miniPlayerOff){
                    
                    [[MediaManager sharedInstance] setPlaylist:self.currentLibrary andSongIndex:0];
                    [[MediaManager sharedInstance] playWithVideo:receivedSong];
                    [self adjustScrollViewToPlayer];
                }
                //update player state
                if(![jukeboxEntry.authorId isEqualToString:currentUser]) {
                    MPMoviePlaybackState state = [[[MediaManager sharedInstance] mPlayer] playbackState];
                    BOOL myIsPlaying = (state == MPMoviePlaybackStatePlaying);
                    if(myIsPlaying != isPlaying) {
                        if(!isPlaying){
                            [[[MediaManager sharedInstance] mPlayer] pause];
                        }
                        else
                            [[[MediaManager sharedInstance] mPlayer] play];
                    }
                }

                
                
            }
        }
    }
}

-(VideoModel *) convertMessageToModel:(NSDictionary*) message {
    VideoModel *result = [[VideoModel alloc] init];
    result.videoId = message[@"videoId"];
    result.title = message[@"title"];
    return result;
}

-(void) sendRemoteAnimation {
    [self addHeart];
    NSString *name = [PFUser currentUser][@"profile"][@"name"];
    MMXMessage *msg = [MMXMessage messageToChannel:self.currentChannel messageContent:@{@"sender":[[PFUser currentUser] objectId], @"type":@"like"}];
    [msg sendWithSuccess:nil failure:nil];
}

@end
