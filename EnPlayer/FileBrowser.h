//
//  FileBrowser.h
//  EnPlayer
//
//  Created by mahongjian on 13-12-20.
//  Copyright (c) 2013年 mahongjian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileLister.h"

NSString* FileBrowserFileSelectedNotification;

//@protocol FileBrowserDelegate;

@interface FileBrowser : UITableViewController
{
	FileLister* fileLister;
}
@property (nonatomic,retain) NSString* directory;
@property (nonatomic,retain) NSString* extFilters;
//@property (nonatomic,retain) id<FileBrowserDelegate> delegate;
@end

//@protocol FileBrowserDelegate<NSObject>
//-(void)browser:(FileBrowser*)browser fileSelected:(NSString*)filename;
//@end

