//
//  Created by matt on 28/09/12.
//

#import "JukeBoxCell.h"
#import <QuartzCore/QuartzCore.h>
#define IPHONE_PORTRAIT_PHOTO  (CGSize){80, 80}
#define ROW_HEIGHT 100
#define IPHONE_PORTRAIT_GRID   (CGSize){375, 0}
#define IV_FRAME CGRectMake((ROW_HEIGHT- IPHONE_PORTRAIT_PHOTO.height)/2, (ROW_HEIGHT - IPHONE_PORTRAIT_PHOTO.height)/2, IPHONE_PORTRAIT_PHOTO.width, IPHONE_PORTRAIT_PHOTO.height)


@implementation JukeBoxCell
{
    CGSize _size;
}
#pragma mark - Init

- (void)setup {

  // positioning
    
    //self.leftMargin = (IPHONE_PORTRAIT_GRID.width - 2*IPHONE_PORTRAIT_PHOTO.width)/3;
    self.topMargin = self.leftMargin;

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

+ (JukeBoxCell *)photoBoxFor:(JukeboxEntry*)jukeboxEntry size:(CGSize)size  {

  // box with photo number tag
    JukeBoxCell *box = [JukeBoxCell boxWithSize:size];

    box.jukeBoxEntry = jukeboxEntry;


    // BOOL isBgLight =[self isLightColor:self.backgroundColor];
    CGFloat hPadding = 10;
    CGFloat vPadding = 5;
    CGFloat titleSize = 20;
    CGFloat authorSize = 17;
    CGFloat songSize = 17;
    CGFloat allTextSize = titleSize + authorSize + songSize + 2*vPadding;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(IV_FRAME.size.width + IV_FRAME.origin.x + 10, ROW_HEIGHT/2 - (allTextSize+vPadding)/2, box.frame.size.width - IV_FRAME.size.width-25 - vPadding, titleSize)];
    title.text = jukeboxEntry.title;
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
    // title.textAlignment = NSTextAlignmentCenter;
    // if(isBgLight)
    title.textColor = [UIColor blackColor];
    //else
    //  title.textColor = [UIColor whiteColor];
    //  title.backgroundColor = [UIColor redColor];
    [box addSubview:title];

    UILabel *author = [[UILabel alloc] initWithFrame:CGRectMake(title.frame.origin.x, title.frame.origin.y + title.frame.size.height + vPadding ,  box.frame.size.width - IV_FRAME.size.width-40, authorSize)];
    author.text =  jukeboxEntry.author;
    // author.textAlignment = NSTextAlignmentCenter;
    author.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    author.textColor = RGB(62,68,72);
    //    if(isBgLight)
    author.textColor = RGB(62,68,72);
    //else
    //    author.textColor = RGB(225,225,225);
    // author.backgroundColor = [UIColor blueColor];
    [box addSubview:author];
    
    UIImageView *playingIcon = [[UIImageView alloc] initWithFrame:CGRectMake(title.frame.origin.x, author.frame.origin.y + author.frame.size.height + vPadding , 17, 17)];
    playingIcon.image = [UIImage imageNamed:@"currently_playing"];
    [box addSubview:playingIcon];
    UILabel *currentlyPlaying = [[UILabel alloc] initWithFrame:CGRectMake(title.frame.origin.x+ 24, author.frame.origin.y + author.frame.size.height + vPadding ,  box.frame.size.width - IV_FRAME.size.width-40, songSize)];
    currentlyPlaying.text = jukeboxEntry.currentlyPlaying;
    currentlyPlaying.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    currentlyPlaying.textColor = RGB(19, 143, 213);
    
    [box addSubview:currentlyPlaying];
    
    CGFloat moreSize = 25;
    UIImageView *more = [[UIImageView alloc] initWithFrame:CGRectMake(box.frame.size.width -moreSize-10, box.frame.size.height/2-moreSize/2, moreSize, moreSize)];
    more.image = [UIImage imageNamed:@"right_arrow"];
    [box addSubview:more];
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(10, ROW_HEIGHT-1, box.frame.size.width-20, 0.3)];
    border.backgroundColor = RGB(236, 238, 241);
    [box addSubview:border];
    
    // add a loading spinner
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinner.frame = IV_FRAME;
        spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
        | UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleLeftMargin;
        spinner.color = UIColor.lightGrayColor;
        [box addSubview:spinner];
        [spinner startAnimating];
      // do the photo loading async, because internet
        
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
  NSString *fullPath = self.jukeBoxEntry.imageURL;
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
      NSLog(@"Finished loading image %@", self.jukeBoxEntry.imageURL);
//    self.backgroundColor = [self averageColor:image];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
      imageView.frame = (CGRect) {(ROW_HEIGHT- IPHONE_PORTRAIT_PHOTO.height)/2, (ROW_HEIGHT - IPHONE_PORTRAIT_PHOTO.height)/2, IPHONE_PORTRAIT_PHOTO.width, IPHONE_PORTRAIT_PHOTO.height};
    //imageView.size = IPHONE_PORTRAIT_PHOTO;
    imageView.alpha = 1;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth
        | UIViewAutoresizingFlexibleHeight;
      imageView.backgroundColor = [UIColor blackColor];
      imageView.layer.cornerRadius = 10;
      imageView.layer.masksToBounds = YES;
      

  });

}

- (UIColor *)averageColor: (UIImage *) image {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:.9];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:.9];
    }
}

-(BOOL) isLightColor:(UIColor*)clr {
    CGFloat white = 0;
    [clr getWhite:&white alpha:nil];
    return (white >= 0.5);
}

@end
