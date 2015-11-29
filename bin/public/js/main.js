var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

(function(window, document) {
  var Activity, Category, Food, Individual, LocStorSingleton, Lock, Recharge, User, addClass, addListener, ajax, append, callpay, clientHeight, clientWidth, compatibleCSSConfig, createDom, deepCopy, getAdaptHeight, getById, getElementsByClassName, getJSON, getObjectURL, hasClass, hashRoute, hidePhone, innerCallback, isPhone, locStor, numToChinese, prepend, query, querys, ref, remove, removeClass, removeListener, rotateDisplay, toggleClass, user;
  ref = [util.addListener, util.removeListener, util.hasClass, util.addClass, util.removeClass, util.ajax, util.getElementsByClassName, util.isPhone, util.hidePhone, util.query, util.querys, util.remove, util.append, util.prepend, util.toggleClass, util.getObjectURL, util.deepCopy, util.getById, util.createDom, util.getJSON, util.getAdaptHeight], addListener = ref[0], removeListener = ref[1], hasClass = ref[2], addClass = ref[3], removeClass = ref[4], ajax = ref[5], getElementsByClassName = ref[6], isPhone = ref[7], hidePhone = ref[8], query = ref[9], querys = ref[10], remove = ref[11], append = ref[12], prepend = ref[13], toggleClass = ref[14], getObjectURL = ref[15], deepCopy = ref[16], getById = ref[17], createDom = ref[18], getJSON = ref[19], getAdaptHeight = ref[20];
  clientWidth = document.body.clientWidth;
  clientHeight = document.documentElement.clientHeight;
  locStor = null;
  user = null;
  compatibleCSSConfig = ["", "-webkit-", "-moz-", "-ms-", "-o-"];
  numToChinese = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"];
  Category = (function() {

    /*
    		* 八个静态私有变量
    		* 1. 用于首页展示的ul的Dom, 里面存放displayDom
    		* 2. 用于点餐页面顶栏ul的Dom, 里面存放bookCategoryDom
    		* 3. 用于收揽展示餐品的Dom, 里面存放foodListDom
    		* 4. 点餐页面用于给顶栏ul纪录调整宽度的值
    		* 5. 所有category类的容器
    		* 6. 当前选中的品类
    		* 7. localStorage单例对象, 初始化放在静态公有函数initial中
    		* 8. 调整宽度按照字符来计算, 1个字母为10px, 1个数字为11px, 1个空格为6px, 1个中文为16px
     */
    var _categoryBookCategoryUlDom, _categoryBookCategoryUlWidth, _categoryCurrentChoose, _cateogries, _catergoryDisplayUlDom, _chooseBookCategoryByCurrentChoose, _foodListAllDom, _getBookCategoryDom, _getCurrentChooseFromLocStor, _getDisplayDom, _getFoodListDom, _getWidthByContent, _hideAllFoodListDom, _setCurrentChoose, _unChooseAllBookCategoryDom, _updateBookCategoryDomWidth, _widthByContent;

    _catergoryDisplayUlDom = query("#Menu-page .category-display-list");

    _categoryBookCategoryUlDom = query("#book-category-wrap .tag-list");

    _foodListAllDom = query("#book-dish-wrap .food-list-wrap");

    _categoryBookCategoryUlWidth = 0;

    _cateogries = [];

    _categoryCurrentChoose = 0;

    _widthByContent = {
      "letter": 10,
      "number": 11,
      "space": 6,
      "chinese": 16
    };


    /*
    		* 静态私有函数
    		* 创建和返回displayDom, 并投放到_catergoryDisplayUlDom中
    		* @param {Object} category类变量
     */

    _getDisplayDom = function(category) {
      var dom, imgDomStr, nameDomStr, url;
      dom = createDom("li");
      dom.id = "category-" + category.seqNum;
      url = category.url || "";
      imgDomStr = "<img alt='标签' class='category-img' src=" + url + ">";
      nameDomStr = "<div class='category-name-field'><p class='category-name'>" + category.name + "</div>";
      dom.innerHTML = "" + imgDomStr + nameDomStr;
      append(_catergoryDisplayUlDom, dom);
      return dom;
    };


    /*
    		* 静态私有函数
    		* 创建和返回bookCategory的dom, 并投放在_categoryBookCategoryUlDom中
    		* @param {Object} category类变量
     */

    _getBookCategoryDom = function(category) {
      var dom, width;
      dom = createDom("li");
      dom.id = "tag-list-" + category.seqNum;
      dom.innerHTML = category.name;
      width = _getWidthByContent(category.name);
      dom.style.width = width + "px";
      append(_categoryBookCategoryUlDom, dom);
      _categoryBookCategoryUlWidth += width + 30;
      return dom;
    };


    /*
    		* 静态私有函数
    		* 创建和返回foodList的dom, 并投放在_foodListAllDomm中
    		* @param {Object} category类变量
     */

    _getFoodListDom = function(category) {
      var dom;
      dom = createDom("ul");
      dom.id = "food-list-" + category.seqNum;
      dom.className = "hide";
      append(_foodListAllDom, dom);
      return dom;
    };


    /*
    		* 静态私有函数
    		* 得到对应的dom的长度
    		* @param {String} dom的内容
     */

    _getWidthByContent = function(str) {
      var allChineseWordLength, allLetter, allLetterLength, allNumber, allNumberLength, allSpace, allSpaceLength;
      allLetter = str.match(/[a-z]/ig) || [];
      allNumber = str.match(/[0-9]/ig) || [];
      allSpace = str.match(/\s/ig) || [];
      allLetterLength = allLetter.length;
      allNumberLength = allNumber.length;
      allSpaceLength = allSpace.length;
      allChineseWordLength = str.length - allLetterLength - allNumberLength - allSpaceLength;
      return _widthByContent["letter"] * allLetterLength + _widthByContent["number"] * allNumberLength + _widthByContent["space"] * allSpaceLength + _widthByContent["chinese"] * allChineseWordLength + 1;
    };

    _updateBookCategoryDomWidth = function() {
      return _categoryBookCategoryUlDom.style.width = _categoryBookCategoryUlWidth + "px";
    };

    _hideAllFoodListDom = function() {
      var category, k, len, results;
      results = [];
      for (k = 0, len = _cateogries.length; k < len; k++) {
        category = _cateogries[k];
        results.push(addClass(category.foodListDom, "hide"));
      }
      return results;
    };

    _unChooseAllBookCategoryDom = function() {
      var category, k, len, results;
      results = [];
      for (k = 0, len = _cateogries.length; k < len; k++) {
        category = _cateogries[k];
        results.push(removeClass(category.bookCategoryDom, "choose"));
      }
      return results;
    };

    _chooseBookCategoryByCurrentChoose = function() {
      _unChooseAllBookCategoryDom();
      _hideAllFoodListDom();
      _getCurrentChooseFromLocStor();
      addClass(_cateogries[_categoryCurrentChoose].bookCategoryDom, "choose");
      removeClass(_cateogries[_categoryCurrentChoose].foodListDom, "hide");
      return setTimeout(function() {
        return _cateogries[_categoryCurrentChoose].bookCategoryDom.scrollIntoView();
      }, 0);
    };

    _setCurrentChoose = function(seqNum) {
      _categoryCurrentChoose = seqNum;
      return locStor.set("categoryCurrentChoose", seqNum);
    };

    _getCurrentChooseFromLocStor = function() {
      var choose;
      choose = locStor.get("categoryCurrentChoose") || 0;
      if (_cateogries[choose]) {
        return _categoryCurrentChoose = Number(choose);
      } else {
        return _categoryCurrentChoose = 0;
      }
    };

    function Category(options) {
      deepCopy(options, this);
      this.init();
      _updateBookCategoryDomWidth();
      _cateogries.push(this);
    }

    Category.prototype.init = function() {
      this.initDisplayDom();
      this.initBookCategoryDom();
      this.initFoodListDom();
      return this.initEvent();
    };

    Category.prototype.initDisplayDom = function() {
      return this.displayDom = _getDisplayDom(this);
    };

    Category.prototype.initBookCategoryDom = function() {
      return this.bookCategoryDom = _getBookCategoryDom(this);
    };

    Category.prototype.initFoodListDom = function() {
      return this.foodListDom = _getFoodListDom(this);
    };

    Category.prototype.initEvent = function() {
      var self;
      self = this;
      addListener(self.displayDom, "click", function() {
        _setCurrentChoose(self.seqNum);
        return hashRoute.hashJump("-Detail-Book-bookCol");
      });
      return addListener(self.bookCategoryDom, "click", function() {
        _setCurrentChoose(self.seqNum);
        return _chooseBookCategoryByCurrentChoose();
      });
    };

    Category.initial = function() {
      var category, dishJSON, i, k, len, results, tempOuter;
      dishJSON = getJSON(getDishJSON());
      results = [];
      for (i = k = 0, len = dishJSON.length; k < len; i = ++k) {
        tempOuter = dishJSON[i];
        results.push(category = new Category({
          name: tempOuter.categoryname,
          id: tempOuter.id,
          seqNum: i
        }));
      }
      return results;
    };

    Category.chooseBookCategoryByCurrentChoose = _chooseBookCategoryByCurrentChoose;

    return Category;

  })();
  Food = (function() {
    var _bookDishDom, _foodCurrentChoose, _foodInfo, _foodInfoDom, _foodInfoImgDom, _foodInfoIntroDom, _foods, _getBottomWrapForInfoDom, _getCurrentChooseFromLocStor, _getDCLabelForTopWrapDom, _getFoodDom, _getImgDomForFoodDom, _getInfoDomForFoodDom, _getInitPriceForBottomWrapDom, _getMinPriceForBottomWrapDom, _getTagLabelForTopWrapDom, _getTopWrapDomForInfoDom, _selectFoodDisplayByCurrentChoose, _setCurrentChoose;

    _bookDishDom = getById("book-dish-wrap");

    _foodInfo = getById("book-info-wrap");

    _foodInfoImgDom = query(".food-img-wrapper img", _foodInfo);

    _foodInfoImgDom.style.height = (clientWidth * 200 / 375) + "px";

    _foodInfoDom = query(".full-part", _foodInfo);

    _foodInfoIntroDom = query(".intro-wrap .intro", _foodInfo);

    _foods = [];

    _foodCurrentChoose = [0, 0];

    _getDCLabelForTopWrapDom = function(food) {
      var dcDom, num;
      dcDom = "";
      if (food.dcType === "discount") {
        num = food.dc;
        if (food.dc % 10 === 0) {
          num = numToChinese[Math.round(food.dc / 10)];
        } else {
          num = food.dc / 10;
        }
        dcDom = "<p class='dc-label'>" + num + "折</p>";
      } else if (food.dcType === "sale") {
        dcDom = "<p class='dc-label'>减" + food.dc + "元</p>";
      } else if (food.dcType === "half") {
        dcDom = "<p class='dc-label'>第二杯半价</p>";
      } else if (food.dcType === "limit") {
        dcDom = "<p class='dc-label'>剩" + food.dc + "件</p>";
      }
      return dcDom;
    };

    _getTagLabelForTopWrapDom = function(food) {
      var tagDom;
      tagDom = "";
      if (food.tag) {
        tagDom = "<p class='tag-label'>" + food.tag + "</p>";
      }
      return tagDom;
    };

    _getTopWrapDomForInfoDom = function(food) {
      var labelField, nameField, topWrapDom;
      topWrapDom = createDom("div");
      topWrapDom.className = "top-wrap";
      nameField = "<div class='name-field'> <p class='c-name'>" + food.cName + "</p> <p class='e-name'>" + food.eName + "</p> </div>";
      labelField = "<div class='label-field'> " + (_getDCLabelForTopWrapDom(food)) + " " + (_getTagLabelForTopWrapDom(food)) + " </div>";
      append(topWrapDom, nameField);
      append(topWrapDom, labelField);
      return topWrapDom;
    };

    _getMinPriceForBottomWrapDom = function(food) {
      var minPrice;
      if (food.dcType === "none" || food.dcType === "half" || !food.dcType || food.dcType === "limit") {
        minPrice = "<p class='min-price money'>" + food.defaultPrice + "</p>";
      } else if (food.dcType === "discount") {
        minPrice = "<p class='min-price money'>" + (Number((food.defaultPrice * food.dc / 100).toFixed(2))) + "</p>";
      } else if (food.dcType === "sale") {
        minPrice = "<p class='min-price money'>" + (Number((food.defaultPrice - food.dc).toFixed(2))) + "</p>";
      }
      return minPrice;
    };

    _getInitPriceForBottomWrapDom = function(food) {
      var initPrice;
      initPrice = "<p class='init-price money'>" + food.defaultPrice + "</p>";
      if (food.dcType === "none" || food.dcType === "half" || !food.dcType || food.dcType === "limit") {
        initPrice = "";
      }
      return initPrice;
    };

    _getBottomWrapForInfoDom = function(food) {
      var bottomWrapDom, controllField, priceField;
      bottomWrapDom = createDom("div");
      bottomWrapDom.className = "bottom-wrap font-number-word";
      priceField = "<div class='price-field'> " + (_getMinPriceForBottomWrapDom(food)) + " " + (_getInitPriceForBottomWrapDom(food)) + " </div>";
      controllField = "<div class='controll-field'> <div class='minus-field btn hide'> <div class='img'></div> </div> <div class='number-field hide'> <p class='num'>0</p> </div> <div class='plus-field btn'> <div class='img'></div> </div> </div>";
      append(bottomWrapDom, priceField);
      append(bottomWrapDom, controllField);
      return bottomWrapDom;
    };

    _getImgDomForFoodDom = function(food) {
      var imgDom;
      if (!food.url) {
        return null;
      }
      imgDom = createDom("div");
      imgDom.className = "left-part";
      imgDom.innerHTML = "<div class='img-field'><img src='" + food.url + "'></div>";
      return imgDom;
    };

    _getInfoDomForFoodDom = function(food) {
      var bottomWrapDom, infoDom, topWrapDom;
      infoDom = createDom("div");
      if (food.url) {
        infoDom.className = "right-part";
      } else {
        infoDom.className = "full-part";
      }
      topWrapDom = _getTopWrapDomForInfoDom(food);
      bottomWrapDom = _getBottomWrapForInfoDom(food);
      append(infoDom, topWrapDom);
      append(infoDom, bottomWrapDom);
      return infoDom;
    };

    _getFoodDom = function(food) {
      var corresFoodListDom, dom, fivePercentLeftLine, foodInfoDom, imgDom, infoDom;
      dom = createDom("li");
      dom.id = "food-" + food.seqNum;
      foodInfoDom = createDom("div");
      foodInfoDom.className = "food-info-field";
      imgDom = _getImgDomForFoodDom(food);
      infoDom = _getInfoDomForFoodDom(food);
      if (imgDom) {
        append(foodInfoDom, imgDom);
      }
      append(foodInfoDom, infoDom);
      append(dom, foodInfoDom);
      fivePercentLeftLine = createDom("div");
      fivePercentLeftLine.className = "fivePercentLeftLine";
      corresFoodListDom = query(".food-list-wrap #food-list-" + food.categorySeqNum);
      append(corresFoodListDom, dom);
      append(corresFoodListDom, fivePercentLeftLine);
      return dom;
    };

    _setCurrentChoose = function(categorySeqNum, seqNum) {
      _foodCurrentChoose[0] = categorySeqNum;
      _foodCurrentChoose[1] = seqNum;
      return locStor.set("foodCurrentChoose", JSON.stringify(_foodCurrentChoose));
    };

    _getCurrentChooseFromLocStor = function() {
      var choose;
      choose = locStor.get("foodCurrentChoose") || "[0, 0]";
      choose = JSON.parse(choose);
      if (_foods[choose[0]][choose[1]]) {
        return deepCopy(choose, _foodCurrentChoose);
      } else {
        return _foodCurrentChoose = [0, 0];
      }
    };

    _selectFoodDisplayByCurrentChoose = function() {
      var currentFooInfoDom, food;
      food = _foods[_foodCurrentChoose[0]][_foodCurrentChoose[1]];
      _foodInfo.style.height = (getAdaptHeight(_bookDishDom, _foodInfo)) + "px";
      _foodInfoImgDom.src = food.url;
      currentFooInfoDom = query(".full-part", food.foodDom) || query(".right-part", food.foodDom);
      _foodInfoDom.innerHTML = currentFooInfoDom.innerHTML;
      return _foodInfoIntroDom.innerHTML = food.intro;
    };

    function Food(options) {
      deepCopy(options, this);
      this.init();
      _foods[this.categorySeqNum].push(this);
    }

    Food.prototype.init = function() {
      this.initFoodDom();
      return this.initAllEvent();
    };

    Food.prototype.initFoodDom = function() {
      return this.foodDom = _getFoodDom(this);
    };

    Food.prototype.initAllEvent = function() {
      var self;
      self = this;
      return addListener(self.foodDom, "click", function() {
        _setCurrentChoose(self.categorySeqNum, self.seqNum);
        return hashRoute.pushHashStr("bookInfo");
      });
    };

    Food.initial = function() {
      var dishJSON, food, i, j, k, l, len, ref1, results, tempOuter;
      dishJSON = getJSON(getDishJSON());
      for (i = k = 0, ref1 = dishJSON.length - 1; 0 <= ref1 ? k <= ref1 : k >= ref1; i = 0 <= ref1 ? ++k : --k) {
        if (!dishJSON[i]) {
          continue;
        }
        _foods[i] = [];
      }
      results = [];
      for (i = l = 0, len = dishJSON.length; l < len; i = ++l) {
        tempOuter = dishJSON[i];
        j = 0;
        results.push((function() {
          var results1;
          results1 = [];
          while (tempOuter[j]) {
            food = new Food({
              dc: tempOuter[j].dc,
              dcType: tempOuter[j].dc_type,
              defaultPrice: tempOuter[j].defaultprice,
              id: tempOuter[j].dishid,
              cName: tempOuter[j].dishname,
              eName: tempOuter[j].dishname2,
              url: tempOuter[j].dishpic,
              categorySeqNum: i,
              seqNum: j,
              tag: tempOuter[j].tag,
              intro: tempOuter[j].intro || ""
            });
            results1.push(j++);
          }
          return results1;
        })());
      }
      return results;
    };

    Food.chooseFoodByCurrentChoose = function() {
      _getCurrentChooseFromLocStor();
      return _selectFoodDisplayByCurrentChoose();
    };

    return Food;

  })();
  Activity = (function() {
    var _activities, _activityContainerDom, _activityCurrentChoose, _activityHomeDisplayChooseUlDom, _activityHomeDisplayUlDom, _activityInfoContentDom, _activityInfoImgDom, _activityInfoImgFieldDom, _activityInfoIntroDom, _activityInfoTimeDom, _activityInfoTitleNameDom, _activityInfoTypeDom, _activityInformationDom, _activityPromotionUlDom, _activityThemeUlDom, _activityTypeNum, _allActivityType, _getActivityDetailInfoDom, _getActivityDisplayChooseDom, _getActivityDisplayDom, _getActivityTypeContainerDom, _getCurrentChooseFromLocStor, _initContainerDomByAllActivity, _initTypeUlDom, _selectActivityDisplayByCurrentChoose, _setCurrentChoose;

    _allActivityType = ["promotion", "theme"];

    _activityHomeDisplayUlDom = query("#Menu-page .activity-display-list");

    _activityHomeDisplayChooseUlDom = query("#Menu-page .choose-dot-list");

    _activityContainerDom = query("#Activity-page #Activity-container-column .activity-container-wrapper");

    _activityPromotionUlDom = null;

    _activityThemeUlDom = null;

    _activityTypeNum = {
      "promotion": 0,
      "theme": 0
    };

    _activities = [];

    _activityCurrentChoose = 0;

    _activityInformationDom = query(".Activity-information-field");

    _activityInfoImgFieldDom = query("#activity-info-img-field .img-field", _activityInformationDom);

    _activityInfoImgDom = query("img", _activityInfoImgFieldDom);

    _activityInfoTypeDom = query(".title-type", _activityInformationDom);

    _activityInfoTitleNameDom = query("#activity-info-title-field .name", _activityInformationDom);

    _activityInfoIntroDom = query("#activity-info-title-field .intro", _activityInformationDom);

    _activityInfoTimeDom = query("#activity-info-time-field .time", _activityInformationDom);

    _activityInfoContentDom = query("#activity-info-content-field .content", _activityInformationDom);

    _activityInfoImgFieldDom.style.height = (clientWidth * 0.9 * 167 / 343) + "px";

    _getActivityDisplayDom = function(activity) {
      var dom;
      dom = createDom("li");
      dom.id = "activity-" + activity.seqNum;
      dom.innerHTML = "<img src='" + activity.displayUrl + "' alt='活动详情' class='activity-img'>";
      append(_activityHomeDisplayUlDom, dom);
      return dom;
    };

    _getActivityDisplayChooseDom = function(activity) {
      var dom;
      dom = createDom("li");
      dom.id = "choose-dot-" + activity.seqNum;
      dom.className = "inactive";
      dom.innerHTML = "<div class='dot'></div>";
      append(_activityHomeDisplayChooseUlDom, dom);
      return dom;
    };

    _getActivityDetailInfoDom = function(activity) {
      var dom, lineDom, type, ulDom;
      dom = createDom("li");
      dom.id = "activity-basic-info-" + activity.seqNum;
      dom.className = "activity-basic-info";
      dom.innerHTML = "<img src='" + activity.detailUrl + "' alt='活动详情'> <div class='info'> <p class='activity-name'>" + activity.title + "</p> <p class='activity-intro'>" + activity.intro + "</p> </div> <div class='arrow'></div>";
      if (activity.type === "theme") {
        ulDom = _activityThemeUlDom;
        type = "theme";
      } else {
        ulDom = _activityPromotionUlDom;
        type = "promotion";
      }
      if (_activityTypeNum[type] !== 0) {
        lineDom = createDom("div");
        lineDom.className = "fivePercentLeftLine";
        append(ulDom, lineDom);
      }
      _activityTypeNum[type]++;
      append(ulDom, dom);
      return dom;
    };

    _getActivityTypeContainerDom = function(type, title) {
      var dom;
      dom = createDom("div");
      dom.id = "activity-" + type + "-field";
      dom.innerHTML = "<div class='title-field'> <p class='title'>" + title + "</p> </div> <ul class='activity-" + type + "-list'></ul>";
      return append(_activityContainerDom, dom);
    };

    _initContainerDomByAllActivity = function(activities) {
      var activity, allTypeExist, k, l, len, len1, len2, m, results, title, type;
      allTypeExist = {};
      for (k = 0, len = _allActivityType.length; k < len; k++) {
        type = _allActivityType[k];
        allTypeExist[type] = false;
      }
      for (l = 0, len1 = activities.length; l < len1; l++) {
        activity = activities[l];
        type = activity.type || "";
        if (type === "theme") {
          allTypeExist[type] = true;
        } else if (type) {
          allTypeExist["promotion"] = true;
        }
      }
      results = [];
      for (m = 0, len2 = _allActivityType.length; m < len2; m++) {
        type = _allActivityType[m];
        if (allTypeExist[type]) {
          if (type === "promotion") {
            title = "促销优惠";
          } else {
            title = "主题活动";
          }
          results.push(_getActivityTypeContainerDom(type, title));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    _initTypeUlDom = function() {
      _activityPromotionUlDom = query(".activity-promotion-list", _activityContainerDom);
      return _activityThemeUlDom = query(".activity-theme-list", _activityContainerDom);
    };

    _setCurrentChoose = function(seqNum) {
      _activityCurrentChoose = seqNum;
      return locStor.set("activityCurrentChoose", seqNum);
    };

    _getCurrentChooseFromLocStor = function() {
      var choose;
      choose = locStor.get("activityCurrentChoose") || 0;
      if (_activities[choose]) {
        return _activityCurrentChoose = Number(choose);
      } else {
        return _activityCurrentChoose = 0;
      }
    };

    _selectActivityDisplayByCurrentChoose = function() {
      var corresActivity, typeName;
      corresActivity = _activities[_activityCurrentChoose];
      if (corresActivity.type === "theme") {
        typeName = "主题";
      } else {
        typeName = "促销";
      }
      _activityInfoImgDom.setAttribute("src", corresActivity.detailUrl);
      _activityInfoTypeDom.innerHTML = typeName;
      _activityInfoTitleNameDom.innerHTML = corresActivity.title;
      _activityInfoIntroDom.innerHTML = corresActivity.intro;
      _activityInfoTimeDom.innerHTML = corresActivity.dateBegin + " - " + corresActivity.dateEnd;
      return _activityInfoContentDom.innerHTML = corresActivity.content;
    };

    function Activity(options) {
      deepCopy(options, this);
      this.init();
      _activities.push(this);
    }

    Activity.prototype.init = function() {
      this.initActivityHomeDisplayDom();
      this.initActivityHomeDisplayChooseDom();
      this.initActivityDetailInfoDom();
      return this.initAllEvent();
    };

    Activity.prototype.initActivityHomeDisplayDom = function() {
      return this._activityHomeDisplayDom = _getActivityDisplayDom(this);
    };

    Activity.prototype.initActivityHomeDisplayChooseDom = function() {
      return this._activityHomeDisplayChooseDom = _getActivityDisplayChooseDom(this);
    };

    Activity.prototype.initActivityDetailInfoDom = function() {
      return this._activityDetailInfoDom = _getActivityDetailInfoDom(this);
    };

    Activity.prototype.initAllEvent = function() {
      var self;
      self = this;
      return addListener(self._activityDetailInfoDom, "click", function() {
        _setCurrentChoose(self.seqNum);
        return hashRoute.pushHashStr("activityInfo");
      });
    };

    Activity.initial = function() {
      var activity, activityJSON, i, k, len;
      activityJSON = getJSON(getActivityJSON());
      _initContainerDomByAllActivity(activityJSON);
      _initTypeUlDom();
      for (i = k = 0, len = activityJSON.length; k < len; i = ++k) {
        activity = activityJSON[i];
        activity = new Activity({
          seqNum: i,
          id: activity.id,
          displayUrl: activity.pic,
          infoUrl: activity.pic,
          detailUrl: activity.pic,
          dateBegin: activity.date_begin,
          dateEnd: activity.date_end,
          intro: activity.intro || "",
          content: activity.content,
          isValid: activity.is_valid,
          title: activity.title,
          type: activity.type
        });
      }
      return new rotateDisplay({
        displayCSSSelector: "#Menu-page .activity-display-list",
        chooseCSSSelector: "#Menu-page .choose-dot-list",
        scale: 110 / 377,
        delay: 3000
      });
    };

    Activity.chooseActivityByCurrentChoose = function() {
      _getCurrentChooseFromLocStor();
      return _selectActivityDisplayByCurrentChoose();
    };

    return Activity;

  })();
  User = (function() {
    var _IndividualDom, _alreadyLoginDom, _balanceDom, _checkEXPByLadder, _currentEXPBarDom, _currentEXPFullValueDom, _currentEXPValueDom, _discountDom, _getCorresIndexFromLadder, _initIsOverlap, _initLadder, _isOverlap, _ladder, _lvDom, _memberImgDom, _memberNameDom, _setCurrentMemberRankInfo, _updateCurrentMemberRankDom;

    _IndividualDom = getById("Individual-page");

    _alreadyLoginDom = query(".Already-login-field", _IndividualDom);

    _lvDom = query(".rank-field p.rank", _alreadyLoginDom);

    _memberNameDom = query(".rank-field p.member-name", _alreadyLoginDom);

    _memberImgDom = query(".member-img-pos #rank-img", _alreadyLoginDom);

    _discountDom = query(".discount-field p.discount", _alreadyLoginDom);

    _balanceDom = query(".remainder-EXP-Blend p.remainder-number", _alreadyLoginDom);

    _currentEXPValueDom = query(".current-value", _alreadyLoginDom);

    _currentEXPFullValueDom = query(".full-value", _alreadyLoginDom);

    _currentEXPBarDom = query(".inner-bar", _alreadyLoginDom);

    _isOverlap = {};

    _ladder = [];

    _initIsOverlap = function(comPre) {
      _isOverlap["discount"] = Boolean(comPre & 1);
      _isOverlap["sale"] = Boolean(comPre & 2);
      _isOverlap["half"] = Boolean(comPre & 4);
      return _isOverlap["limit"] = Boolean(comPre & 8);
    };

    _initLadder = function(ladder) {
      return deepCopy(ladder, _ladder);
    };

    _getCorresIndexFromLadder = function(user) {
      var expInfo, fullFlag, i, index, k, len;
      fullFlag = true;
      index = 0;
      for (i = k = 0, len = _ladder.length; k < len; i = ++k) {
        expInfo = _ladder[i];
        if (expInfo.EXP > user.EXP) {
          index = i - 1;
          fullFlag = false;
          break;
        }
      }
      return {
        fullFlag: fullFlag,
        index: index
      };
    };

    _updateCurrentMemberRankDom = function(user) {
      var discountStr;
      _lvDom.innerHTML = "Lv." + user.currentRank;
      _memberImgDom.className = "member-rank-" + user.currentRank;
      _memberNameDom.innerHTML = user.rankName + "级会员";
      _currentEXPFullValueDom.innerHTML = user.currentFullEXP;
      _currentEXPBarDom.style.width = "";
      if (user.discount >= 100) {
        discountStr = "升级后尊享更多优惠";
      } else {
        discountStr = "VIP尊享" + ((user.discount / 10).toFixed(1)) + "折";
      }
      return _discountDom.innerHTML = discountStr;
    };

    _setCurrentMemberRankInfo = function(user, index, fullIndex) {
      user.currentRank = index;
      user.rankName = _ladder[index].name;
      user.discount = _ladder[index].discount;
      return user.currentFullEXP = _ladder[fullIndex].EXP;
    };

    _checkEXPByLadder = function(user) {
      var fullIndex, index, result;
      result = _getCorresIndexFromLadder(user);
      if (result.fullFlag) {
        index = _ladder.length - 1;
        fullIndex = index;
      } else {
        index = result.index;
        fullIndex = index + 1;
      }
      _setCurrentMemberRankInfo(user, index, fullIndex);
      return _updateCurrentMemberRankDom(user);
    };

    function User(options) {
      this.tryLoginAndUpdateInfo(options);
    }

    User.prototype.isLogin = function() {
      return this.id !== 0;
    };

    User.prototype.init = function() {
      this.setBalance(this.balance);
      return this.setCurrentEXP(this.EXP);
    };

    User.prototype.setBalance = function(balance) {
      this.balance = balance;
      return _balanceDom.innerHTML = this.balance;
    };

    User.prototype.setCurrentEXP = function(EXP) {
      this.EXP = EXP;
      _currentEXPValueDom.innerHTML = this.EXP;
      _checkEXPByLadder(this);
      return _currentEXPBarDom.style.width = (100 * this.EXP / this.currentFullEXP) + "%";
    };

    User.prototype.tryLoginAndUpdateInfo = function(options) {
      deepCopy(options, this);
      return this.init();
    };

    User.initial = function() {
      var ComPreJSON, MemberJSON;
      ComPreJSON = getJSON(getComPreJSON());
      MemberJSON = getJSON(getMemberJSON());
      _initIsOverlap(ComPreJSON);
      _initLadder(MemberJSON.membership.ladder);
      return user = new User({
        avatar: MemberJSON.avatar,
        birthday: MemberJSON.birthday,
        city: MemberJSON.city,
        country: MemberJSON.country,
        mobile: MemberJSON.mobile,
        nickName: MemberJSON.nickname,
        province: MemberJSON.province,
        registerTime: MemberJSON.register_time,
        sex: MemberJSON.sex,
        signature: MemberJSON.signature,
        id: MemberJSON.user,
        EXP: MemberJSON.membership.EXP,
        balance: MemberJSON.membership.balance
      });
    };

    return User;

  })();
  Recharge = (function() {
    var _amountValue, _getRechargeDom, _rechargeNum, _rechargeUlDom;

    _amountValue = [50, 150, 450, 750, 950];

    _rechargeUlDom = query("#Recharge-page .amount-list");

    _rechargeNum = 0;

    _getRechargeDom = function(recharge) {
      var dom, line;
      dom = createDom("li");
      dom.id = "amount-" + recharge.seqNum;
      dom.innerHTML = "<div class='amount-li-field'> <div class='basic-info-field vertical-center'> <p class='money price'>" + recharge.amountValue + "</p> <p class='get-higher-rank'></p> </div> <div class='choose-field'></div> </div>";
      if (_rechargeNum !== 0) {
        line = createDom("div");
        line.className = "fivePercentLeftLine";
        append(_rechargeUlDom, line);
      }
      append(_rechargeUlDom, dom);
      _rechargeNum++;
      return dom;
    };

    function Recharge(options) {
      deepCopy(options, this);
      this.init();
    }

    Recharge.prototype.init = function() {
      return this.initRechargeDom();
    };

    Recharge.prototype.initRechargeDom = function() {
      return this.rechargeDom = _getRechargeDom(this);
    };

    Recharge.initial = function() {
      var i, k, recharge, results;
      results = [];
      for (i = k = 0; k <= 4; i = ++k) {
        results.push(recharge = new Recharge({
          seqNum: i,
          amountValue: _amountValue[i]
        }));
      }
      return results;
    };

    return Recharge;

  })();
  rotateDisplay = (function() {
    var _autoRotateEvent, _getCompatibleTranslateCss, _touchEnd, _touchMove, _touchStart;

    _getCompatibleTranslateCss = function(ver, hor) {
      var config, k, len, result_;
      result_ = {};
      for (k = 0, len = compatibleCSSConfig.length; k < len; k++) {
        config = compatibleCSSConfig[k];
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
      if (!self._autoFlag) {
        self._autoFlag = true;
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
      rotateDisplay._autoFlag = false;
      rotateDisplay.startX = e.touches[0].clientX;
      rotateDisplay.startY = e.touches[0].clientY;
      rotateDisplay.currentX = e.touches[0].clientX;
      return rotateDisplay.currentY = e.touches[0].clientY;
    };


    /*
    		* 触摸的过程记录触摸所到达的坐标
     */

    _touchMove = function(e, rotateDisplay) {
      e.preventDefault();
      e.stopPropagation();
      rotateDisplay._autoFlag = false;
      rotateDisplay.currentX = e.touches[0].clientX;
      return rotateDisplay.currentY = e.touches[0].clientY;
    };


    /*
    		* 比较判断用户是倾向于左右滑动还是上下滑动
    		* 若为左右滑动，则根据用户滑动的地方，反向轮转播放动画(符合正常的滑动逻辑)
     */

    _touchEnd = function(e, rotateDisplay) {
      var activityNum, currentChoose, currentX, currentY, startX, startY, transIndex;
      rotateDisplay._autoFlag = false;
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
      var dom, k, len, ref1;
      deepCopy(options, this);
      this.displayUlDom = query(this.displayCSSSelector);
      this.chooseUlDom = query(this.chooseCSSSelector);
      ref1 = querys("img", this.displayUlDom);
      for (k = 0, len = ref1.length; k < len; k++) {
        dom = ref1[k];
        dom.style.height = (this.scale * clientWidth) + "px";
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
      var dom, k, len, ref1;
      this.displayContainerDom = this.displayUlDom.parentNode;
      this.displayContainerDom.style.overflowX = "hidden";
      this.allDisplayDom = querys("li", this.displayUlDom);

      /*
      			* 让所有的图片的宽度都能适应屏幕
       */
      ref1 = this.allDisplayDom;
      for (k = 0, len = ref1.length; k < len; k++) {
        dom = ref1[k];
        dom.style.width = clientWidth + "px";
      }
      this.activityNum = this.allDisplayDom.length;

      /*
      			* 扩充图片所在ul的长度
       */
      return this.displayUlDom.style.width = (clientWidth * this.activityNum) + "px";
    };

    rotateDisplay.prototype.initChoose = function() {
      var dom, i, k, len, ref1, results, self;
      this.chooseUlDom.parentNode.style.overflow = "hidden";
      self = this;
      this.allChooseDom = querys("li", this.chooseUlDom);
      this.chooseUlDom.style.width = (this.allChooseDom.length * 20) + "px";
      this.currentChoose = 0;
      this.allChooseDom[0].className = "active";
      ref1 = this.allChooseDom;
      results = [];
      for (i = k = 0, len = ref1.length; k < len; i = ++k) {
        dom = ref1[i];
        results.push(addListener(dom, "click", (function(i) {
          return function(e) {
            e.preventDefault();
            e.stopPropagation();
            self._autoFlag = false;
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
      this._autoFlag = true;
      return setTimeout(function() {
        return _autoRotateEvent(self);
      }, self.delay);
    };

    rotateDisplay.prototype.initTouchEvent = function() {
      var self;
      self = this;
      addListener(self.displayContainerDom, "touchstart", function(e) {
        return _touchStart(e, self);
      });
      addListener(self.displayContainerDom, "touchmove", function(e) {
        return _touchMove(e, self);
      });
      return addListener(self.displayContainerDom, "touchend", function(e) {
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
      return hashRoute.pushHashStr("Extra-extraContent-Recharge");
    });

    /*
    		_confirmRechargebtn = getById "recharge-confirm-column"
    		addListener _confirmRechargebtn, "click", -> hashRoute.pushHashStr("choosePaymentMethod")
     */
  })();
  hashRoute = (function() {
    var HomeBottom, HomeMenu, _activityInfoDom, _allExtraContentDoms, _allExtraContentId, _allExtraDoms, _allExtraFormDoms, _allExtraFormId, _allMainDetailDoms, _allMainDetailId, _allMainDoms, _allMainHomeDoms, _allMainHomeId, _allSecondary, _dynamicShowTarget, _extraMainDom, _getHashStr, _hashStateFunc, _hideAllExtra, _hideAllExtraContentPage, _hideAllExtraFormPage, _hideAllExtraPage, _hideAllMain, _hideAllMainDetailPage, _hideAllMainHomePage, _hideAllMainPage, _hideSecondaryPage, _hideTarget, _loc, _modifyTitle, _parseAndExecuteHash, _recentHash, _secondaryInfo, _staticShowTarget, _switchExtraPage, _switchFirstPage, _switchSecondaryPage, _titleDom, hashJump, popHashStr, pushHashStr;
    HomeBottom = (function() {
      var _allDoms, _state, bottomTouchEventTrigger, uncheckAllForBottomAndHideTarget;
      _state = "";
      _allDoms = querys("#nav-field .bottom-field div");
      uncheckAllForBottomAndHideTarget = function() {
        var dom, id, k, len, results;
        results = [];
        for (k = 0, len = _allDoms.length; k < len; k++) {
          dom = _allDoms[k];
          id = dom.id;
          dom.className = id + "-unchecked";
          results.push(_hideTarget(id + "-page"));
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
        uncheckAllForBottomAndHideTarget();
        getById(id).className = id + "-checked";
        return _staticShowTarget(id + "-page");
      };
      return {
        bottomTouchEventTrigger: bottomTouchEventTrigger,
        uncheckAllForBottomAndHideTarget: uncheckAllForBottomAndHideTarget
      };
    })();
    HomeMenu = (function() {
      var _activityColumnDom;
      _activityColumnDom = query("#Menu-page .activity-wrapper");
      return addListener(_activityColumnDom, "click", function() {
        return hashJump("-Detail-Activity");
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
    _allExtraContentId = ["Recharge-page", "Choose-payment-method-page"];
    _loc = window.location;
    _hashStateFunc = {
      "Home": {
        "push": function() {
          return _staticShowTarget("brae-home-page");
        },
        "pop": function() {
          return _hideAllMain();
        }
      },
      "Menu": {
        "push": function() {
          return HomeBottom.bottomTouchEventTrigger("Menu");
        },
        "pop": HomeBottom.uncheckAllForBottomAndHideTarget,
        "title": "餐牌"
      },
      "Already": {
        "push": function() {
          return HomeBottom.bottomTouchEventTrigger("Already");
        },
        "pop": HomeBottom.uncheckAllForBottomAndHideTarget,
        "title": "已点订单"
      },
      "Individual": {
        "push": function() {
          return HomeBottom.bottomTouchEventTrigger("Individual");
        },
        "pop": HomeBottom.uncheckAllForBottomAndHideTarget,
        "title": "个人信息"
      },
      "Detail": {
        "push": function() {
          return _staticShowTarget("brae-detail-page");
        },
        "pop": function() {
          return _hideAllMain();
        }
      },
      "Book": {
        "push": function() {
          return _staticShowTarget("Book-page");
        },
        "pop": function() {
          return _hideTarget("Book-page");
        }
      },
      "bookCol": {
        "push": function() {
          Category.chooseBookCategoryByCurrentChoose();
          return _staticShowTarget("book-order-column");
        },
        "pop": function() {
          return _hideTarget("book-order-column");
        }
      },
      "bookInfo": {
        "push": function() {
          Food.chooseFoodByCurrentChoose();
          return _dynamicShowTarget("book-info-wrap", "hide-right");
        },
        "pop": function() {
          return _hideTarget("book-info-wrap", "hide-right");
        }
      },
      "bookOrder": {
        "push": function() {
          return _dynamicShowTarget("book-order-wrap", "hide-left");
        },
        "pop": function() {
          return _hideTarget("book-order-wrap", "hide-left");
        }
      },
      "Activity": {
        "push": function() {
          return _staticShowTarget("Activity-page");
        },
        "pop": function() {
          return _hideTarget("Activity-page");
        }
      },
      "activityInfo": {
        "push": function() {
          Activity.chooseActivityByCurrentChoose();
          return _switchSecondaryPage("activityInfo", "Activity", _activityInfoDom);
        },
        "pop": function() {
          return _hideSecondaryPage(_activityInfoDom);
        }
      },
      "Extra": {
        "push": function() {
          return _staticShowTarget("extra");
        },
        "pop": function() {
          return _hideTarget("extra");
        }
      },
      "extraContent": {
        "push": function() {
          return _staticShowTarget("brae-payment-page");
        },
        "pop": function() {
          return _hideTarget("brae-payment-page");
        }
      },
      "Recharge": {
        "push": function() {
          _staticShowTarget("Recharge-page");
          if (!user.isLogin()) {
            return hashRoute.back();
          }
        },
        "pop": function() {
          return _hideTarget("Recharge-page");
        }
      },
      "choosePaymentMethod": {
        "push": function() {
          return _staticShowTarget("Choose-payment-method-page");
        },
        "pop": function() {
          return _hideTarget("Choose-payment-method-page");
        }
      },
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
      setTimeout(function() {
        return _staticShowTarget("extra");
      }, 0);
      if (indexOf.call(_allExtraContentId, id) >= 0) {
        setTimeout(function() {
          return _staticShowTarget("brae-payment-page");
        }, 50);
        return setTimeout(function() {
          return _dynamicShowTarget(id, "hide");
        }, 100);
      } else if (indexOf.call(_allExtraFormId, id) >= 0) {
        return _staticShowTarget("brae-form-page");
      }
    };
    _hideAllExtraPage = function() {
      var dom, k, len, results;
      results = [];
      for (k = 0, len = _allExtraDoms.length; k < len; k++) {
        dom = _allExtraDoms[k];
        results.push(addClass(dom, "hide"));
      }
      return results;
    };
    _hideAllExtraFormPage = function() {
      var dom, k, len, results;
      results = [];
      for (k = 0, len = _allExtraFormDoms.length; k < len; k++) {
        dom = _allExtraFormDoms[k];
        results.push(addClass(dom, "hide"));
      }
      return results;
    };
    _hideAllExtraContentPage = function() {
      var dom, k, len, results;
      results = [];
      for (k = 0, len = _allExtraContentDoms.length; k < len; k++) {
        dom = _allExtraContentDoms[k];
        results.push(addClass(dom, "hide"));
      }
      return results;
    };
    _hideAllExtra = function(async) {
      _hideAllExtraFormPage();
      _hideAllExtraContentPage();
      _hideAllExtraPage();
      return _hideTarget("extra");
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
        removeClass(pageDom, "hide-right");
      }
      return setTimeout("scrollTo(0, 0)", 0);
    };
    _hideSecondaryPage = function(pageDom) {
      return addClass(pageDom, "hide-right");
    };
    _hideAllMainPage = function() {
      var dom, k, len, results;
      results = [];
      for (k = 0, len = _allMainDoms.length; k < len; k++) {
        dom = _allMainDoms[k];
        results.push(addClass(dom, "hide"));
      }
      return results;
    };
    _hideAllMainHomePage = function() {
      var dom, k, len, results;
      results = [];
      for (k = 0, len = _allMainHomeDoms.length; k < len; k++) {
        dom = _allMainHomeDoms[k];
        results.push(addClass(dom, "hide"));
      }
      return results;
    };
    _hideAllMainDetailPage = function() {
      var dom, k, len, results;
      results = [];
      for (k = 0, len = _allMainDetailDoms.length; k < len; k++) {
        dom = _allMainDetailDoms[k];
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
      removeClass(getById(id), "hide");
      return setTimeout("scrollTo(0, 0)", 0);
    };
    _dynamicShowTarget = function(id, className) {
      removeClass(getById(id), "hide");
      return setTimeout(function() {
        removeClass(getById(id), className);
        return setTimeout("scrollTo(0, 0)", 0);
      }, 0);
    };
    _hideTarget = function(id, className) {
      var _target;
      _target = getById(id);
      if (className) {
        addClass(_target, className);
        setTimeout(function() {
          return addClass(_target, "hide");
        }, 400);
      } else {
        addClass(_target, "hide");
      }
      return setTimeout("scrollTo(0, 0)", 0);
    };
    _getHashStr = function() {
      return _loc.hash.replace("#", "");
    };
    _modifyTitle = function(str) {
      return _titleDom.innerHTML = str;
    };
    _parseAndExecuteHash = function(str) {
      var base, base1, base2, entry, hash_arr, i, k, l, last_state, len, len1, len2, m, n, o, old_arr, ref1, ref2, ref3, ref4, temp_counter;
      hash_arr = str.split("-");
      if (hash_arr.length <= 1 && hash_arr[0] === "") {
        return;
      }
      old_arr = _recentHash.split("-");
      hash_arr.splice(0, 1);
      old_arr.splice(0, 1);
      last_state = hash_arr[hash_arr.length - 1];
      if (str === _recentHash) {
        for (i = k = 0, len = hash_arr.length; k < len; i = ++k) {
          entry = hash_arr[i];
          if (entry && _hashStateFunc[entry]) {
            setTimeout((function(entry) {
              return function() {
                var base;
                return typeof (base = _hashStateFunc[entry])["push"] === "function" ? base["push"]() : void 0;
              };
            })(entry), i * 100);
          }
        }
        return;
      }
      temp_counter = {};
      for (l = 0, len1 = old_arr.length; l < len1; l++) {
        entry = old_arr[l];
        if (entry) {
          temp_counter[entry] = 1;
        }
      }
      for (m = 0, len2 = hash_arr.length; m < len2; m++) {
        entry = hash_arr[m];
        if (!entry) {
          continue;
        }
        if (temp_counter[entry]) {
          temp_counter[entry]++;
        } else {
          temp_counter[entry] = 1;
        }
      }
      for (i = n = ref1 = old_arr.length - 1; ref1 <= 0 ? n <= 0 : n >= 0; i = ref1 <= 0 ? ++n : --n) {
        if (old_arr[i] && _hashStateFunc[old_arr[i]] && temp_counter[old_arr[i]] === 1) {
          if (typeof (base = _hashStateFunc[old_arr[i]])["pop"] === "function") {
            base["pop"]();
          }
        }
      }
      for (i = o = 0, ref2 = hash_arr.length - 1; 0 <= ref2 ? o <= ref2 : o >= ref2; i = 0 <= ref2 ? ++o : --o) {
        if (hash_arr[i] && _hashStateFunc[hash_arr[i]] && temp_counter[hash_arr[i]] === 1) {
          if (ref3 = hash_arr[i], indexOf.call(_allSecondary, ref3) >= 0) {
            if (ref4 = hash_arr[i], indexOf.call(_secondaryInfo[hash_arr[i - 1]], ref4) >= 0) {
              if (typeof (base1 = _hashStateFunc[hash_arr[i]])["push"] === "function") {
                base1["push"]();
              }
            }
            continue;
          }
          if (typeof (base2 = _hashStateFunc[hash_arr[i]])["push"] === "function") {
            base2["push"]();
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
      parseAndExecuteHash: function() {
        return _parseAndExecuteHash(_getHashStr());
      }
    };
  })();
  Lock = (function() {})();
  LocStorSingleton = (function() {
    var LocStor, _instance;
    _instance = null;
    LocStor = (function() {
      var doc, store;

      function LocStor() {}

      store = window.localStorage;

      doc = document.documentElement;

      if (!store) {
        doc.type.behavior = 'url(#default#userData)';
      }

      LocStor.prototype.set = function(key, val, context) {
        if (store) {
          return store.setItem(key, val, context);
        } else {
          doc.setAttribute(key, value);
          return doc.save(context || 'default');
        }
      };

      LocStor.prototype.get = function(key, context) {
        if (store) {
          return store.getItem(key, context);
        } else {
          doc.load(context || 'default');
          return doc.getAttribute(key) || '';
        }
      };

      LocStor.prototype.rm = function(key, context) {
        if (store) {
          return store.removeItem(key, context);
        } else {
          context = context || 'default';
          doc.load(context);
          doc.removeAttribute(key);
          return doc.save(context);
        }
      };

      LocStor.prototype.clear = function() {
        if (store) {
          return store.clear();
        } else {
          return doc.expires = -1;
        }
      };

      return LocStor;

    })();
    return {
      getInstance: function() {
        if (_instance === null) {
          _instance = new LocStor();
        }
        return _instance;
      },
      initial: function() {
        return locStor = this.getInstance();
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
    LocStorSingleton.initial();
    User.initial();
    Recharge.initial();
    Activity.initial();
    Category.initial();
    Food.initial();
    if (location.hash === "") {
      setTimeout(function() {
        hashRoute.hashJump("-Home");
        return setTimeout(function() {
          hashRoute.pushHashStr("Menu");
          return setTimeout(function() {
            return hashRoute.pushHashStr("x");
          }, 100);
        }, 100);
      }, 100);
    } else {
      hashRoute.parseAndExecuteHash();
    }
    return new rotateDisplay({
      displayCSSSelector: "#Activity-page .header-display-list",
      chooseCSSSelector: "#Activity-page .choose-dot-list",
      scale: 200 / 375,
      delay: 3000
    });
  };
})(window, document);
