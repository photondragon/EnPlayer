//
//  AudioLib.m
//  EnPlayer
//
//  Created by mahongjian on 13-11-20.
//  Copyright (c) 2013年 mahongjian. All rights reserved.
//

#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import "AudioLib.h"
#import "MyAVAudioPlayer.h"

static AudioLib* g_defalutLib = nil;

NSString* documentDir()//返回Document目录
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    if(paths==nil || paths.count==0)
        return nil;
    return [paths objectAtIndex:0];
}
@implementation AudioLib
@synthesize player;
@synthesize currentAudioFile;
@synthesize fileLister;

+(AudioLib*) defaultLib
{
    if(g_defalutLib==nil)
        g_defalutLib = [[AudioLib alloc] init];
    return g_defalutLib;
}
-(void) listDir:(NSString*)dir
{
    NSArray* subs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:Nil];
    for (NSString* sub in subs)
    {
        NSString* subpath = [NSString stringWithFormat:@"%@/%@",dir,sub];
        BOOL isDirectory;
        if([[NSFileManager defaultManager] fileExistsAtPath:subpath isDirectory:&isDirectory])
        {
            if(isDirectory)
                ;//[self listDir:subpath];
            else
                ;//[arrayLib addObject:sub];
        }
    }
}

-(id) init
{
    self = [super init];
    if(self)
    {
		fileLister = [[FileLister alloc] init];
		fileLister.extFilters = @"mp3.wav";
        player = [[MyAVAudioPlayer alloc] init];
        player.repeatTimes = -1;
		currentIndex = -1;
    }
    return self;
}
-(NSInteger) count
{
    return fileLister.itemsCount;
}
-(void)playNext//下一首
{
	int count = [self count];
	int index;
	if(currentIndex>=count-1 || currentIndex<0)
		index = 0;
	else
		index = currentIndex+1;
	while (1) {
		FileListItem* item = [fileLister getByIndex:index];
		if(item.type==EFileListItemFile)
		{
			[self playByIndex:index];
			break;
		}
		index++;
		if(index==count)
			index = 0;
	}
}
-(void)playPrev//上一首
{
	int count = [self count];
	int index;
	if(currentIndex>=count || currentIndex<=0)
		index = count-1;
	else
		index = currentIndex-1;
	while (1) {
		FileListItem* item = [fileLister getByIndex:index];
		if(item.type==EFileListItemFile)
		{
			[self playByIndex:index];
			break;
		}
		index--;
		if(index==-1)
			index += count;
	}
}
-(BOOL)playByIndex:(int)index
{
	FileListItem* item = [fileLister getByIndex:index];
	if(item==nil)
		return FALSE;
	if(item.type==EFileListItemFile)
	{
		currentIndex = index;
		NSString* file = [NSString stringWithFormat:@"%@/%@",fileLister.directory,item.name];
		if([currentAudioFile isEqualToString:file]==FALSE)
		{
			[player load:file];
			[player play];
			currentAudioFile = file;

			//注册远程控制
			[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
			//[self becomeFirstResponder];

			//锁屏界面设置
			NSDictionary* dicAudioInfo = [AudioLib audioInfo:currentAudioFile];
			if(dicAudioInfo && NSClassFromString(@"MPNowPlayingInfoCenter"))
			{
				NSMutableDictionary *songInfo = [ [NSMutableDictionary alloc] init];

				NSString* titleString =[dicAudioInfo objectForKey:kAudioInfo_Title];
				if(titleString)
					[songInfo setObject:titleString forKey:MPMediaItemPropertyTitle];
				NSString* artistString = [dicAudioInfo objectForKey:kAudioInfo_Artist];
				if(artistString)
					[songInfo setObject:artistString forKey:MPMediaItemPropertyArtist];
				NSString* albumTitleString = [dicAudioInfo objectForKey:kAudioInfo_Album];
				if(albumTitleString)
					[songInfo setObject:albumTitleString forKey:MPMediaItemPropertyAlbumTitle];
				UIImage* artworkImage = [dicAudioInfo objectForKey:kAudioInfo_Artwork];
				if(artworkImage)
				{
					MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc]
													initWithImage:artworkImage];
					if(albumArt)
						[songInfo setObject: albumArt forKey:MPMediaItemPropertyArtwork];
				}
				[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
			}

//			//取消锁屏设置
//		    if(NSClassFromString(@"MPNowPlayingInfoCenter"))
//				[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];

//			//[self resignFirstResponder];
//			[[UIApplication sharedApplication] endReceivingRemoteControlEvents];

		}
		return TRUE;
	}
	else//目录
		currentIndex = -1;
	return FALSE;
}

