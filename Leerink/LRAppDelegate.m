//
//  AppDelegate.m
//  Leerink
//
//  Created by Ashish on 21/04/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

// local login id and password
//    sean.finger@leerink.commedatest.com
//    LeerSav08

// qa portal login id and password
// MaryEllen.Eagan@leerink.commedatest.com
// CarinaNebula12

#import "LRAppDelegate.h"
#import "LRLoginViewController.h"
#import "LRMainClientPageViewController.h"
#import <Parse/Parse.h>
#import "LRWebEngine.h"
#import "LRDocumentViewController.h"
#import <Crashlytics/Crashlytics.h>

@implementation LRAppDelegate
@synthesize coreDataHelper;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

// return the Appdelegate and the storyboard from these class methods.
+ (LRAppDelegate *)myAppdelegate
{
    return (LRAppDelegate *)[[UIApplication sharedApplication] delegate];
}
+ (UIStoryboard *)myStoryBoard
{
    return [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
}
+ (NSArray *)fetchDataFromPlist
{
    NSError *error;
    NSString *path = [self fetchPathOfCustomPlist];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Document" ofType:@"plist"]; //5
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    return [data objectForKey:@"docIds"];
}
+ (NSString *)fetchPathOfCustomPlist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Document.plist"]; //3
    
    return path;
}

- (BOOL) isUserLoggedIn
{
    if([self.window.rootViewController isKindOfClass:([LRLoginViewController class])]) {
        return FALSE;
    }
    return TRUE;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Let the device know we want to receive push notifications
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    // initialise the core data helper singleton class
    if (!self.coreDataHelper) {
        self.coreDataHelper = [LRCoreDataHelper new];
        [self.coreDataHelper setupCoreData];
    }
    // [[NSUserDefaults standardUserDefaults] setObject:[userInfo objectForKey:@"DId"] forKey:@""];
    LRMainClientPageViewController *aMainClientPAgeController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRMainClientPageViewController class])];
    self.aBaseNavigationController = [[UINavigationController alloc] initWithRootViewController:aMainClientPAgeController];
    [self.aBaseNavigationController.navigationBar setTranslucent:NO];
    
 /*   if([[[NSUserDefaults standardUserDefaults] objectForKey:@"IsInternalUser"] boolValue] == TRUE) {
        
       [self resetUserDefaultValues];
        LRLoginViewController *loginVC = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRLoginViewController class])];
        [self.window setRootViewController:loginVC];
    }
    else {*/
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"SessionId"] != nil)
        {
            [LRUtility startActivityIndicatorOnView:self.window.rootViewController.view withText:@"Please wait.."];
            
            [[LRWebEngine defaultWebEngine] sendRequestToCheckSessionIsValidforResponseBlock:^(NSDictionary *responseDictionary) {
                if([[responseDictionary objectForKey:@"StatusCode"] intValue] == 401) {
                    //Add the login view controller as the root controller of the app window
                    
                   [self resetUserDefaultValues];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                             message:@"Session expired"
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                   otherButtonTitles:nil, nil];
                    [errorAlertView show];
                    
                    [LRUtility stopActivityIndicatorFromView:self.window.rootViewController.view];
                    LRLoginViewController *loginVC = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRLoginViewController class])];
                    [self.window setRootViewController:loginVC];
                    
                }
                else {
                    // direct the user to the main client page controller if already logged in.
                    [LRUtility stopActivityIndicatorFromView:self.window.rootViewController.view];
                    [self.window setRootViewController:self.aBaseNavigationController];
                }
                
            } errorHandler:^(NSError *errorString) {
                [LRUtility stopActivityIndicatorFromView:self.window.rootViewController.view];
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                         message:[errorString description]
                                                                        delegate:self
                                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                               otherButtonTitles:nil, nil];
                [errorAlertView show];
                DLog(@"%@\t%@\t%@\t%@", [errorString localizedDescription], [errorString localizedFailureReason],
                     [errorString localizedRecoveryOptions], [errorString localizedRecoverySuggestion]);
                
            }];
        }
        else {
            LRLoginViewController *loginVC = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRLoginViewController class])];
            [self.window setRootViewController:loginVC];
        }
    //}
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    self.window.tintColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    [Parse setApplicationId:@"0921QnBasJhIv1cFQkxC8f4aJupFnUbIuCnq8qB6"
                  clientKey:@"CrXy8wSEnkuvmm67ebWMbEOpzFbUA55dI3MFtLjL"];
    
    [Crashlytics startWithAPIKey:@"538f8236cc2bab28cc8de91308000df9c232a03d"];
    
    /* Enabling device logs*/
