//
//  SKPersonInfoController.m
//  NewZhongYan
//
//  Created by lilin on 13-11-14.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "SKPersonInfoController.h"
#import "SKSToolBar.h"
#import "SKMessageEntity.h"
@interface SKPersonInfoController ()
{
    UIBarButtonItem *previousBtn;
    UIBarButtonItem *nextBtn;
    UIBarButtonItem *doneBtn;
    UIToolbar *textToolBar;
    
    CGFloat keyboardHeight;
    NSInteger currentTextViewIndex;
    NSDictionary* personInfoDictionary;
    float changeHeight;//增长的高度
    
}
@end

@implementation SKPersonInfoController
-(void)dealloc
{
    mobileTextField.delegate = nil;
    shortPhoneTextField.delegate = nil;
    telephoneTextField.delegate = nil;
    officeAddressTextField.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)roundTextView:(UIView *)txtView{
    txtView.layer.borderColor = UIColor.grayColor.CGColor;
    txtView.layer.borderWidth = 1;
    txtView.layer.cornerRadius = 3.0;
    txtView.layer.masksToBounds = YES;
    txtView.clipsToBounds = YES;
}

-(void)refreshViewWithNetData
{
    [departmentLabel setText:[personInfoDictionary objectForKey:@"deptName"]];
    [mailLabel setText:[[personInfoDictionary objectForKey:@"email"] stringByReplacingOccurrencesOfString:@"@" withString:@"@\n"]];
    [mobileTextField setText:[personInfoDictionary objectForKey:@"mobile"]];
    [shortPhoneTextField setText:[personInfoDictionary objectForKey:@"shortPhone"]];
    [telephoneTextField setText:[personInfoDictionary objectForKey:@"telephone"]];
    [officeAddressTextField setText:[personInfoDictionary objectForKey:@"officeAddress"]];
}

-(void)refreshViewWithLocalData
{
    [departmentLabel setText:[personInfoDictionary objectForKey:@"UCNAME"]];
    [mailLabel setText:[personInfoDictionary objectForKey:@"EMAIL"]];
    [mobileTextField setText:[personInfoDictionary objectForKey:@"MOBILE"]];
    [shortPhoneTextField setText:[personInfoDictionary objectForKey:@"SHORTPHONE"]];
    [telephoneTextField setText:[personInfoDictionary objectForKey:@"TELEPHONE"]];
    [officeAddressTextField setText:[personInfoDictionary objectForKey:@"OFFICEADDRESS"]];
}

