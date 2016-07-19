	Individual = do ->
		_rechargeFuncDom 	= getById "Recharge-func"
		_couponFucDom 		= getById "Coupon-func"
		fastClick _rechargeFuncDom, -> hashRoute.hashJump("-Extra-extraContent-Recharge")
		fastClick _couponFucDom, ->
			locStor.set "couponState", "display"
			hashRoute.hashJump("-Extra-extraContent-Coupon")
		


		###
		_confirmRechargebtn = getById "recharge-confirm-column"
		addListener _confirmRechargebtn, "click", -> hashRoute.pushHashStr("choosePaymentMethod")
		###