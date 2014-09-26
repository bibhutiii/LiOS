//
//  LRLoginService.m
//  Leerink
//
//  Created by Ashish on 26/06/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LRLoginService.h"
#import "LRUser.h"
#import "LRAnalyst.h"

@interface LRLoginService ()

@property (strong, nonatomic) NSURL *sourceURL;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSMutableArray *symbolsArray;
@end

@implementation LRLoginService

- (id)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
		
        self.sourceURL = url;
	}
	
	return self;
    
    // service URL
    //http://portalqa.leerink.com/leerinkwebservice/leerinkservice.asmx
}
- (void)isLoginSuccessful:(LRLoginResponseBlock)responseBlock withUserName:(NSString *)iUserName andPassword:(NSString *)iPassword
{
    __block BOOL isLoginSuccessful = FALSE;
    
    self.userName = iUserName;
    self.password = iPassword;
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
    
    
    NSURL *url = [NSURL URLWithString:@"http://10.140.217.20/LeerinkApi/api/Session/Create"];
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
	NSLog(@"ERROR with theConnection");
    [LRUtility stopActivityIndicatorFromView:nil];
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
        // [LRAppDelegate myAppdelegate].aTabBarcontroller.selectedIndex = 0;
        [[LRAppDelegate myAppdelegate].window setRootViewController:[LRAppDelegate myAppdelegate].aBaseNavigationController];
        
    }
	if ([elementName isEqualToString:@"LoginResult"]) {
		
		finaldata = nodeContent;
        [LRUtility stopActivityIndicatorFromView:nil];
        if([[resultDictionary objectForKey:@"HasSuccess"] boolValue] == FALSE) {
            [[[UIAlertView alloc] initWithTitle:@"Leerink"
                                        message:[NSString stringWithFormat:@"%@", [resultDictionary objectForKey:@"Message"]]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                              otherButtonTitles:nil] show];
        }
        else {
            // [LRAppDelegate myAppdelegate].aTabBarcontroller.selectedIndex = 0;
            [[LRAppDelegate myAppdelegate].window setRootViewController:[LRAppDelegate myAppdelegate].aBaseNavigationController];
            
            // adding the code to store data in database.
            LRUser *aUser = (LRUser *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRUser" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
            if([resultDictionary objectForKey:@"PrimaryRoleId"]) {
                aUser.roleId = [resultDictionary objectForKey:@"PrimaryRoleId"];
            }
            // if the login is successful then store the current user in the data base.
            aUser.userName = self.userName;
            aUser.password = self.password;
            
            NSUserDefaults *aStandarUserDefaults = [NSUserDefaults standardUserDefaults];
            [aStandarUserDefaults setObject:[resultDictionary objectForKey:@"PrimaryRoleId"] forKey:@"loggedInUSerId"];
            [aStandarUserDefaults synchronize];
            
            [[LRCoreDataHelper sharedStorageManager] saveContext];
        }
	}
}

@end
