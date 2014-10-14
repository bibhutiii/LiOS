//
//  LRTwitterList.h
//  Leerink
//
//  Created by Ashish on 9/10/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LRTwitterList : NSManagedObject

@property (nonatomic, retain) NSString * listName;
@property (nonatomic, retain) NSString * listScreenName;
@property (nonatomic, retain) NSString * listOwnerId;
@property (nonatomic, retain) NSString * listSlug;
@property (nonatomic, retain) id listImage;

@end
