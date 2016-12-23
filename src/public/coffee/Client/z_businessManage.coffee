	BusinessManageSingle = do ->
		_instance = null

		class BusinessManage

			HALF_AN_HOUR_TIMESTAMP  = 1000 * 60 * 30

			ONE_QUARTER_TIMESTAMP   = 1000 * 60 * 15

			ONE_MINUTE_TIMESTAMP	= 1000 * 60

			TYPE_INFO = {
				"eatin"     :   "堂食"
				"takeout"   :   "外带"
				"takeaway"  :   "外卖"
				"reserve"   :   "预定"
			}

			constructor: (options)->
				@assign(options)
				@init()

			assign: (options)->
				@type				   = options.type
				@serverInitTimeStamp	= options.timestamp
				@clientInitTimeStamp	= now()
				@$el					= query options.elCSSSelector
				@$addressEl			 = query options.addrPopupCSSSelector
				@$dateEl				= query options.datePopupCSSSelector


			init: ->
				console.log user
				@initPrepare()
				if @type is "eatin" or @type is "takeout" then return
				@initDomByType()
				@initAllEvent()
				@checkCurrentTimeToAdapt()
				@sexChoose(0)
				@optionAddress = locStor.get("orderAddress") || "请填写您的地址"
				@optionSex = locStor.get("orderSex")
				@optionName = locStor.get("orderName")
				if user
					@optionSex = @optionSex || user.sex
					@optionName = @optionName || user.nickName
				@optionName = @optionName || "请填写您的姓名"
				if @optionName is "请填写您的姓名" then @optionSex = -1
				else @optionSex = @optionSex || 0
				@_setAddress()

			initPrepare: ->
				@validFlag = 0

			initDomByType: ->
				addressTitleStr = "配送地址 (必填)"
				timeTitleStr = "出餐时间"
				@$el.innerHTML = "<div class='addtional-wrapper'>
										<div class='address-field'>
											<div class='title-field'>
												<b>#{addressTitleStr}</b>
											</div>
											<div class='content-field'>
												<p>请填写您的姓名</p>
												<p>请填写您的地址</p>
											</div>
											<div class='arrow'></div>
										</div>
										<div class='fivePercentLeftLine'></div>
										<div class='time-field'>
											<div class='left-part'>
												<b>#{timeTitleStr}</b>
											</div>
											<div class='right-part'>
												<p></p>
											</div>
											<div class='arrow'></div>
											<div class='clear'></div>
										</div>
									</div>"
				@addressDom		 = query ".address-field"	, @$el
				@timeDom			= query ".time-field"	   , @$el
				@addressContentDom  = query ".content-field"	, @addressDom
				@timeContentDom	 = query ".right-part p"	 , @timeDom
				@inputNameDom	   = query "input#input-name"  , @$addressEl
				@inputAddressDom	= query "textarea"		  , @$addressEl

			initAllEvent: ->
				self = @
				addListener @addressDom, "click", ->
					if not user.isLogin() then return alert "请先登录\n在【主页面】->【我】中进行操作"
					allFinalPrice = locStor.get("bookOrderAllPrice")
					location.href = "/Table/Location?orderPrice=#{allFinalPrice}"
				fastClick @timeDom, -> hashRoute.pushHashStr "Popup-Form-chooseDate"

				fastClick (query ".close-btn-image" , @$dateEl), -> hashRoute.back()
				fastClick (query ".day-choose-field", @$dateEl), (target)->
					target = findParent target, (ele)-> hasClass ele, "day-choose"
					if not target then return false
					index = target.id.replace("day-choose-", "")
					self.dateChoose(Number(index))
				fastClick (query ".time-choose-container", @$dateEl), (target)->
					target = findParent target, (ele)-> hasClass ele, "time-choose"
					indexArray = target.id.replace("time-choose-", "").split("-")
					self.timeChoose Number(indexArray[0]), Number(indexArray[1])
				fastClick (query ".confirm-field", @$dateEl), ->
					self._setTime()
					hashRoute.back()

				fastClick (query ".close-btn-image" , @$addressEl), -> hashRoute.back()
				fastClick (query ".right-part", @$addressEl), (target)->
					target = findParent target, (ele)-> hasClass ele, "sex-select"
					if not target then return false
					index = target.id.replace("sex-select-", "")
					self.sexChoose(Number(index))
				fastClick (query ".confirm-field", @$addressEl), ->

					self.optionName	 = filteTheStr self.inputNameDom.value
					self.optionAddress  = filteTheStr self.inputAddressDom.value
					if not self.optionName	  then alert "请填写姓名"; return false
					if not self.optionAddress   then alert "请填写地址"; return false
					self._setAddress()
					hashRoute.back()

			checkCurrentTimeToAdapt: ->

				nowTimestamp = @_getNowServerTimestamp()
				startTimeStamp = @_getStartTimestamp nowTimestamp
				@arrayForTimestamp = arrayForTimestamp = @_getArrayForTimestamp startTimeStamp, HALF_AN_HOUR_TIMESTAMP, 12
				@_initDateEl arrayForTimestamp
				arrayForTimestamp.forEach((elem)-> console.log elem)
				@dateChoose 0
				@timeChoose 0, 0
				@_setTime()

			timeChoose: (dateIndex, timeIndex)->
				for dom in querys "li.time-choose", @$dateEl
					removeClass dom, "choose"
				addClass (query "li#time-choose-#{dateIndex}-#{timeIndex}", @$dateEl), "choose"
				@optionTime = [dateIndex, timeIndex]

			dateChoose: (dateIndex)->
				for dom in querys "div.day-choose", @$dateEl
					removeClass dom, "choose"
				addClass (query "div#day-choose-#{dateIndex}", @$dateEl), "choose"
				for dom in querys "ul.time-choose-list", @$dateEl
					addClass dom, "hide"
				removeClass (query "ul#time-choose-list-#{dateIndex}", @$dateEl), "hide"

			sexChoose: (index)->
				addClass		(query "div#sex-select-#{index}"	, @$addressEl), "choose"
				removeClass	 (query "div#sex-select-#{1^index}"  , @$addressEl), "choose"
				@optionSex = index

			getIsValid: ->
				if @type is "eatin" or @type is "takeout" then return true
				if @validFlag is 3 then return true
				alert "请先填写#{TYPE_INFO[@type]}信息"
				return false

			_setAddress: ->
				if not user.isLogin() then return false
				nameStr = ""
				addressStr = "<p>请选择配送地址</p>"
				if user.sex = 0 then sexStr = " 先生"
				else sexStr = " 女士"
				if user.nickName
					nameStr = "<p>#{user.nickName}#{sexStr}</p>"
				if user.address
					addressStr = "<p>#{user.address.address} #{user.address.detail || ""}</p>"
					@validFlag = @validFlag | 2
				@addressContentDom.innerHTML = "#{nameStr}#{addressStr}"

			_setTime: ->
				dateIndex = @optionTime[0]
				timeIndex = @optionTime[1]
				@timestamp = @arrayForTimestamp[dateIndex].data[timeIndex]
				immediateStr = ""
				timestampStr = new Date(@timestamp).Format("hh:mm")
				if Number(dateIndex) is 0 and Number(timeIndex) is 0 then immediateStr = "立即出餐"
				if immediateStr then timeStr = "#{immediateStr} (约#{timestampStr}送出)"
				else timeStr = "约#{timestampStr}送出"
				@timeContentDom.innerHTML = timeStr
				locStor.set "orderTimestamp", @timestamp
				@validFlag = @validFlag | 1

			_getNowServerTimestamp: ->
				return +new Date() - @clientInitTimeStamp + @serverInitTimeStamp

			_getStartTimestamp: (timestamp)->
				currentDate = new Date timestamp
				minute = currentDate.getMinutes()
				startOffset = HALF_AN_HOUR_TIMESTAMP
				if minute > 0 then startOffset += ONE_QUARTER_TIMESTAMP * (Math.floor(minute / 15) + 1)
				startTimeStamp = timestamp - minute * ONE_MINUTE_TIMESTAMP + startOffset
				return startTimeStamp

			_getArrayForTimestamp: (startTimestamp, offset, count)->
				result = []
				dayMap = {}
				for i in [0..count-1]
					offsetTimestamp = offset * i + startTimestamp
					day = new Date(offsetTimestamp).getDay()
					if not dayMap[day]
						dayMap[day] = {day:day, data:[]}
						result.push(dayMap[day])
					dayMap[day].data.push offsetTimestamp
				return result

			_initDateEl: (arrayForTimestamp)->
				dayChooseContainerDom   = query ".day-choose-field", @$dateEl
				timeChooseContainerDom  = query ".time-choose-container", @$dateEl
				dayChooseContainerDom.innerHTML	 = ""
				timeChooseContainerDom.innerHTML	= ""
				for date, i in arrayForTimestamp
					dayStr = numToChinese[date.day]
					if date.day is 0 then dayStr = "日"
					if i is 0 then prefix = "今天"
					else prefix = "明天"
					dayChooseDom = createDom "div"
					dayChooseDom.className = "day-choose"
					dayChooseDom.id = "day-choose-#{i}"
					dayChooseDom.innerHTML = "<p>#{prefix} (周#{dayStr})</p>"
					append dayChooseContainerDom, dayChooseDom

					timeChooseListDom = createDom "ul"
					timeChooseListDom.className = "time-choose-list hide"
					timeChooseListDom.id = "time-choose-list-#{i}"
					append timeChooseContainerDom, timeChooseListDom

					for timestamp, j in date.data
						timeChooseDom = createDom "li"
						timeChooseDom.className = "time-choose"
						timeChooseDom.id		= "time-choose-#{i}-#{j}"
						timeChooseDom.innerHTML = "<p>#{new Date(timestamp).Format("hh:mm")}</p>
													<div class='tick'></div>
													<div class='clear'></div>"
						append timeChooseListDom, timeChooseDom


		getInstance: ->
			if not _instance
				data = getBusinessJSON()
				_instance = new BusinessManage {
					timestamp			   :   data.timestamp
					type					:   data.type
					elCSSSelector		   :   "#book-order-wrap .addtional"
					addrPopupCSSSelector	:   "#choose-address-page"
					datePopupCSSSelector	:   "#choose-date-page"
				}
			return _instance

		initial: ->
			businessManage = @getInstance()
