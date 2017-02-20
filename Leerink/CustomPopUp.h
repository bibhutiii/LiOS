//
//  CustomPopUp.h
//  Leerink
//
//  Created by Apple on 20/02/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ClickDelegates;

@interface CustomPopUp : UIView{
    
    UIView *childPopUp;
    id<ClickDelegates> _click_delegate;
    UIViewController *_parent;
    
}

@property (nonatomic, retain) id<ClickDelegates> _click_delegate;
@property (nonatomic, retain) UIViewController *_parent;

-(void) initAlertwithParent : (UIViewController *) parent andMessage:(NSString *)message withDelegate : (id<ClickDelegates>) theDelegate;

-(IBAction)OnOKClick :(id) sender;

-(void) hide;

-(void) show;

@end


// Delegate

@protocol ClickDelegates<NSObject>

@optional

-(void) okClicked;
-(void) cancelClicked;

@end
