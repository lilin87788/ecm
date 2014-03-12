//
//  SKViewController.m
//  NewZhongYan
//
//  Created by lilin on 13-9-28.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "SKViewController.h"
#import "SKLoginViewController.h"
#import "DDXMLDocument.h"
#import "DDXMLElementAdditions.h"
#import "DDXMLElement.h"
#import "SKSystemMenuController.h"
#import "SKPatternLockController.h"
#import "SKAgentLogonManager.h"
#import "LocalMetaDataManager.h"
#import "GetNewVersion.h"
#import "SKAPPUpdateController.h"
#import "MBProgressHUD.h"
#import "DataServiceURLs.h"
#import "SKGridController.h"
#import "UIView+screenshot.h"
#import "UIImage+BlurredFrame.h"
#import "SKDaemonManager.h"
#import "SKECMRootController.h"
#define OriginY ((IS_IOS7) ? 64 : 0 )
#define DepartmentInfomationCheckDate @"DepartmentInfomationCheckDate"
#define ClientInfomationCheckDate @"ClientInfomationCheckDate"
@interface SKViewController ()
{
    SKSystemMenuController* settingController;
    BWStatusBarOverlay* BWStatusBar;
    //UIPageControl* pageController;
    
    __weak IBOutlet UIView *workItemView;
    __weak IBOutlet UIView *titleView;
    __weak IBOutlet UIImageView *titleImageView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITabBar *tabbar;
    __weak IBOutlet UITabBarItem *remindTabItem;
    __weak IBOutlet UITabBarItem *emailTabItem;
    UILabel* navTitleLabel;
    UIView* topView;
    
    
    SKGridController* companyController;
    SKGridController* selfCompanyController;
    NSMutableArray* controllerArray;
}
@end

@implementation SKViewController
@synthesize bgScrollView;
@synthesize pageController;
-(UIStatusBarStyle)preferredStatusBarStyle
{
   // return UIStatusBarStyleDefault;
    return UIStatusBarStyleLightContent;
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return  UIBarPositionTop;
}

//功能:点击帮助界面消失的手势
-(void)handleTapForHelpImage:(UIGestureRecognizer*)recognizer
{
    if (recognizer.state==UIGestureRecognizerStateEnded)
    {
        UIImageView* helpImage = (UIImageView*)[self.view.window viewWithTag:1111];
        [helpImage fallOut:.4 delegate:nil completeBlock:^{
            [helpImage performSelector:@selector(removeFromSuperview) withObject:0 afterDelay:0.4];
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }] ;
    }
}

- (IBAction)onHelpButtonClick:(id)sender {
    UIImageView* helpImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [helpImage setImage:[UIImage imageNamed:IS_IPHONE_5? @"iphone5_mainpage" : @"iphone4_mainpage"]];
    [helpImage setUserInteractionEnabled:YES];
    [helpImage setTag:1111];
    [self.view.window addSubview:helpImage];
    
    UITapGestureRecognizer *tapGes=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapForHelpImage:)];
    [helpImage addGestureRecognizer:tapGes];
    [helpImage fallIn:.4 delegate:nil completeBlock:^{
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }];
}

//功能:将用于界面布局的xml文件拷贝到document文件夹中 因为位于bundle中的xml文件不能修改他
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

-(void)initNavBar
{
    self.navigationItem.backBarButtonItem.title = @"返回";
    UIImage* navbgImage;
    if (System_Version_Small_Than_(7)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        navbgImage = [UIImage imageNamed:@"navbar44"] ;
        self.navigationController.navigationBar.tintColor = COLOR(0, 97, 194);
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self setNeedsStatusBarAppearanceUpdate];
        navbgImage = [UIImage imageNamed:@"navbar64"] ;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
    }
    [self.navigationController.navigationBar setBackgroundImage:navbgImage  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor: [UIColor whiteColor]};
    
    
    CGRect rect = self.navigationController.navigationBar.bounds;
    //rect.size.width -= 44;
    topView = [[UIView alloc] initWithFrame:rect];
