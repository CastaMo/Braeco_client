	class User

		###
		* user field
		###
		_IndividualDom = getById "Individual-page"
		_alreadyLoginDom = query ".Already-login-field", _IndividualDom
		_lvDom = query ".rank-field p.rank", _alreadyLoginDom
		_memberNameDom = query ".rank-field p.member-name", _alreadyLoginDom
		_memberImgDom = query ".member-img-pos #rank-img", _alreadyLoginDom
		_discountDom = query ".discount-field p.discount", _alreadyLoginDom
		_balanceDom = query ".remainder-EXP-Blend p.remainder-number", _alreadyLoginDom
		_currentEXPValueDom = query ".current-value", _alreadyLoginDom
		_currentEXPFullValueDom = query ".full-value", _alreadyLoginDom
		_currentEXPBarDom = query ".inner-bar", _alreadyLoginDom
		_isOverlap = {}
		_ladder = []

		###
		* login field
		###
		_loginDom = getById "login-page"
		_picIdWrapperDom = query ".pic-id-wrapper", _loginDom
		_phoneDom = query "input#phone", _loginDom
		_idDom = query "input#id", _loginDom
		_picIdDom = query "input#picId", _loginDom
		_getIdDom = getById "get-id-btn"
		_getPicIdDom = getById "get-pic-id-btn"
		_waitDom = query "#wait-btn", _loginDom
		_confirmLoginBtnDom = query ".confirm-field", _loginDom
		_closeBtnDom = query ".btn-field", _loginDom
		_warnEditDom = querys("p.warm", _loginDom)[1]

		_notYetLoginDom = query ".not-yet-login-field"
		_notYetLoginBtnDom = query ".not-yet-login-wrapper", _notYetLoginDom

		_waitSec = 0
		_picIdWidth = parseInt clientWidth * 0.8 * 0.9 * 0.45
		_isNeedPicId = false

		_initIsOverlap = (comPre)->
			_isOverlap["discount"] = Boolean(comPre & 1)
			_isOverlap["sale"] = Boolean(comPre & 2)
			_isOverlap["half"] = Boolean(comPre & 4)
			_isOverlap["limit"] = Boolean(comPre & 8)
			_isOverlap["combo_only"] = Boolean(comPre & 16)
			_isOverlap["combo_sum"] = Boolean(comPre & 32)
			_isOverlap["combo_static"] = Boolean(comPre & 64)

		_initLadder = (ladder)-> deepCopy ladder, _ladder

		_getCorresIndexFromLadder = (EXP)->
			fullFlag = true; index = 0
			for expInfo, i in _ladder
				if expInfo.EXP > EXP
					index = i - 1; fullFlag = false; break
			if fullFlag then index = _ladder.length - 1
			{fullFlag: fullFlag, index: index}

		_updateCurrentMemberRankDom = (user)->
			_lvDom.innerHTML = "Lv.#{user.currentRank}"
			_memberImgDom.className = "member-rank-#{user.currentRank}"
			_memberNameDom.innerHTML = "#{user.rankName}级会员"
			_currentEXPFullValueDom.innerHTML = user.currentFullEXP
			_currentEXPBarDom.style.width = ""

			if user.discount >= 100 then discountStr = "升级后尊享更多优惠" else discountStr = "尊享#{(user.discount/10).toFixed(1)}折优惠"
			_discountDom.innerHTML = discountStr


		_setCurrentMemberRankInfo = (user, index, fullIndex)->
			user.currentRank = index;
			user.rankName = _ladder[index].name;
			user.discount = _ladder[index].discount;
			user.currentFullEXP = _ladder[fullIndex].EXP

		_checkEXPByLadder = (user)->
			result = _getCorresIndexFromLadder user.EXP
			if result.fullFlag then index = _ladder.length - 1; fullIndex = index
			else index = result.index; fullIndex = index + 1
			_setCurrentMemberRankInfo user, index, fullIndex
			_updateCurrentMemberRankDom user

		_getLoginInfoFromLocStor = ->
			flag = Number(locStor.get("loginFlag") || "0")
			if flag is 1 then _warnEditDom.innerHTML = "使用微信支付不需验证手机号"
			else if flag is 2 then _warnEditDom.innerHTML = "会员充值需要您验证手机号"
			else _warnEditDom.innerHTML = "首次使用请您先验证手机，以便享受更多优惠！"

		###
		* login field start
		###

		_waitEndCallBack = ->
			addClass _waitDom, "hide"; removeClass _getIdDom, "hide"

		_countForWait = ->
			_waitDom.innerHTML = "#{_waitSec}s后再试"
			if _waitSec is 0 then _waitEndCallBack()
			else _waitSec--; setTimeout _countForWait, 1000

		_toggleToGetIdState = (sec)->
			addClass _getIdDom, "hide"; removeClass _waitDom, "hide"; removeClass _confirmLoginBtnDom, "disabled"
			_waitSec = sec; _countForWait()

		_getIdSuccessCallBack = ->
			_setWaitTimeToLocStor();
			_toggleToGetIdState 60;
			user.isNeedPicIdChange false

		_loginSuccessCallBack = (result)->
			hashRoute.back();
			user.tryLoginAndUpdateInfo {
				avatar 				:		result.avatar
				birthday 			:		result.birthday
				city 				:		result.city
				country 			:		result.country
				mobile 				:		result.mobile
				nickName 			:		result.nickname
				province 			:		result.province
				registerTime 		:		result.register_time
				sex 				:		result.sex
				signature 			:		result.signature
				id 					:		result.user
				EXP 				: 		result.membership.EXP
				balance 			:		result.membership.balance
				like 				:		result.like
				address 			: 		result.address
			}
			bookOrder.refreshOrder()
			businessManage._setAddress()

		_setWaitTimeToLocStor = ->
			currentTime = new Date()
			locStor.set("lastGetIdTime", currentTime.getTime())


		_getLastWaitTimeFromLocStorAndJudge = ->
			currentTime = (new Date()).getTime()
			lastTime = Number(locStor.get "lastGetIdTime") || 0
			if lastTime and lastTime isnt 0 and currentTime - lastTime < 60*1000 then _toggleToGetIdState (Math.ceil((60*1000 - currentTime + lastTime) / 1000))

		_loginBtnClickEvent = ->
			if hasClass _confirmLoginBtnDom, "disabled" then return
			id = _idDom.value
			if id.length isnt 6 then alert "请输入6位验证码"; return
			if not lockManage.get("login").getLock() then return
			requireManage.get("login").require(id, (result)->
				_loginSuccessCallBack result
				setTimeout(->
					if hashRoute.getCurrentState() is "bookOrder" then locStor.set("currentPay", "bookOrder"); hashRoute.hashJump("-Detail-Book-choosePaymentMethod")
				, 300)
			, -> lockManage.get("login").releaseLock())

		_getIdClickEvent = ->
			picId = _picIdDom.value
			if _isNeedPicId
				if picId.length isnt 5 then alert "请输入5位图片验证码"; return
				Regx = /^[A-Za-z0-9]*$/
				if not Regx.test(picId) then alert "请输入数字或字母"; return
			if hasClass _getIdDom, "hide" then return
			if not lockManage.get("getId").getLock() then return
			phoneNum = _phoneDom.value
			if phoneNum.length isnt 11 or not isPhone(phoneNum) then alert "请输入正确的11位手机号码"; lockManage.get("getId").releaseLock(); return
			requireManage.get("getId").require(phoneNum, (result)->
				_getIdSuccessCallBack()
			, ->
				lockManage.get("getId").releaseLock()
			, picId)



		_toggleToAlreadyLogin = ->
			addClass _notYetLoginDom, "hide"; removeClass _alreadyLoginDom, "hide"

		_clickGetPicIdEvent = ->
			_getPicIdDom.style.backgroundImage = ""
			setTimeout ->
				_getPicIdDom.style.backgroundImage = "url('/Server/Captcha/#{_picIdWidth}/40')"
			, 50

		_isNeedPicIdChange = (isNeed)->
			_picIdDom.value = ""
			if isNeed then _isNeedPicId = true; removeClass _picIdWrapperDom, "hide"; _clickGetPicIdEvent(); addClass _confirmLoginBtnDom, "disabled"; _idDom.value = ""
			else _isNeedPicId = false; addClass _picIdWrapperDom, "hide"


		###
		* login field end
		###

		constructor: (options)->
			@initAllEvent()
			@tryLoginAndUpdateInfo options
			_getLastWaitTimeFromLocStorAndJudge()


		isLogin: -> Number(@id) isnt 0

		initAllEvent: ->
			fastClick _notYetLoginBtnDom, -> hashRoute.pushHashStr("Popup-Form-Login")
			fastClick _closeBtnDom, -> hashRoute.back()
			fastClick _getIdDom, _getIdClickEvent
			fastClick _confirmLoginBtnDom, _loginBtnClickEvent
			fastClick _getPicIdDom, _clickGetPicIdEvent
			addClass _closeBtnDom, "click", -> hashRoute.back()

		initBasicInfo: ->
			@setBalance @balance
			@setCurrentEXP @EXP
			@setId()
			@setCurrentLike()

		getLadder: -> _ladder

		getIsOverlap: -> _isOverlap

		setBalance: (balance)-> @balance = balance; _balanceDom.innerHTML = "#{Number(@balance.toFixed(2))}"

		isLike: -> return @like

		setLike: (isLike)-> @like = isLike

		setId: -> (query ".id-field p", _IndividualDom).innerHTML = "No.#{@id}号会员"

		setCurrentLike: ->
			if @like then DinnerHeader.setLikeState()
			else DinnerHeader.setUnlikeState()

		rechargeRemainder: (price, EXP)->
			@setBalance(@balance+price)
			@getEXPByPay EXP

		getEXPByPay: (EXP)->
			@setCurrentEXP(@EXP + EXP)
			bookOrder.refreshOrder()

		consumeByBalance: (price)->
			@setBalance(@balance - price)


		setCurrentEXP: (EXP)->
			@EXP = EXP
			_currentEXPValueDom.innerHTML = @EXP
			_checkEXPByLadder @
			_currentEXPBarDom.style.width = "#{100 * @EXP / @currentFullEXP}%"

		tryLoginAndUpdateInfo: (options)->
			deepCopy options, @
			@initBasicInfo()
			if @isLogin() then _toggleToAlreadyLogin(); webSock.reconnect()

		isNeedPicIdChange: (isNeed)-> _isNeedPicIdChange isNeed


		@getLadder: -> _ladder

		@initial: ->
			ComPreJSON = getJSON getComPreJSON()
			MemberJSON = getJSON getMemberJSON()

			_initIsOverlap ComPreJSON
			_initLadder MemberJSON.membership.ladder
			user = new User {
				avatar 				:		MemberJSON.avatar
				birthday 			:		MemberJSON.birthday
				city 					:		MemberJSON.city
				country 			:		MemberJSON.country
				mobile 				:		MemberJSON.mobile
				nickName 			:		MemberJSON.nickname
				province 			:		MemberJSON.province
				registerTime 	:		MemberJSON.register_time
				sex 					:		MemberJSON.sex
				signature 		:		MemberJSON.signature
				id 						:		MemberJSON.user
				EXP 					: 	MemberJSON.membership.EXP
				balance 			:		MemberJSON.membership.balance
				like 					:		MemberJSON.like
				address 			: 		MemberJSON.address
			}
			user.needPhoneOfEveryone = getDinnerInfoJSON().need_phone_of_everyone

		@getLoginInfoFromLocStor : _getLoginInfoFromLocStor

		@getCorresIndexFromLadder: _getCorresIndexFromLadder
