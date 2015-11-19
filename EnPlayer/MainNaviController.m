//
//  MainNaviController.m
//  EnPlayer
//
//  Created by mahongjian on 13-11-20.
//  Copyright (c) 2013年 mahongjian. All rights reserved.
//

#import "MainNaviController.h"
#import "AudioLib.h"
#import "FileBrowser.h"

@interface MainNaviController ()

@end

@implementation MainNaviController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileSelected:) name:FileBrowserFileSelectedNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fileSelected:(NSNotification*)notification//文件被点击了
{
	NSDictionary* dicInfo = notification.userInfo;
	NSLog([dicInfo description]);
}
- (BOOL)canBecomeFirstResponder
{
	return YES;
}
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	id<AudioPlayerProtocol> player = [AudioLib defaultLib].player;
	if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause: // 切换播放、暂停按钮
				if(player.audioState==EAudioStatePlaying)
				{
					[player pause];
				}
				else if(player.audioState==EAudioStatePaused || player.audioState==EAudioStateStopped)
					[player play];
				NSLog(@"RemoteControl TogglePlayPause");
                break;
            case UIEventSubtypeRemoteControlPreviousTrack: // 播放上一曲按钮
                [[AudioLib defaultLib] playPrev];
				NSLog(@"RemoteControl PreviousTrack");
                break;
            case UIEventSubtypeRemoteControlNextTrack: // 播放下一曲按钮
                [[AudioLib defaultLib] playNext];
				NSLog(@"RemoteControl NextTrack");
                break;
            case UIEventSubtypeRemoteControlPlay: // 播放
                [player play];
				NSLog(@"RemoteControl Play");
                break;
            case UIEventSubtypeRemoteControlPause: // 暂停
                [player pause];
				NSLog(@"RemoteControl Pause");
                break;
            case UIEventSubtypeRemoteControlStop: // 停止
                [player stop];
				NSLog(@"RemoteControl Stop");
                break;
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
				NSLog(@"RemoteControl BeginSeekingBackward");
                break;
            case UIEventSubtypeRemoteControlEndSeekingBackward:
				NSLog(@"RemoteControl EndSeekingBackward");
                break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:
				NSLog(@"RemoteControl BeginSeekingForward");
                break;
            case UIEventSubtypeRemoteControlEndSeekingForward:
				NSLog(@"RemoteControl EndSeekingForward");
                break;
            default:
                break;
        }
    }
}
@end
