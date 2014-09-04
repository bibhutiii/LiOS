//
//  LRWebEngine.m
//  Leerink
//
//  Created by Ashish on 22/04/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRWebEngine.h"

static LRWebEngine *sDefaultWebEngine = nil;

@implementation LRWebEngine
#pragma mark -
#pragma mark - Singleton Methods

//Defines a static variable (but only global to this translation unit)) called defaultWebEngine which is then initialised once and only once in sharedManager.
//The way we ensure that it’s only created once is by using the dispatch_once method.
//This is thread safe and handled entirely by the OS
+ (LRWebEngine *)defaultWebEngine
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sDefaultWebEngine = [[self alloc] initWithHostName:@"172.16.133.124"];
    });
    return sDefaultWebEngine;
}

- (id) init
{
	self = [super init];
	if (self != nil)
	{
        // use this if you want to set custom headers for the request.
        //http://172.16.133.124/LeerinkWebServices/LeerinkServices.asmx?op=Login
        mnetworkEngine = [[MKNetworkEngine alloc] initWithHostName:@"172.16.133.124"];
	}
	return self;
}
- (void)loadToCheckCurrencyRatesFromNASDAQWithComnpletionHandler:(LRResponseBlock )response errorHandler:(LRErrorBlock )error
{
    [self aNetWorkOperationWithCustomHeaderscompletionHandler:response errorHandler:error];
}
- (MKNetworkOperation *)aNetWorkOperationWithCustomHeaderscompletionHandler:(LRResponseBlock) completion errorHandler:(LRErrorBlock) error
{
   __block NSString *valueString = nil;
    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    [aRequestDict setObject:@"abc" forKey:@"userName"];
    [aRequestDict setObject:@"def" forKey:@"password"];
    
    MKNetworkOperation *aNetworkOperation = [self operationWithPath:@"LeerinkWebServices/LeerinkServices.asmx?op=Login" params:aRequestDict httpMethod:@"POST"];
    [aNetworkOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:@"abc",@"userName",@"123",@"password", nil]];

    [aNetworkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        completion(valueString);

    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        
    }];
    [self enqueueOperation:aNetworkOperation];
    return aNetworkOperation;
}
@end
