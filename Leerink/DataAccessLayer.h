//
//  DataAccessLayer.h
//  Leerink
//
//  Created by Apple on 17/01/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataAccessLayer : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *storeCoordinator;

+ (DataAccessLayer *)sharedInstance;
- (void)saveContext;
- (void)insertData:(NSString *)fileName WithCurrentDuration:(float)currentLocation;

@end
