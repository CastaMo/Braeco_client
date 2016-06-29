	ComboManageSingleton = do ->

		_instance = null

		class ComboManage

			_totalPrice = 0

			_initPrice = 0

			_currentCombo = null

			_subItems = []

			_comboDom = getById "choose-combo-sub-item-container"
			_comboPriceDom = query "#choose-combo-bottom-field .total-price"
			_confirmDom = query "#choose-combo-bottom-field .combo-confirm-btn"

			_updateComboPrice = (price)-> _totalPrice = price; _comboPriceDom.innerHTML = Number(price.toFixed(2))

			_disableBtn = -> addClass _confirmDom, "disabled"

			_enabledBtn = -> removeClass _confirmDom, "disabled"

			_clear = -> SubItem.clear(); _subItems = []

			_prepareCombo = ->
				for combo, i in _currentCombo.combo
					combo.seqNum = i
					subItem = new SubItem combo
				_subItems[0].chooseSelfDom()
				_updateComboPrice 0
				_disableBtn()
				if _currentCombo.type is "combo_static"
					_initPrice = _currentCombo.defaultPrice
					_updateComboPrice _currentCombo.defaultPrice

			_isFinish = ->
				for subItem in _subItems
					if not (subItem.isFinish() or subItem.isRandom()) then return false
				return true

			_getComboOrderJSON = ->
				_r = []
				for subItem, i in _subItems
					for food, j in subItem.subItemFoods
						for order in food.orders
							_r.push {
								comboId 		:	_currentCombo.id
								subItemSeqNum	:	i
								seqNum 			:	j
								chooseInfo 		:	order.chooseInfo
								num 			:	order.num
								price 			:	order.price
							}
				JSON.stringify _r

			_recordComboOrder = -> locStor.set "comboOrder", _getComboOrderJSON()

			_update = ->
				if _isFinish() then removeClass _confirmDom, "disabled"
				else addClass _confirmDom, "disabled"

				if _currentCombo.type is "combo_sum"
					_p = 0
					for subItem in _subItems
						_p += subItem.price
					_updateComboPrice _p
				else if _currentCombo.type is "combo_static"
					_d = 0
					for subItem in _subItems
						_d += subItem.diff
					_updateComboPrice _initPrice - _d

			_getComboChooseOptions = ->
				_r = []
				for subItem, i in _subItems
					_r.push []
					for subItemFood, j in subItem.subItemFoods
						for order in subItemFood.orders
							_r[i].push {
								id 				:		subItemFood.food.id
								chooseInfo 		:		order.chooseInfo
								price			:		order.price
								num 			:		order.num
								cName 			:		subItemFood.food.cName
							}
				_r


			constructor: -> 
				addListener _confirmDom, "click", (e)->
					if not _isFinish() then return
					_currentCombo.addBookToOrder 1, "套餐", _totalPrice, _getComboChooseOptions(); locStor.set "comboOrder", "[]"; hashRoute.back()

			readFromComboOrder: ->
				_t = locStor.get "comboOrder" || "[]"
				_t = JSON.parse _t
				for order in _t
					@addItemFoodByChoose {
						comboId 		:	order.comboId
						subItemSeqNum	:	order.subItemSeqNum
						seqNum 			:	order.seqNum
						chooseInfo 		:	order.chooseInfo
						num 			:	order.num
						price 			:	order.price

					}

			getComboId: ->
				_id = Number locStor.get "comboId" || 0
				if _id is 0 then return false
				_currentCombo = Food.getFoodById _id
				_clear()
				_prepareCombo()
				_update()
				@readFromComboOrder()
				return true

			getSubItemFoodByChoose: (subItemSeqNum, seqNum)-> return _subItems[subItemSeqNum].subItemFoods[seqNum]

			addItemFoodByChoose: (options)->
				[comboId, subItemSeqNum, seqNum, chooseInfo, num, price] = [options.comboId, options.subItemSeqNum, options.seqNum, options.chooseInfo, options.num, options.price]
				if comboId isnt _currentCombo.id then hashRoute.warn(); return
				try
					_subItems[subItemSeqNum].subItemFoods[seqNum].addOrder chooseInfo, num, price
					_subItems[subItemSeqNum].subItemFoods[seqNum].changeOrderCallback()
				catch e
					hashRoute.warn()

			minusItemFoodByChoose: (options)->
				[comboId, subItemSeqNum, seqNum, chooseInfo, num, price] = [options.comboId, options.subItemSeqNum, options.seqNum, options.chooseInfo, options.num, options.price]
				if comboId isnt _currentCombo.id then hashRoute.warn(); return
				try
					_subItems[subItemSeqNum].subItemFoods[seqNum].minusOrder chooseInfo, num, price
					_subItems[subItemSeqNum].subItemFoods[seqNum].changeOrderCallback()
				catch e
					hashRoute.warn()


			class SubItem extends Base

				_getSubItemDom = (subItem)->
					dom = createDom "div"; dom.className = "choose-combo-sub-item"; dom.id = "choose-combo-sub-item-#{subItem.seqNum}"
					if subItem.require is 0 then chooseStr = "可任意选择"; numStr = ""
					else chooseStr = "还需选#{subItem.require}项"; numStr = " ×#{subItem.require}"
					dom.innerHTML = 	"<div class='sub-item-drop-down-field'>
											<div class='sub-item-drop-down-container'>
												<div class='sub-item-basic-info-field'>
													<div class='sub-item-name font-number-word'>#{subItem.name}#{numStr}</div>
													<div class='sub-item-choose font-number-word'>#{chooseStr}</div>
													<div class='clear'></div>
												</div>
												<ul class='food-choose-list'>
												</ul>
												<div class='sub-item-img-field vertical-center'>
			                                    	<div class='img'></div>
			                                  	</div>
			                                  	<div class='clear'></div>
											</div>
										</div>
										<div class='sub-item-food-field' style='height:0px'>
											<ul class='sub-item-food-list'></ul>
										</div>"
					append _comboDom, dom
					dom

				_unchooseAllSubItemExceptGiven = (subItem_)->
					for subItem in _subItems when subItem isnt subItem_
						subItem.unchooseSelfDom()

				_findUnfinishSubItemAndChoose = ->
					for subItem in _subItems when (not subItem.isFinish()) and (not subItem.isRandom())
						subItem.chooseSelfDom(); return

				constructor: (options)->
					super options
					_subItems.push @
					@addSubItemFood()
					@update()

				init: ->
					@initPrepare()
					@initSubItemDom()
					@initEvent()
				
				initPrepare: ->
					@subItemFoods = []
					@num = 0
					@isChoose = false
					foodNum = @content.length; lineNum = foodNum - 1
					@allHeight = foodNum * 120 + lineNum

				initSubItemDom: ->
					@subItemDom = _getSubItemDom @
					@dropDownDom = query ".sub-item-drop-down-field", @subItemDom
					@foodFieldDom = query ".sub-item-food-field", @subItemDom
					@foodListDom = query "ul.sub-item-food-list", @foodFieldDom
					@chooseDom = query ".sub-item-choose", @dropDownDom
					@foodChooseListDom = query "ul.food-choose-list", @dropDownDom

				addSubItemFood: ->
					for id, i in @content
						subItemFood = new SubItemFood {
							id 				:		id
							seqNum			:		i
							subItemSeqNum 	:		@seqNum
						}

				initEvent: ->
					self = @
					addListener self.dropDownDom, "click", -> self.dropDownClickEvent()

				dropDownClickEvent: ->
					_unchooseAllSubItemExceptGiven @
					if @isChoose then @unchooseSelfDom() else @chooseSelfDom()

				unchooseSelfDom: ->
					@isChoose = false
					removeClass @subItemDom, "choose"
					@foodFieldDom.style.height = "0px"
					removeClass @foodChooseListDom, "hide"

				chooseSelfDom: ->
					@isChoose = true
					addClass @subItemDom, "choose"
					@foodFieldDom.style.height = "#{@allHeight}px"
					addClass @foodChooseListDom, "hide"

				updateFoodChooseListDom: ->
					_addFoodChooseDom = (subItem)->
						_s = ""
						for subItemFood in subItem.subItemFoods
							for order in subItemFood.orders
								if order.chooseInfo then chooseInfo = "(#{order.chooseInfo})" else chooseInfo = ""
								_s += "	<li class='food-choose'>
											<div class='dot'></div>
											<div class='name'>#{subItemFood.food.cName}#{chooseInfo}</div>
											<div class='num font-number-word'>×#{order.num}</div>
											<div class='clear'></div>
										</li>"
						_s
					@foodChooseListDom.innerHTML = _addFoodChooseDom @


				update: ->
					_n = 0; _p = 0; _d = 0
					for subItemFood in @subItemFoods
						_n += subItemFood.num
						_p += subItemFood.price
						_d += subItemFood.diff
					@num = _n; @price = _p; @diff = _d
					if @isRandom() then addClass @chooseDom, "r-ready"
					else 
						if @isFinish() then @chooseDom.innerHTML = "已选好"; addClass @chooseDom, "y-ready"; @unchooseSelfDom(); _findUnfinishSubItemAndChoose()
						else @chooseDom.innerHTML = "还需选#{@require - @num}项"; removeClass @chooseDom, "y-ready"
					@updateFoodChooseListDom()

				isFinish: -> return (@num is @require)

				isRandom: -> return @require is 0

				getDemand: -> return (@require - @num)

				clear: ->
					remove @subItemDom
					@subItemDom = null

				@clear: ->
					for subItem in _subItems
						subItem.clear()

				class SubItemFood extends Base

					_getSubItemFoodDom = (subItemFood)->
						dom = createDom "li"; dom.id = "food-#{subItemFood.seqNum}"
						try
							dom.innerHTML = subItemFood.food.foodDom.innerHTML
						catch e
							console.log subItemFood.id
						if subItemFood.seqNum isnt 0
							lineDom = createDom "div"; lineDom.className = "fivePercentLeftLine"
							append _subItems[subItemFood.subItemSeqNum].foodListDom, lineDom
						append _subItems[subItemFood.subItemSeqNum].foodListDom, dom
						dom

					constructor: (options)->
						super options
						_subItems[@subItemSeqNum].subItemFoods.push @
						@update()

					init: ->
						@initPrepare()
						@initSubItemFoodDom()
						@initImage()
						@initAllEvent()

					initPrepare: ->
						@food = Food.getFoodById @id
						@orders = []
						@num = 0
						@price = 0
						@chooseAllFirstPrice = @food.chooseAllFirstPrice
						@discount = _subItems[@subItemSeqNum].discount || 100


					initSubItemFoodDom: ->
						@subItemFoodDom = _getSubItemFoodDom @
						@adjustLabelDom()
						@adjustPriceDom()
						@adjustControllDom()

					adjustLabelDom: ->
						_ldom = query ".dc-label", @subItemFoodDom
						if _ldom then _ldom.innerHTML = ""
						_lidom = query ".label-img", @subItemFoodDom
						if _lidom then remove _lidom

					adjustPriceDom: ->
						_getMinPriceForBottomWrapDom = (chooseAllFirstPrice, discount)->
							minPrice = "<p class='min-price money'>#{Number((chooseAllFirstPrice * discount / 100).toFixed(2))}</p>"
							minPrice

						_getInitPriceForBottomWrapDom = (chooseAllFirstPrice, discount)->
							initPrice = ""; afterDiscountPrice = chooseAllFirstPrice * discount / 100
							if afterDiscountPrice < chooseAllFirstPrice then initPrice = "<p class='init-price money'>#{chooseAllFirstPrice}</p>"
							initPrice

						if _currentCombo.type is "combo_static" then return
						(query ".price-field", @subItemFoodDom).innerHTML = "
								#{_getMinPriceForBottomWrapDom @chooseAllFirstPrice, @discount}
								#{_getInitPriceForBottomWrapDom @chooseAllFirstPrice, @discount}
								"

					adjustControllDom: ->
						@minusDom = createDom "div"; @minusDom.className = "minus-field btn"; @minusDom.innerHTML = "<div class='img'></div>"
						@numDom = createDom "div"; @numDom.className = "number-field"; @numDom.innerHTML = "<p class='num'>0</p>"
						@addDom = createDom "div"; @addDom.className = "plus-field btn"; @addDom.innerHTML = "<div class='img'></div>"
						_controllDom = query ".controll-field", @subItemFoodDom; _controllDom.innerHTML = ""
						append _controllDom, @minusDom; append _controllDom, @numDom; append _controllDom, @addDom
						@numDom = query "p", @numDom

					initImage: -> if @subItemFoodDom.innerHTML then @getImageBuffer()

					initAllEvent: ->
						self = @
						addListener @addDom, "click", (e)-> self.addDomClickEvent e
						addListener @minusDom, "click", (e)-> self.minusDomClickEvent e

					addDomClickEvent: (e)->
						if _subItems[@subItemSeqNum].getDemand() is 0 and not _subItems[@subItemSeqNum].isRandom() then alert "#{_subItems[@subItemSeqNum].name}品类选择已完成, 请先删除其他单品"; return
						if @food.chooseArr.length is 0
							@addOrder "", 1, @chooseAllFirstPrice * @discount / 100
							@changeOrderCallback()
						else
							locStor.set "bookFoodCurrentChoose", @food.id
							targetInfo = {discount: @discount, subItemSeqNum: @subItemSeqNum, seqNum: @seqNum, comboId: _currentCombo.id}
							locStor.set "bookChooseTargetInfo", JSON.stringify targetInfo
							hashRoute.pushHashStr "Popup-Form-bookChoose"

					minusDomClickEvent: (e)->
						if @orders.length is 0 then hashRoute.warn(); return
						if @orders.length is 1
							f_order = @orders[0]
							@minusOrder f_order.chooseInfo, 1, f_order.price
							@changeOrderCallback()
						else 
							locStor.set "comboChooseDeleteFoodChoose", "[#{@subItemSeqNum}, #{@seqNum}, #{_currentCombo.id}]"
							hashRoute.pushHashStr "Popup-Form-comboChooseDelete"



					addOrder: (chooseInfo, num, price)->
						if _subItems[@subItemSeqNum].getDemand() < num and not _subItems[@subItemSeqNum].isRandom() then hashRoute.warn(); return
						for order in @orders
							if order.chooseInfo is chooseInfo and order.price is price then order.num += num; return
						@orders.push {chooseInfo: chooseInfo, num: num, price:price}


					minusOrder: (chooseInfo, num, price)->
						for order, i in @orders
							if order.chooseInfo is chooseInfo and order.num >= num and order.price is price
								order.num -= num
								if order.num is 0 then @orders.splice i, 1
								return
						hashRoute.warn()

					update: ->
						_n = 0; _p = 0; _d = 0
						for order in @orders
							_n += order.num
							_p += order.price * order.num
							_d += (order.price - @food.defaultPrice) * order.num
						@num = _n; @price = _p; @diff = _d
						@numDom.innerHTML = @num
						if _n >= 1 then removeClass @numDom, "hide"; removeClass @minusDom, "hide"
						else addClass @numDom, "hide"; addClass @minusDom, "hide"

					changeOrderCallback: -> @update(); _subItems[@subItemSeqNum].update(); _update(); _recordComboOrder()

					getImageBuffer: ->
						self = @
						url = @food["dishUrl"]
						if url then imageBuffer = new ImageBuffer {
							url 		:		url
							targetDom 	:		query ".img-field .img", self.subItemFoodDom
							id 			:		"combo-food-#{self.id}"
						}



		getInstance: ->
			if _instance is null then _instance = new ComboManage()
			return _instance

		initial: -> comboManage = ComboManageSingleton.getInstance()




