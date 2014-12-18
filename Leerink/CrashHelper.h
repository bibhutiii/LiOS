//
//  CrashHelper.h
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

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface CrashHelper : NSObject <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
	/**
     ViewController reference for email support
	 */
	UIViewController *_parentController;
}
/**
 Toggle for confirming if report is ready
 */
@property BOOL crashReportComplete;
/*Method descriptions available in implementation*/
+ (CrashHelper *)sharedCrashHelper;
+ (BOOL)hasCrashReportPending;
- (void)checkForCrashes;
- (void)confirmAndSendCrashReportEmailWithViewController:(UIViewController *)parentController;
@end
