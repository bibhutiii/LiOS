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
        sDefaultWebEngine = [[self alloc] initWithHostName:@"iosqa.leerink.com"];
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
            mnetworkEngine = [[MKNetworkEngine alloc] initWithHostName:@"iosqa.leerink.com"customHeaderFields:[NSDictionary dictionaryWithObject:[aStandardUserDefaults objectForKey:@"SessionId"] forKey:@"SessionId"]];
            
        }
        else {
            mnetworkEngine = [[MKNetworkEngine alloc] initWithHostName:@"iosqa.leerink.com"];
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
    
    MKNetworkOperation *aNetworkOperation = [self operationWithPath:@"/LeerinkApi/api/Login/Login" params:aRequestDictionary httpMethod:@"POST" ssl:TRUE];
    
    [aNetworkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        completion(valueString);
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:aNetworkOperation];
    return aNetworkOperation;
}
- (MKNetworkOperation *)sendRequestToGetAnalystsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    MKNetworkOperation *aNetworkOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetAnalysts" params:nil httpMethod:@"POST" ssl:TRUE];
    
    [aNetworkOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    aNetworkOperation.documentType = eLRDocumentAnalyst;
    
    [aNetworkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
        NSDictionary *the_parsedcontents = [LRSaveDataToDatabase getparsedJSONDataForString:valueString forOperation:completedOperation withContextInfo:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:aNetworkOperation];
    return aNetworkOperation;
}
- (MKNetworkOperation *)sendRequestToGetSectorsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    MKNetworkOperation *aNetworkOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetSectors" params:nil httpMethod:@"POST" ssl:TRUE];
    
    [aNetworkOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    aNetworkOperation.documentType = eLRDocumentSector;
    
    [aNetworkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
        NSDictionary *the_parsedcontents = [LRSaveDataToDatabase getparsedJSONDataForString:valueString forOperation:completedOperation withContextInfo:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:aNetworkOperation];
    return aNetworkOperation;
}
- (MKNetworkOperation *)sendRequestToGetSymbolsWithResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    MKNetworkOperation *aNetworkOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetSymbols" params:nil httpMethod:@"POST" ssl:TRUE];
    
    [aNetworkOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    aNetworkOperation.documentType = eLRDocumentSymbol;
    
    [aNetworkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
        NSDictionary *the_parsedcontents = [LRSaveDataToDatabase getparsedJSONDataForString:valueString forOperation:completedOperation withContextInfo:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:aNetworkOperation];
    return aNetworkOperation;
}
- (MKNetworkOperation *)sendRequestToGetDocumentListWithwithContextInfo:(id)iContextInfo forResponseDataBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{    
    NSMutableDictionary *aContecxtInfoDictionary = (NSMutableDictionary *)iContextInfo;
    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    MKNetworkOperation *aNetworkOperation = nil;
    switch ([[aContecxtInfoDictionary objectForKey:@"DocumentTypeList"] intValue]) {
        case eLRDocumentListAnalyst:
        {
            LRAnalyst *analyst = (LRAnalyst *)[iContextInfo objectForKey:@"AnalystDocumentList"];
            [aRequestDict setObject:[NSNumber numberWithInt:[analyst.userId intValue]] forKey:@"AuthorID"];
            aNetworkOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetDocumentList" params:aRequestDict httpMethod:@"POST" ssl:TRUE];
            aNetworkOperation.documentListType = eLRDocumentListAnalyst;

        }
            break;
            case eLRDocumentListSector:
        {
            LRSector *sector = (LRSector *)[iContextInfo objectForKey:@"SectorDocumentList"];
            [aRequestDict setObject:[NSNumber numberWithInt:[sector.researchID intValue]] forKey:@"ResearchID"];
            aNetworkOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetDocumentList" params:aRequestDict httpMethod:@"POST" ssl:TRUE];
            aNetworkOperation.documentListType = eLRDocumentListSector;

        }
            break;
        case eLRDocumentListSymbol:
        {
            LRSymbol *symbol = (LRSymbol *)[iContextInfo objectForKey:@"SymbolDocumentList"];
            [aRequestDict setObject:[NSNumber numberWithInt:[symbol.tickerID intValue]] forKey:@"tickerID"];
            aNetworkOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetDocumentList" params:aRequestDict httpMethod:@"POST" ssl:TRUE];
            aNetworkOperation.documentListType = eLRDocumentListSymbol;
            
        }
            break;
            
        default:
            break;
    }
    __block NSString *valueString = nil;    
    
    
    [aNetworkOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    
    [aNetworkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
        NSDictionary *the_parsedcontents = [LRSaveDataToDatabase getDocumentListJSONDataForString:valueString forOperation:completedOperation withContextInfo:iContextInfo];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:aNetworkOperation];
    return aNetworkOperation;
    
}
- (MKNetworkOperation *)sendRequestToGetDocumentWithwithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    [aRequestDict setObject:iContextInfo forKey:@"Path"];
    
    MKNetworkOperation *aNetworkOperation = [self operationWithPath:@"/LeerinkApi/api/IOS/GetDocument" params:aRequestDict httpMethod:@"POST" ssl:TRUE];
    
    [aNetworkOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    
    [aNetworkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
        NSData *responseData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *the_parsedcontents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:aNetworkOperation];
    return aNetworkOperation;
    
}
- (MKNetworkOperation *)sendRequestToLogOutWithwithContextInfo:(id)iContextInfo forResponseBlock:(LRResponseDataBlock)completion errorHandler:(LRErrorBlock) errorBlock
{
    __block NSString *valueString = nil;
    NSUserDefaults *aStandardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *aRequestDict = [[NSMutableDictionary alloc] init];
    [aRequestDict setObject:@"abc" forKey:@"Guid"];
    [aRequestDict setObject:[aStandardUserDefaults objectForKey:@"SessionId"] forKey:@"sessionId"];

    MKNetworkOperation *aNetworkOperation = [self operationWithPath:@"/LeerinkApi/api/Login/logout" params:nil httpMethod:@"POST" ssl:TRUE];
    
    [aNetworkOperation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[aStandardUserDefaults objectForKey:@"SessionId"],@"Session-Id" ,nil]];
    //aNetworkOperation.documentListRequestType = eLRDocumentListAnalyst;
    
    [aNetworkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        valueString = [completedOperation responseString];
        NSLog(@"recieved currency -- %@",[completedOperation responseString]);
        
        NSData *responseData = [valueString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *the_parsedcontents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
        completion(the_parsedcontents);
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:aNetworkOperation];
    return aNetworkOperation;
    
}
@end