//    topView.backgroundColor =COLOR(0, 97, 194);
//    topView.backgroundColor =COLOR(17, 168, 171);
    topView.backgroundColor =[UIColor clearColor];
    
//    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(285, 9.5, 25, 25)];
//    iv.image = Image(@"main_btn_right_set");
//    [topView addSubview:iv];
    
//    UIButton* settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [settingButton setFrame:CGRectMake(272, 0, 48, 44)];
//    [settingButton addTarget:self action:@selector(showSettingView:) forControlEvents:UIControlEventTouchUpInside];
//    [topView addSubview:settingButton];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 25)];
    [label setFont:[UIFont boldSystemFontOfSize:25]];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:@"湖南中烟"];
    [topView addSubview:label];
    
    navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(112, 18, 80, 19)];
    [navTitleLabel setFont:[UIFont systemFontOfSize:14]];
    [navTitleLabel setTextColor:[UIColor whiteColor]];
    [navTitleLabel setTextAlignment:NSTextAlignmentLeft];
    [navTitleLabel setBackgroundColor:[UIColor clearColor]];
    [topView addSubview:navTitleLabel];
    [self.navigationController.navigationBar addSubview:topView];
}

-(void)showSettingView:(UIButton*)sender
{
    [settingController ecmTouchDown];
}

-(void)initSetting
{
    settingController = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"setting"];
    settingController.rootController = self;
    CGRect rect = CGRectMake(0,self.view.bounds.size.height - 44 - 44,320,self.view.bounds.size.height - 44);
    if (IS_IOS7)
    {
        rect.origin.y += 44;
    }
    rect.origin.y+= 44;
    [settingController.view setFrame:rect];
    [self.view addSubview:settingController.view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"SKECMRootController"])
	{
        SKECMRootController *ecmRoot = segue.destinationViewController;
        ecmRoot.channel = sender;
	}
}

- (IBAction)jumpToEmailController:(id)sender {
}
- (IBAction)jumpToRemindController:(id)sender {
}
- (IBAction)jumpAddressBookController:(id)sender {
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    switch (item.tag) {
        case 0:
        {
            item.selectedImage = Image(@"remind_highnight");
            [self performSegueWithIdentifier:@"SKGTaskViewController"sender:self];
            break;
        }
        case 1:
        {
            item.selectedImage = Image(@"email_highnight");
            [self performSegueWithIdentifier:@"SKEmailController"sender:self];
            break;
        }
        case 2:
        {
            item.selectedImage = Image(@"address_highnight");
            [self performSegueWithIdentifier:@"SKAddressController"sender:self];
            break;
        }
        case 3:
        {
            item.selectedImage = Image(@"setting_highnight");
            [settingController ecmTouchDown];
            break;
        }
        default:
            break;
    }
}

-(void)jumpToController:(id)sender
{
    UIDragButton *btn=(UIDragButton *)[(UIDragButton *)sender superview] ;
    //UIViewController* controller = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:btn.controllerName];
    //[self.navigationController pushViewController:controller animated:YES];
    [self performSegueWithIdentifier:btn.controllerName sender:self];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        BWStatusBar = [[BWStatusBarOverlay alloc] init];
        isFirstLogin = ![APPUtils userUid];
    }
    return self;
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = pageController.currentPage;
    CGRect bounds = bgScrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [bgScrollView scrollRectToVisible:bounds animated:animated];
}

- (void)scrollToPage:(int)page
{
    CGRect bounds = bgScrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [bgScrollView scrollRectToVisible:bounds animated:YES];
    pageController.currentPage = page;
}

- (IBAction)changePage:(id)sender
{
    [self gotoPage:YES];    // YES = animate
}

