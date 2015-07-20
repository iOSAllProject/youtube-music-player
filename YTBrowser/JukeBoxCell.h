//
//  Created by matt on 28/09/12.
//

#import "MGBox.h"
#import "JukeboxEntry.h"
#import "JukeboxListViewController.h"
#import "AppConstant.h"
@interface JukeBoxCell : MGBox
@property (nonatomic, strong) JukeboxEntry *jukeBoxEntry;+ (JukeBoxCell *)photoAddBoxWithSize:(CGSize)size;

+ (JukeBoxCell *)photoBoxFor:(int)i size:(CGSize)size;

- (void)loadPhoto;

@end
