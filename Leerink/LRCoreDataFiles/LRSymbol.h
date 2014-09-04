//
//  LRSymbol.h
//  Leerink
//
//  Created by Ashish on 21/08/2014.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LRSymbol : NSManagedObject

@property (nonatomic, retain) NSString * nameSymbol;
@property (nonatomic, retain) NSNumber * tickerID;
@property (nonatomic, retain) NSSet *symbolDocuments;
@end

@interface LRSymbol (CoreDataGeneratedAccessors)

- (void)addSymbolDocumentsObject:(NSManagedObject *)value;
- (void)removeSymbolDocumentsObject:(NSManagedObject *)value;
- (void)addSymbolDocuments:(NSSet *)values;
- (void)removeSymbolDocuments:(NSSet *)values;

@end
