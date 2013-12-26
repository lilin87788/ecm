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
#import "UIButton+WebCache.h"
#import "SKViewController.h"
#import "SKDaemonManager.h"
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
    UIDragButton *btn=(UIDragButton *)[(UIDragButton *)sender superview] ;
    //UIViewController* controller = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:btn.controllerName];
    //[self.navigationController pushViewController:controller animated:YES];
    [_rootController performSegueWithIdentifier:[self controllerWithCode:btn.controllerName] sender:_rootController];
}

-(void)initSelfFactoryView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        upButtons = [[NSMutableArray alloc] init];
        NSString* sql = [NSString stringWithFormat:@"select * from T_CHANNEL WHERE OWNERAPP = '%@' and LEVL = 1;",self.clientApp.CODE];
        NSArray* array = [[DBQueue sharedbQueue] recordFromTableBySQL:sql];
        for (int i=0;i<array.count;i++)
        {
            NSDictionary *dict=[array objectAtIndex:i];
            UIDragButton *dragbtn=[[UIDragButton alloc] initWithFrame:CGRectZero inView:self.view];
            [dragbtn setTitle:dict[@"NAME"]];
            [dragbtn.tapButton setImageWithURL:[NSURL URLWithString:dict[@"LOGO"]] forState:UIControlStateNormal];
            [dragbtn setNormalImage:dict[@"NAME"]];
            [dragbtn setControllerName:dict[@"CODE"]];
            [dragbtn setLocation:up];
            [dragbtn setDelegate:self];
            [dragbtn setTag:i];
            [dragbtn.tapButton addTarget:self action:@selector(jumpToController:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:dragbtn];
            [upButtons addObject:dragbtn];
        }
        
        [self setUpButtonsFrameWithAnimate:NO withoutShakingButton:nil];
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
        [dragbtn.tapButton addTarget:self action:@selector(jumpToController:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:dragbtn];
        [upButtons addObject:dragbtn];
    }
    [self setUpButtonsFrameWithAnimate:NO withoutShakingButton:nil];
}

-(void)reloadData
{
    [SKDaemonManager SynChannelWithClientApp:self.clientApp complete:^{
        for (UIView* v in self.view.subviews) {
            if (v.class == [UIDragButton class]) {
                [v removeFromSuperview];
            }
        }
        [self initSelfFactoryView];
//        if (self.isCompanyPage) {
//            [self initCompanyPageView];
//        }else{
//            [self initSelfFactoryView];
//        }
    } faliure:^(NSError* error){
        NSLog(@"%@",[error userInfo][@"reason"]);
    }];

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
                            [button setFrame:CGRectMake(40 + x * 90,  40 + y * 96.6, 60, 60)];
                        }
                        //[button setLastCenter:CGPointMake(CGRectGetMidX(button.frame),CGRectGetMidY(button.frame))];
                        [button setLastCenter:CGPointMake(40 + x * 90 + 30,  40 + y * 96.6 + 30)];
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
                        [button setFrame:CGRectMake(40 + x * 90, 40 + y * 96.6, 60, 60)];
                        [button setLastCenter:CGPointMake(40 + x * 90 + 30,  40 + y * 96.6 + 30)];
                    }
                }
            }
        }];
    }
}

- (void)checkLocationOfOthersWithButton:(UIDragButton *)shakingButton
{
    if (shakingButton.location == up)
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

- (void)viewDidLoad
{
    [super viewDidLoad];
     [self initSelfFactoryView];
    
//    if (self.isCompanyPage) {
//        [self initCompanyPageView];
//    }else{
//        [self initSelfFactoryView];
//    }
}

@end
