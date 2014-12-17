//
//  LRWebEngine.m
//  Leerink
//
//  Created by Ashish on 22/04/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRWebEngine.h"
#import "LRSaveDataToDatabase.h"
#import "LRAnalyst.h"
#import "LRSector.h"
#import "LRSymbol.h"

static LRWebEngine *sDefaultWebEngine = nil;
@interface LRWebEngine ()
@property (nonatomic, strong) MKNetworkOperation *iOperation;
@end
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
        sDefaultWebEngine = [[self alloc] initWithHostName:SERVICE_URL_BASE];
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
        NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
        if ([aStandardUserDefaults objectForKey:@"SessionId"]) {
            mnetworkEngine = [[MKNetworkEngine alloc] initWithHostName:SERVICE_URL_BASE customHeaderFields:[NSDictionary dictionaryWithObject:[aStandardUserDefaults objectForKey:@"SessionId"] forKey:@"SessionId"]];
            
        }
        else {
            mnetworkEngine = [[MKNetworkEngine alloc] initWithHostName:SERVICE_URL_BASE];
        }
	}
	return self;
}

- (MKNetworkOperation *)sendRequestToLoginWithParameters:(NSDictionary *)aRequestDictionary andResponseBlock:(LRResponseBlock) completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    [aRequestDict setObject:@"cbrinzey@hqcm.commedatest.com" forKey:@"Username"];
    [aRequestDict setObject:@"WolfRayet12" forKey:@"Password"];
    
    self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/Login/Login" params:aRequestDictionary httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        completion(valueString);
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];
    return self.iOperation;
}
- (MKNetworkOperation *)sendRequestToGetAnalystsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/IOS/GetAnalysts" params:nil httpMethod:@"POST" ssl:TRUE];
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    self.iOperation.documentType = eLRDocumentAnalyst;
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        
        NSDictionary *the_parsedcontents = [LRSaveDataToDatabase getparsedJSONDataForString:valueString forOperation:completedOperation withContextInfo:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];

    return self.iOperation;
}
- (MKNetworkOperation *)sendRequestToGetSectorsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/IOS/GetSectors" params:nil httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    self.iOperation.documentType = eLRDocumentSector;
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        
        NSDictionary *the_parsedcontents = [LRSaveDataToDatabase getparsedJSONDataForString:valueString forOperation:completedOperation withContextInfo:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];
    return self.iOperation;
}
- (MKNetworkOperation *)sendRequestToGetSymbolsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/IOS/GetSymbols" params:nil httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    self.iOperation.documentType = eLRDocumentSymbol;
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        
        NSDictionary *the_parsedcontents = [LRSaveDataToDatabase getparsedJSONDataForString:valueString forOperation:completedOperation withContextInfo:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];
    return self.iOperation;
}
- (MKNetworkOperation *)sendRequestToGetDocumentListWithwithContextInfo:(id)iContextInfo forResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{    
    NSMutableDictionary *aContecxtInfoDictionary = (NSMutableDictionary *)iContextInfo;
    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    self.iOperation = nil;
    switch ([[aContecxtInfoDictionary objectForKey:@"DocumentTypeList"] intValue]) {
        case eLRDocumentListAnalyst:
        {
            [aRequestDict setObject:[iContextInfo objectForKey:@"TopCount"] forKey:@"TopCount"];
            [aRequestDict setObject:[iContextInfo objectForKey:@"AuthorID"] forKey:@"AuthorID"];
            self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/IOS/GetDocumentList" params:aRequestDict httpMethod:@"POST" ssl:TRUE];
            self.iOperation.documentListType = eLRDocumentListAnalyst;

        }
            break;
            case eLRDocumentListSector:
        {
            [aRequestDict setObject:[iContextInfo objectForKey:@"TopCount"] forKey:@"TopCount"];
            [aRequestDict setObject:[iContextInfo objectForKey:@"ResearchID"] forKey:@"ResearchID"];
            self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/IOS/GetDocumentList" params:aRequestDict httpMethod:@"POST" ssl:TRUE];
            self.iOperation.documentListType = eLRDocumentListSector;

        }
            break;
        case eLRDocumentListSymbol:
        {
            [aRequestDict setObject:[iContextInfo objectForKey:@"TopCount"] forKey:@"TopCount"];
            [aRequestDict setObject:[iContextInfo objectForKey:@"tickerID"] forKey:@"tickerID"];
            self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/IOS/GetDocumentList" params:aRequestDict httpMethod:@"POST" ssl:TRUE];
            self.iOperation.documentListType = eLRDocumentListSymbol;
            
        }
            break;
            
        default:
            break;
    }
    __block NSString *valueString = nil;    
    
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        
        NSData *responseData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *the_parsedcontents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];
    return self.iOperation;
    
}
- (MKNetworkOperation *)sendRequestToGetDocumentListForListWithwithContextInfo:(id)iContextInfo forResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    self.iOperation = nil;
    
    [aRequestDict setObject:[iContextInfo objectForKey:@"ListId"] forKey:@"ListId"];
    [aRequestDict setObject:[iContextInfo objectForKey:@"TopCount"] forKey:@"TopCount"];
    self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/IOS/GetDocumentList" params:aRequestDict httpMethod:@"POST" ssl:TRUE];

    __block NSString *valueString = nil;
    
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        
        NSData *responseData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *the_parsedcontents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];
    return self.iOperation;
    
}
- (MKNetworkOperation *)sendRequestToGetDocumentWithwithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    [aRequestDict setObject:iContextInfo forKey:@"DocumentID"];
    [aRequestDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] forKey:@"UserId"];
    
    self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/IOS/GetDocument" params:aRequestDict httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        
        NSData *responseData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *the_parsedcontents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];
    return self.iOperation;
    
}
- (MKNetworkOperation *)sendRequestToLogOutWithwithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    [aRequestDict setObject:@"abc" forKey:@"Guid"];
    [aRequestDict setObject:[aStandardUserDefaults objectForKey:@"SessionId"] forKey:@"sessionId"];

    self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/Login/logout" params:nil httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    //self.iOperation.documentListRequestType = eLRDocumentListAnalyst;
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        
        NSData *responseData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *the_parsedcontents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];
    return self.iOperation;
    
}
- (MKNetworkOperation *)sendRequestToSendCartWithDocIdswithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    [aRequestDict setObject:@"55702" forKey:@"DocumentID"];
    
    self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/IOS/SendDocumentList" params:iContextInfo httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        
        NSData *responseData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *the_parsedcontents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];
    return self.iOperation;
}
- (MKNetworkOperation *)sendRequestToCheckSessionIsValidforResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/Login/IsSessionExpired" params:nil httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        
        NSData *responseData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *the_parsedcontents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];
    return self.iOperation;
}
- (MKNetworkOperation *)sendRequestToSendInstructionsToResetPasswordForEmailAddress:(NSMutableDictionary *)aEmailIdDetails withResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    
    self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/Login/ResetPassword" params:aEmailIdDetails httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        
        NSData *responseData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *the_parsedcontents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];
    return self.iOperation;
}
- (MKNetworkOperation *)sendRequestToGetMainMenuItemsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/IOS/GetHomePageMenus" params:nil httpMethod:@"POST" ssl:TRUE];
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        
        NSData *responseData = [valueString dataUsingEncoding:NSUTF8StringEncoding];

        NSDictionary *the_parsedcontents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];
    
    return self.iOperation;
}
- (MKNetworkOperation *)sendRequestToGetSubMenuItemsWithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/IOS/GetSubMenus" params:iContextInfo httpMethod:@"POST" ssl:TRUE];
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        
        NSData *responseData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *the_parsedcontents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];
    
    return self.iOperation;
}
- (MKNetworkOperation *)sendRequestToSearchForDocumentsForKeyWordsWithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    self.iOperation = [self operationWithPath:@"/iOSAppSvcsV1.2/api/IOS/GetDocumentSearch" params:iContextInfo httpMethod:@"POST" ssl:TRUE];
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved response -- %@",[completedOperation responseString]);
        
        NSData *responseData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *the_parsedcontents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:self.iOperation];
    
    return self.iOperation;
}
#pragma mark - Cancel Network operations
- (void)cancelaNetWorkOperation
{
    if([self.iOperation isExecuting]) {
        [self.iOperation cancel];
    }
}
@end
