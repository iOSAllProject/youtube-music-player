//
//  Created by matt on 28/09/12.
//

#import "JukeBoxCell.h"

#define IPHONE_PORTRAIT_PHOTO  (CGSize){140, 140}
#define IPHONE_PORTRAIT_GRID   (CGSize){375, 0}
@implementation JukeBoxCell

#pragma mark - Init

- (void)setup {

  // positioning
    self.topMargin = 20.0;
    self.leftMargin = (IPHONE_PORTRAIT_GRID.width - 2*IPHONE_PORTRAIT_PHOTO.width)/3;


  // background
  self.backgroundColor = [UIColor whiteColor];
  // shadow
  self.layer.shadowColor = [UIColor colorWithWhite:0.12 alpha:1].CGColor;
  //self.layer.shadowOffset = CGSizeMake(0, 0.5);
  self.layer.shadowRadius = 0;
  self.layer.shadowOpacity = 0;
}

#pragma mark - Factories

+ (JukeBoxCell *)photoAddBoxWithSize:(CGSize)size {

  // basic box
  JukeBoxCell *box = [JukeBoxCell boxWithSize:size];
  box.jukeBoxEntry = [[JukeboxEntry alloc] init];
  // style and tag
  box.backgroundColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.75 alpha:1];
  box.tag = -1;

  // add the add image
  UIImage *add = [UIImage imageNamed:@"add"];
  UIImageView *addView = [[UIImageView alloc] initWithImage:add];
  [box addSubview:addView];
  addView.center = (CGPoint){box.width / 2, box.height / 2};
  addView.alpha = 0.2;
  addView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
      | UIViewAutoresizingFlexibleRightMargin
      | UIViewAutoresizingFlexibleBottomMargin
      | UIViewAutoresizingFlexibleLeftMargin;

  return box;
}

+ (JukeBoxCell *)photoBoxFor:(int)i size:(CGSize)size {

  // box with photo number tag
  JukeBoxCell *box = [JukeBoxCell boxWithSize:size];
  box.tag = i;
  box.jukeBoxEntry = [[JukeboxEntry alloc] init];
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
  __block id bbox = box;
  box.asyncLayoutOnce = ^{
    [bbox loadPhoto];
  };

  return box;
}

#pragma mark - Layout

- (void)layout {
  [super layout];

  // speed up shadows
  self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

#pragma mark - Photo box loading

- (void)loadPhoto {

  // photo url
  id photosDir = @"http://bigpaua.com/images/MGBox";
  id fullPath = [NSString stringWithFormat:@"%@/%d.jpg", photosDir, self.tag];
  NSURL *url = [NSURL URLWithString:fullPath];
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
    self.jukeBoxEntry.image = image;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
    imageView.size = IPHONE_PORTRAIT_PHOTO;
    imageView.alpha = 0;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth
        | UIViewAutoresizingFlexibleHeight;

    // fade the image in
    [UIView animateWithDuration:0.2 animations:^{
      imageView.alpha = 1;
    }];
      
      CGFloat hPadding = 5;
      CGFloat vPadding = 5;
      UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, IPHONE_PORTRAIT_PHOTO.height+vPadding, 140-hPadding*2, 15)];
      title.text =  @"Jukebox Name";
      title.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
      title.textColor = [UIColor blackColor];
    //  title.backgroundColor = [UIColor redColor];
      [self addSubview:title];
      
      UILabel *author = [[UILabel alloc] initWithFrame:CGRectMake(0, title.frame.origin.y + title.frame.size.height +vPadding , 140 - hPadding*2, 10)];
      author.text =  @"Username";
      author.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
      author.textColor = RGB(62,68,72);
     // author.backgroundColor = [UIColor blueColor];
      [self addSubview:author];
  });

    
}

@end
