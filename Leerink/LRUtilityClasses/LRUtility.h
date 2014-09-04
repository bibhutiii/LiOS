//
//  LRUtility.h
//  Leerink
//
//  Created by Ashish on 9/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRUtility : NSObject
+ (void)startActivityIndicatorOnView:(UIView*)inView withText:(NSString*)inStr;
+ (void)stopActivityIndicatorFromView:(UIView*)inView;
@end
