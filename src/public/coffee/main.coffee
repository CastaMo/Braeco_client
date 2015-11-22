do (window, document)->

	[addListener, removeListener, hasClass, addClass, removeClass, ajax, getElementsByClassName, isPhone, hidePhone, query, querys, remove, append, prepend, toggleClass, getObjectURL, deepCopy, getById] = [util.addListener, util.removeListener, util.hasClass, util.addClass, util.removeClass, util.ajax, util.getElementsByClassName, util.isPhone, util.hidePhone, util.query, util.querys, util.remove, util.append, util.prepend, util.toggleClass, util.getObjectURL, util.deepCopy, util.getById]

	clientWidth =  document.body.clientWidth
	clientHeight = document.documentElement.clientHeight

	compatibleCSSConfig = [
		""
		"-webkit-"
		"-moz-"
		"-ms-"
		"-o-"
	]

	Lock = do ->

	class Category

		_catergoryDisplayDom = query "#Menu-page .category-display-list"


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

			addListener _activityColumnDom, "click", -> hashJump("-Activity")

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

		_hideAllMainPage = -> [addClass dom, "hide"; console.log(dom)] for dom in _allMainDoms

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
					if entry and _hashStateFunc[entry] then setTimeout(->
						_hashStateFunc[entry]["push"]?()
					, i * 100)
				return
			console.log old_arr, hash_arr
			temp_counter = {}
			for entry in old_arr
				if entry then temp_counter[entry] = 1
			for entry in hash_arr
				if not entry then continue
				if temp_counter[entry] then temp_counter[entry]++
				else temp_counter[entry] = 1

			for i in [old_arr.length-1..0]
				if old_arr[i] and _hashStateFunc[old_arr[i]] and temp_counter[old_arr[i]] is 1 then _hashStateFunc[old_arr[i]]["pop"]?(); console.log old_arr[i]
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
		_switchExtraPage: _switchExtraPage


	LocalStorage = do ->
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
		#if location.hash is "" then hashRoute.hashJump("-Menu-x")
		hashRoute.hashJump("-Home")
		setTimeout(->
			hashRoute.pushHashStr("Menu")
			setTimeout(->
				hashRoute.pushHashStr("x")
				setTimeout(->
					hashRoute.hashJump("-Detail-Book")
				, 500)
			, 500)
		, 500)
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

		

