//
//  LRLoginViewController.m
//  Leerink
//
//  Created by Ashish on 21/04/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRLoginViewController.h"
#import "RTCustomTextField.h"
#import "UITextField+previousNextToolBar.h"
#import "LRWebEngine.h"
#import "LRAppDelegate.h"
#import "LRUser.h"
#import "LRUserRoles.h"
#import "LRLoginService.h"

#define fontHelveticaNeueSize14 [UIFont systemFontOfSize:14.0]

@interface LRLoginViewController ()
{
    NSMutableArray *prevNextArray;
    UITextField *_refTextField;
    
}
#pragma mark - Add the user roles to the database
- (void) addTheUserRolesToDatabase;
@end

@implementation LRLoginViewController

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
    self.userNameTextField.frame = CGRectMake(45.0, 154.0, 206.0, self.userNameTextField.frame.size.height);
    self.userNameTextField.textColor = [UIColor colorWithRed:65.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1.0];
    self.userNameTextField.layer.cornerRadius = 3.0;
    self.userNameTextField.backgroundColor = [UIColor whiteColor];
    self.userNameTextField.font = fontHelveticaNeueSize14;
    self.userNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.userNameTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.userNameTextField.delegate = self;
    self.userNameTextField.tag = 1;
    
    self.passwordTextField.frame = CGRectMake(45.0, 209.0, 206.0, 32.0);
    self.passwordTextField.textColor = [UIColor colorWithRed:65.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1.0];
    self.passwordTextField.layer.cornerRadius = 3.0;
    self.passwordTextField.backgroundColor = [UIColor whiteColor];
    self.passwordTextField.font = fontHelveticaNeueSize14;
    self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordTextField.keyboardType = UIKeyboardTypeDefault;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passwordTextField.delegate = self;
    self.passwordTextField.tag = 2;
    
    prevNextArray = [[NSMutableArray alloc]initWithObjects:self.userNameTextField,self.passwordTextField, nil];
    
}

#pragma mark -
- (IBAction)logIn:(id)sender {
    
    // check if the username and password fields are not left empty.
    if([self.userNameTextField.text length] == 0) {
        UIAlertView *aUserNameAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                     message:[NSString stringWithFormat:@"Please enter a username"]
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                           otherButtonTitles:nil, nil];
        [aUserNameAlertView show];
        return;
    }
    else if([self.passwordTextField.text length] == 0) {
        UIAlertView *aPassWordAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                     message:[NSString stringWithFormat:@"Please enter a password"]
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                           otherButtonTitles:nil, nil];
        [aPassWordAlertView show];
        return;
    }
    
    // based on the login add the static user roles to the database.
    [self addTheUserRolesToDatabase];
    /////
    
    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    [aRequestDict setObject:self.userNameTextField.text forKey:@"Username"];
    [aRequestDict setObject:self.passwordTextField.text forKey:@"Password"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceId"] != nil) {
        [aRequestDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceId"] forKey:@"DeviceId"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.userNameTextField.text forKey:@"UserName"];

    [[LRAppDelegate myAppdelegate].window setRootViewController:[LRAppDelegate myAppdelegate].aBaseNavigationController];
   /* [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait..."];
    
    [[LRWebEngine defaultWebEngine] sendRequestToLoginWithParameters:aRequestDict andResponseBlock:^(NSString *responseString) {
        
        NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(responseData) {
            NSDictionary *aResponseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
            if(![aResponseDictionary isKindOfClass:([NSNull class])]) {
                NSDictionary *aTempDictionary = [aResponseDictionary objectForKey:@"Data"];
                if(aTempDictionary != (NSDictionary*)[NSNull null]) {
                    [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"SessionId"] forKey:@"SessionId"];
                    [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"PrimaryRoleID"] forKey:@"PrimaryRoleID"];
                    
                    [aStandardUserDefaults setObject:self.userNameTextField.text forKey:@"UserName"];
                    
                    [aStandardUserDefaults synchronize];
                    
                    [[LRAppDelegate myAppdelegate].window setRootViewController:[LRAppDelegate myAppdelegate].aBaseNavigationController];
                    
                }
                else {
                    [LRUtility stopActivityIndicatorFromView:self.view];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                             message:[aResponseDictionary objectForKey:@"Error"]
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                   otherButtonTitles:nil, nil];
                    [errorAlertView show];
                    
                }
            }
        }
        
        
    } errorHandler:^(NSError *errorString) {
        
        [LRUtility stopActivityIndicatorFromView:self.view];
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                 message:[errorString description]
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                       otherButtonTitles:nil, nil];
        [errorAlertView show];
        DLog(@"%@\t%@\t%@\t%@", [errorString localizedDescription], [errorString localizedFailureReason],
             [errorString localizedRecoveryOptions], [errorString localizedRecoverySuggestion]);
        
        
    }];*/
    
}

#pragma mark - Add the user roles to the database
- (void) addTheUserRolesToDatabase
{
    NSArray *userRoles = nil;
    userRoles = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRUserRoles" withPredicate:nil, nil];
    
    // if there are no user roles present in the database only then add the new roles.
    if(!userRoles.count) {
        userRoles = [NSArray arrayWithObjects:@"Institutional Sales Group",@"Equity Research Group",@"Institutional Client",@"Consultant",@"Corporate Consulting Group",@"Investment Banking Group",@"Sales Trading",@"Accounting",@"Middle Market Group",@"Marketing Group",@"Medacorp", nil];
        NSArray *aUserRoleIds = [NSArray arrayWithObjects:@"3",@"5",@"6",@"7",@"8",@"9",@"49",@"86",@"106",@"113",@"132", nil];
        
        for (int i = 0; i < [userRoles count]; i++) {
            
            LRUserRoles *aUserRole = (LRUserRoles *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRUserRoles" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
            aUserRole.userRole = [userRoles objectAtIndex:i];
            aUserRole.userRoleId = [NSNumber numberWithInt:[[aUserRoleIds objectAtIndex:i] intValue]];
        }
        
        [[LRCoreDataHelper sharedStorageManager] saveContext];
    }
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark -
#pragma mark - UITextFielDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _refTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag == 1) {
        [textField previousNextToolBar:self withPreviousButtonEnabled:FALSE withNextButtonEnabled:TRUE];
        
    }
    if(textField.tag == 2) {
        [textField previousNextToolBar:self withPreviousButtonEnabled:TRUE withNextButtonEnabled:FALSE];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
#pragma mark -
#pragma mark - Action methods for prev and next button
- (void)next
{
    if([prevNextArray containsObject:_refTextField])
    {
        int aIndex = (int)[prevNextArray indexOfObject:_refTextField];
        if(aIndex < [prevNextArray count]-1)
        {
            [(UITextField*) [prevNextArray objectAtIndex:aIndex+1] becomeFirstResponder];
        }
    }
}

-(void)previous
{
    if([prevNextArray containsObject:_refTextField])
    {
        int aIndex = (int)[prevNextArray indexOfObject:_refTextField];
        if(aIndex > 0)
        {
            [(UITextField*) [prevNextArray objectAtIndex:aIndex-1] becomeFirstResponder];
        }
    }
}

-(void)done
{
    [_refTextField resignFirstResponder];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a [LRAppDelegate myStoryBoard]-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
