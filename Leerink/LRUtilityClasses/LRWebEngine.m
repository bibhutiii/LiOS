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
        sDefaultWebEngine = [[self alloc] initWithHostName:@"portal.leerink.com"];
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
            mnetworkEngine = [[MKNetworkEngine alloc] initWithHostName:@"portal.leerink.com"customHeaderFields:[NSDictionary dictionaryWithObject:[aStandardUserDefaults objectForKey:@"SessionId"] forKey:@"SessionId"]];
            
        }
        else {
            mnetworkEngine = [[MKNetworkEngine alloc] initWithHostName:@"portal.leerink.com"];
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
    
    self.iOperation = [self operationWithPath:@"/LeerinkApi/api/Login/Login" params:aRequestDictionary httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
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
    
    self.iOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetAnalysts" params:nil httpMethod:@"POST" ssl:TRUE];
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    self.iOperation.documentType = eLRDocumentAnalyst;
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
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
    
    self.iOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetSectors" params:nil httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    self.iOperation.documentType = eLRDocumentSector;
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
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
    
    self.iOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetSymbols" params:nil httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    self.iOperation.documentType = eLRDocumentSymbol;
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
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
            LRAnalyst *analyst = (LRAnalyst *)[iContextInfo objectForKey:@"AnalystDocumentList"];
            [aRequestDict setObject:[NSNumber numberWithInt:[analyst.userId intValue]] forKey:@"AuthorID"];
            self.iOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetDocumentList" params:aRequestDict httpMethod:@"POST" ssl:TRUE];
            self.iOperation.documentListType = eLRDocumentListAnalyst;

        }
            break;
            case eLRDocumentListSector:
        {
            LRSector *sector = (LRSector *)[iContextInfo objectForKey:@"SectorDocumentList"];
            [aRequestDict setObject:[NSNumber numberWithInt:[sector.researchID intValue]] forKey:@"ResearchID"];
            self.iOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetDocumentList" params:aRequestDict httpMethod:@"POST" ssl:TRUE];
            self.iOperation.documentListType = eLRDocumentListSector;

        }
            break;
        case eLRDocumentListSymbol:
        {
            LRSymbol *symbol = (LRSymbol *)[iContextInfo objectForKey:@"SymbolDocumentList"];
            [aRequestDict setObject:[NSNumber numberWithInt:[symbol.tickerID intValue]] forKey:@"tickerID"];
            self.iOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetDocumentList" params:aRequestDict httpMethod:@"POST" ssl:TRUE];
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
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
        NSDictionary *the_parsedcontents = [LRSaveDataToDatabase getDocumentListJSONDataForString:valueString forOperation:completedOperation withContextInfo:iContextInfo];
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
    
    [aRequestDict setObject:iContextInfo forKey:@"ListId"];
    self.iOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetDocumentList" params:aRequestDict httpMethod:@"POST" ssl:TRUE];

    __block NSString *valueString = nil;
    
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
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
    
    self.iOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetDocument" params:aRequestDict httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
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

    self.iOperation = [self operationWithPath:@"/LeerinkApi/api/Login/logout" params:nil httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    //self.iOperation.documentListRequestType = eLRDocumentListAnalyst;
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
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
    
    
    
    self.iOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/SendDocumentList" params:iContextInfo httpMethod:@"POST" ssl:TRUE];
    
    [self.iOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    
    [self.iOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
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
