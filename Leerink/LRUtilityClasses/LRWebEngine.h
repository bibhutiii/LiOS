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

typedef void (^LRResponseBlock)(NSString *responseString);
typedef void (^LRErrorBlock)(NSError *errorString);

- (MKNetworkOperation *)aNetWorkOperationWithCustomHeaderscompletionHandler:(LRResponseBlock) completion errorHandler:(LRErrorBlock) error;

@end
