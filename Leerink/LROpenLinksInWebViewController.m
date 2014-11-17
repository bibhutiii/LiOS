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
     [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    // NSString *encodedString=[[self.linkURL relativeString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //  NSURL *weburl = [NSURL URLWithString:encodedString];
    // self.linkURL = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *aUrlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.linkURL]];
    
    
    [self.openLinkInsideApplicationWebView loadRequest:aUrlRequest];
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
    
    
    //  UIWebView *aEWbivew = [[UIWebView alloc] initWithFrame:self.openLinkInsideApplicationWebView.bounds];
    //   [aEWbivew loadRequest:[NSURLRequest requestWithURL:self.linkURL]];
    // [self.view addSubview:aEWbivew];
    //aEWbivew.delegate = self;
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
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [LRUtility stopActivityIndicatorFromView:self.view];
}
- (void)viewWillDisappear:(BOOL)animated
{
    // [self.openLinkInsideApplicationWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@" "]]];
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
