//
//  WebViewController.h
//  newBeauty
//
//  Created by air on 2018/1/12.
//  Copyright © 2018年 com.xinfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CoreLocation/CoreLocation.h>


@interface WebViewController : UIViewController<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *_webParent;
@property (nonatomic, strong) CLLocationManager *manager;

-(void)initWebview;
@end
