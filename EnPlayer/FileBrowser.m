//
//  FileBrowser.m
//  EnPlayer
//
//  Created by mahongjian on 13-12-20.
//  Copyright (c) 2013年 mahongjian. All rights reserved.
//

#import "FileBrowser.h"

NSString* FileBrowserFileSelectedNotification=@"FileBrowserFileSelectedNotification";

@interface FileBrowser ()
-(void) initialize;
+(NSString*) fileNameFromPath:(NSString*)path;
@end

@implementation FileBrowser
//@synthesize delegate;

+(NSString*) fileNameFromPath:(NSString*)path	//从路径中获取文件名
{
	if (path==nil || [path length]==0)
		return nil;
	int len	= (int)[path length];
	int index	= len-1;
	for (; index >=0; index--)
	{
		if([path characterAtIndex:index]==L'/')
			break;
	}
	if(index==len-1)
		return nil;
	return [path substringFromIndex:index+1];
}
-(id)init
{
	self = [super init];
	if(self)
	{
		[self initialize];
	}
	return self;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
		[self initialize];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if(self)
	{
		[self initialize];
	}
	return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self)
	{
		[self initialize];
	}
	return self;
}

-(void) initialize
{
	if(fileLister==nil)
	{
		fileLister = [[FileLister alloc] init];
	}
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setDirectory:(NSString*)dir
{
	fileLister.directory = dir;
	self.title = [FileBrowser fileNameFromPath:dir];
	[self.tableView reloadData];
}
-(NSString*)directory
{
	return fileLister.directory;
}
-(NSString*)extFilters
{
	return fileLister.extFilters;
}
-(void)setExtFilters:(NSString *)extFilters
{
	fileLister.extFilters = extFilters;
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fileLister.itemsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell==nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	}

	FileListItem* item = [fileLister getByIndex:(int)[indexPath row]];
	if(item)
	{
		cell.textLabel.text = item.name;
	}
    
    return cell;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	FileListItem* item = [fileLister getByIndex:(int)[indexPath row]];
	if(item)
	{
		if(item.type==EFileListItemFile)
		{
			NSDictionary* dic=[NSDictionary dictionaryWithObjectsAndKeys:@"directory",fileLister.directory,@"file",item.name, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:FileBrowserFileSelectedNotification object:self userInfo:dic];
//			if([delegate respondsToSelector:@selector(browser:fileSelected:)])
//				[delegate browser:self fileSelected:item.name];
		}
		else if(item.type==EFileListItemDir)
		{
			
		}
	}
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
