	CouponManageSingleton = do ->

		_instance = null

		_couponPageDom 			= getById "Coupon-page"
		_couponLackDom 			= query "#Coupon-lack", _couponPageDom
		_couponRegularDom 	= query "#Coupon-regular", _couponPageDom

		_couponDisplayDom 	= query "ul.Coupon-display-list", _couponRegularDom
		_couponUseDom 			= query "ul.Coupon-use-list", _couponRegularDom

		_confirmDom 				= query ".confirm-btn", _couponRegularDom

		_allCoupons 				= {}
		_currentCouponId 			= null

		class Coupon extends Base

			_getCouponDom = (coupon)->
				dom = createDom "li"; dom.className = "Coupon"
				dom.innerHTML = "<div class='basic-info'>
													<div class='left-part'>
														<div class='reduce-cost-field'>
															<p class='reduce-cost font-number-word'>#{coupon.costReduce}</p>
														</div>
														<div class='cost-field'>
															<p class='cost'>
																<span>满 </span>
																<span class='price font-number-word'>#{coupon.cost}</span>
																<span> 可用</span>
															</p>
														</div>
													</div>
													<div class='right-part'>
														<div class='name-field'>
															<p class='name'>微信代金券</p>
														</div>
														<div class='apply-field'>
															<p class='apply'>仅限在本餐厅中使用</p>
														</div>
														<div class='composition-field'>
															<p class='composition'>
																<span>最多可叠加使用 </span>
																<span class='font-number-word'>#{coupon.maxUse}</span>
																	<span> 张</span>
															</p>
														</div>
														<div class='date-field'>
															<p class='date'>
																<span>有效期至 </span>
																<span class='font-number-word'>#{(new Date(coupon.endTime)).Format("yyyy.MM.dd")}</span>
															</p>
														</div>
													</div>
													<div class='clear'></div>
												</div>"
				return dom

			_unchooseAll = ->
				_currentCouponId = null
				for id, coupon of _allCoupons
					coupon.unchooseSelf()

			constructor: (options)->
				super options
				_allCoupons[@id] = @

			init: ->
				@initAllPrepare()
				@initAllDom()
				@initAllEvent()

			initAllPrepare: ->
				@able = null

			initAllDom: ->
				@displayDom = _getCouponDom @; addClass @displayDom, "display"
				append _couponDisplayDom, @displayDom

				@useDom = _getCouponDom @; addClass @useDom, "use"
				append _couponUseDom, @useDom

			initAllEvent: ->
				self = @
				addListener @useDom, "click", ->
					if not self.able then return
					self.clickEvent()

			clickEvent: -> _unchooseAll(); @chooseSelf()

			enableSelf: -> @able = true; removeClass @useDom, "disabled"

			disableSelf: -> @able = false; addClass @useDom, "disabled"

			chooseSelf: ->
				_currentCouponId = @id; addClass @useDom, "choose"

			unchooseSelf: -> removeClass @useDom, "choose"

		class CouponManage

			constructor: (options)->
				@initAllEvent()
				@initAllData()

			initAllEvent: ->
				addListener _confirmDom, "click", ->
					locStor.set "couponId", _currentCouponId;
					hashRoute.back()
					bookOrder.refreshOrder()

			initAllData: ->
				allCoupon = getCouponJSON()				
				for coupon in allCoupon
					new Coupon {
						id 						:				Number coupon.id
						costReduce		: 			Number coupon.cost_reduce
						cost 					:				Number coupon.cost
						createTime 		:				Number coupon.create_time * 1000
						endTime 			: 			Number coupon.end_time * 1000
						daily 				:				Number coupon.daily
						max 					:				Number coupon.max
						maxUse 				:				Number coupon.max_use
						status 				:				Number coupon.status
					}
				console.log _allCoupons

			judgeState: ->
				state = locStor.get "couponState"
				_couponRegularDom.className = state
				if state is "display" then return
				totalPrice = Number(locStor.get "bookOrderAllPrice" || "0")
				@judgeAllCouponsAble totalPrice
				if @getAvailableCouponLength(totalPrice) is 0 then hashRoute.warn(); return
				@chooseTheBestCoupon totalPrice


			getAvailableCouponLength: (totalPrice)->
				len = 0
				for id, coupon of _allCoupons
					if coupon.cost <= totalPrice then len++
				return len

			getCouponById: (id)-> return _allCoupons[id]

			judgeAllCouponsAble: (totalPrice)->
				for id, coupon of _allCoupons
					if coupon.cost <= totalPrice then coupon.enableSelf()
					else coupon.disableSelf()

			chooseTheBestCoupon: (totalPrice)->
				temp = 0; _id = null
				for id, coupon of _allCoupons
					if coupon.cost <= totalPrice and temp < coupon.costReduce then _id = id; temp = coupon.costReduce
				_allCoupons[_id].clickEvent()


		getInstance: ->
			if _instance is null then _instance = new CouponManage()
			return _instance

		initial: -> couponManage = CouponManageSingleton.getInstance()




