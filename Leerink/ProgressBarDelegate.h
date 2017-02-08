//
//  ProgressBarDelegate.h
//  Leerink
//
//  Created by Apple on 07/02/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProgressBarDelegate <NSObject>
@required
- (void) UpdateProgress:(float)progress;
@end
// Protocol Definition ends here


@interface ProgressBarDelegate : NSObject

@property (nonatomic, weak) id <ProgressBarDelegate> delegate;

- (void) initWithDelegate:(id<ProgressBarDelegate>)delegate;
-(void)setProgress:(float)progress;

@end
