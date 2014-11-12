//
//  LRDocumentViewController.h
//  Leerink
//
//  Created by Ashish on 11/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRLoadDataDelegate.h"

@interface LRDocumentViewController : UIViewController<LRLoadDataDelegate,UIDocumentInteractionControllerDelegate>

@property (nonatomic, assign) id <LRLoadDataDelegate> delegate;
@property (nonatomic, strong) NSString *documentTitleToBeSavedAsPdf;
@property (nonatomic, strong) NSString *documentId;

- (void)fetchDocument;
@end
