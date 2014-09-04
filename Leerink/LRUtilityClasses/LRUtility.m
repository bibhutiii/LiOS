//
//  LRUtility.m
//  Leerink
//
//  Created by Ashish on 9/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRUtility.h"
#import "MBProgressHUD.h"

//Define activity indicator tag
#define kLoadingTag                 100

@implementation LRUtility
+ (void)startActivityIndicatorOnView:(UIView*)inView withText:(NSString*)inStr
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if (!inView) {
        
        inView = [[[UIApplication sharedApplication] windows] lastObject];
    }
    
    MBProgressHUD *mLoadingScreen =(MBProgressHUD*)[inView viewWithTag:kLoadingTag];
    if(mLoadingScreen == nil)
    {
        mLoadingScreen = [[MBProgressHUD alloc]initWithView:inView];
        mLoadingScreen.labelText = inStr;
        mLoadingScreen.tag = kLoadingTag;
        mLoadingScreen.alpha = 0;
        [inView addSubview:mLoadingScreen];
    }
    else {
        
        mLoadingScreen.labelText = inStr;
    }
    
    [UIView animateWithDuration:0.25
                     animations:
     ^{
         mLoadingScreen.alpha = 1.0f;
         
     }];
}

/**
 Class method to stop activity indicator and removes from super view
 */
+ (void)stopActivityIndicatorFromView:(UIView*)inView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (!inView) {
        
        inView = [[[UIApplication sharedApplication] windows] lastObject];
        
    }
    MBProgressHUD *mLoadingScreen = (MBProgressHUD*)[inView viewWithTag:kLoadingTag];
    
    [UIView animateWithDuration:0.15
                     animations:
     ^{
         mLoadingScreen.alpha = 0.0f;
     }
                     completion:
     ^(BOOL finished)
     {
         [mLoadingScreen hide:YES];
         [mLoadingScreen removeFromSuperview];
     }];
}

@end
