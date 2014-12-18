//
//  LRGlobalSearchDocumentsListViewController.h
//  Leerink
//
//  Created by Ashish on 17/12/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRLoadDataDelegate.h"

@interface LRGlobalSearchDocumentsListViewController : UIViewController<UISearchControllerDelegate,UISearchBarDelegate,LRLoadDataDelegate>

@property (nonatomic, assign) id <LRLoadDataDelegate> delegate;
@property (nonatomic, assign) int documentTypeId;
@property (nonatomic, strong) id contextInfo;
@property (strong, nonatomic) NSMutableArray *globalSearchDocumentsListArray;
@property (strong, nonatomic) NSString *searchKeyWordsString;

@end
