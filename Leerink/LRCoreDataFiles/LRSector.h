//
//  LRSector.h
//  Leerink
//
//  Created by Ashish on 21/08/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LRDocument;

@interface LRSector : NSManagedObject

@property (nonatomic, retain) NSNumber * researchID;
@property (nonatomic, retain) NSString * sectorName;
@property (nonatomic, retain) NSSet *sectorDocuments;
@end

@interface LRSector (CoreDataGeneratedAccessors)

- (void)addSectorDocumentsObject:(LRDocument *)value;
- (void)removeSectorDocumentsObject:(LRDocument *)value;
- (void)addSectorDocuments:(NSSet *)values;
- (void)removeSectorDocuments:(NSSet *)values;

@end
