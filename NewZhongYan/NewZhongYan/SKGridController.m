//
//  SKGridController.m
//  NewZhongYan
//
//  Created by lilin on 13-12-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "SKGridController.h"
#import "DDXMLDocument.h"
#import "DDXMLElementAdditions.h"
#import "DDXMLElement.h"
#import "SKViewController.h"
#import "SKDaemonManager.h"
#import "SKECMRootController.h"
#import "LocalMetaDataManager.h"

#define InitIconX 30
#define InitIconY 40
#define InitIconHeight 80
//(320 - 180 ) - 2x/2 = (140 - 2x)/2 = 70 - x
#define InitIconintervalX 70 - InitIconX
#define InitIconintervalWidth 130 - InitIconX
#define InitIconintervalY 16.6
@interface SKGridController ()
{
    NSMutableArray *upButtons;
}
@end

@implementation SKGridController

-(NSString*)controllerWithCode:(NSString*)code
{
    if ([code isEqualToString:@"copublicnotice"]) {
        return @"SKAnnouncementItemController";
    }
    return @"SKAnnouncementItemController";
}

-(void)jumpToController:(id)sender
{
    UIDragButton *btn=(UIDragButton *)[(UIDragButton *)sender superview];
    [_rootController performSegueWithIdentifier:@"SKECMRootController" sender:btn.channel];
    //    SKECMRootController* controller = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"SKECMRootController"];
    //    controller.channel = btn.channel;
    //    [self.navigationController pushViewController:controller animated:YES];
}

-(void)jumoController:(id)sender
{
    UIDragButton *btn=(UIDragButton *)[(UIDragButton *)sender superview] ;
    //UIViewController* controller = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:btn.controllerName];
    //[self.navigationController pushViewController:controller animated:YES];
    [_rootController performSegueWithIdentifier:btn.controllerName sender:self];
}

