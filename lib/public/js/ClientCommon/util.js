;var util = function(doc, undefined) {
	'use strict';
	var addListener = null,
		removeListener = null,
		hasClass,
		addClass,
		removeClass,
		ajax,
		getElementsByClassName,
		isPhone,
		hidePhone,
		query,
		querys,
		remove,
		append,
		prepend,
		toggleClass,
		getObjectURL,
		is,
		deepCopy,
		getById,
		createDom,
		getJSON,
		getAdaptHeight,
		findParent;
	if (typeof window.addEventListener === 'function') {
		addListener = function(el, type, fn) {
			el.addEventListener(type, fn, false);
		};
		removeListener = function(el, type, fn) {
			el.removeEventListener(type, fn, false);
		};
	} else if (typeof doc.attachEvent === 'function') {  //'IE'
		addListener = function(el, type, fn) {
			el.attachEvent('on'+type, fn);
		};
		removeListener = function(el, type, fn) {
			el.detachEvent('on'+type, fn);
		};
	} else {
		addListener = function(el, type, fn) {
			el['on'+type] = fn;
		};
		removeListener = function(el, type, fn) {
			el['on'+type] = null;
		};
	}

	hasClass = function(ele, cls) {
		var className, reg;
		reg = new RegExp('(\\s|^)' + cls + '(\\s|$)');
		className = ele.getAttribute("class") ? ele.className : "";
		return reg.test(className);
	};

	addClass = function(ele, cls) {
		if (!ele || hasClass(ele, cls)) {
			return (ele.className ? ele.className : "");
		}
		if (ele.className) {
			return (ele.className += ' ' + cls);
		} else {
			return (ele.className = cls);
		}
	};

	removeClass = function(ele, cls) {
		if (!ele) {
			return ele.className ? ele.className : "";
		}
		var reg = new RegExp("(\\s|^)" + cls + "(\\s|$)");
		return (ele.className = ele.className.replace(reg, " ").replace(/(^\s*)|(\s*$)/g, ""));
	}

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
	}

	ajax = function(options) {
		var xhr;
		if (window.XMLHttpRequest) {
			xhr = new XMLHttpRequest();
		} else {	//for IE6
			xhr = new ActiveXObject('Microsoft.XMLHTTP');
		}
		xhr.onreadystatechange = function() {
			callback(xhr, {
				success			: 		options.success,
				always 			: 		options.always,
				unavailabled	: 		options.unavailabled
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
	}

	getElementsByClassName = function(tagName, className) {
		var result = [];
		var allTag = doc.getElementsByTagName(tagName);
		for (var i = 0, len_ = allTag.length; i < len_; i++) {
			if (hasClass(allTag[i], className)) {
				result.push(allTag[i]);
			}
		}
		return result;
	}

	isPhone = function (aPhone) {
		return RegExp(/^(0|86|17951)?(13[0-9]|15[012356789]|18[0-9]|14[57]|17[0-9])[0-9]{8}$/).test(aPhone);
    }

    hidePhone = function(number) {
    	return number.substr(0, 3)+"****"+number.substr(7, 4);
    }

    query = function(string, parentNode) {
    	if (parentNode) {
    		return parentNode.querySelector(string);
    	} else {
    		return doc.querySelector(string);
    	}
    }

    querys = function(string, parentNode) {
    	if (parentNode) {
    		return parentNode.querySelectorAll(string);
    	} else {
    		return doc.querySelectorAll(string);
    	}
    }

    remove = function(childNode) {
    	var parentNode = childNode.parentNode;
    	return parentNode.removeChild(childNode);
    }

    append = function(parentNode, childNode) {
    	if (typeof childNode === "string") {
    		var previousHTML = parentNode.innerHTML;
    		return parentNode.innerHTML = previousHTML + childNode;
    	} else {
    		return parentNode.appendChild(childNode);
    	}
    }

    prepend = function(parentNode, childNode) {
    	if (typeof childNode === "string") {
    		var previousHTML = parentNode.innerHTML;
    		return parentNode.innerHTML = childNode + previousHTML;
    	} else {
    		var reforeNode = parentNode.children[0];
    		parentNode.insertBefore(childNode, reforeNode);
    	}
    }

    toggleClass = function(ele, cls) {
    	if (hasClass(ele, cls)) {
    		return removeClass(ele, cls);
    	} else {
    		return addClass(ele, cls);
    	}
    }

    getObjectURL = function(file) {
    	var url = null;
	    if (window.createObjectURL !== undefined) { // basic
	        url = window.createObjectURL(file);
	    } else if (window.URL !== undefined) { // mozilla(firefox)
	        url = window.URL.createObjectURL(file);
	    } else if (window.webkitURL !== undefined) { // webkit or chrome
	        url = window.webkitURL.createObjectURL(file);
	    }
	    return url;
    }

    is = function(obj, type) {
    	var toString = Object.prototype.toString;
    	return (type === 'Null' && obj == null) ||
    		(type == "Undefined" && Object === undefined) ||
    		toString.call(obj).slice(8, -1) === type;
    }

    deepCopy = function(oldObj, newObj) {
    	for (var key in oldObj) {
	        var copy = oldObj[key];
	        if (oldObj === copy) continue; //如window.window === window，会陷入死循环，需要处理一下
	        if (is(copy, "Object")) {
	            newObj[key] = deepCopy(copy, newObj[key] || {});
	        } else if (is(copy, "Array")) {
	            newObj[key] = []
	            newObj[key] = deepCopy(copy, newObj[key] || []);
	        } else {
	            newObj[key] = copy;
	        }
	    }
	    return newObj;
    }

    getById = function(id) {
    	return doc.getElementById(id);
    }

    createDom = function(tagName) {
    	return document.createElement(tagName);
    }

    getJSON = function(json) {
    	if (typeof json === "string"&&json) {
    		json = JSON.parse(json)
    	}
    	return json
    }

    getAdaptHeight = function(currentDom, previousDom, currentExtra, previousExtra) {
    	var currentHeight = currentDom.getBoundingClientRect().height;
    	var previousHeight = previousDom.getBoundingClientRect().height;
    	if (currentExtra !== undefined) {
    		currentHeight += currentExtra;
    	}
    	if (previousExtra !== undefined) {
    		previousHeight += previousExtra;
    	}
    	return Math.max(currentHeight, previousHeight);
    }

    findParent = function(childNode, filter) {
    	var parentNode = childNode;
    	while (parentNode && (!filter(parentNode))) {
    		parentNode = parentNode.parentNode;
			if (parentNode === document) {
				return null;
			}
    	}
    	return parentNode;
    }

	return {
		addListener:addListener,
		removeListener:removeListener,
		hasClass:hasClass,
		addClass:addClass,
		removeClass:removeClass,
		ajax:ajax,
		getElementsByClassName:getElementsByClassName,
		isPhone:isPhone,
		hidePhone:hidePhone,
		query:query,
		querys:querys,
		remove:remove,
		append:append,
		prepend:prepend,
		toggleClass:toggleClass,
		getObjectURL:getObjectURL,
		is:is,
		deepCopy:deepCopy,
		getById:getById,
		createDom: createDom,
		getJSON: getJSON,
		getAdaptHeight: getAdaptHeight,
		findParent: findParent
	};
}(document);
