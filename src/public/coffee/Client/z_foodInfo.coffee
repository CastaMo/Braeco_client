	FoodInfoSingleton = do ->
		_instance = null

		class FoodInfo
			_bookDishDom = getById "book-dish-wrap"
			_foodInfo = getById "book-info-wrap"
			_foodInfoImgDom = query ".food-img-wrapper .img", _foodInfo
			_foodInfoDom = query ".full-part", _foodInfo
			_plusBtnDom = query ".plus-field", _foodInfoDom
			_foodInfoIntroWrapperDom = query ".food-intro-wrapper", _foodInfo
			_foodInfoIntroDom = query ".intro-wrap .intro", _foodInfo

			_foodCurrentChoose = null
			_currentFood = null

			_getCurrentChooseFromLocStor = ->
				choose = locStor.get("foodCurrentChoose") || "-1000"
				choose = JSON.parse(choose)
				if choose is -1000 then hashRoute.warn(); return false
				_currentFood = Food.getFoodById choose; return true

			_selectFoodDisplayByCurrentChoose = ->
				addClass _foodInfoIntroWrapperDom, "hide"
				_foodInfoImgDom.style.backgroundImage = ""
				_currentFood.getImageBuffer "info"
				currentFooInfoDom = query(".full-part", _currentFood.foodDom) || query(".right-part", _currentFood.foodDom)
				(query ".top-wrap", _foodInfoDom).innerHTML = (query ".top-wrap", currentFooInfoDom).innerHTML
				(query ".price-field", _foodInfoDom).innerHTML = (query ".price-field", currentFooInfoDom).innerHTML
				_foodInfoIntroDom.innerHTML = _currentFood.intro
				if _currentFood.intro then removeClass _foodInfoIntroWrapperDom, "hide"

			constructor: ->
				imgHeight = clientWidth * 200 / 375
				_foodInfoImgDom.style.height = "#{imgHeight}px"
				_foodInfoImgDom.style.backgroundSize = "#{clientWidth}px #{imgHeight}px"

				fastClick _plusBtnDom, (e)-> _currentFood.judgeForBook {initLeft:clientWidth * 0.9 - 30, initTop: event.y-15}, _plusBtnDom

			chooseFoodByCurrentChoose: -> if _getCurrentChooseFromLocStor() then _selectFoodDisplayByCurrentChoose()

			getImgDom: -> _foodInfoImgDom

			getPlusBtnDom: -> _plusBtnDom

		getInstance: ->
			if _instance is null then _instance = new FoodInfo()
			return _instance

		initial: ->
			foodInfo = @getInstance()