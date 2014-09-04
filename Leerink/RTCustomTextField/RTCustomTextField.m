//
//  RTCustomTextField.m
//  RisingTide
//
//  Created by Abhishek Chatterjee's iMAC on 05/09/13.
//  Copyright (c) 2013 Aditi. All rights reserved.
//

#import "RTCustomTextField.h"

@implementation RTCustomTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.edgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

- (void)setEnabled:(BOOL)enabled {
    
    [super setEnabled:enabled];
    
    if (enabled) {
        
        self.textColor = [UIColor colorWithRed:65.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1.0];
    }
    else {
        
        self.textColor = [UIColor grayColor];
    }
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    
    [super setUserInteractionEnabled:userInteractionEnabled];
    
    if (userInteractionEnabled) {
        
        self.textColor = [UIColor colorWithRed:65.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1.0];;
    }
    else {
        
        self.textColor = [UIColor grayColor];
    }
}

@end
