//
//  RootViewController.h
//  SecretTestApp
//
//  Created by Aaron Pang on 3/28/14.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JukeboxEntry.h"
#import "JBCoreDataStack.h"
#import <MMX/MMX.h>
@interface JukeboxPostViewController : UIViewController

-(id) initWithJukeBox:(JukeboxEntry *) jukeboxEntry;
@property (nonatomic, strong) NSMutableArray *currentLibrary;
@property (atomic) BOOL isLiveChatShowing;
@property (nonatomic, strong) dispatch_queue_t concurrentPhotoQueue;
@property (nonatomic, strong) MMXMessage *messages;
@property (nonatomic, strong) MMXChannel *currentChannel;
@end
