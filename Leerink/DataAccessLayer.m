//
//  DataAccessLayer.m
//  Leerink
//
//  Created by Apple on 17/01/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import "DataAccessLayer.h"

@interface DataAccessLayer ()
- (NSURL *)applicationDocumentsDirectory;
@end


@implementation DataAccessLayer

@synthesize storeCoordinator;
@synthesize managedObjectModel;
@synthesize managedObjectContext;

+ (DataAccessLayer *)sharedInstance {
    __strong static DataAccessLayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DataAccessLayer alloc] init];
        sharedInstance.storeCoordinator = [sharedInstance persistentStoreCoordinator];
        sharedInstance.managedObjectContext = [sharedInstance managedObjectContext];
    });
    return sharedInstance;
}

#pragma mark - Core Data

- (void)saveContext {
    NSError *error = nil;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"error: %@", error.userInfo);
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Something has gone terribly wrong! You need to reinstall the app in order for it to work properly."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Close."
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (managedObjectContext != nil)
    {
        return managedObjectContext;
    }
    
    if (storeCoordinator != nil)
    {
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:storeCoordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil)
    {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MP3_Details" withExtension:@"momd"];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (storeCoordinator != nil)
    {
        return storeCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MP3_Details.sqlite"];
    
    NSError *error = nil;
    self.storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"Something has gone terribly wrong! You need to reinstall the app in order for it to work properly."
                                                       delegate:nil
                                              cancelButtonTitle:@"Close."
                                              otherButtonTitles:nil, nil];
        [alert show];
    }    
    
    return storeCoordinator;
}

#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


-(void)insertData:(NSString *)fileName WithCurrentDuration:(float)currentLocation
{
    
    NSManagedObject *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"MP3_Details" inManagedObjectContext:[self managedObjectContext]];
    [newEntry setValue:fileName forKey:@"mp3FileName"];
    [newEntry setValue: [NSNumber numberWithFloat:currentLocation] forKey:@"currentLocation"] ;
    NSError *error = nil;
    if ([managedObjectContext save:&error]) {
        NSLog(@"data saved");
           }
    else{
        NSLog(@"Error occured while saving");
    }
}

@end
