/**
 * js 与oc互操作模块，请在互操作的页面中引用此文件
 * @authors tabu (jirentabu@outlook.com)
 * @date    2015-08-26 11:24:19
 * @version $Id$
 * @sample code:
   window.external.invoke("getValue", {}, function(status, result){
		if(status == 200){
			// do somthing ..
            alert(result["value"]);
		}else{
			// error
		}
	});
 */

var nativeInvoker = {
	createNew: function(){
		var instance = {};	
		instance._requestId = 0;
		instance._requestQueue = new Array();

		instance.invoke = function (method, args, callback) {
			var req = {
				"reqid": this._requestId++,
				"method": 	 method,
				"callback":  callback,
				"args": args,
			};

			this._requestQueue.push(req);
			var jsonString = JSON.stringify(args);
			// iOS7 不支持webkit接口，用location的方式发送request，本地应用拦截相应reqeust转换为本地代码调用，
			document.location.href = "native://localhost?method="+ method +"&reqid=" + parseInt(req["reqid"]) + "&args=" + escape(jsonString);
		}

		instance.__invoke_callback = function(reqid, status, result){
			var index = -1;
			for(var i = 0;i < this._requestQueue.length;i++){
				var req = this._requestQueue[i];
				if(req.reqid == reqid){
					var fun = req["callback"];
					fun(status, result);	
					index = i;
					break;
				}
			}
			if(index >= 0){
				for(var i = index;i < this._requestQueue.length - 1;i++){
					this._requestQueue[i] = this._requestQueue[i + 1];
				}
				this._requestQueue.length -= 1;
			}else{
				alert("not found reqid = " + parseInt(reqid));
			}
		}

		return instance;
	}
};

// add external
window.external = nativeInvoker.createNew();
