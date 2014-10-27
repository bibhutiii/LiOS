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

@end

@implementation LROpenLinksInWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [LRUtility startActivityIndicatorOnView:self.view withText:@"Please wait.."];
    NSURLRequest *aUrlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.linkURL]];
    [self.openLinkInsideApplicationWebView loadRequest:aUrlRequest];
    
    SEL aLogoutButton = sel_registerName("openInSafari");
    
    self.actionBarButtonItem.action = aLogoutButton;
}
- (void)openInSafari
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil otherButtonTitles: @"Open in Safari", nil, nil];
    
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSURL *url= [NSURL URLWithString:self.linkURL];
    
    switch (buttonIndex)
    {
        case 0:
        {
            [[UIApplication sharedApplication] openURL:url];
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
