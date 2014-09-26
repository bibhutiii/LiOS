//
//  NSDate+RTConvenience.m
//  RisingTide
//
//  Created by Abhiman Puranik on 10/10/13.
//  Copyright (c) 2013 Aditi. All rights reserved.
//

#import "NSDate+RTConvenience.h"

@implementation NSDate (RTConvenience)

static NSDateFormatter * dateFormatter;

+ (NSString *) getLocalTimeFromdateString:(NSString *)indateStr withTimeZone:(NSTimeZone *)inTimezone withFormat:(NSString *)informatStr withOutputFormat:(NSString *)reqFormat
{
    NSString *the_retStr = nil;
    
    if (nil == dateFormatter)
        dateFormatter = [[NSDateFormatter alloc] init];
    
    if(informatStr != nil)
        [dateFormatter setDateFormat:informatStr];
    
    if(inTimezone != nil)
        [dateFormatter setTimeZone:inTimezone];
    else
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    if(indateStr)
    {
        NSDate *the_date = [dateFormatter dateFromString:indateStr];
        
        if(the_date == nil)
        {
            NSArray *array = [indateStr componentsSeparatedByString:@"."];
            
            if(array == nil)
            {
                the_date = [dateFormatter dateFromString:indateStr];
            }
            else
            {
                the_date = [dateFormatter dateFromString:[array objectAtIndex:0]];
            }
        }
        
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setDateFormat:reqFormat];
        
        the_retStr = [[dateFormatter stringFromDate:the_date] lowercaseString];
    }
    
    return the_retStr;
}

- (NSString *) dateToStringWithFormat:(NSString *)format
{
	if (dateFormatter == nil)
	{
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
		
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale: enUSPOSIXLocale];
	}
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone: timeZone];
    
    if (nil == format)
        [dateFormatter setDateFormat: @"dd-MM-yyyy"];
    else
        [dateFormatter setDateFormat: format];
    
    return [dateFormatter stringFromDate: self];
}

+ (NSDate *) stringToDateFormat: (NSString *) dateString
{
    if ((NSNull*)dateString == [NSNull null])
        return nil;
    
    NSDate * result;
    
    if (dateFormatter == nil)
    {
        NSLocale * enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale: enUSPOSIXLocale];
       
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    
    result = [dateFormatter dateFromString: dateString];
    
    return result;
}
    
+ (NSDate *) stringToDateFormat: (NSString *) dateString withFormat:(NSString *)dateFormat
{
    if ((NSNull*)dateString == [NSNull null])
        return nil;
    
    NSDate * result;
	
    if (dateFormatter == nil)
	{
        NSLocale * enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
		
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale: enUSPOSIXLocale];
        
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
		[dateFormatter setTimeZone:timeZone];
	}
    
    if (nil != dateFormat)
        [dateFormatter setDateFormat:dateFormat];
    else
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    result = [dateFormatter dateFromString: dateString];
    
    return result;
}

@end
