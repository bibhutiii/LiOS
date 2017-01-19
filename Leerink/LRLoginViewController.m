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
#import "LRDocumentViewController.h"
#import "LROpenLinksInWebViewController.h"
#import "LRPasswordResetViewController.h"
#import "LRTermsAndConditionsViewController.h"
#import "LRChangePaswordViewController.h"
#import <sys/sysctl.h>
#import "LRUtility.h"

#define fontHelveticaNeueSize14 [UIFont systemFontOfSize:14.0]
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

CGFloat animatedDistance;

@interface LRLoginViewController ()
{
    NSMutableArray *prevNextArray;
    UITextField *_refTextField;
}

- (IBAction)termsOfUseLeerinkPartners:(id)sender;
- (IBAction)forgotPasswordClicked:(id)sender;
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
     [self.userNameTextField setTintColor:[UIColor blackColor]];
    
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
    self.passwordTextField.tintColor = [UIColor blackColor];
    
    prevNextArray = [[NSMutableArray alloc]initWithObjects:self.userNameTextField,self.passwordTextField, nil];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"SessionId"] != nil)
    {
        self.userNameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
        self.passwordTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"PassWord"];
    }
}

- (NSString *)platformRawString {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}
- (NSString *)platformNiceString {
    NSString *platform = [self platformRawString];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad 1";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (4G,2)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (4G,3)";
     if ([platform isEqualToString:@"iPad4,1"])      return @"5th Generation iPad Wifi";
     if ([platform isEqualToString:@"iPad4,2"])      return @"5th Generation iPad Cellular";
     if ([platform isEqualToString:@"iPad4,4"])      return @"iPad 3 (4G,3)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}
#pragma mark -
- (IBAction)logIn:(id)sender {
    
   // self.userNameTextField.text = @"Poonamps@aditi.com";
   // self.passwordTextField.text = @"Aditi06*";
    
  //  self.userNameTextField.text = @"rameshv@aditi.com";
  //  self.passwordTextField.text = @"Aditi01*";
    // check if the username and password fields are not left empty.
    //    self.userNameTextField.text = @"alex.calhoun@leerink.commedatest.com";
    //   self.passwordTextField.text = @"TwinJet12";
    
     //self.userNameTextField.text = @"cbrinzey@hqcm.commedatest.com";
     //self.passwordTextField.text = @"WolfRayet12";
    
    // [[LRAppDelegate myAppdelegate].window setRootViewController:[LRAppDelegate myAppdelegate].aBaseNavigationController];
    
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
    //[self addTheUserRolesToDatabase];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.userNameTextField.text forKey:@"UserName"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text forKey:@"PassWord"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    [aRequestDict setObject:self.userNameTextField.text forKey:@"Username"];
    [aRequestDict setObject:self.passwordTextField.text forKey:@"Password"];
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    [aRequestDict setObject:ver forKey:@"IOSVersion"];
    NSString *model = [self platformNiceString];
    [aRequestDict setObject:model forKey:@"DeviceVersion"];

    if(([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"DeviceId"])) {
        [aRequestDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceId"] forKey:@"DeviceId"];
    }
    else {
        [aRequestDict setObject:@"<9f829b9b 4ed9eaaf b070e85a def45657 169394da eb3d483e 14301960 c420bbc4>" forKey:@"DeviceId"];
    }
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait..."];
    
    [[LRWebEngine defaultWebEngine] sendRequestToLoginWithParameters:aRequestDict andResponseBlock:^(NSString *responseString) {
        
        NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(responseData) {
            NSDictionary *aResponseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
            if(![aResponseDictionary isKindOfClass:([NSNull class])]) {
                NSDictionary *aTempDictionary = [aResponseDictionary objectForKey:@"Data"];
                if([[aResponseDictionary objectForKey:@"IsSuccess"] boolValue] == TRUE) {
                    
                    [LRUtility stopActivityIndicatorFromView:self.view];
                    
                    [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"SessionId"] forKey:@"SessionId"];
                    [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"PrimaryRoleID"] forKey:@"PrimaryRoleID"];
                    [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"FirstName"] forKey:@"FirstName"];
                    [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"LastName"] forKey:@"LastName"];
                    [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"DocList"] forKey:@"DocList"];
                    [aStandardUserDefaults setObject:[aTempDictionary objectForKey:@"UserId"] forKey:@"UserId"];
                    [aStandardUserDefaults setObject:[NSNumber numberWithBool:[[aTempDictionary objectForKey:@"IsInternalUser"] boolValue]] forKey:@"IsInternalUser"];
                    
                    [aStandardUserDefaults synchronize];

                    if([[aTempDictionary objectForKey:@"FirstTimeLogin"] isEqualToString:@"HomePage"]) {
                      
                        [[LRAppDelegate myAppdelegate].window setRootViewController:[LRAppDelegate myAppdelegate].aBaseNavigationController];
                    }
                    else if([[aTempDictionary objectForKey:@"FirstTimeLogin"] isEqualToString:@"ChangePassword"]) {
                        LRChangePaswordViewController *aChangePassWordController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRChangePaswordViewController class])];
                       aChangePassWordController.isFromLogin = @"fromLogin";
                        [self presentViewController:aChangePassWordController animated:TRUE completion:nil];
                    }
                    else if([[aTempDictionary objectForKey:@"FirstTimeLogin"] isEqualToString:@"FirstTimeLogin"]) {
                        LRTermsAndConditionsViewController *aTermsController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRTermsAndConditionsViewController class])];
                        [self presentViewController:aTermsController animated:TRUE completion:nil];
                    }
                }
                else {
                    [LRUtility stopActivityIndicatorFromView:self.view];
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
        
        [LRUtility stopActivityIndicatorFromView:self.view];
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
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 3.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
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

- (IBAction)termsOfUseLeerinkPartners:(id)sender {
    
    LROpenLinksInWebViewController *aOpenLinksInWebViewController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LROpenLinksInWebViewController class])];
    aOpenLinksInWebViewController.linkURL = @"http://www.leerink.com/terms-of-use/";
    aOpenLinksInWebViewController.isLinkFromLogin = TRUE;
    aOpenLinksInWebViewController.isHtmlStringLoaded = FALSE;
    [self presentViewController:aOpenLinksInWebViewController animated:TRUE completion:^{
        
    }];
    
}

- (IBAction)forgotPasswordClicked:(id)sender {
    
    LRPasswordResetViewController *aPasswordResetController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRPasswordResetViewController class])];
    [self presentViewController:aPasswordResetController animated:TRUE completion:^{
        
    }];

}
@end
