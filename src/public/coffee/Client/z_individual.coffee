	Individual = do ->
		_rechargeFuncDom 	= getById "Recharge-func"
		_couponFucDom 		= getById "Coupon-func"
		addListener _rechargeFuncDom, "click", -> hashRoute.hashJump("-Extra-extraContent-Recharge")
		addListener _couponFucDom, "click", ->
			locStor.set "couponState", "display"
			hashRoute.hashJump("-Extra-extraContent-Coupon")
		


		###
		_confirmRechargebtn = getById "recharge-confirm-column"
		addListener _confirmRechargebtn, "click", -> hashRoute.pushHashStr("choosePaymentMethod")
		###