#if ENABLE_DEVICE_LOGS == 1
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fileName =[NSString stringWithFormat:@"%@.log",[NSDate date]];
    
    NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    
#endif
    
    return YES;
}

#pragma mark - Orientation methods
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    NSUInteger orientations = UIInterfaceOrientationMaskAllButUpsideDown;
    
    if(self.window.rootViewController){
        UIViewController *presentedViewController = [[self.aBaseNavigationController viewControllers] lastObject];
        orientations = [presentedViewController supportedInterfaceOrientations];
    }
    
    return orientations;
}
#pragma mark - Core data methods
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
- (NSManagedObjectContext *) createManagedObjectContext
{
    if (_persistentStoreCoordinator != nil)
    {
        NSManagedObjectContext * moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [moc setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];
        [moc performBlockAndWait:^{
            [moc setPersistentStoreCoordinator: self.persistentStoreCoordinator];
        }];		return moc;
    }
    else
        return nil;
}
#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"leerink" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"leerink.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark -
#define debug 1

- (LRCoreDataHelper*)cdh {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!self.coreDataHelper) {
        self.coreDataHelper = [LRCoreDataHelper new];
        [self.coreDataHelper setupCoreData];
    }
    return self.coreDataHelper;
}
#pragma mark - Push notification code
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:@"DeviceId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    //  [PFPush handlePush:userInfo];
    // check if the user is already logged in or session has not expired yet.
    NSLog(@"%@",userInfo);
    NSDictionary *aNotificationDetailsDictionary = [userInfo objectForKey:@"aps"];
    [[NSUserDefaults standardUserDefaults] setObject:[userInfo objectForKey:@"DId"] forKey:@"NotificationDocId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    LRLoginViewController *loginVC = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRLoginViewController class])];
    
    if([[LRAppDelegate myAppdelegate] isUserLoggedIn] == TRUE) {
        LRDocumentViewController *aDocumentViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentViewController class])];
        UIApplicationState state = [application applicationState];
        if (state == UIApplicationStateActive)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Leerink" message:[aNotificationDetailsDictionary objectForKey:@"alert"] delegate:self cancelButtonTitle:@"ok" otherButtonTitles: @"cancel", nil];
            if([self.aBaseNavigationController.visibleViewController isKindOfClass:([LRDocumentViewController class])]) {
                NSLog(@"it is document view conroller");
                alert.tag = 1000;
            }
            else {
                alert.tag = 2000;
            }
            [alert show];
        }
        else {
            // Push Notification received in the background
            if([self.aBaseNavigationController.visibleViewController isKindOfClass:([LRDocumentViewController class])]) {
                NSLog(@"it is document view conroller");
                aDocumentViewController.documentId = [userInfo objectForKey:@"DId"];
                [aDocumentViewController fetchDocument];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NotificationDocId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            else {
                aDocumentViewController.documentId = [userInfo objectForKey:@"DId"];
                [self.aBaseNavigationController pushViewController:aDocumentViewController animated:TRUE];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NotificationDocId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
        }
        
        loginVC.isDocumentFromNotification = FALSE;
    }
    else {
        loginVC.isDocumentFromNotification = TRUE;
        [self.window setRootViewController:loginVC];
    }
    
}
#pragma mark - Alert View delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    LRDocumentViewController *aDocumentViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentViewController class])];
    if(alertView.tag == 1000) {
        if(buttonIndex == 0) {
            aDocumentViewController.documentId = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationDocId"];
            [aDocumentViewController fetchDocument];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NotificationDocId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
    }
    if(alertView.tag == 2000) {
        if(buttonIndex == 0) {
            aDocumentViewController.documentId = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationDocId"];
            [self.aBaseNavigationController pushViewController:aDocumentViewController animated:TRUE];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NotificationDocId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
    }
}
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[self cdh] saveContext];
    
  /*  NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"SessionId"]);
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"IsInternalUser"] boolValue] == TRUE) {
            [LRUtility startActivityIndicatorOnView:self.window withText:@"Please wait.."];
            [[LRWebEngine defaultWebEngine] sendRequestToLogOutWithwithContextInfo:nil forResponseBlock:^(NSDictionary *responseDictionary) {
                if([[responseDictionary objectForKey:@"StatusCode"] intValue] == 200) {
                    
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SessionId"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PrimaryRoleID"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FirstName"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LastName"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DocList"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserId"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IsInternalUser"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [LRUtility stopActivityIndicatorFromView:self.window];
                    
                    LRLoginViewController *loginVC = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRLoginViewController class])];
                    [[LRAppDelegate myAppdelegate].window setRootViewController:loginVC];
                    
                }
                
            } errorHandler:^(NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Leerink" message:[error description] delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil, nil];
                [alert show];
                [LRUtility stopActivityIndicatorFromView:self.window];
                DLog(@"%@\t%@\t%@\t%@", [error localizedDescription], [error localizedFailureReason],
                     [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
            }];
    }
    */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
 /*   if([[[NSUserDefaults standardUserDefaults] objectForKey:@"IsInternalUser"] boolValue] == TRUE) {
        
        [self resetUserDefaultValues];
        
        LRLoginViewController *loginVC = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRLoginViewController class])];
        [self.window setRootViewController:loginVC];
    }
    else {*/
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"SessionId"] != nil)
        {
            [LRUtility startActivityIndicatorOnView:self.window.rootViewController.view withText:@"Please wait.."];
            [[LRWebEngine defaultWebEngine] sendRequestToCheckSessionIsValidforResponseBlock:^(NSDictionary *responseDictionary) {
                if([[responseDictionary objectForKey:@"StatusCode"] intValue] == 401) {
                    
                    [self resetUserDefaultValues];
                    
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                             message:@"Session expired"
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                   otherButtonTitles:nil, nil];
                    [errorAlertView show];
                    
                    //Add the login view controller as the root controller of the app window
                    [LRUtility stopActivityIndicatorFromView:self.window.rootViewController.view];
                    LRLoginViewController *loginVC = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRLoginViewController class])];
                    [self.window setRootViewController:loginVC];
                    
                }
                else {
                    // direct the user to the main client page controller if already logged in.
                    [LRUtility stopActivityIndicatorFromView:self.window.rootViewController.view];
                    [self.window setRootViewController:self.aBaseNavigationController];
                }
                
            } errorHandler:^(NSError *errorString) {
                [LRUtility stopActivityIndicatorFromView:self.window.rootViewController.view];
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                         message:[errorString description]
                                                                        delegate:self
                                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                               otherButtonTitles:nil, nil];
                [errorAlertView show];
                DLog(@"%@\t%@\t%@\t%@", [errorString localizedDescription], [errorString localizedFailureReason],
                     [errorString localizedRecoveryOptions], [errorString localizedRecoverySuggestion]);
                
            }];
        }
    //}
    
}
// reset all the values stored in NSUserDefaults when there is an internal user or if the user is logged out etc.
- (void)resetUserDefaultValues
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SessionId"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PrimaryRoleID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FirstName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LastName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DocList"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserId"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IsInternalUser"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NotificationDocId"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[self cdh] saveContext];
    // [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SessionId"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end
