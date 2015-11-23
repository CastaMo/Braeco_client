do (window, document)->

	[addListener, removeListener, hasClass, addClass, removeClass, ajax, getElementsByClassName, isPhone, hidePhone, query, querys, remove, append, prepend, toggleClass, getObjectURL, deepCopy, getById, createDom] = [util.addListener, util.removeListener, util.hasClass, util.addClass, util.removeClass, util.ajax, util.getElementsByClassName, util.isPhone, util.hidePhone, util.query, util.querys, util.remove, util.append, util.prepend, util.toggleClass, util.getObjectURL, util.deepCopy, util.getById, util.createDom]

	clientWidth =  document.body.clientWidth
	clientHeight = document.documentElement.clientHeight

	compatibleCSSConfig = [
		""
		"-webkit-"
		"-moz-"
		"-ms-"
		"-o-"
	]

	numToChinese = ["零","一","二","三","四","五","六","七","八","九","十"]

	getJSON = (json)->
		if typeof json is "string" then json = JSON.parse(json)
		return json

	Lock = do ->

	class Category

		###
		* 八个静态私有变量
		* 1. 用于首页展示的ul的Dom, 里面存放displayDom
		* 2. 用于点餐页面顶栏ul的Dom, 里面存放bookCategoryDom
		* 3. 用于收揽展示餐品的Dom, 里面存放foodListDom
		* 4. 点餐页面用于给顶栏ul纪录调整宽度的值
		* 5. 所有category类的容器
		* 6. 当前选中的品类
		* 7. localStorage单例对象, 初始化放在静态公有函数initial中
		* 8. 调整宽度按照字符来计算, 1个字母为10px, 1个数字为11px, 1个空格为6px, 1个中文为16px
		###
		_catergoryDisplayUlDom = query "#Menu-page .category-display-list"
		_categoryBookCategoryUlDom = query "#book-category-wrap .tag-list"
		_foodListAllDom = query "#book-dish-wrap .food-list-wrap"
		_categoryBookCategoryUlWidth = 0
		_cateogries = []
		_locStor = null
		_currentChoose = 0

		_widthByContent = {
			"letter"	:	10
			"number"	:	11
			"space"		:	6
			"chinese"	:	16
		}

		###
		* 静态私有函数
		* 创建和返回displayDom, 并投放到_catergoryDisplayUlDom中
		* @param {Object} category类变量
		###
		_getDisplayDom = (category)->
			dom = createDom("li"); dom.id = "category-#{category.seqNum}"
			url = category.url || ""
			imgDomStr = "<img alt='标签' class='category-img' src=#{url}>"
			nameDomStr = "<div class='category-name-field'><p class='category-name'>#{category.name}</div>"
			dom.innerHTML = "#{imgDomStr}#{nameDomStr}"
			append _catergoryDisplayUlDom, dom
			return dom

		###
		* 静态私有函数
		* 创建和返回bookCategory的dom, 并投放在_categoryBookCategoryUlDom中
		* @param {Object} category类变量
		###
		_getBookCategoryDom = (category)->
			dom = createDom("li"); dom.id = "tag-list-#{category.seqNum}"
			dom.innerHTML = category.name
			width = _getWidthByContent(category.name)
			dom.style.width = "#{width}px"
			append _categoryBookCategoryUlDom, dom
			_categoryBookCategoryUlWidth += (width + 30)
			return dom

		###
		* 静态私有函数
		* 创建和返回foodList的dom, 并投放在_foodListAllDomm中
		* @param {Object} category类变量
		###
		_getFoodListDom = (category)->
			dom = createDom("ul"); dom.id = "food-list-#{category.seqNum}"; dom.className = "hide"
			append _foodListAllDom, dom
			return dom

		###
		* 静态私有函数
		* 得到对应的dom的长度
		* @param {String} dom的内容
		###
		_getWidthByContent = (str)->
			allLetter = str.match(/[a-z]/ig) || []
			allNumber = str.match(/[0-9]/ig) || []
			allSpace = str.match(/\s/ig) || []

			allLetterLength = allLetter.length
			allNumberLength = allNumber.length
			allSpaceLength = allSpace.length
			allChineseWordLength = str.length - allLetterLength - allNumberLength - allSpaceLength

			return (_widthByContent["letter"] * allLetterLength + 
					_widthByContent["number"] * allNumberLength +
					_widthByContent["space"] * allSpaceLength +
					_widthByContent["chinese"] * allChineseWordLength + 1)

		_updateBookCategoryDomWidth = -> _categoryBookCategoryUlDom.style.width = "#{_categoryBookCategoryUlWidth}px"

		_hideAllFoodListDom = -> addClass category.foodListDom, "hide" for category in _cateogries

		_unChooseAllBookCategoryDom = -> removeClass category.bookCategoryDom, "choose" for category in _cateogries

		_chooseBookCategoryByCurrentChoose = ->
			_unChooseAllBookCategoryDom()
			_hideAllFoodListDom()
			_getCurrentChooseFromLocStor()
			addClass _cateogries[_currentChoose].bookCategoryDom, "choose"
			removeClass _cateogries[_currentChoose].foodListDom, "hide"
			setTimeout(->
				_cateogries[_currentChoose].bookCategoryDom.scrollIntoView()
			, 0)

		_setCurrentChoose = (seqNum)-> _currentChoose = seqNum; _locStor.set("categoryCurrentChoose", seqNum)

		_getCurrentChooseFromLocStor = -> choose = _locStor.get("categoryCurrentChoose") || 0; _currentChoose = Number(choose)

		constructor: (options)->
			deepCopy options, @
			@init()
			_updateBookCategoryDomWidth()
			_cateogries.push @

		init: ->
			@initDisplayDom()
			@initBookCategoryDom()
			@initFoodListDom()
			@initEvent()

		initDisplayDom: -> @displayDom = _getDisplayDom @

		initBookCategoryDom: -> @bookCategoryDom = _getBookCategoryDom @

		initFoodListDom: -> @foodListDom = _getFoodListDom @

		initEvent: -> 
			self = @
			addListener self.displayDom, "click", -> _setCurrentChoose(self.seqNum); hashRoute.hashJump "-Detail-Book-bookCol"
			addListener self.bookCategoryDom, "click", -> _setCurrentChoose(self.seqNum); _chooseBookCategoryByCurrentChoose()

		@initial: ->
			_locStor = LocStorSingleton.getInstance()
			dishJSON = getJSON getDishJSON()
			for tempOuter, i in dishJSON
				category = new Category {
					name 		:		tempOuter.categoryname
					id 			:		tempOuter.id
					seqNum 		:		i
				}
		@chooseBookCategoryByCurrentChoose: _chooseBookCategoryByCurrentChoose

	class Food
		_foodInfo = getById "book-info-wrap"
		_foods = []
		_locStor = null

		_getDCLabelForTopWrapDom = (food)->
			dcDom = ""
			if food.dcType is "discount"
				num = food.dc; if food.dc % 10 is 0 then num = numToChinese[Math.round(food.dc / 10)] else num = food.dc/10
				dcDom = "<p class='dc-label'>#{num}折</p>"
			else if food.dcType is "sale" then dcDom = "<p class='dc-label'>减#{food.dc}元</p>"
			else if food.dcType is "half" then dcDom = "<p class='dc-label'>第二杯半价</p>"
			else if food.dcType is "limit" then dcDom = "<p class='dc-label'>剩#{food.dc}件</p>"
			return dcDom

		_getTagLabelForTopWrapDom = (food)->
			tagDom = ""
			if food.tag then tagDom = "<p class='tag-label'>#{food.tag}</p>"
			return tagDom

		_getTopWrapDomForInfoDom = (food)->
			topWrapDom = createDom("div"); topWrapDom.className = "top-wrap"
			nameField = "<div class='name-field'>
							<p class='c-name'>#{food.cName}</p>
							<p class='e-name'>#{food.eName}</p>
						</div>"
			labelField = "<div class='label-field'>
							#{_getDCLabelForTopWrapDom(food)}
							#{_getTagLabelForTopWrapDom(food)}
						</div>"
			
			append topWrapDom, nameField
			append topWrapDom, labelField
			return topWrapDom

		_getMinPriceForBottomWrapDom = (food)->
			if food.dcType is "none" or food.dcType is "half" or not food.dcType or food.dcType is "limit" then minPrice = "<p class='min-price money'>#{food.defaultPrice}</p>"
			else if food.dcType is "discount" then minPrice = "<p class='min-price money'>#{Number((food.defaultPrice * food.dc / 100).toFixed(2))}</p>"
			else if food.dcType is "sale" then minPrice = "<p class='min-price money'>#{Number((food.defaultPrice - food.dc).toFixed(2))}</p>"
			return minPrice

		_getInitPriceForBottomWrapDom = (food)->
			initPrice = "<p class='init-price money'>#{food.defaultPrice}</p>"
			if food.dcType is "none" or food.dcType is "half" or not food.dcType or food.dcType is "limit" then initPrice = ""
			return initPrice

		_getBottomWrapForInfoDom = (food)->
			bottomWrapDom = createDom("div"); bottomWrapDom.className = "bottom-wrap font-number-word"
			priceField = "<div class='price-field'>
							#{_getMinPriceForBottomWrapDom(food)}
							#{_getInitPriceForBottomWrapDom(food)}
						</div>"
			controllField = "<div class='controll-field'>
								<div class='minus-field btn'>
									<div class='img'></div>
								</div>
								<div class='number-field'>
									<p class='num'>0</p>
								</div>
								<div class='plus-field btn'>
									<div class='img'></div>
								</div>
							</div>"
			append bottomWrapDom, priceField
			append bottomWrapDom, controllField
			return bottomWrapDom
			

		_getImgDomForFoodDom = (food)->
			if not food.url then return null
			imgDom = createDom("div"); imgDom.className = "left-part"
			imgDom.innerHTML = "<div class='img-field'><img src='#{food.url}'></div>"
			return imgDom

		_getInfoDomForFoodDom = (food)->
			infoDom = createDom("div")
			if food.url then infoDom.className = "right-part"
			else infoDom.className = "full-part"
			topWrapDom = _getTopWrapDomForInfoDom(food)
			bottomWrapDom = _getBottomWrapForInfoDom(food)
			append infoDom, topWrapDom
			append infoDom, bottomWrapDom
			return infoDom

		_getFoodDom = (food)->
			dom = createDom("li"); dom.id = "food-#{food.seqNum}"
			foodInfoDom = createDom("div"); foodInfoDom.className = "food-info-field"

			imgDom = _getImgDomForFoodDom(food)
			infoDom = _getInfoDomForFoodDom(food)
			if imgDom then append foodInfoDom, imgDom
			append foodInfoDom, infoDom
			append dom, foodInfoDom

			fivePercentLeftLine = createDom("div"); fivePercentLeftLine.className = "fivePercentLeftLine"

			corresFoodListDom = query ".food-list-wrap #food-list-#{food.categorySeqNum}"
			append corresFoodListDom, dom
			append corresFoodListDom, fivePercentLeftLine

			return dom



		constructor: (options)->
			deepCopy options, @
			@init()
			_foods[@categorySeqNum].push @

		init: ->
			@initFoodDom()

		initFoodDom: ->
			@foodDom = _getFoodDom @

		@initial: ->
			_locStor = LocStorSingleton.getInstance()
			dishJSON = getJSON getDishJSON()
			for i in [0..dishJSON.length-1]
				if not dishJSON[i] then continue
				_foods[i] = []
			for tempOuter, i in dishJSON
				j = 0
				while tempOuter[j]
					console.log(tempOuter[j])
					food = new Food {
						dc 				:		tempOuter[j].dc
						dcType 			:		tempOuter[j].dc_type
						defaultPrice	:		tempOuter[j].defaultprice
						id 				:		tempOuter[j].dishid
						cName 			:		tempOuter[j].dishname
						eName 			:		tempOuter[j].dishname2
						url 			:		tempOuter[j].dishpic
						categorySeqNum 	:		i
						tag 			:		tempOuter[j].tag
					}
					console.log food
					j++



	class Activity
		_activityInformationDom = query ".Activity-information-field"
		_activityInfoImgDom = query "#activity-info-img-field", _activityInformationDom
		_activityInfoImgDom.style.height = "#{clientWidth * 0.9 * 167 / 343}px"

		for dom in querys "#Activity-container-column li"
			addListener dom, "click", -> hashRoute.pushHashStr("activityInfo")


	class rotateDisplay

		_getCompatibleTranslateCss = (ver, hor)->
			result_ = {}
			for config in compatibleCSSConfig
				result_["#{config}transform"] = "translate(#{ver}, #{hor})"
			return result_

		_autoRotateEvent = (rotateDisplay)->
			self = rotateDisplay

			###
			* 监视autoFlag
			###
			if not self.autoFlag then self.autoFlag = true
			else
				index = (self.currentChoose + 1) % self.activityNum
				self.setCurrentChooseAndTranslate(index)
			setTimeout(->
				_autoRotateEvent(self)
			, self.delay)


		###
		* 触摸开始的时候记录初始坐标位置
		###
		_touchStart = (e, rotateDisplay)->
			rotateDisplay.autoFlag = false
			#e.preventDefault()
			#e.stopPropagation()
			rotateDisplay.startX = e.touches[0].clientX
			rotateDisplay.startY = e.touches[0].clientY
			rotateDisplay.currentX = e.touches[0].clientX
			rotateDisplay.currentY = e.touches[0].clientY

		###
		* 触摸的过程记录触摸所到达的坐标
		###
		_touchMove = (e, rotateDisplay)->
			rotateDisplay.autoFlag = false
			rotateDisplay.currentX = e.touches[0].clientX
			rotateDisplay.currentY = e.touches[0].clientY
			e.preventDefault()
			e.stopPropagation()

		###
		* 比较判断用户是倾向于左右滑动还是上下滑动
		* 若为左右滑动，则根据用户滑动的地方，反向轮转播放动画(符合正常的滑动逻辑)
		###
		_touchEnd = (e, rotateDisplay)->
			rotateDisplay.autoFlag = false
			currentX = rotateDisplay.currentX
			currentY = rotateDisplay.currentY
			startX = rotateDisplay.startX
			startY = rotateDisplay.startY
			if Math.abs(currentY - startY) >= Math.abs(currentX - startX) then return
			currentChoose = rotateDisplay.currentChoose; activityNum = rotateDisplay.activityNum
			if currentX < startX then transIndex = (currentChoose + 1) % activityNum
			else if currentX > startX then transIndex = (currentChoose - 1 + activityNum) % activityNum
			rotateDisplay.setCurrentChooseAndTranslate(transIndex)


		###
		* 图片轮转播放
		* @param {Object} options: 组件配置
		*
		* 调用方法:
		* 直接通过构造函数，传入对应的对象配置即可。
		* displayCSSSelector为图片所在的ul的css选择器
		* chooseCSSSelector为图片对应的标号索引所在的ul的css选择器
		* delay为图片每次轮转的时间
		###

		constructor: (options)->
			@displayUlDom = query options.displayCSSSelector
			@chooseUlDom = query options.chooseCSSSelector
			@delay = options.delay
			dom.style.height = "#{options.scale * clientWidth}px" for dom in querys "img", @displayUlDom
			@init()

		init: ->
			@initDisplay()
			@initChoose()
			@initAutoRotate()
			@initTouchEvent()

		initDisplay: ->
			@displayContainerDom = @displayUlDom.parentNode
			@displayContainerDom.style.overflowX = "auto"
			@allDisplayDom = querys "li", @displayUlDom

			###
			* 让所有的图片的宽度都能适应屏幕
			###

			for dom in @allDisplayDom
				dom.style.width = "#{clientWidth}px"
			@activityNum = @allDisplayDom.length

			###
			* 扩充图片所在ul的长度
			###
			@displayUlDom.style.width = "#{clientWidth * @activityNum}px"

		initChoose: ->
			@chooseUlDom.parentNode.style.overflow = "hidden"
			self = @
			@allChooseDom = querys "li", @chooseUlDom
			@currentChoose = 0
			for dom, i in @allChooseDom
				addListener dom, "click", do (i)-> (e)-> e.preventDefault(); e.stopPropagation(); self.autoFlag = false; self.setCurrentChooseAndTranslate(i)

		initAutoRotate: ->
			###
			* autoFlag用于监视是否有人工操作，如果有，则当前最近一次不做播放，重新设置autoFlag，使得下一次播放正常进行
			###
			self = @
			@autoFlag = true
			setTimeout(->
				_autoRotateEvent(self)
			, self.delay)

		initTouchEvent: ->
			self = @
			addListener @displayContainerDom, "touchstart", (e)-> _touchStart(e, self)
			addListener @displayContainerDom, "touchmove", (e)-> _touchMove(e, self)
			addListener @displayContainerDom, "touchend", (e)-> _touchEnd(e, self)

		setCurrentChoose: (index)->
			@allChooseDom[@currentChoose].className = "inactive"
			@allChooseDom[index].className = "active"
			@currentChoose = index

		setCurrentChooseAndTranslate: (index)->
			if index < 0 or index >= @activityNum or index is @currentChoose then return
			transIndex =  -1 * index
			compatibleTranslateCss = _getCompatibleTranslateCss("#{transIndex * clientWidth}px", 0)
			for key, value of compatibleTranslateCss
				@displayUlDom.style[key] = value
			@setCurrentChoose(index)

	Menu = do ->

		_allDishDoms = querys "#book-dish-wrap .food-list-wrap li"
		for dom in _allDishDoms
			addListener dom, "click", -> hashRoute.pushHashStr("bookInfo")

	Individual = do ->
		_rechargeFuncDom = getById "Recharge-func"
		addListener _rechargeFuncDom, "click", -> hashRoute.pushHashStr("Extra-extraContent-Recharge")

		_confirmRechargebtn = getById "recharge-confirm-column"
		addListener _confirmRechargebtn, "click", -> hashRoute.pushHashStr("choosePaymentMethod")

	hashRoute = do ->

		HomeBottom = do ->
			_state = ""
			_allDoms = querys "#nav-field .bottom-field div"


			uncheckAllForBottomAndHideTarget = ->
				for dom in _allDoms
					id = dom.id; dom.className = "#{id}-unchecked"; _hideTarget("#{id}-page")

			bottomTouchEventTrigger = (id)->
				if _state isnt id
					###
					*WebSocketxxxxx
					###
				_state = id
				uncheckAllForBottomAndHideTarget()
				getById(id).className = "#{id}-checked"
				_staticShowTarget("#{id}-page")


			bottomTouchEventTrigger: bottomTouchEventTrigger
			uncheckAllForBottomAndHideTarget: uncheckAllForBottomAndHideTarget

		HomeMenu = do ->
			
			_activityColumnDom = query "#Menu-page .activity-wrapper"

			addListener _activityColumnDom, "click", -> hashJump("-Detail-Activity")

		_extraMainDom = getById "#extra"


		_allMainDoms = querys ".main-page"
		_allMainHomeDoms = querys ".main-home-page"
		_allMainDetailDoms = querys ".main-detail-page"

		_allExtraDoms = querys ".extra-page"
		_allExtraFormDoms = querys ".extra-form-page"
		_allExtraContentDoms = querys ".extra-content-page"

		_activityInfoDom = query ".Activity-information-field"


		_allSecondary = ["activityInfo"]

		_secondaryInfo =
			"Activity": ["activityInfo"]

		_allMainHomeId = ["Menu-page", "Already-page", "Individual-page"]
		_allMainDetailId = ["Book-page", "Activity-page"]
		_allExtraFormId = ["login-page", "book-choose-page", "remark-for-trolley-page", "alert-page", "confirm-page"]
		_allExtraContentId = ["Recharge-page", "Choose-payment-method-page"]


		_loc = window.location
		_hashStateFunc = {
			"Home": {
				"push": -> _staticShowTarget("brae-home-page")
				"pop": -> _hideAllMain()
			}
			"Menu": {
				"push": -> HomeBottom.bottomTouchEventTrigger("Menu")
				"pop": HomeBottom.uncheckAllForBottomAndHideTarget
				"title": "餐牌"
			}
			"Already": {
				"push": -> HomeBottom.bottomTouchEventTrigger("Already")
				"pop": HomeBottom.uncheckAllForBottomAndHideTarget
				"title": "已点订单"
			}
			"Individual": {
				"push": -> HomeBottom.bottomTouchEventTrigger("Individual")
				"pop": HomeBottom.uncheckAllForBottomAndHideTarget
				"title": "个人信息"
			}
			"Detail": {
				"push": -> _staticShowTarget("brae-detail-page")
				"pop": -> _hideAllMain()
			}
			"Book": {
				"push": -> _staticShowTarget("Book-page")
				"pop": -> _hideTarget("Book-page")
			}
			"bookCol": {
				"push": -> Category.chooseBookCategoryByCurrentChoose(); _staticShowTarget("book-order-column")
				"pop": -> _hideTarget("book-order-column")
			}
			"bookInfo": {
				"push": -> _dynamicShowTarget("book-info-wrap", "hide-right")
				"pop": -> _hideTarget("book-info-wrap", "hide-right")
			}
			"Activity": {
				"push": -> _staticShowTarget("Activity-page")
				"pop": -> _hideTarget("Activity-page")
			}
			"activityInfo": {
				"push": -> _switchSecondaryPage("activityInfo", "Activity", _activityInfoDom)
				"pop": -> _hideSecondaryPage(_activityInfoDom)
			}
			"Extra": {
				"push": -> _staticShowTarget("extra")
				"pop": -> _hideTarget("extra")
			}
			"extraContent": {
				"push": -> _staticShowTarget("brae-payment-page")
				"pop": -> _hideTarget("brae-payment-page")
			}
			"Recharge": {
				"push": -> _staticShowTarget("Recharge-page")
				"pop": -> _hideTarget("Recharge-page")
			}
			"choosePaymentMethod": {
				"push": -> _staticShowTarget("Choose-payment-method-page")
				"pop": -> _hideTarget("Choose-payment-method-page")
			}
			"x": {
				"push": -> setTimeout(->
					popHashStr("x")
				,0)
				"pop": -> setTimeout(->
					popHashStr("x")
				,0)
			}
		}
		addListener window, "popstate", -> _parseAndExecuteHash _getHashStr()

		_titleDom = util.query("title")

		_recentHash = _loc.hash.replace("#", "")

		_switchExtraPage = (id)->
			setTimeout(->
				_staticShowTarget("extra")
			, 0)
			if id in _allExtraContentId
				setTimeout(->
					_staticShowTarget("brae-payment-page")
				, 50)
				setTimeout(->
					_dynamicShowTarget(id, "hide")
				, 100)
			else if id in _allExtraFormId then _staticShowTarget("brae-form-page")

		_hideAllExtraPage = -> addClass dom, "hide" for dom in _allExtraDoms

		_hideAllExtraFormPage = -> addClass dom, "hide" for dom in _allExtraFormDoms

		_hideAllExtraContentPage = -> addClass dom, "hide" for dom in _allExtraContentDoms

		_hideAllExtra = (async)->
			_hideAllExtraFormPage(); _hideAllExtraContentPage(); _hideAllExtraPage(); _hideTarget("extra")

		_switchFirstPage = (id)->
			_hideAllMain()
			if id in _allMainHomeId then _staticShowTarget("brae-home-page")
			else if id in _allMainDetailId then _staticShowTarget("brae-detail-page")
			_staticShowTarget(id)
			setTimeout("scrollTo(0, 0)", 0)

		_switchSecondaryPage = (currentState, previousState, pageDom)->
			if currentState in _secondaryInfo[previousState] then removeClass(pageDom, "hide-right")

		_hideSecondaryPage = (pageDom)-> addClass(pageDom, "hide-right")

		_hideAllMainPage = -> addClass dom, "hide" for dom in _allMainDoms

		_hideAllMainHomePage = -> addClass dom, "hide" for dom in _allMainHomeDoms

		_hideAllMainDetailPage = -> addClass dom, "hide" for dom in _allMainDetailDoms

		_hideAllMain = -> _hideAllMainHomePage(); _hideAllMainDetailPage(); _hideAllMainPage()

		_staticShowTarget = (id)-> removeClass(getById(id), "hide"); setTimeout("scrollTo(0, 0)", 0)

		_dynamicShowTarget = (id, className)-> removeClass(getById(id), className); setTimeout("scrollTo(0, 0)", 0)

		_hideTarget = (id, className)->
			_target = getById id
			if className then addClass _target, className
			else addClass _target, "hide"
			setTimeout("scrollTo(0, 0)", 0)

		_getHashStr =  -> _loc.hash.replace("#", "")

		_modifyTitle = (str)-> _titleDom.innerHTML = str

		_parseAndExecuteHash = (str)->
			hash_arr = str.split("-")
			if hash_arr.length <= 1 and hash_arr[0] is "" then return

			old_arr = _recentHash.split("-")
			hash_arr.splice(0, 1); old_arr.splice(0, 1)
			last_state = hash_arr[hash_arr.length-1]

			#if last_state and msgs[last_state] and msgs[last_state]["title"] then hashRoute.modifyTitle(msgs[last_state]["title"])


			if str is _recentHash
				for entry, i in hash_arr
					if entry and _hashStateFunc[entry] then setTimeout(do (entry)->
						-> _hashStateFunc[entry]["push"]?()
					, i * 100)
				return
			temp_counter = {}
			for entry in old_arr
				if entry then temp_counter[entry] = 1
			for entry in hash_arr
				if not entry then continue
				if temp_counter[entry] then temp_counter[entry]++
				else temp_counter[entry] = 1

			for i in [old_arr.length-1..0]
				if old_arr[i] and _hashStateFunc[old_arr[i]] and temp_counter[old_arr[i]] is 1 then _hashStateFunc[old_arr[i]]["pop"]?()
			for i in [0..hash_arr.length-1]
				if hash_arr[i] and _hashStateFunc[hash_arr[i]] and temp_counter[hash_arr[i]] is 1
					if hash_arr[i] in _allSecondary
						if hash_arr[i] in _secondaryInfo[hash_arr[i-1]] then _hashStateFunc[hash_arr[i]]["push"]?()
						continue
					_hashStateFunc[hash_arr[i]]["push"]?()

			_recentHash = str

		pushHashStr = (str)-> _loc.hash = "#{_recentHash}-#{str}"

		popHashStr = (str)-> _loc.hash = _recentHash.replace("-#{str}", "")

		hashJump = (str)-> _loc.hash = str

		ahead: -> history.go(1)

		back: -> history.go(-1)

		refresh: -> _loc.reload()

		pushHashStr: pushHashStr
		popHashStr: popHashStr
		hashJump: hashJump
		HomeBottom: HomeBottom
		parseAndExecuteHash: -> _parseAndExecuteHash _getHashStr()


	LocStorSingleton = do ->
		_instance = null
		class LocStor
			store = window.localStorage;doc = document.documentElement
			if !store then doc.type.behavior = 'url(#default#userData)'
			set: (key, val, context)->
				if store then store.setItem(key, val, context)
				else doc.setAttribute(key, value); doc.save(context || 'default')
			get: (key, context)->
				if store then store.getItem(key, context)
				else doc.load(context || 'default'); doc.getAttribute(key) || ''
			rm: (key, context)->
				if store then store.removeItem(key, context)
				else context = context || 'default';doc.load(context);doc.removeAttribute(key);doc.save(context)
			clear: ->
				if store then store.clear()
				else doc.expires = -1

		getInstance: ->
			if _instance is null then _instance = new LocStor()
			return _instance

	callpay = (options)->
		self = @
		if typeof wx isnt "undefined"
			wxConfigFailed = false
			wx.config({
				debug:false
				appId:"#{options.appid}"
				timestamp:options.timestamp
				nonceStr:"#{options.noncestr}"
				signature: "#{options.signature}"
				jsApiList: ['chooseWXPay']
			})
			wx.ready ->
				if wxConfigFailed then return
				wx.chooseWXPay {
					timestamp: options.timestamp
					nonceStr: "#{options.noncestr}"
					package: "#{options.package}"
					signType: 'MD5'
					paySign: "#{options.signMD}"
					success: (res)->
						options.always?()
						if res.errMsg is "chooseWXPay:ok" then innerCallback("success"); options.callback?()
						else innerCallback("fail", error("wx_result_fail", res.errMsg))
					cancel: (res)-> options.always?(); innerCallback("cancel")
					fail: (res)-> options.always?(); innerCallback("fail", error("wx_config_fail", res.errMsg))
				}
			wx.error (res)-> options.always?(); wxConfigFailed = true; innerCallback("fail", error("wx_config_error", res.errMsg))


	innerCallback = (result, err)->
		if typeof @_resultCallback is "function"
			if typeof err is "undefined" then err = @_error()
			@_resultCallback(result, err)


	window.onload = ->
		Category.initial()
		Food.initial()
		if location.hash is "" then setTimeout(->
			hashRoute.hashJump("-Home")
			setTimeout(->
				hashRoute.pushHashStr("Menu")
				setTimeout(->
					hashRoute.pushHashStr("x")
				, 100)
			, 100)
		, 100)
		else hashRoute.parseAndExecuteHash()
		###
		hashRoute.hashJump("-Home")
		setTimeout(->
			hashRoute.pushHashStr("Menu")
			setTimeout(->
				hashRoute.pushHashStr("x")
				
				setTimeout(->
					hashRoute.hashJump("-Detail-Book-bookCol")
					setTimeout(->
						hashRoute.pushHashStr("bookInfo")
					, 100)
				, 100)
				
			, 100)
		, 100)
		###
		new rotateDisplay {
			displayCSSSelector: "#Menu-page .activity-display-list"
			chooseCSSSelector: "#Menu-page .choose-dot-list"
			scale: 110/377
			delay: 3000
		}
		new rotateDisplay {
			displayCSSSelector: "#Activity-page .header-display-list"
			chooseCSSSelector: "#Activity-page .choose-dot-list"
			scale: 200/375
			delay: 3000
		}

		

