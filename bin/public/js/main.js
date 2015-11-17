var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

(function(window, document) {
  var Activity, Category, Db, HomeBottom, HomeMenu, Lock, addClass, addListener, ajax, allPageManage, append, callpay, clientWidth, compatibleCSSConfig, deepCopy, getById, getElementsByClassName, getObjectURL, hasClass, hashRoute, hidePhone, innerCallback, isPhone, prepend, query, querys, ref, remove, removeClass, removeListener, rotateDisplay, toggleClass;
  ref = [util.addListener, util.removeListener, util.hasClass, util.addClass, util.removeClass, util.ajax, util.getElementsByClassName, util.isPhone, util.hidePhone, util.query, util.querys, util.remove, util.append, util.prepend, util.toggleClass, util.getObjectURL, util.deepCopy, util.getById], addListener = ref[0], removeListener = ref[1], hasClass = ref[2], addClass = ref[3], removeClass = ref[4], ajax = ref[5], getElementsByClassName = ref[6], isPhone = ref[7], hidePhone = ref[8], query = ref[9], querys = ref[10], remove = ref[11], append = ref[12], prepend = ref[13], toggleClass = ref[14], getObjectURL = ref[15], deepCopy = ref[16], getById = ref[17];
  clientWidth = document.body.clientWidth;
  compatibleCSSConfig = ["", "-webkit-", "-moz-", "-ms-", "-o-"];
  allPageManage = (function() {
    var _allDetailDoms, _allDetailId, _allHomeDoms, _allHomeId, _allMainDoms, _hideAllDetailPage, _hideAllHomePage, _hideAllMainPage, _showPage, hideAllPage;
    _allMainDoms = querys(".main-page");
    _allHomeDoms = querys(".main-home-page");
    _allDetailDoms = querys(".main-detail-page");
    _allHomeId = ["Menu-page", "Already-page", "Individual-page"];
    _allDetailId = ["Book-page", "Activity-page"];
    _hideAllMainPage = function() {
      var dom, j, len, results;
      results = [];
      for (j = 0, len = _allMainDoms.length; j < len; j++) {
        dom = _allMainDoms[j];
        results.push(addClass(dom, "hide"));
      }
      return results;
    };
    _hideAllHomePage = function() {
      var dom, j, len, results;
      results = [];
      for (j = 0, len = _allHomeDoms.length; j < len; j++) {
        dom = _allHomeDoms[j];
        results.push(addClass(dom, "hide"));
      }
      return results;
    };
    _hideAllDetailPage = function() {
      var dom, j, len, results;
      results = [];
      for (j = 0, len = _allDetailDoms.length; j < len; j++) {
        dom = _allDetailDoms[j];
        results.push(addClass(dom, "hide"));
      }
      return results;
    };
    _showPage = function(id) {
      return removeClass(getById("" + id), "hide");
    };
    hideAllPage = function() {
      _hideAllMainPage();
      _hideAllHomePage();
      return _hideAllDetailPage();
    };
    return {
      switchTargetPage: function(id) {
        hideAllPage();
        if (indexOf.call(_allHomeId, id) >= 0) {
          _showPage("brae-home-page");
        } else if (indexOf.call(_allDetailId, id) >= 0) {
          _showPage("brae-detail-page");
        }
        _showPage(id);
        return setTimeout(scrollTo, 0, 0, 0);
      },
      hideAllPage: hideAllPage
    };
  })();
  HomeBottom = (function() {
    var _allDoms, _state, bottomTouchEventTrigger, uncheckAllForBottomAndHideAllPage;
    _state = "";
    _allDoms = querys("#nav-field .bottom-field div");
    uncheckAllForBottomAndHideAllPage = function() {
      var dom, id, j, len, results;
      results = [];
      for (j = 0, len = _allDoms.length; j < len; j++) {
        dom = _allDoms[j];
        id = dom.id;
        dom.className = id + "-unchecked";
        results.push(allPageManage.hideAllPage());
      }
      return results;
    };
    bottomTouchEventTrigger = function(id) {
      if (_state !== id) {

        /*
        				*WebSocketxxxxx
         */
      }
      _state = id;
      uncheckAllForBottomAndHideAllPage();
      getById(id).className = id + "-checked";
      return allPageManage.switchTargetPage(id + "-page");
    };
    return {
      bottomTouchEventTrigger: bottomTouchEventTrigger,
      uncheckAllForBottomAndHideAllPage: uncheckAllForBottomAndHideAllPage
    };
  })();
  HomeMenu = (function() {
    var _activityColumnDom;
    _activityColumnDom = query("#Menu-page #Menu-acitvity-column");
    return addListener(_activityColumnDom, "click", function() {
      return hashRoute.hashJump("-Activity");
    });
  })();
  Lock = (function() {})();
  Category = (function() {
    var _catergoryDisplayDom;

    function Category() {}

    _catergoryDisplayDom = query("#Menu-page .category-display-list");

    return Category;

  })();
  Activity = (function() {
    var _headerDom;

    function Activity() {}

    _headerDom = query("#Activity-page #Activity-header-column");

    return Activity;

  })();
  rotateDisplay = (function() {
    var _autoRotateEvent, _getCompatibleTranslateCss, _touchEnd, _touchMove, _touchStart;

    _getCompatibleTranslateCss = function(ver, hor) {
      var config, j, len, result_;
      result_ = {};
      for (j = 0, len = compatibleCSSConfig.length; j < len; j++) {
        config = compatibleCSSConfig[j];
        result_[config + "transform"] = "translate(" + ver + ", " + hor + ")";
      }
      return result_;
    };

    _autoRotateEvent = function(rotateDisplay) {
      var index, self;
      self = rotateDisplay;

      /*
      			* 监视autoFlag
       */
      if (!self.autoFlag) {
        self.autoFlag = true;
      } else {
        index = (self.currentChoose + 1) % self.activityNum;
        self.setCurrentChooseAndTranslate(index);
      }
      return setTimeout(function() {
        return _autoRotateEvent(self);
      }, self.delay);
    };


    /*
    		* 触摸开始的时候记录初始坐标位置
     */

    _touchStart = function(e, rotateDisplay) {
      rotateDisplay.autoFlag = false;
      rotateDisplay.startX = e.touches[0].clientX;
      rotateDisplay.startY = e.touches[0].clientY;
      rotateDisplay.currentX = e.touches[0].clientX;
      return rotateDisplay.currentY = e.touches[0].clientY;
    };


    /*
    		* 触摸的过程记录触摸所到达的坐标
     */

    _touchMove = function(e, rotateDisplay) {
      rotateDisplay.autoFlag = false;
      rotateDisplay.currentX = e.touches[0].clientX;
      rotateDisplay.currentY = e.touches[0].clientY;
      e.preventDefault();
      return e.stopPropagation();
    };


    /*
    		* 比较判断用户是倾向于左右滑动还是上下滑动
    		* 若为左右滑动，则根据用户滑动的地方，反向轮转播放动画(符合正常的滑动逻辑)
     */

    _touchEnd = function(e, rotateDisplay) {
      var activityNum, currentChoose, currentX, currentY, startX, startY, transIndex;
      rotateDisplay.autoFlag = false;
      currentX = rotateDisplay.currentX;
      currentY = rotateDisplay.currentY;
      startX = rotateDisplay.startX;
      startY = rotateDisplay.startY;
      if (Math.abs(currentY - startY) >= Math.abs(currentX - startX)) {
        return;
      }
      currentChoose = rotateDisplay.currentChoose;
      activityNum = rotateDisplay.activityNum;
      if (currentX < startX) {
        transIndex = (currentChoose + 1) % activityNum;
      } else if (currentX > startX) {
        transIndex = (currentChoose - 1 + activityNum) % activityNum;
      }
      return rotateDisplay.setCurrentChooseAndTranslate(transIndex);
    };


    /*
    		* 图片轮转播放
    		* @param {Object} options: 组件配置
    		*
    		* 调用方法:
    		* 直接通过构造函数，传入对应的对象配置即可。
    		* displayCSSSelector为图片所在的ul的css选择器
    		* chooseCSSSelector为图片对应的标号索引所在的ul的css选择器
    		* delay为图片每次轮转的时间
     */

    function rotateDisplay(options) {
      this.displayUlDom = query(options.displayCSSSelector);
      this.chooseUlDom = query(options.chooseCSSSelector);
      this.delay = options.delay;
      query(options.macroCSSSelector).style.height = (options.scale * clientWidth) + "px";
      this.init();
    }

    rotateDisplay.prototype.init = function() {
      this.initDisplay();
      this.initChoose();
      this.initAutoRotate();
      return this.initTouchEvent();
    };

    rotateDisplay.prototype.initDisplay = function() {
      var dom, j, len, ref1;
      this.displayContainerDom = this.displayUlDom.parentNode;
      this.displayContainerDom.style.overflow = "auto";
      this.allDisplayDom = querys("li", this.displayUlDom);

      /*
      			* 让所有的图片的宽度都能适应屏幕
       */
      ref1 = this.allDisplayDom;
      for (j = 0, len = ref1.length; j < len; j++) {
        dom = ref1[j];
        dom.style.width = clientWidth + "px";
      }
      this.activityNum = this.allDisplayDom.length;

      /*
      			* 扩充图片所在ul的长度
       */
      return this.displayUlDom.style.width = (clientWidth * this.activityNum) + "px";
    };

    rotateDisplay.prototype.initChoose = function() {
      var dom, i, j, len, ref1, results, self;
      this.chooseUlDom.parentNode.style.overflow = "auto";
      self = this;
      this.allChooseDom = querys("li", this.chooseUlDom);
      this.currentChoose = 0;
      ref1 = this.allChooseDom;
      results = [];
      for (i = j = 0, len = ref1.length; j < len; i = ++j) {
        dom = ref1[i];
        results.push(addListener(dom, "click", (function(i) {
          return function() {
            self.autoFlag = false;
            return self.setCurrentChooseAndTranslate(i);
          };
        })(i)));
      }
      return results;
    };

    rotateDisplay.prototype.initAutoRotate = function() {

      /*
      			* autoFlag用于监视是否有人工操作，如果有，则当前最近一次不做播放，重新设置autoFlag，使得下一次播放正常进行
       */
      var self;
      self = this;
      this.autoFlag = true;
      return setTimeout(function() {
        return _autoRotateEvent(self);
      }, self.delay);
    };

    rotateDisplay.prototype.initTouchEvent = function() {
      var self;
      self = this;
      addListener(this.displayContainerDom, "touchstart", function(e) {
        return _touchStart(e, self);
      });
      addListener(this.displayContainerDom, "touchmove", function(e) {
        return _touchMove(e, self);
      });
      return addListener(this.displayContainerDom, "touchend", function(e) {
        return _touchEnd(e, self);
      });
    };

    rotateDisplay.prototype.setCurrentChoose = function(index) {
      this.allChooseDom[this.currentChoose].className = "inactive";
      this.allChooseDom[index].className = "active";
      return this.currentChoose = index;
    };

    rotateDisplay.prototype.setCurrentChooseAndTranslate = function(index) {
      var compatibleTranslateCss, key, transIndex, value;
      if (index < 0 || index >= this.activityNum || index === this.currentChoose) {
        return;
      }
      transIndex = -1 * index;
      compatibleTranslateCss = _getCompatibleTranslateCss((transIndex * clientWidth) + "px", 0);
      for (key in compatibleTranslateCss) {
        value = compatibleTranslateCss[key];
        this.displayUlDom.style[key] = value;
      }
      return this.setCurrentChoose(index);
    };

    return rotateDisplay;

  })();
  hashRoute = (function() {
    var _getHashStr, _loc, _modifyTitle, _msgs, _parseAndExecuteHash, _popHashStr, _pushHashStr, _recentHash, title_dom;
    _loc = window.location;
    _msgs = {
      "Menu": {
        "push": function() {
          return HomeBottom.bottomTouchEventTrigger("Menu");
        },
        "pop": HomeBottom.uncheckAllForBottomAndHideAllPage,
        "title": "餐牌"
      },
      "Already": {
        "push": function() {
          return HomeBottom.bottomTouchEventTrigger("Already");
        },
        "pop": HomeBottom.uncheckAllForBottomAndHideAllPage,
        "title": "已点订单"
      },
      "Individual": {
        "push": function() {
          return HomeBottom.bottomTouchEventTrigger("Individual");
        },
        "pop": HomeBottom.uncheckAllForBottomAndHideAllPage,
        "title": "个人信息"
      },
      "Book": {
        "push": function() {
          return allPageManage.switchTargetPage("Book-page");
        },
        "pop": allPageManage.hideAllPage
      },
      "Activity": {
        "push": function() {
          return allPageManage.switchTargetPage("Activity-page");
        },
        "pop": allPageManage.hideAllPage
      },

      /*
      			"Trolley": {
      				"push": -> util.removeClass(Trolley.trolley_page_dom, "hide"); WS.checkSocket(); util.query("#container", Trolley.trolley_page_dom).focus()
      				"pop": -> util.addClass(Trolley.trolley_page_dom, "hide")
      				"title": "购物车"
      			}
      			"Trolley_online_pay": {
      				"push": -> util.removeClass(Trolley.online_pay_dom, "hide-right"); if Membership.balance >= OrderDish.all_orders_price then setTimeout(Trolley.payByMemberBalance, 100)
      				"pop": -> util.addClass(Trolley.online_pay_dom, "hide-right")
      				"title": "在线支付"
      			}
      			"Prompt_pay": {
      				"push": -> util.removeClass(Trolley.prompt_pay_dom, "hide")
      				"pop": Trolley.resetForPromptPayDom
      			}
      			"Activity_info": {
      				"push": Activity.showActivityInfo
      				"pop": -> util.addClass(Activity.detail_dom, "hide")
      			}
      			"Already": {
      				"push": Login.showAlreadyPage
      				"pop": Login.hideAlreadyPage
      				"title": "已点订单"
      			}
      			"Member_recharge": {
      				"push": Membership_pay.showMemberRechargeDom
      				"pop": Membership_pay.hideMemberRechargeDom
      				"title": "会员卡充值"
      			}
      			"Login": {
      				"push": ->
      					if not Login.is_login then Login.showLoginPage()
      					else setTimeout(hashRoute.back, 0)
      				"pop": Login.hideLoginPage
      				"title": "登录"
      			}
       */
      "x": {
        "push": function() {
          return setTimeout(function() {
            return _popHashStr("x");
          }, 0);
        },
        "pop": function() {
          return setTimeout(function() {
            return _popHashStr("x");
          }, 0);
        }
      }
    };
    addListener(window, "popstate", function() {
      return _parseAndExecuteHash(_getHashStr());
    });
    title_dom = util.query("title");
    _recentHash = _loc.hash.replace("#", "");
    _getHashStr = function() {
      return _loc.hash.replace("#", "");
    };
    _pushHashStr = function(str) {
      return _loc.hash = _recentHash + "-" + str;
    };
    _popHashStr = function(str) {
      return _loc.hash = _recentHash.replace("-" + str, "");
    };
    _modifyTitle = function(str) {
      return title_dom.innerHTML = str;
    };
    _parseAndExecuteHash = function(str) {
      var base, base1, base2, entry, hash_arr, i, j, k, l, last_state, len, len1, len2, m, n, old_arr, ref1, ref2, temp_counter;
      hash_arr = str.split("-");
      if (hash_arr.length <= 1 && hash_arr[0] === "") {
        return;
      }
      old_arr = _recentHash.split("-");
      hash_arr.splice(0, 1);
      old_arr.splice(0, 1);
      last_state = hash_arr[hash_arr.length - 1];
      if (str === _recentHash) {
        for (j = 0, len = hash_arr.length; j < len; j++) {
          entry = hash_arr[j];
          if (entry && _msgs[entry]) {
            if (typeof (base = _msgs[entry])["push"] === "function") {
              base["push"]();
            }
          }
        }
        if (str === "-Individual-Login") {
          setTimeout(hashRoute.back, 0);
        }
        return;
      }
      temp_counter = {};
      for (k = 0, len1 = old_arr.length; k < len1; k++) {
        entry = old_arr[k];
        if (entry) {
          temp_counter[entry] = 1;
        }
      }
      for (l = 0, len2 = hash_arr.length; l < len2; l++) {
        entry = hash_arr[l];
        if (!entry) {
          continue;
        }
        if (temp_counter[entry]) {
          temp_counter[entry]++;
        } else {
          temp_counter[entry] = 1;
        }
      }
      for (i = m = ref1 = old_arr.length - 1; ref1 <= 0 ? m <= 0 : m >= 0; i = ref1 <= 0 ? ++m : --m) {
        if (old_arr[i] && _msgs[old_arr[i]] && temp_counter[old_arr[i]] === 1) {
          if (typeof (base1 = _msgs[old_arr[i]])["pop"] === "function") {
            base1["pop"]();
          }
        }
      }
      for (i = n = 0, ref2 = hash_arr.length - 1; 0 <= ref2 ? n <= ref2 : n >= ref2; i = 0 <= ref2 ? ++n : --n) {
        if (hash_arr[i] && _msgs[hash_arr[i]] && temp_counter[hash_arr[i]] === 1) {
          if (typeof (base2 = _msgs[hash_arr[i]])["push"] === "function") {
            base2["push"]();
          }
        }
      }
      return _recentHash = str;
    };
    return {
      ahead: function() {
        return history.go(1);
      },
      back: function() {
        return history.go(-1);
      },
      refresh: function() {
        return _loc.reload();
      },
      hashJump: function(str) {
        return _loc.hash = str;
      }
    };
  })();
  Db = (function() {
    var doc, store;
    store = window.localStorage;
    doc = document.documentElement;
    if (!store) {
      doc.type.behavior = 'url(#default#userData)';
    }
    return {
      set: function(key, val, context) {
        if (store) {
          return store.setItem(key, val, context);
        } else {
          doc.setAttribute(key, value);
          return doc.save(context || 'default');
        }
      },
      get: function(key, context) {
        if (store) {
          return store.getItem(key, context);
        } else {
          doc.load(context || 'default');
          return doc.getAttribute(key) || '';
        }
      },
      rm: function(key, context) {
        if (store) {
          return store.removeItem(key, context);
        } else {
          context = context || 'default';
          doc.load(context);
          doc.removeAttribute(key);
          return doc.save(context);
        }
      },
      clear: function() {
        if (store) {
          return store.clear();
        } else {
          return doc.expires = -1;
        }
      }
    };
  })();
  callpay = function(options) {
    var self, wxConfigFailed;
    self = this;
    if (typeof wx !== "undefined") {
      wxConfigFailed = false;
      wx.config({
        debug: false,
        appId: "" + options.appid,
        timestamp: options.timestamp,
        nonceStr: "" + options.noncestr,
        signature: "" + options.signature,
        jsApiList: ['chooseWXPay']
      });
      wx.ready(function() {
        if (wxConfigFailed) {
          return;
        }
        return wx.chooseWXPay({
          timestamp: options.timestamp,
          nonceStr: "" + options.noncestr,
          "package": "" + options["package"],
          signType: 'MD5',
          paySign: "" + options.signMD,
          success: function(res) {
            if (typeof options.always === "function") {
              options.always();
            }
            if (res.errMsg === "chooseWXPay:ok") {
              innerCallback("success");
              return typeof options.callback === "function" ? options.callback() : void 0;
            } else {
              return innerCallback("fail", error("wx_result_fail", res.errMsg));
            }
          },
          cancel: function(res) {
            if (typeof options.always === "function") {
              options.always();
            }
            return innerCallback("cancel");
          },
          fail: function(res) {
            if (typeof options.always === "function") {
              options.always();
            }
            return innerCallback("fail", error("wx_config_fail", res.errMsg));
          }
        });
      });
      return wx.error(function(res) {
        if (typeof options.always === "function") {
          options.always();
        }
        wxConfigFailed = true;
        return innerCallback("fail", error("wx_config_error", res.errMsg));
      });
    }
  };
  innerCallback = function(result, err) {
    if (typeof this._resultCallback === "function") {
      if (typeof err === "undefined") {
        err = this._error();
      }
      return this._resultCallback(result, err);
    }
  };
  return window.onload = function() {
    allPageManage.switchTargetPage("Activity-page");
    new rotateDisplay({
      displayCSSSelector: "#Menu-page .activity-display-list",
      chooseCSSSelector: "#Menu-page .choose-dot-list",
      macroCSSSelector: "#Menu-page #Menu-acitvity-column",
      scale: 110 / 377,
      delay: 3000
    });
    return new rotateDisplay({
      displayCSSSelector: "#Activity-page .header-display-list",
      chooseCSSSelector: "#Activity-page .choose-dot-list",
      macroCSSSelector: "#Activity-page #Activity-header-column",
      scale: 200 / 375,
      delay: 3000
    });
  };
})(window, document);
