//
//  LROpenLinksInWebViewController.h
//  Leerink
//
//  Created by Ashish on 20/10/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LROpenLinksInWebViewController : UIViewController<UIActionSheetDelegate,UIWebViewDelegate>

@property (nonatomic, strong) NSString *linkURL;
@property (nonatomic, assign) BOOL isLinkFromLogin;
@property (nonatomic, assign) BOOL isHtmlStringLoaded;

@end
