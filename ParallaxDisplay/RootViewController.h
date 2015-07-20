//
//  RootViewController.h
//  SecretTestApp
//
//  Created by Aaron Pang on 3/28/14.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JukeboxEntry.h"
@interface RootViewController : UIViewController

-(id) initWithJukeBox:(JukeboxEntry *) jukeboxEntry;
@end
