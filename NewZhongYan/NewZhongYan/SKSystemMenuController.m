//
//  SKSystemMenuController.m
//  NewZhongYan
//
//  Created by lilin on 13-10-9.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "SKSystemMenuController.h"
#import "SKAppConfiguration.h"
#define duration 0.7
#define ECM 1
#define MAINHEIGHT ([UIScreen mainScreen].bounds.size.height - 44 -  20)
#define MAINY ([UIScreen mainScreen].bounds.size.height - 44 - 44 - 20)
@interface SKSystemMenuController ()
{
    UITapGestureRecognizer *tapgesture;
    UIPanGestureRecognizer *pangesture;
}
@end

@implementation SKSystemMenuController
- (IBAction)onAboutClick:(id)sender {
    [_rootController performSegueWithIdentifier:@"about" sender:0];
}

- (IBAction)onPersonInfoClick:(id)sender {
    [_rootController performSegueWithIdentifier:@"userinfo" sender:0];
}

- (IBAction)onSecretClick:(id)sender {
    [_rootController performSegueWithIdentifier:@"secret" sender:0];
}

- (IBAction)onInstallAppClick:(id)sender {
    [UIAlertView showAlertString:@"该功能即将完善，请稍等"];
}

- (IBAction)onAppMaintainClick:(id)sender {
    [_rootController performSegueWithIdentifier:@"Maintain" sender:0];
}

- (IBAction)onAppConfigureClick:(id)sender {
    SKAppConfiguration *configure=[[SKAppConfiguration alloc] init];
     [[APPUtils visibleViewController].navigationController pushViewController:configure animated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (System_Version_Small_Than_(7)) {
        UIButton* backbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backbtn setFrame:CGRectMake(0, 0, 50, 30)];
        [backbtn setBackgroundImage:Image(@"back") forState:UIControlStateNormal];
        [backbtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backbtn];
        self.navigationItem.leftBarButtonItem = backItem;
    }else{
        UIBarButtonItem* backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
    }
    
    tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchDown)];
    pangesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:0];
    pangesture.delegate = self;
    topImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    imageView.image = [UIImage imageNamed:@"pushbar_p.png"];
    [topImageView addSubview:imageView];
    [topImageView addGestureRecognizer:tapgesture];
    //[topImageView addGestureRecognizer:pangesture]; //先去掉 避免和系统的手势冲突
    [self.view addSubview:topImageView];
}

#pragma mark - View lifecycle
- (void)touchDown
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGRect rect;
    if (isSystemMenuShow)
    {
        rect = CGRectMake(0, MAINY, 320, MAINHEIGHT);
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        {
            rect.origin.y += 64;
        }
        if (ECM) {
            rect.origin.y += 44;
        }
        self.view.frame = rect;
        imageView.image = [UIImage imageNamed:@"pushbar_n.png"];
        isSystemMenuShow = NO;
    }
    else
    {
        rect = CGRectMake(0, 0, 320, MAINHEIGHT);
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        {
            rect.origin.y += 64;
        }
        self.view.frame = rect;
        imageView.image = [UIImage imageNamed:@"pushbar_p.png"];
        isSystemMenuShow = YES;
    }
    [UIView commitAnimations];
}

- (void)ecmTouchDown
{
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        CGRect rect;
        if (isSystemMenuShow)
        {
            rect = CGRectMake(0, MAINY, 320, MAINHEIGHT);
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            {
                rect.origin.y += 64;
            }
            rect.origin.y += 44;
            self.view.frame = rect;
            imageView.image = [UIImage imageNamed:@"pushbar_n.png"];
        }
        else
        {
            rect = CGRectMake(0, 0, 320, MAINHEIGHT);
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            {
                rect.origin.y += 64;
            }
            self.view.frame = rect;
            imageView.image = [UIImage imageNamed:@"pushbar_p.png"];
        }

    } completion:^(BOOL completed){
        isSystemMenuShow = !isSystemMenuShow;
    }];
}

-(void)hide
{
    self.view.frame = CGRectMake(0, MAINY, 320, MAINHEIGHT);
    imageView.image = [UIImage imageNamed:@"pushbar_n.png"];
    isSystemMenuShow = NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        CGRect rect;
        if (isSystemMenuShow)
        {
            rect = CGRectMake(0, MAINY, 320, MAINHEIGHT);
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            {
                rect.origin.y += 64;
            }
            if (ECM) {
                rect.origin.y += 44;
            }
            self.view.frame = rect;
            imageView.image = [UIImage imageNamed:@"pushbar_n.png"];
        }
        else
        {
            rect = CGRectMake(0, 0, 320, MAINHEIGHT);
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            {
                rect.origin.y += 64;
            }
            self.view.frame = rect;
            imageView.image = [UIImage imageNamed:@"pushbar_p.png"];
        }
        
    } completion:^(BOOL completed){
        isSystemMenuShow = !isSystemMenuShow;
    }];
    
    return YES;
}

- (void)viewChange:(int)rangeY
{
    int positionY = self.view.frame.origin.y + rangeY;
    //最顶端 和 最低端 不能拖动 的情况
    if ((System_Version_Small_Than_(7) && positionY < 0) || positionY >= MAINY) {
        return;
    }if (IS_IOS7 && positionY >= (MAINY + 64)) {
        return;
    }
    
    self.view.frame = CGRectMake(0, positionY, 320, MAINHEIGHT);
}

#pragma mark - touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    StartPoint = [[touches anyObject] locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    MovePoint = [[touches anyObject] locationInView:self.view];
    int rangeY = MovePoint.y - StartPoint.y;
    if (rangeY <= 0 && IS_IOS7 && self.view.frame.origin.y == 64) {
        return;
    }
    [self viewChange:rangeY];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.view.frame.origin.y < 200)
    {
        isSystemMenuShow = NO;
        [self touchDown];
    }
    else
    {
        isSystemMenuShow = YES;
        [self touchDown];
    }
}
- (IBAction)contactus:(id)sender {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt:0731-88575036"]];
}

@end
