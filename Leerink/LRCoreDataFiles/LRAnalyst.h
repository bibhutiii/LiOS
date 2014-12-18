//
//  LRAnalyst.h
//  Leerink
//
//  Created by Ashish on 18/12/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LRDocument;

@interface LRAnalyst : NSManagedObject

@property (nonatomic, retain) NSString * analystInfo;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSSet *analystDocuments;
@end

@interface LRAnalyst (CoreDataGeneratedAccessors)

- (void)addAnalystDocumentsObject:(LRDocument *)value;
- (void)removeAnalystDocumentsObject:(LRDocument *)value;
- (void)addAnalystDocuments:(NSSet *)values;
- (void)removeAnalystDocuments:(NSSet *)values;

@end
