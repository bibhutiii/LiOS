//
//  LRUserTimeLineTwitterViewController.h
//  Leerink
//
//  Created by Ashish on 20/10/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRTwitterListTableViewCell.h"

@interface LRUserTimeLineTwitterViewController : UIViewController<LRLoadURLDelegate>

@property (nonatomic, strong) NSString *tweetUserName;
@end
