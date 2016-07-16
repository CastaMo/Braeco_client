	(function(win, doc, undefined) {
		function callback(xhr, options) {
			if (xhr.readyState === 4) {
				if (typeof options.always === "function") {
					options.always();
				}
				if (xhr.status === 200) {
					if (typeof options.success === "function") {
						var result = xhr.responseText;
						options.success(result);
					}
				}
				else if (xhr.status === 503) {
					if (typeof options.unavailabled === "function") {
						options.unavailabled();
					} else {
						alert("操作过于频繁, 请稍后重试");
					}
				}
			}
		};

		var ajax = function(options) {
			var xhr;
			if (window.XMLHttpRequest) {
				xhr = new XMLHttpRequest();
			} else {	//for IE6
				xhr = new ActiveXObject('Microsoft.XMLHTTP');
			}
			xhr.onreadystatechange = function() {
				callback(xhr, {
					success			: 		options.success,
					always 			: 		options.always
				});
			}
			xhr.open(options.type, options.url, options.async);
			if (options.type.toUpperCase() === "POST") {
				xhr.setRequestHeader("Content-type","application/json");
			}
			if (typeof options.data !== "undefined") {
				xhr.send(options.data);
			} else {
				xhr.send();
			}
			return xhr;
		};

		function addStaticData(url, integrateData) {
			integrateData.signal++;
			integrateData.requireQueue.push(function() {
				var script = doc.createElement("script");
				script.src = url;
				script.async = "async";
				script.type = "text/javascript";
				doc.head.appendChild(script);
			});
		};

		function addDynamicData(url, integrateData) {
			integrateData.signal++;
			integrateData.requireQueue.push(function() {
				ajax({
					type 		: 	"POST",
					url 		: 	url,
					async 	: 	true,
					success : 	function(result_) {
						onDataCallback(result_, integrateData);
					}
				});
			});
		}

		function startRequire(integrateData) {
			var requireQueue = integrateData.requireQueue;
			for (var i = 0, len = requireQueue.length; i < len; i++) {
				var ref = requireQueue[i];
				if (typeof ref === "function") {
					ref();
				}
			}
		}

		var onDataCallback = function(result_, integrateData) {

			function dataIsReady(integrateData) {
				return integrateData.signal === 0;
			}

			function dataReadyCallback(integrateData){
				var mainInitBydata = win.mainInitBydata;
				if (typeof mainInitBydata === "function") {
					mainInitBydata(integrateData);
				}
			}

			if (dataIsReady(integrateData)) {
				alert("非法请求");
				return;
			}
			integrateData.signal--;
			var result = result_;
			if (typeof result_ === "string") {
				result = JSON.parse(result_);
			}
			if (result.message === "success") {
				var data = result.data;
				for (var key in data) {
					integrateData.data[key] = data[key];
				}
			}
			if (dataIsReady(integrateData)) {
				dataReadyCallback(integrateData);
			}
		}

		var integrateData = {data:{}, signal:0, requireQueue: []};
		win.integrateData = integrateData;
		win.onDataCallback = onDataCallback;

		addStaticData("/Table/Dinner", integrateData);
		addDynamicData("/Table/Member", integrateData);
		addDynamicData("/Table/Limit", integrateData);
		addDynamicData("/Table/Coupon", integrateData);

		startRequire(integrateData);


	})(window, document);

	(function(win) {
		var result = 'php_str';
		var integrateData = win.integrateData || (win.integrateData = {data: {}, signal: 4});
		var onDataCallback = win.onDataCallback || (win.onDataCallback = function(result_, integrateData) {
			function dataIsReady(integrateData) {
				return integrateData.signal === 0;
			}

			function dataReadyCallback(integrateData){
				var mainInitBydata = win.mainInitBydata;
				if (typeof mainInitBydata === "function") {
					mainInitBydata(integrateData);
				}
			}

			if (dataIsReady(integrateData)) {
				alert("非法请求");
				return;
			}
			integrateData.signal--;
			var result = result_;
			if (typeof result_ === "string") {
				result = JSON.parse(result_);
			}
			if (result.message === "success") {
				var data = result.data;
				for (var key in data) {
					integrateData.data[key] = data[key];
				}
			}
			if (dataIsReady(integrateData)) {
				dataReadyCallback(integrateData);
			}
		});
		onDataCallback(result, integrateData);
	})(window);