//
//  LRTwitterListsViewController.h
//  Leerink
//
//  Created by Ashish on 26/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRTwitterListsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSArray *twitterListsArray;

@end
