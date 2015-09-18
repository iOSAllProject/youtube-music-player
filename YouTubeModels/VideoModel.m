//
//  VideoModel.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "VideoModel.h"

@implementation VideoModel

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
            @"snippet.title": @"title",
            @"id.videoId":@"videoId",
            @"snippet.thumbnails.high.url":@"thumbnail",
            }];
}

@end
