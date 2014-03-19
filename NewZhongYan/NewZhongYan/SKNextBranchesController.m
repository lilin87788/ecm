//
//  SKNextBranchesController.m
//  ZhongYan
//
//  Created by linlin on 9/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKNextBranchesController.h"
#import "utils.h"
#import "DataServiceURLs.h"
#import "utils.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "branch.h"
#import "SKTransactorController.h"
#import "SKSToolBar.h"
#import "SKViewController.h"
@interface SKNextBranchesController ()
{
    UILabel* titleLabel;
}
//构建视图
-(void)drawView;
@end

@implementation SKNextBranchesController
@synthesize GTaskInfo,uid,bid,nextBranches,tableView,transactBid;

- (void)requestFailed:(SKHTTPRequest *)request
{
    NSError *error = [request error];
    [BWStatusBarOverlay showErrorWithMessage:[NetUtils userInfoWhenRequestOccurError:error] duration:1 animated:1];
}

- (void)requestFinished:(SKHTTPRequest *)request
{
    if (request.responseStatusCode == 500) {
        [BWStatusBarOverlay showErrorWithMessage:@"网络异常请联系供应商" duration:1 animated:1];
    }
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:request.responseData options:0 error:nil];
    DDXMLElement* element = (DDXMLElement*)[[doc nodesForXPath:@"//returncode" error:0] objectAtIndex:0];
    DDXMLElement* selectElement = (DDXMLElement*)[[doc nodesForXPath:@"//branches" error:0] objectAtIndex:0];
    self.nextBranches.selection =   [[selectElement attributesAsDictionary] objectForKey:@"selection"];
    self.nextBranches.returncode =  [element stringValue];
    
    //解析
    for (DDXMLElement* node in [doc nodesForXPath:@"//branches" error:0]) {
        branches* bs = [[branches alloc] init];
        bs.attributeDictionary = [(DDXMLElement*)node attributesAsDictionary];
        for (DDXMLElement* element in [node nodesForXPath:@"./branch" error:0])
        {
            branch *b = [[branch alloc] init];
            b.bid = [[element elementForName:@"bid"] stringValue];
            b.bname = [[element elementForName:@"bname"] stringValue];
            b.ifend = [[element elementForName:@"ifend"] stringValue];
            b.node =element;
            [bs.branchArray addObject:b];
            branchCount++;
        }
        [self.nextBranches.branchesArray addObject:bs];
    }
    [self drawView];
}

-(void)fitLabel:(UILabel*)label
{
    label.font = [UIFont systemFontOfSize:17];
    label.numberOfLines = 0;
    [label sizeToFit];
}

-(void)drawView
{
    _tableView = [[UITableView alloc] init];
    if (IS_IOS7) {
        [_tableView setFrame:CGRectMake(0,CGRectGetMaxY(titleLabel.frame) + 5,320,
                                        SCREEN_HEIGHT - 49 - CGRectGetMaxY(titleLabel.frame) - 5)];
    }else{
        [_tableView setFrame:CGRectMake(0,CGRectGetMaxY(titleLabel.frame) + 5,320,
                                        SCREEN_HEIGHT - 49 - CGRectGetMaxY(titleLabel.frame) - 5 - 64)];
    }
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.nextBranches.branchesArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    branches* bs = self.nextBranches.branchesArray[section];
    [_tableView setBounces:branchCount > 6];
    return [bs.branchArray count];
}

-(UITableViewCell*)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identify = @"radiobutton";
    UITableViewCell* cell = [aTableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.imageView.image =[[UIImage imageNamed:@"uncheck.png"] rescaleImageToSize:CGSizeMake(25, 25)];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    branches* bs =  (branches*)self.nextBranches.branchesArray[indexPath.section];
    branch* b = bs.branchArray[indexPath.row];
    cell.textLabel.text = b.bname;
    return cell;
}

-(void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [aTableView cellForRowAtIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"check.png"];
    selectedRow = indexPath;
}

