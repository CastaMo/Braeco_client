(function(window, document) {
  var ActivityDisplay, Bottom, Category, Lock, addClass, addListener, ajax, append, clientWidth, compatibleCssConfig, deepCopy, getById, getElementsByClassName, getObjectURL, hasClass, hashRoute, hidePhone, isPhone, prepend, query, querys, ref, remove, removeClass, removeListener, toggleClass;
  ref = [util.addListener, util.removeListener, util.hasClass, util.addClass, util.removeClass, util.ajax, util.getElementsByClassName, util.isPhone, util.hidePhone, util.query, util.querys, util.remove, util.append, util.prepend, util.toggleClass, util.getObjectURL, util.deepCopy, util.getById], addListener = ref[0], removeListener = ref[1], hasClass = ref[2], addClass = ref[3], removeClass = ref[4], ajax = ref[5], getElementsByClassName = ref[6], isPhone = ref[7], hidePhone = ref[8], query = ref[9], querys = ref[10], remove = ref[11], append = ref[12], prepend = ref[13], toggleClass = ref[14], getObjectURL = ref[15], deepCopy = ref[16], getById = ref[17];
  clientWidth = document.body.clientWidth;
  compatibleCssConfig = ["", "-webkit-", "-moz-", "-ms-", "-o-"];
  Bottom = (function() {
    var _allDoms, _state, _switchTargetPage, bottomTouchEventTrigger, uncheckAllForBottomAndHideAllPage;
    _state = "";
    _allDoms = querys("#nav-field .bottom-field div");
    _switchTargetPage = function(id) {
      removeClass(query("#" + id + "-page"), "hide");
      return setTimeout(scrollTo, 0, 0, 0);
    };
    uncheckAllForBottomAndHideAllPage = function() {
      var dom, id, j, len, results;
      results = [];
      for (j = 0, len = _allDoms.length; j < len; j++) {
        dom = _allDoms[j];
        id = dom.id;
        dom.className = id + "-unchecked";
        results.push(addClass(query("#" + id + "-page"), "hide"));
      }
      return results;
    };
    bottomTouchEventTrigger = function(id) {
      if (_state === id) {
        return;
      }
      _state = id;

      /*
      			*WebSocketxxxxx
       */
      uncheckAllForBottomAndHideAllPage();
      getById(id).className = id + "-checked";
      return _switchTargetPage(id);
    };
    return {
      bottomTouchEventTrigger: bottomTouchEventTrigger,
      uncheckAllForBottomAndHideAllPage: uncheckAllForBottomAndHideAllPage
    };
  })();
  Lock = (function() {})();
  Category = (function() {
    var _catergoryDisplayDom;

    function Category() {}

    _catergoryDisplayDom = query("#Menu-page .category-display-list");

    return Category;

  })();
  ActivityDisplay = (function() {
    var _activityChooseAllDom, _activityChooseDom, _activityDisplayAllDom, _activityDisplayDom, _activityNum, _currentChoose, _getCompatibleTranslateCss, _initForActivityChoose, _initForActivityDisplay, _setCurrentChoose, _setCurrentChooseAndTranslate;
    _activityDisplayDom = query("#Menu-page .activity-display-list");
    _activityChooseDom = query("#Menu-page .choose-dot-list");
    _activityChooseAllDom = null;
    _activityDisplayAllDom = null;
    _activityNum = 0;
    _currentChoose = 0;
    _setCurrentChoose = function(index) {
      _activityChooseAllDom[_currentChoose].className = "inactive";
      _activityChooseAllDom[index].className = "active";
      return _currentChoose = index;
    };
    _initForActivityChoose = function() {
      var dom, i, j, len, results;
      _activityChooseAllDom = querys("li", _activityChooseDom);
      results = [];
      for (i = j = 0, len = _activityChooseAllDom.length; j < len; i = ++j) {
        dom = _activityChooseAllDom[i];
        results.push(addListener(dom, "click", (function(i) {
          return function() {
            return _setCurrentChooseAndTranslate(i);
          };
        })(i)));
      }
      return results;
    };
    _getCompatibleTranslateCss = function(ver, hor) {
      var config, j, len, result_;
      result_ = {};
      for (j = 0, len = compatibleCssConfig.length; j < len; j++) {
        config = compatibleCssConfig[j];
        result_[config + "transform"] = "translate(" + ver + ", " + hor + ")";
      }
      return result_;
    };
    _setCurrentChooseAndTranslate = function(index) {
      var compatibleTranslateCss, key, transIndex, value;
      if (index < 0 || index >= _activityNum || index === _currentChoose) {
        return;
      }
      transIndex = -1 * index;
      compatibleTranslateCss = _getCompatibleTranslateCss((transIndex * clientWidth) + "px", 0);
      for (key in compatibleTranslateCss) {
        value = compatibleTranslateCss[key];
        _activityDisplayDom.style[key] = value;
      }
      return _setCurrentChoose(index);
    };
    _initForActivityDisplay = function() {
      var _allDoms, dom, j, len;
      _allDoms = querys("li", _activityDisplayDom);
      for (j = 0, len = _allDoms.length; j < len; j++) {
        dom = _allDoms[j];
        dom.style.width = clientWidth + "px";
      }
      _activityNum = _allDoms.length;
      return _activityDisplayDom.style.width = (clientWidth * _activityNum) + "px";
    };
    return {
      initial: function() {
        _initForActivityDisplay();
        return _initForActivityChoose();
      }
    };
  })();
  hashRoute = (function() {
    var _getHashStr, _loc, _modifyTitle, _msgs, _parseAndExecuteHash, _popHashStr, _pushHashStr, _recentHash, title_dom;
    _loc = window.location;
    _msgs = {
      "Menu": {
        "push": function() {
          return Bottom.bottomTouchEventTrigger("Menu");
        },
        "pop": Bottom.uncheckAllForBottomAndHideAllPage,
        "title": "餐牌"
      },
      "Already": {
        "push": function() {
          return Bottom.bottomTouchEventTrigger("Already");
        },
        "pop": Bottom.uncheckAllForBottomAndHideAllPage,
        "title": "已点订单"
      },
      "Individual": {
        "push": function() {
          return Bottom.bottomTouchEventTrigger("Individual");
        },
        "pop": Bottom.uncheckAllForBottomAndHideAllPage,
        "title": "个人信息"
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
      }
    };
  })();
  return window.onload = function() {
    Bottom.bottomTouchEventTrigger("Menu");
    return ActivityDisplay.initial();
  };
})(window, document);
