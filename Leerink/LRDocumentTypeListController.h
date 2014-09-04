//
//  LRdocumentTypeListViewController.h
//  Leerink
//
//  Created by Ashish on 30/07/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRParentNavigationController.h"

@interface LRDocumentTypeListController : LRParentNavigationController<LRLoadDataDelegate,UISearchBarDelegate>
@property (strong, nonatomic) NSString *titleHeader;
@property (assign, nonatomic) eLRDocumentType eDocumentType;
@end
