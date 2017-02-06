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
#import <MobileCoreServices/MobileCoreServices.h>
#import "MediaManager.h"

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

- (IBAction)Mp3_Player_Actions:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *mp3ContentTextView;

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
    
    self.responseDictionary = [NSDictionary new];

    self.audioPlayerView.hidden = TRUE;
    self.documentReaderWebView.hidden = TRUE;
    // self.isAudioFilePlayed = FALSE;
    
    [MediaManager sharedInstance].songName=self.documentTitleToBeSavedAsPdf;
    [MediaManager sharedInstance].artist=self.author;
    [MediaManager sharedInstance].album=self.date;

    
    if(self.isAudioFilePlayed == TRUE) {
        
    }
    else {
        self.documentReaderWebView.hidden = FALSE;
        [self.documentReaderWebView setDelegate:self];
    }
    if([self.documentType isEqual:@"mp3"])
    {
        if([self isFileAlreadyExist])
        {
            [LRUtility stopActivityIndicatorFromView:self.view];
            self.progressSuperView.hidden = TRUE;
        }
        else
        {
            [self fetchDocument];
            self.progressSuperView.layer.cornerRadius = 3.0f;
            self.progressSuperView.layer.borderWidth = 2.0f;
        }
    }
    else
    {
    [self fetchDocument];
        self.progressSuperView.layer.cornerRadius = 3.0f;
        self.progressSuperView.layer.borderWidth = 2.0f;
    }
    
   /* [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationIsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil]; */
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
   
    /* [aGetDocumentService getDocument:^(BOOL isDocumentFetched) {
     NSLog(@"document fetched");
     } withDocumentId:self.documentId withUserId:self.userId andPath:self.documentPath];
     */
    LRAppDelegate *appDelegate = (LRAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.lrDocumentViewController = self;
}

/*- (void)appplicationIsActive:(NSNotification *)notification {
    NSLog(@"Application Did Become Active");
    if(![[MediaManager sharedInstance] isAudioPlaying])
    {
        [self.button_Play setEnabled:TRUE];
        [self.button_Pause setEnabled:FALSE];
        [self.button_Stop setEnabled:TRUE];
        
    }
    else
    {
        [self.button_Play setEnabled:FALSE];
        [self.button_Pause setEnabled:TRUE];
        [self.button_Stop setEnabled:TRUE];
        
    }
    float slidervalue=[[MediaManager sharedInstance] currentPlaybackTime];
    self.audioPlayerSlider.value = slidervalue;
}*/

