//
//  ViewController.m
//  JSWebViewDemo
//
//  Created by tabu on 15/9/1.
//  Copyright (c) 2015年 tabu. All rights reserved.
//

#import "ViewController.h"
#import "JSWebView.h"


@interface ViewController ()<JSWebViewInvokeHandler>
@property (weak, nonatomic) IBOutlet JSWebView *webView;
@property (strong, nonatomic) NSString* textValue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textValue = @"object-c";
    
    // register javascript handlers
    // [self.webView registerInvokeHandler:[GlobalJsHandler sharedInstance]];
    [self.webView registerInvokeHandler:self];
    
    // load url
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:3000"]]];
}

#pragma mark - <JSWebViewInvokeHandler>

- (NSDictionary*)js_getValue:(NSDictionary*)userInfo error:(NSError**)error{
    return @{@"value": self.textValue};
}

- (void)js_setValue:(NSDictionary*)userInfo error:(NSError**)error{
    self.textValue = userInfo[@"value"];
    //return @{};
}

@end
