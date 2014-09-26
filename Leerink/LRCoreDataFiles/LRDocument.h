//
//  LRDocument.h
//  Leerink
//
//  Created by Ashish on 11/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LRAnalyst, LRSector, LRSymbol;

@interface LRDocument : NSManagedObject

@property (nonatomic, retain) NSString * documentAuthor;
@property (nonatomic, retain) NSDate * documentDate;
@property (nonatomic, retain) NSNumber * documentID;
@property (nonatomic, retain) NSString * documentTitle;
@property (nonatomic, retain) NSString * documentPath;
@property (nonatomic, retain) LRAnalyst *analyst;
@property (nonatomic, retain) LRSector *sector;
@property (nonatomic, retain) LRSymbol *symbol;

@end
