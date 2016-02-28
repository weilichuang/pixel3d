(function () {
	var __register_name_space__ = true;
	var Sina = {};
if (regist == null) {
	var regist = function(){};
	(function(){
		/**
		 * \u901a\u8fc7\u589e\u52a0\u4ee5\u4e0b\u4e24\u4e2a\u53d8\u91cf\u5230\u95ed\u5305\u5b9e\u73b0Sina\u7684\u79c1\u6709\u5316
		 * var __register_name_space__ = true;
		 * var Sina = {};
		 */
		var funList = {};
		function registerNamespace(sNameSpace, oFunc, oOption){
			var currentPart;
			try {
				if (__register_name_space__ == true) {
					var rootObject = Sina;
				}
				else {
					var rootObject = window;
				}
			}
			catch (e) {
				var rootObject = window;
			}
			var namespaceParts = sNameSpace.split('.');
			try {
				if (__register_name_space__ == true) {
					if (namespaceParts[0] == "Sina") {
						namespaceParts.shift();
					}
				}
			}
			catch (e) {
			}
			for (var i = 0; i < namespaceParts.length; i++) {
				currentPart = namespaceParts[i];
				if (!rootObject[currentPart]) {
					rootObject[currentPart] = {};
				}
				rootObject = rootObject[currentPart];
			}
		}
		function registerFuncLink(sShortName, sNameSpace, oFunc, oOption){
			var currentPart;
			try {
				if (__register_name_space__ == true) {
					var rootObject = Sina;
				}
				else {
					var rootObject = window;
				}
			}
			catch (e) {
				var rootObject = window;
			}
			funList[sNameSpace] = {
				name: sShortName,
				space: sNameSpace,
				func: oFunc,
				option: oOption
			};
			var namespaceParts = sNameSpace.split('.');
			try {
				if (__register_name_space__ == true) {
					if (namespaceParts[0] == "Sina") {
						namespaceParts.shift();
					}
				}
			}
			catch (e) {
			}
			for (var i = 0; i < namespaceParts.length; i++) {
				currentPart = namespaceParts[i];
				if (i == namespaceParts.length - 1) {
					rootObject[currentPart] = oFunc;
					return;
				}
				rootObject = rootObject[currentPart];
			}
		}
		function regist_proto(sShortName, sNameSpace, oFunc, oOption){
			if (sShortName == null) {
				alert("regist_proto[\u51fd\u6570\u7684\u77ed\u540d\u5c1a\u672a\u4f20\u5165]\n\n\u4f8b\u5982\n'$getStyle'");
				return;
			}
			if (sNameSpace == null) {
				alert("regist_proto[\u51fd\u6570\u7684\u547d\u540d\u7a7a\u95f4\u5c1a\u672a\u4f20\u5165]\n\n\u4f8b\u5982\n'Sina.dom.getStyle'");
				return;
			}
			if (oFunc == null) {
				alert("regist_proto[\u5177\u4f53\u51fd\u6570\u5c1a\u672a\u5b9e\u73b0]\n\n\u4f8b\u5982\nfunction (el) {return el.className;}");
				return;
			}
			// \u521b\u5efa\u547d\u540d\u7a7a\u95f4
			registerNamespace(sNameSpace);
			// \u628a\u51fd\u6570\u7ed1\u5b9a\u5230\u76f8\u5e94\u7684\u547d\u540d\u7a7a\u95f4\u4ee5\u53ca\u5185\u90e8\u7684\u5b58\u50a8\u5806\u6808
			registerFuncLink(sShortName, sNameSpace, oFunc, oOption);
		}
		regist_proto.bindTo = function(){
			var a = [];
			var o = funList;
			var n, i;
			for (i in o) {
				n = o[i];
				a[a.length] = "var " + o[i].name + "=" + o[i].space + ";";
			}
			return a.join("");
		};
		regist_proto.getFuncList = function(){
		};
		regist = regist_proto;
	})();
}
/**
 * @author {FlashSoft}
 * @update {xs} 2008-8-11
 */
(function () {
	var _ua = navigator.userAgent.toLowerCase();
	/** \u662f\u5426\u4e3aIE\u6d4f\u89c8\u5668 */
	var ie = /msie/.test(_ua);
	/** \u662f\u5426\u4e3aIE6\u6d4f\u89c8\u5668 */
	var ie6 = /msie 6/.test(_ua);
	/** \u662f\u5426\u4e3aIE7\u6d4f\u89c8\u5668 */
	var ie7 = /msie 7/.test(_ua);
	/** \u662f\u5426\u4e3aFireFox\u6d4f\u89c8\u5668 */
	var ff = /gecko/.test(_ua);
	/** \u662f\u5426\u4e3aFireFox 3\u6d4f\u89c8\u5668 */
	var ff3 = /firefox\/3/.test(_ua);
	/** \u662f\u5426\u4e3aSafari\u6d4f\u89c8\u5668 */
	var safari = /safari/.test(_ua);
	/** \u662f\u5426\u4e3aOpera\u6d4f\u89c8\u5668 */
	var opera = /opera/.test(_ua);
	regist("$ie", "Sina.base.ie", ie, "FlashSoft", "\u5224\u65ad\u6d4f\u89c8\u5668\u662f\u5426\u662fIE");
	regist("$ie6", "Sina.base.ie6", ie6, "FlashSoft", "\u5224\u65ad\u6d4f\u89c8\u5668\u662f\u5426\u662fIE6");
	regist("$ie7", "Sina.base.ie7", ie7, "FlashSoft", "\u5224\u65ad\u6d4f\u89c8\u5668\u662f\u5426\u662fIE7");
	regist("$ff", "Sina.base.ff", ff, "FlashSoft", "\u5224\u65ad\u6d4f\u89c8\u5668\u662f\u5426\u662fFireFox");
	regist("$ff3", "Sina.base.ff3", ff, "xs", "\u5224\u65ad\u6d4f\u89c8\u5668\u662f\u5426\u662fFireFox3.0");
	regist("$safari", "Sina.base.safari", safari, "FlashSoft", "\u5224\u65ad\u6d4f\u89c8\u5668\u662f\u5426\u662fSafari");
	regist("$opera", "Sina.base.opera", opera, "FlashSoft", "\u5224\u65ad\u6d4f\u89c8\u5668\u662f\u5426\u662fOpera");
})();
/**
 * \u8fd4\u56de\u6307\u5b9a\u540d\u79f0\u5bf9\u8c61
 * @param {String} oID \u5bf9\u8c61\u7684\u540d\u5b57
 * @return {Element} \u5bf9\u8c61\u7684DOM\u8282\u70b9
 * @author FlashSoft | fangchao@staff.sina.com.cn
 * @example
 * 	Sina.base.get(document.body);
 * 	Sina.base.get("testInput");
 */
(function () {
	var get = function (oID) {
		var node = typeof oID == "string"? document.getElementById(oID): oID;
		if(node != null)return node;
		//else console.log("\u5bf9\u8c61: " + oID + " \u4e0d\u5b58\u5728");
	};
	regist("$E", "Sina.base.get", get, "FlashSoft", "\u83b7\u53d6\u6307\u5b9a\u540d\u5b57\u7684\u5bf9\u8c61");
})();
/**
 * \u6839\u636etagname\u521b\u5efa\u6307\u5b9a\u7c7b\u578b\u7684\u8282\u70b9\u5143\u7d20
 * @param {String} tagName \u5236\u5b9a\u7684\u8282\u70b9\u7c7b\u578b
 * @return {Element} \u65b0\u5efa\u7684DOM\u8282\u70b9
 * @author xs | zhenhua1@staff.sina.com.cn
 * @example
 * 	Sina.base.create("div");
 */
(function () {
	var create = function (sID) {
		return typeof sID == "string"? document.createElement(sID): null;
	};
	regist("$C", "Sina.dom.create", create, "xs", "\u6839\u636etagname\u521b\u5efa\u6307\u5b9a\u7c7b\u578b\u7684\u8282\u70b9\u5143\u7d20");
})();
/**
* \u8bbe\u5b9a\u6307\u5b9a\u8282\u70b9\u7684\u6837\u5f0f
* @method Sina.dom.setStyle
* @param {HTMLElement | Document} el \u8282\u70b9\u5bf9\u8c61
* @param {String} property \u6837\u5f0f\u540d
* @param {String} val \u6837\u5f0f\u503c
* @author FlashSoft | fangchao@staff.sina.com.cn
* @update 08.02.23
* @example
* 	Sina.dom.setStyle(document.body, "backgroundColor", "red");
*/
(function () {
	var setStyle;
	if (Sina.base.ie) {
		setStyle = function (el, property, val) {
			switch (property) {
				case "opacity":
					el.style.filter = "alpha(opacity=" + (val * 100) + ")";
					if (!el.currentStyle || !el.currentStyle.hasLayout) {
						el.style.zoom = 1;
					}
					break;
				case "float":
					property = "styleFloat";
				default:
					el.style[property] = val;
			}
		};
	}
	else {
		setStyle = function(el, property, val) {
			if (property == "float") {
				property = "cssFloat";
			}
			el.style[property] = val;
		};
	}
	regist("$setStyle", "Sina.dom.setStyle", setStyle, "FlashSoft", "\u8bbe\u5b9a\u6307\u5b9a\u8282\u70b9\u7684\u6837\u5f0f");
})();
/**
* \u83b7\u53d6\u6307\u5b9a\u8282\u70b9\u7684\u6837\u5f0f
* @method Sina.dom.getStyle
* @param {HTMLElement | Document} oElement \u8282\u70b9\u5bf9\u8c61
* @param {String} sProperty \u6837\u5f0f\u540d
* @return {String} \u6307\u5b9a\u6837\u5f0f\u7684\u503c
* @author FlashSoft | fangchao@staff.sina.com.cn
* @update 08.07.29
* @example
* 	Sina.dom.getStyle(document.body, "left");
*/
(function () {
	var getStyle;
	if (Sina.base.ie) {
		getStyle = function(oElement, sProperty){
			var val;
			try{
				switch (sProperty) {
					// \u900f\u660e\u5ea6
					case "opacity":
						val = 100;
						try {
							val = oElement.filters['DXImageTransform.Microsoft.Alpha'].opacity;
						}
						catch (e) {
							try {
								val = oElement.filters('alpha').opacity;
							}
							catch (e) {
							}
						}
						return parseFloat(val / 100);
					// \u6d6e\u52a8
					case "float":
						sProperty = "styleFloat";
					default:
						val = oElement.currentStyle ? oElement.currentStyle[sProperty] : null;
						return (oElement.style[sProperty] || val);
				}
			}
			finally {
				val = null;
			}
		};
	}
	else {
		getStyle = function (oElement, sProperty) {
			var computed;
			try {
				// \u6d6e\u52a8
				if(sProperty == "float") {
					sProperty = "cssFloat";
				}
				// \u83b7\u53d6\u96c6\u5408
				computed = document.defaultView.getComputedStyle(oElement, "");
				return oElement.style[sProperty] || computed? computed[sProperty]: null;
			}
			finally {
				computed = null;
			}
		};
	}
	regist("$getStyle", "Sina.dom.getStyle", getStyle, "FlashSoft", "\u83b7\u53d6\u6307\u5b9a\u8282\u70b9\u7684\u6837\u5f0f");
})();
/**
 * \u5220\u9664\u6307\u5b9a\u540d\u79f0\u7684\u8282\u70b9
 * @param {String | Element} oNode \u8282\u70b9\u7684\u540d\u79f0\u6216\u8005\u8282\u70b9\u5bf9\u8c61
 * @author FlashSoft | fangchao@staff.sina.com.cn
 * @example
 * 	Sina.dom.removeNode("testInput");
 * 	Sina.dom.removeNode(document.getElementsByTagName("a")[0]);
 */
(function () {
	var removeNode = function (oNode) {
		oNode = Sina.base.get(oNode);
		oNode.parentNode.removeChild(oNode);
	};
	regist("$removeNode", "Sina.dom.removeNode", removeNode, "FlashSoft", "\u5220\u9664\u6307\u5b9a\u540d\u79f0\u7684\u8282\u70b9");
})();
/**
 * \u53d6\u5f97\u9875\u9762\u7684\u6eda\u52a8\u6761\u4f4d\u7f6e
 * @method Sina.dom.getScrollPos
 * @return {Array} \u6eda\u52a8\u6761\u5c45\u9876 \u5c45\u5de6\u503c
 * @author fangchao@staff.sina.com.cn
 * @update 08.02.13
 */
(function () {
	var getScrollPos = function(oDocument) {
		oDocument = oDocument || document;
		return [
			Math.max(oDocument.documentElement.scrollTop, oDocument.body.scrollTop),
			Math.max(oDocument.documentElement.scrollLeft, oDocument.body.scrollLeft)
		];
	};
	regist("$getScrollPos", "Sina.dom.getScrollPos", getScrollPos, "FlashSoft", "\u53d6\u5f97\u9875\u9762\u7684\u6eda\u52a8\u6761\u4f4d\u7f6e");
})();
/**
 * @author {FlashSoft}
 */
/**
 * \u83b7\u53d6\u9875\u9762\u7684\u5e26\u6eda\u52a8\u6761\u7684\u9ad8\u5bbd\u4ee5\u53ca\u663e\u793a\u533a\u57df\u9ad8\u5bbd
 * @private
 * @return {Array} \u5206\u522b\u4e3a\u7a97\u53e3\u5e26\u6eda\u52a8\u6761\u5bbd\u9ad8\u8ddf\u663e\u793a\u533a\u57df\u5bbd\u9ad8
 * @author FlashSoft | fangchao@staff.sina.com.cn
 */
(function () {
	var getPageSize = function (){
		var xScroll, yScroll, arrayPageSize, windowWidth, windowHeight, pageHeight, pageWidth;
		if (window.innerHeight && window.scrollMaxY) {
			xScroll = window.innerWidth + window.scrollMaxX;
			yScroll = window.innerHeight + window.scrollMaxY;
		}
		else if (document.body.scrollHeight > document.body.offsetHeight) { // all but Explorer Mac
			xScroll = document.body.scrollWidth;
			yScroll = document.body.scrollHeight;
		}
		else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
			xScroll = document.body.offsetWidth;
			yScroll = document.body.offsetHeight;
		}
		var windowWidth, windowHeight;
		if (self.innerHeight) { // all except Explorer
			windowWidth = self.innerWidth;
			windowHeight = self.innerHeight;
		}
		else
			if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
				windowWidth = document.documentElement.clientWidth;
				windowHeight = document.documentElement.clientHeight;
			}
			else
				if (document.body) { // other Explorers
					windowWidth = document.body.clientWidth;
					windowHeight = document.body.clientHeight;
				}
		// for small pages with total height less then height of the viewport
		if (yScroll < windowHeight) {
			pageHeight = windowHeight;
		}
		else {
			pageHeight = yScroll;
		}
		// for small pages with total width less then width of the viewport
		if (xScroll < windowWidth) {
			pageWidth = windowWidth;
		}
		else {
			pageWidth = xScroll;
		}
		arrayPageSize = new Array(pageWidth, pageHeight, windowWidth, windowHeight);
		return arrayPageSize;
	};
	regist("$getPageSize", "Sina.dom.getPageSize", getPageSize, "FlashSoft", "\u83b7\u53d6\u9875\u9762\u7684\u5e26\u6eda\u52a8\u6761\u7684\u9ad8\u5bbd\u4ee5\u53ca\u663e\u793a\u533a\u57df\u9ad8\u5bbd");
})();
/**
 * \u5728\u6307\u5b9a\u8282\u70b9\u4e0a\u7ed1\u5b9a\u76f8\u5e94\u7684\u4e8b\u4ef6
 * @method Sina.events.addEvent
 * @param {String} oElement \u9700\u8981\u7ed1\u5b9a\u7684\u8282\u70b9ID
 * @param {String} sType \u4e8b\u4ef6\u7684\u7c7b\u578b\u5982:click, mouseover
 * @param {Function} fHandler \u4e8b\u4ef6\u53d1\u751f\u65f6\u76f8\u5e94\u7684\u51fd\u6570
 * @update 08.07.29
 * @author Stan | chaoliang@staff.sina.com.cn
 *         FlashSoft | fangchao@staff.sina.com.cn
 * @example
 * 	//\u9f20\u6807\u70b9\u51fbtestEle\u5219alert "clicked"
 * 	Sina.events.addEvent("testEle", "click", function () {
 * 		alert("clicked");
 * 	});
 */