-(void)getUserInfoFromServer
{
    NSString* urlStr =
    [[NSString stringWithFormat:@"%@/users/%@/userinfo",ZZZobt,[APPUtils userUid]]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SKHTTPRequest *request = [SKHTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
    __weak SKHTTPRequest *req = request;
    [request setCompletionBlock:^{
        SKMessageEntity* entity = [[SKMessageEntity alloc] initWithData:req.responseData] ;
        personInfoDictionary = [[NSDictionary alloc] initWithDictionary:[entity dataItem:0]];
        [self refreshViewWithNetData];
    }];
    [request setFailedBlock:^{
        [BWStatusBarOverlay showMessage:@"获取个人信息失败" duration:1 animated:1];
        NSString* sql =[NSString stringWithFormat:
                        @"SELECT E.CNAME,E.MOBILE,E.EMAIL,E.MOBILE,E.SHORTPHONE,E.TELEPHONE,E.TNAME,E.OFFICEADDRESS,U.CNAME UCNAME,U.PNAME\
                        FROM T_UNIT U LEFT JOIN T_EMPLOYEE E\
                        ON U.DPID = E.DPID\
                        WHERE E.UID = '%@';",[APPUtils userUid]];
        personInfoDictionary = [[NSDictionary alloc] initWithDictionary:[[[DBQueue sharedbQueue] recordFromTableBySQL:sql] objectAtIndex:0]];
        [self refreshViewWithLocalData];
    }];
    [request startAsynchronous];
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
    
    //添加键盘监视通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    SKSToolBar* myToolBar = [[SKSToolBar alloc] initWithFrame:CGRectMake(0, 0, 320, 49)];
    [myToolBar.homeButton addTarget:self action:@selector(backToRoot:) forControlEvents:UIControlEventTouchUpInside];
    [myToolBar.firstButton addTarget:self action:@selector(savePersonInfoToServer) forControlEvents:UIControlEventTouchUpInside];
    [myToolBar.secondButton addTarget:self action:@selector(getUserInfoFromServer) forControlEvents:UIControlEventTouchUpInside];
    [myToolBar setFirstItem:@"btn_save_ecm" Title:@"保存"];
    [myToolBar setSecondItem:@"btn_refresh_ecm" Title:@"刷新"];
    [toolVIew addSubview:myToolBar];
    
    [mobileTextField.internalTextView setKeyboardType:UIKeyboardTypeNumberPad];
    [mobileTextField setDelegate:self];
    //[mobileTextField setMaxNumberOfLines:1];
    
    [telephoneTextField.internalTextView setKeyboardType:UIKeyboardTypeNumberPad];
    [telephoneTextField setDelegate:self];
    //[telephoneTextField setMaxNumberOfLines:1];
    
    [shortPhoneTextField.internalTextView setKeyboardType:UIKeyboardTypeNumberPad];
    [shortPhoneTextField setDelegate:self];
    //[shortPhoneTextField setMaxNumberOfLines:1];
    
    [officeAddressTextField.internalTextView setKeyboardType:UIKeyboardTypeDefault];
    [officeAddressTextField setDelegate:self];
    //[officeAddressTextField setMaxNumberOfLines:1];
    
    
    [self roundTextView:mobileTextField];
    [self roundTextView:telephoneTextField];
    [self roundTextView:shortPhoneTextField];
    [self roundTextView:officeAddressTextField];
    
    //键盘toolBar--------------------------
    previousBtn=[[UIBarButtonItem alloc] initWithTitle:@"上一项" style:UIBarButtonItemStyleBordered target:self action:@selector(previousText)];
    nextBtn=[[UIBarButtonItem alloc] initWithTitle:@"下一项" style:UIBarButtonItemStyleBordered target:self action:@selector(nextText)];
    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    doneBtn=[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(doneTextEditing)];
    textToolBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, BottomY, 320, 44)];
    [textToolBar setItems:[NSArray arrayWithObjects:previousBtn,nextBtn,flexibleSpaceItem,doneBtn,nil]];
    if (System_Version_Small_Than_(7)) {
        [textToolBar setBarStyle:UIBarStyleBlackTranslucent];
    }
    [self.view addSubview:textToolBar];
    
    [self getUserInfoFromServer];
}

-(BOOL)validate
{
    if ([mobileTextField.text isEqualToString:@""])
    {
        [mobileTextField becomeFirstResponder];
        return NO;
    }
    else if([officeAddressTextField.text isEqualToString:@""])
    {
        [officeAddressTextField becomeFirstResponder];
        return NO;
    }
    else if([telephoneTextField.text isEqualToString:@""])
    {
        [telephoneTextField becomeFirstResponder];
        return NO;
    }
    return YES;
}

