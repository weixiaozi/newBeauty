//
//  ViewController.m
//  newBeauty
//
//  Created by air on 2018/1/12.
//  Copyright © 2018年 com.xinfeng. All rights reserved.
//

#import "ViewController.h"
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>
#import "LLGifView.h"

@interface ViewController ()

@end

@implementation ViewController{
    @private WKWebView *webView;
    @private UIView *loadParent;
    @private LLGifView *loadingImage;
    @private UIView *tryAgainParent;
    @private NSString *method;
    @private NSURLRequest * request;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate=self;
    UIView *statusBarView = [[UIView alloc]   initWithFrame:CGRectMake(0, 0,    self.view.bounds.size.width, 20)];
    statusBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:statusBarView];

    [self initWebview];
    [self initLoadView];
    [self openEmpty:true];
    
}

-(void)initLoadView{
    loadParent=[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [loadParent setBackgroundColor:[UIColor whiteColor]];
    //加载动画
    NSData *localData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"loadings" ofType:@"gif"]];
    loadingImage = [[LLGifView alloc] initWithFrame:CGRectMake(0,0,0,0) data:localData];
    CGRect frame=loadingImage.frame;
    frame.size=CGSizeMake(190, 54);
    loadingImage.frame=frame;
    loadingImage.center=CGPointMake((loadParent.frame.size.width)/2,(loadParent.frame.size.height)/3);
    
    //重试布局
    tryAgainParent=[[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    //重试图片
    UIImageView *errorPic=[[UIImageView alloc] init];
    CGRect errorPicFrame=errorPic.frame;
    errorPicFrame.size=CGSizeMake(50, 50);
    errorPic.frame=errorPicFrame;
    errorPic.center=CGPointMake((loadParent.frame.size.width)/2,(loadParent.frame.size.height)/3);
    [errorPic setImage:[UIImage imageNamed:@"no_wifi.png"]];
    [tryAgainParent addSubview:errorPic];
    
    //重试描述
    UILabel *errorDes=[[UILabel alloc]init];
    errorDes.textColor=[UIColor grayColor];
    errorDes.textAlignment=NSTextAlignmentCenter;
    CGRect errorDesFrame=errorPic.frame;
    errorDesFrame.size=CGSizeMake(200, 80);
    errorDes.frame=errorDesFrame;
    errorDes.center=CGPointMake((loadParent.frame.size.width)/2,(loadParent.frame.size.height)/3+50);
    errorDes.text=@"网络异常";
    [tryAgainParent addSubview:errorDes];
    
    //重试按钮
    UIButton *errorButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect errorButtonFrame= errorButton.frame;
    errorButtonFrame.size=CGSizeMake(70, 40);
    errorButton.frame=errorButtonFrame;
    [errorButton setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    [errorButton.layer setMasksToBounds:YES];
    [errorButton.layer setCornerRadius:5.0];
    errorButton.center=CGPointMake((loadParent.frame.size.width)/2,(loadParent.frame.size.height)/3+50+40);
    [errorButton setTitle:@"重试" forState:0];
    [errorButton setTitleColor:[UIColor blackColor] forState:0];
    [errorButton addTarget:self action:@selector(webReloadClick:) forControlEvents:UIControlEventTouchUpInside];
    [tryAgainParent addSubview:errorButton];
    
    
    [loadParent addSubview:loadingImage];
    [loadParent addSubview:tryAgainParent];
    [self.view addSubview:loadParent];
    loadParent.hidden=YES;
}
- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


//网页刷新
- (void)webReloadClick:(UIButton *)btn
{
    if(webView!=nil){
        [self openEmpty:true];
        //        [webView reloadFromOrigin];
        [webView loadRequest:request];
    }
    
}
-(void)openEmpty:(Boolean *)isLoading{
    loadParent.hidden=NO;
    if (isLoading) {
        tryAgainParent.hidden=YES;
        loadingImage.hidden=NO;
        [loadingImage startGif];
    }else{
        tryAgainParent.hidden=NO;
        loadingImage.hidden=YES;
        [loadingImage stopGif];
    }
    
}
-(void)closeEmpty{
    loadParent.hidden=YES;
    [loadingImage stopGif];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initWebview{
    
    webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height+([_isHead isEqualToString:@"1"]?44:0), self.view.bounds.size.width, self.view.bounds.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height-[self checkIsIphonex]-([_isHead isEqualToString:@"1"]?44:0))];
    
    webView.navigationDelegate=self;
    webView.UIDelegate=self;
    
    //2.创建URL
    NSURL *URL = [NSURL URLWithString:_contentUrl];
    
    
    //3.创建Request
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request = [[NSURLRequest alloc]initWithURL:URL cachePolicy:0 timeoutInterval:15.0f];
    
    //4.加载Request
    [webView loadRequest:request];
    //5.添加到视图
    //    self.webView = webView;
    [self.view addSubview:webView];
    //    [__webParent addSubview:webView];
    [[webView configuration].userContentController addScriptMessageHandler:self name:@"phonePlus"];
    [[webView configuration].userContentController addScriptMessageHandler:self name:@"OpenAnotherPage"];
     [[webView configuration].userContentController addScriptMessageHandler:self name:@"finishPage"];
    webView.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleBottomMargin;
    

}

-(int) checkIsIphonex{
    
    CGRect rect = [UIScreen mainScreen].bounds;
    CGSize size = rect.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = size.width*scale;
    //    CGFloat height = size.height*scale;
    
    if(width==1125){
        return 34;
    }
    return 0;
    
}
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
        NSLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
    if([message.name isEqualToString:@"phonePlus"]){
        __weak typeof(self) ws=self;
        [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
            [ws startToShare:platformType shareInfo:message.body];

        }];
    }else if ([message.name isEqualToString:@"OpenAnotherPage"]){
        [self openNewPage:message.body];
        
    }else if([message.name isEqualToString:@"finishPage"]){

        [self.navigationController popViewControllerAnimated:YES];

    }

}
-(void)startToShare:(UMSocialPlatformType)platform shareInfo:(NSDictionary *)tempDic {
    
    if (![tempDic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString *title = [tempDic objectForKey:@"title"];
    NSString *desc = [tempDic objectForKey:@"desc"];
    NSString *pic = [tempDic objectForKey:@"pic"];
    NSString *target = [tempDic objectForKey:@"target"];
    
    
    
    UMSocialMessageObject *object=[UMSocialMessageObject messageObject];
    if (platform==UMSocialPlatformType_Sina) {
        object.text = [NSString stringWithFormat:@"%@  %@", desc, target];
        
        UMShareImageObject *shareImageObject = [[UMShareImageObject alloc] init];
        shareImageObject.shareImage = pic;
        
        object.shareObject = shareImageObject;
        
    }else{
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:pic];
        shareObject.webpageUrl=target;
        object.shareObject=shareObject;
    }

    
    [[UMSocialManager defaultManager]shareToPlatform:platform messageObject:object currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            NSLog(@"qqqq************Share fail with error %@*********",error);
        }else{
            NSLog(@"qqqqresponse data is %@",result);
        }

    }];
}

