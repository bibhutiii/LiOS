//
//  LRDocumentListViewController.h
//  Leerink
//
//  Created by Ashish on 22/04/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRParentNavigationController.h"
#import "LRLoadDataDelegate.h"

@interface LRDocumentListViewController : LRParentNavigationController<LRLoadDataDelegate>

@property (nonatomic, assign) eLRDocumentType documentType;
@property (nonatomic, assign) int documentTypeId;
@end
