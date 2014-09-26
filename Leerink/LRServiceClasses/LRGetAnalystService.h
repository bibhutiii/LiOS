//
//  LRGetAnalystService.h
//  Leerink
//
//  Created by Ashish on 30/07/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRLoadDataDelegate.h"

typedef void (^LRGetAnalystResponse)(BOOL isAnalystFetched);
typedef void (^LRGetSaveAnalystsToDatabase)(BOOL analystSaved);

@interface LRGetAnalystService : NSObject < NSXMLParserDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    NSMutableData *webData;
    NSXMLParser *xmlParser;
    NSString *finaldata;
    NSMutableString *nodeContent;
    NSMutableDictionary *resultDictionary;
}
@property (nonatomic, assign) id <LRLoadDataDelegate> delegate;

- (id)initWithURL:(NSURL *)url;
- (void)getAnalystsFromService:(LRGetAnalystResponse)responseBlock;
@end