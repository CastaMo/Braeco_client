	[addListener, removeListener, hasClass, addClass, removeClass, ajax, getElementsByClassName, isPhone, hidePhone, query, querys, remove, append, prepend, toggleClass, getObjectURL, deepCopy, getById, createDom, getJSON, getAdaptHeight, findParent] = [util.addListener, util.removeListener, util.hasClass, util.addClass, util.removeClass, util.ajax, util.getElementsByClassName, util.isPhone, util.hidePhone, util.query, util.querys, util.remove, util.append, util.prepend, util.toggleClass, util.getObjectURL, util.deepCopy, util.getById, util.createDom, util.getJSON, util.getAdaptHeight, util.findParent]

	clientWidth =  document.body.clientWidth
	clientHeight = document.documentElement.clientHeight
	locStor = null
	user = null
	bookChoose = null
	foodInfo = null
	bookOrder = null
	alreadyManage = null
	pay = null
	lockManage = null
	requireManage = null
	confirmManage = null
	routeManage = null
	webSock = null
	comboManage = null
	comboChooseDeleteManage = null
	couponManage = null
	groupManage = null
	dishLimitManage = null
	getDishJSON = getActivityJSON = getMemberJSON = getComPreJSON = getDinnerJSON = getChannelJSON = getHeaderLikeJSON = getDinnerInfoJSON = getCouponJSON = null
	getGroupJSON = null
	getDishLimitJSON = null
	getDcToolJSON = null

	compatibleCSSConfig = [
		""
		"-webkit-"
		"-moz-"
		"-ms-"
		"-o-"
	]

	getBrotherDom = (dom)-> dom.previousSibling || dom.nextSibling

	filteTheStr = (str)-> result = str.replace(/<(.*)>(.*)<\/(.*)>|<(.*)\/>/g, "").replace(/\\/g,"").replace(/&/g, "")

	now = -> +new Date()

	numToChinese = ["零","一","二","三","四","五","六","七","八","九","十"]