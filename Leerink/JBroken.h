//
//  JBroken.h
//  Leerink
//
//  Created by Bibhuti on 29/06/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JBroken : NSObject

float firmwareVersion();
BOOL isDeviceJailbroken();
BOOL isAppCracked();
BOOL isAppStoreVersion();

@end
