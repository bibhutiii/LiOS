//
//  LRTweets.h
//  Leerink
//
//  Created by Ashish on 20/10/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LRTweets : NSManagedObject

@property (nonatomic, retain) id memberImage;
@property (nonatomic, retain) NSString * tweet;
@property (nonatomic, retain) NSString * tweetDate;
@property (nonatomic, retain) NSString * tweetScreenName;

@end
