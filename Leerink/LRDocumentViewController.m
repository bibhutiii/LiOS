//
//  LRDocumentViewController.m
//  Leerink
//
//  Created by Ashish on 11/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRDocumentViewController.h"
#import "LRGetDocumentService.h"
#import "LRWebEngine.h"

@interface LRDocumentViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *documentReaderWebView;

@end

@implementation LRDocumentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Document";
    LRGetDocumentService *aGetDocumentService = nil;
    aGetDocumentService = [[LRGetDocumentService alloc] initWithURL:[NSURL URLWithString:baseURLForService]];
    aGetDocumentService.delegate = self;
    aGetDocumentService.documentType = self.documentId;
    aGetDocumentService.documentTypeId = self.userId;
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    
    
    [[LRWebEngine defaultWebEngine] sendRequestToGetDocumentWithwithContextInfo:self.documentPath forResponseBlock:^(NSDictionary *responseDictionary) {
        
        if([[responseDictionary objectForKey:@"Error"] isKindOfClass:([NSNull class])]) {
            NSDictionary *aDocumentByteDictionary = [responseDictionary objectForKey:@"Data"];
            NSString *aDocumentEncodedString = [aDocumentByteDictionary objectForKey:@"DocumentByte"];
            
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:aDocumentEncodedString options:0];
            
            
            [self.documentReaderWebView loadData:decodedData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];

        }
        else {
            [LRUtility stopActivityIndicatorFromView:self.view];
            UIAlertView *documentFailAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink" message:[responseDictionary objectForKey:@"Error"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [documentFailAlertView show];
        }
        
    } errorHandler:^(NSError *errorString) {
        
    }];
    
    
    
   /* [aGetDocumentService getDocument:^(BOOL isDocumentFetched) {
        NSLog(@"document fetched");
    } withDocumentId:self.documentId withUserId:self.userId andPath:self.documentPath];
    */
}
- (void)failedToParseTheDocumentWithErrorMessage:(NSString *)errorMessage
{
    [LRUtility stopActivityIndicatorFromView:self.view];
    UIAlertView *documentFailAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [documentFailAlertView show];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error--%@",error);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [LRUtility stopActivityIndicatorFromView:self.view];
}
- (void)didLoadDocumentOnWebView:(NSData *)documentData
{
    [self.documentReaderWebView loadData:documentData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