+(NSDictionary*) audioInfo:(NSString*)file
{
	NSURL * fileURL=[NSURL fileURLWithPath:file];
	//AudioFileTypeID fileTypeHint = kAudioFileMP3Type;
	NSString *fileExtension = [[fileURL path] pathExtension];
	if (![fileExtension isEqual:@"mp3"] && ![fileExtension isEqual:@"m4a"])
		return nil;

	OSStatus err = noErr;

	//打开audio文件
	//__bridge:把ObjC对象转为CoreFoundation对象，只是类型转换，不作其它操作
	AudioFileID fileID = nil;
	err = AudioFileOpenURL((__bridge CFURLRef) fileURL,
						   kAudioFileReadPermission, 0, &fileID );
	if( err != noErr ) {
		NSLog( @"AudioFileOpenURL failed" );
		return nil;
	}

	//	//???
	//	UInt32 id3DataSize = 0;
	//	err = AudioFileGetPropertyInfo( fileID, kAudioFilePropertyID3Tag,
	//								   &id3DataSize, NULL );
	//	if( err != noErr ) {
	//		NSLog( @"AudioFileGetPropertyInfo failed for ID3 tag" );
	//	}

	//获取音乐信息Dictionary
	CFDictionaryRef dictRef = 0;
	UInt32 piDataSize = sizeof(dictRef);
	err = AudioFileGetProperty(fileID, kAudioFilePropertyInfoDictionary,
							   &piDataSize, &dictRef );
	if( err != noErr ) {
		CFRelease(dictRef);
		AudioFileClose(fileID);
		NSLog(@"AudioFileGetProperty(kAudioFilePropertyInfoDictionary) failed");
		return nil;
	}
	NSDictionary* dictInfo = CFBridgingRelease(dictRef);
	NSString * Album = [dictInfo objectForKey:[NSString stringWithUTF8String: kAFInfoDictionary_Album]];
	NSString * Artist = [dictInfo objectForKey:[NSString stringWithUTF8String: kAFInfoDictionary_Artist]];
	NSString * Title = [dictInfo objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_Title]];
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	if(Album)
		[dict setObject:Album forKey:kAudioInfo_Album];
	if(Artist)
		[dict setObject:Artist forKey:kAudioInfo_Artist];
	if(Title)
		[dict setObject:Title forKey:kAudioInfo_Title];

	//获取专辑图片
	CFDataRef albumPicRef= nil;
	UInt32 picDataSize = sizeof(picDataSize);
	err =AudioFileGetProperty( fileID, kAudioFilePropertyAlbumArtwork,
							  &picDataSize, &albumPicRef);
	if(!err){
		NSData* imagedata= CFBridgingRelease(albumPicRef);
		UIImage* image = [[UIImage alloc] initWithData:imagedata];
		if(image)
			[dict setObject:image forKey:kAudioInfo_Artwork];
	}
	if([dict objectForKey:kAudioInfo_Artwork]==nil)
	{//普通方法取不到图片，换用高级方法
		AVURLAsset *avURLAsset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
		BOOL find = FALSE;
		for (NSString *format in [avURLAsset availableMetadataFormats])
		{
			NSLog(@"-------format:%@",format);
			for (AVMetadataItem *metadataItem in [avURLAsset metadataForFormat:format])
			{
				NSLog(@"commonKey:%@",metadataItem.commonKey);
				if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
					//取出封面artwork，从data转成image显示
					UIImage* image = [UIImage imageWithData:[(NSDictionary*)metadataItem.value objectForKey:@"data"]];
					if(image)
						[dict setObject:image forKey:kAudioInfo_Artwork];
					find = TRUE;
					break;
				}
			}
			if(find)
				break;
		}
	}

	AudioFileClose(fileID);

	return dict;
}
@end
