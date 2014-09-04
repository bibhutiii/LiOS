//
//  LRLogOutService.h
//  Leerink
//
//  Created by Ashish on 9/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LogOutDelegate;

@interface LRLogOutService : NSObject < NSXMLParserDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate >
{
    NSMutableData *webData;
    NSXMLParser *xmlParser;
    NSString *finaldata;
    NSMutableString *nodeContent;
    NSMutableDictionary *resultDictionary;
}
@property (nonatomic, assign) id <LogOutDelegate> delegate;
- (void)logOutUserWithIndicatorInView:(id)view;
- (id)initWithURL:(NSURL *)url;

@end

@protocol LogOutDelegate <NSObject>

- (void)isLogOutSuccessfull:(BOOL)value;

@end