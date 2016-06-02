	LockManageSingleton = do ->
		_instance = null

		class LockManage

			_locks = {}
			_allLockName = ['login', 'bookOrder', 'recharge', 'getId', 'like', 'bookClick', 'callWaiter']

			class lockBase
				constructor: (options)->
					deepCopy options, @
					_locks[@name] = @

				getLock: ->
					if @resource > 0 then @resource--; return true
					return false

				releaseLock: -> @resource++

			class Lock extends lockBase
				constructor: (options)->
					super options

			constructor: ->
				for lockName in _allLockName
					lock = new Lock {
						resource 	:	1
						name 		:	lockName
					}

			get: (name)-> return _locks[name]


		getInstance: ->
			if _instance is null then _instance = new LockManage()
			return _instance

		initial: ->
			lockManage = LockManageSingleton.getInstance()