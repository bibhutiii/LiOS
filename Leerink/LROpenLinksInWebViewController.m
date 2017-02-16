//
//  LROpenLinksInWebViewController.m
//  Leerink
//
//  Created by Ashish on 20/10/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LROpenLinksInWebViewController.h"

@interface LROpenLinksInWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *openLinkInsideApplicationWebView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionBarButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation LROpenLinksInWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    // NSString *encodedString=[[self.linkURL relativeString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //  NSURL *weburl = [NSURL URLWithString:encodedString];
    //self.linkURL = @"http://www.google.com";
    
    if(self.linkURL == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Leerink" message:@"No URL available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
   
    if(self.isHtmlStringLoaded) {
        self.toolBar.hidden = TRUE;
        [self.openLinkInsideApplicationWebView loadHTMLString:self.linkURL baseURL:nil];
    }
    else {
        
        if(self.isLinkFromLogin == TRUE) {
            
            SEL aCloseButtonAction = sel_registerName("Close");
            
            UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close-32"] style:UIBarButtonItemStyleBordered target:self action:aCloseButtonAction];
            self.actionBarButtonItem = button;
            [self.actionBarButtonItem setTintColor:[UIColor blackColor]];
            // self.actionBarButtonItem = nil;
            
            self.toolBar.items = [NSArray arrayWithObject:button];
        }
        else {
            SEL aLogoutButton = sel_registerName("openInSafari");
            
            self.actionBarButtonItem.action = aLogoutButton;
        }
        
        NSURLRequest *aUrlRequest = nil;
        
        /*if (![self.linkURL hasPrefix:@"http://"]) {
         NSURL *aRequestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",self.linkURL]];
         NSURLRequest *aUrlRequest = [NSURLRequest requestWithURL:aRequestUrl];
         [self.openLinkInsideApplicationWebView loadRequest:aUrlRequest];
         
         }
         else {
         aUrlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.linkURL]];
         
         }*/
        aUrlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.linkURL]];
        [self.openLinkInsideApplicationWebView loadRequest:aUrlRequest];

    }
}
 - (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:TRUE];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}
- (void)Close
{
    [self dismissViewControllerAnimated:TRUE completion:^{
        
    }];
}
- (void)openInSafari
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil otherButtonTitles: @"Open in Safari", nil, nil];
    
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.linkURL]];
            break;
        }
    }
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error--%@",error);
    [LRUtility stopActivityIndicatorFromView:self.view];
    if(error)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.linkURL]];
    }
   /* UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Leerink"
                                                             message:[error localizedDescription]
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                   otherButtonTitles:nil, nil];
    [errorAlertView show]; */
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [LRUtility stopActivityIndicatorFromView:self.view];
}
- (void)viewWillDisappear:(BOOL)animated
{
    // [self.openLinkInsideApplicationWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@" "]]];
     [self.openLinkInsideApplicationWebView stopLoading];
    self.openLinkInsideApplicationWebView.delegate = nil;
    [super viewWillDisappear:TRUE];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
