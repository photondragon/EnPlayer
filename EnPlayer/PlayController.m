//
//  PlayController.m
//  EnPlayer
//
//  Created by mahongjian on 13-11-20.
//  Copyright (c) 2013年 mahongjian. All rights reserved.
//

#import "PlayController.h"
#import "MyAVAudioPlayer.h"
#import "MyCommon.h"
#import "AudioLib.h"

@interface PlayController ()

@end

@implementation PlayController
@synthesize progressBar;
@synthesize sliderBar;
@synthesize labelTotalTime;
@synthesize labelCurrentTime;
@synthesize labelSliderTime;
@synthesize btnPlayPause;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        touchAssist = [[TouchAssistant alloc] init];
		player = [[AudioLib defaultLib] player];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        touchAssist = [[TouchAssistant alloc] init];
		player = [[AudioLib defaultLib] player];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated
{
    self.sliderBar.value = 0;
    soundDuration = 0;
    player.delegate = self;

    labelCurrentTime.text = @"0";
    labelTotalTime.text = [NSString stringWithFormat:@"%.1f",player.totalTime];
    labelSliderTime.hidden = TRUE;
}
-(void) viewWillDisappear:(BOOL)animated
{
    player.delegate = nil;
}
- (BOOL)canBecomeFirstResponder
{
	return YES;
}
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	[[self nextResponder] remoteControlReceivedWithEvent:event];//最终由根Controller处理
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onSliderPositionChanged:(id)sender
{
    double time = self.sliderBar.value*soundDuration;
    labelSliderTime.text = [NSString stringWithFormat:@"%.0f",time];
}
-(IBAction)onSliderTouchDown:(id)sender
{
	//    NSLog(@"touch Down");
    isTouchingSlider = TRUE;
    labelSliderTime.hidden = FALSE;
}
-(IBAction)onSliderTouchUpInside:(id)sender
{
	//    NSLog(@"touch Up Inside");
    isTouchingSlider = FALSE;
    double currentTime = self.sliderBar.value*soundDuration;
    labelCurrentTime.text = [NSString stringWithFormat:@"%.1f",currentTime];
    player.currentTime = currentTime;
    labelSliderTime.hidden = TRUE;
}
-(IBAction)onSliderTouchUpOutside:(id)sender
{
	//    NSLog(@"touch Up Outside");
    isTouchingSlider = FALSE;
    double currentTime = self.sliderBar.value*soundDuration;
    labelCurrentTime.text = [NSString stringWithFormat:@"%.1f",currentTime];
    player.currentTime = currentTime;
    labelSliderTime.hidden = TRUE;
}

-(IBAction)onBtnPlayPauseClicked:(id)sender
{
    if(player.audioState==EAudioStatePlaying)
    {
        [player pause];
    }
    else if(player.audioState==EAudioStatePaused || player.audioState==EAudioStateStopped)
        [player play];
}
-(IBAction)onBtnPrevClicked:(id)sender
{
	[[AudioLib defaultLib] playPrev];
}
-(IBAction)onBtnNextClicked:(id)sender
{
	[[AudioLib defaultLib] playNext];
}
-(IBAction)onBtnBackwardClicked:(id)sender
{
    player.currentTime -= 5.0;
}
-(IBAction)onBtnForwardClicked:(id)sender
{
    player.currentTime += 5.0;
}
#pragma mark AudioPlayerDelegate
// 通知状态变化
-(void) audioPlayer:(id<AudioPlayerProtocol>)aPlayer enterState:(EAudioStates)newState oldState:(EAudioStates)oldState
{
    if(player.totalTime != soundDuration)
    {
        soundDuration = player.totalTime;
        labelTotalTime.text = [NSString stringWithFormat:@"%.1f",soundDuration];
        if(isTouchingSlider==FALSE)
        {
            sliderBar.value = player.currentTime/soundDuration;
        }
        labelCurrentTime.text = [NSString stringWithFormat:@"%.1f",player.currentTime];
    }
    if(newState==EAudioStatePlaying)
        [btnPlayPause setTitle:@"暂停" forState:UIControlStateNormal];
    else
        [btnPlayPause setTitle:@"播放" forState:UIControlStateNormal];
}
// 通知进度变化
-(void) audioPlayer:(id<AudioPlayerProtocol>)aPlayer progress:(double)currentTime
{
    if(player.totalTime != soundDuration)
    {
        soundDuration = player.totalTime;
        labelTotalTime.text = [NSString stringWithFormat:@"%.1f",soundDuration];
    }
    if(isTouchingSlider==FALSE)
    {
        sliderBar.value = player.currentTime/soundDuration;
    }
    labelCurrentTime.text = [NSString stringWithFormat:@"%.1f",player.currentTime];
}
-(void) audioPlayerReachEnd:(id<AudioPlayerProtocol>)player
{
    //NSLog(@"reach end");
    //[player play];
}
#pragma mark touches
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    [touchAssist touchBeganAtPoint:point];
}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    [touchAssist touchMovedToPoint:point];
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    enum ETouchAssistantType type = [touchAssist touchEndedAtPoint:point];
    if(type==ETouchAssistantType_SwipeH)
    {
        if(touchAssist.offset.x>=0)
            player.currentTime += 5.0;
        else
            player.currentTime -= 5.0;
    }
}
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    [touchAssist touchEndedAtPoint:point];
}
@end
