//
//  VideoModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

#import "VideoLink.h"


@interface VideoModel : JSONModel

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString *videoId;
@property (strong, nonatomic) NSString *thumbnail;
@property (strong, nonatomic) NSString *largeImg;

@end
