//
//  UITextField+previousNextToolBar.m
//  RisingTide
//
//  Created by PUNEETH B H on 18/12/13.
//  Copyright (c) 2013 Aditi. All rights reserved.
//

#import "UITextField+previousNextToolBar.h"

@implementation UITextField (previousNextToolBar)

-(UITextField *)previousNextToolBar:(id)delegate withPreviousButtonEnabled:(BOOL)previousButtonEnabled withNextButtonEnabled:(BOOL)nextButtonEnabled {
    
    UIToolbar * keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 38)];
    
    keyboardToolBar.barStyle = UIBarStyleBlackTranslucent;
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    SEL aPreviousButtonSelector = sel_registerName("previous");
    UIBarButtonItem *prevBtn = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleDone target:delegate action:aPreviousButtonSelector];
    
    [prevBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    prevBtn.enabled = previousButtonEnabled;
    
    SEL aNextButtonSelector = sel_registerName("next");
    UIBarButtonItem *nextBtn = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:delegate action:aNextButtonSelector];
    [nextBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    nextBtn.enabled = nextButtonEnabled;
    
    SEL aDoneButtonSelector = sel_registerName("done");
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:delegate action:aDoneButtonSelector];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [doneBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal]; //Bug 1713 resolved.
    
    if (previousButtonEnabled == TRUE)
    {
        [barItems addObject:prevBtn];
    }
    
    if (nextButtonEnabled == TRUE)
    {
        [barItems addObject:nextBtn];
    }
    
    [barItems addObject:flexible];
    [barItems addObject:doneBtn];
    
    [keyboardToolBar setItems:barItems animated:YES];
    
    self.inputAccessoryView = keyboardToolBar;
    
    return self;
}

@end
