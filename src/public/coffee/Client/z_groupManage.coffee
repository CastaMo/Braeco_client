	GroupManageSingleton = do ->

		_instance = null
		_allGroups = {}

		class Group extends Base
			constructor: (options)->
				super options
				_allGroups[@id] = @


		class GroupManage

			constructor: (options)->
				@initAllData()

			initAllData: ->
				allGroup = getGroupJSON()				
				for group in allGroup
					new Group {
						content 		: 		group.content
						type 				: 		group.type
						belongTo 		: 		group.belong_to
						id 					: 		group.id
						name 				: 		group.name
						remark 			: 		group.remark
						price 			: 		group.price 		|| 0
						discount 		: 		group.discount 	|| 0
					}
				console.log _allGroups

			getGroupById: (id)-> return _allGroups[id]

		getInstance: ->
			if _instance is null then _instance = new GroupManage()
			return _instance

		initial: -> groupManage = GroupManageSingleton.getInstance()



