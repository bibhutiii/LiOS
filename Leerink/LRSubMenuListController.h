//
//  LRdocumentTypeListViewController.h
//  Leerink
//
//  Created by Ashish on 30/07/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRSubMenuListController : UIViewController<LRLoadDataDelegate,UISearchBarDelegate>

@property (strong, nonatomic) NSString *titleHeader;
@property (assign, nonatomic) eLRDocumentType eDocumentType;
@property (nonatomic, assign) id <LRLoadDataDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *subMenuItemsArray;
@property (strong, nonatomic) NSString *returnTypeForMenu;
- (void)didLoadData;
@end
