//
//  LRParentNavigationController.m
//  Leerink
//
//  Created by Ashish on 9/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRParentNavigationController.h"
#import "LRAppDelegate.h"
#import "LRLoginViewController.h"
#import "LRUserRoles.h"
#import "LRCoreDataHelper.h"

@interface LRParentNavigationController ()
{
    NSMutableData *webData;
    NSXMLParser *xmlParser;
    NSString *finaldata;
    NSMutableString *nodeContent;
    NSMutableDictionary *resultDictionary;
}
@end

@implementation LRParentNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:204/255.0 green:219/255.0 blue:230/255.0 alpha:1];
    } else {
        // Load resources for iOS 7 or later
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204/255.0 green:219/255.0 blue:230/255.0 alpha:1];
    }
    self.navigationController.navigationBar.translucent = NO;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f],
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                      }];
    
    SEL aLogoutButton = sel_registerName("logOut");
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Logout-32"] style:0 target:self action:aLogoutButton];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = backButton;
    
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *aUserArray = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRUserRoles" withPredicate:@"userRoleId == %d",[[aStandardUserDefaults objectForKey:@"loggedInUSerId"] intValue], nil];
    if(aUserArray.count) {
        LRUserRoles *aUserRole = (LRUserRoles *)[aUserArray objectAtIndex:0];
        self.title = aUserRole.userRole;

    }
}
- (void)logOut
{
    UIAlertView *aLogOutAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                               message:[NSString stringWithFormat:@"Are you sure you want to logout?"]
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"No", @"")
                                                     otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    [aLogOutAlertView setTag:200];
    [aLogOutAlertView show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 200) {
        if(buttonIndex == 1) {
            [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait..."];
            LRLogOutService *aLogoutService = [[LRLogOutService alloc] initWithURL:[NSURL URLWithString:@"http://10.0.100.40:8081/iOS_QA/Service1.svc?singleWsdl"]];
            aLogoutService.delegate = self;
            [aLogoutService logOutUserWithIndicatorInView:self.view];
        }
    }
}
#pragma mark - LogOut delegate methods
- (void)isLogOutSuccessfull:(BOOL)value
{
    if(value) {
        [LRUtility stopActivityIndicatorFromView:self.view];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone?@"Main_iPhone":@"Main_iPad" bundle:nil];
        LRLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([LRLoginViewController class])];
        [[LRAppDelegate myAppdelegate].window setRootViewController:loginVC];
        UIAlertView *aLogOutAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                   message:[NSString stringWithFormat:@"Log out succesfull"]
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                         otherButtonTitles:nil, nil];
        [aLogOutAlertView show];
        
    }
    else {
        UIAlertView *aLogOutAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                   message:[NSString stringWithFormat:@"Log out unsuccesfull"]
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                         otherButtonTitles:nil, nil];
        [aLogOutAlertView show];
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
