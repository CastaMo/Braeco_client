	HomeBottom = do ->
		_state = ""
		_allDoms = querys "#nav-field .bottom-field div"
		_touchCallback = {
			"Menu": ->
				Category.getImageBufferForAllCategory()
				Activity.getImageBufferForAllAcitvityByType "display"
		}


		uncheckAllForBottomAndHideTarget = ->
			for dom in _allDoms
				id = dom.id; dom.className = "#{id}-unchecked"; addClass(getById("#{id}-page"), "hide"); setTimeout("scrollTo(0, 0)", 0)

		bottomTouchEventTrigger = (id)->
			if _state isnt id
				###
				*WebSocketxxxxx
				###
			_state = id
			uncheckAllForBottomAndHideTarget()
			getById(id).className = "#{id}-checked"
			removeClass(getById("#{id}-page"), "hide"); setTimeout("scrollTo(0, 0)", 0)
			_touchCallback[id]?()


		bottomTouchEventTrigger: bottomTouchEventTrigger
		uncheckAllForBottomAndHideTarget: uncheckAllForBottomAndHideTarget