- (void)applicationEnteredForeground:(NSNotification *)notification {
    NSLog(@"Application Entered Foreground");
    if(![[MediaManager sharedInstance] isAudioPlaying])
    {
        [self.button_Play setEnabled:TRUE];
        [self.button_Pause setEnabled:FALSE];
        [self.button_Stop setEnabled:TRUE];
        
    }
    else
    {
        [self.button_Play setEnabled:FALSE];
        [self.button_Pause setEnabled:TRUE];
        [self.button_Stop setEnabled:TRUE];
        
    }
    float slidervalue=[[MediaManager sharedInstance] currentPlaybackTime];
    self.audioPlayerSlider.value = slidervalue;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:TRUE];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f],
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                      }];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:9.0/255.0 green:60.0/255.0 blue:113/255.0 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
   

}
- (void)updateSlider {
    // Update the slider about the music time
    //self.audioPlayerSlider.value = self.audioPlayer.currentTime;
    float slidervalue=[[MediaManager sharedInstance] currentPlaybackTime];
    self.audioPlayerSlider.value = slidervalue;
   if(slidervalue<=0.0f)
    {
        [self.button_Play setEnabled:TRUE];
        [self.button_Pause setEnabled:FALSE];
        [self.button_Stop setEnabled:TRUE];
        [self.sliderTimer invalidate];
        self.sliderTimer=nil;
    }
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
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *libraryDirectory = [paths objectAtIndex:0];
                self.documentTitleToBeSavedAsPdf = [self.documentTitleToBeSavedAsPdf stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
                
                [decodedData writeToFile:[libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.%@",self.documentId,self.date,self.documentType]] atomically:YES];
                
                CFStringRef fileExtension = (__bridge CFStringRef) self.documentType;
                CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
                
                if (UTTypeConformsTo(fileUTI, kUTTypeAudio)) {
                    NSLog(@"It's Audio");
                    
                    if([[MediaManager sharedInstance] isAudioPlaying])
                    {
                        [[MediaManager sharedInstance] pause];
                    }
                    
                    self.audioPlayerView.hidden = FALSE;
                    // Get the file path to the song to play.
                    
                    // NSString *filePath = [[NSBundle mainBundle] pathForResource:@"simsg355q"
                    //       ofType:@"wav"];
                    
                    // Convert the file path to a URL.
                    //   NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
                    
                    //Initialize the AVAudioPlayer.
                    NSFileManager *filemgr;
                    
                    filemgr = [NSFileManager defaultManager];
                    
                    if ([filemgr fileExistsAtPath:[NSString stringWithFormat:@"/%@/%@_%@.%@",libraryDirectory,self.documentId,self.date,self.documentType]] == YES) {
                        NSLog (@"File exists");
                        
                        NSString *fileURLString = [NSString stringWithFormat:@"/%@/%@_%@.%@",libraryDirectory,self.documentId,self.date,self.documentType];// your file URL as *string*
                        
                        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:fileURLString];
                        [[MediaManager sharedInstance] initWithURL:fileURL];
                        
                        //self.audioPlayer = [[AVAudioPlayer alloc]
                         //               initWithContentsOfURL:fileURL error:nil];
                        
                        [[MediaManager sharedInstance] prepareToPlay];
                        // [self.audioPlayer prepareToPlay];
                        
                        [[MediaManager sharedInstance] setCurrentTime:0];
                        //self.audioPlayer.currentTime = 0;
                        
                        //self.audioPlayer.delegate = self;
                        
                        self.progressSuperView.hidden = TRUE;
                        
                        SEL updateSlider = sel_registerName("updateSlider");
                        // Set a timer which keep getting the current music time and update the UISlider in 1 sec interval
                        self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:updateSlider userInfo:nil repeats:YES];
                        // Set the maximum value of the UISlider
                        self.audioPlayerSlider.maximumValue = [[MediaManager sharedInstance] getDuration];
                        
                        self.audioPlayerSlider.value = 0.0;
                        
                        self.audioPlayerView.userInteractionEnabled = TRUE;
                        
                        self.audioPlayerSlider.userInteractionEnabled = TRUE;
                        
                        //[self.audioPlayer play];
                        
                        [[MediaManager sharedInstance] play];
                        //float currentTime = [[MediaManager sharedInstance] currentPlaybackTime];
                        
                        [self.button_Play setEnabled:FALSE];
                        
                        if(self.mp3Content.length > 0)
                            self.mp3ContentTextView.text = self.mp3Content;
                        else
                            self.mp3ContentTextView.text = @"No MP3 Doc Content available";
                    }
                }
                else {
                    if([self.documentType isEqualToString:@"pdf"]) {
                        [self.documentReaderWebView loadData:decodedData MIMEType:[NSString stringWithFormat:@"application/%@",self.documentType] textEncodingName:@"utf-8" baseURL:nil];
                    }
                    else {
                        NSFileManager *filemgr;
                        
                        filemgr = [NSFileManager defaultManager];
                        
                        if ([filemgr fileExistsAtPath:[NSString stringWithFormat:@"/%@/%@_%@.%@",libraryDirectory,self.documentId,self.date,self.documentType]] == YES) {
                            NSLog (@"File exists");
                            
                            NSString *fileURLString = [NSString stringWithFormat:@"/%@/%@_%@.%@",libraryDirectory,self.documentId,self.date,self.documentType];// your file URL as *string*
                            [self.documentReaderWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:fileURLString]]];
                            
                        }
                    }
                    SEL aLogoutButton = sel_registerName("iBooks");
                    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Share-black-32"] style:0 target:self action:aLogoutButton];
                    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
                    self.navigationItem.rightBarButtonItem = backButton;
                    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
                }
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    
    NSFileManager *filemgr;
    
    filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:[NSString stringWithFormat:@"/%@/%@_%@.%@",libraryDirectory,self.documentId,self.date,self.documentType]] == YES) {
        NSLog (@"File exists");
        
        NSString *fileURLString = [NSString stringWithFormat:@"/%@/%@_%@.%@",libraryDirectory,self.documentId,self.date, self.documentType];// your file URL as *string*
        
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
    
    //[self.sessionDataTask suspend];
    
    [self.documentReaderWebView stopLoading];
    self.documentReaderWebView.delegate = nil;
    
    if([self.sliderTimer isValid]) {
        [self.sliderTimer invalidate];
    }
   // [self.defaultSession invalidateAndCancel];
    
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
    [[MediaManager sharedInstance] stop];
    [[MediaManager sharedInstance] setCurrentTime:self.audioPlayerSlider.value];
    [[MediaManager sharedInstance] prepareToPlay];
    [[MediaManager sharedInstance] play];
    [self.button_Play setEnabled:FALSE];
    [self.button_Pause setEnabled:TRUE];
    [self.button_Stop setEnabled:TRUE];
    /*SEL updateSlider = sel_registerName("updateSlider");
    self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:updateSlider userInfo:nil repeats:YES];
    self.audioPlayerSlider.maximumValue = [[MediaManager sharedInstance] getDuration];
    self.audioPlayerSlider.value = [[MediaManager sharedInstance] currentPlaybackTime];*/
}
- (IBAction)Mp3_Player_Actions:(id)sender {
    
    switch ([sender tag]) {
        case 501:
        {
            if(self.audioPlayerSlider.value > 0.0) {
                [self.sliderTimer invalidate];
                self.sliderTimer=nil;
                [[MediaManager sharedInstance] play];
                SEL updateSlider = sel_registerName("updateSlider");
                // Set a timer which keep getting the current music time and update the UISlider in 1 sec interval
                self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:updateSlider userInfo:nil repeats:YES];
                // Set the maximum value of the UISlider
                self.audioPlayerSlider.maximumValue = [[MediaManager sharedInstance] getDuration];
            }
            else {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *libraryDirectory = [paths objectAtIndex:0];
                
                NSString *fileURLString = [NSString stringWithFormat:@"/%@/%@_%@.%@",libraryDirectory,self.documentId,self.date,self.documentType];// your file URL as *string*
                
                NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:fileURLString];
                 [[MediaManager sharedInstance] initWithURL:fileURL];
                
               /* self.audioPlayer = [[AVAudioPlayer alloc]
                                    initWithContentsOfURL:fileURL error:nil];
               
                [self.audioPlayer prepareToPlay];
                
                [self.audioPlayer play];*/
                [[MediaManager sharedInstance] prepareToPlay];

                [[MediaManager sharedInstance] play];
                [self.sliderTimer invalidate];
                self.sliderTimer=nil;
                SEL updateSlider = sel_registerName("updateSlider");
                self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:updateSlider userInfo:nil repeats:YES];
                self.audioPlayerSlider.maximumValue = [[MediaManager sharedInstance] getDuration];
                
            }
            [self.button_Play setEnabled:FALSE];
            [self.button_Pause setEnabled:TRUE];
            [self.button_Stop setEnabled:TRUE];
            
        }
            break;
        case 502:
        {
            //[self.audioPlayer pause];
            [self.sliderTimer invalidate];
            [[MediaManager sharedInstance] pause];
            [self.button_Play setEnabled:TRUE];
            [self.button_Pause setEnabled:FALSE];
            [self.button_Stop setEnabled:TRUE];
        }
            break;
        case 503:
        {
            self.audioPlayerSlider.value = 0.0;
            //[self.audioPlayer stop];
            [[MediaManager sharedInstance] stop];
            [self.sliderTimer invalidate];
            [self.button_Play setEnabled:TRUE];
            [self.button_Stop setEnabled:FALSE];
            [self.button_Pause setEnabled:FALSE];
        }
            break;
            
        default:
            break;
    }
}
- (void)setAudioToPause
{
}

