//
//  LRDocumentViewController.m
//  Leerink
//
//  Created by Ashish on 11/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRDocumentViewController.h"
#import "LRWebEngine.h"
#import <AVFoundation/AVFoundation.h>

@interface LRDocumentViewController () {
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *stopButton;
}
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIWebView *documentReaderWebView;
@property (weak, nonatomic) IBOutlet UIView *audioPlayerView;
@property (retain)UIDocumentInteractionController *documentController;
@property (nonatomic, retain) NSMutableData *dataToDownload;
@property (nonatomic) float downloadSize;
@property (weak, nonatomic) IBOutlet UIProgressView *aProgressView;
@property (weak, nonatomic) IBOutlet UIView *progressSuperView;
@property (weak, nonatomic) IBOutlet UIButton *progressSuperViewCloseButton;
@property (nonatomic, strong) NSDictionary *responseDictionary;
@property (nonatomic) NSURLSessionDataTask *sessionDataTask;
@property (nonatomic) NSURLSession *defaultSession;
- (IBAction)closeProgressView:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *audioPlayerSlider;
@property (strong, nonatomic) NSTimer *sliderTimer;
- (IBAction)sliderValueChanged:(id)sender;

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
    self.responseDictionary = [NSDictionary new];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f],
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                      }];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:9.0/255.0 green:60.0/255.0 blue:113/255.0 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    self.audioPlayerView.hidden = TRUE;
    self.documentReaderWebView.hidden = TRUE;
   // self.isAudioFilePlayed = FALSE;
    
    if(self.isAudioFilePlayed == TRUE) {
        self.audioPlayerView.hidden = FALSE;
        // Get the file path to the song to play.
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"simsg355q"
                                                             ofType:@"wav"];
        
        // Convert the file path to a URL.
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
        
        //Initialize the AVAudioPlayer.
        self.audioPlayer = [[AVAudioPlayer alloc]
                            initWithContentsOfURL:fileURL error:nil];
        
        // Preloads the buffer and prepares the audio for playing.
        [self.audioPlayer prepareToPlay];
        
        self.audioPlayer.currentTime = 0;
        
        [self.audioPlayer play];
        
        self.audioPlayer.delegate = self;
        
        self.progressSuperView.hidden = TRUE;
        
        SEL updateSlider = sel_registerName("updateSlider");
        // Set a timer which keep getting the current music time and update the UISlider in 1 sec interval
        self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:updateSlider userInfo:nil repeats:YES];
        // Set the maximum value of the UISlider
        self.audioPlayerSlider.maximumValue = self.audioPlayer.duration;
        
        self.audioPlayerSlider.value = 0.8;
        
        self.audioPlayerView.userInteractionEnabled = TRUE;
        
        self.audioPlayerSlider.userInteractionEnabled = TRUE;

    }
    else {
        self.documentReaderWebView.hidden = FALSE;
            [self.documentReaderWebView setDelegate:self];
        [self fetchDocument];
    }
    
    self.progressSuperView.layer.cornerRadius = 3.0f;
    self.progressSuperView.layer.borderWidth = 2.0f;
    /* [aGetDocumentService getDocument:^(BOOL isDocumentFetched) {
     NSLog(@"document fetched");
     } withDocumentId:self.documentId withUserId:self.userId andPath:self.documentPath];
     */
}

- (void)updateSlider {
    // Update the slider about the music time
    self.audioPlayerSlider.value = self.audioPlayer.currentTime;
}

