	ConfirmManageSingleton = do ->

		_instance = null

		class confirmManage

			_confirmPageDom = getById "confirm-page"

			_closeBtnDom 			= 		query ".header-field .btn-field", _confirmPageDom
			_titleDom 				= 		query ".title-field .title", _confirmPageDom
			_contentDom 			=  		query ".content-field .content", _confirmPageDom
			_cancelBtnDom 			= 		query ".confirm-wrapper .cancel-field", _confirmPageDom
			_inputFieldDom 			= 		query ".lower-wrapper", _confirmPageDom
			_inputDom 				= 		query "input#server", _inputFieldDom
			_confirmBtnDom 			= 		query ".confirm-wrapper .confirm-field", _confirmPageDom
			_confirmBtnContentDom 	= 		query "p", _confirmBtnDom

			_confirmCallback = null
			_cancelCallback = null
			_needInput = false
			
			_setConfig = (options)->
				_titleDom.innerHTML = options.title
				_contentDom.innerHTML = options.content
				_confirmBtnContentDom.innerHTML = options.confirmContent
				if _needInput = options.needInput then _inputDom.value = ""; removeClass _inputFieldDom, "hide"
				else addClass _inputFieldDom, "hide"
				_confirmCallback = options.success
				_cancelCallback = options.cancel

			constructor: ->
				addListener _closeBtnDom, "touchstart", -> hashRoute.back(); _cancelCallback?()
				addListener _cancelBtnDom, "touchstart", -> hashRoute.back(); _cancelCallback?()
				addListener _confirmBtnDom, "touchstart", -> hashRoute.back(); _confirmCallback?(_inputDom.value)

			simulateConfirm: (options)->
				_setConfig options
				hashRoute.pushHashStr "Popup-Form-Confirm"

			isValid: -> return (_confirmCallback isnt null and _cancelCallback isnt null)

		getInstance: ->
			if _instance is null then _instance = new confirmManage()
			return _instance
		initial: ->
			confirmManage = ConfirmManageSingleton.getInstance()