//
//  LRGetSectorService.h
//  Leerink
//
//  Created by Ashish on 7/08/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRLoadDataDelegate.h"

typedef void (^LRGetSectorResponse)(BOOL isSectorFetched);

@interface LRGetSectorService : NSObject < NSXMLParserDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    NSMutableData *webData;
    NSXMLParser *xmlParser;
    NSString *finaldata;
    NSMutableString *nodeContent;
    NSMutableDictionary *resultDictionary;
}
@property (nonatomic, assign) id <LRLoadDataDelegate> delegate;

- (id)initWithURL:(NSURL *)url;
- (void)getSector:(LRGetSectorResponse)responseBlock;
@end

