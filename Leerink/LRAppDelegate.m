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
#import <CrashReporter/CrashReporter.h>
#import "CrashHelper.h"
#import "LRTermsAndConditionsViewController.h"
#import "MediaManager.h"

@implementation LRAppDelegate


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

/*http://localhost/IRP/Portal/Web/FirstTimeLogin.aspx
 http://localhost/IRP/Portal/Web/ConsultantChangePassword.aspx*/
//DExt
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[CrashHelper sharedCrashHelper] checkForCrashes];
    [self setupAudio];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ok;
    NSError *setCategoryError = nil;
    ok = [audioSession setCategory:AVAudioSessionCategoryPlayback
                             error:&setCategoryError];
    if (!ok) {
        NSLog(@"%s setCategoryError=%@", __PRETTY_FUNCTION__, setCategoryError);
    }
    
    // Let the device know we want to receive push notifications
     if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]){
     [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil]];
     [[UIApplication sharedApplication] registerForRemoteNotifications];
     
     /*NSDictionary *RemoteNoti =[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
     if (RemoteNoti) {
     //your methods to process notification
     [[NSUserDefaults standardUserDefaults] setObject:@"pdf" forKey:@"DocumentPathForNotification"];
     [[NSUserDefaults standardUserDefaults] setObject:@"123" forKey:@"NotificationDocId"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     }*/
     
     }
     else{
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
     
     /*NSDictionary *RemoteNoti =[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
     if (RemoteNoti) {
     //your methods to process notification
     [[NSUserDefaults standardUserDefaults] setObject:@"pdf" forKey:@"DocumentPathForNotification"];
     [[NSUserDefaults standardUserDefaults] setObject:@"123" forKey:@"NotificationDocId"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     }*/
     
     }
    /*
     [Parse setApplicationId:@"0921QnBasJhIv1cFQkxC8f4aJupFnUbIuCnq8qB6"
     clientKey:@"CrXy8wSEnkuvmm67ebWMbEOpzFbUA55dI3MFtLjL"];
    */
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
                LRDocumentViewController *aDocumentViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentViewController class])];
                // direct the user to the main client page controller if already logged in.
                [LRUtility stopActivityIndicatorFromView:self.window.rootViewController.view];
                [self.window setRootViewController:self.aBaseNavigationController];
                
                
                if([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"NotificationDocId"]){
                    
                    NSLog(@"notification found");
                    aDocumentViewController.documentId = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationDocId"];
                    aDocumentViewController.documentPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"DocumentPathForNotification"];
                    if([self.aBaseNavigationController.visibleViewController isKindOfClass:([LRDocumentViewController class])]) {
                        [aDocumentViewController fetchDocument];
                    }
                    else {
                        [self.aBaseNavigationController pushViewController:aDocumentViewController animated:TRUE];
                    }
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NotificationDocId"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DocumentPathForNotification"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            
        } errorHandler:^(NSError *errorString) {
            [LRUtility stopActivityIndicatorFromView:self.window.rootViewController.view];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                     message:[errorString localizedDescription]
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
    
    //   [Crashlytics startWithAPIKey:@"538f8236cc2bab28cc8de91308000df9c232a03d"];
    
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
- (void)cancelledPasswordResetController
{
    LRLoginViewController *loginVC = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRLoginViewController class])];
    [self.window setRootViewController:loginVC];
}
- (void)autoLoginAfterPassWordReset
{
    LRLoginViewController *loginVC = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRLoginViewController class])];
    [self.window setRootViewController:loginVC];
    
    loginVC.userNameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    loginVC.passwordTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"PassWord"];
   
    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    [aRequestDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"] forKey:@"Username"];
    [aRequestDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"PassWord"] forKey:@"Password"];
    
    if(([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"DeviceId"])) {
        [aRequestDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceId"] forKey:@"DeviceId"];
    }
    else {
        [aRequestDict setObject:@"<9f829b9b 4ed9eaaf b070e85a def45657 169394da eb3d483e 14301960 c420bbc4>" forKey:@"DeviceId"];
    }
    [LRUtility startActivityIndicatorOnView:self.window.rootViewController.view withText:@"Please wait..."];
    
    [[LRWebEngine defaultWebEngine] sendRequestToLoginWithParameters:aRequestDict andResponseBlock:^(NSString *responseString) {
        
        NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(responseData) {
            NSDictionary *aResponseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
            if(![aResponseDictionary isKindOfClass:([NSNull class])]) {
                NSDictionary *aTempDictionary = [aResponseDictionary objectForKey:@"Data"];
                if([[aResponseDictionary objectForKey:@"IsSuccess"] boolValue] == TRUE) {
                    
                    [LRUtility stopActivityIndicatorFromView:self.window.rootViewController.view];
                    
                    if([[aTempDictionary objectForKey:@"FirstTimeLogin"] isEqualToString:@"HomePage"]) {
                        
                        [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"SessionId"] forKey:@"SessionId"];
                        //   [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"PrimaryRoleID"] forKey:@"PrimaryRoleID"];
                        [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"FirstName"] forKey:@"FirstName"];
                        [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"LastName"] forKey:@"LastName"];
                        [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"DocList"] forKey:@"DocList"];
                        [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"UserId"] forKey:@"UserId"];
                        [aStandardUserDefaults setObject:[NSNumber numberWithBool:[[aTempDictionary objectForKey:@"IsInternalUser"] boolValue]] forKey:@"IsInternalUser"];
                        
                        [aStandardUserDefaults synchronize];
                        
                        [[LRAppDelegate myAppdelegate].window setRootViewController:[LRAppDelegate myAppdelegate].aBaseNavigationController];
                    }
                }
                else {
                    [LRUtility stopActivityIndicatorFromView:self.window.rootViewController.view];
                    NSString *aMsgStr = nil;
                    if(![[aResponseDictionary objectForKey:@"Message"] isKindOfClass:([NSNull class])]) {
                        aMsgStr = [aResponseDictionary objectForKey:@"Message"];
                    }
                    else if(![[aResponseDictionary objectForKey:@"Error"] isKindOfClass:([NSNull class])]) {
                        aMsgStr = [aResponseDictionary objectForKey:@"Error"];
                    }
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                             message:aMsgStr
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                   otherButtonTitles:nil, nil];
                    [errorAlertView show];
                    
                }
            }
        }
        
        
    } errorHandler:^(NSError *errorString) {
        
        [LRUtility stopActivityIndicatorFromView:self.window.rootViewController.view];
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                 message:[errorString localizedDescription]
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                       otherButtonTitles:nil, nil];
        [errorAlertView show];
        DLog(@"%@\t%@\t%@\t%@", [errorString localizedDescription], [errorString localizedFailureReason],
             [errorString localizedRecoveryOptions], [errorString localizedRecoverySuggestion]);
        
        
    }];

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

