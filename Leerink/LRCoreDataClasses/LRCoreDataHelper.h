//
//  LRCoreDataHelper.h
//  Leerink
//
//  Created by Ashish on 23/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface LRCoreDataHelper :NSObject

@property (nonatomic, strong) NSManagedObjectContext       *context;
@property (nonatomic, strong) NSManagedObjectModel         *model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, strong) NSPersistentStore            *store;

- (void)setupCoreData;
- (void)saveContext;

- (id)init;

+ (LRCoreDataHelper *) sharedStorageManager;
+ (LRCoreDataHelper *) createStorageManager;

- (void)setSortDescriptors: (NSString *) firstArgument, ... NS_REQUIRES_NIL_TERMINATION;

- (NSArray *) fetchObjectsForEntityName:(NSString *)newEntityName
                          withPredicate:(id)stringOrPredicate, ... NS_REQUIRES_NIL_TERMINATION;
//Block based
- (void)fetchObjectsForEntityName:(NSString *)newEntityName
                    withPredicate:(NSString *)inPredicate
                  completionBlock:(void (^)(NSArray *objects))inCompletionBlock;

- (NSManagedObject *)createManagedObjectForName:(NSString *)objectName inContext:(NSManagedObjectContext *)passedManagedObjectContext;

@end