//
//  Created by matt on 28/09/12.
//  Additions by Marin Todorov for YouTube JSONModel tutorial

#import "MGLine.h"
#import "MGBox.h"
#import "AHKActionSheet.h"
#import "JBCoreDataStack.h"
#import "Song.h"
#import "VideoModel.h"
@interface SongCell : MGBox

+(SongCell *)photoBoxForVideo:(VideoModel*)video withSize:(CGSize) size withLine: (BOOL) drawLine;

@property (strong, nonatomic) VideoModel *video;
@property (nonatomic, assign) BOOL drawLine;


@end
