//
//  SKSearchController.m
//  NewZhongYan
//
//  Created by lilin on 13-10-29.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "SKSearchController.h"
#import "NSString+hnzy.h"
#import "SKSearchCell.h"
#import "SKNewsAttachController.h"
#import "SKAttachViewController.h"
@interface UIButton(network)
- (void)startLoadData:(BOOL)show;
@end

@implementation UIButton(network)

- (void)startLoadData:(BOOL)show {
	if(show) {
		UIActivityIndicatorView *progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		UIView *progressView = [[UIView alloc] initWithFrame: self.bounds];
        [self addSubview:progressView];
        [self setTitle:@"正在加载..." forState:UIControlStateNormal];
        [progressView setTag:1001];
        [self setEnabled:NO];
        [progressView addSubview: progress];
        CGPoint p =  progressView.center;
        p.x -= 90;
		progress.center = p;
		[progress startAnimating];
	} else {
		[self setEnabled:YES];
        [[self viewWithTag:1001] removeFromSuperview];
	}
}

@end


@interface SKSearchController ()

@end

@implementation SKSearchController
@synthesize moreBtn;
@synthesize doctype;
@synthesize TITL,AUID,BGTM,EDTM;
@synthesize fid;
@synthesize keyArray = _keyArray;
- (IBAction)moreConditionBtnClick:(id)sender {
    CGRect moreRect=insiderView.frame;
    moreRect.origin.x=0;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (insiderView.frame.size.width) {
            insiderView.frame = CGRectMake(0,0, 0, 0)  ;
            insiderView.contentView.frame =  CGRectMake(10,15, 0, 0);
        }else{
            insiderView.frame = CGRectMake(0,0, 320, [UIScreen mainScreen].bounds.size.height-44-20);
            insiderView.contentView.frame = CGRectMake(10,15, 300,320);
            insiderView.titleTextField.text = self.searchBar.text;
            [self.searchBar resignFirstResponder];
            //[[self conditionBtn] setEnabled:YES];
        }
    }];
}

//多选界面的取消
-(void)cancelMoreCondition:(id)sender
{
    CGRect moreRect=insiderView.frame;
    moreRect.origin.x=320;
    [UIView animateWithDuration:0.3 animations:^{
        insiderView.frame=CGRectMake(0, 100, 0, 0);
    }];
}

- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[SKHTTPRequest sharedQueue] cancelAllOperations];
    }];
}

-(void)onSearchInsideViewConfirmWith:(NSString*)title Author:(NSString*)author StartTime:(NSString*)bgtm EndTime:(NSString*)edtm
{
    NSDate* start = [DateUtils stringToDate:bgtm DateFormat:@"yyyy-MM-dd"];
    NSDate* end = [DateUtils stringToDate:edtm DateFormat:@"yyyy-MM-dd"];
    self.BGTM = [NSString stringWithFormat:@"%d000",(int)[start timeIntervalSince1970]];
    self.EDTM = [NSString stringWithFormat:@"%d000",(int)[end timeIntervalSince1970]];
    self.TITL = title;
    self.AUID = author;
    self.searchBar.text = title;
    pageindex = 1;
    
    NSString* key = [NSString string];
    self.keyArray = [self.TITL componentsSeparatedByWhiteSpaceWithoutself];
    for (NSString* k in self.keyArray) key = [key stringByAppendingFormat:@" AND TITL LIKE '%%%@%%'",k];
    if (key.length > 4) {
        key = [key substringFromIndex:4];
    }else{
        key = @"TITL LIKE ''";
    }
    NSString* sql = [NSString stringWithFormat:
                     @"select *\
                     from %@\
                     %@\
                     and AUNAME like '%%%@%%'\
                     and DATETIME('%@','start of day') < DATETIME(CRTM)\
                     and DATETIME('%@','+12 hour') > DATETIME(CRTM)\
                     and ENABLED  = 1\
                     ORDER BY CRTM DESC;",[SKAttachManger tbname:doctype],key,author,bgtm,edtm];
    [_dataArray setArray:[[DBQueue sharedbQueue] recordFromTableBySQL:sql]];
    [self moreConditionBtnClick:0];
    [self.tableView reloadData];
}

