//
//  LRDocumentListViewController.h
//  Leerink
//
//  Created by Ashish on 22/04/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRLoadDataDelegate.h"


@interface LRDocumentListViewController : UIViewController<LRLoadDataDelegate,UIWebViewDelegate,UISearchControllerDelegate,UISearchBarDelegate>

@property (nonatomic, assign) id <LRLoadDataDelegate> delegate;
@property (nonatomic, assign) eLRDocumentType documentType;
@property (nonatomic, assign) eLRDocumentListType documentListType;
@property (nonatomic, assign) int documentTypeId;
@property (nonatomic, strong) id contextInfo;
@property (strong, nonatomic) NSMutableArray *documentsListArray;
@property (strong, nonatomic) NSString *returnTypeForMenu;
@property (strong, nonatomic) NSString *menuItemId;
@property (strong, nonatomic) NSString *parentMenuItemId;


@property (nonatomic,assign) BOOL isDocumentsFetchedForList;
@end
