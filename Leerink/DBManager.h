//
//  DBManager.h
//  Leerink
//
//  Created by Bibhuti on 18/01/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;
- (BOOL)createDB;

#pragma mark - Method to store, retrieve, and delete mp3 file playing location.
- (BOOL) saveData:(NSString*)FileName AndLocation:(float)CurrentLocation;
- (float) getCurrentLocationByFileName:(NSString*)FileName;
- (BOOL) addEditLocation:(NSString*)FileName AndLocation:(float)CurrentLocation;
- (BOOL) updateData:(NSString*)FileName AndLocation:(float)CurrentLocation;
- (BOOL)deleteFileEntry:(NSString *)FileName;


#pragma mark - Method to store, retrieve, and delete mp3 file downloading entry.
- (BOOL)deleteDownloadEntry:(NSString *)FileName;
- (BOOL) saveDownloadEntry:(NSString*)FileName AndProgress:(float)currentProgress;
- (BOOL) updateDownloadEntry:(NSString*)FileName AndProgress:(float)currentProgress;
- (BOOL) isFileDonwloading:(NSString*)FileName;
- (float) getCurrentProgressByFileName:(NSString*)FileName;

@end
