//
//  Created by matt on 28/09/12.
//  Additions by Marin Todorov for YouTube JSONModel tutorial
#import "AppConstant.h"
#import "VoteCell.h"
@interface VoteCell()

@end

@implementation VoteCell
#pragma mark - Init
AHKActionSheet *actionSheet;
UIImage *image;
static CGFloat imageHeight = 50;
static CGFloat imageWidth = 89.0;


- (void)setup {

  // positioning
  self.rightMargin = 10;
  self.leftMargin = 10;
  // background
    self.backgroundColor =  [UIColor whiteColor];

  // shadow
    
  self.layer.shadowColor = [UIColor colorWithWhite:0.12 alpha:1].CGColor;
  self.layer.shadowOffset = CGSizeMake(0, 0.5);
  self.layer.shadowRadius = 0;
  self.layer.shadowOpacity = 1;

}

#pragma mark - Factories

+ (VoteCell *)photoBoxForVideo:(VideoModel*)video withSize:(CGSize)size withLine:(BOOL)drawLine atIndex:(int)i
{
  // box with photo number tag
  VoteCell *box = [VoteCell boxWithSize:size];
  box.drawLine = drawLine;
  box.video = video;
  NSURL *url = [NSURL URLWithString:video.thumbnail];
  // add a loading spinner
  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  spinner.center = CGPointMake(box.width / 2, box.height / 2);
  spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
      | UIViewAutoresizingFlexibleRightMargin
      | UIViewAutoresizingFlexibleBottomMargin
      | UIViewAutoresizingFlexibleLeftMargin;
  spinner.color = UIColor.lightGrayColor;

  [box addSubview:spinner];
  [spinner startAnimating];
  
  // do the photo loading async, because internets
  __weak id wbox = box;
  box.asyncLayoutOnce = ^{
      [wbox loadPhotoFromURL:url withCellSize:size atIndex:i];
  };


  return box;
}



#pragma mark - Photo box loading
- (void)loadPhotoFromURL:(NSURL*)url withCellSize:(CGSize) size atIndex:(int) i
{

  // fetch the remote photo
  NSData *data = [NSData dataWithContentsOfURL:url];

  // do UI stuff back in UI land
  dispatch_async(dispatch_get_main_queue(), ^{

    // ditch the spinner
    UIActivityIndicatorView *spinner = self.subviews.lastObject;
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    CGFloat imagePadding = (size.height - imageHeight)/2;
          CGFloat trackNumSize = 25;
    CGFloat trackPadding = 5 + trackNumSize;
    CGFloat labelPadding = imageWidth + 5 + trackPadding;
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(labelPadding, imagePadding,size.width - imageWidth - 40,imageHeight)];
      // [label setFrame:CGRectIntegral(label.frame)];
      // [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    label.backgroundColor = [UIColor clearColor];
    label.text = self.video.title;
    label.numberOfLines = 0;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    label.textColor = [UIColor blackColor];
    [self addSubview:label];
    UILabel *trackNumber = [[UILabel alloc] initWithFrame:(CGRect){0, imagePadding, trackNumSize,imageHeight}];
    trackNumber.text = [NSString stringWithFormat:@"%i",i];

    trackNumber.numberOfLines = 0;
    trackNumber.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    trackNumber.textColor = [UIColor blackColor];
      trackNumber.textAlignment = NSTextAlignmentCenter;
    [self addSubview:trackNumber];
    /*
    CGFloat buttonSize = 21.0;
    CGFloat buttonPadding = (size.height - buttonSize)/2;
    UIButton *moreOptions = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-buttonSize-10, buttonPadding, buttonSize, buttonSize)];
    UIButton *moreOptionsBackground = [[UIButton alloc] initWithFrame:CGRectMake(label.frame.origin.x + label.frame.size.width+5, 0.0, self.frame.size.width - (label.frame.origin.x + label.frame.size.width)+5, self.frame.size.height)];
    
    [moreOptions setBackgroundImage:[UIImage imageNamed:@"internet"] forState:UIControlStateNormal];
    [self addSubview:moreOptionsBackground];
    [self addSubview:moreOptions];
    [moreOptions addTarget:self
                      action:@selector(showMore:)
            forControlEvents:UIControlEventTouchUpInside];
    [moreOptionsBackground addTarget:self
                                action:@selector(showMore:)
                      forControlEvents:UIControlEventTouchUpInside];
    */
      /*
      CGFloat buttonSize = 25.0;
      CGFloat buttonTopPadding = 7;
      UIButton *upVote = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-buttonSize-10, buttonTopPadding, buttonSize, buttonSize)];
      [upVote setBackgroundImage:[UIImage imageNamed:@"up-vote"] forState:UIControlStateNormal];
      [self addSubview:upVote];
      UIButton *downVote = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-buttonSize-10, self.frame.size.height - buttonSize - buttonTopPadding, buttonSize, buttonSize)];
      [downVote setBackgroundImage:[UIImage imageNamed:@"down-vote"] forState:UIControlStateNormal];
      [self addSubview:downVote];
      CGFloat votePadding = 0;
      CGFloat voteHeight = downVote.frame.origin.y- upVote.frame.origin.y - upVote.frame.size.height- 2*votePadding;
      
      UILabel *voteCount = [[UILabel alloc] initWithFrame:CGRectMake(upVote.frame.origin.x, upVote.frame.origin.y + upVote.frame.size.height  , upVote.frame.size.width, voteHeight)];
      [self addSubview:voteCount];
      voteCount.text = @"0";
      voteCount.textAlignment = NSTextAlignmentCenter;
      voteCount.textColor = [UIColor blackColor];
      voteCount.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0f];
       */
     if(self.drawLine){
          UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0.0, size.height-1, size.width, 0.5)];
          border.backgroundColor = RGB(236, 238, 241);
          [self addSubview:border];
    }
      
      
    // failed to get the photo?
    if (!data) {
    //self.alpha = 0.3;
        // got the photo, so lets show it
        UIImage *image = [UIImage imageNamed:@"album-art-missing"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

        imageView.frame = CGRectMake(imageWidth/4 + labelPadding,imagePadding,41, 41);
        UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0,imagePadding,imageWidth, imageHeight)];
        emptyView.backgroundColor = [UIColor blackColor];
        [self addSubview:emptyView];
        [self addSubview:imageView];
        return;
    }

    // got the photo, so lets show it
    UIImage *image = [UIImage imageWithData:data];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

    
    imageView.frame = CGRectMake(trackPadding,imagePadding,imageWidth, imageHeight);
    [self addSubview:imageView];
    
    imageView.alpha = 0;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;

    // fade the image in
    [UIView animateWithDuration:0.2 animations:^{
    imageView.alpha = 1;
    }];
  });
}

