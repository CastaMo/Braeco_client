	startAPP = do ->
		_totalTime = 3
		_ = 0

		_initCallbackForIntegrateData = (integrateData)->
			_initAllGetJSONFuncByIntegrateData integrateData.data
			_initAllModule()
			_checkCurrentHash()

		_initAllGetJSONFuncByIntegrateData = (data)->
			try
				getGroupJSON 				= -> return data.menu.groups
				getDishLimitJSON 			= -> return data.dish_limit
				getDishJSON		 			= -> return data.menu.categories
				getDinnerJSON 				= -> return data.covers
				getChannelJSON 				= -> return data.channel
				getDinnerInfoJSON 			= -> return {
					id 						: 		data.dinner.id
					name					: 		data.dinner.name
					need_phone_of_everyone 	: 		data.need_phone_of_everyone
				}
				getCouponJSON 				= -> return data.couponorder
				getDcToolJSON 				= -> return data.dc_tool
				getActivityJSON 			= -> return data.activity
				getMemberJSON 				= -> return {
					avatar 				: 		data.member_info.avatar
					mobile 				: 		data.member_info.mobile
					nickname 			: 		data.member_info.nickname
					user 				: 		data.member_info.user
					membership 			: 		{
						EXP 		: 		data.member_info.EXP
						balance 	: 		data.member_info.balance
						ladder 		:		data.membership_rule.ladder
					}
				}
				getComPreJSON 				= -> return 8
				getHeaderLikeJSON 			= -> return 0
				getRechargeJSON 			= -> return data.membership_rule
			catch e
				alert "数据解析失败"
				alert JSON.stringify(e)


		_initAllModule = ->
			# try
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
				DishLimitManageSingleton.initial()
				_++
				GroupManageSingleton.initial()
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
			# catch e
			# 	alert "模块加载失败: #{_}"
			# 	alert e

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

		initial: (integrateData)->
			_initCallbackForIntegrateData(integrateData)
