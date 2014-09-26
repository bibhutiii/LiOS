//
//  LRDocumentViewController.h
//  Leerink
//
//  Created by Ashish on 11/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRParentNavigationController.h"
#import "LRLoadDataDelegate.h"

@interface LRDocumentViewController : LRParentNavigationController<LRLoadDataDelegate>

@property (nonatomic, assign) int documentId;
@property (nonatomic, assign) int userId;
@property (nonatomic, strong) NSString *documentPath;
@property (nonatomic, strong) NSString *documentType;

@end
