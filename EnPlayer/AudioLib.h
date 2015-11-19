//
//  AudioLib.h
//  EnPlayer
//
//  Created by mahongjian on 13-11-20.
//  Copyright (c) 2013年 mahongjian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioPlayerProtocol.h"
#import "FileLister.h"

@interface AudioLib : NSObject
{
	int currentIndex;
}
+(AudioLib*) defaultLib;
+(NSDictionary*) audioInfo:(NSString*)file;
@property (nonatomic,assign,readonly) NSInteger count;//音频个数
@property (nonatomic,retain,readonly) id<AudioPlayerProtocol> player;
@property (nonatomic,retain,readonly) NSString* currentAudioFile;
@property (nonatomic,retain,readonly) FileLister* fileLister;
//@property (nonatomic,assign) int playIndex;	//当前播放的音乐的index
-(BOOL)playByIndex:(int)index;//如果是文件，则播放，并返回TRUE。如果是目录，则打开此目录，并返回FALSE，此时界面需要刷新列表。
-(void)playNext;//下一首
-(void)playPrev;//上一首
@end
