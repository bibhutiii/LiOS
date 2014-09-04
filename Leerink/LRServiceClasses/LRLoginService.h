//
//  LRLoginService.h
//  Leerink
//
//  Created by Ashish on 26/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LRLoginResponseBlock)(BOOL isLoginSuccessful);

@interface LRLoginService : NSObject < NSXMLParserDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate >
{
    NSMutableData *webData;
    NSXMLParser *xmlParser;
    NSString *finaldata;
    NSMutableString *nodeContent;
    NSMutableDictionary *resultDictionary;
}

- (id)initWithURL:(NSURL *)url;

- (void)isLoginSuccessful:(LRLoginResponseBlock)responseBlock withUserName:(NSString *)iUserName andPassword:(NSString *)iPassword;
@end