-(void)savePersonInfoToServer
{
    
    if (![self validate]) {
        return;
    }
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/userinfo/update",ZZZobt]];
    SKFormDataRequest *savePersonInfoRequest = [SKFormDataRequest requestWithURL:url];
    [savePersonInfoRequest setPostValue:[APPUtils userUid] forKey:@"userid"];
    [savePersonInfoRequest setPostValue:mobileTextField.text forKey:@"mobile"];
    [savePersonInfoRequest setPostValue:shortPhoneTextField.text forKey:@"shortPhone"];
    [savePersonInfoRequest setPostValue:telephoneTextField.text forKey:@"telephone"];
    [savePersonInfoRequest setPostValue:officeAddressTextField.text forKey:@"officeAddress"];
    __weak SKFormDataRequest *req = savePersonInfoRequest;
    [savePersonInfoRequest setCompletionBlock:^{
        if (req.responseStatusCode == 500){
            [BWStatusBarOverlay showErrorWithMessage:@"网络异常请联系供应商" duration:1 animated:1];
        }
        if ([[req responseString] isEqualToString:@"OK"]) {
            [BWStatusBarOverlay showSuccessWithMessage:@"保存成功" duration:1 animated:1];
        }else{
            [BWStatusBarOverlay showErrorWithMessage:@"服务器异常" duration:1 animated:1];
        }
    }];
    [savePersonInfoRequest setFailedBlock:^{
        NSError *error = [req error];
        [BWStatusBarOverlay showErrorWithMessage:[NetUtils userInfoWhenRequestOccurError:error] duration:1 animated:1];
    }];
    [savePersonInfoRequest startAsynchronous];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect toolbarFrame=textToolBar.frame;
    toolbarFrame.origin.y=BottomY;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [textToolBar setFrame:toolbarFrame];
    [mainScrollView setContentOffset:CGPointMake(0,0) animated:YES];
    [UIView commitAnimations];
}

-(void)keyboardWillShow:(NSNotification *)note
{
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    keyboardHeight=keyboardBounds.size.height;
    CGRect toolbarFrame=textToolBar.frame;
    toolbarFrame.origin.y=BottomY -  keyboardHeight - 44;
    [self setToolBarItemEnable];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [textToolBar setFrame:toolbarFrame];
    [UIView commitAnimations];
}

#pragma mark -textDelegate

-(void)doneTextEditing
{
    [mobileTextField resignFirstResponder];
    [officeAddressTextField resignFirstResponder];
    [telephoneTextField resignFirstResponder];
    [shortPhoneTextField resignFirstResponder];
}

-(void)setToolBarItemEnable
{
    [previousBtn setEnabled:![mobileTextField isFirstResponder]];
    [nextBtn setEnabled:![officeAddressTextField isFirstResponder]];
}

//上一项
-(void)previousText
{
    if ([mobileTextField isFirstResponder])
    {
        return;
    }
    else if([shortPhoneTextField isFirstResponder])
    {
        [mobileTextField becomeFirstResponder];
    }
    else if([telephoneTextField isFirstResponder])
    {
        [shortPhoneTextField becomeFirstResponder];
    }
    else if([officeAddressTextField isFirstResponder])
    {
        [telephoneTextField becomeFirstResponder];
    }
    
    [self setToolBarItemEnable];
}
//下一项
-(void)nextText
{
    if ([mobileTextField isFirstResponder])
    {
        [shortPhoneTextField becomeFirstResponder];
    }
    else if([shortPhoneTextField isFirstResponder])
    {
        [telephoneTextField becomeFirstResponder];
    }
    else if([telephoneTextField isFirstResponder])
    {
        [officeAddressTextField becomeFirstResponder];
    }
    else if([officeAddressTextField isFirstResponder])
    {
        return;
    }
    [self setToolBarItemEnable];
}

