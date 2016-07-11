	class Food

		_foodInfoImgDom = query "#book-info-wrap .food-img-wrapper .img"

		_foodsArr = []
		_foodsMap = {}

		_getImageBufferFlag = []

		_ComboType = ['combo_sum', 'combo_static']

		_isCombo = (type)-> return (type in _ComboType)

		_getDCLabelForTopWrapDom = (food)->
			dcDom = ""
			if food.dcType is "discount"
				num = food.dc; if food.dc % 10 is 0 then num = numToChinese[Math.round(food.dc / 10)] else num = food.dc/10
				dcDom = "<p class='dc-label'>#{num}折</p>"
			else if food.dcType is "sale" then dcDom = "<p class='dc-label'>减#{food.dc}元</p>"
			else if food.dcType is "half" then dcDom = "<p class='dc-label'>第二份半价</p>"
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
			minPrice = "<p class='min-price money'>#{food.getAfterDiscountPrice food.chooseAllFirstPrice}</p>"
			minPrice

		_getInitPriceForBottomWrapDom = (food)->
			initPrice = ""; afterDiscountPrice = food.getAfterDiscountPrice food.chooseAllFirstPrice
			if afterDiscountPrice < food.chooseAllFirstPrice then initPrice = "<p class='init-price money'>#{food.chooseAllFirstPrice}</p>"
			initPrice

		_getBottomWrapForInfoDom = (food)->
			if food.isCombo then _btn = 	"<div class='choose-to-add plus-field'>
												<div class='word'>选择</div>
											</div>"
			else _btn = 	"<div class='plus-field btn'>
								<div class='img'></div>
							</div>"
			bottomWrapDom = createDom("div"); bottomWrapDom.className = "bottom-wrap font-number-word"
			priceField = "<div class='price-field'>
							#{_getMinPriceForBottomWrapDom(food)}
							#{_getInitPriceForBottomWrapDom(food)}
						</div>"
			controllField = "<div class='controll-field'>
								#{_btn}
							</div>"
			append bottomWrapDom, priceField
			append bottomWrapDom, controllField
			return bottomWrapDom

		_getImgDomForFoodDom = (food)->
			labelImgDom = ""
			if food.dcType and food.dcType isnt "none"
				labelImgDom = "<div class='label-img #{food.dcType}-img'></div>"

			imgDom = createDom("div"); imgDom.className = "left-part"
			imgDom.innerHTML = "<div class='img-field'><div class='img default-square-image'></div>#{labelImgDom}</div>"

			return imgDom

		_getInfoDomForFoodDom = (food)->
			infoDom = createDom("div")
			infoDom.className = 'right-part'
			topWrapDom = _getTopWrapDomForInfoDom(food)
			bottomWrapDom = _getBottomWrapForInfoDom(food)
			append infoDom, topWrapDom
			append infoDom, bottomWrapDom
			return infoDom

		_getFoodDom = (food)->
			dom = createDom("li"); dom.id = "food-#{food.seqNum}"; if food.dcType is "combo_only" then dom.className = 'hide'
			foodInfoDom = createDom("div"); foodInfoDom.className = "food-info-field"

			imgDom = _getImgDomForFoodDom(food)
			infoDom = _getInfoDomForFoodDom(food)
			if imgDom then append foodInfoDom, imgDom
			append foodInfoDom, infoDom
			append dom, foodInfoDom

			fivePercentLeftLine = createDom("div"); fivePercentLeftLine.className = "fivePercentLeftLine"

			corresFoodListDom = query ".food-list-wrap #food-list-#{food.categorySeqNum}"
			append corresFoodListDom, dom
			if food.dcType isnt "combo_only" then append corresFoodListDom, fivePercentLeftLine

			return dom

		_getChooseElemArrayFromChooseArray = (arr)->
			_results = {}
			j = 0;
			while arr[j]
				_results[j] = arr[j]; j++
			_results.length = j
			_results.groupname = arr.groupname
			_results.groupid = arr.groupid
			_results

		_getChooseArrayFromObject = (arr)->
			i = 0;
			while arr[i]
				_getChooseElemArrayFromChooseArray arr[i++]

		_setCurrentChoose = (id, chooseName)->
			locStor.set chooseName, JSON.stringify id

		_getAfterDiscountPriceFunction = (food)->
			getAfterDiscountPrice = (price)-> Number(price)
			if food.dcType is "none" or food.dcType is "half" or not food.dcType or food.dcType is "limit"
				getAfterDiscountPrice = (price)-> price
			else if food.dcType is "discount"
				getAfterDiscountPrice = (price)-> Number((price * food.dc / 100).toFixed(2))
			else if food.dcType is "sale"
				getAfterDiscountPrice = (price)-> Number((price - food.dc).toFixed(2))
			getAfterDiscountPrice

		_getChooseAllFirstPrice = (food)->
			extraPrice = 0
			for tempOuter in food.chooseArr
				extraPrice += tempOuter.property[0].price
			(extraPrice + food.defaultPrice)

		constructor: (options)->
			deepCopy options, @
			@init()
			_foodsArr[@categorySeqNum].push @
			_foodsMap[@id] = @

		init: ->
			@initSpecial()
			@initFoodDom()
			@initAllEvent()

		initFoodDom: ->
			self = @
			@foodDom = _getFoodDom @

		initAllEvent: ->
			self = @
			addListener self.foodDom, "click", (e)->
				target = e.target || e.srcElement
				parentNode = findParent(target, (parent)-> return (hasClass(parent, "controll-field") || hasClass(parent, "food-list-wrap")))
				if parentNode and (hasClass(parentNode, "controll-field")) then return
				if hashRoute.getCurrentState() is "bookInfo" then return
				_setCurrentChoose self.id, "foodCurrentChoose"; hashRoute.hashJump("-Detail-Book-bookInfo")
			addListener (query ".plus-field", self.foodDom), "click", do ->
				if self.isCombo then return (e)->
					_orderId = locStor.get "comboId" || "-1000"
					if Number(_orderId) isnt self.id then locStor.set "comboOrder", "[]"
					locStor.set "comboId", self.id; hashRoute.hashJump "-Detail-Book-chooseCombo"
				else return (e)-> self.judgeForBook {initLeft:clientWidth * 0.9 - 30, initTop: @getBoundingClientRect().top - 7.5}, @

		initSpecial: ->
			@isCombo = _isCombo @type
			@getAfterDiscountPrice = _getAfterDiscountPriceFunction @
			@chooseAllFirstPrice = _getChooseAllFirstPrice @

		getCoresImgDomByType: (type)->
			if type is "dish" then return (query ".img", @foodDom)
			else if type is "info" then return _foodInfoImgDom

		getImageBuffer: (type)->
			self = @
			url = self["#{type}Url"]
			if url then imageBuffer = new ImageBuffer {
				url 		:		url
				targetDom 	:		self.getCoresImgDomByType type
				id 			:		"food-#{type}-#{self.id}"
			}

		checkAndTrySubtractLimit: (num)->
			if @dcType isnt "limit" then return true
			if @checkLimit(-1*num)
				@setLimit(-1*num)
				return true
			return false

		checkAndTryAddLimit: (num)->
			if @dcType isnt "limit" then return true
			if @checkLimit(num)
				@setLimit(num)
				return true
			return false

		checkLimit: (num)->
			if @dcType isnt "limit" then return true
			return (@dc + num >= 0)

		setLimit: (num)->
			@dc += num; (query ".dc-label", @foodDom).innerHTML = "剩#{@dc}件"

		judgeForBook: (optionsForBall, addDom)->
			if @isCombo
				_orderId = locStor.get "comboId" || "-1000"
				if Number(_orderId) isnt @id then locStor.set "comboOrder", "[]"
				locStor.set "comboId", @id; hashRoute.hashJump "-Detail-Book-chooseCombo"
			else if @chooseArr.length is 0
				@clickForBook 1, "", @defaultPrice, optionsForBall, addDom
			else
				if not @checkLimit -1 then alert("#{@cName}剩余菜品数量不足"); return
				_setCurrentChoose @id, "bookFoodCurrentChoose"
				locStor.set "bookChooseTargetInfo", "bookOrder"
				hashRoute.pushHashStr("Popup-Form-bookChoose")

		deleteSelfDom: ->
			brotherDom = getBrotherDom @foodDom
			if brotherDom then remove brotherDom
			remove @foodDom

		clearAllLimit: ->
			if @dcType is "limit" then @dc = 0; (query ".dc-label", @foodDom).innerHTML = "剩#{@dc}件"

		clickForBook: (num, chooseInfo, afterChoosePrice, optionsForBall, addDom)->

			if not @checkLimit(-1*num) then lockManage.get("bookClick").releaseLock(); alert("#{@cName}剩余菜品数量不足"); return
			self = @
			new ActiveBall {
				initLeft: optionsForBall.initLeft
				initTop: optionsForBall.initTop
				callback: ->
					bookOrder.addOrderSignal(); self.addBookToOrder num, chooseInfo, afterChoosePrice
					setTimeout (-> bookOrder.animationCallback()), 420
			}

		addBookToOrder: (num, chooseInfo, afterChoosePrice, comboOptions)->
			bookOrder.bookForFood {
				categorySeqNum 		:		@categorySeqNum
				seqNum 				:		@seqNum
				cName 				:		@cName
				afterChoosePrice 	:		afterChoosePrice
				id 					:		@id
				num 				:		num
				chooseInfo 			:		chooseInfo
				dcType 				:		@dcType
				type 				: 	@type
				dc 					:		@dc
				tag 				:		@tag
				comboOptions		:		comboOptions || []
			}

		addBookToAlready: (num, chooseInfo, afterChoosePrice, comboOptions)->
			alreadyManage.recordForFood {
				categorySeqNum 		:		@categorySeqNum
				seqNum 				:		@seqNum
				cName 				:		@cName
				afterChoosePrice 	:		afterChoosePrice
				id 					:		@id
				num 				:		num
				chooseInfo 			:		chooseInfo
				dcType 				:		@dcType
				dc 					:		@dc
				tag 				:		@tag
				comboOptions		:		comboOptions || []
			}

		getDiffByChooseInfo: (chooseInfo)->
			arr = chooseInfo.split " 、 "
			diff = 0
			for chooseElem, i in @chooseArr
				for elem in chooseElem.property
					if arr[i] is elem.name then diff += elem.price
			return diff

		@getImageBufferForCorresCategoryNum: (categorySeqNum)->
			if _getImageBufferFlag[categorySeqNum] then return
			_getImageBufferFlag[categorySeqNum] = true
			for food in _foodsArr[categorySeqNum]
				food.getImageBuffer "dish"


		@initial: ->
			dishJSON = getJSON getDishJSON()
			for tempOuter, i in dishJSON
				_foodsArr[i] = []
				_getImageBufferFlag.push false
				for temp, j in tempOuter.dishes
					temp.groups = temp.groups || []
					if temp.pic then url = "#{temp.pic}?imageView2/1/w/95/h/95"; infoUrl = "#{temp.pic}?imageView2/1/w/#{Math.floor(clientWidth)}/h/#{Math.floor(clientWidth*200/375)}"
					else url = ""; infoUrl = ""

					if temp.dc_type is "limit"
						temp.dc = dishLimitManage.getDishLimitById(temp.id).dc

					newGroup = []
					if temp.type is "normal"
						for groupId in temp.groups
							group = groupManage.getGroupById groupId
							newTemp = {}
							newTemp.groupname = group.name
							newTemp.property = group.content
							newGroup.push newTemp
						temp.chooseArr = newGroup
					else if _isCombo temp.type
						for groupId, index in temp.groups
							newTemp = {}
							group = groupManage.getGroupById groupId
							newTemp.discount = group.discount || 0
							newTemp.price = group.price || 0
							newTemp.require = temp.require[index]
							newTemp.name 	= group.name
							newTemp.content = []
							newTemp.type = group.type
							deepCopy group.content, newTemp.content
							newGroup.push newTemp
						temp.combo = newGroup

					food = new Food {
						dc 				:		Number(temp.dc) || 0
						type 			: 	temp.type
						dcType 			:		temp.dc_type
						defaultPrice	:		temp.default_price
						id 				:		temp.id
						cName 			:		temp.name
						eName 			:		temp.name2
						dishUrl 		:		url
						infoUrl 		:		infoUrl
						categorySeqNum 	:		i
						seqNum 			:		j
						tag 			:		temp.tag
						intro 			: 		temp.detail || ""
						chooseArr 		:		temp.chooseArr || []
						like 			:		temp.like
						combo 			:		temp.combo  || []
					}


		@getFoodByCategorySeqNumAndSeqNum: (categorySeqNum, seqNum)-> _foodsArr[categorySeqNum][seqNum]
		@getFoodById: (id)-> _foodsMap[id]

		