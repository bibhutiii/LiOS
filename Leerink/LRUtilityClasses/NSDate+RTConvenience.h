//
//  NSDate+RTConvenience.h
//  RisingTide
//
//  Created by Abhiman Puranik on 10/10/13.
//  Copyright (c) 2013 Aditi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RTConvenience)

+ (NSString *) getLocalTimeFromdateString:(NSString *)indateStr withTimeZone:(NSTimeZone *)inTimezone withFormat:(NSString *)informatStr withOutputFormat:(NSString *)reqFormat;
- (NSString *) dateToStringWithFormat:(NSString *)format;
+ (NSDate *) stringToDateFormat: (NSString *) dateString;
+ (NSDate *) stringToDateFormat: (NSString *) dateString withFormat:(NSString *)dateFormat;

@end