-(void)initPageController
{
    pageController = [[SMPageControl alloc] initWithFrame:CGRectMake((320 - 150)/2., BottomY - 49 - 35, 150, 40)];
    //[pageController setHidden:YES];
    [pageController setIndicatorDiameter:8];
    [pageController setHidesForSinglePage:YES];
    [pageController setNumberOfPages:2];
//    [pageController setPageIndicatorTintColor:[UIColor blackColor]];
//    [pageController setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
    [pageController setCurrentPageIndicatorImage:Image(@"dot_selected")];
    [pageController setPageIndicatorImage:Image(@"dot_normal")];
    [pageController setCurrentPage:0];
    [pageController addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageController];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth(bgScrollView.frame);
    NSUInteger page = floor((bgScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageController.currentPage = page;
    SKGridController *controller = controllerArray[page];
    titleLabel.text = controller.clientApp.NAME;
    navTitleLabel.text = controller.clientApp.NAME;
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    [bgScrollView setContentSize:CGSizeMake((page + 1) * 320, bgScrollView.frame.size.height)];
    SKGridController *controller = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"SKGridController"];
    //controller.isCompanyPage = !page;
    controller.rootController = self;
    [controllerArray addObject:controller];
    if (controller.view.superview == nil)
    {
        CGRect frame = bgScrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self addChildViewController:controller];
        [bgScrollView addSubview:controller.view];
    }
}

- (SKGridController*)loadScrollViewWithClientApp:(SKClientApp*)app PageNo:(int)page
{
    if (page == 0) {
        navTitleLabel.text = app.NAME;
    }
    [bgScrollView setContentSize:CGSizeMake((page + 1) * 320, bgScrollView.frame.size.height)];
    SKGridController *controller = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"SKGridController"];
    controller.rootController = self;
    controller.clientApp = app;
    [controllerArray addObject:controller];
    if (controller.view.superview == nil)
    {
        CGRect frame = bgScrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [self addChildViewController:controller];
        [bgScrollView addSubview:controller.view];
    }
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    titleLabel.text = @"吴忠主页";
    controllerArray = [NSMutableArray array];
    if (System_Version_Small_Than_(7)) {
        tabbar.backgroundImage = Image(@"landbar_noshadow");
        [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor lightGrayColor]} forState:UIControlStateNormal];
    }

    [self copyXMLToDocument];
    [self initNavBar];
    [self initPageController];
    [self initSetting];
    if (isFirstLogin) {
        SKLoginViewController* loginController = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"loginController"];
        [FileUtils setvalueToPlistWithKey:@"EPSIZE" Value:@"5"];
        [self presentViewController:loginController animated:NO completion:^{
            NSString* username = [FileUtils valueFromPlistWithKey:@"gpusername"];
            if ([username length] > 0) {
                loginController.userField.text = username;
                loginController.userField.enabled = NO;
            }
        }];
    }else{
        [self initClientApp];
        UINavigationController* nav = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"patternlocknav"];
        SKPatternLockController* locker = (SKPatternLockController*)[nav topViewController];
        [locker setDelegate:self];
        [[APPUtils visibleViewController] presentViewController:nav animated:NO completion:^{
            [LocalMetaDataManager restoreAllMetaData];
        }];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [topView setHidden:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [topView setHidden:NO];
}

-(void)viewWillLayoutSubviews
{
    tabbar.selectedItem = nil;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [emailTabItem setBadgeValue:[LocalMetaDataManager newDataItemCount:[LocalDataMeta sharedMail]]];
    [remindTabItem setBadgeValue:[LocalMetaDataManager newDataItemCount:[LocalDataMeta sharedRemind]]];
}

#pragma mark - 屏保代理函数
//注释  比较版本号
//注释  显示版本号
-(void)onGetNewVersionDoneWithDic:(NSDictionary *)dic
{
    NSDictionary* vDic=[[NSDictionary alloc] initWithDictionary:[[[dic objectForKey:@"s"] objectAtIndex:0] objectForKey:@"v"]];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    if ([[vDic objectForKey:@"NVER"] floatValue] > [appVersion floatValue])
    {
        UINavigationController* nav = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"versionupdatenav"];
        [self presentViewController:nav animated:NO completion:^{
            SKAPPUpdateController* updater = (SKAPPUpdateController*)[nav topViewController];
            [updater setVersionDic:vDic];
        }];
    }
}

