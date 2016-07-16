	class Base
		constructor: (options)->
			deepCopy options, @
			@init()

		init: ->

	class rotateDisplay extends Base

		_getCompatibleTranslateCss = (ver, hor)->
			result_ = {}
			for config in compatibleCSSConfig
				result_["#{config}transform"] = "translate3d(#{ver}, #{hor}, 0)"
			result_

		_getCompatibleDurationCss = (isMove = false)->
			result_ = {}
			if isMove
				for config in compatibleCSSConfig
					result_["#{config}transition"] = "all 0 linear"
			else
				for config in compatibleCSSConfig
					result_["#{config}transition"] = "all 0.3s ease-in-out"
			result_

		_autoRotateEvent = (rotateDisplay)->
			self = rotateDisplay

			###
			* 监视autoFlag
			###
			if not self._autoFlag then self._autoFlag = true
			else
				index = (self.currentChoose + 1) % self.activityNum
				self.setCurrentChooseAndTranslate(index)
			setTimeout(->
				_autoRotateEvent(self)
			, self.delay)


		###
		* 触摸开始的时候记录初始坐标位置
		###
		_touchStart = (e, rotateDisplay)->
			rotateDisplay._autoFlag = false
			#e.preventDefault()
			#e.stopPropagation()
			rotateDisplay.startX = e.touches[0].clientX
			rotateDisplay.startY = e.touches[0].clientY
			rotateDisplay.currentX = e.touches[0].clientX
			rotateDisplay.currentY = e.touches[0].clientY
			rotateDisplay.timestamp = (new Date()).getTime()

		###
		* 触摸的过程记录触摸所到达的坐标
		###
		_touchMove = (e, rotateDisplay)->
			e.preventDefault()
			e.stopPropagation()
			rotateDisplay._autoFlag = false
			rotateDisplay.currentX = e.touches[0].clientX
			rotateDisplay.currentY = e.touches[0].clientY
			rotateDisplay.timestamp = (new Date()).getTime()
			if rotateDisplay.activityNum > 1
				touchOffsetX = rotateDisplay.currentX - rotateDisplay.startX
				rotateDisplay.setTransitionForDisplayUlDom true
				rotateDisplay.translateForDisplayUlDom "#{-1 * rotateDisplay.currentChoose * clientWidth + touchOffsetX}px", 0

		###
		* 比较判断用户是倾向于左右滑动还是上下滑动
		* 若为左右滑动，则根据用户滑动的地方，反向轮转播放动画(符合正常的滑动逻辑)
		###
		_touchEnd = (e, rotateDisplay)->
			rotateDisplay._autoFlag = false
			currentX = rotateDisplay.currentX
			currentY = rotateDisplay.currentY
			startX = rotateDisplay.startX
			startY = rotateDisplay.startY
			lastTimestamp = rotateDisplay.timestamp
			currentTimestamp = (new Date()).getTime()
			currentChoose = rotateDisplay.currentChoose; activityNum = rotateDisplay.activityNum

			transIndex = currentChoose
			if currentX < startX
				if (startX - currentX)*2 >= clientWidth or (currentTimestamp - lastTimestamp < 20)
					transIndex = (currentChoose + 1) % activityNum
			else if currentX > startX
				if (currentX - startX)*2 >= clientWidth or (currentTimestamp - lastTimestamp < 20)
					transIndex = (currentChoose - 1 + activityNum) % activityNum

			rotateDisplay.setTransitionForDisplayUlDom false
			rotateDisplay.setCurrentChooseAndTranslate currentChoose
			rotateDisplay.setCurrentChooseAndTranslate transIndex


		###
		* 图片轮转播放
		* @param {Object} options: 组件配置
		*
		* 调用方法:
		* 直接通过构造函数，传入对应的对象配置即可。
		* displayCSSSelector为图片所在的ul的css选择器
		* chooseCSSSelector为图片对应的标号索引所在的ul的css选择器
		* delay为图片每次轮转的时间
		###

		constructor: (options)->
			@displayUlDom = query options.displayCSSSelector
			@chooseUlDom = query options.chooseCSSSelector
			dom.style.height = "#{options.scale * clientWidth}px" for dom in querys "img", @displayUlDom
			super options

		init: ->
			@initDisplay()
			@initChoose()
			@initAutoRotate()
			@initTouchEvent()

		initDisplay: ->
			@displayContainerDom = @displayUlDom.parentNode
			@displayContainerDom.style.overflowX = "hidden"
			@allDisplayDom = querys "li", @displayUlDom

			###
			* 让所有的图片的宽度都能适应屏幕
			###

			for dom in @allDisplayDom
				dom.style.width = "#{clientWidth}px"
			@activityNum = @allDisplayDom.length

			###
			* 扩充图片所在ul的长度
			###
			@displayUlDom.style.width = "#{clientWidth * @activityNum}px"

		initChoose: ->
			@chooseUlDom.parentNode.style.overflow = "hidden"
			self = @
			@allChooseDom = querys "li", @chooseUlDom
			@chooseUlDom.style.width = "#{@allChooseDom.length * 20}px"
			@currentChoose = 0
			@allChooseDom[0].className = "active"
			for dom, i in @allChooseDom
				addListener dom, "click", do (i)-> (e)-> e.preventDefault(); e.stopPropagation(); self._autoFlag = false; self.setCurrentChooseAndTranslate(i)

		initAutoRotate: ->
			###
			* autoFlag用于监视是否有人工操作，如果有，则当前最近一次不做播放，重新设置autoFlag，使得下一次播放正常进行
			###
			self = @
			@_autoFlag = true
			setTimeout(->
				_autoRotateEvent(self)
			, self.delay)

		initTouchEvent: ->
			self = @
			addListener self.displayContainerDom, "touchstart", (e)-> _touchStart(e, self)
			addListener self.displayContainerDom, "touchmove", (e)-> _touchMove(e, self)
			addListener self.displayContainerDom, "touchend", (e)-> _touchEnd(e, self)

		setCurrentChoose: (index)->
			@allChooseDom[@currentChoose].className = "inactive"
			@allChooseDom[index].className = "active"
			@currentChoose = index

		setTransitionForDisplayUlDom: (isMove)->
			compatibleDurationCss = _getCompatibleDurationCss isMove
			for key, value of compatibleDurationCss
				@displayUlDom.style[key] = value

		translateForDisplayUlDom: (ver = 0, hor = 0)->
			compatibleTranslateCss = _getCompatibleTranslateCss(ver, hor)
			for key, value of compatibleTranslateCss
				@displayUlDom.style[key] = value

		setCurrentChooseAndTranslate: (index)->
			if index < 0 or index >= @activityNum then return
			transIndex =  -1 * index
			@translateForDisplayUlDom("#{transIndex * clientWidth}px", 0)
			@setCurrentChoose(index)

	class ImageBuffer extends Base

		_imageBuffers = {}

		constructor: (options)->
			if _imageBuffers[options.id] then return null
			super options
			_imageBuffers[@id] = @

		init: ->
			@initBuffer()
			@initEvent()
			@initLoad()

		initBuffer: ->
			@image = new Image()

		initEvent: ->
			self = @
			@image.onload = ->
				self.targetDom.style.backgroundImage = "url(#{self.url})"; delete _imageBuffers[self.id]
			@image.onerror = ->
				delete _imageBuffers[self.id]
			@image.onabort = ->
				delete _imageBuffers[self.id]

		initLoad: ->
			@image.src = @url

	class ActiveBall extends Base
		window.ActiveBall = ActiveBall
		_activeBalls = []

		_bookBottomDom = getById "book-bottom-column"

		_getActiveBallDom = (activeBall)->
			dom = createDom "div"; dom.className = 'active-ball'
			dom.style.left = "#{activeBall.initLeft}px"
			dom.style.top = "#{activeBall.initTop}px"
			append _bookBottomDom, dom
			dom

		constructor: (options)->
			super options
			_activeBalls.unshift @

		init: ->
			@initConfig()
			@initActiveBallDom()
			@initBallEvent()

		initConfig: ->
			@curvature = @curvature	|| 0.009
			@duration = @duration 	|| 600
			@endLeft = @endLeft 	|| 28
			@endTop = @endTop 		|| (clientHeight - 50)
			@initLeft = @initLeft 	|| clientWidth
			@initTop = @initTop 	|| 0
			@midLeft = (@initLeft + @endLeft) / 2
			@midTop = @initTop / 1.1
			@begin = now()
			@end = @begin + @duration
			@driftx = @initLeft - @endLeft; @drifty = @initTop - @endTop
			@a = (@initTop * (@endLeft - @midLeft) + @endTop * (@midLeft - @initLeft) + @midTop * (@initLeft - @endLeft)) / (@initLeft * @initLeft * (@endLeft - @midLeft) + @endLeft * @endLeft * (@midLeft - @initLeft) + @midLeft * @midLeft * (@initLeft - @endLeft))
			@b = (@initTop - @endTop) / (@initLeft - @endLeft) - @a * (@initLeft + @endLeft)
			@c = @initTop - @initLeft * @initLeft * @a - @initLeft * @b

		initActiveBallDom: -> @activeBallDom = _getActiveBallDom @

		initBallEvent: ->
			self = @
			@timerId = setInterval (-> self.step now()), 20

		step: (now)->
			if now > @end then @stop(); @callback?(); remove @activeBallDom; _activeBalls.pop(); return
			x = @initLeft - (now - @begin) * @driftx / @duration
			y = @a * x * x + @b * x + @c
			@show x, y
			@stepCallback?()

		stop: -> if @timerId then clearInterval @timerId

		show: (x, y)-> @activeBallDom.style.left = "#{x}px"; @activeBallDom.style.top = "#{y}px"

	callpay = (options)->
		self = @
		if typeof wx isnt "undefined"
			wxConfigFailed = false
			wx.config({
				debug:false
				appId:"#{options.appid}"
				timestamp:options.timestamp
				nonceStr:"#{options.noncestr}"
				signature: "#{options.signature}"
				jsApiList: ['chooseWXPay']
			})
			wx.ready ->
				if wxConfigFailed then return
				wx.chooseWXPay {
					timestamp: options.timestamp
					nonceStr: "#{options.noncestr}"
					package: "#{options.package}"
					signType: 'MD5'
					paySign: "#{options.signMD}"
					success: (res)->
						options.always?()
						if res.errMsg is "chooseWXPay:ok" then innerCallback("success"); options.callback?()
						else innerCallback("fail", error("wx_result_fail", res.errMsg))
					cancel: (res)-> options.always?(); innerCallback("cancel")
					fail: (res)-> options.always?(); innerCallback("fail", error("wx_config_fail", res.errMsg))
				}
			wx.error (res)-> options.always?(); wxConfigFailed = true; innerCallback("fail", error("wx_config_error", res.errMsg))

	innerCallback = (result, err)->
		if typeof @_resultCallback is "function"
			if typeof err is "undefined" then err = @_error()
			@_resultCallback(result, err)
