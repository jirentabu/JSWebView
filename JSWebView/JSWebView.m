//
//  JSWebView.m
//
//  Created by tabu on 15/8/26.
//  Copyright (c) 2015年 tabu. All rights reserved.
//

#import "JSWebView.h"
#import "NSDictionary+QueryString.h"
#import <objc/message.h>


@interface JSWebView()<UIWebViewDelegate>
{
    __weak id<UIWebViewDelegate> _jsdelegate;
}

@property (nonatomic, strong) NSMutableArray* handlers; //array of id<JSWebViewInvokeHandler>

@end

@implementation JSWebView

@synthesize delegate = _jsdelegate;

#pragma mark - Lifecyle

- (instancetype)init{
    self = [super init];
    if(self){
        [self __init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self __init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self __init];
    }
    return self;
}

- (void)__init{
    [super setDelegate:self];
    self.handlers = [[NSMutableArray alloc] init];
}

#pragma mark - Invoke Call

- (void)registerInvokeHandler:(id<JSWebViewInvokeHandler>)handle{
    NSValue* value = [NSValue valueWithNonretainedObject:handle];
    [self.handlers addObject:value];
}

- (void)dynamicCallHandler:(id<JSWebViewInvokeHandler>)handler selector:(SEL)selector reqid:(NSNumber*)reqid args:(NSDictionary*)userInfo{
    NSError* error = nil;
    
    // use 64 bit
    NSDictionary* (*action)(id, SEL, NSDictionary*, NSError**) = (NSDictionary* (*)(id, SEL, NSDictionary*, NSError**)) objc_msgSend;
    
    NSDictionary* result = action(handler, selector, userInfo, &error);
    if (result == nil) {
        result = @{};
    }
    
    if (error != nil) {
        [self replyRequest:[reqid integerValue] status:500 result:result];
    }else{
        [self replyRequest:[reqid integerValue] status:200 result:result];
    }
}

- (void)replyRequest:(NSInteger)reqId status:(NSInteger)status result:(NSDictionary*)result{
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonString = @"{}";
    if(jsonData){
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSString* script = [NSString stringWithFormat:@"window.external.__invoke_callback(%ld, %ld, %@)", (long)reqId, (long)status, jsonString];
    [self stringByEvaluatingJavaScriptFromString: script];
}

#pragma mark - <UIWebViewDelegate>

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    BOOL result = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        result = [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    if(!result) return NO;
    
    
    // filter by schema 'native'
    if ([request.URL.scheme isEqualToString:@"native"]) {
        NSDictionary* queryParams = [NSDictionary dictionaryWithFormEncodedString:request.URL.query];
        
        NSString* method = queryParams[@"method"];
        NSNumber* reqid  = queryParams[@"reqid"];
        NSString* args   = queryParams[@"args"];
        NSError* error   = nil;
        
        if (method.length == 0 || reqid == nil || args == nil) {
            NSAssert(false, @"bad request args.");
            [self replyRequest:[reqid integerValue] status:400 result:@{}];
            return NO;
        }
        
        // deserialization request args
        NSDictionary* userInfo = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:[args dataUsingEncoding:NSUTF8StringEncoding]
                                                                                options:NSJSONReadingMutableContainers
                                                                                  error:&error];
        if(error != nil){ // bad request
            NSLog(@"jsWebView error = %@", error);
            [self replyRequest:[reqid integerValue] status:400 result:@{}];
            return NO;
        }
        
        // default selector name
        NSString* selectorName = [NSString stringWithFormat:@"js_%@", method];
        for (NSInteger i = self.handlers.count - 1; i >= 0; --i) { // 注册顺序反向调用，相同方法后注册的覆盖前面的
            NSValue* weakHandle = [self.handlers objectAtIndex:i];
            id<JSWebViewInvokeHandler> handler = weakHandle.pointerValue;
            NSString* mapedSelectorName = selectorName;
            if ([handler respondsToSelector:@selector(jsWebView:mapMethod:)]) {
                mapedSelectorName = [handler jsWebView:self mapMethod:method];
            }
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:error:", mapedSelectorName]);
            if ([handler respondsToSelector:selector]) {
                [self dynamicCallHandler:handler selector:selector reqid:reqid args:userInfo];
                return NO;
            }
        }
        
        NSAssert(false, @"not found js invoke method.", method, args);
        // not found interface.
        [self replyRequest:[reqid integerValue] status:404 result:@{}];
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
}

@end
