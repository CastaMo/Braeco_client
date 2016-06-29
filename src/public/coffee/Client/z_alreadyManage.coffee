	AlreadyManageSingleton = do ->
		_instance = null			

		class AlreadyManage

			_alreadyDom = getById "Already-page"

			_serviceBtnDom = query "#service-button", _alreadyDom

			_notOrderDom = query ".Already-not-order-field", _alreadyDom
			_bookBtnDom = query ".not-order-img-wrapper", _notOrderDom

			_hasOrderDom = query ".Already-content-field", _alreadyDom

			_alreadyOrders = {}

			_getOrCreateAlreadyOrder = (options)->
				if _alreadyOrders[options.id] then return _alreadyOrders[options.orderId]
				alreadyOrder = new AlreadyOrder {
					giveName 				:		options.giveName || ""
					id 						:		options.orderId
					discountList 			:		options.discountList
					allFinalPrice 			:		Number(options.allFinalPrice)
					memo 					:		options.memo
					allFood 				:		{}
				}

			_getOrCreateAlreadyFood = (options, alreadyOrder)->
				alreadyFood = null
				try 
					alreadyFood = _alreadyOrders[alreadyOrder.orderId].allFood[options.id]
				catch e
					alreadyFood = null
				if alreadyFood then return alreadyFood
				alreadyFood = new AlreadyFood {
					food 					:		{
						id 					:		options.id
						categorySeqNum 		:		options.categorySeqNum
						seqNum 				:		options.seqNum
						foodDom 			:		options.foodDom
						cName 				:		options.cName
						dcType 				:		options.dcType
						type 					: 	options.type
						dc 					:		options.dc
						tag 				:		options.tag
					}
					allChoose 				:		[]
					orderId 				:		options.orderId
				}

			_getOrCreateAlreadyChoose = (options, alreadyFood)->
				_isSame = (elem, options)->
					_food = Food.getFoodById options.id
					if not _food.isCombo then return (elem.chooseInfo is options.chooseInfo)
					return (JSON.stringify(elem.comboOptions) is JSON.stringify(options.comboOptions))
				target = null
				for elem in alreadyFood.allChoose
					if _isSame(elem, options) then target = elem; break
				if target then return target
				alreadyChoose = new AlreadyChoose {
					orderId 			:		alreadyFood.orderId
					id 					:		options.id
					num 				:		0
					afterChoosePrice 	:		options.afterChoosePrice
					comboOptions 		:		options.comboOptions || []
					chooseInfo 			:		options.chooseInfo
				}

			_getAlreadyOrderJSON = ->
				result = []
				for orderId, alreadyOrder of _alreadyOrders
					alreadyOrderElem = {orderId: orderId, alreadyFoodList: [], giveName: alreadyOrder.giveName, memo: alreadyOrder.memo, allFinalPrice: alreadyOrder.allFinalPrice, discountList: alreadyOrder.discountList}
					for id, alreadyFood of alreadyOrder.allFood
						if alreadyFood.food.dcType is "give" then continue
						for elem in alreadyFood.allChoose
							if elem.num <= 0 then continue
							object = {}
							object.id = elem.id
							object.num = elem.num
							object.afterChoosePrice = elem.afterChoosePrice
							object.chooseInfo = elem.chooseInfo
							object.comboOptions = elem.comboOptions || []
							alreadyOrderElem.alreadyFoodList.push object
					result.push alreadyOrderElem
				JSON.stringify result

			_tryGetCurrentOrderId = ->
				currentOrderId = Math.abs(Math.floor(locStor.get("orderId"))) || 0
				locStor.rm "orderId"
				#"#{(new Date()).Format('yyyy-MM-dd hh:mm:ss')}"
				"#{currentOrderId}号"

			_addAlreadyOrder = (orderId, allAlreadyOrderElem, discountList, giveName, allFinalPrice, memo)->

				_addSingleFood = (options, alreadyOrder)->
					alreadyFood = _getOrCreateAlreadyFood options, alreadyOrder
					alreadyChoose = _getOrCreateAlreadyChoose options, alreadyFood
					alreadyChoose.addOrderByNum options.num

				alreadyOrder = _getOrCreateAlreadyOrder {
					orderId 		:		orderId
					discountList 	:		discountList
					giveName 		:		giveName
					allFinalPrice 	:		Number(allFinalPrice)
					memo 			:		memo
				}
				for elem in allAlreadyOrderElem
					if food = Food.getFoodById elem.id
						options = {
							orderId 			:	orderId
							id 					:	food.id
							categorySeqNum 		:	elem.categorySeqNum
							seqNum 				:	elem.seqNum
							cName 				:	food.cName
							dc 					:	food.dc
							dcType 				:	food.dcType
							type 				: food.type
							tag 				:	food.tag
							num 				:	elem.num
							afterChoosePrice	:	elem.afterChoosePrice
							chooseInfo 			:	elem.chooseInfo
							comboOptions 		:	elem.comboOptions
						}
						_addSingleFood options, alreadyOrder
				if giveName then options = {
					orderId 			:	orderId
					id 					:	3
					categorySeqNum 		:	100
					seqNum 				:	100
					cName 				:	giveName
					dc 					:	0
					dcType 				:	"give"
					num 				:	1
					afterChoosePrice	:	0
					chooseInfo 			:	""

				}; _addSingleFood options, alreadyOrder
				setTimeout(->
					alreadyOrder.initAllEvent()
				, 200)
				_saveForAlready()
				_toggelToAlreadyState()

			_saveForAlready = ->
				locStor.set("allAlreadyOrder", _getAlreadyOrderJSON())

			_toggelToAlreadyState = -> addClass _notOrderDom, "hide"; removeClass _hasOrderDom, "hide"


			constructor: ->
				addListener _bookBtnDom, "click", -> hashRoute.hashJump "-Detail-Book-bookCol"
				addListener _serviceBtnDom, "click", ->
					if not lockManage.get("callWaiter").getLock() then alert("服务员正火速赶来, 请耐心等候"); return
					confirmManage.simulateConfirm {
						title 			:		"呼叫服务"
						content 		:		"确认呼叫服务员<br>为您解决问题?"
						confirmContent 	:		"呼叫"
						needInput 		:		true
						cancel 			:		-> lockManage.get("callWaiter").releaseLock()
						success 		:		(content)-> webSock.sendCallWaiter(content); setTimeout((-> alert("服务员正火速赶来, 请耐心等候")), 0); setTimeout(->
							lockManage.get("callWaiter").releaseLock()
						, 60*1000)
					}

			initAlready: ->
				allAlreadyOrder = locStor.get "allAlreadyOrder"
				if not allAlreadyOrder or allAlreadyOrder is "[]" then allAlreadyOrder = []
				else allAlreadyOrder = JSON.parse allAlreadyOrder
				for elem in allAlreadyOrder
					_addAlreadyOrder elem.orderId, elem.alreadyFoodList, elem.discountList, elem.giveName, elem.allFinalPrice, elem.memo

			confirmOrderAndUpdateAllInfo: (allAlreadyOrderElem, discountList, giveName, allFinalPrice, memo)->
				currentOrderId = _tryGetCurrentOrderId()
				if not currentOrderId then return
				_addAlreadyOrder currentOrderId, allAlreadyOrderElem, discountList, giveName, allFinalPrice, memo


			class AlreadyOrder extends Base

				_typeForName = {
					"half": "第二杯半价"
					"discount": "折扣优惠"
					"sale": "立减优惠"
					"reduce": "满减优惠"
					"membership": "会员优惠"
					"coupon" : "代金券"
				}

				_getAlreadyOrderDom = (alreadyOrder)->
					dom = createDom "div"; dom.className = "already-content"; dom.id = "already-content-#{alreadyOrder.id}"
					hideClassStr = ""
					dom.innerHTML = "<div class='already-header'>
										<div class='already-id-field font-number-word'>
											<p class='id'>#{alreadyOrder.id}</p>
										</div>
										<div class='img-field'>
											<div class='img'></div>
										</div>
										<div class='clear'></div>
									</div>
									<div class='already-container'>
										<div class='food-order-wrapper'></div>
										<div class='food-discount-wrapper'>
											<div class='title-field'>
												<p class='title'>优惠折扣</p>
											</div>
											<ul class='discount-list'></ul>
										</div>
										<div class='food-total-price-wrapper'>
											<div class='price-field'>
												<p class='word'>总价</p>
												<p class='price money font-number-word'></p>
											</div>
											<div class='clear'></div>
										</div>
									</div>"
					prepend _hasOrderDom, dom
					dom

				_createDiscountDomIfExist = (save, type, alreadyOrder)->
					save = Number save
					if save is 0 then return
					discountName = _typeForName[type]
					if alreadyOrder.allSaleNum > 0
						lineDom = createDom "div"; lineDom.className = "fivePercentLeftLine"
						append alreadyOrder.alreadyDiscountUlDom, lineDom
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
					append alreadyOrder.alreadyDiscountUlDom, dom
					alreadyOrder.allSaleNum++

				_unchooseAlreadyOrder = (alreadyOrder)-> removeClass alreadyOrder.alreadyOrderDom, "choose"; alreadyOrder.isChoose = false; alreadyOrder.alreadyOrderContainerDom.style.height = "0"

				_chooseAlreadyOrder = (alreadyOrder)-> addClass alreadyOrder.alreadyOrderDom, "choose"; alreadyOrder.isChoose = true; alreadyOrder.alreadyOrderContainerDom.style.height = "#{alreadyOrder.containerHeight}px"

				_unchooseAllAlreadyOrderExceptSelf = (alreadyOrder_)->
					for id, alreadyOrder of _alreadyOrders when alreadyOrder isnt alreadyOrder_
						_unchooseAlreadyOrder alreadyOrder

				_touchAlreadyOrderHeaderEvent = (alreadyOrder)->
					alreadyOrder.containerHeight = _getContainerHeight alreadyOrder
					_unchooseAllAlreadyOrderExceptSelf alreadyOrder
					if alreadyOrder.isChoose then _unchooseAlreadyOrder alreadyOrder
					else _chooseAlreadyOrder alreadyOrder

				_getContainerHeight = (alreadyOrder)->
					height = 15 + 30
					height += (query ".food-order-wrapper", alreadyOrder.alreadyOrderDom).getBoundingClientRect().height
					height += (query ".food-discount-wrapper", alreadyOrder.alreadyOrderDom).getBoundingClientRect().height
					height += (query ".food-total-price-wrapper", alreadyOrder.alreadyOrderDom).getBoundingClientRect().height
					height

				constructor: (options)->
					super options
					_alreadyOrders[@id] = @

				init: ->
					@initAlreadyOrderDom()
					@initAlreadyDiscountDom()
					@initAlreadyAllFinalPrice()

				initAlreadyOrderDom: -> @alreadyOrderDom = _getAlreadyOrderDom @; @alreadyOrderFoodDom = query ".food-order-wrapper", @alreadyOrderDom; @isChoose = false; @alreadyOrderContainerDom = query ".already-container", @alreadyOrderDom

				initAlreadyDiscountDom: ->
					@alreadyDiscountDom = query ".food-discount-wrapper", @alreadyOrderDom
					@alreadyDiscountUlDom = query ".discount-list", @alreadyDiscountDom
					@allSaleNum = 0
					for type, save of @discountList
						_createDiscountDomIfExist save, type, @
					if @allSaleNum is 0 then addClass @alreadyDiscountDom, "hide"

				initAlreadyAllFinalPrice: -> 
					(query ".food-total-price-wrapper .price", @alreadyOrderDom).innerHTML = Number @allFinalPrice.toFixed 2

				initAllEvent: ->
					self = @
					addListener (query ".already-header", @alreadyOrderDom), "click", ->
						_touchAlreadyOrderHeaderEvent self
					_touchAlreadyOrderHeaderEvent @


			class AlreadyFood extends Base

				_getAlreadyFoodDom = (alreadyFood)->
					dom = createDom "ul"; dom.className = "food-order-#{alreadyFood.food.categorySeqNum}-#{alreadyFood.food.seqNum}"
					append _alreadyOrders[alreadyFood.orderId].alreadyOrderFoodDom, dom
					dom

				constructor: (options)->
					super options
					_alreadyOrders[@orderId].allFood[@food.id] = @

				init: ->
					@initAlreadyFoodDom()

				initAlreadyFoodDom: ->
					@alreadyFoodDom = _getAlreadyFoodDom @

				getAlreadyChooseIndexByChooseInfo: (chooseInfo)->
					for elem, i in @allChoose
						if elem.chooseInfo is chooseInfo then return i
					return -1

				checkIfNeedRemove: ->
					if @allChoose.length is 0
						remove @alreadyFoodDom
						delete _alreadyOrders[@orderId].allFood[@food.id]

			class AlreadyChoose

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

				_getFoodInfoBydcType = (alreadyChoose)->

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
					type = _alreadyOrders[alreadyChoose.orderId].allFood[alreadyChoose.id].food.type
					if type is "combo_static" or type is "combo_sum"
						return "<ul class='combo-list'>
									#{_getComboInfoByOptions alreadyChoose.comboOptions}
								</ul>"
					return alreadyChoose.chooseInfo

				_getAlreadyChooseDom = (alreadyChoose)->
					dom = createDom "li"; dom.className = 'food-order-choose'
					food = _alreadyOrders[alreadyChoose.orderId].allFood[alreadyChoose.id].food
					alreadyFoodDom = _alreadyOrders[alreadyChoose.orderId].allFood[alreadyChoose.id].alreadyFoodDom
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
														<p class='choose'>#{_getFoodInfoBydcType alreadyChoose}</p>
													</div>
												</div>
											</div>
											<div class='bottom-wrap font-number-word'>
												<div class='price-field'>
													<p class='min-price money'>#{Number((alreadyChoose.afterChoosePrice).toFixed(2))}</p>
												</div>
												<div class='controll-field'>
													<div class='number-field'>
														<p class='num'>#{alreadyChoose.num}</p>
													</div>
												</div>
											</div>
										</div>
									</div>"
					
					lineDom = createDom "div"; lineDom.className = 'fivePercentLeftLine'
					append alreadyFoodDom, lineDom

					append alreadyFoodDom, dom
					dom

				constructor: (options)->
					deepCopy options, @
					@init()
					_alreadyOrders[@orderId].allFood[@id].allChoose.push @

				init: ->
					@initAlreadyChooseDom()

				initAlreadyChooseDom: ->
					@alreadyChooseDom = _getAlreadyChooseDom @
					@numDom = query ".num", @alreadyChooseDom

				addOrderByNum: (num)->
					@num += num
					@numDom.innerHTML = @num

				subtractOrderByNum: (num)->
					if (@num - num) < 0 then return
					dcType = _alreadyOrders[@orderId].allFood[@id].food.dcType
					@num -= num; @numDom.innerHTML = @num
					if @num is 0 then @deleteDomAndSelf()

				deleteDomAndSelf: ->
					brotherDom = getBrotherDom @alreadyChooseDom
					if brotherDom then remove brotherDom
					remove @alreadyChooseDom
					index = _alreadyOrders[@orderId].allFood[@id].getAlreadyChooseIndexByChooseInfo @chooseInfo
					if index >= 0 then _alreadyOrders[@orderId].allFood[@id].allChoose.splice(index, 1)
					_alreadyOrders[@orderId].allFood[@id].checkIfNeedRemove()


		getInstance: ->
			if _instance is null then _instance = new AlreadyManage()
			return _instance

		initial: ->
			alreadyManage = @getInstance()
			alreadyManage.initAlready()
