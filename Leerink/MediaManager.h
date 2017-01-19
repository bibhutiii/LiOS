//
//  MediaManager.h
//  Leerink
//
//  Created by Apple on 09/01/17.
//  Copyright © 2017 leerink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface MediaManager : NSObject<AVAudioPlayerDelegate>

+(MediaManager *)sharedInstance;
-(void)playWithURL:(NSURL *)url;
-(void)initWithURL:(NSURL *)url;
-(float)currentPlaybackTime;
-(NSTimeInterval)getDuration;
-(void)play;
-(void)stop;
-(void)prepareToPlay;
-(void)pause;
-(void)setCurrentTime:(float) value;
-(void)setUpRemoteControl;
-(bool)isAudioPlaying;
-(NSURL *)url;


@end
