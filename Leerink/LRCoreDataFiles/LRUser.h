//
//  LRUser.h
//  Leerink
//
//  Created by Ashish on 21/08/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LRUser : NSManagedObject

@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * roleId;
@property (nonatomic, retain) NSString * userName;

@end
