//
//  ViewController.h
//  newBeauty
//
//  Created by air on 2018/1/12.
//  Copyright © 2018年 com.xinfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ViewController : UIViewController<WKNavigationDelegate,WKScriptMessageHandler>
@property(strong,nonatomic)NSString *contentUrl;
@property(strong,nonatomic)NSString *isHead;

-(void)initWebview:(NSString *) url;
-(void)goBackSelf:(UIButton*)sender;
@end


