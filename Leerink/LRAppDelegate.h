//
//  AppDelegate.h
//  Leerink
//
//  Created by Ashish on 4/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRDocumentViewController.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface LRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
// the base navigation controller from where all the other controllers like lists,twitter will be pushed.
@property (strong, nonatomic) UINavigationController *aBaseNavigationController;
@property (nonatomic, assign) BOOL documentFetchedFromNotification;
@property (weak, nonatomic) LRDocumentViewController *lrDocumentViewController;




// class methods to fetch the storyboard and the appdelegare instead of defining them everywhere.
+ (LRAppDelegate *)myAppdelegate;
+ (UIStoryboard *)myStoryBoard;
+ (NSArray *)fetchDataFromPlist;
+ (NSString *)fetchPathOfCustomPlist;
- (void)autoLoginAfterPassWordReset;
- (void)cancelledPasswordResetController;
- (BOOL) isUserLoggedIn;
- (void)resetUserDefaultValues;
- (void)setupAudio;


@end