-(bool)isFileAlreadyExist
{
    NSFileManager *filemgr;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    
    filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:[NSString stringWithFormat:@"/%@/%@_%@.%@",libraryDirectory,self.documentId,self.date,self.documentType]] == YES) {
        self.audioPlayerView.hidden = FALSE;
        NSLog (@"File exists");
        NSString *fileURLString = [NSString stringWithFormat:@"/%@/%@_%@.%@",libraryDirectory,self.documentId,self.date,self.documentType];// your file URL as *string*
        
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:fileURLString];
        NSString *urlString=[NSString stringWithFormat:@"%@",[[MediaManager sharedInstance] url]];
        NSString *newUrlString=[NSString stringWithFormat:@"%@",fileURL];
        
        if([[MediaManager sharedInstance] currentPlaybackTime]>0.0f && [urlString isEqual:newUrlString]) {
            
            if(![[MediaManager sharedInstance] isAudioPlaying])
            {
               //  [[MediaManager sharedInstance] play];
                [self.button_Play setEnabled:TRUE];
                [self.button_Pause setEnabled:FALSE];
                [self.button_Stop setEnabled:TRUE];

            }
            else
            {
                [self.button_Play setEnabled:FALSE];
                [self.button_Pause setEnabled:TRUE];
                [self.button_Stop setEnabled:TRUE];

            }
            
            self.progressSuperView.hidden = TRUE;
            [self.sliderTimer invalidate];
            self.sliderTimer=nil;
            SEL updateSlider = sel_registerName("updateSlider");
            // Set a timer which keep getting the current music time and update the UISlider in 1 sec interval
            self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:updateSlider userInfo:nil repeats:YES];
            // Set the maximum value of the UISlider
            self.audioPlayerSlider.maximumValue = [[MediaManager sharedInstance] getDuration];
            self.audioPlayerSlider.value = [[MediaManager sharedInstance] currentPlaybackTime];
         
            
            self.audioPlayerView.userInteractionEnabled = TRUE;
            
            self.audioPlayerSlider.userInteractionEnabled = TRUE;
            
           // [self.button_Play setEnabled:FALSE];
            
            if(self.mp3Content.length > 0)
                self.mp3ContentTextView.text = self.mp3Content;
            else
                self.mp3ContentTextView.text = @"No MP3 Doc Content available";

        }
        else {
            
            if([[MediaManager sharedInstance] isAudioPlaying])
            {
                [[MediaManager sharedInstance] pause];
            }
            
            [[MediaManager sharedInstance] initWithURL:fileURL];
            [[MediaManager sharedInstance] prepareToPlay];
            [[MediaManager sharedInstance] setCurrentTime:0];
            self.progressSuperView.hidden = TRUE;
            
            [self.sliderTimer invalidate];
            self.sliderTimer=nil;
            SEL updateSlider = sel_registerName("updateSlider");
            // Set a timer which keep getting the current music time and update the UISlider in 1 sec interval
            self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:updateSlider userInfo:nil repeats:YES];
            // Set the maximum value of the UISlider
            self.audioPlayerSlider.maximumValue = [[MediaManager sharedInstance] getDuration];
            
            float currentDuration=[[DBManager getSharedInstance]getCurrentLocationByFileName:[NSString stringWithFormat:@"%@",[fileURL lastPathComponent]]];
            if(currentDuration>0.0f)
            {
                self.audioPlayerSlider.value = currentDuration;
                [[MediaManager sharedInstance] setCurrentTime:currentDuration];
            }
            else
            {
                self.audioPlayerSlider.value = 0.0;
            }
            
            self.audioPlayerView.userInteractionEnabled = TRUE;
            
            self.audioPlayerSlider.userInteractionEnabled = TRUE;
            
            [[MediaManager sharedInstance] play];
            
            [self.button_Play setEnabled:FALSE];
            [self.button_Pause setEnabled:TRUE];
            [self.button_Stop setEnabled:TRUE];
            
            if(self.mp3Content.length > 0)
                self.mp3ContentTextView.text = self.mp3Content;
            else
                self.mp3ContentTextView.text = @"No MP3 Doc Content available";
        }
        return true;
    }
    else
    {
       return false;
    }
}

@end
