//
//  JSWebView.h
//    oc & js 互操作JSWebView类
//
//  Created by tabu on 15/8/26.
//  Copyright (c) 2015年 tabu. All rights reserved.
//
//
//  Sample code:
//    @interface JSWebViewController ()<JSWebViewInvokeHandler>
//
//    @property (weak, nonatomic) IBOutlet JSWebView *webView;
//    @property (strong, nonatomic) NSString* textValue;
//
//    @end
//
//
//    @implementation JSWebViewController
//
//    - (void)viewDidLoad {
//        [super viewDidLoad];
//        
//        self.textValue = @"sample";
//        
//        NSURL*  url = [NSURL URLWithString:@"http://localhost:3000"];
//
//        [self.webView registerInvokeHandler:self]; // 注册js接口实现
//        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
//    }
//
//    #pragma mark - <JSWebViewInvokeHandler>
//
//    - (NSDictionary*)js_getValue:(NSDictionary*)userInfo error:(NSError**)error{
//        return @{@"value": self.textValue};
//    }
//
//    - (void)js_setValue:(NSDictionary*)userInfo error:(NSError**)error{
//        self.textValue = userInfo[@"value"];
//        //return @{};
//    }
//
//    @end
//


#import <UIKit/UIKit.h>


/**
 *  js 接口实现协议
 */
@protocol JSWebViewInvokeHandler <NSObject>
@optional

/**
 *  js调用本地接口名称映射，函数名默认js调用的method前加js_, 如果映射其他名称的本地函数，实现该接口
 *
 *  @param webView
 *  @param method  web页面调用的函数名称，如：getToken，默认映射为js_getToken
 *
 *  @return 对应本地方法名
 */
- (NSString*)jsWebView:(UIWebView *)webView mapMethod:(NSString*)method;

/**
 *  具有返回值的js接口
 *  js端调用
 *  window.external.invoke("getToken", //默认映射为js_getToken
 *                         { }//映射为userInfo,
 *                         function(status, 
 *                             result // js_getToken的返回值
 *                         ){});
 *
 *  @param userInfo 从js页面传递过来的json数据，各个接口统一协商
 *  @param error    函数执行错误信息
 *
 *  @return 返回给js端的数据，如果无返回值可用void
 */
//- (NSDictionary*)js_getToken:(NSDictionary*)userInfo error:(NSError**)error;

@end


/**
 *  支持js互操作的WebView
 */
@interface JSWebView : UIWebView

@property(weak, nonatomic) id<UIWebViewDelegate> delegate;

/**
 *  注册实现js接口类
 *
 *  @param handle js接口服务类
 */
- (void)registerInvokeHandler:(id<JSWebViewInvokeHandler>)handle;

@end