-(void)setScrollViewOffsetWithTextView:(HPGrowingTextView *)textView
{
    if(textView==officeAddressTextField)
    {
        [mainScrollView setContentOffset:CGPointMake(0,205) animated:YES];
    }else if(textView==mobileTextField){
        [mainScrollView setContentOffset:CGPointMake(0,35) animated:YES];
    }else if(textView==shortPhoneTextField){
        [mainScrollView setContentOffset:CGPointMake(0,90) animated:YES];
    } else if(textView==telephoneTextField){
        [mainScrollView setContentOffset:CGPointMake(0,150) animated:YES];
    }
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    if (IS_IPHONE_5){
        if(growingTextView==officeAddressTextField)
        {
            [mainScrollView setContentOffset:CGPointMake(0,120) animated:YES];
        }else if(growingTextView==telephoneTextField){
            [mainScrollView setContentOffset:CGPointMake(0,60) animated:YES];
        }
    }else{
        [self setScrollViewOffsetWithTextView:growingTextView];
    }
    
    TextDownView *tdView;
    if (growingTextView.textDownView)
    {
        tdView=growingTextView.textDownView;
    }
    else
    {
        tdView=[[TextDownView alloc] init];
        CGRect tdRect=[tdView frame];
        tdRect.origin.y=CGRectGetMaxY(growingTextView.frame)-3;
        tdRect.origin.x=growingTextView.frame.origin.x;
        tdRect.size.width=150;
        tdRect.size.height=20;
        tdView.frame=tdRect;
        
        CGRect labelRect=[tdView.noticeLabel frame];
        labelRect.size.width=135;
        
        tdView.noticeLabel.frame=labelRect;
        
        tdView.noticeLabel.font=[UIFont systemFontOfSize:12];
        [mainScrollView addSubview:tdView];
        growingTextView.textDownView=tdView;
    }
    [tdView setHidden:NO];
    if(growingTextView==mobileTextField)
    {
        tdView.noticeLabel.text=@"请输入移动电话号码";
    }
    else if(growingTextView==shortPhoneTextField)
    {
        tdView.noticeLabel.text=@"请输入短号";
    }
    else if(growingTextView==telephoneTextField)
    {
        tdView.noticeLabel.text=@"请输入办公电话";
    }
    else
    {
        tdView.noticeLabel.text=@"请输入办公地址";
    }
    [tdView.flagImage setImage:[UIImage imageNamed:@"warning.png"]];
    [tdView.noticeLabel setTextColor:[UIColor colorWithRed:0/255.0  green:89.0/255.0 blue:175.0/255.0 alpha:1]];
    return YES;
}

-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    [self setToolBarItemEnable];
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView
{
    TextDownView *tdView=growingTextView.textDownView;
    [tdView setHidden:NO];
    if(growingTextView==mobileTextField)
    {
        if ([growingTextView.text isEqualToString:@""])
        {
            tdView.noticeLabel.text=@"必须填写电话号码!";
            
        }
        else
        {
            [tdView setHidden:YES];
        }
    }
    else if(growingTextView==shortPhoneTextField)
    {
        
        [tdView setHidden:YES];
        
    }
    else if(growingTextView==telephoneTextField)
    {
        if ([growingTextView.text isEqualToString:@""])
        {
            tdView.noticeLabel.text=@"必须填写办公电话!";
        }
        else
        {
            [tdView setHidden:YES];
        }
    }
    else if(growingTextView==officeAddressTextField)
    {
        if ([growingTextView.text isEqualToString:@""])
        {
            tdView.noticeLabel.text=@"必须填写办公地址!";
        }
        else
        {
            [tdView setHidden:YES];
        }
    }
    [tdView.flagImage setImage:[UIImage imageNamed:@"error.png"]];
    [tdView.noticeLabel setTextColor:[UIColor redColor]];
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    if ((int)diff <= 0) return;
    changeHeight+=diff;
    CGSize size = mainScrollView.contentSize;
    size.height-=diff;
    mainScrollView.contentSize=size;
    
    CGRect tRect=growingTextView.textDownView.frame;
    tRect.origin.y-=diff;
    growingTextView.textDownView.frame=tRect;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    NSInteger number = [growingTextView.text length];
    
    if (growingTextView!=officeAddressTextField)
    {
        if (number > 19)
        {
            growingTextView.text = [growingTextView.text substringToIndex:19];
            //number = 40;
        }
    }else
    {
        if (number > 40)
        {
            growingTextView.text = [growingTextView.text substringToIndex:40];
            //number = 40;
        }
    }
}

@end
