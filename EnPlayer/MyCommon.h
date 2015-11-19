//
//  MyCommon.h
//  EnPlayer
//
//  Created by mahongjian on 13-11-20.
//  Copyright (c) 2013年 mahongjian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioPlayerProtocol.h"

@interface MyCommon : NSObject
+(id<AudioPlayerProtocol>) player;
+(NSString*)documentDir;//返回Document目录
@end
