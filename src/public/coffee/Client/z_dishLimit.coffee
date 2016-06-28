	DishLimitManageSingleton = do ->

		_instance = null
		_allDishLimits = {}

		class DishLimit extends Base
			constructor: (options)->
				super options
				_allDishLimits[@id] = @


		class DishLimitManage

			constructor: (options)->
				@initAllData()

			initAllData: ->
				allDishLimits = getDishLimitJSON()				
				for id, dc of allDishLimits
					new DishLimit {
						id 		: 		id
						dc 		: 		dc
					}
				console.log _allDishLimits

			getDishLimitById: (id)-> return _allDishLimits[id]

		getInstance: ->
			if _instance is null then _instance = new DishLimitManage()
			return _instance

		initial: -> dishLimitManage = DishLimitManageSingleton.getInstance()


