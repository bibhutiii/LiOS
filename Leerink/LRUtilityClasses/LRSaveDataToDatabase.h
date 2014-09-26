//
//  LRSaveDataToDatabase.h
//  Leerink
//
//  Created by Ashish on 22/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRLoadDataDelegate.h"

@interface LRSaveDataToDatabase : NSObject

@property (nonatomic, assign) id <LRLoadDataDelegate> delegate;
+ (NSMutableDictionary *)getparsedJSONDataForString:(NSString*)inresponsedata forOperation:(MKNetworkOperation*)inOperation withContextInfo:(id)iContextInfo;
+ (NSMutableDictionary *)getDocumentListJSONDataForString:(NSString*)inresponsedata forOperation:(MKNetworkOperation*)inOperation withContextInfo:(id)iContextInfo;
@end
