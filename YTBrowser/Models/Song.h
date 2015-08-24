//
//  Song.h
//  YTBrowser
//
//  Created by Matan Vardi on 5/17/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * videoId;
@end
