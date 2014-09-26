//
//  LRGetDocumentService.h
//  Leerink
//
//  Created by Ashish on 11/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRLoadDataDelegate.h"

typedef void (^LRGetDocumentResponse)(BOOL isDocumentFetched);

@interface LRGetDocumentService : NSObject < NSXMLParserDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    NSMutableData *webData;
    NSXMLParser *xmlParser;
    NSString *finaldata;
    NSMutableString *nodeContent;
    NSMutableDictionary *resultDictionary;
}
@property (nonatomic, assign) int documentTypeId;
@property (nonatomic, assign) eLRDocumentType documentType;
@property (nonatomic, assign) id <LRLoadDataDelegate> delegate;

- (id)initWithURL:(NSURL *)url;
- (void)getDocument:(LRGetDocumentResponse)responseBlock withDocumentId:(int )documentId withUserId:(int )userId andPath:(NSString *)path;
@end