-(BOOL)isLoggedCookieValidity
{
    ASIHTTPRequest* validateLogonrequest =
    [ASIHTTPRequest requestWithURL:validloginurl];
    [validateLogonrequest setTimeOutSeconds:15];
    [validateLogonrequest setDefaultResponseEncoding:NSUTF8StringEncoding];
    [validateLogonrequest startSynchronous];
    if ([[validateLogonrequest responseData] length] == 1)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)updateClientAppinfo
{
    for (SKGridController* controller in controllerArray) {
        [controller reloadData];
    }
}

-(void)initClientApp
{
    clientAppArray = [NSMutableArray array];
    NSArray* array = [[DBQueue sharedbQueue] recordFromTableBySQL:@"select * from T_CLIENTAPP where HASPMS = 1 and ENABLED = 1 ORDER BY DEFAULTED;"];
    [pageController setNumberOfPages:array.count];
    for (NSDictionary* dict in array) {
        SKClientApp* clientApp = [[SKClientApp alloc] initWithDictionary:dict];
        [clientAppArray addObject:clientApp];
    }
    for (SKClientApp* app in clientAppArray) {
        [self loadScrollViewWithClientApp:app PageNo:[clientAppArray indexOfObject:app]];
    }
}

-(void)firstInitClientApp
{
    clientAppArray = [NSMutableArray array];
    NSArray* array = [[DBQueue sharedbQueue] recordFromTableBySQL:@"select * from T_CLIENTAPP where HASPMS = 1 and ENABLED = 1 ORDER BY DEFAULTED;"];
    [pageController setNumberOfPages:array.count];
    for (NSDictionary* dict in array) {
        SKClientApp* clientApp = [[SKClientApp alloc] initWithDictionary:dict];
        [clientAppArray addObject:clientApp];
    }
    for (SKClientApp* app in clientAppArray) {
        SKGridController* controller =  [self loadScrollViewWithClientApp:app PageNo:[clientAppArray indexOfObject:app]];
        [controller reloadData];
    }
}

/**
 *  检测应用更新的代码该代码一天只执行一次
 *  特殊情况: 当APP更新后可能会导致强制更新应用
 */
//保证每天只执行一次的代码
-(void)checkClientInfomationCheckDate
{
    NSDate* date = [[NSUserDefaults standardUserDefaults] objectForKey:ClientInfomationCheckDate];
//    NSLog(@"%@",[[date dateAtStartOfDay] dateByAddingHours:8]);
//    NSLog(@"%d",[[[[[NSDate date] dateAtStartOfDay] dateByAddingHours:8] dateByAddingDays:1] daysAfterDate:[[date dateAtStartOfDay] dateByAddingHours:8]]);
    if(!date)//这里保证补丁代码只执行一次
    {
        [[NSUserDefaults standardUserDefaults] setObject:[[[NSDate date] dateAtStartOfDay] dateByAddingHours:8] forKey:DepartmentInfomationCheckDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)afterOnLogon
{
    [self updateClientAppinfo];
    [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedVersionInfo] delegate:self];
    [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedRemind] delegate:self];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ECONTACTSYNED"]) {
        if ([APPUtils currentReachabilityStatus] == ReachableViaWiFi) {
            [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedEmployee] delegate:self];
            [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedOranizational] delegate:self];
            [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedUnit] delegate:self];
        }
    }
    [GetNewVersion getNewsVersionComplteBlock:^(NSDictionary* dict){
        [self onGetNewVersionDoneWithDic:dict];
    } FaliureBlock:^(NSDictionary* error){
        NSLog(@"获取app版本信息失败 %@",error);
    }];
}

