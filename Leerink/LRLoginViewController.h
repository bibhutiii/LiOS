//
//  LRLoginViewController.h
//  Leerink
//
//  Created by Ashish on 21/04/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRLoadDataDelegate.h"
@interface LRLoginViewController : UIViewController<UITextFieldDelegate,LRLoadDataDelegate>

@property (nonatomic, assign) BOOL isDocumentFromNotification;
@end
