	PaySingleton = do ->

		_instance = null

		class Pay

			_choosePaymentDom = getById "Choose-payment-method-page"
			_currentPay = ""

			_viaMemberDom = getById "choose-payment-via-member-column"
			_viaMemberChooseDom = query "#choose-member", _viaMemberDom
			_viaMemberChooseRemainderDom = query "p.remainder-number", _viaMemberChooseDom

			_viaMemberRechargeDom = query "#recharge-btn", _viaMemberDom
			_viaMemberRechargeRemainderDom = query "p.remainder-number", _viaMemberRechargeDom

			_headerDom = getById "payment-total-column"
			_headPriceDom = query ".payment-total-wrapper p.total-price", _choosePaymentDom
			_headerDom.style.width = "#{clientWidth}px"

			_viaOnlineDom = getById "choose-payment-via-online-column"
			_viaOnlineUlDom = query "ul.via-online-list", _choosePaymentDom			

			_viaCashDom = getById "choose-payment-via-cash-column"
			_viaCashWarnDom = getById "remind-via-cash-column"

			_confirmPayBtnDom = query ".confirm-field", _choosePaymentDom

			_totalPrice = 0
			_initTotalPrice = 0
			_moneyPaid = ""

			_payMethods = {}
			_allMethods = []

			_allPayUse = ["bookOrder", "recharge"]
			_allPayMethodNum = 0

			_payDiscountAbleForPayUse =  {
				"bookOrder" 	: 	true
				"recharge" 		:	false
			}

			_allPayUseMapPriceName = {
				"bookOrder" 	: 	"bookOrderAllPrice"
				"recharge" 		: 	"rechargePrice"
			}

			_getBookInfoFromLocStor = ->
				allBookOrder = JSON.parse(locStor.get("allBookOrder"))
				arrForBook = []
				for elem in allBookOrder
					food = Food.getFoodById elem.id
					isOverlap = user.getIsOverlap()
					target = {}
					target.id = food.id
					if food.dcType is "half" then isHalfStr = "H"
					else isHalfStr = ""
					target.s = elem.num
					if food.isCombo
						_t = []
						for subItem, i in elem.comboOptions
							_t.push []
							for subItemFood, j in subItem
								for temp in [0..subItemFood.num - 1]
									_s = {}
									_s.id = subItemFood.id
									if subItemFood.chooseInfo is "" then _s.p = []
									else _s.p = subItemFood.chooseInfo.split " 、 "
									_t[i].push _s
						target.p = _t
					else
						if elem.chooseInfo is "" then target.p = []
						else target.p = elem.chooseInfo.split " 、 "
					finalPrice = food.getAfterDiscountPrice elem.afterChoosePrice
					if not food.dcType or food.dcType is "none" or isOverlap[food.dcType] or food.dcType is "half"
						finalPrice *= (user.discount / 100)
					target.m = "#{isHalfStr}#{Number(finalPrice.toFixed(2))}"
					arrForBook.push target
				JSON.stringify arrForBook

			_getBookAllPriceFromLocStor = ->
				temp = Number(locStor.get("bookOrderAllPrice"))
				_initTotalPrice = temp
				_couponSave = 0
				couponId = Number locStor.get "couponId" || "0"
				if couponId > 0
					coupon = couponManage.getCouponById couponId
					_couponSave = coupon.costReduce
				temp -= _couponSave
				if temp < 0 then temp = 0
				_totalPrice = temp
				_headPriceDom.innerHTML = Number(temp.toFixed(2))

			_getRechargePriceFromLocStor = ->
				_initTotalPrice = _totalPrice = Number(locStor.get("rechargePrice"))
				_headPriceDom.innerHTML = Number(_totalPrice.toFixed(2))

			_checkCurerntPayAndJudegeShow = ->
				addClass _viaMemberDom, "hide"; addClass _viaCashDom, "hide"
				if user.isLogin() and _currentPay isnt "recharge" then removeClass _viaMemberDom, "hide"; removeClass _viaCashDom, "hide"

			_checkUserDiscountAndJudgeShow = ->
				_viaMemberChooseRemainderDom.innerHTML = _viaMemberRechargeRemainderDom.innerHTML = Number(user.balance.toFixed(2))
				addClass _viaMemberChooseDom, "hide"; addClass _viaMemberRechargeDom, "hide"
				if user.balance >= _totalPrice then removeClass _viaMemberChooseDom, "hide"
				else removeClass _viaMemberRechargeDom, "hide"

			_checkUserRemainder = ->
				_checkCurerntPayAndJudegeShow()
				_checkUserDiscountAndJudgeShow()


			_readyForBookOrder = ->
				_getBookAllPriceFromLocStor()
				_getBookInfoFromLocStor()
				aliPayF2F = _payMethods["alipay_qr_f2f"]
				if aliPayF2F then removeClass aliPayF2F.methodDom, "hide"
				addClass _viaCashWarnDom, "hide"

			_readyForRecharge = ->
				_getRechargePriceFromLocStor()
				aliPayF2F = _payMethods["alipay_qr_f2f"]
				if aliPayF2F then addClass aliPayF2F.methodDom, "hide"
				removeClass _viaCashWarnDom, "hide"

			_rechargeBtnClickEvent = ->
				setTimeout(->
						hashRoute.back()
						setTimeout(->
							hashRoute.hashJump("-Extra-extraContent-Recharge")
						, 100)
					, 0)

			_asyncBackForCount = (count, delay, callback)->
				if count is 0 then setTimeout(callback, delay)
				else setTimeout((-> hashRoute.back(); _asyncBackForCount --count, delay, callback), delay)

			_rechargeCallBack = (func)-> _asyncBackForCount 2, 200, func
				

			_bookOrderCallBack = (func)-> _asyncBackForCount 4, 200, func


			_getPayContents = (_currentPay)->
				if _currentPay is "recharge" then return _totalPrice
				else if _currentPay is "bookOrder" then return _getBookInfoFromLocStor()

			_confirmPaySuccessCallBack = (_currentPay, _moneyPaid)->
				if _currentPay is "recharge"
					_rechargeCallBack ->
						recharge = Recharge.getRecharge (locStor.get("rechargeIndex") || 0)
						user.rechargeRemainder recharge.get, recharge.EXP

				else if _currentPay is "bookOrder"
					_bookOrderCallBack ->
						locStor.set("deleteCouponId", locStor.get("couponId"))
						currentOrderId = Math.abs(Math.floor(locStor.get("orderId"))) || 0
						console.log currentOrderId
						hashRoute.hashJump "-Home-Already"
						bookOrder.confirmPay()
						couponManage.useCouponFromLocStor()

						EXPRate = Recharge.getEXPRateByType(_moneyPaid)

						if _moneyPaid is "prepayment" then user.consumeByBalance _totalPrice
						else user.getEXPByPay(Math.floor(_totalPrice * EXPRate))
						requireManage.get("couponAdd").require(currentOrderId, (result)->
							location.href = "/coupon/add/afterpay/#{result.couponid}"
						)


			_confirmPayBtnClickEvent = ->

				_commonCallback = ->
					_disableConfirmBtn()
					requireManage.get(_currentPay).require(_getPayContents(_currentPay), _moneyPaid, do (_currentPay, _moneyPaid)->
						->
							locStor.set "#{_allPayUseMapPriceName[_currentPay]}", _totalPrice
							_confirmPaySuccessCallBack _currentPay, _moneyPaid
					, ->
						lockManage.get(_currentPay).releaseLock()
						_enabledConfirmBtn()
					, locStor.get("memo"), locStor.get("couponId") || "0")

				if not _moneyPaid then alert("请先选择支付方式"); return
				if _moneyPaid not in _allMethods then alert("非法选择"); return
				if _currentPay not in _allPayUse then alert("非法操作"); return
				if not lockManage.get(_currentPay).getLock() then return

				content = ""
				if _moneyPaid is "alipay_qr_f2f" then content = "请扫描订单小票二维码支付(稍后服务员将随餐品一并送上)"
				else if _moneyPaid is "cash" then content = "确认使用现金下单吗?\n(请您备好#{Number(_totalPrice.toFixed(2))}元稍后买单)"
				else if _moneyPaid is "prepayment" then content = "是否使用会员卡余额支付?\n(需支付#{Number(_totalPrice.toFixed(2))}元)"
				
				if not user.needPhoneOfEveryone
					if _moneyPaid is "cash" and not user.mobile then lockManage.get(_currentPay).releaseLock(); locStor.set("loginFlag", 1); hashRoute.pushHashStr("Popup-Form-Login"); return
					else if _currentPay is "recharge" and not user.mobile then lockManage.get(_currentPay).releaseLock(); locStor.set("loginFlag", 2); hashRoute.pushHashStr("Popup-Form-Login"); return
				else if user.needPhoneOfEveryone
					if not user.mobile then lockManage.get(_currentPay).releaseLock(); locStor.set("loginFlag", 0); hashRoute.pushHashStr("Popup-Form-Login"); return
				if content
					confirmManage.simulateConfirm {
						title 			:		"确认支付"
						content 		:		content
						confirmContent 	:		"支付"
						success 		:		_commonCallback
						cancel 			:		lockManage.get(_currentPay).releaseLock()
					}
				else _commonCallback()

			_getNameAndLogoClassByMethod = (method)->
				if method is "wx_pub" or method is "p2p_wx_pub"
					return {name: "微信支付", logoClass: "weixinLogo"}
				else if method is "alipay_wap" or method is "alipay_qr_f2f"
					return {name: "支付宝支付", logoClass: "aliPayLogo"}
				else if method is "bfb_wap"
					return {name: "百度钱包", logoClass: "baiduLogo"}
				else return {name: "default", logoClass: "default"}

			_getMethodDom = (payMethod)->
				if payMethod.method is "cash"
					methodDom = createDom "div"; methodDom.className = "via-cash-title-field via-title-field"
					methodDom.innerHTML = "<div>
											<div class='title-wrapper'>
												<div class='title-field'>
													<p class='title'>使用现金或其他方式支付</p>
												</div>
												<div class='choose-field'></div>
												<div class='clear'></div>
											</div>
										</div>"
					append _viaCashDom, methodDom
					return methodDom
				else
					if _allPayMethodNum > 0
						lineDom = createDom "div"; lineDom.className = "fivePercentLeftLine"
						append _viaOnlineUlDom, lineDom
					nameAndLogo = _getNameAndLogoClassByMethod payMethod.method
					methodDom = createDom "li"; methodDom.id = payMethod.method; methodDom.className = "via-online"
					recommond = "推荐使用"; if payMethod.method is "alipay_qr_f2f" then recommond = "将在小票附上二维码"
					recommondClassName = "recommond"
					methodDom.innerHTML = "<div class='via-online-wrapper li-wrapper'>
												<div class='img-field'>
													<div class='img #{nameAndLogo.logoClass}'></div>
												</div>
												<div class='online-info-field info-field'>
													<div class='name-field up-field'>
														<p class='word'>#{nameAndLogo.name}</p>
													</div>
													<div class='recommend-field down-field'>
														<p class=#{recommondClassName}>#{recommond}</p>
													</div>
												</div>
												<div class='choose-field'></div>
											</div>"
					append _viaOnlineUlDom, methodDom
					_allPayMethodNum++
					return methodDom

			_checkViaOnlineMethod = ->
				if _allPayMethodNum is 0
					warnDom = createDom "div"; warnDom.className = "via-online-none-warn"
					warnDom.innerHTML = "<p class='warn'>本餐厅暂不支持在线支付</p>"
					append _viaOnlineDom, warnDom


			_disableConfirmBtn = ->
				addClass _confirmPayBtnDom, "disabled"

			_enabledConfirmBtn = ->
				removeClass _confirmPayBtnDom, "disabled"


			class PayMethod

				_unchooseAllMethod = -> removeClass payMethod.methodDom, "choose" for key, payMethod of _payMethods

				_payMethodChooseEvent = (payMethod)-> ->
					_moneyPaid = payMethod.method
					_unchooseAllMethod()
					addClass payMethod.methodDom, "choose"
					if _payDiscountAbleForPayUse[_currentPay]
						discount = payMethod.discount
					else
						discount = 100
					_couponSave = 0
					if _currentPay is "bookOrder"
						couponId = Number locStor.get "couponId" || "0"
						if couponId > 0
							coupon = couponManage.getCouponById couponId
							_couponSave = coupon.costReduce
					_totalPrice = (_initTotalPrice - _couponSave) * discount / 100
					if _totalPrice < 0 then _totalPrice = 0
					_headPriceDom.innerHTML = _getFinalTotalDisplayPriceByDiscount discount, _couponSave


				_getFinalTotalDisplayPriceByDiscount = (discount, _couponSave)->
					totalPrice = Number(((_initTotalPrice - _couponSave) * discount / 100).toFixed(2))
					if totalPrice < 0 then totalPrice = 0
					return totalPrice

				constructor: (options)->
					deepCopy options, @
					@init()
					_payMethods[@method] = @
					_allMethods.push @method

				init: ->
					@initAllPrepare()
					@initAllDom()
					@initAllEvent()

				initAllPrepare: ->
					@defaultInfo = "推荐使用"
					if @method is "alipay_qr_f2f" then @defaultInfo = "将在小票附上二维码"

				initAllDom: ->
					@initMethodDom()
					@initWordDom()

				initMethodDom: ->
					if @methodDom then return
					@methodDom = _getMethodDom @

				initWordDom: -> @wordDom = query ".recommend-field p", @methodDom

				initAllEvent: ->
					self = @
					fastClick self.methodDom, _payMethodChooseEvent @

				getDiscountInfo: ->
					if @discount < 100
						num = @discount; if @discount % 10 is 0 then num = numToChinese[Math.round(@discount / 10)] else num = @discount/10
						return discountInfo = "立享#{num}折优惠"
					else
						return @defaultInfo

				unshowDiscountInfo: ->
					if not @wordDom then return
					@wordDom.className = "recommond"; @wordDom.innerHTML = @defaultInfo

				showDiscountInfo: ->
					if not @wordDom then return
					if @discount < 100
						@wordDom.className = "discount-recommond"; @wordDom.innerHTML = @getDiscountInfo()

				@reset: -> _unchooseAllMethod()

				@toggleDiscountInfoByPayUse: ->
					if _payDiscountAbleForPayUse[_currentPay]
						for key, payMethod of _payMethods
							payMethod.showDiscountInfo()
					else
						for key, payMethod of _payMethods
							payMethod.unshowDiscountInfo()

			selectPayInfoByCurrentChoose: ->
				_moneyPaid = ""
				PayMethod.reset()
				_currentPay = locStor.get "currentPay"
				if _currentPay is "bookOrder" then _readyForBookOrder()
				else if _currentPay is "recharge" then _readyForRecharge()
				else hashRoute.back()
				PayMethod.toggleDiscountInfoByPayUse()
				_checkUserRemainder()


			constructor: ->
				payMethod = new PayMethod {
					methodDom 	:		query "#choose-payment-via-member-column #choose-member"
					method 		:		"prepayment"
					discount 	: 		100
					enable 		:		true
				}
				allMehods = getChannelJSON() || '{}'
				allMehods = getJSON allMehods
				for method, discount of allMehods
					payMethod = new PayMethod {
						method 		:		method
						discount 	:		discount
						enable 		: 	true
					}
				_checkViaOnlineMethod()
				fastClick _viaMemberRechargeDom, _rechargeBtnClickEvent
				fastClick _confirmPayBtnDom, ->
					if hasClass _confirmPayBtnDom, "disabled" then return
					_confirmPayBtnClickEvent()

		getInstance: ->
			if _instance is null then _instance = new Pay()
			return _instance
		initial: ->
			pay = PaySingleton.getInstance()
		