//
//  SSLPinsTestUtility.m
//  Leerink
//
//  Created by Bibhuti on 29/06/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import "SSLPinsTestUtility.h"
#import "ISPCertificatePinning.h"

@implementation SSLPinsTestUtility


+ (NSData*)loadCertificateFromFile:(NSString*)fileName {
    NSString *certPath =  [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:@"der"];
    NSData *certData = [[NSData alloc] initWithContentsOfFile:certPath];
    return certData;
}


+ (NSDictionary*) setupTestSSLPinsDictionnary {
    // Build our dictionnary of domain => certificates
    NSMutableDictionary *domainsToPin = [[NSMutableDictionary alloc] init];
    
    
    // For portalQA
    NSData *portalQAData = [SSLPinsTestUtility loadCertificateFromFile:@"portalqa.leerink.com"];
    if (portalQAData == nil) {
        NSLog(@"Failed to load a certificate for portalQA");
        return nil;
    }
    NSArray *portalQACerts = [NSArray arrayWithObject:portalQAData];
    [domainsToPin setObject:portalQACerts forKey:@"portalQA.leerink.com"];
    
    
    // For portal
    NSData *portalData = [SSLPinsTestUtility loadCertificateFromFile:@"portal.leerink.com"];
    if (portalData == nil) {
        NSLog(@"Failed to load a certificate for portal");
        return nil;
    }
    NSArray *portalCerts = [NSArray arrayWithObject:portalData];
    [domainsToPin setObject:portalCerts forKey:@"portal.leerink.com"];
    
    
    
    return domainsToPin;
}

@end