-(void) showMore:(id) sender{
    actionSheet = [[AHKActionSheet alloc] initWithTitle:nil];
    
    actionSheet.blurTintColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    actionSheet.blurRadius = 8.0f;
    actionSheet.buttonHeight = 50.0f;
    actionSheet.cancelButtonHeight = 50.0f;
    actionSheet.animationDuration = 0.5f;
    actionSheet.cancelButtonShadowColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
    actionSheet.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
    actionSheet.selectedBackgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    UIFont *defaultFont = [UIFont fontWithName:@"Avenir" size:17.0f];
    actionSheet.buttonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                          NSForegroundColorAttributeName : [UIColor whiteColor] };
    actionSheet.disabledButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                                  NSForegroundColorAttributeName : [UIColor grayColor] };
    actionSheet.destructiveButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                                     NSForegroundColorAttributeName : [UIColor redColor] };
    actionSheet.cancelButtonTextAttributes = @{ NSFontAttributeName : defaultFont,
                                                NSForegroundColorAttributeName : [UIColor whiteColor] };
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    // do UI stuff back in UI land
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(10, 10, 71, 40);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL URLWithString:self.video.thumbnail];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (!data) {
            //self.alpha = 0.3;
            // got the photo, so lets show it
            UIImage *image = [UIImage imageNamed:@"album-art-missing"];
            UIImageView *imageViewDefault = [[UIImageView alloc] initWithImage:image];
            
            imageViewDefault.frame = CGRectMake(imageWidth/4+10,10,41, 41);
            UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 71, 40)];
            emptyView.backgroundColor = [UIColor blackColor];
            [headerView addSubview:emptyView];
            [headerView addSubview:imageViewDefault];
            return;
        }
        
        UIImage *image = [UIImage imageWithData:data];
        imageView.image = image;
        [headerView addSubview:imageView];
    });
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(91, 20, 200, 20)];
    label1.text = self.video.title;
    label1.textColor = [UIColor whiteColor];
    label1.font = [UIFont fontWithName:@"Avenir" size:17.0f];
    label1.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label1];
    actionSheet.headerView = headerView;

    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Add to Favorites", nil)
                              image:[UIImage imageNamed:@"Icon2"]
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *as) {
                                [self insertSongToLibrary];
                            }];
    
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Share with Jukebox"]
                                  image:[UIImage imageNamed:@"Icon3"]
                                   type:AHKActionSheetButtonTypeDefault
                                handler:nil];
    
    [actionSheet show];

}

-(void) insertSongToLibrary {
    JBCoreDataStack *coreDataStack = [JBCoreDataStack defaultStack];
    Song *song = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:coreDataStack.managedObjectContext];
    song.videoId = self.video.videoId;
    song.title = self.video.title;
    song.url = self.video.thumbnail;
    NSLog(@"Saved %@ %@ %@", song.videoId, song.title, song.url);
    [coreDataStack saveContext];
    
}




@end
