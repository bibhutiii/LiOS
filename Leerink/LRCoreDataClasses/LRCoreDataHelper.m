//
//  LRCoreDataHelper.m
//  Leerink
//
//  Created by Ashish on 23/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRCoreDataHelper.h"
#import "LRAppDelegate.h"

@implementation LRCoreDataHelper
{
    NSMutableArray * sortDescriptors;
}

#define debug 1

#pragma mark - FILES
NSString *storeFilename = @"leerink.sqlite";

+ (LRCoreDataHelper *) sharedStorageManager
{
    
    if ([LRAppDelegate myAppdelegate].coreDataHelper.context == nil)
        [LRAppDelegate myAppdelegate].coreDataHelper.context = [LRAppDelegate myAppdelegate].managedObjectContext;
    
    return [LRAppDelegate myAppdelegate].coreDataHelper;
}
+ (LRCoreDataHelper *) createStorageManager
{
    LRCoreDataHelper * manager = [[LRCoreDataHelper alloc] init];
    manager.context = [[LRAppDelegate myAppdelegate] createManagedObjectContext];
    return manager;
}
#pragma mark - SETUP
- (id)init {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (!self) {return nil;}
    
    _model = [[NSManagedObjectModel alloc] initWithContentsOfURL: [[NSBundle mainBundle] URLForResource:@"leerink" withExtension:@"momd"]];
    _coordinator = [[NSPersistentStoreCoordinator alloc]
                    initWithManagedObjectModel:_model];
    _context = [[NSManagedObjectContext alloc]
                initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:_coordinator];
    return self;
}
#pragma mark - PATHS
- (NSString *)applicationDocumentsDirectory {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class,NSStringFromSelector(_cmd));
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) lastObject];
}
- (NSURL *)applicationStoresDirectory {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    NSURL *storesDirectory =
    [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]]
     URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtURL:storesDirectory
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&error]) {
            if (debug==1) {
                NSLog(@"Successfully created Stores directory");}
        }
        else {NSLog(@"FAILED to create Stores directory: %@", error);}
    }
    return storesDirectory;
}
- (NSURL *)storeURL {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [[self applicationStoresDirectory]
            URLByAppendingPathComponent:storeFilename];
}
- (void)loadStore {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_store) {return;} // Don't load store if it's already loaded
    NSError *error = nil;
    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:nil
                                                  URL:[self storeURL]
                                              options:nil error:&error];
    if (!_store) {NSLog(@"Failed to add store. Error: %@", error);abort();}
    else         {if (debug==1) {NSLog(@"Successfully added store: %@", _store);}}
}
- (void)setupCoreData {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self loadStore];
}
#pragma mark - SAVING
- (void)saveContext {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_context hasChanges]) {
        NSError *error = nil;
        if ([_context save:&error]) {
            NSLog(@"_context SAVED changes to persistent store");
        } else {
            NSLog(@"Failed to save _context: %@", error);
        }
    } else {
        NSLog(@"SKIPPED _context save, there are no changes!");
    }
}
- (NSManagedObject *)createManagedObjectForName:(NSString *)objectName inContext:(NSManagedObjectContext *)passedManagedObjectContext
{
    return [NSEntityDescription
            insertNewObjectForEntityForName: objectName
            inManagedObjectContext:passedManagedObjectContext];
}
/*
 
 Code samples quoted on each blog page and linked projects may be used in accordance with the following "zlib"-style license:
 
 Copyright (c) 2009-2011 Matt Gallagher. All rights reserved.
 
 This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software. Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 
 The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 This notice may not be removed or altered from any source distribution.
 This permission only applies to the code samples and code in the downloadable projects. The prose and artwork assets of this blog and its downloadable content may not be reproduced without prior consent.
 */

// The following method is used based on the license mentioned above.

// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
//
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
                         withPredicate:(id)stringOrPredicate, ...
{
    NSManagedObjectContext *newManagedObjectContext = self.context;
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:newEntityName inManagedObjectContext: newManagedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            if (! [stringOrPredicate isEqualToString: @""])
            {
                va_list variadicArguments;
                va_start(variadicArguments, stringOrPredicate);
                predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                                                   arguments:variadicArguments];
                va_end(variadicArguments);
                [request setPredicate:predicate];
            }
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd),  NSStringFromClass([stringOrPredicate class]) );
            predicate = (NSPredicate *)stringOrPredicate;
            [request setPredicate:predicate];
        }
        
    }
    if (sortDescriptors != nil)
    {
        [request setSortDescriptors: sortDescriptors];
        sortDescriptors = nil;
    }
    
    // [request setIncludesPendingChanges:YES];
    NSError *error = nil;
    
    NSArray *results = [newManagedObjectContext executeFetchRequest:request error:&error];
    
    if (error != nil)
    {
        [NSException raise:NSGenericException format: @"%@", [error description]];
    }
    
    return results;
}

- (void)fetchObjectsForEntityName:(NSString *)newEntityName
                    withPredicate:(NSString *)inPredicate
                  completionBlock:(void (^)(NSArray *objects))inCompletionBlock
{
    NSManagedObjectContext *newManagedObjectContext = self.context;
    
    __weak NSManagedObjectContext *weakManagedObjectContext = newManagedObjectContext;
    
    [newManagedObjectContext performBlock:^{
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:newEntityName inManagedObjectContext: weakManagedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        
        if (nil != inPredicate)
        {
            [request setPredicate:[NSPredicate predicateWithFormat:inPredicate]];
        }
        
        if (sortDescriptors != nil)
        {
            [request setSortDescriptors: sortDescriptors];
            sortDescriptors = nil;
        }
        
        NSError *error = nil;
        NSArray *results = [weakManagedObjectContext executeFetchRequest:request error:&error];
        if (error != nil)
        {
            [NSException raise:NSGenericException format: @"%@", [error description]];
        }
        inCompletionBlock(results);
    }];
}

// Pass a series of sort descriptiors.  Prepend with ! for descending sort order.
- (void) setSortDescriptors: (NSString *) firstArgument, ...
{
    sortDescriptors = [NSMutableArray arrayWithCapacity: 10];
    va_list args;
    va_start(args, firstArgument);
    for (NSString *arg = firstArgument; arg != nil; arg = va_arg(args, NSString*))
    {
        if ([[arg substringToIndex: 1] isEqualToString: @"!"])
            [sortDescriptors addObject: [NSSortDescriptor sortDescriptorWithKey:[arg substringFromIndex: 1] ascending: NO]];
        else
            [sortDescriptors addObject: [NSSortDescriptor sortDescriptorWithKey: arg ascending: YES]];
    }
}


@end
