//
//  _LNWeakRef.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface _LNWeakRef : NSObject

@property (nonatomic, weak) id object;

+ (instancetype)refWithObject:(id)object;

@end