- (void)openNewPage:(NSDictionary *)tempDic
{
    if (![tempDic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    method= [tempDic objectForKey:@"method"];

    NSString *head = [tempDic objectForKey:@"head"];
    NSString *content = [tempDic objectForKey:@"url"];
    
    ViewController *test = [[ViewController alloc] init];
    test.contentUrl=content;
    test.isHead=head;
    [self.navigationController pushViewController:test animated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:![_isHead isEqualToString:@"1"] animated:NO];
    if (method!=nil && ![method isEqualToString:@""]) {
        [webView evaluateJavaScript:method completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            
        }];
        method=nil;
    }
}
-(void)dealloc{
    [[webView configuration].userContentController removeScriptMessageHandlerForName:@"phonePlus"];
    [[webView configuration].userContentController removeScriptMessageHandlerForName:@"OpenAnotherPage"];
    [[webView configuration].userContentController removeScriptMessageHandlerForName:@"finishPage"];
    [loadingImage stopGif];
    [loadingImage removeFromSuperview];
    loadingImage=nil;

}
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    BOOL isHiddenNavBar = [viewController isKindOfClass:[self class]];
    
    [self.navigationController setNavigationBarHidden:![_isHead isEqualToString:@"1"] animated:NO];
    
}

// 页面开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"webview22didStartProvisionalNavigation");
    [self openEmpty:true];
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"webview22didCommitNavigation");
    
}
// 页面加载失败时调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"webview22didFailProvisionalNavigation:%@",error.description);
    [self openEmpty:false];
    
    
}

// 页面加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];
    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    NSLog(@"webview22didfinish");
    [self closeEmpty];
}

@end
