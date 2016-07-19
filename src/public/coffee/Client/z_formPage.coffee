	FormPage = do ->
		_formPageDom = getById "brae-form-page"
		_coverDom = query ".cover", _formPageDom
		_coverDom.style.width = "#{clientWidth}px"; _coverDom.style.height = "#{clientHeight}px"

		_popupDom = getById "popup"

		_judegeWouldScrollByHeight = (parentNode)->
			_parentHeight = parentNode.parentNode.getBoundingClientRect().height
			_allChildHeight = 0
			for child in parentNode.childNodes
				if child.getBoundingClientRect then _allChildHeight += child.getBoundingClientRect().height

			#如果子节点们触发了overflow时，返回true
			return _parentHeight < _allChildHeight

		_preventScrollFromOuter = (e)->
			e = e || window.event
			target = e.target || e.srcElement
			parentNode = findParent(target, (parentNode)-> return ((hasClass parentNode, "book-choose") or (hasClass parentNode, "combo-choose-delete") or (hasClass parentNode, "form-page") or (hasClass parentNode, "category") ))
			if !((hasClass parentNode, "book-choose") or (hasClass parentNode, "combo-choose-delete") or (hasClass parentNode, "category"))  then e.preventDefault()
			#else if !_judegeWouldScrollByHeight(parentNode.parentNode) then e.preventDefault()

		fastClick _popupDom, "touchmove", _preventScrollFromOuter
		fastClick _coverDom, -> if hashRoute.getCurrentState() is "categoryChoose" then hashRoute.back()

		_fixNeedPages = ['book-choose-page', 'combo-choose-delete-page', 'category-choose-page']

		_togglePageCallback = (pageId)->
			if pageId in _fixNeedPages then _popupDom.style.position = "fixed"
			else _popupDom.style.position = "absolute"

		togglePage: (pageId)-> _togglePageCallback pageId