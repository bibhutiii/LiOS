//
//  LRTwitterListTweetsViewController.h
//  Leerink
//
//  Created by Ashish on 9/10/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRParentNavigationController.h"
#import "LRTwitterList.h"

@interface LRTwitterListTweetsViewController : LRParentNavigationController

@property (nonatomic, strong) LRTwitterList *aTwitterList;
@property (nonatomic, assign) BOOL isTwitterListCountMoreThanOne;
@end
