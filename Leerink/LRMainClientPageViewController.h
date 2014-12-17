//
//  LRMainClientPageViewController.h
//  Leerink
//
//  Created by Ashish on 19/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMPullToRefreshManager.h"
#import "LRLoadDataDelegate.h"

@interface LRMainClientPageViewController : UIViewController<UIActionSheetDelegate,MNMPullToRefreshManagerClient,LRLoadDataDelegate,UITextFieldDelegate>

@end
