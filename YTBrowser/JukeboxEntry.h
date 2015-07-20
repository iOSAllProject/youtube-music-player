//
//  JukeboxEntry.h
//  YTBrowser
//
//  Created by Matan Vardi on 7/19/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//
#import <Foundation/Foundation.h>
@interface JukeboxEntry : NSObject

@property (nonatomic,strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSArray *songs;
@end