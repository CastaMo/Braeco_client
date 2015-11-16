do (window, document)->

	[addListener, removeListener, hasClass, addClass, removeClass, ajax, getElementsByClassName, isPhone, hidePhone, query, querys, remove, append, prepend, toggleClass, getObjectURL, deepCopy, getById] = [util.addListener, util.removeListener, util.hasClass, util.addClass, util.removeClass, util.ajax, util.getElementsByClassName, util.isPhone, util.hidePhone, util.query, util.querys, util.remove, util.append, util.prepend, util.toggleClass, util.getObjectURL, util.deepCopy, util.getById]

	clientWidth =  document.body.clientWidth

	compatibleCssConfig = [
		""
		"-webkit-"
		"-moz-"
		"-ms-"
		"-o-"
	]

	Bottom = do ->
		_state = ""
		_allDoms = querys "#nav-field .bottom-field div"

		_switchTargetPage = (id)->
			removeClass(query("##{id}-page"), "hide")
			setTimeout(scrollTo, 0, 0, 0)


		uncheckAllForBottomAndHideAllPage = ->
			for dom in _allDoms
				id = dom.id; dom.className = "#{id}-unchecked"; addClass(query("##{id}-page"), "hide")

		bottomTouchEventTrigger = (id) ->
			if _state is id then return
			_state = id
			###
			*WebSocketxxxxx
			###
			uncheckAllForBottomAndHideAllPage()
			getById(id).className = "#{id}-checked"
			_switchTargetPage(id)


		bottomTouchEventTrigger: bottomTouchEventTrigger
		uncheckAllForBottomAndHideAllPage: uncheckAllForBottomAndHideAllPage

	Lock = do ->

	class Category

		_catergoryDisplayDom = query "#Menu-page .category-display-list"


	ActivityDisplay = do ->
		_activityDisplayDom = query "#Menu-page .activity-display-list"
		_activityChooseDom = query "#Menu-page .choose-dot-list"
		_activityChooseAllDom = null
		_activityDisplayAllDom = null
		_activityNum = 0
		_currentChoose = 0

		_setCurrentChoose = (index)->
			_activityChooseAllDom[_currentChoose].className = "inactive"
			_activityChooseAllDom[index].className = "active"
			_currentChoose = index

		_initForActivityChoose = ->
			_activityChooseAllDom = querys "li", _activityChooseDom
			for dom, i in _activityChooseAllDom
				addListener dom, "click", do (i)-> -> _setCurrentChooseAndTranslate(i)

		_getCompatibleTranslateCss = (ver, hor)->
			result_ = {}
			for config in compatibleCssConfig
				result_["#{config}transform"] = "translate(#{ver}, #{hor})"
			return result_

		_setCurrentChooseAndTranslate = (index)->
			if index < 0 or index >= _activityNum or index is _currentChoose then return
			transIndex =  -1 * index
			compatibleTranslateCss = _getCompatibleTranslateCss("#{transIndex * clientWidth}px", 0)
			for key, value of compatibleTranslateCss
				_activityDisplayDom.style[key] = value
			_setCurrentChoose(index)
		

		_initForActivityDisplay = ->
			_allDoms = querys "li", _activityDisplayDom
			for dom in _allDoms
				dom.style.width = "#{clientWidth}px"
			_activityNum = _allDoms.length
			_activityDisplayDom.style.width = "#{clientWidth * _activityNum}px"


		initial: ->
			_initForActivityDisplay()
			_initForActivityChoose()

		

	hashRoute = do ->
		_loc = window.location
		_msgs = {
			"Menu": {
				"push": -> Bottom.bottomTouchEventTrigger("Menu")
				"pop": Bottom.uncheckAllForBottomAndHideAllPage
				"title": "餐牌"
			}
			"Already": {
				"push": -> Bottom.bottomTouchEventTrigger("Already")
				"pop": Bottom.uncheckAllForBottomAndHideAllPage
				"title": "已点订单"
			}
			"Individual": {
				"push": -> Bottom.bottomTouchEventTrigger("Individual")
				"pop": Bottom.uncheckAllForBottomAndHideAllPage
				"title": "个人信息"
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



	window.onload = ->
		Bottom.bottomTouchEventTrigger("Menu")
		ActivityDisplay.initial()

