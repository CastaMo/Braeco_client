do (window, document)->

	[addListener, removeListener, hasClass, addClass, removeClass, ajax, getElementsByClassName, isPhone, hidePhone, query, querys, remove, append, prepend, toggleClass, getObjectURL, deepCopy, getById] = [util.addListener, util.removeListener, util.hasClass, util.addClass, util.removeClass, util.ajax, util.getElementsByClassName, util.isPhone, util.hidePhone, util.query, util.querys, util.remove, util.append, util.prepend, util.toggleClass, util.getObjectURL, util.deepCopy, util.getById]

	clientWidth =  document.body.clientWidth

	compatibleCSSConfig = [
		""
		"-webkit-"
		"-moz-"
		"-ms-"
		"-o-"
	]

	allPageManage = do ->
		_allMainDoms = querys ".main-page"
		_allHomeDoms = querys ".main-home-page"
		_allDetailDoms = querys ".main-detail-page"

		_allHomeId = ["Menu-page", "Already-page", "Individual-page"]
		_allDetailId = ["Book-page", "Activity-page"]

		_hideAllMainPage = -> addClass dom, "hide" for dom in _allMainDoms

		_hideAllHomePage = -> addClass dom, "hide" for dom in _allHomeDoms

		_hideAllDetailPage = -> addClass dom, "hide" for dom in _allDetailDoms

		_showPage = (id)-> removeClass(getById("#{id}"), "hide")

		hideAllPage = -> _hideAllMainPage(); _hideAllHomePage(); _hideAllDetailPage()

		switchTargetPage: (id)->
			hideAllPage()
			if id in _allHomeId then _showPage("brae-home-page")
			else if id in _allDetailId then _showPage("brae-detail-page")
			_showPage(id)
			setTimeout(scrollTo, 0, 0, 0)

		hideAllPage: hideAllPage

	HomeBottom = do ->
		_state = ""
		_allDoms = querys "#nav-field .bottom-field div"


		uncheckAllForBottomAndHideAllPage = ->
			for dom in _allDoms
				id = dom.id; dom.className = "#{id}-unchecked"; allPageManage.hideAllPage()

		bottomTouchEventTrigger = (id)->
			if _state isnt id
				###
				*WebSocketxxxxx
				###
			_state = id
			uncheckAllForBottomAndHideAllPage()
			getById(id).className = "#{id}-checked"
			allPageManage.switchTargetPage("#{id}-page")


		bottomTouchEventTrigger: bottomTouchEventTrigger
		uncheckAllForBottomAndHideAllPage: uncheckAllForBottomAndHideAllPage

	HomeMenu = do ->
		
		_activityColumnDom = query "#Menu-page #Menu-acitvity-column"

		addListener _activityColumnDom, "click", -> hashRoute.hashJump("-Activity")

	Lock = do ->

	class Category

		_catergoryDisplayDom = query "#Menu-page .category-display-list"


	class Activity
		_headerDom = query "#Activity-page #Activity-header-column"


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
			query(options.macroCSSSelector).style.height = "#{options.scale * clientWidth}px"

			@init()

		init: ->
			@initDisplay()
			@initChoose()
			@initAutoRotate()
			@initTouchEvent()

		initDisplay: ->
			@displayContainerDom = @displayUlDom.parentNode
			@displayContainerDom.style.overflow = "auto"
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
			@chooseUlDom.parentNode.style.overflow = "auto"
			self = @
			@allChooseDom = querys "li", @chooseUlDom
			@currentChoose = 0
			for dom, i in @allChooseDom
				addListener dom, "click", do (i)-> -> self.autoFlag = false; self.setCurrentChooseAndTranslate(i)

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



		

	hashRoute = do ->
		_loc = window.location
		_msgs = {
			"Menu": {
				"push": -> HomeBottom.bottomTouchEventTrigger("Menu")
				"pop": HomeBottom.uncheckAllForBottomAndHideAllPage
				"title": "餐牌"
			}
			"Already": {
				"push": -> HomeBottom.bottomTouchEventTrigger("Already")
				"pop": HomeBottom.uncheckAllForBottomAndHideAllPage
				"title": "已点订单"
			}
			"Individual": {
				"push": -> HomeBottom.bottomTouchEventTrigger("Individual")
				"pop": HomeBottom.uncheckAllForBottomAndHideAllPage
				"title": "个人信息"
			}
			"Book": {
				"push": -> allPageManage.switchTargetPage("Book-page")
				"pop": allPageManage.hideAllPage
			}
			"Activity": {
				"push": -> allPageManage.switchTargetPage("Activity-page")
				"pop": allPageManage.hideAllPage
			}
			###
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
			###
			"x": {
				"push": -> setTimeout(->
					_popHashStr("x")
				,0)
				"pop": -> setTimeout(->
					_popHashStr("x")
				,0)
			}
		}
		addListener window, "popstate", ->
			_parseAndExecuteHash _getHashStr()

		title_dom = util.query("title")

		_recentHash = _loc.hash.replace("#", "")

		_getHashStr =  -> _loc.hash.replace("#", "")

		_pushHashStr = (str)-> _loc.hash = "#{_recentHash}-#{str}"

		_popHashStr = (str)-> _loc.hash = _recentHash.replace("-#{str}", "")

		_modifyTitle = (str)-> title_dom.innerHTML = str

		_parseAndExecuteHash = (str)->
			hash_arr = str.split("-")
			if hash_arr.length <= 1 and hash_arr[0] is "" then return

			old_arr = _recentHash.split("-")
			hash_arr.splice(0, 1); old_arr.splice(0, 1)
			last_state = hash_arr[hash_arr.length-1]

			#if last_state and msgs[last_state] and msgs[last_state]["title"] then hashRoute.modifyTitle(msgs[last_state]["title"])

			if str is _recentHash
				for entry in hash_arr
					if entry and _msgs[entry] then _msgs[entry]["push"]?()
				if str is "-Individual-Login" then setTimeout(hashRoute.back, 0)
				return

			temp_counter = {}
			for entry in old_arr
				if entry then temp_counter[entry] = 1
			for entry in hash_arr
				if not entry then continue
				if temp_counter[entry] then temp_counter[entry]++
				else temp_counter[entry] = 1

			for i in [old_arr.length-1..0]
				if old_arr[i] and _msgs[old_arr[i]] and temp_counter[old_arr[i]] is 1 then _msgs[old_arr[i]]["pop"]?()
			for i in [0..hash_arr.length-1]
				if hash_arr[i] and _msgs[hash_arr[i]] and temp_counter[hash_arr[i]] is 1 then _msgs[hash_arr[i]]["push"]?()

			_recentHash = str

		ahead: -> history.go(1)

		back: -> history.go(-1)

		refresh: -> _loc.reload()

		hashJump: (str)-> _loc.hash = str

	Db = do ->
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
		allPageManage.switchTargetPage("Activity-page")
		
		new rotateDisplay {
			displayCSSSelector: "#Menu-page .activity-display-list"
			chooseCSSSelector: "#Menu-page .choose-dot-list"
			macroCSSSelector: "#Menu-page #Menu-acitvity-column"
			scale: 110/377
			delay: 3000
		}
		new rotateDisplay {
			displayCSSSelector: "#Activity-page .header-display-list"
			chooseCSSSelector: "#Activity-page .choose-dot-list"
			macroCSSSelector: "#Activity-page #Activity-header-column"
			scale: 200/375
			delay: 3000
		}
		

