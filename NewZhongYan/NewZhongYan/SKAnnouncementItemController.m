//
//  SKAnnouncementItemController.m
//  NewZhongYan
//
//  Created by lilin on 13-11-7.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "SKAnnouncementItemController.h"
#import "SKTableViewCell.h"
#import "SKSearchController.h"
#import "SKAttachViewController.h"
@interface SKAnnouncementItemController ()

@end

@implementation SKAnnouncementItemController

-(void)onRefrshClick
{
    [super onRefrshClick];
    [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedAnnouncement] delegate:self];
}

-(void)onSearchClick
{
    NSLog(@"onSearchClick");
    UINavigationController* nav = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"searchnavcontroller"];
    SKSearchController* searcher = (SKSearchController*)[nav topViewController];
    searcher.doctype = SKAnnounce;
    [[APPUtils visibleViewController] presentViewController:nav animated:YES completion:^{
        
    }];
}
-(void)dataFromDataBaseWithComleteBlock:(resultsetBlock)block
{
    [super dataFromDataBaseWithComleteBlock:block];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *sql =[NSString stringWithFormat:
                        @"SELECT (case when(strftime('%%s','now','start of day','-8 hour','-1 day') >= strftime('%%s',crtm)) then 1 else 0 end ) as bz,TID,ATTS,TITL,strftime('%%Y-%%m-%%d %%H:%%M',CRTM) CRTM,AUNAME,READED FROM T_NOTIFY WHERE TPID = '4' AND ENABLED = 1 ORDER BY CRTM DESC LIMIT %d,%d",from,20];
        NSArray* dataArray = [[DBQueue sharedbQueue] recordFromTableBySQL:sql];
        for (NSMutableDictionary* d in dataArray)
        {
            if (![[d objectForKey:@"bz"] intValue] && ![[d objectForKey:@"READED"] intValue]) {
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


- (void)viewDidLoad
{
    [super viewDidLoad];
	[self dataFromDataBaseWithComleteBlock:^(NSArray* array){
        [_dataItems setArray:array];
        [self.tableView tableViewDidFinishedLoading];
        [self.tableView setReachedTheEnd:array.count < 20];
        [self.tableView reloadData];
        from += 20;
    }];
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

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataItems.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"公告列表";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identify = @"anoucecell";
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
    if ([[segue identifier] isEqualToString:@"notifyDetail"]) {
        SKAttachViewController *attachController = (SKAttachViewController *)[segue destinationViewController];
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        attachController.cmsInfo = _dataItems[selectedIndexPath.row];
        attachController.doctype = SKAnnounce;
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"notifyDetail" sender:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:16.];
    CGSize size = [_dataItems[indexPath.row][@"TITL"] sizeWithFont:font constrainedToSize:CGSizeMake(280, 220) lineBreakMode:NSLineBreakByTruncatingTail];
    return size.height + 30;
}

@end
