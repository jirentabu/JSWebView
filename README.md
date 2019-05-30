# JSWebView Control

简化、统一javascript & objc本地代码间互操作，便于维护和后期扩展

## 特性
* javascript调用Object-c本地代码

* 统一的参数传递(json)

* 方便扩展新的接口供javascript调用

* 模块化实现接口，javascript接口可以在多个业务对象中实现，根据页面需求注册

## 使用

### Objective-C


1. 项目中添加JSWebView文件夹

2. 引用头文件
```Objective-C
#import "JSWebView.h"
```
3. ViewController中添加JSWebView，与添加UIWebView一致

4. ViewController实现JSWebViewInvokeHandler协议
```Objective-C
@interface ViewController ()<JSWebViewInvokeHandler>

@end
```

5. ViewController.m的viewDidLoad中注册
```Objective-C
[self.webView registerInvokeHandler:self];
```

6. ViewController.m添加javascript调用接口
```Objective-C
#pragma mark - <JSWebViewInvokeHandler>

- (NSDictionary*)js_getValue:(NSDictionary*)userInfo error:(NSError**)error{
    return @{@"value": self.textValue};
}
```

### javascript

1. 页面中引用ios.invoke.js
```javascript
<script src="/public/js/ios.invoke.js" type="text/javascript" charset="utf-8"></script>
```

2. 调用objc函数
```javascript
$("#btn_get").click(function(){
	window.external.invoke("getValue", {}, function(status, result){
		if(status == 200){
			$("#data").val(result["value"]);
		}else{
			alert("get value error.");
		}
	});
});
```
