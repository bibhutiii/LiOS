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
@property (retain)UIDocumentInteractionController *documentController;
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
       [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f],
                                                                                                                          NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                                                                          }];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:204/255.0 green:219/255.0 blue:230/255.0 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    
    [[LRWebEngine defaultWebEngine] sendRequestToGetDocumentWithwithContextInfo:self.documentPath forResponseBlock:^(NSDictionary *responseDictionary) {
        
        if([[responseDictionary objectForKey:@"Error"] isKindOfClass:([NSNull class])]) {
            NSDictionary *aDocumentByteDictionary = [responseDictionary objectForKey:@"Data"];
            NSString *aDocumentEncodedString = [aDocumentByteDictionary objectForKey:@"DocumentByte"];
            
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:aDocumentEncodedString options:0];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *libraryDirectory = [paths objectAtIndex:0];
           // self.documentTitleToBeSavedAsPdf = @"abc def fgt dasdsadasd dssdsd ererer 4535454dsfdf";
            self.documentTitleToBeSavedAsPdf = [self.documentTitleToBeSavedAsPdf stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
           // self.documentTitleToBeSavedAsPdf = [self.documentTitleToBeSavedAsPdf stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            [decodedData writeToFile:[libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",self.documentTitleToBeSavedAsPdf]] atomically:YES];
            
            [self.documentReaderWebView loadData:decodedData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
            
            SEL aLogoutButton = sel_registerName("iBooks");
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Share-black-32"] style:0 target:self action:aLogoutButton];
            self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
            self.navigationItem.rightBarButtonItem = backButton;


        }
        else {
            [LRUtility stopActivityIndicatorFromView:self.view];
            UIAlertView *documentFailAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink" message:[responseDictionary objectForKey:@"Error"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [documentFailAlertView show];
        }
        
    } errorHandler:^(NSError *errorString) {
        [LRUtility stopActivityIndicatorFromView:self.view];
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                                 message:[errorString description]
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                       otherButtonTitles:nil, nil];
        [errorAlertView show];

    }];
    

    
   /* [aGetDocumentService getDocument:^(BOOL isDocumentFetched) {
        NSLog(@"document fetched");
    } withDocumentId:self.documentId withUserId:self.userId andPath:self.documentPath];
    */
}
- (void) iBooks
{
    NSLog(@"%@",self.documentTitleToBeSavedAsPdf);
   // self.documentTitleToBeSavedAsPdf = @"BAX/Managing Through Headwinds While Still Reinvesting in Future Growth/Outperform";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    
    NSFileManager *filemgr;
    
    filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:[NSString stringWithFormat:@"/%@/%@.pdf",libraryDirectory,self.documentTitleToBeSavedAsPdf]] == YES) {
        NSLog (@"File exists");
        
        NSString *fileURLString = [NSString stringWithFormat:@"/%@/%@.pdf",libraryDirectory,self.documentTitleToBeSavedAsPdf];// your file URL as *string*
        
        if(![fileURLString isKindOfClass:([NSNull class])]) {
            
            self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:fileURLString]];
            self.documentController.delegate = self;
            //self.documentController.UTI = @"com.adobe.pdf";
            [self.documentController presentOpenInMenuFromRect:CGRectZero inView:self.view  animated:YES];

            /*if(self.documentController)
            {
                NSLog(@"App found");
                [self.documentController presentOpenInMenuFromRect:CGRectZero inView:self.view  animated:YES];
            }
            else {
                NSString * messageString = [NSString stringWithFormat:@"No PDF reader was found on your device. Please download a PDF reader (eg. iBooks)."];
                
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Leerink " message:messageString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }*/
        }
        else
            NSLog (@"File not found");
        
        
    }

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
