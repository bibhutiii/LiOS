//
//  CustomPopUp.m
//  Leerink
//
//  Created by Apple on 20/02/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import "CustomPopUp.h"
#import "Util.h"

@implementation CustomPopUp{
    
    float popUpX;
    CGRect popUpRect;
}

@synthesize _click_delegate, _parent;


-(void) initAlertwithParent : (UIViewController *) parent andMessage:(NSString *)message withDelegate : (id<ClickDelegates>) theDelegate{
    
    self._click_delegate = theDelegate;
    self._parent = parent;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect rect = CGRectMake(0, 0, screenWidth, screenHeight);
    self.frame = rect;
    self.backgroundColor = [UIColor clearColor];;
    
    childPopUp = [UIView new];
    float popUpHeight = screenHeight/3;
    
    popUpX = 20.0;
    
    popUpRect = CGRectMake(popUpX, (screenHeight - popUpHeight)/2, screenWidth - (popUpX * 2), popUpHeight);
    childPopUp.center = self.center;
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [self setBorderOnly:childPopUp withBGColor:[UIColor orangeColor] withCornerRadius:5.0 andBorderWidth:0.0 andBorderColor:[UIColor greenColor] WithAlpha:1];
    childPopUp.frame = popUpRect;
    [self addSubview:childPopUp];
    
    [self addMessage:message];
    
    [self addButton];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    [UIView commitAnimations];
    
}

-(void) show{
    
    [self._parent.view addSubview:self];
}

-(void) addMessage:(NSString *)aMsgStr{
    
    // Add Label
    UIWebView *googleView = [[UIWebView alloc] initWithFrame:CGRectMake(popUpX, popUpX, popUpRect.size.width - popUpX, popUpX)];
    googleView.backgroundColor = [UIColor clearColor];
    googleView.opaque = NO;
    [googleView loadHTMLString:[NSString stringWithFormat:@"%@%@%@",@"<body style='font-size: 2px;'>",aMsgStr,@"</body>"] baseURL:nil];
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 1200)];
    view.backgroundColor = [UIColor clearColor];
    [childPopUp addSubview:googleView];
    
}


-(void) addButton{
    
    // Add Button
    UIButton *okBtn = [[UIButton alloc]initWithFrame:CGRectMake(popUpX, childPopUp.frame.size.height - 50, popUpRect.size.width - 40, 40)];
    okBtn.backgroundColor=[UIColor blueColor];
    [self setBorderOnly:okBtn  withBGColor:[UIColor greenColor] withCornerRadius:5.0 andBorderWidth:0.0 andBorderColor:[UIColor greenColor] WithAlpha:1];
    [okBtn setTitle:@"OK" forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(OnOKClick:) forControlEvents:UIControlEventTouchDown];
    [childPopUp addSubview:okBtn];
    
}

-(IBAction)OnOKClick :(id) sender{
    
    [_click_delegate okClicked];
    
}

-(void) show : (UIViewController *) parent{
    
}

-(void) hide{
    
    [self removeFromSuperview];
    
}

- (void)bounce1AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
    [UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.2];
    self.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}


-(void) setBorderOnly:(UIView *) theView withBGColor:(UIColor *) color withCornerRadius :(float) radius andBorderWidth :(float) borderWidth andBorderColor :(UIColor *) bgColor WithAlpha:(float) curAlpha
{
    theView.layer.borderWidth = borderWidth;
    theView.layer.cornerRadius = radius;
    theView.layer.borderColor = [bgColor CGColor];
    UIColor *c = [color colorWithAlphaComponent:curAlpha];
    theView.layer.backgroundColor = [c CGColor];
}

@end
