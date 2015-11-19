//
//  MyAVAudioPlayer.h
//  MusicPlayer
//
//  Created by mahj on 11/7/13.
//  Copyright (c) 2013年 photondragon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioPlayerProtocol.h"
#import <AVFoundation/AVFoundation.h>

//用AVAudioPlayer来实现AudioPlayerProtocol
@interface MyAVAudioPlayer : NSObject
<AudioPlayerProtocol,
AVAudioPlayerDelegate>
{
	AVAudioPlayer* player;
	NSTimer* updateProgressTimer;
    int _repeatTimes;
	NSMutableDictionary* audioInfo;
}
@end
