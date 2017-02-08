//
//  ProgressBarDelegate.m
//  Leerink
//
//  Created by Apple on 07/02/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import "ProgressBarDelegate.h"

@implementation ProgressBarDelegate

- (void) initWithDelegate:(id<ProgressBarDelegate>)delegate
{
    self.delegate = delegate;
}


@end
