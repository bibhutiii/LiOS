//
//  LRGetSymbolService.m
//  Leerink
//
//  Created by Ashish on 7/08/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRGetSymbolService.h"
#import "LRUser.h"
#import "LRAnalyst.h"
#import "LRSymbol.h"

@interface LRGetSymbolService ()

@property (strong, nonatomic) NSURL *sourceURL;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSMutableArray *symbolsArray;
@end

@implementation LRGetSymbolService

- (id)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
		
        self.sourceURL = url;
	}
	
	return self;
    
    // service URL
    //http://portalqa.leerink.com/leerinkwebservice/leerinkservice.asmx
}
- (void)getSymbol:(LRGetSymbolResponse)responseBlock
{
    __block BOOL isLoginSuccessful = TRUE;
    ////
    
    //Web Service Call
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                             "<SOAP-ENV:Envelope \n"
                             "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" \n"
                             "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" \n"
                             "xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\" \n"
                             "SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"\n"
                             "xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"> \n"
                             "<SOAP-ENV:Body> \n"
                             "<GetSymbols xmlns=\"http://tempuri.org/\">"
                             "</GetSymbols>\n"
                             "</SOAP-ENV:Body> \n"
                             "</SOAP-ENV:Envelope>"];
    
    
    NSURL *url = [NSURL URLWithString:@"http://10.0.100.40:8081/iOS_QA/Service1.svc"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    [theRequest addValue: @"text/xml" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/IService1/GetSymbols" forHTTPHeaderField:@"Soapaction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        webData = [[NSMutableData alloc]init];
    }
    else {
        isLoginSuccessful = FALSE;
        NSLog(@"No Connection established");
    }
    responseBlock(isLoginSuccessful);
}
#pragma mark - new
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[webData setLength: 0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[webData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"ERROR with theConenction");
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"DONE. Received Bytes: %lu", (unsigned long)[webData length]);
    
    
    
	NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    
    NSString *aDecodedString = [theXML stringByDecodingHTMLEntities];
    NSLog(@"%@",aDecodedString);
    
	xmlParser = [[NSXMLParser alloc]initWithData:webData];
	[xmlParser setDelegate: self];
	//[xmlParser setShouldResolveExternalEntities: NO];
	[xmlParser parse];
    //
	//[webData release];
	//[resultTable reloadData];
}


//xml delegates

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"ELE -- %@",elementName);
	if([elementName isEqualToString:@"GetSymbolsResult"])
    {
        self.symbolsArray = [NSMutableArray new];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"FC -- %@",string);
    
    NSData *responseData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    self.symbolsArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
    
    //  resultDictionary = [NSMutableDictionary dictionaryWithDictionary:parsedContent];
    
	//[nodeContent appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"GetSymbolsResult"])
    {
        NSArray *symbols = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRSymbol" withPredicate:nil, nil];
        if(symbols.count == 0) {
            for (NSDictionary *analystDictionary in self.symbolsArray) {
                LRSymbol *aSymbol = (LRSymbol *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRSymbol" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
                
                aSymbol.tickerID = [NSNumber numberWithInt:[[analystDictionary objectForKey:@"tickerID"] intValue]];
                aSymbol.nameSymbol = [analystDictionary objectForKey:@"NameSymbol"];
            }
        }
        else {
            for (LRSymbol *aSymbol in symbols) {
                [[[LRCoreDataHelper sharedStorageManager] context] deleteObject:aSymbol];
            }
            for (NSDictionary *analystDictionary in self.symbolsArray) {
                LRSymbol *aSymbol = (LRSymbol *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRSymbol" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
                
                aSymbol.tickerID = [NSNumber numberWithInt:[[analystDictionary objectForKey:@"tickerID"] intValue]];
                aSymbol.nameSymbol = [analystDictionary objectForKey:@"NameSymbol"];
            }
        }
        [[LRCoreDataHelper sharedStorageManager] saveContext];
        
        // after the data has been loaded into the database, reload the table to compose the data in the tableview.
        if([self.delegate respondsToSelector:@selector(didLoadData)]) {
            [self.delegate didLoadData];
        }
    }
}

@end

