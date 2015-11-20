var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

(function(window, document) {
  var Activity, Category, Db, Individual, Lock, addClass, addListener, ajax, append, callpay, clientWidth, compatibleCSSConfig, deepCopy, extraPageManage, getById, getElementsByClassName, getObjectURL, hasClass, hashRoute, hidePhone, innerCallback, isPhone, prepend, query, querys, ref, remove, removeClass, removeListener, rotateDisplay, toggleClass;
  ref = [util.addListener, util.removeListener, util.hasClass, util.addClass, util.removeClass, util.ajax, util.getElementsByClassName, util.isPhone, util.hidePhone, util.query, util.querys, util.remove, util.append, util.prepend, util.toggleClass, util.getObjectURL, util.deepCopy, util.getById], addListener = ref[0], removeListener = ref[1], hasClass = ref[2], addClass = ref[3], removeClass = ref[4], ajax = ref[5], getElementsByClassName = ref[6], isPhone = ref[7], hidePhone = ref[8], query = ref[9], querys = ref[10], remove = ref[11], append = ref[12], prepend = ref[13], toggleClass = ref[14], getObjectURL = ref[15], deepCopy = ref[16], getById = ref[17];
  clientWidth = document.body.clientWidth;
  compatibleCSSConfig = ["", "-webkit-", "-moz-", "-ms-", "-o-"];
  Lock = (function() {})();
  Category = (function() {
    var _catergoryDisplayDom;

    function Category() {}

    _catergoryDisplayDom = query("#Menu-page .category-display-list");

    return Category;

  })();
  Activity = (function() {
    var _activityInfoImgDom, _activityInformationDom, dom, j, len, ref1;

    function Activity() {}

    _activityInformationDom = query(".Activity-information-field");

    _activityInfoImgDom = query("#activity-info-img-field", _activityInformationDom);

    _activityInfoImgDom.style.height = (clientWidth * 0.9 * 167 / 343) + "px";

    ref1 = querys("#Activity-container-column li");
    for (j = 0, len = ref1.length; j < len; j++) {
      dom = ref1[j];
      addListener(dom, "click", function() {
        return hashRoute.pushHashStr("activityInfo");
      });
    }

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
      var dom, j, len, ref1;
      this.displayUlDom = query(options.displayCSSSelector);
      this.chooseUlDom = query(options.chooseCSSSelector);
      this.delay = options.delay;
      ref1 = querys("img", this.displayUlDom);
      for (j = 0, len = ref1.length; j < len; j++) {
        dom = ref1[j];
        dom.style.height = (options.scale * clientWidth) + "px";
      }
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
      this.displayContainerDom.style.overflowX = "auto";
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
      this.chooseUlDom.parentNode.style.overflow = "hidden";
      self = this;
      this.allChooseDom = querys("li", this.chooseUlDom);
      this.currentChoose = 0;
      ref1 = this.allChooseDom;
      results = [];
      for (i = j = 0, len = ref1.length; j < len; i = ++j) {
        dom = ref1[i];
        results.push(addListener(dom, "click", (function(i) {
          return function(e) {
            e.preventDefault();
            e.stopPropagation();
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
  Individual = (function() {
    var _rechargeFuncDom;
    _rechargeFuncDom = getById("Recharge-func");
    return addListener(_rechargeFuncDom, "click", function() {
      return hashRoute.pushHashStr("Recharge");
    });
  })();
  hashRoute = (function() {
    var HomeBottom, HomeMenu, _activityInfoDom, _allExtraContentDoms, _allExtraContentId, _allExtraDoms, _allExtraFormDoms, _allExtraFormId, _allMainDetailDoms, _allMainDetailId, _allMainDoms, _allMainHomeDoms, _allMainHomeId, _allSecondary, _dynamicShowTarget, _extraMainDom, _getHashStr, _hashStateFunc, _hideAllExtra, _hideAllExtraContentPage, _hideAllExtraFormPage, _hideAllExtraPage, _hideAllMain, _hideAllMainDetailPage, _hideAllMainHomePage, _hideAllMainPage, _hideSecondaryPage, _hideTarget, _loc, _modifyTitle, _parseAndExecuteHash, _recentHash, _secondaryInfo, _staticShowTarget, _switchExtraPage, _switchFirstPage, _switchSecondaryPage, _titleDom, hashJump, popHashStr, pushHashStr;
    HomeBottom = (function() {
      var _allDoms, _state, bottomTouchEventTrigger, uncheckAllForBottomAnd_hideAllMain;
      _state = "";
      _allDoms = querys("#nav-field .bottom-field div");
      uncheckAllForBottomAnd_hideAllMain = function() {
        var dom, id, j, len, results;
        results = [];
        for (j = 0, len = _allDoms.length; j < len; j++) {
          dom = _allDoms[j];
          id = dom.id;
          dom.className = id + "-unchecked";
          results.push(_hideAllMain());
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
        uncheckAllForBottomAnd_hideAllMain();
        getById(id).className = id + "-checked";
        return _switchFirstPage(id + "-page");
      };
      return {
        bottomTouchEventTrigger: bottomTouchEventTrigger,
        uncheckAllForBottomAnd_hideAllMain: uncheckAllForBottomAnd_hideAllMain
      };
    })();
    HomeMenu = (function() {
      var _activityColumnDom;
      _activityColumnDom = query("#Menu-page .activity-wrapper");
      return addListener(_activityColumnDom, "click", function() {
        return hashJump("-Activity");
      });
    })();
    _extraMainDom = getById("#extra");
    _allMainDoms = querys(".main-page");
    _allMainHomeDoms = querys(".main-home-page");
    _allMainDetailDoms = querys(".main-detail-page");
    _allExtraDoms = querys(".extra-page");
    _allExtraFormDoms = querys(".extra-form-page");
    _allExtraContentDoms = querys(".extra-content-page");
    _activityInfoDom = query(".Activity-information-field");
    _allSecondary = ["activityInfo"];
    _secondaryInfo = {
      "Activity": ["activityInfo"]
    };
    _allMainHomeId = ["Menu-page", "Already-page", "Individual-page"];
    _allMainDetailId = ["Book-page", "Activity-page"];
    _allExtraFormId = ["login-page", "book-choose-page", "remark-for-trolley-page", "alert-page", "confirm-page"];
    _allExtraContentId = ["Recharge-page", "Confirm-pay-page"];
    _loc = window.location;
    _hashStateFunc = {
      "Menu": {
        "push": function() {
          return HomeBottom.bottomTouchEventTrigger("Menu");
        },
        "pop": HomeBottom.uncheckAllForBottomAnd_hideAllMain,
        "title": "餐牌"
      },
      "Already": {
        "push": function() {
          return HomeBottom.bottomTouchEventTrigger("Already");
        },
        "pop": HomeBottom.uncheckAllForBottomAnd_hideAllMain,
        "title": "已点订单"
      },
      "Individual": {
        "push": function() {
          return HomeBottom.bottomTouchEventTrigger("Individual");
        },
        "pop": HomeBottom.uncheckAllForBottomAnd_hideAllMain,
        "title": "个人信息"
      },
      "Book": {
        "push": function() {
          return _switchFirstPage("Book-page");
        },
        "pop": _hideAllMain
      },
      "Activity": {
        "push": function() {
          return _switchFirstPage("Activity-page");
        },
        "pop": _hideAllMain
      },
      "activityInfo": {
        "push": function() {
          return _switchSecondaryPage("activityInfo", "Activity", _activityInfoDom);
        },
        "pop": function() {
          return _hideSecondaryPage(_activityInfoDom);
        }
      },
      "Recharge": {
        "push": function() {
          return _switchExtraPage("Recharge-page");
        },
        "pop": function() {
          return _hideAllExtra(true);
        }
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
            return popHashStr("x");
          }, 0);
        },
        "pop": function() {
          return setTimeout(function() {
            return popHashStr("x");
          }, 0);
        }
      }
    };
    addListener(window, "popstate", function() {
      return _parseAndExecuteHash(_getHashStr());
    });
    _titleDom = util.query("title");
    _recentHash = _loc.hash.replace("#", "");
    _switchExtraPage = function(id) {
      _hideAllExtra();
      _staticShowTarget("extra");
      if (indexOf.call(_allExtraContentId, id) >= 0) {
        _staticShowTarget("brae-payment-page");
        return setTimeout(function() {
          return _dynamicShowTarget(id, "hide-right");
        }, 0);
      } else if (indexOf.call(_allExtraFormId, id) >= 0) {
        return _staticShowTarget("brae-form-page");
      }
    };
    _hideAllExtraPage = function() {
      var dom, j, len, results;
      results = [];
      for (j = 0, len = _allExtraDoms.length; j < len; j++) {
        dom = _allExtraDoms[j];
        results.push(addClass(dom, "hide"));
      }
      return results;
    };
    _hideAllExtraFormPage = function() {
      var dom, j, len, results;
      results = [];
      for (j = 0, len = _allExtraFormDoms.length; j < len; j++) {
        dom = _allExtraFormDoms[j];
        results.push(addClass(dom, "hide"));
      }
      return results;
    };
    _hideAllExtraContentPage = function() {
      var dom, j, len, results;
      results = [];
      for (j = 0, len = _allExtraContentDoms.length; j < len; j++) {
        dom = _allExtraContentDoms[j];
        results.push(addClass(dom, "hide-right"));
      }
      return results;
    };
    _hideAllExtra = function(async) {
      _hideAllExtraFormPage();
      _hideAllExtraContentPage();
      if (async) {
        return setTimeout(function() {
          _hideAllExtraPage();
          return _hideTarget("extra");
        }, 400);
      } else {
        _hideAllExtraPage();
        return _hideTarget("extra");
      }
    };
    _switchFirstPage = function(id) {
      _hideAllMain();
      if (indexOf.call(_allMainHomeId, id) >= 0) {
        _staticShowTarget("brae-home-page");
      } else if (indexOf.call(_allMainDetailId, id) >= 0) {
        _staticShowTarget("brae-detail-page");
      }
      _staticShowTarget(id);
      return setTimeout("scrollTo(0, 0)", 0);
    };
    _switchSecondaryPage = function(currentState, previousState, pageDom) {
      if (indexOf.call(_secondaryInfo[previousState], currentState) >= 0) {
        return removeClass(pageDom, "hide-right");
      }
    };
    _hideSecondaryPage = function(pageDom) {
      return addClass(pageDom, "hide-right");
    };
    _hideAllMainPage = function() {
      var dom, j, len, results;
      results = [];
      for (j = 0, len = _allMainDoms.length; j < len; j++) {
        dom = _allMainDoms[j];
        results.push(addClass(dom, "hide"));
      }
      return results;
    };
    _hideAllMainHomePage = function() {
      var dom, j, len, results;
      results = [];
      for (j = 0, len = _allMainHomeDoms.length; j < len; j++) {
        dom = _allMainHomeDoms[j];
        results.push(addClass(dom, "hide"));
      }
      return results;
    };
    _hideAllMainDetailPage = function() {
      var dom, j, len, results;
      results = [];
      for (j = 0, len = _allMainDetailDoms.length; j < len; j++) {
        dom = _allMainDetailDoms[j];
        results.push(addClass(dom, "hide"));
      }
      return results;
    };
    _hideAllMain = function() {
      _hideAllMainHomePage();
      _hideAllMainDetailPage();
      return _hideAllMainPage();
    };
    _staticShowTarget = function(id) {
      return removeClass(getById(id), "hide");
    };
    _dynamicShowTarget = function(id, className) {
      return removeClass(getById(id), className);
    };
    _hideTarget = function(id, className) {
      var _target;
      _target = getById(id);
      if (className) {
        return addClass(_target, className);
      } else {
        return addClass(_target, "hide");
      }
    };
    _getHashStr = function() {
      return _loc.hash.replace("#", "");
    };
    _modifyTitle = function(str) {
      return _titleDom.innerHTML = str;
    };
    _parseAndExecuteHash = function(str) {
      var base, base1, base2, base3, entry, hash_arr, i, j, k, l, last_state, len, len1, len2, m, n, old_arr, ref1, ref2, ref3, ref4, temp_counter;
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
          if (entry && _hashStateFunc[entry]) {
            if (typeof (base = _hashStateFunc[entry])["push"] === "function") {
              base["push"]();
            }
          }
        }
        if (str === "-Individual-Login") {
          setTimeout(back, 0);
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
        if (old_arr[i] && _hashStateFunc[old_arr[i]] && temp_counter[old_arr[i]] === 1) {
          if (typeof (base1 = _hashStateFunc[old_arr[i]])["pop"] === "function") {
            base1["pop"]();
          }
        }
      }
      for (i = n = 0, ref2 = hash_arr.length - 1; 0 <= ref2 ? n <= ref2 : n >= ref2; i = 0 <= ref2 ? ++n : --n) {
        if (hash_arr[i] && _hashStateFunc[hash_arr[i]] && temp_counter[hash_arr[i]] === 1) {
          if (ref3 = old_arr[i], indexOf.call(_allSecondary, ref3) >= 0) {
            if (ref4 = old_arr[i], indexOf.call(_secondaryInfo[old_arr[i - 1]], ref4) >= 0) {
              if (typeof (base2 = _hashStateFunc[hash_arr[i]])["push"] === "function") {
                base2["push"]();
              }
            }
            continue;
          }
          if (typeof (base3 = _hashStateFunc[hash_arr[i]])["push"] === "function") {
            base3["push"]();
          }
        }
      }
      return _recentHash = str;
    };
    pushHashStr = function(str) {
      return _loc.hash = _recentHash + "-" + str;
    };
    popHashStr = function(str) {
      return _loc.hash = _recentHash.replace("-" + str, "");
    };
    hashJump = function(str) {
      return _loc.hash = str;
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
      pushHashStr: pushHashStr,
      popHashStr: popHashStr,
      hashJump: hashJump,
      HomeBottom: HomeBottom,
      _switchExtraPage: _switchExtraPage
    };
  })();
  extraPageManage = (function() {
    var _extraDom;
    return _extraDom = getById("extra");
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
    if (location.hash === "") {
      hashRoute.hashJump("-Menu-x");
    }
    new rotateDisplay({
      displayCSSSelector: "#Menu-page .activity-display-list",
      chooseCSSSelector: "#Menu-page .choose-dot-list",
      scale: 110 / 377,
      delay: 3000
    });
    return new rotateDisplay({
      displayCSSSelector: "#Activity-page .header-display-list",
      chooseCSSSelector: "#Activity-page .choose-dot-list",
      scale: 200 / 375,
      delay: 3000
    });
  };
})(window, document);
