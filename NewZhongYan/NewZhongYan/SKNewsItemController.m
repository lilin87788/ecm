//
//  SKNewsItemController.m
//  NewZhongYan
//
//  Created by lilin on 13-10-10.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "SKNewsItemController.h"
#import "SKTableViewCell.h"
#import "SKNewsAttachController.h"
#import "SKBrowseNewsController.h"
#import "SKSearchController.h"
#define READ 1
#define UNREAD 0
#define BEFORETWODAY 1 //两天以前
#define INNERTWODAY  0 //两天以内
@interface SKNewsItemController ()

@end

@implementation SKNewsItemController
@synthesize tableView = _tableView;
-(void)onRefrshClick
{
    [super onRefrshClick];
    [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedNews] delegate:self];
}

-(void)onSearchClick
{
    NSLog(@"onSearchClick");
    UINavigationController* nav = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"searchnavcontroller"];
    SKSearchController* searcher = (SKSearchController*)[nav topViewController];
    searcher.doctype = SKNews;
    [[APPUtils visibleViewController] presentViewController:nav animated:YES completion:^{
        
    }];
}

-(void)dataFromDataBaseWithComleteBlock:(resultsetBlock)block
{
    [super dataFromDataBaseWithComleteBlock:block];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* sql = [NSString stringWithFormat:
                         @"select (case when(strftime('%%s','now','start of day','-8 hour','-1 day') >= strftime('%%s',crtm)) then 1 else 0 end ) as bz,TID,ATTS,TITL,strftime('%%Y-%%m-%%d %%H:%%M',CRTM) CRTM,AUNAME,READED from T_NEWS where ENABLED = 1  ORDER BY CRTM DESC LIMIT %d,%d;",from,20];
        NSArray* dataArray = [[DBQueue sharedbQueue] recordFromTableBySQL:sql];
        for (NSMutableDictionary* d in dataArray)
        {
            if ([[d objectForKey:@"bz"] intValue] == INNERTWODAY && [[d objectForKey:@"READED"] intValue] == UNREAD) {
                [d setObject:@"0" forKey:@"READED"];
            }else{
                [d setObject:@"1" forKey:@"READED"];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(dataArray);
            }
        });
    });
}

//字典里面存数组，数组里面放的是字典
-(NSMutableDictionary*)dictionaryWithTid:(NSString*)tid
{
    for (NSMutableDictionary* dict in _dataItems) {
        if ([[dict objectForKey:@"TID"] isEqualToString:tid]) {
            return dict;
        }
    }
    return nil;
}

-(void)newsStateChanged:(NSNotification*)aNotification
{
    NSDictionary* responseDict = [aNotification userInfo];
    NSMutableDictionary* news = [self dictionaryWithTid:[responseDict objectForKey:@"TID"]];
    [news setObject:@"1" forKey:@"READED"];
    [self.tableView reloadData];
}

//标准
#pragma mark - View lifecycle
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newsStateChanged" object:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"新闻";
    [self dataFromDataBaseWithComleteBlock:^(NSArray* array){
        [_dataItems setArray:array];
        [self.tableView tableViewDidFinishedLoading];
        [self.tableView setReachedTheEnd:array.count < 20];
        [self.tableView reloadData];
        from += 20;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newsStateChanged:) name:@"newsStateChanged" object:0];
}

#pragma mark - PullingRefreshTableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView != (UIScrollView*)self.tableView) return;
    [self.tableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView != (UIScrollView*)self.tableView)   return;
    [self.tableView tableViewDidEndDragging:scrollView];
}

#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(onRefrshClick) withObject:nil afterDelay:0.0];
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self dataFromDataBaseWithComleteBlock:^(NSArray* array){
        [_dataItems addObjectsFromArray:array];
        [self.tableView tableViewDidFinishedLoading];
        [self.tableView setReachedTheEnd:array.count < 20];
        [self.tableView reloadData];
        from += 20;
    }];
}

#pragma mark - Table view data source/Users/lilin/Desktop/基于 ios7 的新工程/NewZhongYan/NewZhongYan/SKNewsAttachController.m


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataItems.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"新闻列表";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identify = @"newscell";
    SKTableViewCell*  cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell)
    {
        cell = [[SKTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    [cell setCMSInfo:[_dataItems objectAtIndex:indexPath.row]];
    [cell resizeCellHeight];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"news"]) {
        SKNewsAttachController *attachController = (SKNewsAttachController *)[segue destinationViewController];
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        attachController.news = _dataItems[selectedIndexPath.row];
    }
    if ([[segue identifier] isEqualToString:@"browse"]) {
        SKBrowseNewsController *browser = (SKBrowseNewsController *)[segue destinationViewController];
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        NSMutableDictionary* dict = _dataItems[selectedIndexPath.row];
        browser.currentDictionary = dict;
        if (![[dict objectForKey:@"READED"] intValue])
        {
            NSString* sql =[NSString stringWithFormat:@"update T_NEWS set READED = 1 where TID  = '%@'",[_dataItems[selectedIndexPath.row] objectForKey:@"TID"]];
            [dict setObject:@"1" forKey:@"READED"];
            [self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[DBQueue sharedbQueue] updateDataTotableWithSQL:sql];
            });
        }
        [_tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"browse" sender:self];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:16.];
    CGSize size = [_dataItems[indexPath.row][@"TITL"] sizeWithFont:font constrainedToSize:CGSizeMake(280, 220) lineBreakMode:NSLineBreakByTruncatingTail];
    return size.height + 30;
}
@end
