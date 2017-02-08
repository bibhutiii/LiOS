//
//  DBManager.m
//  Leerink
//
//  Created by Apple on 18/01/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import "DBManager.h"

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
//static sqlite3_stmt *statement = nil;

@implementation DBManager

+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    //dirPaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    dirPaths = NSSearchPathForDirectoriesInDomains (NSLibraryDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"Leerink.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "create table if not exists MP3_Detail (FileName TEXT PRIMARY KEY, CurrentLocation TEXT)";
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            
            sql_stmt = "create table if not exists  MP3_FileDown(FileName TEXT PRIMARY KEY, CurrentProgress TEXT)";
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }

            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    
    return isSuccess;
}


#pragma mark - Method to store, retrieve, and delete mp3 file playing location.
- (BOOL) addEditLocation:(NSString*)FileName AndLocation:(float)CurrentLocation
{
    if([self getCurrentLocationByFileName:FileName]==0.0f)
    {
        return [ self saveData:FileName AndLocation:CurrentLocation];
    }
    else
    {
        return [ self updateData:FileName AndLocation:CurrentLocation];
    }
}

-(BOOL)deleteFileEntry:(NSString *)FileName
{
    BOOL status=YES;
    sqlite3 *database;
    NSString * theFileName=FileName;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        NSString * sState=@"DELETE FROM MP3_Detail WHERE FileName='";
        NSString * s=  [NSString stringWithFormat:@"%@%@%@",sState,theFileName,@"';"];
        
        const char *sqlStatement = [s cStringUsingEncoding:NSUTF8StringEncoding];//"DELETE FROM users WHERE id='3';";
        sqlite3_stmt *compiledStatement;
        sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL);
        
        
        if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
            status=NO;
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return status;
}


- (BOOL) saveData:(NSString*)FileName AndLocation:(float)CurrentLocation
{
    sqlite3 *database;
    NSString * theFileName=FileName;
    NSString * theCurrentLocation=[[NSNumber numberWithFloat:CurrentLocation] stringValue];;
    BOOL status=YES;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "insert into MP3_Detail (FileName,CurrentLocation) VALUES (?,?)";
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)    {
            sqlite3_bind_text( compiledStatement, 1,[theFileName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text( compiledStatement, 2,[theCurrentLocation UTF8String], -1, SQLITE_TRANSIENT);
        }
        if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
            status=NO;
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return status;
}

- (BOOL) updateData:(NSString*)FileName AndLocation:(float)CurrentLocation
{
    sqlite3 *database;
    NSString * theFileName=FileName;
    NSString * theCurrentLocation=[[NSNumber numberWithFloat:CurrentLocation] stringValue];;
    BOOL status=YES;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "UPDATE MP3_Detail SET CurrentLocation=? WHERE FileName=?";
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)    {
            sqlite3_bind_text( compiledStatement, 1,[theCurrentLocation UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text( compiledStatement, 2,[ theFileName UTF8String], -1, SQLITE_TRANSIENT);
        }
        if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
            status=NO;
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return status;
}



- (float) getCurrentLocationByFileName:(NSString*)FileName
{
    const char *dbpath =  [databasePath UTF8String];
    sqlite3_stmt    *statement;
    static sqlite3 *database = nil;
    float location=0.0f;
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT CurrentLocation FROM MP3_Detail WHERE FileName='%@'",FileName];
        
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                location = [numberFormatter numberFromString:[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)]].floatValue;  ;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return location;
}


#pragma mark - Method to store, retrieve, and delete mp3 file downloading entry.
-(BOOL)deleteDownloadEntry:(NSString *)FileName
{
    BOOL status=YES;
    sqlite3 *database;
    NSString * theFileName=FileName;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        NSString * sState=@"DELETE FROM MP3_FileDown WHERE FileName='";
        NSString * s=  [NSString stringWithFormat:@"%@%@%@",sState,theFileName,@"';"];
        
        const char *sqlStatement = [s cStringUsingEncoding:NSUTF8StringEncoding];
        sqlite3_stmt *compiledStatement;
        sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL);
        
        
        if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
            status=NO;
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return status;
}


- (BOOL) saveDownloadEntry:(NSString*)FileName AndProgress:(float)currentProgress
{
    sqlite3 *database;
    NSString * theFileName=FileName;
    NSString * theCurrentLocation=[[NSNumber numberWithFloat:currentProgress] stringValue];;
    BOOL status=YES;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "insert into MP3_FileDown (FileName,CurrentProgress) VALUES (?,?)";
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)    {
            sqlite3_bind_text( compiledStatement, 1,[theFileName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text( compiledStatement, 2,[theCurrentLocation UTF8String], -1, SQLITE_TRANSIENT);
        }
        if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
            status=NO;
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return status;
}

- (BOOL) updateDownloadEntry:(NSString*)FileName AndProgress:(float)currentProgress
{
    sqlite3 *database;
    NSString * theFileName=FileName;
    NSString * theCurrentLocation=[[NSNumber numberWithFloat:currentProgress] stringValue];;
    BOOL status=YES;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "UPDATE MP3_FileDown SET CurrentProgress=? WHERE FileName=?";
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)    {
            sqlite3_bind_text( compiledStatement, 1,[theCurrentLocation UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text( compiledStatement, 2,[ theFileName UTF8String], -1, SQLITE_TRANSIENT);
        }
        if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
            NSLog( @"Save Error: %s", sqlite3_errmsg(database) );
            status=NO;
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return status;
}




- (BOOL) isFileDonwloading:(NSString*)FileName
{
    const char *dbpath =  [databasePath UTF8String];
    sqlite3_stmt    *statement;
    static sqlite3 *database = nil;
    BOOL isExists=NO;
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT FileName FROM MP3_FileDown WHERE FileName='%@'",FileName];
        
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                isExists=YES;
                break;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return isExists;
}

- (float) getCurrentProgressByFileName:(NSString*)FileName
{
    const char *dbpath =  [databasePath UTF8String];
    sqlite3_stmt    *statement;
    static sqlite3 *database = nil;
    float location=0.0f;
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT CurrentProgress FROM MP3_FileDown WHERE FileName='%@'",FileName];
        
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                location = [numberFormatter numberFromString:[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)]].floatValue;  ;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return location;
}


@end
