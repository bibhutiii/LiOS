//
//  LRPasswordResetViewController.m
//  Leerink
//
//  Created by Ashish on 25/11/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRPasswordResetViewController.h"
#import "LRWebEngine.h"

@interface LRPasswordResetViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation LRPasswordResetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closePasswordResetPage:(id)sender {
    
    [self dismissViewControllerAnimated:TRUE completion:^{
        
    }];
}
- (IBAction)sendPasswordResetInstructionsToMail:(id)sender {
    
    if([self.emailTextField.text length] == 0) {
        UIAlertView *aUserNameAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                     message:[NSString stringWithFormat:@"Please enter an email id"]
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                           otherButtonTitles:nil, nil];
        [aUserNameAlertView show];
        return;

    }
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    NSMutableDictionary *aRequestDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.emailTextField.text,@"EmailAddress", nil];
    [[LRWebEngine defaultWebEngine] sendRequestToSendInstructionsToResetPasswordForEmailAddress:aRequestDictionary withResponseBlock:^(NSDictionary *responseDictionary) {
        NSString *msg = nil;

        if([[responseDictionary objectForKey:@"IsSuccess"] boolValue] == TRUE) {
            //Add the login view controller as the root controller of the app window
            
            [self dismissViewControllerAnimated:TRUE completion:^{
                
                
            }];
            msg = [responseDictionary objectForKey:@"Message"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                     message:msg
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                           otherButtonTitles:nil, nil];
            [errorAlertView show];
            
        }
        else {
            if(![[responseDictionary objectForKey:@"Message"] isKindOfClass:([NSNull class])]) {
                msg = [responseDictionary objectForKey:@"Message"];
            }
            else if([[responseDictionary objectForKey:@"Error"] isKindOfClass:([NSNull class])]) {
                msg = [responseDictionary objectForKey:@"Error"];
            }
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                     message:msg
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                           otherButtonTitles:nil, nil];
            [errorAlertView show];

            // direct the user to the main client page controller if already logged in.
            [LRUtility stopActivityIndicatorFromView:self.view];
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
#pragma mark -
#pragma mark - UITextFielDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
   }
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
