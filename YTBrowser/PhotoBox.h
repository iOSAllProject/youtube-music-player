//
//  Created by matt on 28/09/12.
//  Additions by Marin Todorov for YouTube JSONModel tutorial

#import "MGLine.h"
#import "MGBox.h"
#import "AHKActionSheet.h"
#import "JBCoreDataStack.h"
#import "Song.h"
#import "VideoModel.h"
@interface PhotoBox : MGBox

+(PhotoBox *)photoBoxForVideo:(VideoModel*)video withSize:(CGSize) size;

@property (strong, nonatomic) VideoModel *video;

@end
