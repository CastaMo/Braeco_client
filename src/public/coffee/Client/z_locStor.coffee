	LocStorSingleton = do ->
		_instance = null
		class LocStor
			store = window.localStorage;doc = document.documentElement
			if !store then doc.type.behavior = 'url(#default#userData)'

			set: (key, val, context)->
				if store then store.setItem(key, val, context)
				else doc.setAttribute(key, value); doc.save(context || 'default')
			get: (key, context)->
				if store then store.getItem(key, context)
				else doc.load(context || 'default'); doc.getAttribute(key) || ''
			rm: (key, context)->
				if store then store.removeItem(key, context)
				else context = context || 'default';doc.load(context);doc.removeAttribute(key);doc.save(context)
			clear: ->
				if store then store.clear()
				else doc.expires = -1

		_checkDinnerInfo = ->
			currentDinnerInfo = getDinnerInfoJSON() || "{}"; currentDinnerInfo = getJSON currentDinnerInfo
			dinnerid = Number(currentDinnerInfo["id"])
			if not dinnerid then return
			dinnerName = currentDinnerInfo["name"]
			(query "#Activity-page .business-name").innerHTML = dinnerName
			previousid = locStor.get("dinnerid") || "0"; previousid = getJSON previousid
			if previousid isnt dinnerid then locStor.clear()
			lastEnterTime = locStor.get("lastEnterTime") || "0"; lastEnterTime = getJSON lastEnterTime
			lastEnterDate = new Date lastEnterTime
			currentEnterDate = new Date()
			currentEnterTime = currentEnterDate.getTime()
			if not (lastEnterDate.getYear() is currentEnterDate.getYear() and lastEnterDate.getMonth() is currentEnterDate.getMonth() and lastEnterDate.getDate() is currentEnterDate.getDate()) then locStor.clear()
			if lastEnterTime + 6*60*60*1000 <= currentEnterTime then locStor.clear()
			locStor.set("dinnerid", dinnerid)
			locStor.set("lastEnterTime", currentEnterTime)


		getInstance: ->
			if _instance is null then _instance = new LocStor()
			return _instance

		initial: ->
			locStor = @getInstance()
			_checkDinnerInfo()