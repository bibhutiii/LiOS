//
//  LRTermsAndConditionsViewController.m
//  Leerink
//
//  Created by Ashish on 23/12/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRTermsAndConditionsViewController.h"
#import "LRWebEngine.h"
#import "LRChangePaswordViewController.h"
#import <sys/sysctl.h>
#import "LRMainClientPageViewController.h"

@interface LRTermsAndConditionsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *decline_Check;
@property (weak, nonatomic) IBOutlet UILabel *termsAndConditionsLAbel;

@property (weak, nonatomic) IBOutlet UIButton *accept_Check;
@property (assign, nonatomic) BOOL termsAccepted;
@end

@implementation LRTermsAndConditionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.termsAccepted = NO;
    
    [self platformNiceString];
    
}
- (NSString *)platformRawString {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    if(machine!=NULL)
    {
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        NSString *platform = [NSString stringWithUTF8String:machine];
        free(machine);
        return platform;
    }
    else
    {
        return @"";
    }
}
- (NSString *)platformNiceString {
    NSString *platform = [self platformRawString];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    {
        [self.termsAndConditionsLAbel setFont:[UIFont systemFontOfSize:10]];
        return @"iPhone 3G";
    }
    if ([platform isEqualToString:@"iPhone2,1"])     {
        [self.termsAndConditionsLAbel setFont:[UIFont systemFontOfSize:10]];
        return @"iPhone 3GS";
    }
    if ([platform isEqualToString:@"iPhone3,1"])     {
        [self.termsAndConditionsLAbel setFont:[UIFont systemFontOfSize:10]];
        return @"iPhone 4";
    }
    if ([platform isEqualToString:@"iPhone3,3"])     {
        [self.termsAndConditionsLAbel setFont:[UIFont systemFontOfSize:10]];
        return @"Verizon iPhone 4";
    }
    if ([platform isEqualToString:@"iPhone4,1"])     {
        [self.termsAndConditionsLAbel setFont:[UIFont systemFontOfSize:10]];
        return @"iPhone 4S";
    }
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
    if ([platform isEqualToString:@"i386"])          {
        [self.termsAndConditionsLAbel setFont:[UIFont systemFontOfSize:10]];
        return @"Simulator";
    }
    if ([platform isEqualToString:@"x86_64"])        {
        [self.termsAndConditionsLAbel setFont:[UIFont systemFontOfSize:10]];
        return @"Simulator";
    }
    return platform;
}
- (IBAction)accept_Terms:(id)sender {
    self.termsAccepted = TRUE;
    [self.accept_Check setImage:[UIImage imageNamed:@"checkbox@2x"] forState:UIControlStateNormal];
    [self.decline_Check setImage:[UIImage imageNamed:@"uncheckbox@2x"] forState:UIControlStateNormal];
}
- (IBAction)decline_Terms:(id)sender {
    self.termsAccepted = FALSE;
    [self.decline_Check setImage:[UIImage imageNamed:@"checkbox@2x"] forState:UIControlStateNormal];
    [self.accept_Check setImage:[UIImage imageNamed:@"uncheckbox@2x"] forState:UIControlStateNormal];
}
- (IBAction)submit_Terms:(id)sender {
    if(self.termsAccepted == TRUE) {
        NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
        //[aRequestDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"] forKey:@"Username"];
        //[aRequestDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"PassWord"] forKey:@"Password"];
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_SERVICE_NAME];
        [aRequestDict setObject:[AESCrypt decrypt:keychain[@"UserName"] password:PASS] forKey:@"Username"];
        [aRequestDict setObject:[AESCrypt decrypt:keychain[@"PassWord"] password:PASS] forKey:@"Password"];
        
        [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait..."];
        
        [[LRWebEngine defaultWebEngine] sendRequestToAcceptTermsAndConditions:aRequestDict andResponseBlock:^(NSString *responseString) {
            
            NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            if(responseData) {
                NSDictionary *aResponseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
                if(![aResponseDictionary isKindOfClass:([NSNull class])]) {
                    NSDictionary *aTempDictionary = [aResponseDictionary objectForKey:@"Data"];
                    if([[aResponseDictionary objectForKey:@"IsSuccess"] boolValue] == TRUE) {
                        
                        [LRUtility stopActivityIndicatorFromView:self.view];
                        
                        if([[aTempDictionary objectForKey:@"FirstTimeLogin"] isEqualToString:@"ChangePassword"]) {
                            LRChangePaswordViewController *aChangePassWordController = [[LRAppDelegate myStoryBoard] instantiateViewControllerWithIdentifier:NSStringFromClass([LRChangePaswordViewController class])];
                            [self presentViewController:aChangePassWordController animated:TRUE completion:nil];
                        }
                        else if([[aTempDictionary objectForKey:@"FirstTimeLogin"] isEqualToString:@"HomePage"]) {
                            [[[LRAppDelegate myAppdelegate] window] setRootViewController:[[LRAppDelegate myAppdelegate] aBaseNavigationController]];
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
    else {
        [self dismissViewControllerAnimated:TRUE completion:nil];
    }
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

@end
