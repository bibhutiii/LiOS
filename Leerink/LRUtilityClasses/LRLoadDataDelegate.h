//
//  LRLoadDataDelegate.h
//  Leerink
//
//  Created by Ashish on 30/07/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKNetworkOperation.h"
@protocol LRLoadDataDelegate <NSObject>

@optional
- (void)didLoadData:(BOOL)isDataReceived;
- (void)didLoadDocumentOnWebView:(NSData *)documentData;
- (void)failedToParseTheDocumentWithErrorMessage:(NSString *)errorMessage;
- (void)cancelaNetWorkOperation;
- (void)selectDocumentForRowWithIndex:(int )index;
- (void)infoForAuthorsSelected:(id)sender withTag:(int)iTag;
- (void)showBioInformationForSelectedAnalystwithTag:(int)iTag;
- (void)showTextOnlyVersionOfTheDocumentWithTag:(int)iTag;
- (void)showPDFOnlyVersionOfTheDocumentWithTag:(int)iTag;
@end
