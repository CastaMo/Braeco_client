	class Recharge
		_rechargeUlDom 	= query "#Recharge-page .amount-list"
		_rechargeNum 	= 0
		_ladder 		= []
		_allRecharges 	= []
		_EXPRateMapType = {}

		_getRechargeDom = (recharge)->
			dom = createDom "li"
			dom.innerHTML = "<div class='amount-li-field'>
								<div class='basic-info-field vertical-center'>
									<p>
										<span class='money price'>#{recharge.pay}</span> #{if recharge.get > recharge.pay then "<span class='give'>(立送<span class='money price'>#{recharge.get - recharge.pay} </span>)</span>" else ""}
									</p>
									<p class='get-higher-rank'></p>
								</div>
								<div class='choose-field'></div>
							</div>"
			if _rechargeNum isnt 0
				line = createDom "div"; line.className = "fivePercentLeftLine"
				append _rechargeUlDom, line
			append _rechargeUlDom, dom
			_rechargeNum++
			return dom

		_rechargeBtnClickEvent = (recharge)->
			->
				locStor.set("currentPay", "recharge")
				locStor.set("rechargeIndex", recharge.index)
				locStor.set("rechargePrice", recharge.pay)
				hashRoute.hashJump "-Detail-Book-choosePaymentMethod"

		constructor: (options)->
			deepCopy options, @
			@init()
			_allRecharges.push @

		init: ->
			@initRechargeDom()
			@initRechargeEvent()

		initRechargeDom: ->
			@rechargeDom = _getRechargeDom @
			@higherDom = query "p.get-higher-rank", @rechargeDom

		initRechargeEvent: ->
			self = @
			fastClick self.rechargeDom, _rechargeBtnClickEvent self

		updateHigherInfo: ->
			result = User.getCorresIndexFromLadder(user.EXP + @EXP)
			higherStr = ""; index = result.index
			if index > user.currentRank then higherStr = "充值后可升级为 Lv.#{index} #{_ladder[index].name}级会员"
			@higherDom.innerHTML = higherStr


		@initial: ->
			ladder = User.getLadder()
			deepCopy ladder, _ladder

			_EXPRateMapType = getRechargeJSON().EXPRate
			allRechargeDatas = getRechargeJSON().charge_ladder
			console.log _EXPRateMapType
			for recharge, i in allRechargeDatas
				recharge.index = i
				new Recharge recharge

			Recharge.updateAllRechargeHigherInfo()

		@updateAllRechargeHigherInfo: -> recharge.updateHigherInfo() for recharge in _allRecharges

		@getRecharge: (index)-> return _allRecharges[index]

		@getEXPRateByType: (type)-> return _EXPRateMapType[type] || 5

