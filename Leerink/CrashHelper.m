//
//  CrashHelper.m
//
//  Version 1.0
//
//  Created by Raj Chiderae on 12/06/2013.
// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2013 Raj Chiderae
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CrashHelper.h"
#import <CrashReporter/CrashReporter.h>
#import "LRMainClientPageViewController.h"

#define kDefaultEmailID @"sam.storer@leerink.com"
#define kCrashEmailSubject @"crash report"
#define kCrashFileName @"CrashReport"
#define kCrashAlertViewTitle @"Leerink"
#define kCrashAlertViewMessage @"We just recovered from a crash, We have sent a report to the Support team"
#define kCrashAlertViewOkTitle @"Ok"
#define kCrashAlertViewCancelTitle @"Cancel"
#define kCrashEmailMessage @""

@implementation CrashHelper

static NSString *crashPath;
static CrashHelper *_sharedManager = nil;
static BOOL _hasCrashReportPending;


#pragma mark Shared Instance
/**
 Singleton Shared Instance of App Crash Helper
 */
+ (CrashHelper *)sharedCrashHelper {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        if (_sharedManager == nil) {
            _sharedManager = [[self alloc] init];
            _sharedManager.crashReportComplete = NO;
        }
    });
    return _sharedManager;
}

/**
 Method to handle a pending crash report
 */
- (void)handleCrashReport {
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSData *crashData;
    NSError *error;
    
    // Try loading the crash report
    crashData = [crashReporter loadPendingCrashReportDataAndReturnError:&error];
    if (crashData == nil) {
        NSLog(@"Could not load crash report: %@", error);
        [self finishCrashReporter:crashReporter];
        return;
    }
    
    // We could send the report from here, but we'll just print out
    // some debugging info instead
    PLCrashReport *report = [[PLCrashReport alloc] initWithData:crashData error:&error];
    if (report == nil) {
        NSLog(@"Could not parse crash report");
        [self finishCrashReporter:crashReporter];
        return;
    }
    
    //NSLog(@"Crashed on %@", report.systemInfo.timestamp);
    //NSLog(@"Crashed with signal %@ (code %@, address=0x%" PRIx64 ")", report.signalInfo.name,
    //      report.signalInfo.code, report.signalInfo.address);
    
    [self saveCrashReport:crashReporter];
    
    return;
}

/**
 Method to purge any pending reports
 @param crashReporter:PLCrashReporter instance to be used
 */
- (void)finishCrashReporter:(PLCrashReporter *)crashReporter {
    [crashReporter purgePendingCrashReport];
    _hasCrashReportPending = false;
}

/** Method runs, if a crash report exists, make it accessible via iTunes document sharing. This is a no-op on Mac OS X.
 @param crashReporter:PLCrashReporter instance to be used
 */
- (void)saveCrashReport:(PLCrashReporter *)reporter {
    if (![reporter hasPendingCrashReport])
        return;
    
#if TARGET_OS_IPHONE
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if (![fm createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Could not create documents directory: %@", error);
        return;
    }
    
    
    NSData *data = [[PLCrashReporter sharedReporter] loadPendingCrashReportDataAndReturnError:&error];
    if (data == nil) {
        NSLog(@"Failed to load crash report data: %@", error);
        return;
    }
    
    NSString *outputPath = [documentsDirectory stringByAppendingPathComponent:kCrashFileName];
    if (![data writeToFile:outputPath atomically:YES]) {
        NSLog(@"Failed to write crash report");
        return;
    }
    
    crashPath = outputPath;
    
    
    
    [reporter purgePendingCrashReport];
    self.crashReportComplete = YES;
    
#endif
}

/**
 Method to send any prepared report via email after confrimation
 @param parentController: ViewController instance from where this method is called
 */
- (void)confirmAndSendCrashReportEmailWithViewController:(UIViewController *)parentController {
    _parentController = parentController;
    
   	UIAlertView *customAlert = [[UIAlertView alloc]initWithTitle:kCrashAlertViewTitle message:kCrashAlertViewMessage delegate:self cancelButtonTitle:kCrashAlertViewOkTitle otherButtonTitles:nil, nil];
    [customAlert show];
}

/**
 Method to send any prepared report via email
 */
- (void)sendCrashReportEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        NSArray *receipients = [[NSArray alloc]initWithObjects:kDefaultEmailID, nil];
        [controller setToRecipients:receipients];
        [controller setSubject:kCrashEmailSubject];
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_SERVICE_NAME];
        //NSData *crashData = [NSData dataWithContentsOfFile:crashPath];
        [keychain setData:[NSData dataWithContentsOfFile:crashPath] forKey:@"crashData"];
        [controller addAttachmentData:[keychain dataForKey:@"crashData"] mimeType:@"text/plain" fileName:kCrashFileName];
        [controller setMessageBody:kCrashEmailMessage isHTML:YES];
        if (controller) {
            [_parentController presentViewController:controller animated:YES completion: ^{
            }];
        }
    }
    else {
        NSLog(@"cp--%@",crashPath);
        
        NSLog(@"Device cannot email crash report");
    }
}

/**
 Method to check for any crashes, only call from UIApplicationDelegate
 */
- (void)checkForCrashes {
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    
    // Check if we previously crashed
    _hasCrashReportPending = [crashReporter hasPendingCrashReport];
    if (_hasCrashReportPending) {
        self.crashReportComplete = NO;
        [self handleCrashReport];
    }
    // Enable the Crash Reporter
    if (![crashReporter enableCrashReporterAndReturnError:&error])
        NSLog(@"Warning: Could not enable crash reporter: %@", error);
}

/** getter for hasCrashReportPending */
+ (BOOL)hasCrashReportPending {
    return _hasCrashReportPending;
}

#pragma mark MFMailComposeViewController method
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"Crash report sent");
    }
    [_parentController dismissViewControllerAnimated:YES completion: ^{
    }];
    [self finishCrashReporter:[PLCrashReporter sharedReporter]];
}

#pragma mark alertview method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
        NSError *error;
        
        NSData *crashData = [NSData dataWithContentsOfFile:crashPath];
        
        PLCrashReport *report = [[PLCrashReport alloc] initWithData:crashData error:&error];
        
        NSString *humanReadable = [PLCrashReportTextFormatter stringValueForCrashReport:report withTextFormat:PLCrashReportTextFormatiOS];
        //NSLog(@"Report: %@", humanReadable);
        
        // Get NSString from NSData object in Base64
        NSString *base64Encoded = [crashData base64EncodedStringWithOptions:0];

        NSData *aData = [base64Encoded dataUsingEncoding:NSUTF8StringEncoding];
        
        
        NSString *final = [aData base64EncodedStringWithOptions:0];
        
      //  NSString *aStr = @"hellohowru";
        
    //    NSData* cData = [aStr dataUsingEncoding:NSUTF8StringEncoding];
        
     //   NSString *aStre = [crashData base64EncodedStringWithOptions:0];

        NSLog(@"asdsa--%@",final);
        //   NSString *abas = [crashData base64EncodedString];
        
        if([self.delegate respondsToSelector:@selector(sendCrashReportToServiceWithByteConvertedString:)]) {
            [self.delegate sendCrashReportToServiceWithByteConvertedString:humanReadable];
        }
        
    }
    else {
        [self finishCrashReporter:[PLCrashReporter sharedReporter]];
    }
}

@end
