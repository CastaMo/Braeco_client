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
	businessManage = null

	getDishJSON = getActivityJSON = getMemberJSON = getComPreJSON = getDinnerJSON = getChannelJSON = getHeaderLikeJSON = getDinnerInfoJSON = getCouponJSON = null
	getGroupJSON = null
	getDishLimitJSON = null
	getDcToolJSON = null
	getRechargeJSON = null
	getBusinessJSON = null

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

	Date.prototype.Format = (fmt)->
		o = {
			"M+" : this.getMonth()+1
			"d+" : this.getDate()
			"h+" : this.getHours()
			"m+" : this.getMinutes()
			"s+" : this.getSeconds()
			"q+" : Math.floor((this.getMonth()+3)/3)
			"S"  : this.getMilliseconds()
		}
		if /(y+)/.test(fmt)
			fmt = fmt.replace(RegExp.$1, (this.getFullYear()+"").substr(4 - RegExp.$1.length))
		for k of o when new RegExp("(#{k})").test(fmt)

			if RegExp.$1.length is 1 then str = o[k]
			else str = ("00"+ o[k]).substr((""+ o[k]).length)

			fmt = fmt.replace(RegExp.$1, str)
		return fmt