-(void)initChannelView:(basicBlock)completeBlock
{
    for (UIView* v in self.view.subviews) {
        if (v.class == [UIDragButton class]) {
            [v removeFromSuperview];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        upButtons = [[NSMutableArray alloc] init];
        NSString* sql = [NSString stringWithFormat:@"select * from T_CHANNEL WHERE OWNERAPP = '%@' and LEVL = 1 and ENABLED = 1;",self.clientApp.CODE];
        NSArray* array = [[DBQueue sharedbQueue] recordFromTableBySQL:sql];
        for (int i=0;i<array.count;i++)
        {
            NSDictionary *dict=[array objectAtIndex:i];
            SKChannel* channel = [[SKChannel alloc] initWithDictionary:dict];
            if (![channel.FIDLIST isEqual:[NSNull null]]) {
                [channel restoreVersionInfo];
            }
            
            UIDragButton *dragbtn=[[UIDragButton alloc] initWithFrame:CGRectZero inView:self.view];
            [dragbtn setChannel:channel];
            [dragbtn setTitle:dict[@"NAME"]];
            [dragbtn.tapButton setPlaceholderImage:Image(@"icon_default")];
            if (dict[@"LOGO"] == [NSNull null]) {
                [dragbtn.tapButton setImageURL:[NSURL URLWithString:@"http://tam.hngytobacco.com/ZZZobtc/public/icon/wzfactory/wzgeneralinfo.png"]];
            }else{
                [dragbtn.tapButton setImageURL:[NSURL URLWithString:dict[@"LOGO"]]];
            }
            [dragbtn setControllerName:dict[@"CODE"]];
            [dragbtn setDelegate:self];
            [dragbtn setTag:i];
            [dragbtn.tapButton addTarget:self action:@selector(jumpToController:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:dragbtn];
            [upButtons addObject:dragbtn];
        }
        [self setUpButtonsFrameWithAnimate:NO withoutShakingButton:nil];
        if (completeBlock) {
            completeBlock();
        }
    });
}

-(void)initCompanyPageView
{
    upButtons = [[NSMutableArray alloc] init];
    NSArray *dataArray=[self dataFromXml];
    for (int i=0;i<dataArray.count;i++)
    {
        DDXMLElement *obj=[dataArray objectAtIndex:i];
        UIDragButton *dragbtn=[[UIDragButton alloc] initWithFrame:CGRectZero inView:self.view];
        [dragbtn setTitle:[obj elementForName:@"title"].stringValue];
        [dragbtn setNormalImage:[obj elementForName:@"icon"].stringValue];
        [dragbtn setControllerName:[obj elementForName:@"controller"].stringValue];
        [dragbtn setLocation:up];
        [dragbtn setDelegate:self];
        [dragbtn setTag:i];
        [dragbtn.tapButton addTarget:self action:@selector(jumoController:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:dragbtn];
        [upButtons addObject:dragbtn];
    }
    [self setUpButtonsFrameWithAnimate:NO withoutShakingButton:nil];
}

//取出xml中的app节点  并按照app节点中的location节点的值升序排序
-(NSArray *)dataFromXml
{
    NSString *path=[[FileUtils documentPath] stringByAppendingPathComponent:@"main_config.xml"];
    NSData *data=[NSData dataWithContentsOfFile:path];
    DDXMLDocument *doc = [[DDXMLDocument alloc]initWithData:data options:0 error:nil];
    NSArray *items = [doc nodesForXPath:@"//app" error:nil];
    
    NSArray *array=[items sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2)
                    {
                        DDXMLElement *element1=(DDXMLElement *)obj1;
                        DDXMLElement *element2=(DDXMLElement *)obj2;
                        DDXMLNode *locationElement1=[element1 elementForName:@"location"];
                        DDXMLNode *locationElement2=[element2 elementForName:@"location"];
                        int index1=[locationElement1.stringValue integerValue];
                        int index2=[locationElement2.stringValue integerValue];
                        if (index1 > index2) {
                            return (NSComparisonResult)NSOrderedDescending;
                        }
                        if (index1 < index2)
                        {
                            return (NSComparisonResult)NSOrderedAscending;
                        }
                        return (NSComparisonResult)NSOrderedSame;
                    }];
    return array;
}

- (void)setUpButtonsFrameWithAnimate:(BOOL)_bool withoutShakingButton:(UIDragButton *)shakingButton
{
    int count = [upButtons count];
    if (shakingButton != nil) {
        [UIView animateWithDuration:_bool ? 0.4 : 0 animations:^{
            for (int y = 0; y <= count / 3; y++) {
                for (int x = 0; x < 3; x++) {
                    int i = 3 * y + x;
                    if (i < count) {
                        UIDragButton *button = (UIDragButton *)[upButtons objectAtIndex:i];
                        if (button.tag != shakingButton.tag){
                            [button setFrame:CGRectMake(InitIconX + x * (InitIconintervalWidth),  InitIconY + y * (InitIconHeight + InitIconintervalY), 60, 60)];
                        }
                        [button setLastCenter:CGPointMake( InitIconX + x * (InitIconintervalWidth) + 60/2.0,  InitIconY + y * (InitIconHeight + InitIconintervalY)  + 60/2.0)];
                    }
                }
            }
        }];
    }else{
        [UIView animateWithDuration:_bool ? 0.4 : 0 animations:^{
            for (int y = 0; y <= count / 3; y++) {
                for (int x = 0; x < 3; x++) {
                    int i = 3 * y + x;
                    if (i < count) {
                        UIDragButton *button = (UIDragButton *)[upButtons objectAtIndex:i];
                        [button setFrame:CGRectMake(InitIconX + x *  (InitIconintervalWidth), InitIconY + y * (InitIconHeight + InitIconintervalY), 60, 60)];
                        [button setLastCenter:CGPointMake( InitIconX + x * (InitIconintervalWidth) + 60/2.0,  InitIconY + y * (InitIconHeight + InitIconintervalY)  + 60/2.0 )];
                    }
                }
            }
        }];
    }
}

- (void)checkLocationOfOthersWithButton:(UIDragButton *)shakingButton
{
    for (int i = 0; i < [upButtons count]; i++)
    {
        UIDragButton *button = (UIDragButton *)[upButtons objectAtIndex:i];
        if (button.tag != shakingButton.tag)
        {
            CGRect intersectionRect=CGRectIntersection(shakingButton.frame, button.frame);//两个按钮接触的大小
            if (intersectionRect.size.width>15&&intersectionRect.size.height>25)
            {
                [upButtons exchangeObjectAtIndex:i withObjectAtIndex:[upButtons indexOfObject:shakingButton]];
                [self setUpButtonsFrameWithAnimate:YES withoutShakingButton:shakingButton];
                //[self writeDataToXml];
                break;
            }
        }
    }
}


-(void)checkShakingButtonToLeftEdge:(UIDragButton *)shakingButton
{
    if (_rootController.pageController.currentPage == 1) {
        [_rootController scrollToPage:0];
    }
}

-(void)checkShakingButtonToRightEdge:(UIDragButton *)shakingButton
{
    if (_rootController.pageController.currentPage == 0) {
        [_rootController scrollToPage:1];
    }
}

-(void)copyXMLToDocument
{
    //这里最好判断原xml文件是不是存在 在向doc中执行复制操作
    NSString *path =[[NSString alloc]initWithString:[[NSBundle mainBundle]pathForResource:@"main_config"ofType:@"xml"]];
    NSString *docPath=[[FileUtils documentPath] stringByAppendingPathComponent:@"main_config.xml"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:docPath])
    {
        [[NSFileManager defaultManager] copyItemAtPath:path toPath:docPath error:nil];
    }else{
        [[NSFileManager defaultManager] removeItemAtPath:docPath error:0];
        [[NSFileManager defaultManager] copyItemAtPath:path toPath:docPath error:nil];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.clientApp.APPTYPE isEqualToString:@"ECM"]) {
        [SKDaemonManager SynChannelWithClientApp:self.clientApp complete:^{
            [self initChannelView:^{
                [SKDaemonManager SynMaxUpdateDateWithClient:self.clientApp
                                                   complete:^(NSMutableArray* array){
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [self reloadBageNumberWithServerInfo:array];
                                                       });
                                                   } faliure:^(NSError* error){
                                                       
                                                   }];
            }];
        } faliure:^(NSError* error){
            [SKDaemonManager SynMaxUpdateDateWithClient:self.clientApp
                                               complete:^(NSMutableArray* array){
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self reloadBageNumberWithServerInfo:array];
                                                   });
                                               } faliure:^(NSError* error){
                                                   
                                               }];
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initChannelView:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadBageNumber];
        });
    }];
}

