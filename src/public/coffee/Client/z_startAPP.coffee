	startAPP = do ->
		_totalTime = 3
		_ = 0

		_initCallback = {
			"Need to rescan qrcode" 	:	->	window.location.pathname = "/Table/Confirm/rescan"
			"success" 					:	(result)->
				_initAllGetJSONFunc result.data
				_initAllModule()
				_checkCurrentHash()
		}

		_initAllGetJSONFunc = (data)->
			try
				getDishJSON 				= -> return data.dish
				getActivityJSON 		= -> return data.activity
				getMemberJSON 			= -> return data.member
				getComPreJSON 			= -> return data.compatible
				getDinnerJSON 			= -> return data.covers
				getChannelJSON 			= -> return data.channel
				getHeaderLikeJSON 	= -> return data.sum_like
				getDinnerInfoJSON 	= -> return data.dinner
				getCouponJSON 			= -> return data.couponorder
			catch e
				alert "数据解析失败"
				alert JSON.stringify(e)

		_initAllModule = ->
			try
				_++
				RequireManageSingleton.initial()
				_++
				ConfirmManageSingleton.initial()
				_++
				WebSockSingleton.initial()
				_++
				LockManageSingleton.initial()
				_++
				LocStorSingleton.initial()
				_++
				DinnerHeader.initial()
				_++
				User.initial()
				_++
				CouponManageSingleton.initial()
				_++
				Recharge.initial()
				_++
				Activity.initial()
				_++
				Category.initial()
				_++
				Food.initial()
				_++
				ComboManageSingleton.initial()
				_++
				ComboChooseDeleteManageSingleton.initial()
				_++
				FoodInfoSingleton.initial()
				_++
				BookChooseSingleton.initial()
				_++
				BookOrderSingleton.initial()
				_++
				AlreadyManageSingleton.initial()
				_++
				PaySingleton.initial()
				_++
			catch e
				alert "模块加载失败: #{_}"
				alert e

		_checkCurrentHash = ->
			hash_ = location.hash.replace("#", "")
			if hash_ is "" then setTimeout(->
				hashRoute.hashJump("-Home")
				setTimeout(->
					hashRoute.pushHashStr("Menu")
					setTimeout(->
						hashRoute.pushHashStr("x")
					, 100)
				, 100)
			, 100)
			else if hash_ is "Order"
				setTimeout(->
					bookOrder.confirmPay()
					hashRoute.hashJump("-Home")
					setTimeout(->
						hashRoute.pushHashStr("Already")
						setTimeout(->
							hashRoute.pushHashStr("x")
						, 100)
					, 100)
				, 100)
			else if hash_ is "Recharge" then setTimeout(->
				hashRoute.hashJump("-Home")
				setTimeout(->
					hashRoute.pushHashStr("Individual")
					setTimeout(->
						hashRoute.pushHashStr("x")
					, 100)
				, 100)
			, 100)
			else hashRoute.parseAndExecuteHash()

		_mainInit = (result)->
			_initCallback[result.message]?(result)

		_testIsDataReady = ->
			if window.allData then _mainInit JSON.parse window.allData; window.allData = null;
			else window.mainInit = _mainInit

		initial: ->
			_testIsDataReady()
			