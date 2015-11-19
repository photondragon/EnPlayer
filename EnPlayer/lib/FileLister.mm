//
//  FileList.m
//  EnPlayer
//
//  Created by mahongjian on 13-12-18.
//  Copyright (c) 2013年 mahongjian. All rights reserved.
//

#import "FileLister.h"

#define MaxCheckPostfixLen 128 //最大检测的后缀名长度。如果后缀名长度超过这个值，则不对其进行后缀名过滤

@implementation FileListItem
@synthesize name;
@synthesize type;
-(void)setFileName:(NSString *)aName
{
	name = aName;
}
-(void)setFileType:(EFileListItemType)aType
{
	type = aType;
}
@end

/////////////////////////////////////
inline int FileListFindSubStringCaseInsensitive(const unichar*substr,int sublen,const unichar*string,int len)
{
	int end = len-sublen;
	for(int i=0;i<=end;i++)
	{
		int j	= 0;
		while(j<sublen && (string[i+j]==substr[j]))
			j++;
		if(j==sublen)
			return i;
	}
	return -1;
}

static FileLister* g_defaultLister = nil;

@interface FileLister(hidden)
-(void) relistDir;
@end

@implementation FileLister
@synthesize hideDirectory;
@synthesize directory;
@synthesize extFilters;
+(FileLister*)defaultLister
{
	if(g_defaultLister==nil)
	{
		g_defaultLister = [[FileLister alloc] init];
	}
	return g_defaultLister;
}

-(id) init
{
	self = [super init];
	if(self)
	{
		arrayItems = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)setExtFilters:(NSString *)filters
{
	NSUInteger len = filters.length;
	if(filters && len==0)
		filters = nil;

	if(filters==extFilters || [filters isEqualToString:extFilters])
		return;

	if(len>0)
		extFilters = filters;
	else
		extFilters = nil;

	[self relistDir];
}
-(void)setDirectory:(NSString*)dirPath
{
	if(dirPath==directory || [dirPath isEqualToString:directory])
		return;

	NSUInteger len = dirPath.length;
	if(len>0)
	{
		unichar c;
		[dirPath getCharacters:&c range:NSMakeRange(len-1, 1)];
		if(c=='/')//去掉末尾的/
			directory = [dirPath substringToIndex:len-1];
		else
			directory = dirPath;
	}
	else
		directory = nil;

	[self relistDir];
}
-(int) itemsCount
{
	return arrayItems.count;
}
-(NSString*) getNameByIndex:(int)index
{
	return [self getByIndex:index].name;
}
-(FileListItem*) getByIndex:(int)index
{
	if(index<0 || index>arrayItems.count)
		return nil;
	return [arrayItems objectAtIndex:index];
}
-(void) relistDir
{
	[arrayItems removeAllObjects];
	if(directory==nil)
		return;

	NSFileManager* fm	= [NSFileManager defaultManager];
	NSArray* files	= [fm contentsOfDirectoryAtPath:directory error:nil];
	int count	= files.count;

	unichar* filters = 0;
	unichar* ext = 0;
	int filterslen = extFilters.length;
	if(filterslen>0)
	{
		filters = new unichar[filterslen+2];
		[[extFilters lowercaseString] getCharacters:filters+1 range:NSMakeRange(0, filterslen)];
		filters[0] = '.';
		filterslen++;
		filters[filterslen++] = '.';
		ext = new unichar[MaxCheckPostfixLen+2];//存储文件后缀名，+2以使前后能容下两个点号.
	}

	for(int i=0;i<count;i++)
	{
		NSString* name	= [files objectAtIndex:i];
		BOOL isDir;
		if([fm fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",directory,name] isDirectory:&isDir]==NO)//文件不存在
		{
			continue;
		}
		if(isDir)
		{
			if(hideDirectory)
				continue;//忽略目录
		}
		else if(filterslen>0)
		{
			int len = name.length;
			int cpylen;
			if(len>MaxCheckPostfixLen+1)
				cpylen = MaxCheckPostfixLen+1;
			else
				cpylen = len;
			[name getCharacters:ext range:NSMakeRange(len-cpylen,cpylen)];
			int j = cpylen-1;
			while (j>=0 && ext[j]!='.')j--;
			if(j<0)//没找到.号，也就是没有后缀名(或后缀名太长)
				continue;
			int extlen=0;
			for (; j<cpylen; j++)
			{
				if (ext[j]>='A' && ext[j]<='Z')
					ext[extlen++] = ext[j]+0x20;
				else
					ext[extlen++] = ext[j];
			}
			if(extlen==1)//只有.号，但没有后缀名
				continue;
			ext[extlen++] = '.';
			if(FileListFindSubStringCaseInsensitive(ext,extlen,filters,filterslen)<0)
				continue;
		}
		FileListItem* item = [[FileListItem alloc] init];
		[item setFileName:name];
		if(isDir)
			[item setFileType:EFileListItemDir];
		else
			[item setFileType:EFileListItemFile];
		[arrayItems addObject:item];
	}
	delete filters;
	delete ext;
}
@end
