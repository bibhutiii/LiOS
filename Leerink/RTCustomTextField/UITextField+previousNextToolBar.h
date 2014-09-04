//
//  UITextField+previousNextToolBar.h
//  RisingTide
//
//  Created by PUNEETH B H on 18/12/13.
//  Copyright (c) 2013 Aditi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (previousNextToolBar)

-(UITextField *)previousNextToolBar:(id)delegate withPreviousButtonEnabled:(BOOL)previousButtonEnabled withNextButtonEnabled:(BOOL)nextButtonEnabled;

@end
