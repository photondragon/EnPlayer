//
//  PlayController.h
//  EnPlayer
//
//  Created by mahongjian on 13-11-20.
//  Copyright (c) 2013年 mahongjian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioPlayerProtocol.h"
#import "TouchAssistant.h"

@interface PlayController : UIViewController
<AudioPlayerDelegate>
{
//    id<AudioPlayerProtocol> player;
    double soundDuration;
    BOOL isTouchingSlider;
    TouchAssistant* touchAssist;
	id<AudioPlayerProtocol> player;
}
@property (nonatomic,retain) IBOutlet UIProgressView* progressBar;
@property (nonatomic,retain) IBOutlet UISlider* sliderBar;
@property (nonatomic,retain) IBOutlet UILabel* labelTotalTime;
@property (nonatomic,retain) IBOutlet UILabel* labelCurrentTime;
@property (nonatomic,retain) IBOutlet UILabel* labelSliderTime;//显示当前划动位置相应的时间
@property (nonatomic,retain) IBOutlet UIButton* btnPlayPause;
-(IBAction)onSliderPositionChanged:(id)sender;
-(IBAction)onSliderTouchDown:(id)sender;
-(IBAction)onSliderTouchUpInside:(id)sender;
-(IBAction)onSliderTouchUpOutside:(id)sender;
-(IBAction)onBtnPrevClicked:(id)sender;
-(IBAction)onBtnNextClicked:(id)sender;
-(IBAction)onBtnBackwardClicked:(id)sender;
-(IBAction)onBtnForwardClicked:(id)sender;
-(IBAction)onBtnPlayPauseClicked:(id)sender;
@end
