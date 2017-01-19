//
//  DBManager.h
//  Leerink
//
//  Created by Apple on 18/01/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;
-(BOOL)createDB;
- (BOOL) saveData:(NSString*)FileName AndLocation:(float)CurrentLocation;
- (float) getCurrentLocationByFileName:(NSString*)FileName;
- (BOOL) addEditLocation:(NSString*)FileName AndLocation:(float)CurrentLocation;
- (BOOL) updateData:(NSString*)FileName AndLocation:(float)CurrentLocation;
-(BOOL)deleteFileEntry:(NSString *)FileName;

@end