(function () {
	var addEvent;
	if(Sina.base.ie) {
		addEvent = function (oElement, sType, fHandler) {
			oElement = Sina.base.get(oElement);
			oElement.attachEvent("on" + sType, fHandler);
		};
	}
	else {
		addEvent = function (oElement, sType, fHandler, bUseCapture) {
			oElement = Sina.base.get(oElement);
			if(bUseCapture == "undefined") {
				bUseCapture = false;
			}
			oElement.addEventListener(sType, fHandler, bUseCapture);
		};
	}
	regist("$addEvent", "Sina.events.addEvent", addEvent, "FlashSoft", "\u5728\u6307\u5b9a\u8282\u70b9\u4e0a\u7ed1\u5b9a\u76f8\u5e94\u7684\u4e8b\u4ef6");
})();
/**
 * \u5728\u6307\u5b9a\u8282\u70b9\u4e0a\u7ed1\u5b9a\u76f8\u5e94\u7684\u4e8b\u4ef6
 * @method Sina.events.addEvent
 * @param {String} oElement \u9700\u8981\u7ed1\u5b9a\u7684\u8282\u70b9ID
 * @param {String} sType \u4e8b\u4ef6\u7684\u7c7b\u578b\u5982:click, mouseover
 * @param {Function} fHandler \u4e8b\u4ef6\u53d1\u751f\u65f6\u76f8\u5e94\u7684\u51fd\u6570
 * @update 08.07.29
 * @author Stan | chaoliang@staff.sina.com.cn
 *         FlashSoft | fangchao@staff.sina.com.cn
 * @example
 * 	//\u9f20\u6807\u70b9\u51fbtestEle\u5219alert "clicked"
 * 	Sina.events.addEvent("testEle", "click", function () {
 * 		alert("clicked");
 * 	});
 */
(function () {
	var removeEvent;
	if(Sina.base.ie) {
		removeEvent = function (oElement, sType, fHandler) {
			oElement = Sina.base.get(oElement);
			oElement.detachEvent("on" + sType, fHandler);
		};
	}
	else {
		removeEvent = function (oElement, sType, fHandler, bUseCapture) {
			oElement = Sina.base.get(oElement);
			oElement.removeEventListener(sType, fHandler, false);
		};
	}
	regist("$removeEvent", "Sina.events.removeEvent", removeEvent, "FlashSoft", "\u5728\u6307\u5b9a\u8282\u70b9\u4e0a\u7ed1\u5b9a\u76f8\u5e94\u7684\u4e8b\u4ef6");
})();
/**
 * \u57fa\u4e8eJavascript\u7684Flash\u5a92\u4f53\u7248\u672c\u68c0\u6d4b\u4e0e\u5d4c\u5165\u6a21\u5757 SWFObject v2.1
 * @author {\u8001\u5916..}
 * @desc
 *		\u5b98\u65b9\uff1ahttp://code.google.com/p/swfobject/
 *		1.5\u4e2d\u6587\u6587\u6863\uff1a http://www.awflasher.com/flash/articles/swfobj.htm
 * @update 2008-8-7
 */
