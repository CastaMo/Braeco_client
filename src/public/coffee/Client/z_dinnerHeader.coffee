	class DinnerHeader extends Base
		_dinnerHeaders = []
		_likeNum = 0
		_isLike = false
		_getImageBufferFlag = false

		_activityHeaderDom = getById "Activity-header-column"
		_dinnerHeaderContainerDom = query "ul.header-display-list", _activityHeaderDom
		_dinnerHeaderChooseFieldDom = query "ul.choose-dot-list", _activityHeaderDom

		_likeFieldDom = query ".like-field", _activityHeaderDom
		_likeIconDom = query ".like-icon", _likeFieldDom
		_likeNumDom = query ".like-num", _likeFieldDom

		_getDinnerHeaderDisplayDom = (dinnerHeader)->
			imgWidth = clientWidth; imgHeight = clientWidth*200/375

			dom = createDom "li"; dom.id = "header-#{dinnerHeader.seqNum}"
			dom.innerHTML = "<div class='header-img img default-display-image' style='height:#{imgHeight}px;background-size:#{imgWidth}px #{imgHeight}px'></div>"
			append _dinnerHeaderContainerDom, dom
			dom

		_getDinnerHeaderChooseDom = (dinnerHeader)->
			dom = createDom "li"; dom.id = "choose-dot-#{dinnerHeader.seqNum}"; dom.className = "inactive"
			dom.innerHTML = "<div class='dot'></div>"
			append _dinnerHeaderChooseFieldDom, dom
			dom

		_setLikeState = ->
			addClass _likeIconDom, "like"; removeClass _likeIconDom, "unlike"
			_isLike = true

		_setUnlikeState = ->
			addClass _likeIconDom, "unlike"; removeClass _likeIconDom, "like"
			_isLike = false

		_getLikeNum = ->
			likeNum = getHeaderLikeJSON() || "0"
			likeNum = JSON.parse likeNum
			_likeNum = likeNum
			_likeNumDom.innerHTML = _likeNum

		_setLike = (isAdd)->
			if isAdd then _likeNum++; _setLikeState()
			else if _likeNum >= 1 then _likeNum--; _setUnlikeState()
			_likeNumDom.innerHTML = _likeNum

		_addLike = ->
			if not user.isLogin() or user.isLike() or _isLike then return
			_setLike true
			user.setLike true

		_subtractLike = ->
			if not user.isLogin() or not user.isLike() or not _isLike then return
			_setLike false
			user.setLike false

		_likeFieldClickSuccessCallBack = ->
			if not _isLike then _addLike()
			else _subtractLike()

		constructor: (options)->
			super options
			_dinnerHeaders.push @

		init: ->
			@initDinnerHeaderDisplayDom()
			@initDinnerHeaderChooseDom()

		initDinnerHeaderDisplayDom: ->
			@dinnerHeaderDisplayDom = _getDinnerHeaderDisplayDom @

		initDinnerHeaderChooseDom: ->
			@dinnerHeaderChooseDom = _getDinnerHeaderChooseDom @

		getImageBuffer: ->
			self = @
			if @url then imageBuffer = new ImageBuffer {
				url 		:		self.url
				targetDom 	:		query ".img", self.dinnerHeaderDisplayDom
				id 			:		"header-#{self.seqNum}"
			}

		@getImageBufferForAllDinnerHeader: ->
			if _getImageBufferFlag then return
			_getImageBufferFlag = true
			for dinnerHeader in _dinnerHeaders
				dinnerHeader.getImageBuffer()

		@initial: ->
			dinnerJSON = getDinnerJSON() || "[]"
			dinnerJSON = getJSON dinnerJSON
			if dinnerJSON
				for elem, i in dinnerJSON
					dinnerHeader = new DinnerHeader {
						seqNum 			:		i
						url 			:		"#{elem}?imageView2/1/w/#{Math.floor(clientWidth)}/h/#{Math.floor((clientWidth)*200/375)}"
					}
				if dinnerJSON.length >= 1
					new rotateDisplay {
						displayCSSSelector: "#Activity-page .header-display-list"
						chooseCSSSelector: "#Activity-page .choose-dot-list"
						scale: 200/375
						delay: 3000
					}
			_getLikeNum()
			addListener _likeFieldDom, "click", ->
				if not user.isLogin() then locStor.set("loginFlag", 0); hashRoute.pushHashStr("Popup-Form-Login"); return
				if not lockManage.get("like").getLock() then return
				if _isLike then x = 0
				else x = 1
				requireManage.get("like").require(x, ->
					_likeFieldClickSuccessCallBack()
				, ->
					setTimeout(->
						lockManage.get("like").releaseLock()
					, 1000)
				)
		@setLikeState: _setLikeState
		@setUnlikeState: _setUnlikeState