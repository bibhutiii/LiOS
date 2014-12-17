//
//  LRContactListTableViewCell.h
//  Leerink
//
//  Created by Ashish on 9/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRLoadDataDelegate.h"

@interface LRContactListTableViewCell : UITableViewCell
- (void)fillDataForContactCellwithName:(NSString *)contactName;
- (void)fillDataForMenuCellWithDisplayName:(NSString *)displayName andIconImage:(UIImage *)image;

@property (nonatomic, assign) id <LRLoadDataDelegate> delegate;
@end
