//
//  LRWebEngine.h
//  Leerink
//
//  Created by Ashish on 22/04/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"

@interface LRWebEngine : MKNetworkEngine
{
    MKNetworkEngine *mnetworkEngine;
}

+ (LRWebEngine *) defaultWebEngine;

typedef void (^LRResponseDataBlock)(NSDictionary *responseDictionary);
typedef void (^LRResponseBlock)(NSString *responseString);
typedef void (^LRErrorBlock)(NSError *errorString);

- (MKNetworkOperation *)aNetWorkOperationWithCustomHeaderscompletionHandler:(LRResponseBlock) completion errorHandler:(LRErrorBlock) error;
- (MKNetworkOperation *)sendRequestToGetAnalystsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) error;
- (MKNetworkOperation *)sendRequestToGetSectorsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) error;
- (MKNetworkOperation *)sendRequestToGetSymbolsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) error;
- (MKNetworkOperation *)sendRequestToGetDocumentListWithwithContextInfo:(id)iContextInfo forResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) error;
- (MKNetworkOperation *)sendRequestToGetDocumentWithwithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) error;
- (MKNetworkOperation *)sendRequestToLogOutWithwithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) error;
@end
