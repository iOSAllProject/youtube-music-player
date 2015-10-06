//
//  Created by matt on 28/09/12.
//

#import "MGBox.h"
#import "JukeboxEntry.h"
#import "JukeboxListViewController.h"
#import "AppConstant.h"

IB_DESIGNABLE
@interface JukeBoxCell : MGBox
@property (nonatomic, strong) JukeboxEntry *jukeBoxEntry;
+ (JukeBoxCell *)photoAddBoxWithSize:(CGSize)size;
@property (nonatomic) CGFloat scrollSize;
@property (nonatomic) NSInteger index;
//+ (JukeBoxCell *)photoBoxFor:(int)i size:(CGSize)size atIndex:(NSInteger) index withScrollSize:(CGFloat) scrollSize;
+(JukeBoxCell *)photoBoxFor:(JukeboxEntry*)jukeboxEntry size:(CGSize)size;
- (void)loadPhoto;
@property CGSize size;
@end