- (void)tableView:(UITableView *)aTableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [aTableView cellForRowAtIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"uncheck.png"];
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headView = [[UIView alloc] init];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    branches* bs = self.nextBranches.branchesArray[section];
    if (bs.attributeDictionary[@"name"]) {
        [label setText:[NSString stringWithFormat:@"   %@ (单选)",bs.attributeDictionary[@"name"]]];
    }else{
        [label setText:@"   流程选择 (单选)"];
    }
    [label setTextColor:COLOR(51,181,229)];
    [self fitLabel:label];
    
    [headView setFrame:CGRectMake(0, 0, 320, label.frame.size.height)];
    [headView addSubview:label];
    
    UIImageView* DividingLines = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_line.png"]];
    [DividingLines setFrame:CGRectMake(0,  CGRectGetMaxY(label.frame) + 5, 320, 2)];
    [headView addSubview:DividingLines];
    return headView;
}

-(void)dealloc
{
    if ([NBRequest isExecuting]) {
        [NBRequest clearDelegatesAndCancel];
    }
}

-(id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        selectedRow = nil;
        self.title = @"流程分支";
        self.GTaskInfo = dictionary;
        self.nextBranches = [[aNextBranches alloc] init];
        self.uid = [APPUtils userUid];
        self.bid = @"000";
        
    }
    return self;
}

