	class Recharge
		_amountValue = [50, 150, 450, 750, 950]
		_rechargeUlDom = query "#Recharge-page .amount-list"
		_rechargeNum = 0
		_ladder = []
		_recharges = []

		_getRechargeDom = (recharge)->
			dom = createDom "li"; dom.id = "amount-#{recharge.seqNum}"
			dom.innerHTML = "<div class='amount-li-field'>
								<div class='basic-info-field vertical-center'>
									<p class='money price'>#{recharge.amountValue}</p>
									<p class='get-higher-rank'></p>
								</div>
								<div class='choose-field'></div>
							</div>"
			if _rechargeNum isnt 0
				line = createDom "div"; line.className = "fivePercentLeftLine"
				append _rechargeUlDom, line
			append _rechargeUlDom, dom
			_rechargeNum++
			dom

		_rechargeBtnClickEvent = (recharge)->
			->
				locStor.set("currentPay", "recharge")
				locStor.set("rechargePrice", recharge.amountValue)
				hashRoute.hashJump "-Detail-Book-choosePaymentMethod"

		constructor: (options)->
			deepCopy options, @
			@init()
			_recharges.push @

		init: ->
			@initRechargeDom()
			@initRechargeEvent()

		initRechargeDom: ->
			@rechargeDom = _getRechargeDom @
			@higherDom = query "p.get-higher-rank", @rechargeDom

		initRechargeEvent: ->
			self = @
			addListener self.rechargeDom, "click", _rechargeBtnClickEvent @

		updateHigherInfo: ->
			result = User.getCorresIndexFromLadder(user.EXP + (@amountValue)*10)
			higherStr = ""; index = result.index
			if index > user.currentRank then higherStr = "充值后可升级为 Lv.#{index} #{_ladder[index].name}级会员"
			@higherDom.innerHTML = higherStr


		@initial: ->
			ladder = User.getLadder()
			deepCopy ladder, _ladder
			for amount, i in _amountValue
				recharge = new Recharge {
					seqNum 			:		i
					amountValue 	:		amount
				}
			Recharge.updateAllRechargeHigherInfo()

		@updateAllRechargeHigherInfo: -> recharge.updateHigherInfo() for recharge in _recharges