//
//  LRTweets.h
//  Leerink
//
//  Created by Ashish on 9/10/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LRTweets : NSManagedObject

@property (nonatomic, retain) NSString * tweet;
@property (nonatomic, retain) id memberImage;

@end
