//
//  MyCommon.m
//  EnPlayer
//
//  Created by mahongjian on 13-11-20.
//  Copyright (c) 2013年 mahongjian. All rights reserved.
//

#import "MyCommon.h"
#import "MyAVAudioPlayer.h"

id<AudioPlayerProtocol> g_player = nil;
@implementation MyCommon

+(void) initialize
{
    if(g_player==nil)
    {
        g_player = [[MyAVAudioPlayer alloc] init];
        g_player.repeatTimes = -1;
    }
}
+(id<AudioPlayerProtocol>) player
{
    if(g_player==nil)
        [MyCommon initialize];
    return g_player;
}

+(NSString*)documentDir//返回Document目录
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    if(paths==nil || paths.count==0)
        return nil;
    return [paths objectAtIndex:0];
}
@end