#pragma mark -远程查询
-(NSString*)criteriaString
{
    return[NSString stringWithFormat:@"array('author'=>'%@','title'=>'%@','starttime' => '%@','endtime'=>'%@');",self.AUID,self.TITL,self.BGTM,self.EDTM];
}

//搜索健康
-(void)remotequery
{
    if (self.TITL.length == 0) {
        return;
    }
    SKFormDataRequest* Request = [SKFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/commons/cms/queryCMSItem",ZZZobt]]];
    [Request setPostValue:[APPUtils userUid] forKey:@"userid"];
    [Request setPostValue:self.fid forKey:@"fid"];
    [Request setPostValue:[NSString stringWithFormat:@"%ld",(long)pageindex] forKey:@"page"];
    [Request setPostValue:[self criteriaString] forKey:@"criteria"];
    [Request setPostValue:@"0" forKey:@"mincmsid"];
    [Request startAsynchronous];
    [Request setStartedBlock:^{
        isRemote = YES;
        [moreBtn startLoadData:YES];
    }];
    
    __weak SKFormDataRequest* request = Request;
    [Request setCompletionBlock:^{
        isRemote = NO;
        [moreBtn startLoadData:NO];
        //NSLog(@"%@",request.responseString);
        NSDictionary *dic=[[request responseData] objectFromJSONData];
        if ([[dic allKeys] containsObject:@"s"])
        {
            NSArray* array = [dic objectForKey:@"s"];
            if (array.count > 0)
            {
                NSDictionary* vdic = [array objectAtIndex:0];
                if (vdic && [[vdic allKeys] containsObject:@"v"])
                {
                    if (dic && [[dic allKeys] containsObject:@"c"]) {
                        if ([[dic objectForKey:@"c"] isEqualToString:@"EXCEPTION"]) {
                            [BWStatusBarOverlay showErrorWithMessage:@"没有查询到结果" duration:1 animated:1];
                            return ;
                        }
                    }
                }
            }
            
            if (pageindex == 1) {
                [_dataArray setArray:array];
            }else{
                [_dataArray addObjectsFromArray:array];
            }
            self.keyArray = [self.TITL componentsSeparatedByWhiteSpaceWithoutself];
            pageindex += (array.count < 20) ? 0 : 1;
            [self.tableView reloadData];
            [moreBtn setEnabled:!(array.count < 20)];
            [moreBtn setTitle:array.count < 20 ? @"没有更多了" :@"下一页" forState:UIControlStateNormal];
        }else{
            [moreBtn setTitle:@"远程查询" forState:UIControlStateNormal];
        }
    }];
    
    [Request setFailedBlock:^{
        isRemote = NO;
        [moreBtn startLoadData:NO];
        [moreBtn setTitle:@"远程查询" forState:UIControlStateNormal];
    }];
}

-(LocalDataMeta*)dataMeta:(SKDocType)type
{
    if (type == SKNotify) {
        return [LocalDataMeta sharedNotify];
    }else if (type == SKMeet){
        return [LocalDataMeta sharedMeeting];
    }else if (type == SKAnnounce){
        return [LocalDataMeta sharedAnnouncement];
    }else{
        return nil;
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

-(void)initNavBar
{
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    UIImage* navbgImage;
    if (System_Version_Small_Than_(7)) {
        navbgImage = [UIImage imageNamed:@"navbar44"] ;
        self.navigationController.navigationBar.tintColor = COLOR(0, 97, 194);
    }else{
        [self setNeedsStatusBarAppearanceUpdate];
        self.navigationController.navigationBar.translucent = YES;
        navbgImage = [UIImage imageNamed:@"navbar64"] ;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    [self.navigationController.navigationBar setBackgroundImage:navbgImage  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor: [UIColor whiteColor]};
}

-(void)initData
{
    _dataArray = [[NSMutableArray alloc] init];
    self.TITL = @"";
    self.AUID = @"";
    self.BGTM = @"";
    self.EDTM = @"";
    pageindex = 1;
    self.fid = [SKAttachManger fid:doctype];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavBar];
    [self initData];
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn setFrame:CGRectMake(15, 4.5, 290, 41)];
    [moreBtn setTitle:@"远程查询" forState:UIControlStateNormal];
    [moreBtn setBackgroundImage:Image(@"contentview_graylongbutton") forState:UIControlStateNormal];
    [moreBtn setBackgroundImage:Image(@"contentview_graylongbutton_highlighted") forState:UIControlStateHighlighted];
    [moreBtn setBackgroundImage:Image(@"contentview_graylongbutton_highlighted") forState:UIControlStateSelected];
    [moreBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(remotequery) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:moreBtn];
    [self.tableView setTableFooterView:view];
    
    insiderView = [[SKSearchInsiderView alloc] initWithFrame:CGRectMake(320, 0, 320, [UIScreen mainScreen].bounds.size.height-44-20)];
    insiderView.frame = CGRectMake(0, 0, 0, 0);
    insiderView.delegate = self;
    insiderView.target = self;
    //[self.view addSubview:insiderView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identify = @"SearchCell";
    SKSearchCell*  cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SKSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    NSDictionary* dataDictionary = [[[_dataArray objectAtIndex:indexPath.row] allKeys] containsObject:@"v"]
    ? [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"v"]
    : [_dataArray objectAtIndex:indexPath.row];
    if (doctype == SKMeet) {
        [cell setMeetInfo:dataDictionary];
        [cell resizeMeetCellHeight];
    }else{
        [cell setCMSInfo:dataDictionary];
        [cell resizeCellHeight];
    }
    [cell setKeyWordArray:self.keyArray];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:16.];
    NSDictionary* dataDictionary = [[[_dataArray objectAtIndex:indexPath.row] allKeys] containsObject:@"v"]
    ? [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"v"]
    : [_dataArray objectAtIndex:indexPath.row];
    CGSize size = [dataDictionary[@"TITL"] sizeWithFont:font constrainedToSize:CGSizeMake(280, 220) lineBreakMode:NSLineBreakByCharWrapping];
    if (doctype == SKMeet) {
        return size.height + 50;
    }else{
        return size.height + 30;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary* dataDictionary = [[[_dataArray objectAtIndex:indexPath.row] allKeys] containsObject:@"v"]
    ? [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"v"]
    : [_dataArray objectAtIndex:indexPath.row];
    if (doctype == SKNews) {
        SKNewsAttachController *attachController =[[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"SKNewsAttachController"];
        attachController.news = dataDictionary;
        attachController.isSearch = YES;
        [self.navigationController pushViewController:attachController animated:YES];
    }else{
        SKAttachViewController* attachController = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"SKAttachViewController"];
        attachController.cmsInfo = dataDictionary;
        attachController.doctype = doctype;
        [self.navigationController pushViewController:attachController animated:YES];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.TITL = self.searchBar.text;
    self.AUID = @"";
    self.BGTM = @"";
    self.EDTM = @"";
    pageindex = 1;
    self.keyArray = [self.TITL componentsSeparatedByWhiteSpaceWithoutself];
    if (self.keyArray.count) {
        if (self.searchBar.text.length) {
            NSString* sql = [SKAttachManger sql:doctype keyArray:self.keyArray];
            [_dataArray setArray:[[DBQueue sharedbQueue] recordFromTableBySQL:sql]];
        }else{
            self.TITL = @"";
            [_dataArray removeAllObjects];
        }
        [moreBtn setTitle:@"远程查询" forState:UIControlStateNormal];
        [moreBtn setEnabled:YES];
        [moreBtn setHidden:!self.searchBar.text.length];
        [self.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}
@end
