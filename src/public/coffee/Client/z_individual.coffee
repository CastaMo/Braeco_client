	Individual = do ->
		_rechargeFuncDom = getById "Recharge-func"
		addListener _rechargeFuncDom, "click", -> hashRoute.hashJump("-Extra-extraContent-Recharge")


		###
		_confirmRechargebtn = getById "recharge-confirm-column"
		addListener _confirmRechargebtn, "click", -> hashRoute.pushHashStr("choosePaymentMethod")
		###