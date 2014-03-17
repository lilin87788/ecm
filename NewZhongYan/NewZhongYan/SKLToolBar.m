//
//  SKLToolBar.m
//  ZhongYan
//
//  Created by linlin on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKLToolBar.h"
@implementation SKLToolBar
@synthesize homeButton,firstButton,secondButton,thirdButton;
@synthesize firstLabel,secondLabel,thirdLabel;

- (void)backToRoot:(id)sender
{
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [homeButton setBackgroundColor:COLOR(17, 168, 171)];
        [homeButton setFrame:CGRectMake(2, 0, 49, 49)];
        [self addSubview:homeButton];
        
        //search text
        UILabel* homeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        homeLabel.text = @"首页";
        homeLabel.textAlignment = UITextAlignmentCenter;
        homeLabel.backgroundColor = [UIColor clearColor];
        homeLabel.textColor = [UIColor colorWithRed:0 green:48.0/255 blue:161.0/255 alpha:1];
        homeLabel.font = [UIFont systemFontOfSize:10];
        CGPoint labelCenter = homeButton.center;
        labelCenter.y += 15;
        [homeLabel setCenter:labelCenter];
        [self addSubview:homeLabel];
        
        //右边的背景图片
        UIImage* image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"email_bg" ofType:@"png"]];
        UIImageView * bgImageView = [[UIImageView alloc] initWithImage:image];
        [bgImageView setFrame:CGRectMake(89, 0, 231, 49)];
        [self addSubview:bgImageView];
        
        //first
        firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:firstButton];
        
        //second
        secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:secondButton];

        
        //third
        thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:thirdButton];

        [homeButton addTarget:self action:@selector(backToRoot:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)setFirstItem:(NSString*)imageName Title:(NSString*)title
{
    [firstButton setFrame:CGRectMake(89, 0, 77, 48)];
    [firstButton setImageEdgeInsets:UIEdgeInsetsMake(8, 15, 8, 30)];
    [firstButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [firstButton setImage:[UIImage imageNamed:[imageName stringByAppendingString:@"_presssed"]] forState:UIControlStateHighlighted];
    [firstButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [firstButton setTitle:title forState:UIControlStateNormal];
}

-(void)setSecondItem:(NSString*)imageName Title:(NSString*)title
{
    [secondButton setFrame:CGRectMake(166, 0, 77, 48)];
    [secondButton setImageEdgeInsets:UIEdgeInsetsMake(8, 10, 8, 35)];
    [secondButton setTitleEdgeInsets:UIEdgeInsetsMake(14, -1, 14, 1)];
    [secondButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [secondButton setImage:[UIImage imageNamed:[imageName stringByAppendingString:@"_presssed"]] forState:UIControlStateHighlighted];
    [secondButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [secondButton setTitle:title forState:UIControlStateNormal];
}

-(void)setThirdItem:(NSString*)imageName Title:(NSString*)title
{
    [thirdButton setFrame:CGRectMake(243, 0, 77, 48)];
    [thirdButton setImageEdgeInsets:UIEdgeInsetsMake(8, 5, 8, 40)];
    [thirdButton setTitleEdgeInsets:UIEdgeInsetsMake(14, -15, 14, 0)];
    [thirdButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [thirdButton setImage:[UIImage imageNamed:[imageName stringByAppendingString:@"_presssed"]] forState:UIControlStateHighlighted];
    [thirdButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [thirdButton setTitle:title forState:UIControlStateNormal];
}
@end
