//
//  LRGetDocumentService.m
//  Leerink
//
//  Created by Ashish on 11/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRGetDocumentService.h"
#import "LRUser.h"
#import "LRAnalyst.h"
#import "LRSymbol.h"
#import "LRSector.h"
#import "LRDocument.h"
#import "NSString+HTML.h"

@interface LRGetDocumentService ()

@property (strong, nonatomic) NSURL *sourceURL;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSMutableArray *symbolsArray;
@property (strong, nonatomic) NSData *documentData;
@property (assign, nonatomic) BOOL isDocumentAvailable;
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
- (void)getDocument:(LRGetDocumentResponse)responseBlock withDocumentId:(int )documentId withUserId:(int )userId andPath:(NSString *)path
{
    __block BOOL isSectorFetched = TRUE;
    self.isDocumentAvailable = FALSE;
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
                             "<GetDocument xmlns=\"http://tempuri.org/\">"
                             "<documentID>%d</documentID>\n"
                             "<userID>%d</userID>\n"
                             "<path>%@</path>\n"
                             "</GetDocument>\n"
                             "</SOAP-ENV:Body> \n"
                             "</SOAP-ENV:Envelope>",documentId,userId,path];
    
    
    NSURL *url = [NSURL URLWithString:locationOfServiceURL];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    [theRequest addValue: @"text/xml" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/IIIRPIOSService/GetDocument" forHTTPHeaderField:@"Soapaction"];
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
    
    if((unsigned long)[webData length] == 0) {
        if([self.delegate respondsToSelector:@selector(didLoadData:)]){
            [self.delegate didLoadData:FALSE];
        }
    }
    else {
        
        NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
        
        NSString *aDecodedString = [theXML stringByDecodingHTMLEntities];
        NSLog(@"%@",aDecodedString);
        
        xmlParser = [[NSXMLParser alloc]initWithData:webData];
        [xmlParser setDelegate: self];
        [xmlParser parse];
    }
}


//xml delegates

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"ELE -- %@",elementName);
    if ([elementName isEqualToString:@"a:ErrorMessage"]) {
        self.isDocumentAvailable = TRUE;
    }
	if([elementName isEqualToString:@"GetDocumentResult"])
    {
        self.symbolsArray = [NSMutableArray new];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"FC -- %@",string);
    if(self.isDocumentAvailable && string.length > 0) {
        self.isDocumentAvailable = FALSE;
        if([self.delegate respondsToSelector:@selector(failedToParseTheDocumentWithErrorMessage:)]) {
            [self.delegate failedToParseTheDocumentWithErrorMessage:string];
        }
    }
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
    
    self.documentData = decodedData;
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"GetDocumentResult"])
    {
       // after the data has been loaded into the database, reload the table to compose the data in the tableview.
        if([self.delegate respondsToSelector:@selector(didLoadDocumentOnWebView:)]) {
            [self.delegate didLoadDocumentOnWebView:self.documentData];
        }
    }
}

@end

