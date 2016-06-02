	DetailPage = do ->

		_menuDom = getById "book-menu-wrap"
		_bookOrderDom = getById "book-order-column"
		_categoryBookCategoryDom = getById "book-top-wrap"
		_bookBottomDom = getById "book-bottom-column"
		_bookOrderBottomDom = query "#book-order-bottom-field", _bookBottomDom
		_chooseComboBottomDom = query "#choose-combo-bottom-field", _bookBottomDom

		_chooseComboDom = getById "choose-combo-column"

		for dom, i in querys "#book-menu-wrap > div:not(.clear)"
			dom.style.width = "#{clientWidth}px"
		_menuDom.style.width = "#{i * clientWidth}px"

		_translateForMenulDom = (compatibleTranslateCss = {})->
			for key, value of compatibleTranslateCss
				_menuDom.style[key] = value

		_getCompatibleTranslateCss = (ver, hor)->
			result_ = {}
			for config in compatibleCSSConfig
				result_["#{config}transform"] = "translate3d(#{ver}, #{hor}, 0)"
			result_

		_defaultShowDetail = ->
			removeClass _bookOrderDom, "hide"
			addClass _chooseComboDom, "hide"
			addClass _categoryBookCategoryDom, "hide"
			removeClass _bookBottomDom, "hide"

			removeClass _bookOrderBottomDom, "hide"
			addClass _chooseComboBottomDom, "hide"

		_togglePageCallback = {
			"bookInfo"				:	 do ->
				compatibleTranslateCss = _getCompatibleTranslateCss 0, 0
				->
					_defaultShowDetail()
					_translateForMenulDom compatibleTranslateCss
			"bookCol"				:	 do ->
				compatibleTranslateCss = _getCompatibleTranslateCss "#{-1*clientWidth}px", 0
				->
					_defaultShowDetail()
					removeClass _categoryBookCategoryDom, "hide"
					_translateForMenulDom compatibleTranslateCss

			"bookOrder"				:	 do ->
				compatibleTranslateCss = _getCompatibleTranslateCss "#{-2*clientWidth}px", 0
				->
					_defaultShowDetail()
					_translateForMenulDom compatibleTranslateCss
			"choosePaymentMethod"	:	 do ->
				compatibleTranslateCss = _getCompatibleTranslateCss "#{-3*clientWidth}px", 0
				->
					_defaultShowDetail()
					addClass _bookBottomDom, "hide"
					_translateForMenulDom compatibleTranslateCss
			"chooseCombo" 			:	do ->
				->
					addClass _bookOrderDom, "hide"
					removeClass _chooseComboDom, "hide"
					addClass _bookOrderBottomDom, "hide"
					removeClass _chooseComboBottomDom, "hide"
		}

		_translateForMenulDom _getCompatibleTranslateCss "#{-1*clientWidth}px", 0


		togglePage: (state)->
			_togglePageCallback[state]?()
			setTimeout("scrollTo(0, 0)", 0)