//
//  Created by matt on 28/09/12.
//  Additions by Marin Todorov for YouTube JSONModel tutorial

#import "MGLine.h"
#import "MGBox.h"

@interface PhotoBox : MGBox

+(PhotoBox *)photoBoxForURL:(NSURL*)url title:(NSString*)title withSize:(CGSize) size;

@property (strong, nonatomic) NSString* titleString;

@end
