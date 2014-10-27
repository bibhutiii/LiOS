//
//  LRTwitterListTableViewCell.h
//  Leerink
//
//  Created by Ashish on 26/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LRLoadURLDelegate;

@interface LRTwitterListTableViewCell : UITableViewCell
- (void)fillDataForDocumentCellwithTwitterListMemberName:(NSString *)memberName andMemberImage:(id )image;
- (void)fillDataForTweetCellWithTweet:(NSString *)iTweet andMemberImage:(id )image andDate:(NSString *)iDate;
@property (nonatomic, assign) id <LRLoadURLDelegate> delegate;
@end

@protocol LRLoadURLDelegate <NSObject>

- (void)loadWebViewWithURL:(NSString *)url;
@end