	BookChooseSingleton = do ->
		_instance = null

		class BookChoose

			_bookChoosePage = getById "book-choose-page"
			_closeBtnDom = query ".header-field .btn", _bookChoosePage
			_titleNameDom = query ".header-field p.title", _bookChoosePage

			_bookChooseContainerDom = query ".container-field .book-choose-wrapper", _bookChoosePage
			_chooseInfoDom = query ".choose-info-wrapper p.choose-info", _bookChoosePage
			_priceDom = query ".choose-info-wrapper .price-wrapper", _bookChoosePage
			_confirmDom = query ".confirm-column .confirm-field", _bookChoosePage
			_confirmWordDom = query "p.confirm", _confirmDom

			_currentFood = null
			_price = 0
			_isCombo = false
			_targetInfo = null
			_minPrice = 0

			_bookChooseList = []
			_bookChooseElem = []
			_bookCurrentChoose = []
			_bookCurrentInfo = []

			_updateChooseInfo = ->
				_chooseInfoDom.innerHTML = _bookCurrentInfo.join(" 、 ")

			_updateFinalPrice = ->
				if _isCombo and _targetInfo.type is "static_combo"
					price = _targetInfo.staticPrice
				else
					price = _currentFood.defaultPrice
				for choose, i in _bookCurrentChoose
					price += _bookChooseElem[i][choose].price
				_price = price
				if _isCombo and _targetInfo.type is "discount_combo"
					_minPrice = Number((_targetInfo.discount * price / 10000).toFixed(2))
				else if _isCombo and _targetInfo.type is "static_combo"
					_minPrice = price
				else _minPrice = _currentFood.getAfterDiscountPrice price
				minPriceStr = "<p class='min-price money'>#{Number(_minPrice.toFixed(2))}</p>"
				initPriceStr = ""
				if _minPrice isnt _price then initPriceStr = "<p class='init-price money'>#{Number(_price.toFixed(2))}</p>"
				_priceDom.innerHTML = "#{minPriceStr}#{initPriceStr}"


			_getCurrentChooseFromLocStor = ->
				choose = locStor.get("bookFoodCurrentChoose") || "-1000"
				targetInfo = locStor.get "bookChooseTargetInfo"

				if targetInfo is "bookOrder" then _isCombo = false; _confirmWordDom.innerHTML = "加入购物车"
				else _isCombo = true; _targetInfo = JSON.parse targetInfo; _confirmWordDom.innerHTML = "确认"
				
				choose = JSON.parse(choose)
				if choose is -1000 then hashRoute.warn(); return false
				_currentFood = Food.getFoodById choose; return true

			_resetBookChoose = ->
				_bookChooseList = []
				_bookChooseElem = []
				_bookCurrentChoose = []
				_bookCurrentInfo = []
				_bookChooseContainerDom.innerHTML = ""
				_chooseInfoDom.innerHTML = ""
				_priceDom.innerHTML = ""

			_constructBookChooseFromCurrentFood = ->
				_titleNameDom.innerHTML = _currentFood.cName
				for tempOuter, i in _currentFood.chooseArr
					bookChooseList = new BookChooseList {
						seqNum 			:		i
						name 			:		tempOuter.groupname
					}
					bookChooseListDom = query "ul", bookChooseList.bookChooseListDom
					_bookChooseElem[i] = []
					for elem, j in tempOuter.property
						bookChooseElem = new BookChooseElem {
							listSeqNum		:		i
							seqNum 			:		j
							name 			:		elem.name
							price 			:		elem.price
						}, bookChooseListDom
					_bookChooseElem[i][0].chooseEvent()
					clearDom = createDom "div"; clearDom.className = "clear"
					append bookChooseListDom, clearDom

			_selectBookFoodDisplayByCurrentChoose = ->
				if _currentFood.chooseArr.length is 0 then hashRoute.back(); return
				_resetBookChoose()
				_constructBookChooseFromCurrentFood()


			class BookChooseList

				_getBookChooseListDom = (bookChooseList)->
					dom = createDom "div"; dom.id = "book-choose-#{bookChooseList.seqNum}"; dom.className = "book-choose"
					dom.innerHTML = "<div class='group-name-field'>
										<p class='group-name'>#{bookChooseList.name}</p>
									</div>
									<ul class='book-choose-list'>
									</ul>"
					append _bookChooseContainerDom, dom
					lineDom = createDom "div"; lineDom.className = "fivePercentLeftLine"
					append _bookChooseContainerDom, lineDom
					dom

				constructor: (options)->
					deepCopy options, @
					@init()
					_bookChooseList.push @

				init: -> @initBookChooseListDom()

				initBookChooseListDom: -> @bookChooseListDom = _getBookChooseListDom @

			class BookChooseElem

				_getBookChooseElemDom = (bookChooseElem, bookChooseListDom)->
					dom = createDom "li"; dom.id = "choose-elem-#{bookChooseElem.seqNum}"; dom.className = "choose-elem"
					dom.innerHTML = bookChooseElem.name
					append bookChooseListDom, dom
					dom

				_unChooseAllBookChooseFromList = (listSeqNum)-> removeClass elem.bookChooseElemDom, "choose" for elem in _bookChooseElem[listSeqNum]

				constructor: (options, bookChooseListDom)->
					deepCopy options, @
					@init(bookChooseListDom)
					_bookChooseElem[@listSeqNum].push @

				init: (bookChooseListDom)->
					@initBookChooseElemDom bookChooseListDom
					@initAllEvent()

				initBookChooseElemDom: (bookChooseListDom)->
					@bookChooseElemDom = _getBookChooseElemDom @, bookChooseListDom

				initAllEvent: ->
					self = @
					fastClick self.bookChooseElemDom, -> self.chooseEvent()

				chooseEvent: ->
					_unChooseAllBookChooseFromList @listSeqNum
					addClass @bookChooseElemDom, "choose"
					_bookCurrentChoose[@listSeqNum] = @seqNum
					_bookCurrentInfo[@listSeqNum] = @name
					_updateChooseInfo()
					_updateFinalPrice()


			constructor: ->
				fastClick _confirmDom, (e)->
					hashRoute.back()
					if _isCombo
						comboManage.addItemFoodByChoose {
							comboId 		:	_targetInfo.comboId
							subItemSeqNum 	:	_targetInfo.subItemSeqNum
							seqNum 			:	_targetInfo.seqNum
							chooseInfo 		:	_bookCurrentInfo.join(" 、 ")
							num 			:	1
							price 			:	_minPrice
						}
						_targetInfo = null; return
					setTimeout ->
						if state = hashRoute.getCurrentState() is "bookCol"
							plusBtnDom = query ".plus-field", _currentFood.foodDom
							_currentFood.foodDom.scrollIntoViewIfNeeded()
						else
							imgDom = foodInfo.getImgDom(); plusBtnDom = foodInfo.getPlusBtnDom()
							imgDom.scrollIntoViewIfNeeded()
							setTimeout (-> hashRoute.back()), 100
						setTimeout (-> _currentFood.clickForBook 1, _bookCurrentInfo.join(" 、 "), _price, {initLeft:clientWidth * 0.9 - 30, initTop: plusBtnDom.getBoundingClientRect().top - 7.5}), 10
					, 10
				fastClick _closeBtnDom, -> hashRoute.back()

			chooseFoodByCurrentChoose: -> if _getCurrentChooseFromLocStor() then _selectBookFoodDisplayByCurrentChoose()

		getInstance: ->
			if _instance is null then _instance = new BookChoose()
			return _instance

		initial: ->
			bookChoose = @getInstance()