// Stop the timer when the music is finished (Need to implement the AVAudioPlayerDelegate in the Controller header)
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    // Music completed
        [self.sliderTimer invalidate];
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    
    self.aProgressView.progress = 0.0f;
    self.downloadSize=[response expectedContentLength];
    self.dataToDownload=[[NSMutableData alloc]init];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [_dataToDownload appendData:data];
    self.aProgressView.progress=[ _dataToDownload length ]/_downloadSize;
    
    
    NSString *str = [[NSString alloc] initWithData:_dataToDownload encoding:NSUTF8StringEncoding];
    // NSLog(@"recieved currency -- %@",str);
    
    NSData *responseData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    self.responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(error == nil)
    {
        NSLog(@"Download is Succesfull");
        [task suspend];
        [LRUtility stopActivityIndicatorFromView:self.view];
        self.progressSuperView.hidden = TRUE;
        if([[self.responseDictionary objectForKey:@"IsSuccess"] boolValue] == TRUE) {
            if(![[self.responseDictionary objectForKey:@"Error"] isKindOfClass:([NSNull class])]) {
                NSDictionary *aDocumentByteDictionary = [self.responseDictionary objectForKey:@"Data"];
                NSString *aDocumentEncodedString = [aDocumentByteDictionary objectForKey:@"DocumentByte"];
                
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:aDocumentEncodedString options:0];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                NSString *libraryDirectory = [paths objectAtIndex:0];
                // self.documentTitleToBeSavedAsPdf = @"abc def fgt dasdsadasd dssdsd ererer 4535454dsfdf";
                self.documentTitleToBeSavedAsPdf = [self.documentTitleToBeSavedAsPdf stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
                // self.documentTitleToBeSavedAsPdf = [self.documentTitleToBeSavedAsPdf stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                [decodedData writeToFile:[libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",self.documentTitleToBeSavedAsPdf,self.documentType]] atomically:YES];
                if([self.documentType isEqualToString:@"pdf"]) {
                    [self.documentReaderWebView loadData:decodedData MIMEType:[NSString stringWithFormat:@"application/%@",self.documentType] textEncodingName:@"utf-8" baseURL:nil];
                }
                else {
                    NSFileManager *filemgr;
                    
                    filemgr = [NSFileManager defaultManager];
                    
                    if ([filemgr fileExistsAtPath:[NSString stringWithFormat:@"/%@/%@.%@",libraryDirectory,self.documentTitleToBeSavedAsPdf,self.documentType]] == YES) {
                        NSLog (@"File exists");
                        
                        NSString *fileURLString = [NSString stringWithFormat:@"/%@/%@.%@",libraryDirectory,self.documentTitleToBeSavedAsPdf,self.documentType];// your file URL as *string*
                        [self.documentReaderWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:fileURLString]]];
                        
                    }
                }
                SEL aLogoutButton = sel_registerName("iBooks");
                UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Share-black-32"] style:0 target:self action:aLogoutButton];
                self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
                self.navigationItem.rightBarButtonItem = backButton;
                [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
                
                [LRUtility stopActivityIndicatorFromView:self.view];
            }
        }
        else  {
            [LRUtility stopActivityIndicatorFromView:self.view];
            UIAlertView *aLogOutAlertView = nil;
            NSString *aMsgStr = nil;
            if(![[self.responseDictionary objectForKey:@"Message"] isKindOfClass:([NSNull class])]) {
                aMsgStr = [self.responseDictionary objectForKey:@"Message"];
            }
            
            if(![[self.responseDictionary objectForKey:@"Error"] isKindOfClass:([NSNull class])]) {
                aMsgStr = [self.responseDictionary objectForKey:@"Error"];
            }
            aLogOutAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                          message:aMsgStr
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                otherButtonTitles:nil, nil];
            
            [aLogOutAlertView show];
        }
        
    }
    else {
        NSLog(@"Error %@",[error localizedDescription]);
        if([[error localizedDescription] isEqualToString:@"cancelled"])
            return;
        UIAlertView *documentFailAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [documentFailAlertView show];
    }
}
- (void)fetchDocument
{
    NSLog(@"notification working");
    if([self.documentType length] == 0 || [self.documentType isKindOfClass:([NSNull class])] || self.documentType == nil) {
        self.documentType = self.documentPath;
    }
    
    //  [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    self.delegate = [LRWebEngine defaultWebEngine];
    ///
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/iOSAppSvcsV1.2/api/IOS/GetDocument",SERVICE_URL_BASE]];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString * params = [NSString stringWithFormat:@"DocumentID=%@",self.documentId];
    [urlRequest addValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"SessionId"] forHTTPHeaderField:@"Session-Id"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.sessionDataTask = [self.defaultSession dataTaskWithRequest:urlRequest];
    [self.sessionDataTask resume];
}
- (void) iBooks
{
    NSLog(@"%@",self.documentTitleToBeSavedAsPdf);
    // self.documentTitleToBeSavedAsPdf = @"BAX/Managing Through Headwinds While Still Reinvesting in Future Growth/Outperform";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    
    NSFileManager *filemgr;
    
    filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:[NSString stringWithFormat:@"/%@/%@.%@",libraryDirectory,self.documentTitleToBeSavedAsPdf,self.documentType]] == YES) {
        NSLog (@"File exists");
        
        NSString *fileURLString = [NSString stringWithFormat:@"/%@/%@.%@",libraryDirectory,self.documentTitleToBeSavedAsPdf,self.documentType];// your file URL as *string*
        
        if(![fileURLString isKindOfClass:([NSNull class])]) {
            
            self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:fileURLString]];
            self.documentController.delegate = self;
            //self.documentController.UTI = @"com.adobe.pdf";
            [[[LRAppDelegate myAppdelegate] window] setTintColor:[UIColor blackColor]];
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
- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    [[[LRAppDelegate myAppdelegate] window] setTintColor:[UIColor whiteColor]];
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
    [LRUtility stopActivityIndicatorFromView:self.view];
    if([[error localizedDescription] isEqualToString:@"Plug-in handled load"])
        return;
    UIAlertView *documentFailAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [documentFailAlertView show];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [LRUtility stopActivityIndicatorFromView:self.view];
}
-(void)viewWillDisappear:(BOOL)animated
{
    if([self.delegate respondsToSelector:@selector(cancelaNetWorkOperation)]) {
        [self.delegate cancelaNetWorkOperation];
    }
    [[[LRAppDelegate myAppdelegate] window] setTintColor:[UIColor whiteColor]];
    
    [self.sessionDataTask suspend];
    
    [self.documentReaderWebView stopLoading];
    self.documentReaderWebView.delegate = nil;
    
    if([self.sliderTimer isValid]) {
        [self.sliderTimer invalidate];
    }
    [self.defaultSession invalidateAndCancel];
    
    [super viewWillDisappear:TRUE];
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

- (IBAction)closeProgressView:(id)sender {
    
    [self.sessionDataTask suspend];
    [self.sessionDataTask suspend];
    
    [self.documentReaderWebView stopLoading];
    self.documentReaderWebView.delegate = nil;
    
    if([self.sliderTimer isValid]) {
        [self.sliderTimer invalidate];
    }
    //  [self.defaultSession invalidateAndCancel];

    [self.navigationController popViewControllerAnimated:TRUE];
}
- (IBAction)sliderValueChanged:(id)sender {
    [self.audioPlayer stop];
    [self.audioPlayer setCurrentTime:self.audioPlayerSlider.value];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];

}
@end
