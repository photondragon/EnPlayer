//
//  AudioPlayerProtocol.h
//  MusicPlayer
//
//  Created by mahj on 11/7/13.
//  Copyright (c) 2013年 photondragon. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef _ABCDHello_AudioPlayerProtocol_H_
#define _ABCDHello_AudioPlayerProtocol_H_

/// 声音播放状态
typedef enum _EAudioState
{//加载成功后可以进入Stopped状态，也可以直接进入Playing状态，这看具体怎么实现，没有强制要求
	EAudioStateNone=0,//未加载
	EAudioStateLoading,//正在加载
	EAudioStateFailed,//出错了
	EAudioStatePlaying,//正在播放
	EAudioStatePaused,//暂停
	EAudioStateStopped,//停止
}EAudioStates;

#define kAudioInfo_Title	@"title"
#define kAudioInfo_Artist	@"artist"
#define kAudioInfo_Album	@"album"
#define kAudioInfo_Artwork	@"artwork"

/// 声音播放器委托
@protocol AudioPlayerDelegate;

/// 音频播放器接口
@protocol AudioPlayerProtocol <NSObject>
-(void)load:(NSString*)audiofile;//加载音频文件
-(void)unload;//卸载音频文件
-(void)play;
-(void)pause;
-(void)stop;
-(NSDictionary*) audioInfo;
@property (nonatomic,retain) id<AudioPlayerDelegate> delegate;
@property (nonatomic,assign) EAudioStates audioState;
@property (nonatomic,assign) double currentTime;//当前播放位置（时间）
@property (nonatomic,assign,readonly) double totalTime;//总时长
@property (nonatomic,assign) int repeatTimes; //重复次数。0表示播放一次，1表示播放两次，以此类推。负值表示无限循环。
@end

/// 声音播放器委托
@protocol AudioPlayerDelegate <NSObject>
@optional
/// 通知状态变化
-(void) audioPlayer:(id<AudioPlayerProtocol>)player enterState:(EAudioStates)newState oldState:(EAudioStates)oldState;
/// 通知进度变化
-(void) audioPlayer:(id<AudioPlayerProtocol>)player progress:(double)currentTime;
/// 音频播放完毕的通知
/** 当音频播放到末尾停止播放时，会先触发一个-(void)audioPlayer:enterState:oldState:消息，
 之后然后才触发这个消息。如果你想播放结束后再自动重头开始播放，可以用到本消息
 */
-(void) audioPlayerReachEnd:(id<AudioPlayerProtocol>)player;
@end

/*
 假设MyAVAudioPlayer、OpenALPlayer、ThirdPartSoundPlayer都实现了AudioPlayerProtocol接口。
 如果你想让你的程序用AVAudio播放声音，就生成一个MyAVAudioPlayer对象：
 id<AudioPlayerProtocol> player = [[MyAVAudioPlayer alloc] init];
 如果你想让你的程序用OpenAL播放声音，就生成一个OpenALPlayer对象：
 id<AudioPlayerProtocol> player = [[OpenALPlayer alloc] init];
 如果你想让你的程序用第三方音频库播放声音，就生成一个ThirdPartSoundPlayer对象：
 id<AudioPlayerProtocol> player = [[ThirdPartSoundPlayer alloc] init];
 
 然后播放控制的代码都是一致的：
 [player play];
 [player stop];
 [player pause];
 使用者无需知道播放器对象到底是MyAVAudioPlayer对象、OpenALPlayer对象还是ThirdPartSoundPlayer对象，因为它们都是id<AudioPlayerProtocol>
*/
#endif