//
//  LRLogOutService.m
//  Leerink
//
//  Created by Ashish on 9/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRLogOutService.h"

@interface LRLogOutService ()

@property (strong, nonatomic) NSURL *sourceURL;

@end

@implementation LRLogOutService

- (id)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
		
        self.sourceURL = url;
	}
	
	return self;
    
    // service URL
    //http://portalqa.leerink.com/leerinkwebservice/leerinkservice.asmx
}
- (void)logOutUserWithIndicatorInView:(id)view
{
    NSString *soapFormat1 = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n"
                             "<soap12:Body>\n"
                             "<LogOut xmlns=\"http://tempuri.org/\">\n"
                             "</soap12:Body>\n"
                             "</soap12:Envelope>\n"];
    
    // 2nd part sopa 1.2
    /*<?xml version="1.0" encoding="utf-8"?>
     <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
     <soap12:Body>
     <LogOut xmlns="http://tempuri.org/" />
     </soap12:Body>
     </soap12:Envelope>
     */
    
    //    sean.finger@leerink.commedatest.com
	
    //    LeerSav08
    
    
    NSLog(@"The request format is %@",soapFormat1);
    
    NSLog(@"web url = %@",self.sourceURL);
    
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc]initWithURL:self.sourceURL];
    
    NSString *msgLength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapFormat1 length]];
    
    [theRequest addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue:@"http://tempuri.org/LogOut" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    //the below encoding is used to send data over the net
    [theRequest setHTTPBody:[soapFormat1 dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSURLConnection *connect = [[NSURLConnection alloc]initWithRequest:theRequest delegate:self];
    
    if (connect) {
        [connect start];
        webData = [[NSMutableData alloc]init];
    }
    else {
        [LRUtility stopActivityIndicatorFromView:view];
        NSLog(@"No Connection established");
    }
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
    if(webData) {
        [self.delegate isLogOutSuccessfull:TRUE];
    }
    else {
        [self.delegate isLogOutSuccessfull:FALSE];
    }
	NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
	NSLog(@"%@",theXML);
	
	xmlParser = [[NSXMLParser alloc]initWithData:webData];
	[xmlParser setDelegate: self];
	[xmlParser parse];
}


//xml delegates

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSData *responseData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *parsedContent = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
    
    resultDictionary = [NSMutableDictionary dictionaryWithDictionary:parsedContent];
    
	[nodeContent appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"LogOutResponse"]) {
		
		finaldata = nodeContent;
        
        if([[resultDictionary objectForKey:@"HasSuccess"] boolValue] == FALSE) {
            [[[UIAlertView alloc] initWithTitle:@"Leerink"
                                        message:[NSString stringWithFormat:@"%@", [resultDictionary objectForKey:@"Message"]]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                              otherButtonTitles:nil] show];
            
        }
	}
}
@end
