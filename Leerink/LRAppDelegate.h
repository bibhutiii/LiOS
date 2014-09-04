//
//  AppDelegate.h
//  Leerink
//
//  Created by Ashish on 4/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRCRMListViewController.h"
#import "LRCoreDataHelper.h"

@interface LRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UINavigationController *aBaseNavigationController;
@property (nonatomic, strong) LRCoreDataHelper *coreDataHelper;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (NSManagedObjectContext *) createManagedObjectContext;

@end
