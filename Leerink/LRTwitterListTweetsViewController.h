//
//  LRTwitterListTweetsViewController.h
//  Leerink
//
//  Created by Ashish on 9/10/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRTwitterList.h"
#import "LRTwitterListTableViewCell.h"
#import "MNMPullToRefreshManager.h"


@interface LRTwitterListTweetsViewController : UIViewController<LRLoadURLDelegate,MNMPullToRefreshManagerClient>

@property (nonatomic, strong) LRTwitterList *aTwitterList;
@property (nonatomic, assign) BOOL isTwitterListCountMoreThanOne;
@end
