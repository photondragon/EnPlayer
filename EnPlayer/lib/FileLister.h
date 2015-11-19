//
//  FileList.h
//  EnPlayer
//
//  Created by mahongjian on 13-12-18.
//  Copyright (c) 2013年 mahongjian. All rights reserved.
//

#import <Foundation/Foundation.h>

enum EFileListItemType
{
	EFileListItemNone = 0,
	EFileListItemFile,
	EFileListItemDir,
};

//文件信息
@interface FileListItem : NSObject
{
}
@property (nonatomic,retain,readonly) NSString* name;
@property (nonatomic,assign,readonly) enum EFileListItemType type;
@end

@interface FileLister : NSObject
{
	NSMutableArray* arrayItems;
}
+(FileLister*)defaultLister;
///是否隐藏目录（不列出）。默认否
@property (nonatomic,assign) BOOL hideDirectory;
///当前目录。
/** 如果目录以'/'结尾，会自动去掉末尾的'/'
 nil表示没有设置目录。
 如果设置此属性为根目录@"/"，则自动转换成空串@""。
 如果设置此属性为@""，则自动转换为nil
 */
@property (nonatomic,retain) NSString* directory;
///后缀名过滤（对目录无效）。多个后缀名以点分隔。如设置为@"png.jpg"，则只列出*.png和*.jpg文件。
@property (nonatomic,retain) NSString* extFilters;
@property (nonatomic,assign,readonly) int itemsCount;
-(NSString*) getNameByIndex:(int)index;
-(FileListItem*) getByIndex:(int)index;
@end