#pragma mark - Push notification code
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    //   PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    //    [currentInstallation setDeviceTokenFromData:deviceToken];
    // [currentInstallation saveInBackground];
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:@"DeviceId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    //  [PFPush handlePush:userInfo];
    // check if the user is already logged in or session has not expired yet.
    NSLog(@"%@",userInfo);
    NSDictionary *aNotificationDetailsDictionary = [userInfo objectForKey:@"aps"];
    [[NSUserDefaults standardUserDefaults] setObject:@"pdf" forKey:@"DocumentPathForNotification"];
    [[NSUserDefaults standardUserDefaults] setObject:@"123" forKey:@"NotificationDocId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    LRLoginViewController *loginVC = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRLoginViewController class])];
    
    if([[LRAppDelegate myAppdelegate] isUserLoggedIn] == TRUE) {
        UIApplicationState state = [application applicationState];
        if (state == UIApplicationStateActive)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Leerink" message:[aNotificationDetailsDictionary objectForKey:@"alert"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: @"Cancel", nil];
            if([self.aBaseNavigationController.visibleViewController isKindOfClass:([LRDocumentViewController class])]) {
                NSLog(@"it is document view conroller");
                alert.tag = 1000;
            }
            else {
                alert.tag = 2000;
            }
            [alert show];
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification){
                [alert dismissWithClickedButtonIndex:1 animated:NO];
            }];
        }
        else {
            // Push Notification received in the background
            /*if([self.aBaseNavigationController.visibleViewController isKindOfClass:([LRDocumentViewController class])]) {
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
             
             }*/
        }
        
    }
    else {
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
            aDocumentViewController.documentPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"DocumentPathForNotification"];
            [aDocumentViewController fetchDocument];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NotificationDocId"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DocumentPathForNotification"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
    }
    if(alertView.tag == 2000) {
        if(buttonIndex == 0) {
            aDocumentViewController.documentId = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationDocId"];
            aDocumentViewController.documentPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"DocumentPathForNotification"];
            [self.aBaseNavigationController pushViewController:aDocumentViewController animated:TRUE];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NotificationDocId"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DocumentPathForNotification"];
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
    
    if([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"NotificationDocId"]){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NotificationDocId"];
    }
    if([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"DocumentPathForNotification"]){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DocumentPathForNotification"];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Leerink" message:[error localizedDescription] delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil, nil];
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
    LRDocumentViewController *aDocumentViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRDocumentViewController class])];
    
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
                if([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"NotificationDocId"]){
                    
                    NSLog(@"notification found");
                    aDocumentViewController.documentId = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationDocId"];
                    aDocumentViewController.documentPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"DocumentPathForNotification"];
                    if([self.aBaseNavigationController.visibleViewController isKindOfClass:([LRDocumentViewController class])]) {
                        [aDocumentViewController fetchDocument];
                    }
                    else {
                        [self.aBaseNavigationController pushViewController:aDocumentViewController animated:TRUE];
                    }
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NotificationDocId"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DocumentPathForNotification"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            
        } errorHandler:^(NSError *errorString) {
            [LRUtility stopActivityIndicatorFromView:self.window.rootViewController.view];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                     message:[errorString localizedDescription]
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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DocumentPathForNotification"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SessionId"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)setupAudio
{
    // Set AVAudioSession
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    
    // Change the default output audio route
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                            sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay)
        {
            NSLog(@"UIEventSubtypeRemoteControlPlay");
             [[MediaManager sharedInstance] play];
        }
        else if (event.subtype == UIEventSubtypeRemoteControlPause)
        {
            NSLog(@"UIEventSubtypeRemoteControlPause");
            [[MediaManager sharedInstance] pause];

        }
        else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause)
        {
            NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
        }
    }
}


@end
