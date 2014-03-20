//
//  SKAppInstallController.m
//  NewZhongYan
//
//  Created by lilin on 14-3-20.
//  Copyright (c) 2014年 surekam. All rights reserved.
//

#import "SKAppInstallController.h"

@implementation SKAppInstallController
-(void)viewDidLoad
{
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://tam.hngytobacco.com/d/"]];
    [_webview loadRequest:request];
}
@end
