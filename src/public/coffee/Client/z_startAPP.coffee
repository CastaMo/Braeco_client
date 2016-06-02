	startAPP = do ->
		_totalTime = 3
		_ = null

		_initCallback = {
			"Need to rescan qrcode" 	:	->	window.location.pathname = "/Table/Confirm/rescan"
			"success" 					:	(result)->
				_initAllGetJSONFunc result.data
				_initAllModule()
				_checkCurrentHash()
		}

		_initAllGetJSONFunc = (data)->
			try
				getDishJSON 		= -> return data.dish
				getActivityJSON 	= -> return data.activity
				getMemberJSON 		= -> return data.member
				getComPreJSON 		= -> return data.compatible
				getDinnerJSON 		= -> return data.covers
				getChannelJSON 		= -> return data.channel
				getHeaderLikeJSON 	= -> return data.sum_like
				getDinnerInfoJSON 	= -> return data.dinner
			catch e
				alert "数据解析失败"
				alert JSON.stringify(e)

		_initAllModule = ->
			try
				_ = 0
				RequireManageSingleton.initial()
				_ = 1
				ConfirmManageSingleton.initial()
				_ = 2
				WebSockSingleton.initial()
				_ = 3
				LockManageSingleton.initial()
				_ = 4
				LocStorSingleton.initial()
				_ = 5
				DinnerHeader.initial()
				_ = 6
				User.initial()
				_ = 7
				Recharge.initial()
				_ = 8
				Activity.initial()
				_ = 9
				Category.initial()
				_ = 10
				Food.initial()
				_ = 11
				ComboManageSingleton.initial()
				_ = 12
				ComboChooseDeleteManageSingleton.initial()
				_ = 13
				FoodInfoSingleton.initial()
				_ = 14
				BookChooseSingleton.initial()
				_ = 15
				BookOrderSingleton.initial()
				_ = 16
				AlreadyManageSingleton.initial()
				_ = 17
				PaySingleton.initial()
				_ = 18
			catch e
				alert "模块加载失败:", _
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
			