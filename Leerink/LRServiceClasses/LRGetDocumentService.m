//
//  LRGetDocumentService.m
//  Leerink
//
//  Created by Ashish on 21/08/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRGetDocumentService.h"
#import "LRUser.h"
#import "LRAnalyst.h"
#import "LRSymbol.h"
#import "LRSector.h"
#import "LRDocument.h"

@interface LRGetDocumentService ()

@property (strong, nonatomic) NSURL *sourceURL;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSMutableArray *symbolsArray;
@end

@implementation LRGetDocumentService

- (id)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
		
        self.sourceURL = url;
	}
	
	return self;
    
    // service URL
    //http://portalqa.leerink.com/leerinkwebservice/leerinkservice.asmx
}
- (void)getDocument:(LRGetDocumentResponse)responseBlock withDocumentType:(NSString *)documentType andId:(int )documentTypeId
{
    __block BOOL isSectorFetched = TRUE;
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
                             "<GetDocumentList xmlns=\"http://tempuri.org/\">"
                             "<%@>%d</%@>\n"
                             "</GetDocumentList>\n"
                             "</SOAP-ENV:Body> \n"
                             "</SOAP-ENV:Envelope>",documentType,documentTypeId,documentType];
    
    
    NSURL *url = [NSURL URLWithString:@"http://10.0.100.40:8081/iOS_QA/Service1.svc"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    [theRequest addValue: @"text/xml" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/IService1/GetDocumentList" forHTTPHeaderField:@"Soapaction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        webData = [[NSMutableData alloc]init];
    }
    else {
        isSectorFetched = FALSE;
        NSLog(@"No Connection established");
    }
    responseBlock(isSectorFetched);
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
	if([elementName isEqualToString:@"GetDocumentListResult"])
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
    if([elementName isEqualToString:@"GetDocumentListResult"])
    {
        switch (self.documentType)
        {
            case eLRDocumentAnalyst:
            {
                NSArray *analystsArray = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRAnalyst" withPredicate:@"userId == %d",self.documentTypeId, nil];
                if(analystsArray && analystsArray.count) {
                    LRAnalyst *analyst = [analystsArray objectAtIndex:0];
                    
                    NSArray *documentsForAnalyst = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRDocument" withPredicate:@"analyst.userId == %d",self.documentTypeId, nil];
                    if(documentsForAnalyst && documentsForAnalyst.count > 0) {
                        for (LRDocument *aDocument in documentsForAnalyst) {
                            [[[LRCoreDataHelper sharedStorageManager] context] deleteObject:aDocument];
                        }
                    }

                    for (NSDictionary *aDocumentDictionary in self.symbolsArray) {
                        
                        LRDocument *aDocument = (LRDocument *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRDocument" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
                        aDocument.documentAuthor = [aDocumentDictionary objectForKey:@"author"];
                        aDocument.documentTitle = [aDocumentDictionary objectForKey:@"documentTitle"];
                       // aDocument.documentDate = [aDocumentDictionary objectForKey:@"update_date"];
                        aDocument.documentID = [aDocumentDictionary objectForKey:@"documentID"];
                        
                        aDocument.analyst = analyst;
                        [analyst addAnalystDocumentsObject:aDocument];

                        [[LRCoreDataHelper sharedStorageManager] saveContext];
                    }
                }

            }
                break;
            case eLRDocumentSector:
            {
                NSArray *sectorsArray = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRSector" withPredicate:@"researchID == %d",self.documentTypeId, nil];
                if(sectorsArray && sectorsArray.count) {
                    LRSector *sector = [sectorsArray objectAtIndex:0];
                    
                    NSArray *documentsForAnalyst = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRDocument" withPredicate:@"sector.researchID == %d",self.documentTypeId, nil];
                    if(documentsForAnalyst && documentsForAnalyst.count > 0) {
                        for (LRDocument *aDocument in documentsForAnalyst) {
                            [[[LRCoreDataHelper sharedStorageManager] context] deleteObject:aDocument];
                        }
                    }
                    
                    for (NSDictionary *aDocumentDictionary in self.symbolsArray) {
                        
                        LRDocument *aDocument = (LRDocument *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRDocument" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
                        aDocument.documentAuthor = [aDocumentDictionary objectForKey:@"author"];
                        aDocument.documentTitle = [aDocumentDictionary objectForKey:@"documentTitle"];
                        // aDocument.documentDate = [aDocumentDictionary objectForKey:@"update_date"];
                        aDocument.documentID = [aDocumentDictionary objectForKey:@"documentID"];
                        
                        aDocument.sector = sector;
                        [sector addSectorDocumentsObject:aDocument];
                        
                        [[LRCoreDataHelper sharedStorageManager] saveContext];
                    }
                }

            }
                break;
            case eLRDocumentSymbol:
            {
                NSArray *sectorsArray = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRSymbol" withPredicate:@"tickerID == %d",self.documentTypeId, nil];
                if(sectorsArray && sectorsArray.count) {
                    LRSymbol *symbol = [sectorsArray objectAtIndex:0];
                    
                    NSArray *documentsForAnalyst = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRDocument" withPredicate:@"symbol.tickerID == %d",self.documentTypeId, nil];
                    if(documentsForAnalyst && documentsForAnalyst.count > 0) {
                        for (LRDocument *aDocument in documentsForAnalyst) {
                            [[[LRCoreDataHelper sharedStorageManager] context] deleteObject:aDocument];
                        }
                    }
                    
                    for (NSDictionary *aDocumentDictionary in self.symbolsArray) {
                        
                        LRDocument *aDocument = (LRDocument *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRDocument" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
                        aDocument.documentAuthor = [aDocumentDictionary objectForKey:@"author"];
                        aDocument.documentTitle = [aDocumentDictionary objectForKey:@"documentTitle"];
                        // aDocument.documentDate = [aDocumentDictionary objectForKey:@"update_date"];
                        aDocument.documentID = [aDocumentDictionary objectForKey:@"documentID"];
                        
                        aDocument.symbol = symbol;
                        [symbol addSymbolDocumentsObject:aDocument];
                        
                        [[LRCoreDataHelper sharedStorageManager] saveContext];
                    }
                }
            }
                break;
                
            default:
                break;
        }
        // after the data has been loaded into the database, reload the table to compose the data in the tableview.
        if([self.delegate respondsToSelector:@selector(didLoadData)]) {
            [self.delegate didLoadData];
        }
    }
}

@end
