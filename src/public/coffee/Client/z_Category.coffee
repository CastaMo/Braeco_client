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
		_catergoryDisplayUlDom  		= query "#Menu-page .category-display-list"
		_categoryBookCategoryUlDom 		= query "#category-choose-page ul.category-list"
		_foodListAllDom 				= query "#book-dish-wrap .food-list-wrap"
		_categoryBookCategoryUlWidth 	= 0
		_cateogries 					= []
		_categoryCurrentChoose 			= 0

		_asideWrapDom 					= getById "book-aside-wrap"
		_leftCoverDom 					= query ".left-cover"
		_rightCoverDom 					= query ".right-cover"

		_widthByContent = {
			"letter"	:	10
			"number"	:	11
			"space"		:	6
			"chinese"	:	16
		}

		_getImageBufferFlag 			= false

		_categoryChooseCloseBtnDom 		= query "#category-choose-page .close-btn"
		_categoryChooseSwitchBtnDom 	= query "#category-switch-btn-container .switch-btn"
		_categoryDisplayNameDom 		= query "#book-aside-wrapper #category-name-container p.category-name"

		###
		* 静态私有函数
		* 创建和返回displayDom, 并投放到_catergoryDisplayUlDom中
		* @param {Object} category类变量
		###
		_getDisplayDom = (category)->
			dom = createDom("li"); dom.id = "category-#{category.seqNum}"
			if not category.displayFlag then dom.className = "hide"

			domWidth = clientWidth * 160 / 375; domHeight = domWidth
			imgDomStr = "<div class='category-img default-category-image' style='background-size:#{domWidth}px #{domHeight}px;'></div>"
			
			nameDomStr = "<div class='category-name-field'><p class='category-name total-center'>#{category.name}</p></div>"
			dom.innerHTML = "#{imgDomStr}#{nameDomStr}"
			dom.style.height = "#{domHeight}px"; dom.style.width = "#{domWidth}px"
			if category.state is 1 then dom.style.float = "left"
			else dom.style.float = "right"
			dom.style.marginBottom = "#{Math.floor(clientWidth * 55 / 375 / 3)}px"
			append _catergoryDisplayUlDom, dom
			return dom

		###
		* 静态私有函数
		* 创建和返回bookCategory的dom, 并投放在_categoryBookCategoryUlDom中
		* @param {Object} category类变量
		###
		_getBookCategoryDom = (category)->
			dom = createDom("li"); dom.className = "category #{if not category.displayFlag then 'hide' else ''}"
			dom.innerHTML = "	<div class='category-wrapper'>
									<div class='category-word'>
										<p>#{category.name}</p>
									</div>
								</div>"
			#width = _getWidthByContent(category.name)
			#dom.style.width = "#{width}px"
			append _categoryBookCategoryUlDom, dom
			lineDom = createDom "div"; lineDom.className = "category-line"
			append _categoryBookCategoryUlDom, lineDom
			#_categoryBookCategoryUlWidth += (width + 25)
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
		###

		#_updateBookCategoryDomWidth = -> _categoryBookCategoryUlDom.style.width = "#{_categoryBookCategoryUlWidth}px"

		_hideAllFoodListDom = -> addClass category.foodListDom, "hide" for category in _cateogries

		_unChooseAllBookCategoryDom = -> removeClass category.bookCategoryDom, "choose" for category in _cateogries

		_chooseBookCategoryByCurrentChoose = ->
			_unChooseAllBookCategoryDom()
			_hideAllFoodListDom()
			_getCurrentChooseFromLocStor()
			addClass _cateogries[_categoryCurrentChoose].bookCategoryDom, "choose"
			removeClass _cateogries[_categoryCurrentChoose].foodListDom, "hide"
			_categoryDisplayNameDom.innerHTML = _cateogries[_categoryCurrentChoose].name
			Food.getImageBufferForCorresCategoryNum(_categoryCurrentChoose)
			###
			setTimeout(->
				_cateogries[_categoryCurrentChoose].bookCategoryDom.scrollIntoView()
			, 0)
			###

		_setCurrentChoose = (seqNum)-> _categoryCurrentChoose = seqNum; locStor.set("categoryCurrentChoose", seqNum)

		_getCurrentChooseFromLocStor = ->
			choose = locStor.get("categoryCurrentChoose") || 0
			if _cateogries[choose] then _categoryCurrentChoose = Number(choose)
			else _categoryCurrentChoose = 0

		_coverDomClickEvent = (e)->
			touchPosX = e.x
			for category in _cateogries
				domBound = category.bookCategoryDom.getBoundingClientRect()
				rightBound = domBound.right
				leftBound = domBound.left
				if touchPosX >= leftBound and touchPosX <= rightBound then category.bookCategoryDom.click()

		_judgeLeftCoverAndRightCoverShowOrHide = ->
			setTimeout(->
				ulBound = _categoryBookCategoryUlDom.getBoundingClientRect()
				changeBound = clientWidth * 0.066 + 10
				if ulBound.left + changeBound >= 0 then addClass _leftCoverDom, "hide"
				else removeClass _leftCoverDom, "hide"
				if clientWidth + changeBound >= ulBound.right then addClass _rightCoverDom, "hide"
				else removeClass _rightCoverDom, "hide"
			, 0)

		constructor: (options)->
			deepCopy options, @
			@init()
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
			if self.displayFlag
				addListener self.displayDom, "click", -> _setCurrentChoose(self.seqNum); hashRoute.hashJump "-Detail-Book-bookCol"
			addListener self.bookCategoryDom, "click", -> _setCurrentChoose(self.seqNum); _chooseBookCategoryByCurrentChoose(); hashRoute.back()

		getImageBuffer: ->
			self = @
			if @url then imageBuffer = new ImageBuffer {
				url 		:		self.url
				targetDom 	:		query ".category-img", self.displayDom
				id 			:		"food-#{self.id}"
			}

		@initial: ->
			dishJSON = getJSON getDishJSON()
			state = 0
			for tempOuter, i in dishJSON
				if tempOuter.display_flag then state ^= 1
				category = new Category {
					name 		:		tempOuter.name
					id 			:		tempOuter.id
					seqNum 		:		i
					url 		:		"#{tempOuter.pic}?imageView2/1/w/#{Math.floor(clientWidth * 160 / 375)}/h/#{Math.floor(clientWidth * 160 / 375)}"
					displayFlag : 		tempOuter.display_flag
					state 	: 	state
				}
			clearDom = createDom "div"; clearDom.className = "clear"
			append _catergoryDisplayUlDom, clearDom
			addListener _categoryChooseCloseBtnDom, "click", (e)-> hashRoute.back()
			addListener _categoryChooseSwitchBtnDom, "click", (e)-> if hashRoute.getCurrentState() isnt "categoryChoose" then hashRoute.pushHashStr "Popup-Form-categoryChoose"
			(query "#category-choose-page .container-field-wrapper").style.height = "#{clientHeight - 50}px"
			_catergoryDisplayUlDom.parentNode.parentNode.style.margin = "0 #{Math.floor(clientWidth * 55 / 375 / 3)}px"
			#addListener _leftCoverDom, "click", (e)-> _coverDomClickEvent(e)
			#addListener _rightCoverDom, "click", (e)-> _coverDomClickEvent(e)
			#_asideWrapDom.onscroll = _judgeLeftCoverAndRightCoverShowOrHide
			#_updateBookCategoryDomWidth()

		@chooseBookCategoryByCurrentChoose: _chooseBookCategoryByCurrentChoose

		@getImageBufferForAllCategory: ->
			if _getImageBufferFlag then return
			_getImageBufferFlag = true
			for category in _cateogries
				category.getImageBuffer()
