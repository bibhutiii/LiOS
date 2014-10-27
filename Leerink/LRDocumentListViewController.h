//
//  LRDocumentListViewController.h
//  Leerink
//
//  Created by Ashish on 22/04/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRLoadDataDelegate.h"

@interface LRDocumentListViewController : UIViewController<LRLoadDataDelegate,UIWebViewDelegate>

@property (nonatomic, assign) eLRDocumentType documentType;
@property (nonatomic, assign) eLRDocumentListType documentListType;
@property (nonatomic, assign) int documentTypeId;
@property (nonatomic, strong) id contextInfo;
@end