-(void)onPatternLockSuccess
{
    if (isFirstLogin){//这里还有bug//测试 登陆后会不会到这里
        isFirstLogin = NO;
        NSString* username = [FileUtils valueFromPlistWithKey:@"gpusername"];
        if ([username length] > 0 ) {
            [FileUtils setvalueToPlistWithKey:@"gpusername" Value:@""];//这里一般不是第一次登陆 比如屏幕保护密码输错
        }else{
            if ([APPUtils currentReachabilityStatus] != NotReachable) {
                [self firstInitClientApp];
                [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedEmployee] delegate:self];
                [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedOranizational] delegate:self];
                [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedUnit] delegate:self];
                [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedSelfEmployee] delegate:0];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SKAppDelegate sharedCurrentUser].logging = NO;
                    [BWStatusBarOverlay showSuccessWithMessage:@"当前网络不可用，请检查网络设置" duration:1 animated:1];
                });
            }
        }
    }else{
        if ([APPUtils currentReachabilityStatus] != NotReachable) {
            NSDate *date=[FileUtils valueFromPlistWithKey:@"sleepTime"];
            int sleepSecond = [[NSDate date] secondsAfterDate:date];
            if (sleepSecond > 1500 || sleepSecond < 0)
            {
                if (sleepSecond > 1500 && [self isLoggedCookieValidity]) {
                    [self afterOnLogon];
                }else{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [[APPUtils AppLogonManager] loginWithUser:[SKAppDelegate sharedCurrentUser]
                                                    CompleteBlock:^{
                                                        [self afterOnLogon];
                                                    }failureBlock:^(NSDictionary* dict){
                                                        
                                                    }];
                    });
                }
                
            }else{
                //有事后需要检查是否需要重新构建grid 界面 比如 bug10 首次登陆 help 界面 再进来的情况
                if (!clientAppArray) {
                    [self firstInitClientApp];
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ECONTACTSYNED"]) {
                        if ([APPUtils currentReachabilityStatus] == ReachableViaWiFi) {
                            [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedEmployee] delegate:self];
                            [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedOranizational] delegate:self];
                            [SKDataDaemonHelper synWithMetaData:[LocalDataMeta sharedUnit] delegate:self];
                        }
                    }
                }
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SKAppDelegate sharedCurrentUser].logging = NO;
                [BWStatusBarOverlay showSuccessWithMessage:@"当前网络不可用，请检查网络设置" duration:1 animated:1];
            });
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        [FileUtils setvalueToPlistWithKey:@"gpsw" Value:@""];
        [FileUtils setvalueToPlistWithKey:@"gpusername" Value:[APPUtils userUid]];
        [[DBQueue sharedbQueue] updateDataTotableWithSQL:@"delete from USER_REMS"];
        SKLoginViewController* loginController = [[APPUtils AppStoryBoard] instantiateViewControllerWithIdentifier:@"loginController"];
        [[APPUtils visibleViewController] presentViewController:loginController animated:NO completion:^{
            [loginController.userField setText:[FileUtils valueFromPlistWithKey:@"gpusername"]];
            [loginController.userField setEnabled:NO];
        }];
    }
}

#pragma mark - 数据代理函数
-(void)didBeginSynData:(LocalDataMeta *)metaData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([metaData.dataCode isEqualToString:@"employee"]  && ![metaData isUserOwner])  {
            BWStatusBar =  [[BWStatusBarOverlay alloc] init];
            [BWStatusBar showLoadingWithMessage:@"正在同步通讯录..." animated:YES];
            [BWStatusBar setProgressBackgroundColor:COLOR(17, 168, 171)];
        }
    });
}

-(void)didCompleteSynData:(LocalDataMeta *)metaData
{
    if ([metaData.dataCode isEqualToString:@"employee"] && ![metaData isUserOwner])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ECONTACTSYNED"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        dispatch_async(dispatch_get_main_queue(), ^{
            [BWStatusBar showSuccessWithMessage:@"通讯录同步完成" duration:2 animated:YES];
        });
    }
}

-(void)didCompleteSynData:(NSString *)datacode SV:(int)sv SC:(int)sc LV:(int)lv
{
    
}

-(void)didEndSynData:(LocalDataMeta *)metaData
{
    float p = (float)metaData.lastfrom/metaData.lastcount;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([metaData.dataCode isEqualToString:@"employee"] && ![metaData isUserOwner])  {
            [BWStatusBar setProgress:p animated:YES];
            [BWStatusBar setMessage:@"正在同步通讯录..." animated:NO];
        }
    });
}

-(void)didCancelSynData:(LocalDataMeta *)metaData
{
    
}

-(void)didErrorSynData:(LocalDataMeta *)metaData Reason:(NSString *)errorinfo
{
    NSLog(@"didErrorSynData");
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"SKViewController 我内存报警了，来治我吧。。。");
}
@end
