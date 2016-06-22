	hashRoute = do ->

		_extraMainDom = getById "#extra"


		_allMainDoms = querys ".main-page"
		_allMainHomeDoms = querys ".main-home-page"
		_allMainDetailDoms = querys ".main-detail-page"

		_allExtraDoms = querys ".extra-page"
		_allExtraContentDoms = querys ".extra-content-page"
		
		_allPopupFormDoms = querys ".popup-form-page"

		_activityInfoDom = query ".Activity-information-field"

		_bookPageDom = getById "book-order-wrap"
		_bookDishDom = getById "book-dish-wrap"

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
				"push": ->
					bookOrder.toggleState "col"
					Category.chooseBookCategoryByCurrentChoose()
					DetailPage.togglePage "bookCol"
				"pop": -> 
			}
			"bookInfo": {
				"push": ->
					bookOrder.toggleState "info"
					foodInfo.chooseFoodByCurrentChoose()
					DetailPage.togglePage "bookInfo"
				"pop": -> 
			}
			"bookOrder": {
				"push": ->
					bookOrder.toggleState "order"
					DetailPage.togglePage "bookOrder"
				"pop": ->
			}
			"choosePaymentMethod": {
				"push": ->
					pay.selectPayInfoByCurrentChoose()
					DetailPage.togglePage "choosePaymentMethod"
					if not user.isLogin() then hashRoute.back()
				"pop": -> 
			}
			"chooseCombo": {
				"push": ->
					DetailPage.togglePage "chooseCombo"
					comboManage.getComboId()
			}
			"Activity": {
				"push": -> _staticShowTarget("Activity-page"); Activity.getImageBufferForAllAcitvityByType "info"; DinnerHeader.getImageBufferForAllDinnerHeader()
				"pop": -> _hideTarget("Activity-page")
			}
			"activityInfo": {
				"push": ->
					Activity.chooseActivityByCurrentChoose()
					_switchSecondaryPage("activityInfo", "Activity", _activityInfoDom)
				"pop": -> _hideSecondaryPage(_activityInfoDom)
			}
			"Extra": {
				"push": -> _staticShowTarget("extra")
				"pop": -> _hideTarget("extra")
			}
			"extraContent": {
				"push": -> _staticShowTarget("brae-extra-content-page")
				"pop": -> _hideTarget("brae-extra-content-page")
			}
			"Recharge": {
				"push": ->
					_staticShowTarget("Recharge-page")
					if not user.isLogin() then hashRoute.back()
				"pop": -> _hideTarget("Recharge-page")
			}
			"Coupon": {
				"push": -> _staticShowTarget("Coupon-page"); couponManage.judgeState()
				"pop": -> _hideTarget("Coupon-page")
			}
			"Popup": {
				"push": -> _staticShowTarget("popup")
				"pop": -> _hideTarget("popup")
			}
			"Form": {
				"push": -> _staticShowTarget("brae-form-page")
				"pop": -> _hideTarget("brae-form-page")
			}
			"bookChoose": {
				"push": ->
					bookChoose.chooseFoodByCurrentChoose()
					_staticShowTarget("book-choose-page")
					FormPage.togglePage "book-choose-page"
				"pop": -> _hideTarget("book-choose-page")
			}
			"categoryChoose": {
				"push" 	: -> _staticShowTarget("category-choose-page"); FormPage.togglePage "category-choose-page"
				"pop" 	: -> _hideTarget("category-choose-page")
			}
			"remarkForTrolley": {
				"push": -> _staticShowTarget("remark-for-trolley-page"); FormPage.togglePage "remark-for-trolley-page"
				"pop": -> _hideTarget("remark-for-trolley-page")
			}
			"Login": {
				"push": -> _staticShowTarget("login-page"); FormPage.togglePage "login-page"; User.getLoginInfoFromLocStor()
				"pop": -> _hideTarget("login-page")
			}
			"Confirm": {
				"push": ->
					if not confirmManage.isValid() then hashRoute.back()
					_staticShowTarget("confirm-page")
					FormPage.togglePage "confirm-page"
				"pop": -> _hideTarget("confirm-page")
			}
			"comboChooseDelete": {
				"push": ->
					_staticShowTarget "combo-choose-delete-page"
					FormPage.togglePage "combo-choose-delete-page"
					comboChooseDeleteManage.getSubItemFoodChoose()
				"pop": -> _hideTarget "combo-choose-delete-page"
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

		_hideAllExtraContentPage = -> addClass dom, "hide" for dom in _allExtraContentDoms

		_hideAllExtra = (async)->
			_hideAllExtraContentPage(); _hideAllExtraPage(); _hideTarget("extra")

		_hideAllPopupFormPage = -> addClass dom, "hide" for dom in _allPopupFormDoms

		_switchFirstPage = (id)->
			_hideAllMain()
			if id in _allMainHomeId then _staticShowTarget("brae-home-page")
			else if id in _allMainDetailId then _staticShowTarget("brae-detail-page")
			_staticShowTarget(id)
			setTimeout("scrollTo(0, 0)", 0)

		_switchSecondaryPage = (currentState, previousState, pageDom)->
			if currentState in _secondaryInfo[previousState] then removeClass(pageDom, "hide-right")
			setTimeout("scrollTo(0, 0)", 0)

		_hideSecondaryPage = (pageDom)-> addClass(pageDom, "hide-right")

		_hideAllMainPage = -> addClass dom, "hide" for dom in _allMainDoms

		_hideAllMainHomePage = -> addClass dom, "hide" for dom in _allMainHomeDoms

		_hideAllMainDetailPage = -> addClass dom, "hide" for dom in _allMainDetailDoms

		_hideAllMain = -> _hideAllMainHomePage(); _hideAllMainDetailPage(); _hideAllMainPage()

		_staticShowTarget = (id)-> removeClass(getById(id), "hide"); setTimeout("scrollTo(0, 0)", 0)

		_dynamicShowTarget = (id, className)-> removeClass(getById(id), "hide"); setTimeout(->
			removeClass(getById(id), className); setTimeout("scrollTo(0, 0)", 0)
		, 50)

		_hideTarget = (id, className)->
			_target = getById id
			if className then addClass _target, className; setTimeout(->
				addClass _target, "hide"
			, 400)
			else addClass _target, "hide"
			setTimeout("scrollTo(0, 0)", 0)

		_getHashStr =  -> _loc.hash.replace("#", "")

		_modifyTitle = (str)-> document.title = str

		_parseAndExecuteHash = (str)->
			hash_arr = str.split("-")
			if hash_arr.length <= 1 and hash_arr[0] is "" then return

			old_arr = _recentHash.split("-")
			hash_arr.splice(0, 1); old_arr.splice(0, 1)
			last_state = hash_arr[hash_arr.length-1]

			#if last_state and _hashStateFunc[last_state] and _hashStateFunc[last_state]["title"] then _modifyTitle _hashStateFunc[last_state]["title"]


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

		back: -> history.go(-1)

		refresh: -> _loc.reload()

		pushHashStr: pushHashStr
		popHashStr: popHashStr
		hashJump: hashJump
		parseAndExecuteHash: -> _parseAndExecuteHash _getHashStr()
		getCurrentState: -> _recentHash.split("-").pop()
		warn: -> alert "非法操作"; hashRoute.back()

	###
	*	重构
	###
	RouteManageSingleton = do ->
		_instance = null

		class RouteManage
			
			_hashStateFunc = {}

			_loc = window.location

			_recentHash = _loc.hash.replace("#", "")

			constructor: ->

			getOrCreateRouteEntry: (options)->
				if _e = _hashStateFunc[options.name] then return _e
				return new routeEntry options

			toggleHashState: (str)->
				_r = "-#{str}"
				try
					while _p = _hashStateFunc[str].parent
						_r = "-#{_p}#{_r}"; str = _p
					_loc.hash = _r
				catch e
					@warn()
				

			parseAndExecuteHash: (str)->
				hash_arr = str.split("-")
				if hash_arr.length <= 1 and hash_arr[0] is "" then return

				old_arr = _recentHash.split("-")
				hash_arr.splice(0, 1); old_arr.splice(0, 1)
				last_state = hash_arr[hash_arr.length-1]

				#if last_state and _hashStateFunc[last_state] and _hashStateFunc[last_state]["title"] then _modifyTitle _hashStateFunc[last_state]["title"]


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


			back: -> history.go(-1)

			refresh: -> _loc.reload()

			pushHashStr: (str)-> _loc.hash = "#{_recentHash}-#{str}"

			popHashStr: (str)-> _loc.hash = _recentHash.replace("-#{str}", "")

			hashJump: (str)-> _loc.hash = str

			getCurrentState: -> _recentHash.split("-").pop()

			warn: -> alert "非法操作"; hashRoute.back()

			class routeEntry extends Base

				constructor: (options)->
					super options
					_hashStateFunc[@name] = @

				init: ->


		getInstance: ->
			if _instance is null then _instance = new RouteManage()
			return _instance

		initial: -> routeManage = RouteManageSingleton.getInstance()