(function () {
/*! SWFObject v2.1 <http://code.google.com/p/swfobject/>
	Copyright (c) 2007-2008 Geoff Stearns, Michael Williams, and Bobby van der Sluis
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
*/
var swfobject = function() {
	var UNDEF = "undefined",
		OBJECT = "object",
		SHOCKWAVE_FLASH = "Shockwave Flash",
		SHOCKWAVE_FLASH_AX = "ShockwaveFlash.ShockwaveFlash",
		FLASH_MIME_TYPE = "application/x-shockwave-flash",
		EXPRESS_INSTALL_ID = "SWFObjectExprInst",
		win = window,
		doc = document,
		nav = navigator,
		domLoadFnArr = [],
		regObjArr = [],
		objIdArr = [],
		listenersArr = [],
		script,
		timer = null,
		storedAltContent = null,
		storedAltContentId = null,
		isDomLoaded = false,
		isExpressInstallActive = false;
	/* Centralized function for browser feature detection
		- Proprietary feature detection (conditional compiling) is used to detect Internet Explorer's features
		- User agent string detection is only used when no alternative is possible
		- Is executed directly for optimal performance
	*/
	var ua = function() {
		var w3cdom = typeof doc.getElementById != UNDEF && typeof doc.getElementsByTagName != UNDEF && typeof doc.createElement != UNDEF,
			playerVersion = [0,0,0],
			d = null;
		if (typeof nav.plugins != UNDEF && typeof nav.plugins[SHOCKWAVE_FLASH] == OBJECT) {
			d = nav.plugins[SHOCKWAVE_FLASH].description;
			if (d && !(typeof nav.mimeTypes != UNDEF && nav.mimeTypes[FLASH_MIME_TYPE] && !nav.mimeTypes[FLASH_MIME_TYPE].enabledPlugin)) { // navigator.mimeTypes["application/x-shockwave-flash"].enabledPlugin indicates whether plug-ins are enabled or disabled in Safari 3+
				d = d.replace(/^.*\s+(\S+\s+\S+$)/, "$1");
				playerVersion[0] = parseInt(d.replace(/^(.*)\..*$/, "$1"), 10);
				playerVersion[1] = parseInt(d.replace(/^.*\.(.*)\s.*$/, "$1"), 10);
				playerVersion[2] = /r/.test(d) ? parseInt(d.replace(/^.*r(.*)$/, "$1"), 10) : 0;
			}
		}
		else if (typeof win.ActiveXObject != UNDEF) {
			var a = null, fp6Crash = false;
			try {
				a = new ActiveXObject(SHOCKWAVE_FLASH_AX + ".7");
			}
			catch(e) {
				try {
					a = new ActiveXObject(SHOCKWAVE_FLASH_AX + ".6");
					playerVersion = [6,0,21];
					a.AllowScriptAccess = "always";	 // Introduced in fp6.0.47
				}
				catch(e) {
					if (playerVersion[0] == 6) {
						fp6Crash = true;
					}
				}
				if (!fp6Crash) {
					try {
						a = new ActiveXObject(SHOCKWAVE_FLASH_AX);
					}
					catch(e) {}
				}
			}
			if (!fp6Crash && a) { // a will return null when ActiveX is disabled
				try {
					d = a.GetVariable("$version");	// Will crash fp6.0.21/23/29
					if (d) {
						d = d.split(" ")[1].split(",");
						playerVersion = [parseInt(d[0], 10), parseInt(d[1], 10), parseInt(d[2], 10)];
					}
				}
				catch(e) {}
			}
		}
		var u = nav.userAgent.toLowerCase(),
			p = nav.platform.toLowerCase(),
			webkit = /webkit/.test(u) ? parseFloat(u.replace(/^.*webkit\/(\d+(\.\d+)?).*$/, "$1")) : false, // returns either the webkit version or false if not webkit
			ie = false,
			windows = p ? /win/.test(p) : /win/.test(u),
			mac = p ? /mac/.test(p) : /mac/.test(u);
		/*@cc_on
			ie = true;
			@if (@_win32)
				windows = true;
			@elif (@_mac)
				mac = true;
			@end
		@*/
		return { w3cdom:w3cdom, pv:playerVersion, webkit:webkit, ie:ie, win:windows, mac:mac };
	}();
	/* Cross-browser onDomLoad
		- Based on Dean Edwards' solution: http://dean.edwards.name/weblog/2006/06/again/
		- Will fire an event as soon as the DOM of a page is loaded (supported by Gecko based browsers - like Firefox -, IE, Opera9+, Safari)
	*/
	var onDomLoad = function() {
		if (!ua.w3cdom) {
			return;
		}
		addDomLoadEvent(main);
		if (ua.ie && ua.win) {
			// \u65b0\u589e\u5904\u7406\u5224\u65ad By FlashSoft
			var rnd = parseInt(Math.random() * 10000, 10);
			try {	 // Avoid a possible Operation Aborted error
				doc.write("<scr" + "ipt id=__ie_ondomload_" + rnd + " defer=true src='javascript:void(0)'></scr" + "ipt>"); // String is split into pieces to avoid Norton AV to add code that can cause errors
				script = getElementById("__ie_ondomload_" + rnd);
				if (script) {
					addListener(script, "onreadystatechange", checkReadyState);
				}
			}
			catch(e) {}
		}
		if (ua.webkit && typeof doc.readyState != UNDEF) {
			timer = setInterval(function() { if (/loaded|complete/.test(doc.readyState)) { callDomLoadFunctions(); }}, 10);
		}
		if (typeof doc.addEventListener != UNDEF) {
			doc.addEventListener("DOMContentLoaded", callDomLoadFunctions, null);
		}
		addLoadEvent(callDomLoadFunctions);
	}();
	function checkReadyState() {
		if (script.readyState == "complete") {
			script.parentNode.removeChild(script);
			callDomLoadFunctions();
		}
	}
	function callDomLoadFunctions() {
		if (isDomLoaded) {
			return;
		}
		if (ua.ie && ua.win) { // Test if we can really add elements to the DOM; we don't want to fire it too early
			var s = createElement("span");
			try { // Avoid a possible Operation Aborted error
				var t = doc.getElementsByTagName("body")[0].appendChild(s);
				t.parentNode.removeChild(t);
			}
			catch (e) {
				return;
			}
		}
		isDomLoaded = true;
		if (timer) {
			clearInterval(timer);
			timer = null;
		}
		var dl = domLoadFnArr.length;
		for (var i = 0; i < dl; i++) {
			domLoadFnArr[i]();
		}
	}
	function addDomLoadEvent(fn) {
		if (isDomLoaded) {
			fn();
		}
		else {
			domLoadFnArr[domLoadFnArr.length] = fn; // Array.push() is only available in IE5.5+
		}
	}
	/* Cross-browser onload
		- Based on James Edwards' solution: http://brothercake.com/site/resources/scripts/onload/
		- Will fire an event as soon as a web page including all of its assets are loaded
	 */
	function addLoadEvent(fn) {
		if (typeof win.addEventListener != UNDEF) {
			win.addEventListener("load", fn, false);
		}
		else if (typeof doc.addEventListener != UNDEF) {
			doc.addEventListener("load", fn, false);
		}
		else if (typeof win.attachEvent != UNDEF) {
			addListener(win, "onload", fn);
		}
		else if (typeof win.onload == "function") {
			var fnOld = win.onload;
			win.onload = function() {
				fnOld();
				fn();
			};
		}
		else {
			win.onload = fn;
		}
	}
	/* Main function
		- Will preferably execute onDomLoad, otherwise onload (as a fallback)
	*/
	function main() { // Static publishing only
		var rl = regObjArr.length;
		for (var i = 0; i < rl; i++) { // For each registered object element
			var id = regObjArr[i].id;
			if (ua.pv[0] > 0) {
				var obj = getElementById(id);
				if (obj) {
					regObjArr[i].width = obj.getAttribute("width") ? obj.getAttribute("width") : "0";
					regObjArr[i].height = obj.getAttribute("height") ? obj.getAttribute("height") : "0";
					if (hasPlayerVersion(regObjArr[i].swfVersion)) { // Flash plug-in version >= Flash content version: Houston, we have a match!
						if (ua.webkit && ua.webkit < 312) { // Older webkit engines ignore the object element's nested param elements
							fixParams(obj);
						}
						setVisibility(id, true);
					}
					else if (regObjArr[i].expressInstall && !isExpressInstallActive && hasPlayerVersion("6.0.65") && (ua.win || ua.mac)) { // Show the Adobe Express Install dialog if set by the web page author and if supported (fp6.0.65+ on Win/Mac OS only)
						showExpressInstall(regObjArr[i]);
					}
					else { // Flash plug-in and Flash content version mismatch: display alternative content instead of Flash content
						displayAltContent(obj);
					}
				}
			}
			else {	// If no fp is installed, we let the object element do its job (show alternative content)
				setVisibility(id, true);
			}
		}
	}
	/* Fix nested param elements, which are ignored by older webkit engines
		- This includes Safari up to and including version 1.2.2 on Mac OS 10.3
		- Fall back to the proprietary embed element
	*/
	function fixParams(obj) {
		var nestedObj = obj.getElementsByTagName(OBJECT)[0];
		if (nestedObj) {
			var e = createElement("embed"), a = nestedObj.attributes;
			if (a) {
				var al = a.length;
				for (var i = 0; i < al; i++) {
					if (a[i].nodeName == "DATA") {
						e.setAttribute("src", a[i].nodeValue);
					}
					else {
						e.setAttribute(a[i].nodeName, a[i].nodeValue);
					}
				}
			}
			var c = nestedObj.childNodes;
			if (c) {
				var cl = c.length;
				for (var j = 0; j < cl; j++) {
					if (c[j].nodeType == 1 && c[j].nodeName == "PARAM") {
						e.setAttribute(c[j].getAttribute("name"), c[j].getAttribute("value"));
					}
				}
			}
			obj.parentNode.replaceChild(e, obj);
		}
	}
	/* Show the Adobe Express Install dialog
		- Reference: http://www.adobe.com/cfusion/knowledgebase/index.cfm?id=6a253b75
	*/
	function showExpressInstall(regObj) {
		isExpressInstallActive = true;
		var obj = getElementById(regObj.id);
		if (obj) {
			if (regObj.altContentId) {
				var ac = getElementById(regObj.altContentId);
				if (ac) {
					storedAltContent = ac;
					storedAltContentId = regObj.altContentId;
				}
			}
			else {
				storedAltContent = abstractAltContent(obj);
			}
			if (!(/%$/.test(regObj.width)) && parseInt(regObj.width, 10) < 310) {
				regObj.width = "310";
			}
			if (!(/%$/.test(regObj.height)) && parseInt(regObj.height, 10) < 137) {
				regObj.height = "137";
			}
			doc.title = doc.title.slice(0, 47) + " - Flash Player Installation";
			var pt = ua.ie && ua.win ? "ActiveX" : "PlugIn",
				dt = doc.title,
				fv = "MMredirectURL=" + win.location + "&MMplayerType=" + pt + "&MMdoctitle=" + dt,
				replaceId = regObj.id;
			// For IE when a SWF is loading (AND: not available in cache) wait for the onload event to fire to remove the original object element
			// In IE you cannot properly cancel a loading SWF file without breaking browser load references, also obj.onreadystatechange doesn't work
			if (ua.ie && ua.win && obj.readyState != 4) {
				var newObj = createElement("div");
				replaceId += "SWFObjectNew";
				newObj.setAttribute("id", replaceId);
				obj.parentNode.insertBefore(newObj, obj); // Insert placeholder div that will be replaced by the object element that loads expressinstall.swf
				obj.style.display = "none";
				var fn = function() {
					obj.parentNode.removeChild(obj);
				};
				addListener(win, "onload", fn);
			}
			createSWF({ data:regObj.expressInstall, id:EXPRESS_INSTALL_ID, width:regObj.width, height:regObj.height }, { flashvars:fv }, replaceId);
		}
	}
	/* Functions to abstract and display alternative content
	*/
	function displayAltContent(obj) {
		if (ua.ie && ua.win && obj.readyState != 4) {
			// For IE when a SWF is loading (AND: not available in cache) wait for the onload event to fire to remove the original object element
			// In IE you cannot properly cancel a loading SWF file without breaking browser load references, also obj.onreadystatechange doesn't work
			var el = createElement("div");
			obj.parentNode.insertBefore(el, obj); // Insert placeholder div that will be replaced by the alternative content
			el.parentNode.replaceChild(abstractAltContent(obj), el);
			obj.style.display = "none";
			var fn = function() {
				obj.parentNode.removeChild(obj);
			};
			addListener(win, "onload", fn);
		}
		else {
			obj.parentNode.replaceChild(abstractAltContent(obj), obj);
		}
	}
	function abstractAltContent(obj) {
		var ac = createElement("div");
		if (ua.win && ua.ie) {
			ac.innerHTML = obj.innerHTML;
		}
		else {
			var nestedObj = obj.getElementsByTagName(OBJECT)[0];
			if (nestedObj) {
				var c = nestedObj.childNodes;
				if (c) {
					var cl = c.length;
					for (var i = 0; i < cl; i++) {
						if (!(c[i].nodeType == 1 && c[i].nodeName == "PARAM") && !(c[i].nodeType == 8)) {
							ac.appendChild(c[i].cloneNode(true));
						}
					}
				}
			}
		}
		return ac;
	}
	/* Cross-browser dynamic SWF creation
	*/
	function createSWF(attObj, parObj, id) {
		var r, el = getElementById(id);
		if (el) {
			if (typeof attObj.id == UNDEF) { // if no 'id' is defined for the object element, it will inherit the 'id' from the alternative content
				attObj.id = id;
			}
			if (ua.ie && ua.win) { // IE, the object element and W3C DOM methods do not combine: fall back to outerHTML
				var att = "";
				for (var i in attObj) {
					if (attObj[i] != Object.prototype[i]) { // Filter out prototype additions from other potential libraries, like Object.prototype.toJSONString = function() {}
						if (i.toLowerCase() == "data") {
							parObj.movie = attObj[i];
						}
						else if (i.toLowerCase() == "styleclass") { // 'class' is an ECMA4 reserved keyword
							att += ' class="' + attObj[i] + '"';
						}
						else if (i.toLowerCase() != "classid") {
							att += ' ' + i + '="' + attObj[i] + '"';
						}
					}
				}
				var par = "";
				for (var j in parObj) {
					if (parObj[j] != Object.prototype[j]) { // Filter out prototype additions from other potential libraries
						par += '<param name="' + j + '" value="' + parObj[j] + '" />';
					}
				}
				el.outerHTML = '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"' + att + '>' + par + '</object>';
				objIdArr[objIdArr.length] = attObj.id; // Stored to fix object 'leaks' on unload (dynamic publishing only)
				r = getElementById(attObj.id);
			}
			else if (ua.webkit && ua.webkit < 312) { // Older webkit engines ignore the object element's nested param elements: fall back to the proprietary embed element
				var e = createElement("embed");
				e.setAttribute("type", FLASH_MIME_TYPE);
				for (var k in attObj) {
					if (attObj[k] != Object.prototype[k]) { // Filter out prototype additions from other potential libraries
						if (k.toLowerCase() == "data") {
							e.setAttribute("src", attObj[k]);
						}
						else if (k.toLowerCase() == "styleclass") { // 'class' is an ECMA4 reserved keyword
							e.setAttribute("class", attObj[k]);
						}
						else if (k.toLowerCase() != "classid") { // Filter out IE specific attribute
							e.setAttribute(k, attObj[k]);
						}
					}
				}
				for (var l in parObj) {
					if (parObj[l] != Object.prototype[l]) { // Filter out prototype additions from other potential libraries
						if (l.toLowerCase() != "movie") { // Filter out IE specific param element
							e.setAttribute(l, parObj[l]);
						}
					}
				}
				el.parentNode.replaceChild(e, el);
				r = e;
			}
			else { // Well-behaving browsers
				var o = createElement(OBJECT);
				o.setAttribute("type", FLASH_MIME_TYPE);
				for (var m in attObj) {
					if (attObj[m] != Object.prototype[m]) { // Filter out prototype additions from other potential libraries
						if (m.toLowerCase() == "styleclass") { // 'class' is an ECMA4 reserved keyword
							o.setAttribute("class", attObj[m]);
						}
						else if (m.toLowerCase() != "classid") { // Filter out IE specific attribute
							o.setAttribute(m, attObj[m]);
						}
					}
				}
				for (var n in parObj) {
					if (parObj[n] != Object.prototype[n] && n.toLowerCase() != "movie") { // Filter out prototype additions from other potential libraries and IE specific param element
						createObjParam(o, n, parObj[n]);
					}
				}
				el.parentNode.replaceChild(o, el);
				r = o;
			}
		}
		return r;
	}
	function createObjParam(el, pName, pValue) {
		var p = createElement("param");
		p.setAttribute("name", pName);
		p.setAttribute("value", pValue);
		el.appendChild(p);
	}
	/* Cross-browser SWF removal
		- Especially needed to safely and completely remove a SWF in Internet Explorer
	*/
	function removeSWF(id) {
		var obj = getElementById(id);
		if (obj && (obj.nodeName == "OBJECT" || obj.nodeName == "EMBED")) {
			if (ua.ie && ua.win) {
				if (obj.readyState == 4) {
					removeObjectInIE(id);
				}
				else {
					win.attachEvent("onload", function() {
						removeObjectInIE(id);
					});
				}
			}
			else {
				obj.parentNode.removeChild(obj);
			}
		}
	}
	function removeObjectInIE(id) {
		var obj = getElementById(id);
		if (obj) {
			for (var i in obj) {
				if (typeof obj[i] == "function") {
					obj[i] = null;
				}
			}
			obj.parentNode.removeChild(obj);
		}
	}
	/* Functions to optimize JavaScript compression
	*/
	function getElementById(id) {
		var el = null;
		try {
			el = doc.getElementById(id);
		}
		catch (e) {}
		return el;
	}
	function createElement(el) {
		return doc.createElement(el);
	}
	/* Updated attachEvent function for Internet Explorer
		- Stores attachEvent information in an Array, so on unload the detachEvent functions can be called to avoid memory leaks
	*/
	function addListener(target, eventType, fn) {
		target.attachEvent(eventType, fn);
		listenersArr[listenersArr.length] = [target, eventType, fn];
	}
	/* Flash Player and SWF content version matching
	*/
	function hasPlayerVersion(rv) {
		var pv = ua.pv, v = rv.split(".");
		v[0] = parseInt(v[0], 10);
		v[1] = parseInt(v[1], 10) || 0; // supports short notation, e.g. "9" instead of "9.0.0"
		v[2] = parseInt(v[2], 10) || 0;
		return (pv[0] > v[0] || (pv[0] == v[0] && pv[1] > v[1]) || (pv[0] == v[0] && pv[1] == v[1] && pv[2] >= v[2])) ? true : false;
	}
	/* Cross-browser dynamic CSS creation
		- Based on Bobby van der Sluis' solution: http://www.bobbyvandersluis.com/articles/dynamicCSS.php
	*/
	function createCSS(sel, decl) {
		if (ua.ie && ua.mac) {
			return;
		}
		var h = doc.getElementsByTagName("head")[0], s = createElement("style");
		s.setAttribute("type", "text/css");
		s.setAttribute("media", "screen");
		if (!(ua.ie && ua.win) && typeof doc.createTextNode != UNDEF) {
			s.appendChild(doc.createTextNode(sel + " {" + decl + "}"));
		}
		h.appendChild(s);
		if (ua.ie && ua.win && typeof doc.styleSheets != UNDEF && doc.styleSheets.length > 0) {
			var ls = doc.styleSheets[doc.styleSheets.length - 1];
			if (typeof ls.addRule == OBJECT) {
				ls.addRule(sel, decl);
			}
		}
	}
	function setVisibility(id, isVisible) {
		var v = isVisible ? "visible" : "hidden";
		if (isDomLoaded && getElementById(id)) {
			getElementById(id).style.visibility = v;
		}
		else {
			createCSS("#" + id, "visibility:" + v);
		}
	}
	/* Filter to avoid XSS attacks
	*/
	function urlEncodeIfNecessary(s) {
		var regex = /[\\\"<>\.;]/;
		var hasBadChars = regex.exec(s) != null;
		return hasBadChars ? encodeURIComponent(s) : s;
	}
	/* Release memory to avoid memory leaks caused by closures, fix hanging audio/video threads and force open sockets/NetConnections to disconnect (Internet Explorer only)
	*/
	var cleanup = function() {
		if (ua.ie && ua.win) {
			window.attachEvent("onunload", function() {
				// remove listeners to avoid memory leaks
				var ll = listenersArr.length;
				for (var i = 0; i < ll; i++) {
					listenersArr[i][0].detachEvent(listenersArr[i][1], listenersArr[i][2]);
				}
				// cleanup dynamically embedded objects to fix audio/video threads and force open sockets and NetConnections to disconnect
				var il = objIdArr.length;
				for (var j = 0; j < il; j++) {
					removeSWF(objIdArr[j]);
				}
				// cleanup library's main closures to avoid memory leaks
				for (var k in ua) {
					ua[k] = null;
				}
				ua = null;
				for (var l in swfobject) {
					swfobject[l] = null;
				}
				swfobject = null;
			});
		}
	}();
	return {
		/* Public API
			- Reference: http://code.google.com/p/swfobject/wiki/SWFObject_2_0_documentation
		*/
		registerObject: function(objectIdStr, swfVersionStr, xiSwfUrlStr) {
			if (!ua.w3cdom || !objectIdStr || !swfVersionStr) {
				return;
			}
			var regObj = {};
			regObj.id = objectIdStr;
			regObj.swfVersion = swfVersionStr;
			regObj.expressInstall = xiSwfUrlStr ? xiSwfUrlStr : false;
			regObjArr[regObjArr.length] = regObj;
			setVisibility(objectIdStr, false);
		},
		getObjectById: function(objectIdStr) {
			var r = null;
			if (ua.w3cdom) {
				var o = getElementById(objectIdStr);
				if (o) {
					var n = o.getElementsByTagName(OBJECT)[0];
					if (!n || (n && typeof o.SetVariable != UNDEF)) {
							r = o;
					}
					else if (typeof n.SetVariable != UNDEF) {
						r = n;
					}
				}
			}
			return r;
		},
		embedSWF: function(swfUrlStr, replaceElemIdStr, widthStr, heightStr, swfVersionStr, xiSwfUrlStr, flashvarsObj, parObj, attObj) {
			if (!ua.w3cdom || !swfUrlStr || !replaceElemIdStr || !widthStr || !heightStr || !swfVersionStr) {
				return;
			}
			widthStr += ""; // Auto-convert to string
			heightStr += "";
			if (hasPlayerVersion(swfVersionStr)) {
				setVisibility(replaceElemIdStr, false);
				var att = {};
				if (attObj && typeof attObj === OBJECT) {
					for (var i in attObj) {
						if (attObj[i] != Object.prototype[i]) { // Filter out prototype additions from other potential libraries
							att[i] = attObj[i];
						}
					}
				}
				att.data = swfUrlStr;
				att.width = widthStr;
				att.height = heightStr;
				var par = {};
				if (parObj && typeof parObj === OBJECT) {
					for (var j in parObj) {
						if (parObj[j] != Object.prototype[j]) { // Filter out prototype additions from other potential libraries
							par[j] = parObj[j];
						}
					}
				}
				if (flashvarsObj && typeof flashvarsObj === OBJECT) {
					for (var k in flashvarsObj) {
						if (flashvarsObj[k] != Object.prototype[k]) { // Filter out prototype additions from other potential libraries
							if (typeof par.flashvars != UNDEF) {
								par.flashvars += "&" + k + "=" + flashvarsObj[k];
							}
							else {
								par.flashvars = k + "=" + flashvarsObj[k];
							}
						}
					}
				}
				addDomLoadEvent(function() {
					createSWF(att, par, replaceElemIdStr);
					if (att.id == replaceElemIdStr) {
						setVisibility(replaceElemIdStr, true);
					}
				});
			}
			else if (xiSwfUrlStr && !isExpressInstallActive && hasPlayerVersion("6.0.65") && (ua.win || ua.mac)) {
				isExpressInstallActive = true; // deferred execution
				setVisibility(replaceElemIdStr, false);
				addDomLoadEvent(function() {
					var regObj = {};
					regObj.id = regObj.altContentId = replaceElemIdStr;
					regObj.width = widthStr;
					regObj.height = heightStr;
					regObj.expressInstall = xiSwfUrlStr;
					showExpressInstall(regObj);
				});
			}
		},
		getFlashPlayerVersion: function() {
			return { major:ua.pv[0], minor:ua.pv[1], release:ua.pv[2] };
		},
		hasFlashPlayerVersion: hasPlayerVersion,
		createSWF: function(attObj, parObj, replaceElemIdStr) {
			if (ua.w3cdom) {
				return createSWF(attObj, parObj, replaceElemIdStr);
			}
			else {
				return undefined;
			}
		},
		removeSWF: function(objElemIdStr) {
			if (ua.w3cdom) {
				removeSWF(objElemIdStr);
			}
		},
		createCSS: function(sel, decl) {
			if (ua.w3cdom) {
				createCSS(sel, decl);
			}
		},
		addDomLoadEvent: addDomLoadEvent,
		addLoadEvent: addLoadEvent,
		getQueryParamValue: function(param) {
			var q = doc.location.search || doc.location.hash;
			if (param == null) {
				return urlEncodeIfNecessary(q);
			}
			if (q) {
				var pairs = q.substring(1).split("&");
				for (var i = 0; i < pairs.length; i++) {
					if (pairs[i].substring(0, pairs[i].indexOf("=")) == param) {
						return urlEncodeIfNecessary(pairs[i].substring((pairs[i].indexOf("=") + 1)));
					}
				}
			}
			return "";
		},
		// For internal usage only
		expressInstallCallback: function() {
			if (isExpressInstallActive && storedAltContent) {
				var obj = getElementById(EXPRESS_INSTALL_ID);
				if (obj) {
					obj.parentNode.replaceChild(storedAltContent, obj);
					if (storedAltContentId) {
						setVisibility(storedAltContentId, true);
						if (ua.ie && ua.win) {
							storedAltContent.style.display = "block";
						}
					}
					storedAltContent = null;
					storedAltContentId = null;
					isExpressInstallActive = false;
				}
			}
		}
	};
}();
	var SwfView = {
		/**
		 *  swfobject \u7c7b\u5f15\u7528
		 */
		swfobject : swfobject,
		/**
		 *  \u9700\u8981\u5448\u73b0\u7684SWF\u5217\u8868
		 */
		swfList: new Array(),
		/**
		 * \u6dfb\u52a0\u65b9\u6cd5
		 * @param {String} Swf file url
		 * @param {HTMLElement} \u7236\u5bb9\u5668
		 * @param {String}  \u9ad8
		 * @param {String}  \u5bbd
		 * @param {String}  \u7248\u672c\u53f7
		 * @param {String}  (\u5b89\u88c5\u5411\u5bfcexpressInstall.swf\u6587\u4ef6\u8def\u5f84)
		 * @param {Object} FlashVars \u53c2\u6570
		 * @param {Object} Flash \u5bf9\u8c61\u7684\u53c2\u6570
		 * @param {Object} Flash \u5bf9\u8c61\u7684\u5c5e\u6027
		 * @author xs | zhenhua1@staff.sina.com.cn
		 * @update FlashSoft | fangchao@staff.sina.com.cn
		 *         08.10.13
		 * @example
		 * 			Sina.util.Swf.Add("test.swf", "swfBox", "200", "100");
		 */
		Add: function (sURL, sID, nWidth, nHeight, nVersion, sExpressInstall, oVar, oParam, oAtts, bAuto) {
			if(sURL && sID) {
				this.swfList[this.swfList.length] = {
					sURL: sURL,
					sID: sID,
					nWidth: nWidth,
					nHeight: nHeight,
					nVersion: nVersion || "9.0.0",
					sExpressInstall: sExpressInstall || "expressInstall.swf",
					oVar: oVar,
					oParam: oParam,
					oAtts: oAtts
				};
				if(bAuto){
					this.Init();
				}
			}
			return SwfView;
		},
		/**
		 * \u6267\u884c\u521d\u59cb\u5316
		 * @author xs | zhenhua1@staff.sina.com.cn
		 * @update FlashSoft | fangchao@staff.sina.com.cn
		 *         08.10.13
		 */
		Init: function () {
			var list = this.swfList;
			for(var i = 0; i < list.length; i ++) {
				this.swfobject.embedSWF(list[i]["sURL"], list[i]["sID"], list[i]["nWidth"], list[i]["nHeight"], list[i]["nVersion"], list[i]["sExpressInstall"], list[i]["oVar"], list[i]["oParam"], list[i]["oAtts"]);
			}
			list = new Array();
			return SwfView;
		}
	};
	regist("$Swf", "Sina.util.Swf", SwfView, "xs", "\u57fa\u4e8eJavascript\u7684Flash\u5a92\u4f53\u7248\u672c\u68c0\u6d4b\u4e0e\u5d4c\u5165\u6a21\u5757 SWFObject v2.1 \u7684\u4e8c\u6b21\u5c01\u88c5");
})();
(function () {
	//-- \u57fa\u7840Lib\u5305 ----------------------------------------------------------------
/**
 * \u8fd4\u56de\u95ed\u5305\u51fd\u6570\u5f15\u7528,\u652f\u6301\u4f20\u9012\u53d8\u91cf
 * @method Sina.base.bind
 * @param {Function} method \u672c\u4f53\u51fd\u6570
 * @param {Object} object this\u6307\u9488
 * @param {Array} args \u6570\u7ec4\u53c2\u6570
 * @author FlashSoft | fangchao@staff.sina.com.cn
 * @update 08.08.02
 * @example
 * 	var img = document.createElement("img");
 * 	var func = function (a, b) {
 * 		alert(a);
 * 	};
 * 	var index = 1;
 * 	Sina.events.addEvent(img, "click", Sina.base.bind(func, this, [index, 2]);
 */
(function () {
	var bind;
	bind = function(method, object, args) {
		args = args == null? []: args;
		return function() {
		  method.apply(object, args);
		};
	};
	regist("$bind", "Sina.base.bind", bind, "FlashSoft", "\u8fd4\u56de\u4e00\u4e2a\u95ed\u5305\u5f15\u7528,\u5141\u8bb8\u4f20\u53d8\u91cf");
})();
	eval(regist.bindTo());
	// --------------------------------------------------------------------------------
	var transitions = {
		simple: function(time, startValue, changeValue, duration){
			return changeValue * time / duration + startValue;
		},
		backEaseIn: function(t, b, c, d){
			var s = 1.70158;
			return c * (t /= d) * t * ((s + 1) * t - s) + b;
		},
		backEaseOut: function(t, b, c, d, a, p){
			var s = 1.70158;
			return c * ((t = t / d - 1) * t * ((s + 1) * t + s) + 1) + b;
		},
		backEaseInOut: function(t, b, c, d, a, p){
			var s = 1.70158;
			if ((t /= d / 2) < 1) {
				return c / 2 * (t * t * (((s *= (1.525)) + 1) * t - s)) + b;
			}
			return c / 2 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2) + b;
		},
		bounceEaseOut: function(t, b, c, d){
			if ((t /= d) < (1 / 2.75)) {
				return c * (7.5625 * t * t) + b;
			}
			else
				if (t < (2 / 2.75)) {
					return c * (7.5625 * (t -= (1.5 / 2.75)) * t + .75) + b;
				}
				else
					if (t < (2.5 / 2.75)) {
						return c * (7.5625 * (t -= (2.25 / 2.75)) * t + .9375) + b;
					}
					else {
						return c * (7.5625 * (t -= (2.625 / 2.75)) * t + .984375) + b;
					}
		},
		bounceEaseIn: function(t, b, c, d){
			return c - transitions.bounceEaseOut(d - t, 0, c, d) + b;
		},
		bounceEaseInOut: function(t, b, c, d){
			if (t < d / 2) {
				return transitions.bounceEaseIn(t * 2, 0, c, d) * .5 + b;
			}
			else {
				return transitions.bounceEaseOut(t * 2 - d, 0, c, d) * .5 + c * .5 + b;
			}
		},
		strongEaseInOut: function(t, b, c, d){
			return c * (t /= d) * t * t * t * t + b;
		},
		regularEaseIn: function(t, b, c, d){
			return c * (t /= d) * t + b;
		},
		regularEaseOut: function(t, b, c, d){
			return -c * (t /= d) * (t - 2) + b;
		},
		regularEaseInOut: function(t, b, c, d){
			if ((t /= d / 2) < 1) {
				return c / 2 * t * t + b;
			}
			return -c / 2 * ((--t) * (t - 2) - 1) + b;
		},
		strongEaseIn: function(t, b, c, d){
			return c * (t /= d) * t * t * t * t + b;
		},
		strongEaseOut: function(t, b, c, d){
			return c * ((t = t / d - 1) * t * t * t * t + 1) + b;
		},
		strongEaseInOut: function(t, b, c, d){
			if ((t /= d / 2) < 1) {
				return c / 2 * t * t * t * t * t + b;
			}
			return c / 2 * ((t -= 2) * t * t * t * t + 2) + b;
		},
		elasticEaseIn: function(t, b, c, d, a, p){
			if (t == 0) {
				return b;
			}
			if ((t /= d) == 1) {
				return b + c;
			}
			if (!p) {
				p = d * .3;
			}
			if (!a || a < Math.abs(c)) {
				a = c;
				var s = p / 4;
			}
			else {
				var s = p / (2 * Math.PI) * Math.asin(c / a);
			}
			return -(a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
		},
		elasticEaseOut: function(t, b, c, d, a, p){
			if (t == 0) {
				return b;
			}
			if ((t /= d) == 1) {
				return b + c;
			}
			if (!p) {
				p = d * .3;
			}
			if (!a || a < Math.abs(c)) {
				a = c;
				var s = p / 4;
			}
			else {
				var s = p / (2 * Math.PI) * Math.asin(c / a);
			}
			return (a * Math.pow(2, -10 * t) * Math.sin((t * d - s) * (2 * Math.PI) / p) + c + b);
		},
		elasticEaseInOut: function(t, b, c, d, a, p){
			if (t == 0) {
				return b;
			}
			if ((t /= d / 2) == 2) {
				return b + c;
			}
			if (!p) {
				var p = d * (.3 * 1.5);
			}
			if (!a || a < Math.abs(c)) {
				var a = c;
				var s = p / 4;
			}
			else {
				var s = p / (2 * Math.PI) * Math.asin(c / a);
			}
			if (t < 1) {
				return -.5 * (a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
			}
			return a * Math.pow(2, -10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p) * .5 + c + b;
		}
	};
	/**
	 * \u8fd4\u56de\u4e00\u4e2a\u968f\u673aID
	 * @param {HTMLNode} oNode
	 * @return {String}
	 */
	var getUniqueID = function (oNode) {
		return oNode.uniqueID;
	};
	if(!$ie) {
		getUniqueID = function (oNode) {
			try {
				var rnd_ID;
				if(oNode.getAttribute("uniqueID") == null) {
					rnd_ID = "moz__id" + parseInt(Math.random() * 100) + "_" + new Date().getTime();
					oNode.setAttribute("uniqueID", rnd_ID);
					return rnd_ID;
				}
				return oNode.getAttribute("uniqueID");
			}
			finally {
				rnd_ID = null;
			}
		};
	}
	/**
	 * \u8fd4\u56de\u5bf9\u8c61\u7684\u771f\u6b63\u7c7b\u578b
	 * @param {Object} oObject
	 * @return {String}
	 */
	function getType (oObject) {
		try {
			var s = oObject.constructor.toString().toLowerCase();
			return s.slice(s.indexOf("function") + 9, s.indexOf("()"));
		}
		finally {
			s = null;
		}
	}
	/**
	 * \u83b7\u53d6\u52a8\u753b\u5bf9\u8c61\u7684\u8d77\u59cb\u503c
	 * @param {Object} oNode \u52a8\u753b\u5bf9\u8c61
	 * @param {Array} aProperty \u8981\u53d6\u7684\u53c2\u6570\u6570\u7ec4
	 * @return {Array} \u5bf9\u8c61\u521d\u59cb\u503c\u7684\u6570\u7ec4
	 */
	function getStartValue (oNode, aProperty) {
		var i, _len, _arr = [];
		_len = aProperty.length;
		for(i = 0; i < _len; i ++ ) {
			_arr[_arr.length] = parseFloat($getStyle(oNode, aProperty[i]));
		}
		return _arr;
	}
	/**
	 * \u683c\u5f0f\u5316\u4f20\u5165\u53c2\u6570
	 * @param {Array | String} oProperty \u683c\u5f0f\u5316\u524d\u7684\u53c2\u6570
	 * @return {Array} \u683c\u5f0f\u5316\u540e\u7684\u53c2\u6570
	 */
	function formatProperty (oProperty) {
		return getType(oProperty) != "array"? [oProperty]: oProperty;
	}
	/**
	 * \u683c\u5f0f\u5316\u76ee\u6807\u503c\u7684\u6570\u7ec4
	 * @param {Array | String} oEndingValue \u76ee\u6807\u503c
	 * @param {Array} aProperty \u52a8\u753b\u5bf9\u8c61\u7684\u53c2\u6570\u6570\u7ec4
	 */
	function formatValue (oEndingValue, aProperty) {
		try {
			var _type = getType(oEndingValue);
			var _valuearray = [], _suffixarray = [], i, _len, _suffix;
			if(_type != "array") {
				_suffix = getSuffix(oEndingValue);
				_valuearray = [_suffix[0]];
				_suffixarray = [_suffix[1]];
			}
			else {
				_len = oEndingValue.length;
				for(i = 0; i < _len; i ++ ) {
					_suffix = getSuffix(oEndingValue[i]);
					_suffix[1] = aProperty[i] == "opacity"? "": _suffix[1];
					_valuearray[_valuearray.length] = _suffix[0];
					_suffixarray[_suffixarray.length] = _suffix[1];
				}
			}
			return [_valuearray, _suffixarray];
		}
		finally {
			_type = _valuearray = _suffixarray = i = _len = _suffix = null;
		}
	}
	/**
	 * \u5206\u6790\u6267\u884c\u7684\u5355\u4f4d\u5e76\u8fd4\u56de
	 * @param {String} sValue
	 * @return {Array} \u6570\u503c\u8ddf\u5355\u4f4d
	 */
	function getSuffix (sValue) {
		try {
			var charCase = /(-?\d.?\d*)([a-z%]*)/i.exec(sValue);
			return [charCase[1], charCase[2]? charCase[2]: "px"];
		}
		finally {
			charCase = null;
		}
	}
	var runList = {};
	var saveList = {};
	function getInstance (oNode) {
		try {
			var uID = getUniqueID(oNode);
			var runFunc;
			// \u5982\u679c\u6307\u5b9a\u7684\u5bf9\u8c61\u6ca1\u6709\u5728\u5b9e\u4f8b\u5bf9\u8c61\u5217\u8868\u4e2d
			if(runList[uID] != true) {
				runFunc = new ancestor();
				saveList[uID] = {
					node: oNode,
					func: runFunc
				};
				runList[uID] = true;
//				trace("\u521b\u5efa\u5b9e\u4f8b");
				return runFunc
			}
			// \u5982\u679c\u5728\u5219\u8fd4\u56de\u5b9e\u4f8b\u5bf9\u8c61
			else {
//				trace("\u5df2\u6709\u5b9e\u4f8b");
				return saveList[uID].func;
			}
		}
		finally {
			uID = runFunc = null;
		}
	}
	/**
	 * Tween\u7c7b\u7684\u7c7b
	 */
	function ancestor () {
		this._timer = null;
	}
	/**
	 * Tween\u7c7b\u7684Start\u65b9\u6cd5
	 * @param {Object} oNode \u9700\u8981\u52a8\u753b\u7684\u5bf9\u8c61
	 * @param {Array | String} oProperty \u8981\u64cd\u4f5c\u7684\u53c2\u6570
	 * @param {Array | String} oEndingValue \u76ee\u6807\u503c
	 * @param {Number} nSeconds \u8017\u65f6
	 * @param {String} sAnimation \u52a8\u753b\u7c7b\u578b
	 * @param {Object} oFunc \u56de\u8c03\u51fd\u6570
	 */
	ancestor.prototype.start = function (oNode, oProperty, oEndingValue, nSeconds, sAnimation , oFunc) {
		this.reset();
		oFunc = oFunc || {};
		if(oFunc.end) {
			this._func.end = oFunc.end;
		}
		if(oFunc.tween) {
			this._func.tween = oFunc.tween;
		}
		var _propertyArr = formatProperty(oProperty);
		var _startValueArr = getStartValue(oNode, _propertyArr);
		var _endValueArr = formatValue(oEndingValue, _propertyArr);
//		trace("\u5f00\u59cb:: \u8bbe\u5b9a\u53c2\u6570", {color: "#9f0"});
		this._node = oNode;
		this._property = _propertyArr;
		this._endingvalue = _endValueArr[0];
		this._suffixvalue = _endValueArr[1];
		this._startvalue = _startValueArr;
		this._end = false;
		this._fps = 0;
		/*
		trace("\u5bf9\u8c61:: " + this._node.id || "\u65e0ID\u540d\u79f0", {
			color: "#ff99cc"
		});
		trace("\u5c5e\u6027[" + getType(this._property) + "]:: " + this._property, {
			color: "#ff99cc"
		});
		trace("\u8d77\u59cb\u503c[" + getType(this._startvalue) + "]:: " + this._startvalue, {
			color: "#ff99cc"
		});
		trace("\u76ee\u6807\u503c[" + getType(this._endingvalue) + "]:: " + this._endingvalue, {
			color: "#ff99cc"
		});
		trace("\u5355\u4f4d[" + getType(this._suffixvalue) + "]:: " + this._suffixvalue, {
			color: "#ff99cc"
		});
		//*/
		if(nSeconds != null) {
			this._seconds = nSeconds;
		}
		if(transitions[sAnimation] != null) {
			this._animation = transitions[sAnimation];
		}
		this._starttime = new Date().getTime();
		this._timer = setInterval($bind(this.play, this), 10);
	};
	/**
	 * Tween\u7c7b\u7684paly\u65b9\u6cd5
	 */
	ancestor.prototype.play = function () {
		var nTime = (new Date().getTime() - this._starttime) / 1000;
		var i, ani, _len = this._property.length;
		if(nTime > this._seconds) {
			nTime = this._seconds;
		}
		for(i = 0; i < _len; i ++ ) {
			ani = this._animation(nTime, this._startvalue[i], this._endingvalue[i] - this._startvalue[i], this._seconds);
			$setStyle(this._node, this._property[i], ani + this._suffixvalue[i]);
			//trace(nTime + "|" + this._startvalue[i] + "|" + (this._endingvalue[i] + this._startvalue[i]) + "|" + this._seconds + "|" + ani);
		}
		this._fps ++;
		this._func.tween();
		if(nTime == this._seconds) {
			this.stop();
		}
		//trace("_________________________");
	};
	/**
	 * Tween\u7c7b\u7684stop\u65b9\u6cd5
	 */
	ancestor.prototype.stop = function () {
		clearInterval(this._timer);
		this._end = true;
		this._func.end();
//		trace("FPS:: " + parseInt(this._fps / this._seconds));
//		trace("\u505c\u6b62:: \u6e05\u7406\u5b9a\u65f6\u5668", {color: "red"});
	};
	/**
	 * Tween\u7c7b\u7684\u590d\u4f4d\u65b9\u6cd5
	 */
	ancestor.prototype.reset = function () {
//		trace("\u6e05\u7406:: \u6e05\u7406\u5e76\u521d\u59cb\u5316\u6570\u636e", {color: "yellow"});
		clearInterval(this._timer);
		this._end = false;
		/** \u5fc5\u9009\u53c2\u6570 */
		this._node = null;
		this._property = [];
		this._startvalue = [];
		this._endingvalue = [];
		this._suffixvalue = [];
		this._fps = 0;
		/** \u975e\u5fc5\u9009\u53c2\u6570 */
		this._seconds = .5;
		this._animation = transitions.simple;
		this._func = {
			end: function () {},
			tween: function () {}
		};
	};
	/**
	 * \u5bf9Tween\u7c7b\u7684\u9759\u6001\u5c01\u88c5,\u65b9\u4fbf\u8c03\u7528
	 * @param {Object} oNode \u9700\u8981\u52a8\u753b\u7684\u5bf9\u8c61
	 * @param {Array | String} oProperty \u8981\u64cd\u4f5c\u7684\u53c2\u6570
	 * @param {Array | String} oEndingValue \u76ee\u6807\u503c
	 * @param {Number} nSeconds \u8017\u65f6
	 * @param {String} sAnimation \u52a8\u753b\u7c7b\u578b
	 * @param {Object} oFunc \u56de\u8c03\u51fd\u6570
	 */
	function tween (oNode, oProperty, oEndingValue, nSeconds, sAnimation , oFunc) {
		var instance = getInstance(oNode);
		instance.start.apply(instance, arguments);
	}
	/**
	 * \u9759\u6001\u5c01\u88c5\u7684stop\u65b9\u6cd5
	 * @param {Object} oNode
	 */
	tween.stop = function (oNode) {
		getInstance(oNode).stop();
	};
	/**
	 * \u9759\u6001\u5c01\u88c5\u7684isTween\u65b9\u6cd5,\u5224\u65ad\u52a8\u753b\u662f\u5426\u7ed3\u675f
	 * @param {Object} oNode
	 */
	tween.isTween = function (oNode) {
		return !getInstance(oNode)._end;
	};
	regist("$tween", "Sina.utils.tween", tween, "FlashSoft", "\u52a8\u753b\u7c7b");
})();
/**
 * \u628a\u5b57\u7b26\u4e32\u8f6c\u5316\u6210JSON\u683c\u5f0f
 * @method Sina.string.toJson
 * @param {String} sStr \u5b57\u7b26\u4e32
 * @author FlashSoft | fangchao@staff.sina.com.cn
 * @update 08.08.27
 * @example
 * 	var s = {data: 1};
 * 	var o = Sina.string.toJson(s);
 *  alert(o.data);
 *  // \u8f93\u51fa\u7ed3\u679c\u4e3a1
 */
(function () {
	var toJson;
	toJson = function(sStr){
		try {
			var o = eval("(" + sStr + ")");
			return o;
		}
		finally {
			o = null;
		}
	};
	regist("$toJson", "Sina.string.toJson", toJson, "FlashSoft", "\u628a\u5b57\u7b26\u4e32\u8f6c\u5316\u6210JSON\u683c\u5f0f");
})();
	eval(regist.bindTo());
	var node = {};
	var channel = "";
	var uid = "";
	var click_timer = 0;
	var click_uid = 0;
	var getBrowser = function () {
		var isOpera, isIE, isNc, isFF = false;
		if(navigator.userAgent.indexOf("Opera") != -1) {
			isOpera = true;
		}else if(navigator.userAgent.indexOf("Firefox") != -1) {
			isFF = true;
		}else if(navigator.appName == "Microsoft Internet Explorer") {
			isIE = true;
		}else if(navigator.appName == "Netscape") {
			isNc = true;
		}
		var browser = null;
		if (isIE) {
			browser = "IE";
		}else if (isFF) {
			browser = "FF";
		}else if (isOpera) {
			browser = "Opera";
		}else {
			browser = "Other";
		}
		return browser;
	};
	var createSwf = function (sUID) {
		var browser = getBrowser();
		Sina.util.Swf.Add("http://sjs.sinajs.cn/common/js/share_connect.swf", "webIM_Conn_Connect", "1", "1", "", "", "", {
			allowScriptAccess: "always"
		}).Init();
		(function () {
			node = $E("webIM_Conn_Connect");
			if(node.register != null) {
				node.register({
					"channel_name": channel,
					"type": "Client"}
				);
				setInterval(function () {
//					console.log(check_win());
				}, 1000);
			}
			else {
				setTimeout(arguments.callee, 100);
			}
		})();
	};
	var check_win = function () {
		try {
			var winStatus = node.getVars(channel, "has_webim");
			return winStatus;
		}catch(e){
			return false;
		}
	};
	var open_webim_win = function (sUID) {
		var d = new Date().valueOf();
		if(click_uid == sUID) {
			if(d - click_timer < 3000) {
//				console.log(sUID + " \u8fd8\u5728\u51b7\u5374");
				return;
			}
			else {
//				console.log("\u5df2\u7ecf\u8fc7\u4e86\u51b7\u5374\u65f6\u95f4");
			}
		}
		else {
//			console.log("UID\u4e0d\u4e00\u6837,\u4e0d\u4f7f\u7528\u51b7\u5374\u65f6\u95f4");
		}
		click_uid = sUID;
		click_timer = d;
		var to_uid = sUID == 0? "": "&to_uid=" + sUID;
		var url="http://web.uc.sina.com.cn/client/webim.html?my_uid=" + uid + to_uid;
		window.open(url, "uc_win","width=600, height=425, titlebar=no, toolbar=no, menubar=no, scrollbars=no, resizable=no, location=yes, status=no, top=100, left=100");
	};
	var windowTitle = null;
	var flashTitleFunc = function (o, s) {
		var flashNum = 10;
		var flashNN = 0;
		function f() {
			if(flashNN % 2) {
				document.title = o;
			}
			else {
				document.title = s;
			}
			flashNN ++;
			if (flashNN > flashNum) {
				document.title = s;
				return;
			}
			setTimeout(f, 1000);
		}
		f();
	};
	var flashTitle = function () {
		if(windowTitle == null) {
			windowTitle = document.title;
		}
		flashTitleFunc("\u25cf\u6709\u804a\u5929\u4fe1\u606f\u25cf" + windowTitle, windowTitle);
	};
	window.flashTitle = flashTitle;
	var msg_list = {};
	var webIM = function (sUID) {
		$E("webIM_Conn_Iframe").src = "http://web.uc.sina.com.cn/proxy/proxy.html?my_uid=" + sUID;
		uid = sUID;
		var browser = getBrowser();
		channel = "_" + browser + sUID + "proxy";
		createSwf(sUID);
	};
	webIM.msg = function (sUID) {
		if(check_win() == false) {
			open_webim_win(sUID);
			webIM.hide_tip();
		}
		else {
			var server_id = node.getServer(channel);
			node.send(channel, server_id, "connect.uc_win_focus", sUID);
		}
	};
	webIM.view_pop = function () {
		if (check_win() == false) {
			open_webim_win(0);
			webIM.hide_tip();
		}
		else {
			var server_id = node.getServer(channel);
			node.send(channel, server_id, "connect.uc_win_focus", 0);
		}
	};
	webIM.hide_tip = function () {
		// 加上 try catch 保证节点不存在也不报错 L.Ming 2008.12.31
		try {
			$removeNode($E("web_im_pop_container"));
		}
		catch(e){}
	};
	/*
	 webIM.get_content({
		type: "msg",
		items: [{username:1147697897, msg:"aaa"}]
	});
	 */
	webIM.get_content = function (oData) {
		var type = oData.type;
		var items = oData.items;
		flashTitle();
		if (type == "msg") {
			for (var i = 0; i < items.length; i++) {
				var sUID = items[i].username;
				var sMSG = items[i].msg;
				msg_list[sUID] = {
					msg: sMSG
				};
				// \u83b7\u53d6\u6635\u79f0
				node.call({
					channel_name: channel,
					loader_name: "get_nick",
					url: "http://uic.sinajs.cn/uic?type=nick&uids=" + sUID,
					callback_function: "webIM.conn_nick"
				});
			}
		}
	};
	webIM.conn_nick = function (sData) {
		try{
			var oData = $toJson(sData);
		}
		catch(e){
			var oData = {};
		}
		var sUID = 0;
		var sNick = "\u65b0\u6d6a\u7f51\u53cb";
		for(var key in oData) {
			sUID = key;
			sNick = oData[key];
		}
		var sMSG = msg_list[sUID].msg;
		var oarg = {
			uid: sUID,
	        nick: sNick,
	        content: sMSG,
	        callback: function(){
				webIM.view_pop();
				return;
	        }
		}
		webIM_Pop(oarg);
	};
	// webIM Pop\u90e8\u5206
	/*=========================================================================================================*/
    //\u914d\u7f6e\u53c2\u6570
	//\u8ddd\u79bb\u5e95\u90e8\u4f4d\u7f6e\uff0c\u5355\u4f4d\u50cf\u7d20
	var popBottom = 10;
	var popRight = 10;
	//\u6d6e\u51fa\u5c42\u663e\u793a\u65f6\u95f4\uff0c\u5355\u4f4d\u79d2
	var delayTime = 10;
	//\u52a8\u753b\u8fc7\u7a0b\u65f6\u95f4\uff0c\u5355\u4f4d\u79d2
	var tweenTime = 1;
	/*=========================================================================================================*/
    /*
     * \u5168\u5c40\u53d8\u91cf\u5217\u8868
     */
    var IMUids = [];
    var IMHtml1 = '<div class="im2Bg">\
    				<div class="im2"><span><a href="javascript:;" onclick="return false;">[<em>\u6253\u5f00\u804a\u5929</em>]</a></span><img src="http://sjs.sinajs.cn/common/images/im/icon.gif" /> <a href="javascript:;" onclick="return false;"><strong>\u6709{#count#}\u4e2a\u597d\u53cb\u548c\u4f60\u804a\u5929</strong></a></div>\
					</div>';
    var IMHtml2 = '<div class="box_bg">\
					<div class="imBoxBg">\
					        <div class="conn">\
					            <div class="title">\
					                <a  href="javascript:;" onclick="return false;" class="mar5"><img src="{#headphoto#}" /></a> <a href="#">{#nick#}</a> \u5bf9\u4f60\u8bf4\uff1a</a>\
					            </div>\
					            <div class="connBox">{#content#}</div>\
					            <div class="imbottom"><span><a  href="javascript:;" onclick="return false;">[<em>\u6253\u5f00\u804a\u5929</em>]</a></span><img src="http://sjs.sinajs.cn/common/images/im/icon.gif" /> <a  href="javascript:;" onclick="return false;"><strong>\u6709{#count#}\u4e2a\u597d\u53cb\u548c\u4f60\u804a\u5929</strong></a></div>\
					        </div>\
					    </div>\
					</div>\
					';
    var popContainer;
	var timeOut;
	var lastCallBack;
	var isFollowInIe6;
	var isBig;
    /*
     * \u5168\u5c40\u53d8\u91cf\u65b0\u52a0\u5165uid
     * @param {String} uid \u8f93\u5165uid
     */
    function addUid(uid){
		if(uid == 0){
			return;
		}
        for (var i = 0, j = IMUids.length; i < j; i++) {
            if (IMUids[i] == uid) {
                return;
            }
        }
        IMUids.push(uid);
    }
    /*
     * \u83b7\u53d6\u76f8\u5e94\u7684html
     * @param {String} nick		\u5f53\u524d\u7528\u6237\u6635\u79f0
     * @param {String} content	\u7559\u8a00\u5185\u5bb9
     */
    function getHtml(uid, nick, content){
        var str = "";
		if(nick){
			str = IMHtml2.replace("{#content#}", content).replace("{#nick#}", nick).replace("{#count#}", IMUids.length).replace("{#headphoto#}","http://portrait"+(uid%8+1)+".sinaimg.cn/"+uid+"/blog/50");
		}else{
			str = IMHtml1.replace("{#count#}", IMUids.length);
		}
        return str;
    }
	//\u7531\u5927\u53d8\u5c0f
	function big2small(){
		var popString = getHtml();
		popContainer.innerHTML = popString;
		isBig = false;
	}
	/*
	 *
	 */
	function position4Ie6(dom){
		setInterval(function(){
			if(isBig){
				$setStyle(popContainer, "top", $getScrollPos()[0]+$getPageSize()[3]-189-popBottom+"px");
			}else{
				$setStyle(popContainer, "top", $getScrollPos()[0]+$getPageSize()[3]-33-popBottom+"px");
			}
		},500);
	}
    /*
     * \u7ed9\u5916\u9762\u8c03\u7528\u7684\u65b9\u6cd5
     * @param {Object} opt				\u7528\u6237\u7684\u4fe1\u606f
     * @param {String} opt.uid			\u5f53\u524d\u7528\u6237\u7684uid
     * @param {String} opt.nick			\u5f53\u524d\u7528\u6237\u7684\u540d\u79f0
     * @param {String} opt.content		\u804a\u5929\u4fe1\u606f
     * @param {Function} opt.callback	\u70b9\u51fb\u6d6e\u5c42\u6267\u884c\u51fd\u6570
     */
    var webIM_Pop = function(opt){
        if (!opt) {
            return;
        }
        var option = {
            uid: opt.uid ? opt.uid : 0,
            nick: opt.nick ? opt.nick : "\u65b0\u6d6a\u7f51\u53cb",
            content: opt.content ? opt.content : "",
            callback: opt.callback ? opt.callback : function(){
            }
        };
        addUid(option.uid);
        var popString = getHtml(option.uid, option.nick, option.content);
        if (!$E("web_im_pop_container")) {
            popContainer = document.createElement("DIV");
            popContainer.setAttribute("id", "web_im_pop_container");
			$setStyle(popContainer, "position", "fixed");
			$setStyle(popContainer, "bottom", "-60px");
			$setStyle(popContainer, "right", popRight+"px");
			$setStyle(popContainer, "opacity", "0");
			$setStyle(popContainer, "cursor", "pointer");
            document.body.appendChild(popContainer);
        }
		if(lastCallBack){
			$removeEvent(popContainer,"click",lastCallBack);
		}
		$addEvent(popContainer,"click",option.callback);
		lastCallBack = option.callback;
		//\u706d\u4e86\u5c0f\u5e7f\u544a\uff0c\u5c45\u7136\u7528xp\u8fd9\u4e48\u5389\u5bb3\u7684id
		if($E("xp")){
			$removeNode($E("xp"));
		}
        popContainer.innerHTML = popString;
		isBig = true;
		if(window.navigator.userAgent.indexOf("MSIE 6.0")>-1){
			$setStyle(popContainer, "position", "absolute");
		}
		/**
		 * \u5bf9Tween\u7c7b\u7684\u9759\u6001\u5c01\u88c5,\u65b9\u4fbf\u8c03\u7528
		 * @param {Object} oNode \u9700\u8981\u52a8\u753b\u7684\u5bf9\u8c61
		 * @pvaram {Array | String} oProperty \u8981\u64cd\u4f5c\u7684\u53c2\u6570
		 * @param {Array | String} oEndingValue \u76ee\u6807\u503c
		 * @param {Number} nSeconds \u8017\u65f6
		 * @param {String} sAnimation \u52a8\u753b\u7c7b\u578b
		 * @param {Object} oFunc \u56de\u8c03\u51fd\u6570
		 * tween($E("xxxx"), ["opacity", "width"], ["1", "2%"], 2, "simple");
		 */
		$tween(popContainer, ["opacity","bottom"], ["1", popBottom+"px"], tweenTime, "backEaseInOut");
		//\u9488\u5bf9ie6\u7684\u8ddf\u968f
		if(window.navigator.userAgent.indexOf("MSIE 6.0") > -1){
			if(isFollowInIe6 == undefined){
				isFollowInIe6 = setTimeout(function(){
									position4Ie6(popContainer);
								}, tweenTime*1000);
			}
		}
		//\u5f00\u59cb\u51c6\u5907\u53d8\u5c0f\u4e86
		clearTimeout(timeOut);
//		trace("\u6e05\u740610\u79d2\u540e\u53d8\u6210\u5c0f\u5c42\u5ef6\u65f6");
		timeOut = setTimeout(big2small,delayTime*1000);
    };
    //\u7ed1\u5b9a\u5230\u5168\u5c40
    webIM.webIMPop = webIM_Pop;
	window.webIM = webIM;
})();
var __sayon_webim_msg_pop__ = false;

