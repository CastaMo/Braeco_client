	class Activity extends Base
		_allActivityType = ["promotion", "theme"]

		_activityHomeDisplayUlDom = query "#Menu-page .activity-display-list"
		_activityHomeDisplayChooseUlDom = query "#Menu-page .choose-dot-list"

		_activityContainerDom = query "#Activity-page #Activity-container-column .activity-container-wrapper"
		_activityPromotionUlDom = null
		_activityThemeUlDom = null
		_activityTypeNum = {
			"promotion": 0
			"theme": 0
		}

		_getImageBufferFlag = {
			"display": false
			"info": false
		}

		_activities = []
		_activityCurrentChoose = 0
		_reduceList = []
		_giveList = []

		_activityContentDom = query ".Activity-content-field"
		_activityInformationDom = query ".Activity-information-field"
		_activityInfoImgFieldDom = query "#activity-info-img-field .img-field", _activityInformationDom
		_activityInfoImgDom = query ".img", _activityInfoImgFieldDom
		_activityInfoTypeDom = query ".title-type", _activityInformationDom
		_activityInfoTitleNameDom = query "#activity-info-title-field .name", _activityInformationDom
		_activityInfoIntroDom = query "#activity-info-title-field .intro", _activityInformationDom
		_activityInfoTimeDom = query "#activity-info-time-field .time", _activityInformationDom
		_activityInfoContentDom = query "#activity-info-content-field .content", _activityInformationDom

		_activityColumnDom = query ".activity-wrapper"

		infoImgWidth = clientWidth * 0.9; infoImgHeight = infoImgWidth*167/343
		_activityInfoImgFieldDom.style.height = "#{infoImgHeight}px"
		_activityInfoImgDom.style.backgroundSize = "#{infoImgWidth}px #{infoImgHeight}px"

		_getActivityDisplayDom = (activity)->
			imgWidth = clientWidth; imgHeight = clientWidth * 200 / 375
			dom = createDom("li"); dom.id = "activity-#{activity.seqNum}"
			dom.innerHTML = "<div class='activity-img img default-display-image' style='height:#{imgHeight}px;background-size:#{imgWidth}px #{imgHeight}px'></div>
							<div class='activity-name-wrapper'>
								<div class='activity-name-field'>
									<p class='activity-name'>#{activity.title}</p>
								</div>
							</div>"
			append _activityHomeDisplayUlDom, dom
			dom

		_getActivityDisplayChooseDom = (activity)->
			dom = createDom("li"); dom.id = "choose-dot-#{activity.seqNum}"; dom.className = "inactive"
			dom.innerHTML = "<div class='dot'></div>"
			append _activityHomeDisplayChooseUlDom, dom
			dom

		_getActivityDetailInfoDom = (activity)->
			dom = createDom("li"); dom.id = "activity-basic-info-#{activity.seqNum}"; dom.className = "activity-basic-info"
			dom.innerHTML = "<div class='img default-square-image'></div>
							<div class='info'>
								<p class='activity-name'>#{activity.title}</p>
								<p class='activity-intro'>#{activity.intro}</p>
							</div>
							<div class='arrow'></div>"
			if activity.type is "theme" then ulDom = _activityThemeUlDom; type = "theme"
			else ulDom = _activityPromotionUlDom; type = "promotion"
			if _activityTypeNum[type] isnt 0
				lineDom = createDom("div"); lineDom.className = "fivePercentLeftLine"
				append ulDom, lineDom
			_activityTypeNum[type]++
			append ulDom, dom
			dom

		_getActivityTypeContainerDom = (type, title)->
			dom = createDom("div"); dom.id = "activity-#{type}-field"
			dom.innerHTML = "<div class='title-field'>
								<p class='title'>#{title}</p>
							</div>
							<ul class='activity-#{type}-list'></ul>"
			append _activityContainerDom, dom

		_initContainerDomByAllActivity = (activities)->
			allTypeExist = {}
			allTypeExist[type] = false for type in _allActivityType
			for activity in activities
				type = activity.type || ""
				if type is "theme" then allTypeExist[type] = true
				else if type then allTypeExist["promotion"] = true
			for type in _allActivityType
				if allTypeExist[type]
					if type is "promotion" then title = "促销优惠"
					else title = "主题活动"
					_getActivityTypeContainerDom(type, title)

		_initTypeUlDom = -> _activityPromotionUlDom = query ".activity-promotion-list", _activityContainerDom; _activityThemeUlDom = query ".activity-theme-list", _activityContainerDom

		_setCurrentChoose = (seqNum)-> _activityCurrentChoose = seqNum; locStor.set("activityCurrentChoose", seqNum)

		_getCurrentChooseFromLocStor = ->
			choose = locStor.get("activityCurrentChoose") || 0
			if _activities[choose] then _activityCurrentChoose = Number(choose)
			else _activityCurrentChoose = 0

		_selectActivityDisplayByCurrentChoose = ->
			setTimeout(->
				_activityInformationDom.style.height = "#{getAdaptHeight(_activityInformationDom, _activityContentDom)}px"
			, 100)
			corresActivity = _activities[_activityCurrentChoose]
			if corresActivity.type is "theme" then typeName = "主题"
			else typeName = "促销"
			_activityInfoImgDom.style.backgroundImage = "";corresActivity.getImageBuffer "detail"
			_activityInfoTypeDom.innerHTML = typeName
			_activityInfoTitleNameDom.innerHTML = corresActivity.title
			_activityInfoIntroDom.innerHTML = corresActivity.intro
			if Number(corresActivity.dateBegin) is 0 and Number(corresActivity.dateEnd) is 0
				_activityInfoTimeDom.innerHTML = "永久"
			else
				_activityInfoTimeDom.innerHTML = "	#{new Date(corresActivity.dateBegin*1000).Format('yyyy.MM.dd')} - 
													#{new Date(corresActivity.dateEnd*1000).Format('yyyy.MM.dd')}"
			_activityInfoContentDom.innerHTML = corresActivity.content


		constructor: (options)->
			super options
			_activities.push @

		init: ->
			@initActivityHomeDisplayDom()
			@initActivityHomeDisplayChooseDom()
			@initActivityDetailInfoDom()
			@initAllEvent()
			@checkType()

		initActivityHomeDisplayDom: ->
			@_activityHomeDisplayDom = _getActivityDisplayDom @

		initActivityHomeDisplayChooseDom: ->
			@_activityHomeDisplayChooseDom = _getActivityDisplayChooseDom @

		initActivityDetailInfoDom: ->
			@_activityDetailInfoDom = _getActivityDetailInfoDom @

		initAllEvent: ->
			self = @
			fastClick self._activityDetailInfoDom,  ->
				if hashRoute.getCurrentState() is "activityInfo" then return
				_setCurrentChoose self.seqNum; hashRoute.pushHashStr("activityInfo")

		checkType: ->
			if @isValid
				if @type is "reduce" then deepCopy @detail, _reduceList
				if @type is "give" then deepCopy @detail, _giveList

		getCoresImgDomByType: (type)->
			if type is "display" then return (query ".img", @_activityHomeDisplayDom)
			else if type is "info" then return (query ".img", @_activityDetailInfoDom)
			else if type is "detail" then return _activityInfoImgDom

		getImageBuffer: (type)->
			self = @; url = @["#{type}Url"]
			if url then imageBuffer = new ImageBuffer {
				url 		:		url
				targetDom 	:		self.getCoresImgDomByType type
				id 			:		"activity-#{type}-#{self.seqNum}"
			}

		@getImageBufferForAllAcitvityByType: (type)->
			if _getImageBufferFlag[type] then return
			_getImageBufferFlag[type] = true
			for activity in _activities
				activity.getImageBuffer type

		@initial: ->
			dcTool = getJSON getDcToolJSON()
			_giveList = dcTool.give
			_reduceList = dcTool.reduce
			activityJSON = getJSON getActivityJSON()
			_initContainerDomByAllActivity(activityJSON)
			_initTypeUlDom()
			for activity, i in activityJSON
				activity = new Activity {
					seqNum 			:		i
					id 				:		activity.id
					displayUrl 		:		"#{activity.pic}?imageView2/1/w/#{Math.floor(clientWidth)}/h/#{Math.floor(clientWidth * 200 / 375)}"
					infoUrl 		:		"#{activity.pic}?imageView2/1/w/80/h/80"
					detailUrl 		:		"#{activity.pic}?imageView2/1/w/#{Math.floor(clientWidth * 0.9)}/h/#{Math.floor(clientWidth * 0.9 * 167 / 343)}"
					dateBegin 		:		activity.date_begin
					dateEnd 		:		activity.date_end
					intro 			:		activity.intro || ""
					content 		:		activity.content
					isValid 		:		activity.is_valid || true
					title 			:		activity.title
					type 			:		activity.type
					detail 			:		activity.detail
				}
			if activityJSON.length > 0
				new rotateDisplay {
					displayCSSSelector: "#Menu-page .activity-display-list"
					chooseCSSSelector: "#Menu-page .choose-dot-list"
					scale: 200/375
					delay: 3000
				}
			fastClick _activityColumnDom, -> hashRoute.hashJump("-Detail-Activity")

		@chooseActivityByCurrentChoose: -> _getCurrentChooseFromLocStor(); _selectActivityDisplayByCurrentChoose()

		@getReduceList: -> _reduceList

		@getGiveList: -> _giveList