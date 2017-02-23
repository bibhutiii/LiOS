//
//  LRChangePaswordViewController.m
//  Leerink
//
//  Created by Ashish on 23/12/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRChangePaswordViewController.h"
#import "UITextField+previousNextToolBar.h"
#import "LRWebEngine.h"
#import "CustomIOSAlertView.h"
#define fontHelveticaNeueSize14 [UIFont systemFontOfSize:14.0]

CGFloat animatedDistance;

@interface LRChangePaswordViewController ()
{
    NSMutableArray *prevNextArray;
    UITextField *_refTextField;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (weak, nonatomic) IBOutlet UITextField *choose_New_Password;
@property (weak, nonatomic) IBOutlet UITextField *confirm_New_password;
- (IBAction)save_New_Password:(id)sender;
- (IBAction)cancel_New_PAssword:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *labelAZ;
@property (weak, nonatomic) IBOutlet UILabel *labelaz;
@property (weak, nonatomic) IBOutlet UILabel *label09;
@property (weak, nonatomic) IBOutlet UILabel *labelSpecialCharacters;

@end

@implementation LRChangePaswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.choose_New_Password.textColor = [UIColor colorWithRed:65.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1.0];
    self.choose_New_Password.layer.cornerRadius = 3.0;
    self.choose_New_Password.backgroundColor = [UIColor whiteColor];
    self.choose_New_Password.font = fontHelveticaNeueSize14;
    self.choose_New_Password.autocorrectionType = UITextAutocorrectionTypeNo;
    self.choose_New_Password.keyboardType = UIKeyboardTypeEmailAddress;
    self.choose_New_Password.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.choose_New_Password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.choose_New_Password.delegate = self;
    self.choose_New_Password.tag = 1;
    [self.choose_New_Password setTintColor:[UIColor blackColor]];
    
    self.confirm_New_password.textColor = [UIColor colorWithRed:65.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1.0];
    self.confirm_New_password.layer.cornerRadius = 3.0;
    self.confirm_New_password.backgroundColor = [UIColor whiteColor];
    self.confirm_New_password.font = fontHelveticaNeueSize14;
    self.confirm_New_password.autocorrectionType = UITextAutocorrectionTypeNo;
    self.confirm_New_password.keyboardType = UIKeyboardTypeDefault;
    self.confirm_New_password.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.confirm_New_password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.confirm_New_password.delegate = self;
    self.confirm_New_password.tag = 2;
    self.confirm_New_password.tintColor = [UIColor blackColor];
    
    prevNextArray = [[NSMutableArray alloc]initWithObjects:self.choose_New_Password,self.confirm_New_password, nil];
    
    
    self.scrolView.scrollEnabled = TRUE;
    [self.scrolView setContentSize:CGSizeMake(320, 850)];
    
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
  /*  CGRect textFieldRect =
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
    
    [UIView commitAnimations];*/
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
   /* CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];*/
    
    textField.secureTextEntry = TRUE;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)save_New_Password:(id)sender {
    
    if([self.choose_New_Password.text length] == 0) {
        UIAlertView *aChoosPAssWordAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                          message:[NSString stringWithFormat:@"Please enter a New Password"]
                                                                         delegate:self
                                                                cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                otherButtonTitles:nil, nil];
        [aChoosPAssWordAlertView show];
        return;
    }
    else if([self.confirm_New_password.text length] == 0) {
        UIAlertView *aConfirmNEwPasswordAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                               message:[NSString stringWithFormat:@"Please Confirm you New Password"]
                                                                              delegate:self
                                                                     cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                     otherButtonTitles:nil, nil];
        [aConfirmNEwPasswordAlertView show];
        return;
    }
    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_SERVICE_NAME];
    //[aRequestDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"] forKey:@"Username"];
    [aRequestDict setObject:[AESCrypt decrypt:keychain[@"UserName"] password:PASS] forKey:@"Username"];
    [aRequestDict setObject:self.choose_New_Password.text forKey:@"Password"];
    
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait..."];
    
    [[LRWebEngine defaultWebEngine] sendRequestToChangePassWord:aRequestDict andResponseBlock:^(NSString *responseString) {
        
        NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(responseData) {
            NSDictionary *aResponseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
            if(![aResponseDictionary isKindOfClass:([NSNull class])]) {
                if([[aResponseDictionary objectForKey:@"IsSuccess"] boolValue] == TRUE) {
                    
                    [LRUtility stopActivityIndicatorFromView:self.view];
                    keychain[@"PassWord"]=[AESCrypt encrypt:self.choose_New_Password.text password:PASS];
                    //[[NSUserDefaults standardUserDefaults] setObject:[AESCrypt encrypt:self.choose_New_Password.text password:PASS] forKey:@"PassWord"];
                    //[[NSUserDefaults standardUserDefaults] setObject:self.choose_New_Password.text forKey:@"PassWord"];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[LRAppDelegate myAppdelegate] autoLoginAfterPassWordReset];
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
                    
                    
                    
                    /*UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                             message:[aMsgStr stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"]
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                   otherButtonTitles:nil, nil]; */
                    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 280, 270)];
                    webView.backgroundColor = [UIColor clearColor];
                    webView.opaque = NO;
                    [webView loadHTMLString:[NSString stringWithFormat:@"%@%@%@",@"<body style='font-family: arial !important;'><b><center>Leerink</center></b><br/>",aMsgStr,@"</body>"] baseURL:nil];
                    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 270)];
                    view.backgroundColor = [UIColor clearColor];
                    [view addSubview:webView];
                    //[errorAlertView show];
                    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
                    [alertView setContainerView:view];
                    [alertView show];
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




- (IBAction)cancel_New_PAssword:(id)sender {
    if([self.isFromLogin length] > 0) {
        if([self.isFromLogin isEqualToString:@"fromLogin"]) {
            [self dismissViewControllerAnimated:TRUE completion:nil];
        }
    }
    else
        [[LRAppDelegate myAppdelegate] cancelledPasswordResetController];
}
@end
