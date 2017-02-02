//
//  MediaManager.m
//  Leerink
//
//  Created by Apple on 09/01/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import "MediaManager.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import "DBManager.h"

static MediaManager *sharedInstance = nil;


@interface MediaManager (){
    AVAudioPlayer *audioPlayer;
}

@property (nonatomic) bool isSongPaused;


@end
@implementation MediaManager


-(id)init{
    if(self = [super init]){
        
    }
    return self;
}

+(MediaManager *)sharedInstance{
    //create an instance if not already else return
    if(!sharedInstance){
        sharedInstance = [[[self class] alloc] init];
  
    }
    return sharedInstance;
}

-(void)playWithURL:(NSURL *)url{
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc]    initWithContentsOfURL:url error:&error ];
    if(error == nil){
        [audioPlayer setDelegate:self];
        [audioPlayer play];
        _isSongPaused=false;
        [self setUpRemoteControl];
    }
    _isSongPaused=false;
    
}

-(void)initWithURL:(NSURL *)url{
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [audioPlayer setDelegate:self];
}


-(void)play{
    [audioPlayer play];
    _isSongPaused=false;
    [self setUpRemoteControl];
}

-(void)stop{
    [audioPlayer stop];
    _isSongPaused=true;
    [self deleteFileEntry];
    [self setUpRemoteControl];
}

-(void)prepareToPlay{
    [audioPlayer prepareToPlay];
}

-(void)pause{
    [audioPlayer pause];
    _isSongPaused=true;
    [self saveCurrentPosition];
    [self setUpRemoteControl];
}

-(void)setCurrentTime:(float) value{
    [audioPlayer setCurrentTime:value];
}

-(float)currentPlaybackTime{
    
    return audioPlayer.currentTime;
}

-(NSURL *)url;
{
    return audioPlayer.url;
}

-(NSTimeInterval)getDuration{
    
    return audioPlayer.duration;
}

-(void)deleteFileEntry
{
    NSURL *filePath=audioPlayer.url;
    NSString *fileName = [filePath lastPathComponent];
    [[DBManager getSharedInstance]deleteFileEntry:fileName];
}

-(void)saveCurrentPosition
{
    BOOL success = NO;
    //NSString *alertString = @"Data Insertion failed";
    NSURL *filePath=audioPlayer.url;
    NSString *fileName = [filePath lastPathComponent];
    float CurrentLocation=audioPlayer.currentTime;
    success = [[DBManager getSharedInstance]addEditLocation:fileName AndLocation:CurrentLocation];
    if (success == NO) {
        /*UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
         alertString message:nil
         delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show]; */
    }

}

-(void)setUpRemoteControl
{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        
        MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"LeerinkLogo"]];
        
        [songInfo setObject:self.songName forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:self.artist forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:self.album forKey:MPMediaItemPropertyAlbumTitle];
        [songInfo setObject:[NSNumber numberWithDouble:audioPlayer.currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        [songInfo setObject:[NSNumber numberWithDouble:audioPlayer.duration] forKey:MPMediaItemPropertyPlaybackDuration];
      
        [songInfo setObject:[NSNumber numberWithDouble:(_isSongPaused? 0.0f:1.0f)] forKey:MPNowPlayingInfoPropertyPlaybackRate];

        [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        
        [playingInfoCenter setNowPlayingInfo:songInfo];
        
        
    }
}

-(bool)isAudioPlaying
{
    return audioPlayer.playing;
    
}


// Stop the timer when the music is finished (Need to implement the AVAudioPlayerDelegate in the Controller header)
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    // Music completed
    _isSongPaused=TRUE;
    [self stop];
}


- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"-- interrupted --");
    [self pause];
}


//----------- THIS PART NOT WORKING WHEN RUNNING IN BACKGROUND ----------
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
                         withFlags:(NSUInteger)flags
{
    if (flags == AVAudioSessionInterruptionFlags_ShouldResume) {
        [self play];
    }
}

@end
