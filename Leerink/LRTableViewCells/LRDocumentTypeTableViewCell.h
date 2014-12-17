//
//  LRDocumentTypeTableViewCell.h
//  Leerink
//
//  Created by Ashish on 13/08/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRLoadDataDelegate.h"

@interface LRDocumentTypeTableViewCell : UITableViewCell
- (void)fillDataForDocumentCellwithTitle:(NSString *)title andDateTime:(NSString *)date andAuthor:(NSString *)author andisDocumentSelected:(BOOL)isSelected hasMultipleAuthors:(BOOL)hasMultipleAuthors showTextOnlyIcon:(BOOL)showTextOnlyIcon;
@property (nonatomic, assign) id <LRLoadDataDelegate> delegate;
@end