-(void)reloadData
{
    [SKDaemonManager SynChannelWithClientApp:self.clientApp complete:^{
        [self initChannelView:^{
            [SKDaemonManager SynMaxUpdateDateWithClient:self.clientApp
                                               complete:^(NSMutableArray* array){
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self reloadBageNumberWithServerInfo:array];
                                                   });
                                               } faliure:^(NSError* error){
                                                   
                                               }];
        }];
    } faliure:^(NSError* error){
        [SKDaemonManager SynMaxUpdateDateWithClient:self.clientApp
                                           complete:^(NSMutableArray* array){
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [self reloadBageNumberWithServerInfo:array];
                                               });
                                           } faliure:^(NSError* error){
                                               
                                           }];
    }];
}

-(long long)maxuptmFromServer:(NSArray*)array ChannelCode:(NSString*)code{
    for (NSDictionary* dict in array) {
        NSDictionary* vinfo = dict[@"v"];
        if ([vinfo[@"CHANNELCODE"] isEqualToString:code]) {
            NSString* timestr = vinfo[@"LATESTTIME"];
            //NSLog(@"%@ %@",timestr,code);
            NSTimeInterval time = [[DateUtils stringToDate:timestr DateFormat:dateTimeFormat] timeIntervalSince1970];
            return time*1000;
        }
    }
    return 0;
}

-(void)reloadBageNumberWithServerInfo:(NSArray*)array{
        if(array){
            for (UIDragButton*btn in upButtons) {
                long long lmaxuptm = [btn.channel.MAXUPTM longLongValue];
                //long long lminuptm = [btn.channel.MINUPTM longLongValue];
                long long smaxuptm = [self maxuptmFromServer:array ChannelCode:btn.channel.CODE];
                //NSLog(@"%@ lmax =  %lld  smax = %lld lmin =%lld",btn.channel.NAME,lmaxuptm,smaxuptm,lminuptm);
                if (smaxuptm > lmaxuptm) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [btn setBadgeNumber:@"new"];
                    });
                }else{
                    if (![btn.channel.TYPELABLE isEqualToString:@"meeting,"]) {
                        [btn setBadgeNumber:[LocalMetaDataManager newECMDataItemCount:btn.channel.FIDLISTS]];
                    }else{
                         [btn setBadgeNumber:[LocalMetaDataManager newECMMeettingItemCount:btn.channel.FIDLISTS]];
                    }
                }
            }
        }
}

-(void)reloadBageNumber{
    [self setECMBadgeNumber];
}

-(void)setECMBadgeNumber{
    for (UIDragButton *btn in upButtons)
    {
        if (![btn.channel.TYPELABLE isEqualToString:@"meeting,"]) {
            [btn setBadgeNumber:[LocalMetaDataManager newECMDataItemCount:btn.channel.FIDLISTS]];
        }else{
            [btn setBadgeNumber:[LocalMetaDataManager newECMMeettingItemCount:btn.channel.FIDLISTS]];
        }
    }
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    NSLog(@"SKGridController 我内存报警了，来治我吧。。。");
}
@end
