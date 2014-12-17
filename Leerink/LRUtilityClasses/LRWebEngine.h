//
//  LRWebEngine.h
//  Leerink
//
//  Created by Ashish on 22/04/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"
#import "LRLoadDataDelegate.h"

@interface LRWebEngine : MKNetworkEngine<LRLoadDataDelegate>
{
    MKNetworkEngine *mnetworkEngine;
}

+ (LRWebEngine *) defaultWebEngine;

typedef void (^LRResponseDataBlock)(NSDictionary *responseDictionary);
typedef void (^LRResponseBlock)(NSString *responseString);
typedef void (^LRErrorBlock)(NSError *errorString);

- (MKNetworkOperation *)sendRequestToLoginWithParameters:(NSDictionary *)aRequestDictionary andResponseBlock:(LRResponseBlock) completion errorHandler:(LRErrorBlock) errorBlock;
- (MKNetworkOperation *)sendRequestToGetAnalystsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock;
- (MKNetworkOperation *)sendRequestToGetSectorsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock;
- (MKNetworkOperation *)sendRequestToGetSymbolsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock;
- (MKNetworkOperation *)sendRequestToGetDocumentListWithwithContextInfo:(id)iContextInfo forResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock;
- (MKNetworkOperation *)sendRequestToGetDocumentListForListWithwithContextInfo:(id)iContextInfo forResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock;
- (MKNetworkOperation *)sendRequestToGetDocumentWithwithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock;
- (MKNetworkOperation *)sendRequestToLogOutWithwithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock;
- (MKNetworkOperation *)sendRequestToSendCartWithDocIdswithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock;
- (MKNetworkOperation *)sendRequestToCheckSessionIsValidforResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock;
- (MKNetworkOperation *)sendRequestToSendInstructionsToResetPasswordForEmailAddress:(NSMutableDictionary *)aEmailIdDetails withResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock;
- (MKNetworkOperation *)sendRequestToGetMainMenuItemsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock;
- (MKNetworkOperation *)sendRequestToGetSubMenuItemsWithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock;
- (MKNetworkOperation *)sendRequestToSearchForDocumentsForKeyWordsWithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock;
@end
