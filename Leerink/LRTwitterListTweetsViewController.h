//
//  LRTwitterListTweetsViewController.h
//  Leerink
//
//  Created by Ashish on 9/10/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRTwitterListTableViewCell.h"
#import "MNMPullToRefreshManager.h"


@interface LRTwitterListTweetsViewController : UIViewController<LRLoadURLDelegate,MNMPullToRefreshManagerClient>

@property (strong, nonatomic) NSMutableArray *tweetsListArray;
@property (nonatomic, assign) BOOL isTwitterListCountMoreThanOne;
@property (strong, nonatomic) NSString *aTwitterListScreenName;
@property (strong, nonatomic) NSString *aTwitterListOwnerId;
@property (strong, nonatomic) NSString *aTwitterListSlug;
@end