- (void)backToRoot:(id)sender{
    for (UIViewController* controller  in self.navigationController.viewControllers){
        NSString *classString = NSStringFromClass([controller class]);
        if ([classString isEqualToString:@"SKMainViewController"]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

-(void)lastStep:(id)sender{
    SKViewController* controller = [APPUtils AppRootViewController];
    [controller.navigationController popViewControllerAnimated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSURL* commitUrl = [DataServiceURLs commitWorkItem];
        SKFormDataRequest *commitRequest = [SKFormDataRequest requestWithURL:commitUrl];
        [commitRequest setPostValue:[APPUtils userUid] forKey:@"userid"];
        [commitRequest setPostValue:[GTaskInfo objectForKey:@"TFRM"]  forKey:@"from"];
        [commitRequest setPostValue:[GTaskInfo objectForKey:@"AID"]  forKey:@"workitemid"];
        [commitRequest setPostValue:self.transactBid forKey:@"branchid"];
        [commitRequest setPostValue:@"" forKey:@"plist"];
        __weak SKFormDataRequest *req = commitRequest;
        [commitRequest setCompletionBlock:^{
            if (req.responseStatusCode == 500) {
                //[utils AlterView:self.view Title:@"尊敬的用户您好:" Deatil:@"网络异常请联系供应商"]; return;
                return;
            }
            if ([[req responseString] isEqualToString:@"OK"])
            {
                [BWStatusBarOverlay showMessage:@"办理成功" duration:1.5 animated:YES];
                for (UIViewController* controller  in self.navigationController.viewControllers){
                    NSString *classString = NSStringFromClass([controller class]);
                    if ([classString isEqualToString:@"SKGTaskViewController"]) {
                        [self.navigationController popToViewController:controller animated:YES];
                    }
                }
            }else{
                [BWStatusBarOverlay showMessage:[req responseString] duration:1.5 animated:YES];
            }
        }];
        //失败
        [commitRequest setFailedBlock:^{
            NSError *error = [req error];
            [BWStatusBarOverlay showMessage:[NetUtils userInfoWhenRequestOccurError:error] duration:1.5 animated:YES];
        }];
        [commitRequest startAsynchronous];
    }
}

-(void)nextStep:(id)sender{
    if (!selectedRow) {
        //[utils showTextOnView:self.view Text:@"您还没有选择适当的流程分支!"];
        [BWStatusBarOverlay showErrorWithMessage:@"您还没有选择适当的流程分支!" duration:1 animated:YES];
        return;
    }
    branches* bs =  (branches*)self.nextBranches.branchesArray[selectedRow.section];
    branch* b = bs.branchArray[selectedRow.row];
    if ([b.ifend isEqualToString:@"nextto"]) {
        
        //➢	branchid，可供选择的分支途径。为String数组，如果某项流程是主流程下子流程，其格式为主流程id:子流程id
        SKNextBranchesController* nb = [[SKNextBranchesController alloc] initWithDictionary:self.GTaskInfo];
        nb.bid = b.bid;
        nb.transactBid = [self.transactBid stringByAppendingString:[NSString stringWithFormat:@":%@",b.bid]];
        [self.navigationController pushViewController:nb animated:YES];
    } else {
        if ([b.ifend isEqualToString:@"YES"]) {
            self.transactBid = [self.transactBid stringByAppendingString:[NSString stringWithFormat:@":%@",b.bid]];
            self.transactBid = [self.transactBid substringFromIndex:1];
            NSString* msg = [NSString stringWithFormat:@"流程将进入%@环节是否确认提交",b.bname];
            UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [av show];
        }else{
            //还待测试
            self.transactBid = [self.transactBid stringByAppendingString:[NSString stringWithFormat:@":%@",b.bid]];
            self.transactBid = [self.transactBid substringFromIndex:1];
            SKTransactorController* tc = [[SKTransactorController alloc] initWithDictionary:self.GTaskInfo BranchID:self.transactBid];
            tc.branchname = b.bname;
            [self.navigationController pushViewController:tc animated:YES];
        }
    }
}

#pragma mark - View lifecycle

-(UILabel*)selfAdaptionLable:(UIFont*)font Width:(CGFloat)width Text:(NSString*)text
{
    CGFloat rowHeight = [@"李林" sizeWithFont:font constrainedToSize:CGSizeMake(320, MAXFLOAT)].height;
    CGFloat height = [text sizeWithFont:font
                      constrainedToSize: CGSizeMake(width,MAXFLOAT)
                          lineBreakMode:NSLineBreakByWordWrapping].height; //expectedLabelSizeOne.height 就是内容的高度
    CGRect labelRect = CGRectMake((320 - width)/2.0, TopY + 5,width,height);
    UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;//上面两行设置多行显示s
    label.font = font;
    label.text = text;
    if (height > rowHeight) [label setTextAlignment:NSTextAlignmentLeft];
    else             [label setTextAlignment:NSTextAlignmentCenter];
    return label;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IS_IOS7) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    [self.view setBackgroundColor:[UIColor whiteColor]];
    titleLabel = [self selfAdaptionLable:[UIFont systemFontOfSize:17]
                                   Width:300
                                    Text:[self.GTaskInfo objectForKey:@"TITL"]];
    [titleLabel setTag:1000];
    //[titleLabel setBackgroundColor:COLOR(17, 168, 171)];
    [titleLabel setTextColor:[UIColor grayColor]];
    [titleLabel setShadowColor:[UIColor whiteColor]];
    [titleLabel setShadowOffset:CGSizeMake(-1, -1)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.view addSubview:titleLabel];
    
    SKSToolBar* myToolBar = [[SKSToolBar alloc] initWithFrame:CGRectMake(0, BottomY-49, 320, 49)];
    [myToolBar.homeButton addTarget:self action:@selector(backToRoot:) forControlEvents:UIControlEventTouchUpInside];
    [myToolBar.firstButton addTarget:self action:@selector(lastStep:) forControlEvents:UIControlEventTouchUpInside];
    [myToolBar.secondButton addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    [myToolBar setFirstItem:@"btn_last_ecm" Title:@"上一步"];
    [myToolBar setSecondItem:@"btn_next_ecm" Title:@"下一步"];
    [self.view addSubview:myToolBar];
    
    NSURL* nextBranchesURL = [DataServiceURLs getNextBranches:[APPUtils userUid]
                                                         TFRM:[GTaskInfo objectForKey:@"TFRM"]
                                                          AID:[GTaskInfo objectForKey:@"AID"]
                                                          BID:self.bid
                              ];
    
    NBRequest = [[SKHTTPRequest alloc] initWithURL:nextBranchesURL];
    [NBRequest setDefaultResponseEncoding:NSUTF8StringEncoding];
    [NBRequest setDelegate:self];
    [NBRequest startAsynchronous];
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

@end
