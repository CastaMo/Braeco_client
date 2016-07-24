	WebSockSingleton = do ->
		_instance = null
		class WebSock
			_lastRec = 0
			_ws = null
			_waitList = {}
			_configForWS = {
				"onmessage": (e)->
					_lastRec = (new Date()).getTime()
					option = JSON.parse(e.data)
					if option.type is "ping"
						response = {"type": "ping"}
						_ws.send JSON.stringify(response)
					else if option.type is "notify"
						message = option.msg
						if message.content is "Order printed"
							responseObj = {"content": "Order printed notified", "orderid": message.orderid}
							response = {"type": "feedback", "msg": responseObj}
							_ws.send JSON.stringify(response)
							setTimeout (-> alert "服务员已接单, 请您耐心等候, 不要更换桌位"), 2000
					else if option.type is "error"
						message = option.msg
						if message is "Someone login your account" then _lastRec = 0
				"onopen": -> _lastRec = (new Date()).getTime(); _signalAllTheRequest(); console.log "连接成功"
			}

			_resetWS = ->
				if _ws then _ws.close()
				if location.hostname is "localhost" or location.hostname is "devel.brae.co" then return
				_ws = new ReconnectingWebSocket("ws://#{location.hostname}:8587")
				deepCopy _configForWS, _ws

			_checkIsLostConnectAndSignal = ->
				current = new Date()
				if _lastRec + 15*1000 <= current.getTime() then _resetWS()
				else _signalAllTheRequest()

			###
			*
			* Add the funciton to the wait list of the WebSocket, and identify the process as id
			* @param {Process, Number}
			*
			###
			_waitForWebSocketRequest = (proc, id)-> _waitList[id] = proc

			_signalAllTheRequest = ->
				for id, proc of _waitList
					proc?(); delete _waitList[id]

			_sendMessageProc = (proc)->
				_waitForWebSocketRequest(proc, (new Date()).getTime())
				setTimeout(_checkIsLostConnectAndSignal, 0)

			sendTouchFeedBack: (hash)->
				msg = JSON.stringify({"type": "touch", "msg": hash})
				_sendMessageProc do (msg)-> -> _ws.send msg

			sendCallWaiter: (content)->
				msg = JSON.stringify({"type": "service", "msg": "#{content}" || ""})
				_sendMessageProc do (msg)-> -> _ws.send msg

			constructor: ->
				_resetWS()

			check: ->
				_checkIsLostConnectAndSignal()

			reconnect: ->
				_resetWS()


		getInstance: ->
			if _instance is null then _instance = new WebSock()
			return _instance

		initial: -> webSock = WebSockSingleton.getInstance()