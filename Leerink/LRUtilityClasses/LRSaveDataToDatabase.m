//
//  LRSaveDataToDatabase.m
//  Leerink
//
//  Created by Ashish on 22/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import "LRSaveDataToDatabase.h"
#import "LRAnalyst.h"
#import "LRSector.h"
#import "LRDocument.h"
#import "LRSymbol.h"
#import "NSDate+Helper.h"

@implementation LRSaveDataToDatabase
+ (NSMutableDictionary *)getparsedJSONDataForString:(NSString*)inresponsedata forOperation:(MKNetworkOperation*)inOperation withContextInfo:(id)iContextInfo
{
    NSMutableDictionary *parsedContent = nil;
    switch ([inOperation documentType]) {
        case eLRDocumentAnalyst:
        {
            if(inresponsedata)
            {
                NSData *responseData = [inresponsedata dataUsingEncoding:NSUTF8StringEncoding];
                
                parsedContent = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
                NSArray *listOfAnalysts = [parsedContent objectForKey:@"DataList"];
                
                NSArray *analysts = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRAnalyst" withPredicate:nil, nil];
                
                if(![analysts isKindOfClass:([NSNull class])]) {
                    for (LRAnalyst *analyst in analysts) {
                        [[[LRCoreDataHelper sharedStorageManager] context] deleteObject:analyst];
                    }
                }
                if(![listOfAnalysts isKindOfClass:([NSNull class])]) {
                    for (NSDictionary *analystDictionary in listOfAnalysts) {
                        LRAnalyst *analyst = (LRAnalyst *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRAnalyst" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
                        
                        NSString *name = [analystDictionary objectForKey:@"DisplayName"];
                        NSArray *array = [name componentsSeparatedByString:@","];
                        analyst.firstName = [array objectAtIndex:1];
                        analyst.lastName = [array objectAtIndex:0];
                        analyst.userId = [NSNumber numberWithInt:[[analystDictionary objectForKey:@"UserID"] intValue]];
                    }
                    [[LRCoreDataHelper sharedStorageManager] saveContext];
                }
            }
            // after the data has been loaded into the database, reload the table to compose the data in the tableview.
            
        }
            break;
        case eLRDocumentSector:
        {
            if(inresponsedata)
            {
                NSData *responseData = [inresponsedata dataUsingEncoding:NSUTF8StringEncoding];
                
                parsedContent = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
                NSArray *listOfSectors = [parsedContent objectForKey:@"DataList"];
                
                NSArray *sectors = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRSector" withPredicate:nil, nil];
                
                if(![sectors isKindOfClass:([NSNull class])]) {
                    for (LRAnalyst *analyst in sectors) {
                        [[[LRCoreDataHelper sharedStorageManager] context] deleteObject:analyst];
                    }
                }
                if(![listOfSectors isKindOfClass:([NSNull class])]) {
                    for (NSDictionary *analystDictionary in listOfSectors) {
                        LRSector *sector = (LRSector *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRSector" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
                        
                        sector.sectorName = [analystDictionary objectForKey:@"SectorName"];
                        sector.researchID = [NSNumber numberWithInt:[[analystDictionary objectForKey:@"ResearchID"] intValue]];
                    }
                    [[LRCoreDataHelper sharedStorageManager] saveContext];
                }
            }
            // after the data has been loaded into the database, reload the table to compose the data in the tableview.
            
        }
            break;
        case eLRDocumentSymbol:
        {
            if(inresponsedata)
            {
                NSData *responseData = [inresponsedata dataUsingEncoding:NSUTF8StringEncoding];
                
                parsedContent = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
                NSArray *listOfSymbols = [parsedContent objectForKey:@"DataList"];
                
                NSArray *symbols = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRSymbol" withPredicate:nil, nil];
                if(![symbols isKindOfClass:([NSNull class])]) {
                    for (LRSymbol *symbol in symbols) {
                        [[[LRCoreDataHelper sharedStorageManager] context] deleteObject:symbol];
                    }
                    
                }
                if(![listOfSymbols isKindOfClass:([NSNull class])]) {
                    for (NSDictionary *analystDictionary in listOfSymbols) {
                        LRSymbol *symbol = (LRSymbol *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRSymbol" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
                        
                        symbol.nameSymbol = [analystDictionary objectForKey:@"NameSymbol"];
                        symbol.tickerID = [NSNumber numberWithInt:[[analystDictionary objectForKey:@"TickerID"] intValue]];
                    }
                    [[LRCoreDataHelper sharedStorageManager] saveContext];
                }
            }
            // after the data has been loaded into the database, reload the table to compose the data in the tableview.
            
        }
            break;
            
        default:
            break;
    }
    return parsedContent;
}
+ (NSMutableDictionary *)getDocumentListJSONDataForString:(NSString*)inresponsedata forOperation:(MKNetworkOperation*)inOperation withContextInfo:(id)iContextInfo
{
    NSMutableDictionary *parsedContent = nil;
    switch ([inOperation documentListType]) {
            
        case eLRDocumentListAnalyst:
        {
            LRAnalyst *analyst = (LRAnalyst *)[iContextInfo objectForKey:@"AnalystDocumentList"];
            
            NSArray *documentsForAnalyst = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRDocument" withPredicate:@"analyst.userId == %d",analyst.userId, nil];
            if(documentsForAnalyst && documentsForAnalyst.count > 0) {
                for (LRDocument *aDocument in documentsForAnalyst) {
                    [[[LRCoreDataHelper sharedStorageManager] context] deleteObject:aDocument];
                }
            }
            [[LRCoreDataHelper sharedStorageManager] saveContext];
            
            NSData *responseData = [inresponsedata dataUsingEncoding:NSUTF8StringEncoding];
            
            parsedContent = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
            NSArray *listOfDocuments = [parsedContent objectForKey:@"DataList"];
            if(![listOfDocuments isKindOfClass:([NSNull class])]) {
                for (NSDictionary *aDocumentDictionary in listOfDocuments) {
                    
                    LRDocument *aDocument = (LRDocument *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRDocument" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
                    aDocument.documentAuthor = [aDocumentDictionary objectForKey:@"Author"];
                    aDocument.documentTitle = [aDocumentDictionary objectForKey:@"DocumentTitle"];
                    
                    NSArray *arr = [[aDocumentDictionary objectForKey:@"UpdateDate"] componentsSeparatedByString:@"T"];
                    if(arr.count > 0) {
                        aDocument.documentDate = [arr objectAtIndex:0];
                    }
                    
                    aDocument.documentID = [[aDocumentDictionary objectForKey:@"DocumentID"] stringValue];
                    aDocument.documentPath = [aDocumentDictionary objectForKey:@"Path"];
                    aDocument.analyst = analyst;
                    [analyst addAnalystDocumentsObject:aDocument];
                    
                    [[LRCoreDataHelper sharedStorageManager] saveContext];
                }
            }
            
        }
            break;
        case eLRDocumentListSector:
        {
            LRSector *sector = (LRSector *)[iContextInfo objectForKey:@"SectorDocumentList"];
            
            NSArray *documentsForSector = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRDocument" withPredicate:@"sector.researchID == %d",sector.researchID, nil];
            if(documentsForSector && documentsForSector.count > 0) {
                for (LRDocument *aDocument in documentsForSector) {
                    [[[LRCoreDataHelper sharedStorageManager] context] deleteObject:aDocument];
                }
            }
            [[LRCoreDataHelper sharedStorageManager] saveContext];
            
            NSData *responseData = [inresponsedata dataUsingEncoding:NSUTF8StringEncoding];
            
            parsedContent = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
            NSArray *listOfDocuments = [parsedContent objectForKey:@"DataList"];
            if(![listOfDocuments isKindOfClass:([NSNull class])]) {
                for (NSDictionary *aDocumentDictionary in listOfDocuments) {
                    
                    LRDocument *aDocument = (LRDocument *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRDocument" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
                    aDocument.documentAuthor = [aDocumentDictionary objectForKey:@"Author"];
                    aDocument.documentTitle = [aDocumentDictionary objectForKey:@"DocumentTitle"];
                    NSArray *arr = [[aDocumentDictionary objectForKey:@"UpdateDate"] componentsSeparatedByString:@"T"];
                    if(arr.count > 0) {
                        aDocument.documentDate = [arr objectAtIndex:0];
                    }
                    aDocument.documentID = [[aDocumentDictionary objectForKey:@"DocumentID"] stringValue];
                    aDocument.documentPath = [aDocumentDictionary objectForKey:@"Path"];
                    aDocument.sector = sector;
                    [sector addSectorDocumentsObject:aDocument];
                    
                    [[LRCoreDataHelper sharedStorageManager] saveContext];
                }
            }
            
        }
            break;
        case eLRDocumentListSymbol:
        {
            LRSymbol *symbol = (LRSymbol *)[iContextInfo objectForKey:@"SymbolDocumentList"];
            
            NSArray *documentsForSector = [[LRCoreDataHelper sharedStorageManager] fetchObjectsForEntityName:@"LRDocument" withPredicate:@"symbol.tickerID == %d",symbol.tickerID, nil];
            if(documentsForSector && documentsForSector.count > 0) {
                for (LRDocument *aDocument in documentsForSector) {
                    [[[LRCoreDataHelper sharedStorageManager] context] deleteObject:aDocument];
                }
            }
            [[LRCoreDataHelper sharedStorageManager] saveContext];
            
            NSData *responseData = [inresponsedata dataUsingEncoding:NSUTF8StringEncoding];
            
            parsedContent = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
            NSArray *listOfDocuments = [parsedContent objectForKey:@"DataList"];
            if(![listOfDocuments isKindOfClass:([NSNull class])]) {
                for (NSDictionary *aDocumentDictionary in listOfDocuments) {
                    
                    LRDocument *aDocument = (LRDocument *)[[LRCoreDataHelper sharedStorageManager] createManagedObjectForName:@"LRDocument" inContext:[[LRCoreDataHelper sharedStorageManager] context]];
                    aDocument.documentAuthor = [aDocumentDictionary objectForKey:@"Author"];
                    aDocument.documentTitle = [aDocumentDictionary objectForKey:@"DocumentTitle"];
                    NSArray *arr = [[aDocumentDictionary objectForKey:@"UpdateDate"] componentsSeparatedByString:@"T"];
                    if(arr.count > 0) {
                        aDocument.documentDate = [arr objectAtIndex:0];
                    }
                    aDocument.documentID = [[aDocumentDictionary objectForKey:@"DocumentID"] stringValue];
                    aDocument.documentPath = [aDocumentDictionary objectForKey:@"Path"];
                    aDocument.symbol = symbol;
                    [symbol addSymbolDocumentsObject:aDocument];
                    
                    [[LRCoreDataHelper sharedStorageManager] saveContext];
                }
            }
        }
            break;
        default:
            break;
    }
    return parsedContent;
}
@end
