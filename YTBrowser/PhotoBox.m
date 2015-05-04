//
//  Created by matt on 28/09/12.
//  Additions by Marin Todorov for YouTube JSONModel tutorial
#import "AppConstant.h"
#import "PhotoBox.h"
@interface PhotoBox()

@end

@implementation PhotoBox
#pragma mark - Init

static CGFloat imageHeight = 60;
static CGFloat imageWidth = 107.0;

- (void)setup {

  // positioning
  self.rightMargin = 0;
  self.leftMargin = 0;
  // background
    self.backgroundColor =  [UIColor whiteColor];

  // shadow
    
  self.layer.shadowColor = [UIColor colorWithWhite:0.12 alpha:1].CGColor;
  self.layer.shadowOffset = CGSizeMake(0, 0.5);
  self.layer.shadowRadius = 1;
  self.layer.shadowOpacity = 1;

}

#pragma mark - Factories

+ (PhotoBox *)photoBoxForURL:(NSURL*)url title:(NSString*)title withSize:(CGSize) size
{
  // box with photo number tag
  PhotoBox *box = [PhotoBox boxWithSize:size];
  box.titleString = title;
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
      [wbox loadPhotoFromURL:url withCellSize:size];
  };

  return box;
}



#pragma mark - Photo box loading
- (void)loadPhotoFromURL:(NSURL*)url withCellSize:(CGSize) size
{

  // fetch the remote photo
  NSData *data = [NSData dataWithContentsOfURL:url];

  // do UI stuff back in UI land
  dispatch_async(dispatch_get_main_queue(), ^{

    // ditch the spinner
    UIActivityIndicatorView *spinner = self.subviews.lastObject;
    [spinner stopAnimating];
    [spinner removeFromSuperview];

    // failed to get the photo?
    if (!data) {
    self.alpha = 0.3;
    return;
    }

    // got the photo, so lets show it
    UIImage *image = [UIImage imageWithData:data];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

    CGFloat imagePadding = (size.height - imageHeight)/2;
    imageView.frame = CGRectMake(imagePadding,imagePadding,imageWidth, imageHeight);
    [self addSubview:imageView];
    
    imageView.alpha = 0;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;

    // fade the image in
    [UIView animateWithDuration:0.2 animations:^{
    imageView.alpha = 1;
    }];


    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(imageWidth + 15, imagePadding,size.width - imageWidth - 50,imageHeight)];
   // [label setFrame:CGRectIntegral(label.frame)];
   // [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    label.backgroundColor = [UIColor clearColor];
    label.text = self.titleString;
    label.numberOfLines = 0;
    
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    label.textColor = [UIColor blackColor];
    [self addSubview:label];
    
    CGFloat buttonSize = 20.0;
    CGFloat buttonPadding = (size.height - buttonSize)/2;
    UIButton *moreOptions = [[UIButton alloc] initWithFrame:CGRectMake(label.frame.origin.x+label.frame.size.width+5, buttonPadding, buttonSize, buttonSize)];
    [moreOptions setBackgroundImage:[UIImage imageNamed:@"more-128"] forState:UIControlStateNormal];
    [self addSubview:moreOptions];
      



  });
}

@end
