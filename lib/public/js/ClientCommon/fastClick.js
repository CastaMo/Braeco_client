/*
 * @author: CastaMo
 * @last-edit-date: 2016-07-19
 * @depend: none
 *
 */

(function(win, doc) {

	'use strict';

	// ----------------------------------------- 辅助函数 start-------------------------------------------------

	//通过惰性加载优化判断
	var addListener, removeListener;

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

	// ----------------------------------------- 辅助函数 end-------------------------------------------------


	function fastClick(el, fn) {
		var clickFlag = true,
			target;
		addListener(el, "touchstart", function(e) {
			e = e || window.event
			target = e.target || e.srcElement;
			e.stopPropagation();
			clickFlag = true;
			return false;
		});
		addListener(el, "touchmove", function(e) {
			e.stopPropagation();
			clickFlag = false;
			return false;
		});
		addListener(el, "touchend", function(e) {
			e.stopPropagation();
			if (clickFlag) {
				if (typeof fn === "function") {
					fn(target);
				}
			}
			return false;
		});
	}
	win.fastClick = fastClick;

})(window, document, undefined);
