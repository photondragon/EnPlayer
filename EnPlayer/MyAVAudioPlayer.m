//
//  MyAVAudioPlayer.m
//  MusicPlayer
//
//  Created by mahj on 11/7/13.
//  Copyright (c) 2013年 photondragon. All rights reserved.
//

#import "MyAVAudioPlayer.h"

@implementation MyAVAudioPlayer
@synthesize delegate;
@synthesize audioState;

-(id) init
{
	self = [super init];
	if(self)
	{
		
	}
	return self;
}
-(void) dealloc
{
	if(audioState != EAudioStateNone)
	{
		[self unload];
	}
	[delegate release];
	[super dealloc];
}

-(void) notifyNewState:(EAudioStates)newState oldState:(EAudioStates)oldState
{
    switch (newState) {
        case EAudioStateFailed:
            NSLog(@"EAudioState Failed");
            break;
        case EAudioStateLoading:
            NSLog(@"EAudioState Loading");
            break;
        case EAudioStateNone:
            NSLog(@"EAudioState None");
            break;
        case EAudioStatePaused:
            NSLog(@"EAudioState Paused");
            break;
        case EAudioStatePlaying:
            NSLog(@"EAudioState Playing");
            break;
        case EAudioStateStopped:
            NSLog(@"EAudioState Stopped");
            break;
        default:
            break;
    }
	if(oldState==newState)
		return;
	if(audioState==EAudioStatePlaying)
		updateProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
	else
	{
		if(updateProgressTimer)
		{
			[updateProgressTimer invalidate];
			updateProgressTimer = nil;
		}
	}
	if(delegate && [delegate respondsToSelector:@selector(audioPlayer:enterState:oldState:)])
		[delegate audioPlayer:self enterState:audioState oldState:EAudioStateNone];
}
-(void) notifyProgress:(double)currentTime
{
	if(delegate && [delegate respondsToSelector:@selector(audioPlayer:progress:)])
		[delegate audioPlayer:self progress:currentTime];
}
-(void)notifyReachEnd
{
    if(delegate && [delegate respondsToSelector:@selector(audioPlayerReachEnd:)])
        [delegate audioPlayerReachEnd:self];
}
-(void)load:(NSString*)audiofile//加载音频文件
{
	if(audioState != EAudioStateNone)
	{
		[self unload];
	}
	NSData* data = [NSData dataWithContentsOfFile:audiofile];
	if(data)
	{
		NSError* error=nil;
		player = [[AVAudioPlayer alloc] initWithData:data error:&error];
		if(player && error==nil)
		{
			player.delegate = self;
            player.numberOfLoops = _repeatTimes;
			audioState = EAudioStateStopped;
		}
		else
		{
			audioState = EAudioStateFailed;
		}
	}
	else
		audioState = EAudioStateFailed;
	[self notifyNewState:audioState oldState:EAudioStateNone];
}
-(void)unload
{
	if(audioState != EAudioStateNone)
	{
		EAudioStates oldstate = audioState;
		audioState = EAudioStateNone;
		if(player)
		{
			player.delegate = nil;
			[player release];
			player = nil;
		}
		
		[self notifyNewState:audioState oldState:oldstate];
	}
	if(updateProgressTimer)
	{
		[updateProgressTimer invalidate];
		updateProgressTimer = nil;
	}
}
-(void)play
{
	if(audioState!=EAudioStateStopped && audioState!=EAudioStatePaused)
		return;
	EAudioStates oldstate = audioState;
	if([player play])
		audioState = EAudioStatePlaying;
	else
		audioState = EAudioStateFailed;
	[self notifyNewState:audioState oldState:oldstate];
}
-(void)pause
{
	if(audioState!=EAudioStatePlaying)
		return;
	EAudioStates oldstate = audioState;
	[player pause];
	audioState = EAudioStatePaused;
	[self notifyNewState:audioState oldState:oldstate];
}
-(void)stop
{
	if(audioState!=EAudioStatePlaying && audioState!=EAudioStatePaused)
		return;
	EAudioStates oldstate = audioState;
	[player stop];
	self.currentTime = 0.0;
	audioState = EAudioStateStopped;
	[self notifyNewState:audioState oldState:oldstate];
}

-(double) totalTime
{
	return player.duration;
}
-(double) currentTime
{
	return player.currentTime;
}
-(void) setCurrentTime:(double)currentTime
{
    if(currentTime<0)
        currentTime = 0;
    else if(currentTime>=player.duration)
    {
        currentTime = player.duration-0.05;//如果设置currentTime>player.duration，则AVAudioPlayer会出错，然后就不能播放了。
        if(currentTime<0)
            currentTime = 0;
    }
	player.currentTime = currentTime;
	[self notifyProgress:player.currentTime];
}

-(void) updateProgress
{
	if(audioState!=EAudioStatePlaying)
		return;
	[self notifyProgress:player.currentTime];
}
-(int) repeatTimes
{
    return _repeatTimes;
}
-(void) setRepeatTimes:(int)repeatTimes
{
    _repeatTimes = repeatTimes;
    player.numberOfLoops = _repeatTimes;
}
-(NSDictionary*) audioInfo
{
	if(audioInfo==nil)
	{
		;
	}
	return nil;
}

#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	EAudioStates oldstate = audioState;
	if(flag==TRUE)
		audioState = EAudioStateStopped;
	else//出现解码错误
		audioState = EAudioStateFailed;
	[self notifyNewState:audioState oldState:oldstate];
    if(audioState == EAudioStateStopped)
        [self notifyReachEnd];
}

//??????未测试?????
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	EAudioStates oldstate = audioState;
	audioState = EAudioStateFailed;
	[self notifyNewState:audioState oldState:oldstate];
}
//??????未测试?????
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	EAudioStates oldstate = audioState;
	audioState = EAudioStatePaused;
	[self notifyNewState:audioState oldState:oldstate];
}
//??????未测试?????
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
	if(flags == AVAudioSessionInterruptionOptionShouldResume)
	{
		;
	}
	EAudioStates oldstate = audioState;
	audioState = EAudioStatePlaying;
	[self notifyNewState:audioState oldState:oldstate];
}
@end
