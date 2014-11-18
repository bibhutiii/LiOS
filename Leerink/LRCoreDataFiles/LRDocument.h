//
//  LRDocument.h
//  Leerink
//
//  Created by Ashish on 18/11/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LRAnalyst, LRSector, LRSymbol;

@interface LRDocument : NSManagedObject

@property (nonatomic, retain) NSString * documentAuthor;
@property (nonatomic, retain) NSString * documentDate;
@property (nonatomic, retain) NSString * documentID;
@property (nonatomic, retain) NSString * documentPath;
@property (nonatomic, retain) NSString * documentTitle;
@property (nonatomic, retain) LRAnalyst *analyst;
@property (nonatomic, retain) LRSector *sector;
@property (nonatomic, retain) LRSymbol *symbol;

@end
