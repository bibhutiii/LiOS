//
//  LeerinkUpdater.h
//  Leerink
//
//  Created by Bibhuti on 17/02/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface LeerinkUpdater : NSObject <UIAlertViewDelegate>

/** Shared instance. [ATAppUpdater sharedUpdater] */
+ (id)sharedUpdater;

/** Checks for newer version and show alert without a cancel button. */
- (void)showUpdateWithForce;

/** Checks for newer version and show alert with a cancel button. */
- (void)showUpdateWithConfirmation;

/** Checks for newer version and show alert with or without a cancel button. */
- (void)forceOpenNewAppVersion:(BOOL)force
__attribute((deprecated("Use 'showUpdateWithForce' or 'showUpdateWithConfirmation' instead.")));

/** Set the UIAlertView title. NSLocalizedString() supported. */
@property (nonatomic, weak) NSString *alertTitle;

/** Set the UIAlertView alert message. NSLocalizedString() supported. */
@property (nonatomic, weak) NSString *alertMessage;

/** Set the UIAlertView update button's title. NSLocalizedString() supported. */
@property (nonatomic, weak) NSString *alertUpdateButtonTitle;

/** Set the UIAlertView cancel button's title. NSLocalizedString() supported. */
@property (nonatomic, weak) NSString *alertCancelButtonTitle;

@end
