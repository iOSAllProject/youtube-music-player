//
//  JukeboxEntry.h
//  YTBrowser
//
//  Created by Matan Vardi on 7/19/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface JukeboxEntry : NSObject
@property (nonatomic,strong) NSString *objectId;
@property (nonatomic,strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *authorId;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSArray *songs;
@property (nonatomic, strong) NSString *currentlyPlaying;
@property  NSInteger elapsedTime;
@property  BOOL isPlaying;
@property  (nonatomic, readwrite) CLLocationCoordinate2D location;
@end
