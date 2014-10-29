//
//  AppDelegate.h
//  Leerink
//
//  Created by Ashish on 4/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRCoreDataHelper.h"

@interface LRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
// the base navigation controller from where all the other controllers like lists,twitter will be pushed.
@property (strong, nonatomic) UINavigationController *aBaseNavigationController;
// a core data helper class to avoid the methods to be written in appDelegate.
@property (nonatomic, strong) LRCoreDataHelper *coreDataHelper;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// class methods to fetch the storyboard and the appdelegare instead of defining them everywhere.
+ (LRAppDelegate *)myAppdelegate;
+ (UIStoryboard *)myStoryBoard;
+ (NSArray *)fetchDataFromPlist;
+ (NSString *)fetchPathOfCustomPlist;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (NSManagedObjectContext *) createManagedObjectContext;

@end
