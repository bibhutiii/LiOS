//
//  LRUserRoles.h
//  Leerink
//
//  Created by Ashish on 21/08/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LRUserRoles : NSManagedObject

@property (nonatomic, retain) NSString * userRole;
@property (nonatomic, retain) NSNumber * userRoleId;

@end
