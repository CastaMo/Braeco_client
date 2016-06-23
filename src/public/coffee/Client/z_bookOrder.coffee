	BookOrderSingleton = do ->
		_instance = null
		_bookCount = 0
		_ = null

		_initAllBookOrder = ->
			BookOrder.readMemoFromLocStor()
			allBookOrder = locStor.get "allBookOrder"
			if not allBookOrder then return
			allBookOrder = JSON.parse allBookOrder
			isFail = false
			for elem in allBookOrder
				try
					food = Food.getFoodById elem.id
					food.addBookToOrder elem.num, elem.chooseInfo, elem.afterChoosePrice, elem.comboOptions
				catch e
					isFail = true
			#if isFail then alert "存在非法餐品"					

		class BookOrder

			_bookPageDom = getById "book-order-wrap"
			_bookDishDom = getById "book-dish-wrap"
			_foodContainerDom = query ".food-order-wrapper", _bookPageDom
			_foodDiscountWrapper = query ".food-discount-wrapper", _bookPageDom
			_foodDiscountDom = query ".discount-list", _bookPageDom
			_memoBtnDom = query ".food-memo-wrapper", _bookPageDom
			_memoContentDom = query ".memo-field .memo", _bookPageDom

			_bookBottomDom = getById "book-bottom-column"
			_orderBtnDom = query ".order-btn", _bookBottomDom
			_payBtnDom = query ".pay-btn", _bookBottomDom
			_trolleyDom = query ".trolley-field", _bookBottomDom
			_allNumDom = query ".num", _trolleyDom
			_totalPriceDom = query ".total-price", _bookBottomDom

			_foodMemoDom = query ".food-memo-wrapper", _bookPageDom
			_memoBtnDom = query ".title-field", _foodMemoDom
			_memoFieldDom = query ".memo-field", _foodMemoDom
			_memoContentDom = query ".memo-field p.memo", _memoFieldDom
			_memoInputDom = query "#remark-for-trolley-page input#remark"
			_memoClose = query "#remark-for-trolley-page .btn-field"
			_memoConfirm = query "#remark-for-trolley-page .confirm-field"

			_couponChooseDom = query ".coupon-choose", _bookPageDom
			_couponNumberLenDom = query ".coupon-number-field span", _couponChooseDom

			_orderFoods = {}

			_giveFoodName = ""

			_memo = ""

			_allNum = 0
			_allInitPrice = 0
			_dcHalfSave = 0
			_dcDiscountSave = 0
			_dcSaleSave = 0
			_reduceSave = 0
			_membershipSave = 0

			_allSaleNum = 0

			_allFinalPrice = 0

			_typeForName = {
				"half": "第二杯半价"
				"discount": "折扣优惠"
				"sale": "立减优惠"
				"reduce": "满减优惠"
				"membership": "会员优惠"
				"coupon": "代金券"
			}

			_getOrCreateOrderFood = (options)->
				if _orderFoods[options.id] then return _orderFoods[options.id]
				orderFood = new OrderFood {
					food 					:		{
						id 					:		options.id
						categorySeqNum 		:		options.categorySeqNum
						seqNum 				:		options.seqNum
						foodDom 			:		options.foodDom
						cName 				:		options.cName
						dcType 				:		options.dcType
						dc 					:		options.dc
						tag 				:		options.tag
					}
					allChoose 				:		[]
				}
				orderFood

			_getOrCreateOrderChoose = (options, orderFood)->

				_isSame = (elem, options)->
					_food = Food.getFoodById options.id
					if not _food.isCombo then return (elem.chooseInfo is options.chooseInfo)
					return (JSON.stringify(elem.comboOptions) is JSON.stringify(options.comboOptions))

				target = null
				for elem in orderFood.allChoose
					if _isSame(elem, options) then target = elem; break
				if target then return target
				orderChoose = new OrderChoose {
					id 					:		options.id
					num 				:		0
					afterChoosePrice 	:		options.afterChoosePrice
					chooseInfo 			:		options.chooseInfo
					comboOptions		:		options.comboOptions
				}
				orderChoose

			_getBookOrderJSON = ->
				result = []
				for id, orderFood of _orderFoods
					for elem in orderFood.allChoose
						if elem.num <= 0 or orderFood.food.dcType is "give" then continue
						object = {}
						object.id = elem.id
						object.num = elem.num
						object.afterChoosePrice = elem.afterChoosePrice
						object.chooseInfo = elem.chooseInfo
						object.comboOptions = elem.comboOptions
						result.push object
				JSON.stringify result

			_getDiscountDom = (save, type)->
				discountName = _typeForName[type]
				if save is 0 then return
				if _allSaleNum > 0
					lineDom = createDom "div"; lineDom.className = "fivePercentLeftLine"
					append _foodDiscountDom, lineDom
				dom = createDom "li"; dom.className = "discount-field"
				dom.innerHTML = "<div class='discount-wrapper'>
									<div class='discount-name-field'>
										<p class='discount-name'>#{discountName}</p>
									</div>
									<div class='discount-money-field'>
										<p class='minus'>-</p>
										<p class='discount-money money'>#{Number(save.toFixed(2))}</p>
									</div>
								</div>"
				append _foodDiscountDom, dom
				_allSaleNum++

			_resetAllBookOrder = ->
				try
					_orderFoods[3].allChoose[0].subtractOrderByNum 1
				addClass _foodDiscountWrapper, "hide"
				_allInitPrice = _dcHalfSave = _dcDiscountSave = _dcSaleSave = _reduceSave = _membershipSave = 0
				_foodDiscountDom.innerHTML = ""; _allSaleNum = 0; _allNum = 0
				addClass _orderBtnDom, "disabled"; addClass _trolleyDom, "disabled"

			_filterForAllOrderChoose = (filter)->
				for id, orderFood of _orderFoods
					for elem in orderFood.allChoose
						filter?(orderFood, elem)

			_updateInitPrice = -> _filterForAllOrderChoose (orderFood, elem)-> _allInitPrice += elem.num * elem.afterChoosePrice; _allNum += elem.num

			_updateDcHalfSave = ->
				for id, orderFood of _orderFoods
					if orderFood.food.dcType is "half"
						temp = []
						for elem in orderFood.allChoose
							for i in [0..elem.num - 1]
								temp.push elem.afterChoosePrice
						temp.sort (a, b)-> a > b
						i = 0; middle = Math.floor(temp.length / 2)
						isOverlapForHalf = user.getIsOverlap()["half"]
						if temp.length > 1
							for i in [0..middle-1]
								if isOverlapForHalf then _membershipSave += ((temp[i] / 2) * (100 - user.discount) / 100); _dcHalfSave += ((temp[i] / 2) * (user.discount) / 100)
								else _dcHalfSave += (temp[i] / 2)
							if isOverlapForHalf
								for i in [middle..temp.length-1]
									_membershipSave += ((temp[i]) * (100 - user.discount) / 100)
						else if temp.length is 1 then _membershipSave += (temp[0] * (100 - user.discount) / 100)

			_updateDcDiscountSave = -> _filterForAllOrderChoose (orderFood, elem)-> if orderFood.food.dcType is "discount" then _dcDiscountSave += (elem.num * elem.afterChoosePrice * (100 - orderFood.food.dc) / 100)

			_updateDcSaleSave = ->_filterForAllOrderChoose (orderFood, elem)-> if orderFood.food.dcType is "sale" then _dcSaleSave += (elem.num * orderFood.food.dc)

			_updateMembershipSave = ->
				if not user.isLogin() then return
				isOverlap = user.getIsOverlap()
				for id, orderFood of _orderFoods
					if orderFood.food.dcType is "half" then continue
					else if (not orderFood.food.dcType) or (orderFood.food.dcType is "none") or (isOverlap[orderFood.food.dcType])
						for elem in orderFood.allChoose
							food = Food.getFoodById orderFood.food.id
							_membershipSave += (elem.num * food.getAfterDiscountPrice(elem.afterChoosePrice) * (100 - user.discount) / 100)

			_updateReduceSave = ->
				_currentAllPrice = _allInitPrice - _dcHalfSave - _dcDiscountSave - _dcSaleSave - _membershipSave
				reduceList = Activity.getReduceList()
				maxIndex = -1; maxLeast = 0
				for elem, i in reduceList
					if _currentAllPrice >= elem.least and elem.least > maxLeast then maxIndex = i; maxLeast = elem.least
				if maxIndex >= 0 then _reduceSave = reduceList[maxIndex].reduce

			_updateGive = ->
				_currentAllPrice = _allInitPrice - _dcHalfSave - _dcDiscountSave - _dcSaleSave - _membershipSave - _reduceSave; cName = ""
				giveList = Activity.getGiveList()
				maxIndex = -1; maxLeast = 0
				for elem, i in giveList
					if _currentAllPrice >= elem.least and elem.least > maxLeast then maxIndex = i; maxLeast = elem.least
				if maxIndex >= 0 then cName = giveList[maxIndex].dish
				if cName
					_giveFoodName = cName
					bookOrder.bookForFood {
						seqNum 				:		100
						cName 				:		cName
						afterChoosePrice 	:		0
						id 					:		3
						num 				:		1
						chooseInfo 			:		""
						dcType 				:		"give"
						dc 					:		""
						tag 				:		""
					}

			_calFinalPrice = ->
				_allFinalPrice = _allInitPrice - _dcHalfSave - _dcDiscountSave - _dcSaleSave - _reduceSave - _membershipSave
				locStor.set("bookOrderAllPrice", _allFinalPrice)

			_updateCoupon = ->
				len = couponManage.getAvailableCouponLength _allFinalPrice
				_couponNumberLenDom.innerHTML = len
				if len > 0 then removeClass _couponChooseDom, "hide"
				else addClass _couponChooseDom, "hide"
				couponId = Number locStor.get "couponId" || "0"
				if couponId > 0
					coupon = couponManage.getCouponById couponId
					if coupon.cost > _allFinalPrice then locStor.rm "couponId"


			_calAllSaveAndShow = ->
				_getDiscountDom _dcHalfSave, "half"
				_getDiscountDom _dcDiscountSave, "discount"
				_getDiscountDom _dcSaleSave, "sale"
				_getDiscountDom _membershipSave, "membership"
				_getDiscountDom _reduceSave, "reduce"
				couponId = Number locStor.get "couponId" || "0"
				totalPrice = _allFinalPrice
				if couponId > 0
					coupon = couponManage.getCouponById couponId
					totalPrice -= coupon.costReduce
					if totalPrice < 0 then totalPrice = 0
					_getDiscountDom coupon.costReduce, "coupon"
				_allNumDom.innerHTML = _allNum; _totalPriceDom.innerHTML = Number(totalPrice.toFixed(2))
				if _allNum > 0 then removeClass _orderBtnDom, "disabled"; removeClass _trolleyDom, "disabled"
				if totalPrice < _allInitPrice then removeClass _foodDiscountWrapper, "hide"
			
			_updateAllBookOrderNumAndPrice = ->
				_resetAllBookOrder()
				_updateInitPrice()
				_updateDcHalfSave()
				_updateDcDiscountSave()
				_updateDcSaleSave()
				_updateMembershipSave()
				_updateReduceSave()
				_updateGive()
				_calFinalPrice()
				_updateCoupon()
				_calAllSaveAndShow()

			###
			* memo start
			###

			_updateMemoFromInput = ->
				_memo = _memoInputDom.value
				_memo = filteTheStr(_memo)
				locStor.set "memo", _memo
				_showMemoInMemoField()


			_insertMemoToInput = ->
				_memoInputDom.value = _memo


			_showMemoInMemoField = ->
				addClass _memoFieldDom, "hide"
				_memoContentDom.innerHTML = _memo
				if _memo then removeClass _memoFieldDom, "hide"

			@readMemoFromLocStor: ->
				_memo = filteTheStr(locStor.get("memo") || "")
				_showMemoInMemoField()


			###
			* memo end
			###


			class OrderFood

				_getOrderFoodDom = (orderFood)->
					dom = createDom "ul"; dom.className = "food-order-#{orderFood.food.categorySeqNum}-#{orderFood.food.seqNum}"
					append _foodContainerDom, dom
					dom

				constructor: (options)->
					deepCopy options, @
					@init()
					_orderFoods[@food.id] = @

				init: ->
					@initOrderFoodDom()

				initOrderFoodDom: ->
					@orderFoodDom = _getOrderFoodDom @

				getOrderChooseIndexByChooseInfo: (chooseInfo)->
					for elem, i in @allChoose
						if elem.chooseInfo is chooseInfo then return i
					return -1

				checkIfNeedRemove: ->
					if @allChoose.length is 0
						remove @orderFoodDom
						delete _orderFoods[@food.id]

			class OrderChoose extends Base

				_getDCLabelForTopWrapDom = (food)->
					dcDom = ""
					if food.dcType is "discount"
						num = food.dc; if food.dc % 10 is 0 then num = numToChinese[Math.round(food.dc / 10)] else num = food.dc/10
						dcDom = "<p class='dc-label'>#{num}折</p>"
					else if food.dcType is "sale" then dcDom = "<p class='dc-label'>减#{food.dc}元</p>"
					else if food.dcType is "half" then dcDom = "<p class='dc-label'>第二杯半价</p>"
					#else if food.dcType is "limit" then dcDom = "<p class='dc-label'>剩#{food.dc}件</p>"
					else if food.dcType is "give" then dcDom = "<p class='dc-label'>满送</p>"
					return dcDom

				_getTagLabelForTopWrapDom = (food)->
					tagDom = ""
					if food.tag then tagDom = "<p class='tag-label'>#{food.tag}</p>"
					return tagDom

				_getFoodInfoBydcType = (orderChoose)->

					_getComboInfoByOptions = (comboOptions)->
						_s = ""
						for subItem in comboOptions
							for subItemFoodOrder in subItem
								chooseInfo = ""; if subItemFoodOrder.chooseInfo then chooseInfo = "(#{subItemFoodOrder.chooseInfo})"
								_s += "<li class='combo-choose'>
											<div class='choose-name'>#{subItemFoodOrder.cName}#{chooseInfo}</div>
											<div class='choose-num'>x#{subItemFoodOrder.num}</div>
											<div class='clear'></div>
										</li>"
						return _s

					dcType = _orderFoods[orderChoose.id].food.dcType
					if dcType is "combo_static" or dcType is "combo_sum"
						return "<ul class='combo-list'>
									#{_getComboInfoByOptions orderChoose.comboOptions}
								</ul>"
					return orderChoose.chooseInfo

				_getOrderChooseDom = (orderChoose)->
					dom = createDom "li"; dom.className = 'food-order-choose'
					food = _orderFoods[orderChoose.id].food
					orderFoodDom = _orderFoods[orderChoose.id].orderFoodDom
					hideStr = ""
					if food.dcType is "give" then hideStr = " hide"
					dom.innerHTML = "<div class='food-info-field'>
										<div class='full-part'>
											<div class='top-wrap'>
												<div class='first-part'>
													<div class='name-field'>
														<p class='c-name'>#{food.cName}</p>
													</div>
													<div class='label-field'>
														#{_getDCLabelForTopWrapDom(food)}
														#{_getTagLabelForTopWrapDom(food)}
													</div>
												</div>
												<div class='second-part'>
													<div class='choose-field choose-for-order'>
														<p class='choose'>#{_getFoodInfoBydcType orderChoose}</p>
													</div>
												</div>
												<div class='clear'></div>
											</div>
											<div class='bottom-wrap font-number-word'>
												<div class='price-field'>
													<p class='min-price money'>#{Number((orderChoose.afterChoosePrice).toFixed(2))}</p>
												</div>
												<div class='controll-field'>
													<div class='minus-field btn#{hideStr}'>
														<div class='img'></div>
													</div>
													<div class='number-field'>
														<p class='num'>#{orderChoose.num}</p>
													</div>
													<div class='plus-field btn#{hideStr}'>
														<div class='img'></div>
													</div>
												</div>
											</div>
										</div>
										<div class='clear'></div>
									</div>"
					if _orderFoods[orderChoose.id].allChoose.length isnt 0
						lineDom = createDom "div"; lineDom.className = 'fivePercentLeftLine'
						append orderFoodDom, lineDom
					append orderFoodDom, dom
					dom

				constructor: (options)->
					super options
					_orderFoods[@id].allChoose.push @

				init: ->
					@initOrderChooseDom()
					@initAllEvent()

				initOrderChooseDom: ->
					@orderChooseDom = _getOrderChooseDom @
					@numDom = query ".num", @orderChooseDom

				initAllEvent: ->
					self = @
					addListener (query ".minus-field", self.orderChooseDom), "touchstart", -> self.subtractOrderByNum 1
					addListener (query ".plus-field", self.orderChooseDom), "touchstart", -> self.addOrderByNum 1

				addOrderByNum: (num)->
					food = _orderFoods[@id].food
					if @id isnt 3
						food = Food.getFoodById @id
						if not food.checkAndTrySubtractLimit num then alert("#{food.cName}剩余菜品数量不足"); return
					@num += num
					@numDom.innerHTML = @num
					if _orderFoods[@id].food.dcType isnt "give" then _updateAllBookOrderNumAndPrice()
					bookOrder.saveForBook()

				subtractOrderByNum: (num)->
					if (@num - num) < 0 then return
					food = _orderFoods[@id].food
					if @id isnt 3
						food = Food.getFoodById @id
						if not food.checkAndTryAddLimit num then alert("#{food.cName}剩余菜品数量不足"); return
					dcType = _orderFoods[@id].food.dcType
					@num -= num; @numDom.innerHTML = @num
					if @num is 0 then @deleteDomAndSelf()
					if dcType isnt "give" then _updateAllBookOrderNumAndPrice()
					bookOrder.saveForBook()
					if _allNum is 0 then setTimeout(hashRoute.back, 10)

				deleteDomAndSelf: ->
					brotherDom = getBrotherDom @orderChooseDom
					if brotherDom then remove brotherDom
					remove @orderChooseDom
					index = _orderFoods[@id].getOrderChooseIndexByChooseInfo @chooseInfo
					if index >= 0 then _orderFoods[@id].allChoose.splice(index, 1)
					_orderFoods[@id].checkIfNeedRemove()


			constructor: ->
				addListener _orderBtnDom, "click", -> 
					if hasClass @, "disabled" or hashRoute.getCurrentState() is "bookOrder" then return
					if hashRoute.getCurrentState() is "bookInfo" then setTimeout((-> hashRoute.hashJump "-Detail-Book-bookCol"; setTimeout((-> hashRoute.hashJump "-Detail-Book-bookOrder"), 10)), 0)
					else hashRoute.hashJump "-Detail-Book-bookOrder"

				addListener _trolleyDom, "click", ->
					if hashRoute.getCurrentState() is "bookOrder" then return
					if hasClass @, "disabled" then return
					if hashRoute.getCurrentState() is "bookInfo" then setTimeout((-> hashRoute.hashJump "-Detail-Book-bookCol"; setTimeout((-> hashRoute.hashJump "-Detail-Book-bookOrder"), 10)), 0)
					else hashRoute.hashJump "-Detail-Book-bookOrder"

				addListener _payBtnDom, "click", ->
					try
						_ = 0
						if hashRoute.getCurrentState() is "Login" then hashRoute.warn(); return
						_ = 1
						if _allNum is 0 then alert "请先点餐品"; return
						_ = 2
						if not user.isLogin() then locStor.set("loginFlag", 0); hashRoute.hashJump("-Detail-Book-bookOrder-Popup-Form-Login"); return
						_ = 3
						locStor.set("currentPay", "bookOrder")
						_ = 4
						hashRoute.hashJump "-Detail-Book-choosePaymentMethod"
						_ = 5
					catch e
						alert JSON.stringify(e)
						alert _
				

				addListener _memoBtnDom, "touchstart", ->
					_insertMemoToInput()
					hashRoute.pushHashStr "Popup-Form-remarkForTrolley"
				addListener _memoClose, "touchstart", -> hashRoute.back()
				addListener _memoConfirm, "touchstart", -> _updateMemoFromInput(); hashRoute.back()

				addListener _couponChooseDom, "click", ->
					if couponManage.getAvailableCouponLength _allFinalPrice <= 0 then hashRoute.warn()
					locStor.set "couponState", "use"
					hashRoute.hashJump("-Extra-extraContent-Coupon")

			toggleState: do ->
				_stateConfig = {
					"col" 		:		-> removeClass _orderBtnDom, "hide"
					"order" 	: 		-> removeClass _payBtnDom, "hide"
					"info" 		:		-> removeClass _orderBtnDom, "hide"
				}
				(state)->
					do ->
						addClass _payBtnDom, "hide"; addClass _orderBtnDom, "hide"
						_stateConfig[state]?()

			deleteDisabledDishes: (dishIdArr, type)->
				dishNames = ""; count = 0
				for id in dishIdArr
					try
						orderFood = _orderFoods[id]
						if count++ is 0 then dishNames += orderFood.food.cName
						else dishNames += ", #{orderFood.food.cName}"
						for choose in orderFood.allChoose
							choose.subtractOrderByNum choose.num
						food = Food.getFoodById id
						if type is "limit" then food.clearAllLimit()
						else if type is "disabled" then food.deleteSelfDom()
					catch e
						alert("非法操作")
				if type is "limit" then msg = "售罄"
				else if type is "disabled" then msg = "下架"
				alert "#{dishNames} 已#{msg}";
				hashRoute.back()
					

			bookForFood: (options)->
				if options.id isnt 3
					food = Food.getFoodById options.id
					if not food.checkLimit(-1*options.num) then alert("#{food.cName}剩余菜品数量不足"); return
				orderFood = _getOrCreateOrderFood options
				orderChoose = _getOrCreateOrderChoose options, orderFood
				orderChoose.addOrderByNum options.num

			saveForBook: ->
				locStor.set("allBookOrder", _getBookOrderJSON())

			calForOrderPageHeight: ->
				_bookPageDom.style.height = ""
				setTimeout(->
					_bookPageDom.style.height = "#{getAdaptHeight(_bookPageDom, _bookDishDom)}px"
				, 100)

			refreshOrder: _updateAllBookOrderNumAndPrice

			clearAllOrder: ->
				_orderFoods = {}
				_foodContainerDom.innerHTML = ""
				_updateAllBookOrderNumAndPrice()
				@saveForBook()
				_memoInputDom.value = ""
				_updateMemoFromInput()

			confirmPay: ->
				_couponSave = 0
				couponId = Number locStor.get "couponId" || "0"
				if couponId > 0
					coupon = couponManage.getCouponById couponId
					_couponSave = coupon.costReduce
				alreadyManage.confirmOrderAndUpdateAllInfo(JSON.parse(_getBookOrderJSON()), {
					half 				:		_dcHalfSave
					discount 		:		_dcDiscountSave
					sale 				:		_dcSaleSave
					reduce 			:		_reduceSave
					membership 	:		_membershipSave
					coupon 			: 	_couponSave
				}, _giveFoodName, Number(locStor.get("bookOrderAllPrice")), _memo)
				@clearAllOrder()

			addOrderSignal: -> _bookCount++; setTimeout (-> removeClass _trolleyDom, "playAnimationForBook"; setTimeout (-> addClass _trolleyDom, "playAnimationForBook"), 50), 0

			animationCallback: -> _bookCount--; if _bookCount is 0 then removeClass _trolleyDom, "playAnimationForBook"

			getOrderFoodById: (id)-> return _orderFoods[id]

		getInstance: ->
			if _instance is null then _instance = new BookOrder()
			return _instance

		initial: ->
			bookOrder = @getInstance()
			_initAllBookOrder()

