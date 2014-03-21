//
//  SKToolBar.m
//  ZhongYan
//
//  Created by linlin on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKToolBar.h"
#import "APPUtils.h"
#import "SKViewController.h"
@implementation SKToolBar
@synthesize homeButton,searchButton,refreshButton;

-(void)backToRoot:(id)sender
{
    SKViewController* controller = [APPUtils AppRootViewController];
    [controller.navigationController popToRootViewControllerAnimated:YES];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = COLOR(247, 247, 247);
        homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [homeButton setImage:Image(@"homepage") forState:UIControlStateNormal];
        [homeButton setImage:Image(@"homepage_blue") forState:UIControlStateSelected];
        [homeButton setImage:Image(@"homepage_blue") forState:UIControlStateHighlighted];
        [homeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 8, 0)];
        [homeButton setFrame:CGRectMake(2, 0, 49, 49)];
        [homeButton addTarget:self action:@selector(backToRoot:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:homeButton];
        
        //search text
        UILabel* homeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        homeLabel.text = @"首页";
        homeLabel.textAlignment = UITextAlignmentCenter;
        homeLabel.backgroundColor = [UIColor clearColor];
        homeLabel.font = [UIFont systemFontOfSize:10];
        CGPoint labelCenter = homeButton.center;
        labelCenter.y += 15;
        [homeLabel setCenter:labelCenter];
        [self addSubview:homeLabel];
        
        //search
        searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [searchButton setFrame:CGRectMake(180, 0, 49, 49)];
        [searchButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 8, 0)];
        [searchButton setImage:Image(@"btn_search_ecm") forState:UIControlStateNormal];
        [searchButton setImage:Image(@"btn_search_ecm_press") forState:UIControlStateSelected];
        [searchButton setImage:Image(@"btn_search_ecm_press") forState:UIControlStateHighlighted];
        [self addSubview:searchButton];
        
        UILabel* searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        searchLabel.text = @"搜索";
        searchLabel.textAlignment = UITextAlignmentCenter;
        searchLabel.backgroundColor = [UIColor clearColor];
        searchLabel.font = [UIFont systemFontOfSize:10];
        CGPoint searchLabelCenter = searchButton.center;
        searchLabelCenter.y += 15;
        [searchLabel setCenter:searchLabelCenter];
        [self addSubview:searchLabel];
        
        refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [refreshButton setFrame:CGRectMake(260, 0, 49, 49)];
        [refreshButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 8, 0)];
        [refreshButton setImage:[UIImage imageNamed:@"btn_refresh_ecm"] forState:UIControlStateNormal];
        [refreshButton setImage:[UIImage imageNamed:@"btn_refresh_ecm_press"] forState:UIControlStateSelected];
        [refreshButton setImage:[UIImage imageNamed:@"btn_refresh_ecm_press"] forState:UIControlStateSelected];
        [self addSubview:refreshButton];

        UILabel* refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        refreshLabel.text = @"同步";
        refreshLabel.textAlignment = UITextAlignmentCenter;
        refreshLabel.backgroundColor = [UIColor clearColor];
        refreshLabel.font = [UIFont systemFontOfSize:10];
        CGPoint refreshlabelCenter = refreshButton.center;
        refreshlabelCenter.y += 15;
        [refreshLabel setCenter:refreshlabelCenter];
        [self addSubview:refreshLabel];
        
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 0.5)];
        [view setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:view];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame Target:(id)target FirstAction:(SEL)firstaction SecondAction:(SEL)secondaction
{
    self = [self initWithFrame:frame];
    if (self) {
        [searchButton addTarget:target action:firstaction forControlEvents:UIControlEventTouchUpInside];
        [refreshButton addTarget:target action:secondaction forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(id)initMaintainWithFrame:(CGRect)frame Target:(id)target Action:(SEL)action
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = COLOR(247, 247, 247);
        homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [homeButton setImage:Image(@"homepage") forState:UIControlStateNormal];
        [homeButton setImage:Image(@"homepage_blue") forState:UIControlStateSelected];
        [homeButton setImage:Image(@"homepage_blue") forState:UIControlStateHighlighted];
        [homeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 8, 0)];
        [homeButton setFrame:CGRectMake(2, 0, 49, 49)];
        [homeButton addTarget:self action:@selector(backToRoot:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:homeButton];
        
        //search text
        UILabel* homeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        homeLabel.text = @"首页";
        homeLabel.textAlignment = UITextAlignmentCenter;
        homeLabel.backgroundColor = [UIColor clearColor];
        homeLabel.font = [UIFont systemFontOfSize:10];
        CGPoint labelCenter = homeButton.center;
        labelCenter.y += 15;
        [homeLabel setCenter:labelCenter];
        [self addSubview:homeLabel];
        
        UIButton* clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearBtn setTitle:@"一键清除" forState:UIControlStateNormal];
        [clearBtn setFrame:CGRectMake(320 - 200, 0, 200, 49)];
        [clearBtn setTitleEdgeInsets:UIEdgeInsetsMake(10, 40, 0, 0)];
        [clearBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [clearBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        clearBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:clearBtn];
        
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 0.5)];
        [view setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:view];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame FirstTarget:(id)firsttarget FirstAction:(SEL)firstaction
      SecondTarget:(id)secondtarget SecondAction:(SEL)secondaction
{
    self = [self initWithFrame:frame];
    if (self) {
        [searchButton addTarget:firsttarget action:firstaction forControlEvents:UIControlEventTouchUpInside];
        [refreshButton addTarget:secondtarget action:secondaction forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)addFirstTarget:(id)target action:(SEL)action
{
    if (action && target) {
        [searchButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)addSecondTarget:(id)target action:(SEL)action
{
    if (action && target) {
        [refreshButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)setFirstTarget:(id)target action:(SEL)action
{
    for (id target in [searchButton allTargets]) {
        [searchButton removeTarget:target action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    }
    if (action && target) {
        [searchButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)setSecondTarget:(id)target action:(SEL)action
{
    for (id target in [refreshButton allTargets]) {
        [refreshButton removeTarget:target action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (action && target) {
        [refreshButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
}
@end
