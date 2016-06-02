	ComboChooseDeleteManageSingleton = do ->
		_instance = null

		class ComboChooseDeleteManage

			_comboChooseDeletePageDom = getById "combo-choose-delete-page"
			_closeBtnDom = query ".btn-field", _comboChooseDeletePageDom
			_comboChooseDeleteDom = query ".combo-choose-delete-wrapper", _comboChooseDeletePageDom
			_confirmBtnDom = query ".confirm-wrapper .confirm-field", _comboChooseDeletePageDom

			_currentSubItemFood = null
			_targeInfo = []
			_currentChoose = -1
			_comboChooseDeletes = []

			_clear = ->
				for comboChooseDelete in _comboChooseDeletes
					comboChooseDelete.clear()
				_comboChooseDeletes = []


			_initComboChooseDelete = ->
				for order, i in _currentSubItemFood.orders
					comboChooseDelete = new ComboChooseDelete {
						seqNum 		:		i
						chooseInfo 	:		order.chooseInfo
						price 		:		order.price
					}
				_comboChooseDeletes[0].chooseSelfEvent()

			getSubItemFoodChoose: ->
				chooseInfo = locStor.get "comboChooseDeleteFoodChoose" || "[]"
				if chooseInfo is "[]" then hashRoute.warn(); return
				_clear()
				_targeInfo = JSON.parse chooseInfo
				_currentSubItemFood = comboManage.getSubItemFoodByChoose _targeInfo[0], _targeInfo[1]
				_initComboChooseDelete()

			_confirmBtnClickEvent = ->
				comboManage.minusItemFoodByChoose {
					comboId 		:		_targeInfo[2]
					subItemSeqNum 	:		_currentSubItemFood.subItemSeqNum
					seqNum 			:		_currentSubItemFood.seqNum
					chooseInfo 		:		_comboChooseDeletes[_currentChoose].chooseInfo
					num 			:		1
					price 			:		_comboChooseDeletes[_currentChoose].price
				}
				hashRoute.back()

			class ComboChooseDelete extends Base

				_getComboChooseDeleteDom = (comboChooseDelete)->
					dom = createDom "div"; dom.id = "combo-choose-delete-#{comboChooseDelete.seqNum}"; dom.className = "combo-choose-delete"
					dom.innerHTML = "<div class='combo-choose-delete-info-wrapper'>
										<div class='choose-info vertical-center'>#{comboChooseDelete.chooseInfo}</div>
										<div class='choose-field vertical-center'></div>
										<div class='choose-price money font-number-word vertical-center'>#{comboChooseDelete.price}</div>
									</div>"
					lineDom = createDom "div"; lineDom.className = "fivePercentLeftLine"
					append _comboChooseDeleteDom, dom
					append _comboChooseDeleteDom, lineDom
					dom

				_unchooseAllComboChooseDelete = ->
					for comboChooseDelete in _comboChooseDeletes
						removeClass comboChooseDelete.comboChooseDeleteDom, "choose"

				constructor: (options)->
					super options
					_comboChooseDeletes.push @

				init: ->
					@initComboChooseDeleteDom()
					@initAllEvent()

				initComboChooseDeleteDom: ->
					@comboChooseDeleteDom = _getComboChooseDeleteDom @

				initAllEvent: ->
					self = @
					addListener @comboChooseDeleteDom, "click", -> self.chooseSelfEvent()

				chooseSelfEvent: ->
					_unchooseAllComboChooseDelete()
					_currentChoose = @seqNum
					addClass @comboChooseDeleteDom, "choose"

				clear: ->
					brotherDom = getBrotherDom @comboChooseDeleteDom
					if brotherDom then remove brotherDom
					remove @comboChooseDeleteDom


			constructor: ->
				addListener _closeBtnDom, "click", -> hashRoute.back()
				addListener _confirmBtnDom, "click", _confirmBtnClickEvent


		getInstance: ->
			if _instance is null then _instance = new ComboChooseDeleteManage()
			return _instance

		initial: ->
			comboChooseDeleteManage = @getInstance()
