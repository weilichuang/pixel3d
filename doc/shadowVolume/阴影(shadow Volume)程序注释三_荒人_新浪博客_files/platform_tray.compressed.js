/**
 * @fileoverview \u535a\u5ba26.0\u6258\u76d8\u7a0b\u5e8f\u72ec\u7acb\u90e8\u7f72\u5305
 * @author FlashSoft | fangchao@staff.sina.com.cn
 * @update 08.09.08
 * @changed xy xinyu@staff.sina.com.cn
 *
 */
(function () {
	var funcName = "trace";
	if(window[funcName] == null) {
		(function () {
			var trace = function () {};
			trace.error = function () {};
			trace.traceList = [];
			window[funcName] = trace;
		})();
	}
	/**.
	 *  \u4ee3\u7801\u5de5\u4f5c\u6d41\u7a0b:
	 *  \u68c0\u67e5\u662f\u5426\u767b\u9646
	 *  //\u8f7d\u5165\u6837\u5f0f\u8868
	 *  \u6839\u636e\u767b\u9646\u60c5\u51b5\u8fd4\u56de\u6258\u76d8HTML
	 *  \u521d\u59cb\u5316Base HTML
	 *  \u628a\u5199\u5165\u7684HTML\u8fd4\u56deDOM\u8282\u70b9\u5217\u8868\u683c\u5f0f
	 *  \u521d\u59cb\u5316\u7ed1\u5b9a\u4e8b\u4ef6
	 *  \u628a\u63a5\u53e3\u8bfb\u5230\u7684\u6570\u636e\u8fdb\u884c\u5448\u73b0
	 *  \u5b9a\u65f6\u8f6e\u5bfb\u6765\u628a\u63a5\u53e3\u5f97\u5230\u7684\u6570\u636e\u66f4\u65b0\u5230\u5f53\u524d\u9875\u9762
	 *  \u628a\u5f53\u524d\u9875\u9762\u7684\u6570\u636e\u5171\u4eab\u5230\u5176\u4ed6\u9875\u9762
	 *
	 */
	var __register_name_space__ = true;
	var Sina = {};
	//-- \u57fa\u7840Lib\u5305 ----------------------------------------------------------------
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
/**
 *
 * @method Sina.base.parseParam
 * @param {Object} oSource \u9700\u8981\u88ab\u8d4b\u503c\u53c2\u6570\u7684\u5bf9\u8c61
 * @param {Object} oParams \u4f20\u5165\u7684\u53c2\u6570\u5bf9\u8c61
 * @author FlashSoft | fangchao@staff.sina.com.cn
 * @update 08.08.25
 */
(function () {
	var parseParam = function (oSource, oParams) {
		var key;
		try {
			if (typeof oParams != "undefined") {
				for (key in oSource) {
					if (oParams[key] != null) {
						oSource[key] = oParams[key];
					}
				}
			}
		}
		finally {
			key = null;
			return oSource;
		}
	};
	regist("$parseParam", "Sina.base.parseParam", parseParam, "FlashSoft", "\u89e3\u6790\u4f20\u5165\u53c2\u6570\u8d4b\u503c\u7ed9\u9ed8\u8ba4\u53c2\u6570,\u7528\u6765\u505a\u65b9\u6cd5\u7684\u53c2\u6570\u89e3\u6790\u7528");
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
* \u83b7\u53d6\u8282\u70b9\u5bf9\u8c61\u7684\u8ddd\u6587\u6863\u7684XY\u503c
* @method getXY
* @param {HTMLElement } el \u8282\u70b9\u5bf9\u8c61
* @return {Array} x,y\u7684\u6570\u7ec4\u5bf9\u8c61
* @author FlashSoft | fangchao@staff.sina.com.cn
* @update 08.02.23
* @example
* 	Sina.dom.getXY(Sina.base.get("testDiv"));
*/
(function () {
	var getXY;
	if (Sina.base.ie) {
		getXY = function(el){
			var parentNode, pos, box, doc, scrollPos;
			try {
				if ((el.parentNode == null || el.offsetParent == null || Sina.dom.getStyle(el, "display") == "none") && el != document.body) {
					return false;
				}
				parentNode = null;
				pos = [];
				doc = el.ownerDocument;
				box = el.getBoundingClientRect();
				scrollPos = Sina.dom.getScrollPos(el.ownerDocument);
				return [box.left + scrollPos[1], box.top + scrollPos[0]];
			}
			finally {
				parentNode = pos = box = doc = scrollPos = null;
			}
		};
	}
	else {
		getXY = function (el) {
			var parentNode, pos, box, doc, scrollPos;
			try {
				if ((el.parentNode == null || el.offsetParent == null || Sina.dom.getStyle(el, "display") == "none") && el != document.body) {
					return false;
				}
				parentNode = null;
				pos = [];
				doc = el.ownerDocument;
				pos = [el.offsetLeft, el.offsetTop];
				parentNode = el.offsetParent;
				var hasAbs = Sina.dom.getStyle(el, "position") == "absolute";
				if (parentNode != el) {
					while (parentNode) {
							pos[0] += parentNode.offsetLeft;
							pos[1] += parentNode.offsetTop;
							if (Sina.base.safari && !hasAbs && Sina.dom.getStyle(parentNode,"position") == "absolute" ) {
									hasAbs = true;
							}
							parentNode = parentNode.offsetParent;
					}
				}
				if (Sina.base.safari && hasAbs) {
					pos[0] -= el.ownerDocument.body.offsetLeft;
					pos[1] -= el.ownerDocument.body.offsetTop;
				}
				parentNode = el.parentNode;
				while (parentNode.tagName && !/^body|html$/i.test(parentNode.tagName)) {
					if (Sina.dom.getStyle(parentNode, "display").search(/^inline|table-row.*$/i)) {
						pos[0] -= parentNode.scrollLeft;
						pos[1] -= parentNode.scrollTop;
					}
					parentNode = parentNode.parentNode;
				}
				return pos;
			}
			finally {
				parentNode = pos = box = doc = scrollPos = null;
			}
		};
	}
	regist("$getXY", "Sina.dom.getXY", getXY, "FlashSoft", "\u83b7\u53d6\u8282\u70b9\u5bf9\u8c61\u7684\u8ddd\u6587\u6863\u7684XY\u503c");
})();
/**
 * \u7ed9\u6307\u5b9a\u5bf9\u8c61\u589e\u52a0HTML[\u4e0d\u4f1a\u7834\u574f\u8fd9\u4e2a\u5bf9\u8c61\u56fa\u6709\u8282\u70b9\u7684\u4e8b\u4ef6]
 * @method Sina.dom.addHTML
 * @param {HTMLElement | Document} oParentNode \u8282\u70b9\u5bf9\u8c61
 * @param {String} sHTML \u4ee3\u7801\u5b57\u7b26\u4e32
 * @return {Void}
 * @author FlashSoft | fangchao@staff.sina.com.cn
 * @update 07.12.26
 * @example
 *	Sina.base.addHTML(document.body, "<input/>");
 */
(function () {
	var addHTML;
	if(Sina.base.ie) {
		addHTML = function (oParentNode, sHTML, where) {
			//where = where.toLowerCase() || "beforeend";
			oParentNode = Sina.base.get(oParentNode);
			switch(where){
				case "beforebegin":
					oParentNode.insertAdjacentHTML('BeforeBegin', sHTML);
					break;
				case "afterbegin":
					oParentNode.insertAdjacentHTML('AfterBegin', sHTML);
					break;
				case "afterend":
					oParentNode.insertAdjacentHTML('AfterEnd', sHTML);
					break;
				case "beforeend":
				default:
					oParentNode.insertAdjacentHTML('BeforeEnd', sHTML);
					break;
			}
		};
	}
	else {
		addHTML = function (oParentNode, sHTML, where) {
			//where = where.toLowerCase() || "beforeend";
			oParentNode = Sina.base.get(oParentNode);
			var oFrag;
			var oRange = oParentNode.ownerDocument.createRange();
			try{
				switch(where){
					case "beforebegin":
						oRange.setStartBefore(oParentNode);
						oFrag = oRange.createContextualFragment(sHTML);
						oParentNode.parentNode.insertBefore(oFrag, oParentNode);
						break;
					case "afterbegin":
						if(oParentNode.firstChild){
							oRange.setStartBefore(oParentNode.firstChild);
							oFrag = oRange.createContextualFragment(sHTML);
							oParentNode.insertBefore(oFrag, oParentNode.firstChild);
						}else{
							oParentNode.innerHTML = sHTML;
						}
						break;
					case "afterend":
						oRange.setStartAfter(oParentNode);
						oFrag = oRange.createContextualFragment(sHTML);
						oParentNode.parentNode.insertBefore(oFrag, oParentNode.nextSibling);
						break;
					case "beforeend":
					default:
						if(oParentNode.lastChild){
							oRange.setStartAfter(oParentNode.lastChild);
							oFrag = oRange.createContextualFragment(sHTML);
							oParentNode.appendChild(oFrag);
						}else{
							oParentNode.innerHTML = html;
						}
						break;
				}
			}
			finally{
				oRange = oFrag = null;
			}
		};
	}
	regist("$addHTML", "Sina.dom.addHTML", addHTML, "FlashSoft", "\u7ed9\u6307\u5b9a\u5bf9\u8c61\u589e\u52a0HTML[\u4e0d\u4f1a\u7834\u574f\u8fd9\u4e2a\u5bf9\u8c61\u56fa\u6709\u8282\u70b9\u7684\u4e8b\u4ef6]");
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
 * \u5224\u65ad\u9f20\u6807\u662f\u5426\u5728\u6307\u5b9a\u5bf9\u8c61\u4e0a
 * @param {HTMLElement | Document} oElement \u8282\u70b9\u5bf9\u8c61
 * @param {Event} oEvent event
 * @return {Boolean} \u5982\u679c\u9f20\u6807\u5728\u5bf9\u8c61\u4e0a\u5219\u4e3ature,\u5426\u5219\u4e3afalse
 * @author FlashSoft | fangchao@staff.sina.com.cn
 * @update 08.09.21
 */
(function () {
	var hitTest = function (oElement, oEvent) {
		var _nodeXY = Sina.dom.getXY(oElement);
		var _pos = {
			left: _nodeXY[0],
			top: _nodeXY[1],
			right: _nodeXY[0] + oElement.offsetWidth,
			bottom: _nodeXY[1] + oElement.offsetHeight
		};
		var _x = oEvent.clientX;
		var _y = oEvent.clientY;
		return (_x >= _pos.left && _x <= _pos.right) && (_y >= _pos.top && _y <= _pos.bottom)? false: true;
	};
	regist("$hitTest", "Sina.dom.hiTest", hitTest, "FlashSoft", "\u5224\u65ad\u9f20\u6807\u662f\u5426\u5728\u6307\u5b9a\u5bf9\u8c61\u4e0a");
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
 * \u83b7\u53d6Event\u5bf9\u8c61
 * @method Sina.base.getEvent
 * @return {Event} Event\u5bf9\u8c61
 * @author FlashSoft | fangchao@staff.sina.com.cn
 * @update 08.07.29
 * @example
 * 	Sina.events.getEvent();
 */
(function () {
	var getEvent;
	if(Sina.base.ie) {
		getEvent = function () {
			return window.event;
		};
	}
	else {
		getEvent = function () {
			var o, e, n;
			try {
				o = arguments.callee.caller;
				n = 0;
				while(o != null && n < 40){
					e = o.arguments[0];
					if (e && (e.constructor == Event || e.constructor == MouseEvent)) {
						return e;
					}
					n ++;
					o = o.caller;
				}
				return e;
			}
			finally {
				o = e = n = null;
			}
		};
	}
	regist("$getEvent", "Sina.events.getEvent", getEvent, "FlashSoft", "\u83b7\u53d6Event\u5bf9\u8c61");
})();
/**
 * \u7981\u6b62Event\u4e8b\u4ef6\u5192\u6ce1
 * @method Sina.base.stopEvent
 * @author FlashSoft | fangchao@staff.sina.com.cn
 * @update 08.07.29
 * @example
 * 	Sina.events.stopEvent();
 */
(function () {
	var stopEvent;
	if(Sina.base.ie) {
		stopEvent = function () {
			var ev;
			try {
				ev = Sina.events.getEvent();
				ev.cancelBubble = true;
				ev.returnValue = false;
			}
			finally {
				ev = null;
			}
		};
	}
	else {
		stopEvent = function () {
			var ev;
			try {
				ev = Sina.events.getEvent();
				ev.preventDefault();
				ev.stopPropagation();
			}
			finally {
				ev = null;
			}
		};
	}
	regist("$stopEvent", "Sina.dom.stopEvent", stopEvent, "FlashSoft", "\u7981\u6b62Event\u4e8b\u4ef6\u5192\u6ce1");
})();
/**
 * \u83b7\u53d6\u4e8b\u4ef6\u6e90\u5bf9\u8c61 (IE\u4e0b\u4e3a event.srcElement , FF\u4e0b\u4e3a eventObj.target)
 * @method Sina.events.getTarget
 * @param {Object} Event\u5bf9\u8c61
 * @author xs | zhenhua1@staff.sina.com.cn
 * @update 08.08.03
 * @example
 * 	//\u5728\u4e8b\u4ef6\u6267\u884c\u51fd\u6570\u5185\u83b7\u53d6\u4e8b\u4ef6\u6e90\u5bf9\u8c61
 * 	Sina.events.getTarget(Sina.events.getEvent());
 */
(function () {
	var getTarget;
	if(Sina.base.ie) {
		getTarget = function (oEvnet) {
			return (oEvnet||window.event).srcElement;
		};
	}
	else {
		getTarget = function (oEvnet) {
			var node = oEvnet.target;
			while(node.nodeType != 1){
				node = node.parentNode;
			}
			return node;
		};
	}
	regist("$getTarget", "Sina.events.getTarget", getTarget, "xs", "\u83b7\u53d6\u4e8b\u4ef6\u6e90\u5bf9\u8c61 (IE\u4e0b\u4e3a event.srcElement , FF\u4e0b\u4e3a eventObj.target)");
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
/*
 * Copyright (c) 2008, Sina Inc. All rights reserved.
 * @fileoverview cookie\u64cd\u4f5c\u7c7b
 * @author xinlin | xinlin@sina.staff.com.cn
 * @version 1.0 | 2008-09-02
 * @update 08.11.05
 * 	FlashSoft | fangchao@staff.sina.com.cn
 */
/**
 * @deprecated
 * cookie\u7684\u64cd\u4f5c\u5f88\u7279\u522b\uff0c\u8bfb\u5199\u90fd\u662f\u901a\u8fc7document.cookie\u6765\u64cd\u4f5c\u7684
 * 1.\u8bfb\u53d6\u7684\u65f6\u5019\uff0c\u6d4f\u89c8\u5668\u5e76\u6ca1\u6709\u63d0\u4f9b\u63a5\u53e3\u4f9b\u6309\u9700\u8bfb\u53d6\uff0c\u800c\u662f\u76f4\u63a5\u8fd4\u56de\u6240\u6709\u7684cookie
 * 2.\u5199\u5165\u7684\u65f6\u5019\uff0c\u5bf9document.cookie\u7684\u8d4b\u503c\u5374\u662f\u53ea\u4f1a\u5bf9\u8bbe\u7f6e\u7684cookie name\u6240\u5bf9\u5e94\u7684cookie\u503c\u53d1\u751f\u4f5c\u7528\uff0c\u4e0d\u4f1a\u5f71\u54cd\u5176\u4ed6\u7684cookie\u503c\u3002\u5220\u9664\u64cd\u4f5c\u4e0e\u670d\u52a1\u5668\u7aef\u7684\u505a\u6cd5\u76f8\u540c\u90fd\u662f\u5c06cookie\u8bbe\u7f6e\u4e3a\u8fc7\u671f\u3002
 * \u8fd9\u91cc\u53ef\u4ee5\u53d1\u73b0\u6d4f\u89c8\u5668\u7684cookie\u64cd\u4f5c\u662f\u7edf\u4e00\u7684\u5165\u53e3\uff0c\u4e0d\u8bba\u662f\u670d\u52a1\u5668\u7aef\u8fd8\u662f\u5ba2\u6237\u7aef\u3002
 *
 */
(function () {
	var Cookie = {};
	/**
	 * \u8bfb\u53d6cookie,\u6ce8\u610fcookie\u540d\u5b57\u4e2d\u4e0d\u5f97\u5e26\u5947\u602a\u7684\u5b57\u7b26\uff0c\u5728\u6b63\u5219\u8868\u8fbe\u5f0f\u7684\u6240\u6709\u5143\u5b57\u7b26\u4e2d\uff0c\u76ee\u524d .[]$ \u662f\u5b89\u5168\u7684\u3002
	 * @param {Object} cookie\u7684\u540d\u5b57
	 * @return {String} cookie\u7684\u503c
	 * @example
	 * var value = Cookie.getCookie(name);
	 */
	Cookie.getCookie = function (name) {
		name = name.replace(/([\.\[\]\$])/g,'\\\$1');
		var rep = new RegExp(name + '=([^;]*)?;','i');
		var co = document.cookie + ';';
		var res = co.match(rep);
		if (res) {
			return res[1];
		}
		else {
			return "";
		}
	};
	/**
	 * \u8bbe\u7f6ecookie
	 * @param {String} name cookie\u540d
	 * @param {String} value cookie\u503c
	 * @param {Number} expire Cookie\u6709\u6548\u671f\uff0c\u5355\u4f4d\uff1a\u5c0f\u65f6
	 * @param {String} path \u8def\u5f84
	 * @param {String} domain \u57df
	 * @param {Boolean} secure \u5b89\u5168cookie
	 * @example
	 * Cookie.setCookie('name','sina')
	 */
	Cookie.setCookie = function (name, value, expire, path, domain, secure) {
			var cstr = [];
			cstr.push(name + '=' + escape(value));
			if(expire){
				var dd = new Date();
				var expires = dd.getTime() + expire * 3600000;
				dd.setTime(expires);
				cstr.push('expires=' + dd.toGMTString());
			}
			if (path) {
				cstr.push('path=' + path);
			}
			if (domain) {
				cstr.push('domain=' + domain);
			}
			if (secure) {
				cstr.push(secure);
			}
			document.cookie = cstr.join(';');
	};
	/**
	 * \u5220\u9664cookie
	 * @param {String} name cookie\u540d
	 */
	Cookie.deleteCookie = function(name) {
			document.cookie = name + '=;' + 'expires=Fri, 31 Dec 1999 23:59:59 GMT;';
	};
	regist("$Cookie", "Sina.util.Cookie", Cookie, "xinlin", "Cookie\u8bfb\u5199\u7c7b");
})();
/*
 * Copyright (c) 2007, Sina Inc. All rights reserved.
 * @fileoverview \u5f15\u7528\u5916\u90e8\u7684js\u6587\u4ef6\uff0c\u5e76\u76d1\u6d4bjs\u7684\u8f7d\u5165\u72b6\u6001
 */
/**
 * \u5c06\u5355\u4e2a\u6216\u8005\u4e00\u7ec4js\u5f15\u5165\u5230\u9875\u9762\u4e0a\uff0c\u5f53\u8f7d\u5165\u5b8c\u6210\u65f6\u6267\u884c\u6307\u5b9a\u7684\u51fd\u6570
 * @author stan | chaoliang@staff.sina.com.cn
 * @param {String} jsfile \u5f15\u5165\u7684\u5355\u4e2a\u6587\u4ef6\u5730\u5740
 * @param {Array} jsfile \u5f15\u5165\u7684\u591a\u4e2a\u6587\u4ef6\u5730\u5740\u7ec4\u6210\u7684\u6570\u7ec4
 * @param {Function} handle \u6240\u5f15\u5165\u7684js\u6587\u4ef6\u5168\u90e8\u52a0\u8f7d\u5b8c\u6bd5\u540e\u8981\u6267\u884c\u7684\u51fd\u6570
 * @example
 * 		var jsfiles = [
 * 				"http://blog.sina.com.cn/file1.js",
 * 				"http://blog.sina.com.cn/file2.js"
 * 		]
 * 		Sina.io.include(jsfiles, function(){
 * 			alert("all file are included");
 * 		})
 * @global $include
 */
(function(){
suinclude = function(jsfile, handle, _charset) {
	var ja = new Array();
	var jsHash = {};
	if(typeof jsfile == 'string') ja.push(jsfile);
	else ja = jsfile.slice(0);
	var ua = navigator.userAgent.toLowerCase();
	var isIE = /msie/.test(ua);
	var isOpera = /opera/.test(ua);
	var isMoz = /firefox/.test(ua);
	for(var i=0;i<ja.length;i++) {
		jsHash['j'+i] = false;
		jsHash['count_'+i]=0;
		var js = $C('script');
		js.type = 'text/javascript';
		if(_charset != null && _charset == "gb2312"){
			js.charset = _charset;
		}
		js.src = ja[i];
		js.id = 'j' + i;
		if(isIE) js.onreadystatechange = function() {
			if(this.readyState.toLowerCase() == 'complete' || this.readyState.toLowerCase() == 'loaded'){
				jsHash[this.id] = true;
			}
		};
		if(isMoz) js.onload = function() {
			jsHash[this.id] = true;
		};
		if(isOpera) jsHash['j' + i] = true;
		document.body.appendChild(js);
	}
	var loadTimer = setInterval(function(){
			for (var i = 0; i < ja.length; i++) {
				trace(jsHash['j'+i]+";jsHash['count_'+i]="+jsHash['count_'+i]+";js.src="+ja[i]);
				if (jsHash['count_' + i] < 5) {
					if (jsHash['j' + i] == false) {
						jsHash['count_' + i]++;
						return;
					}
				}else{
					continue;
				}
			}
		clearInterval(loadTimer);
		eval(handle)();
	},100);
};
regist("$suinclude", "Sina.io.suinclude", suinclude, "xy", "\u8f7d\u5165\u4e00\u4e2aurl,\u6210\u529f\u540e\u6267\u884c\u56de\u8c03\u51fd\u6570\uff0c\u5982\u679c\u91cd\u590d\u8f7d\u51655\u6b21\u4e0d\u6210\u529f\uff0c\u5219\u653e\u5f03\u6267\u884c");
})();
	eval(regist.bindTo());
	//-- \u5168\u5c40\u914d\u7f6e\u4fe1\u606f --------------------------------------------------------------
	var get_timer = null;
	var html_nologin = '';
	html_nologin += '<div class="sinatopbar" id="login_bar_{Tray}">';
	html_nologin += '  <div class="stb">';
	html_nologin += '		<!--\u4ea7\u54c1Logo-->';
	html_nologin += '     <div class="logo"><a id="login_bar_logo_link_{Tray}"></a></div>';
	html_nologin += '       <div class="stbcen">';
	html_nologin += '       <!--\u8fd0\u8425\u5bfc\u822a-->'
	html_nologin += '       <div class="st_Jh_vblog_nologin">';
	html_nologin += '			<span class="v1" id="login_yunying_span_{Tray}"><a href="http://blog.sina.com.cn" id="login_operation_first_btn_{Tray}" target="_blank">\u535a\u5ba2\u9996\u9875</a></span>';
	html_nologin += '           <span class="Mb_line"></span>';
	html_nologin += '           <span class="v2" id="login_bar_operation_span_{Tray}" ><a href="http://blog.sina.com.cn/lm/rank/index.html" id="login_operation_second_btn_{Tray}" target="_blank">\u6392\u884c\u699c</a></span>';
	html_nologin += '			<span class="v2" style="display:none;" id="login_bar_video_btn_{Tray}"><a href="javascript:;" id="login_bar_video_{Tray}"><strong>\u70b9\u64ad\u5355</strong><em>(0)</em></a><input type="hidden" id="video_number_{Tray}" value="0"></span>';
	html_nologin += '           <span class="vAd" id="login_ad_content_{Tray}"><a target="_blank" href="http://blog.sina.com.cn/lm/z/zhuliugan/index.html">H1N1\u6d41\u611f\u9694\u79bb\u8005\u535a\u5ba2</a></span>';
	html_nologin += '       </div>';
	html_nologin += '		<!--\u767b\u9646\u6309\u94ae-->';
	html_nologin += '       <div class="stblog">';
	html_nologin += '               <span class="stblog1" ><input type="button" value="\u767b\u5f55" id="login_login_btn_{Tray}" style="cursor: pointer"/></span>';
	html_nologin += '               <span class="stbline_j"></span>';
	html_nologin += '               <span class="stblog2"><a href="javascript:;" id="login_reg_btn_{Tray}" target="_blank">\u6ce8\u518c</a></span>';
	html_nologin += '       </div>';
	html_nologin += '       </div>';
	html_nologin += '		<div class="t_help">';
	html_nologin += '          <span class="stb_sosline" ></span>';
	html_nologin += '          <span class="helplink">';
	html_nologin += '				<a id="login_help_link_{Tray}" href="http://blog.sina.com.cn/lm/help/2009/index.html" target="_blank">\u5e2e\u52a9</a>';
	html_nologin += '			</span>';
	html_nologin += '		</div>';
	html_nologin += '		<!--\u641c\u7d22\u533a\u57df-->';
	html_nologin += '       <div class="stbsea"><form id="login_bar_search_form_{Tray}" method="get" target="_blank" action="http://uni.sina.com.cn/c.php?ie={Charset2}&t=blog"><div style="overflow:hidden">';
	html_nologin += '            <input name="ie" value="{Charset2}" type="hidden"><input name="e" value="{Charset}" type="hidden" style="width:0px;"><input name="k" value="" type="hidden" id="login_bar_search_hide_k_{Tray}" style="width:0px;"><input name="ts" value="" type="hidden" id="login_bar_search_hide_ts_{Tray}" style="width:0px;"><input name="key" value="" type="hidden" id="login_bar_search_hide_key_{Tray}">';
	html_nologin += '            <input name="keyword" value="" type="hidden" style="width:0px;" id="login_bar_search_hide_key_word_{Tray}"><input name="t" value="" type="hidden" id="login_bar_search_hide_t_{Tray}" style="width:0px;"></div><div class="sts1" style="background:url(http://simg.sinajs.cn/common/images/sinatopbar/090315_bg2.gif) no-repeat; background-position:2px 0px;*background-position:2px 2px; width:117px; padding:0px 0px 0px 4px; height:24px;"><input type="text"  class="stinp1"  style="background:none transparent; height:18px; padding:2px 0px 2px 2px; width:109px;" id="login_bar_search_input_{Tray}" ></div><div class="sts2"><div class="anainp" id="login_bar_search_menu_label_{Tray}">\u7efc\u5408</div><div class="arrow" id="login_bar_search_menu_arrow_{Tray}"></div></div><div class="sts3"><input class="suba"  type="submit"  value="\u641c\u7d22"></div></form></div>';
	html_nologin += '   </div>';
	html_nologin += '</div>';
	var html_login = '';
	html_login += '<div id="login_swf_parent_{Tray}" style="width: 20px; height: 20px; position: fixed; _position: absolute; left:0; top:0; overflow: hidden;">';
	html_login += '<div id="login_conn_swf_{Tray}"></div>';
	html_login += '<div id="login_music_swf_{Tray}"></div>';
	html_login += '</div>';
	html_login += '<div class="sinatopbar" id="login_bar_{Tray}">';
	html_login += '	<div class="stb">';
	html_login += '		<!--\u4ea7\u54c1Logo-->';
	html_login += '		<div class="logo"><a id="login_bar_logo_link_{Tray}"></a></div>';
	html_login += '		<!-- \u4fe1\u606f\u5448\u73b0\u533a\u57df -->';
	html_login += '		<div class="stbcen2">';
	html_login += '			<div class="nbg1" id="login_bar_opt_app_{Tray}"><div class="nbg2">';
	html_login += '				<!-- APP_\u83dc\u5355\u6587\u5b57 -->';
	html_login += '				<div class="name" id="login_bar_app_menu_label_{Tray}">\u8bfb\u53d6\u4e2d...</div>';
	html_login += '				<!-- APP_\u4e0b\u62c9\u7bad\u5934 -->';
	html_login += '				<div class="arr2" id="login_bar_app_menu_arrow_{Tray}"><a href="javascript:;" >&nbsp;</a></div>';
	html_login += '			</div></div>';
	html_login += '			<div class="nbg1" id="login_bar_opt_friend_{Tray}"><div class="nbg2">';
	html_login += '				<!-- \u597d\u53cb_\u83dc\u5355\u6587\u5b57 -->';
	html_login += '				<div class="name3" id="login_bar_friend_menu_label_{Tray}">\u597d\u53cb</div>';
	html_login += '			</div></div>';
	html_login += '			<div class="nbg1" id="login_bar_opt_msg_{Tray}"><div class="nbg2">';
	html_login += '				<div class="ico2" id="login_bar_msg_menu_ico_{Tray}" style="display: none;"><img src="http://simg.sinajs.cn/common/images/sinatopbar/spacetop_icon3_on.gif"></div>';
	html_login += '				<!-- \u6536\u4ef6\u7bb1_\u83dc\u5355\u6587\u5b57 -->';
	html_login += '				<div class="name2" id="login_bar_msg_menu_label_{Tray}">\u6536\u4ef6\u7bb1</div>';
	html_login += '				<!-- \u6536\u4ef6\u7bb1_\u4e0b\u62c9\u7bad\u5934 -->';
	html_login += '				<div class="arr2" id="login_bar_msg_menu_arrow_{Tray}"><a href="javascript:;"></a></div>';
	html_login += '			</div></div>';
	html_login += '			<!-- \u97f3\u4e50\u64ad\u653e\u5668\u533a\u57df -->';
	html_login += '			<div class="musican">';
	html_login += '				<span class="stbplay"><img id="login_bar_music_menu_control_{Tray}" width="29" height="31"></span>';
	html_login += '				<span title="\u64ad\u653e\u5217\u8868" class="stblist" id="login_bar_music_menu_label_{Tray}"><img src="http://simg.sinajs.cn/common/images/sinatopbar/stbcen_7.gif"></span>';
	html_login += '			</div>';
	html_login += '         <!-- \u64ad\u5ba2\u70b9\u64ad\u5355 -->';
	html_login += '         <div class="stbline" style="display:none;" id="login_bar_video_line_{Tray}"></div>';
	html_login += '         <div class="stbset" style="display:none;" id="login_bar_video_btn_{Tray}"><a href="javascript:;" id="login_bar_video_{Tray}"><strong>\u70b9\u64ad\u5355</strong><em>(0)</em></a><input type="hidden" id="video_number_{Tray}" value="0"></div>'
	html_login += '			<div class="stbline"></div>';
	html_login += '			<div class="stbset"><a id="login_bar_loginout_label_{Tray}" href="javascript:;">\u9000\u51fa</a></div>';
	html_login += '		</div>';
	html_login += '		<div class="t_help">';
	html_login += '          <span class="stb_sosline" ></span>';
	html_login += '          <span class="helplink">';
	html_login += '				<a id="login_help_link_{Tray}" href="http://blog.sina.com.cn/lm/help/2009/index.html" target="_blank">\u5e2e\u52a9</a>';
	html_login += '			</span>';
	html_login += '		</div>';
	html_login += '		<!--\u641c\u7d22\u533a\u57df-->';
	html_login += '		<div class="stbsea"><form id="login_bar_search_form_{Tray}" method="get" target="_blank" action="http://uni.sina.com.cn/c.php?ie={Charset2}&t=blog"><div style="overflow:hidden"><input name="ie" value="{Charset2}" type="hidden"><input name="e" value="{Charset}" type="hidden"><input name="k" value="" type="hidden" id="login_bar_search_hide_k_{Tray}"><input name="key" value="" type="hidden" id="login_bar_search_hide_key_{Tray}"><input name="keyword" value="" type="hidden" id="login_bar_search_hide_key_word_{Tray}"><input name="t" value="" type="hidden" id="login_bar_search_hide_t_{Tray}">';
	html_login += '     <input name="ts" value="" type="hidden" id="login_bar_search_hide_ts_{Tray}"></div><div class="sts1" style="background:url(http://simg.sinajs.cn/common/images/sinatopbar/090315_bg2.gif) no-repeat; background-position:2px 0px;*background-position:2px 2px; width:117px; padding:0px 0px 0px 4px; height:24px;"><input type="text" class="stinp1" style="background:none transparent; height:18px; padding:2px 0px 2px 2px; width:109px;" id="login_bar_search_input_{Tray}"></div><div class="sts2"><div class="anainp" id="login_bar_search_menu_label_{Tray}">\u7efc\u5408</div><div class="arrow" id="login_bar_search_menu_arrow_{Tray}"></div></div><div class="sts3"><input class="suba"  type="submit"  value="\u641c\u7d22"></div></form></div>';
	html_login += '	</div>';
	html_login += '</div>';
	var html_app = '';
	html_app += '<div class="layerBox" id="app_menu_{Tray}" style="position: absolute; display: none; z-index: 1000;">';
	html_app += '	<div class="topIcon s2"></div>';
	html_app += '	<div class="layerIn">';
	html_app += '		<dl class="mlinkList">';
	html_app += '			<dd><span class="icon"><img class="CP_i CP_i_blog" src="http://simg.sinajs.cn/common/images/CP_i.gif" align="absmiddle"></span><span class="l">&nbsp;<a href="http://blog.sina.com.cn" id="app_menu_blog_item_{Tray}"><strong>\u535a\u5ba2</strong></a></span><span class="r"><a href="http://control.blog.sina.com.cn/admin/article/article_add.php" class="linkEdit" target="_blank">[\u53d1\u535a\u6587]</a></span></dd>';
	html_app += '			<dd><span class="icon"><img class="CP_i CP_i_blogi" src="http://simg.sinajs.cn/common/images/CP_i.gif" align="absmiddle"></span><span class="l">&nbsp;<a href="http://photo.blog.sina.com.cn" id="app_menu_photo_item_{Tray}"><strong>\u76f8\u518c</strong></a></span><span class="r"><a href="http://photo.blog.sina.com.cn/upload/upload.php" class="linkEdit" target="_blank">[\u53d1\u56fe\u7247]</a></span></dd>';
	html_app += '			<dd><span class="icon"><img class="CP_i CP_i_music" src="http://simg.sinajs.cn/common/images/CP_i.gif" align="absmiddle"></span><span class="l">&nbsp;<a href="http://music.sina.com.cn" id="app_menu_music_item_{Tray}"><strong>\u97f3\u4e50</strong></a></span></dd>';
	html_app += '			<dd><span class="icon"><img class="CP_i CP_i_blogv" src="http://simg.sinajs.cn/common/images/CP_i.gif" align="absmiddle"></span><span class="l">&nbsp;<a href="http://v.sina.com.cn" id="app_menu_video_item_{Tray}"><strong>\u64ad\u5ba2</strong></a></span><span class="r"><a href="http://vupload.you.video.sina.com.cn/u.php?m=1" class="linkEdit" target="_blank">[\u4e0a\u4f20]</a> <a href="http://vupload.you.video.sina.com.cn/r.php" class="linkEdit" target="_blank">[\u5f55\u5236]</a></span></dd>';
	html_app += '			<dd class="lines"><span class="icon"><img class="CP_i CP_i_center" src="http://simg.sinajs.cn/common/images/CP_i.gif" align="absmiddle"></span><span class="l">&nbsp;<a href="http://profile.blog.sina.com.cn/u/UID" id="app_menu_personal_item_{Tray}"><strong>\u4e2a\u4eba\u4e2d\u5fc3</strong></a></span></dd>';
	html_app += '		</dl>';
	html_app += '		<div class="myset">';
	html_app += '			<p><a href="http://icp.api.sina.com.cn/person/update_base.php" id="app_menu_update_base_{Tray}"  target="_blank">\u4e2a\u4eba\u8d44\u6599\u4fee\u6539</a></p>';
	html_app += '			<p><a href="http://icp.api.sina.com.cn/person/modify_pass.php" id="app_menu_password_base_{Tray}"  target="_blank">\u767b\u5f55\u5bc6\u7801\u4fee\u6539</a></p>';
	html_app += '		</div>';
	html_app += '	</div>';
	html_app += '</div>';
	//\u64cd\u4f5c\u63d0\u793a xy
	html_app += '<div class="layerBox_yello" id="operation_tips_{Tray}" style="position: absolute; display: none; z-index: 1000;">';
	html_app += '	<div class="topArrow"></div>';

	html_app += '	<div class="layerConn">';
	html_app += '		<div class="closeMe"><a href="javascript:;" id="operation_tips_close_{Tray}"></a></div>';
	html_app += '		<div class="NoteInfo">\u70b9\u51fb\u6b64\u5904\u8fd4\u56de\u81ea\u5df1\u7684\u535a\u5ba2\u3001\u76f8\u518c\u3001\u97f3\u4e50\u3001\u64ad\u5ba2\u3001\u4e2a\u4eba\u4e2d\u5fc3\u3002</div>';
	html_app += '	</div>';
	html_app += '</div>';
	// \u66f4\u65b0\u63d0\u793a xy
	html_app += '<div class="layerBox_yello2" id="message_tips_{Tray}" style="position: absolute; display: none; z-index: 1000;">';
	html_app += '	<a href="javascript:;" id="message_tips_close_{Tray}"></a>';
	html_app += '	<span id="message_tips_enter_{Tray}">\u6709\u65b0\u6d88\u606f\uff01</span>';
	html_app += '</div>';
	var html_friend = '';
	html_friend += '<div class="layerBox" id="friend_menu_{Tray}" style="position: absolute; display: none; z-index: 1000;">';
	html_friend += '	<div class="topIcon s1"></div>';
	html_friend += '	<div class="layerIn">';
	html_friend += '		<div class="search">';
	html_friend += '			<input type="text" class="iptTxt" id="friend_menu_search_input_{Tray}"><input type="button" class="btn btnSearch">';
	html_friend += '		</div>';
	html_friend += '		<dl class="friendList" id="friend_menu_list_{Tray}">';
	html_friend += '			<dd>\u8f7d\u5165\u4e2d...</dd>';
	html_friend += '		</dl>';
	html_friend += '		<div class="page"><a href="javascript:;" id="friend_menu_pre_link_{Tray}">\u4e0a\u9875</a><span>|</span><a href="javascript:;" id="friend_menu_next_link_{Tray}">\u4e0b\u9875</a></div>';
	html_friend += '		<div class="line"></div>';
	html_friend += '		<div class="editLink"><span class="l"><a href="http://space.sina.com.cn/friend/invitefriend.php" target="_blank">[\u9080\u8bf7\u597d\u53cb]</a></span><span class="r"><a href="http://space.sina.com.cn/accountmanage/accountmanage.php" target="_blank">[\u7ba1\u7406]</a></span></div>';
	html_friend += '	</div>';
	html_friend += '</div>';
	var html_msg = '';
	html_msg += '<div class="layerBox" id="msg_menu_{Tray}" style="position: absolute; display: none; z-index: 1000;">';
	html_msg += '	<div class="topIcon s2"></div>';
	html_msg += '	<div class="layerIn">';
	html_msg += '		<dl class="noteList">';
	html_msg += '			<dd class="lines"><span class="l"><a href="http://icp.api.sina.com.cn/pubcontrol/index.php?ptype=1" target="_blank">\u901a\u77e5</a></span><span id="msg_menu_notice_item_{Tray}"></span></dd>';
	html_msg += '			<dd><span class="l"><a href="http://icp.api.sina.com.cn/pubcontrol/index.php?ptype=3" target="_blank">\u7eb8\u6761</a></span><span id="msg_menu_message_item_{Tray}"></span></dd>';
	html_msg += '			<dd class="lines"><span class="l"><a href="http://icp.api.sina.com.cn/pubcontrol/index.php?ptype=2" target="_blank">\u597d\u53cb\u9080\u8bf7</a></span><span id="msg_menu_invite_item_{Tray}"></span></dd>';
	html_msg += '			<dd id="msg_menu_blogcomment_span_{Tray}" style="display: none"><span class="l"><a href="http://icp.api.sina.com.cn/pubcontrol/index.php?ptype=5" target="_blank">\u535a\u5ba2\u8bc4\u8bba</a></span><span id="msg_menu_blogcomment_item_{Tray}"></span></dd>';
	html_msg += '			<dd id="msg_menu_photocomment_span_{Tray}" style="display: none" ><span class="l"><a href="http://icp.api.sina.com.cn/pubcontrol/index.php?ptype=7" target="_blank">\u76f8\u518c\u8bc4\u8bba</a></span><span id="msg_menu_photocomment_item_{Tray}"></span></dd>';
	html_msg += '			<dd id="msg_menu_videocomment_span_{Tray}" style="display: none"><span class="l"><a href="http://icp.api.sina.com.cn/pubcontrol/index.php?ptype=10" target="_blank">\u64ad\u5ba2\u8bc4\u8bba</a></span><span id="msg_menu_videocomment_item_{Tray}"></span></dd>';
	html_msg += '			<dd class="lines" id="msg_menu_blogrecomment_span_{Tray}" style="display: none" ><span class="l"><a href="http://icp.api.sina.com.cn/pubcontrol/index.php?ptype=6" target="_blank">\u8bc4\u8bba\u56de\u590d</a></span><span id="msg_menu_blogrecomment_item_{Tray}"></span></dd>';
	html_msg += '			<dd id="msg_menu_leavemsg_span_{Tray}" style="display: none" class="noline"><span class="l"><a href="http://icp.api.sina.com.cn/pubcontrol/index.php?ptype=9" target="_blank" id="msg_menu_leavemsg_link_{Tray}">\u7559\u8a00</a></span><span id="msg_menu_leavemsg_item_{Tray}"></span></dd>';
	html_msg += '			<dd id="msg_menu_mail_span_{Tray}" style="display: none" ><span class="l"><a href="http://mail.sina.com.cn" target="_blank" id="msg_menu_mail_link_{Tray}">\u90ae\u4ef6</a></span><span id="msg_menu_mail_item_{Tray}"></span></dd>';
	html_msg += '		</dl>';
	html_msg += '	</div>';
	html_msg += '</div>';
	var html_search = '';
	html_search += '<div class="layerBox layerBox_Md_1" id="search_menu_{Tray}" style="position: absolute; display: none;  z-index: 1000;">';
	html_search += '	<ul class="layerIn_No_1">';
	html_search += '		<li class="bottomline"><a href="javascript:;" b_value="space" style="text-decoration:none;">\u7efc\u5408&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></li>';
	html_search += '		<li><a href="javascript:;" b_value="blog" style="text-decoration:none;">\u535a\u6587&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></li>';
	html_search += '		<li><a href="javascript:;" b_value="bauthor" style="text-decoration:none;">\u535a\u4e3b&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></li>';
	html_search += '		<li><a href="javascript:;" b_value="photo" style="text-decoration:none;">\u56fe\u7247&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></li>';
	html_search += '		<li><a href="javascript:;" b_value="music" style="text-decoration:none;">\u97f3\u4e50&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></li>';
	html_search += '		<li><a href="javascript:;" b_value="vblog" style="text-decoration:none;">\u89c6\u9891&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></li>';
	html_search += '		<li class="bottomline"><a href="javascript:;" b_value="vauthor" style="text-decoration:none;">\u64ad\u4e3b&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></li>';
	html_search += '		<li><a href="javascript:;" b_value="tiezi" style="text-decoration:none;">\u8bba\u575b&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></li>';
	html_search += '		<li><a href="javascript:;" b_value="bar" style="text-decoration:none;">\u65b0\u6d6a\u5427&nbsp;&nbsp;&nbsp;</a></li>';
	html_search += '		<li><a href="javascript:;" b_value="quanzi" style="text-decoration:none;">\u5708\u5b50&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></li>';
	html_search += '	</ul>';
	html_search += '</div>';
	//\u64ad\u5ba2\u70b9\u64ad\u5355\u70b9\u51fb\u5f39\u51fa\u7684\u83dc\u5355,video_menu1\u4e3a\u6709\u64ad\u653e\u5217\u8868\u7684
	var html_video='';
	html_video +='<div class="layerBox layerBox_Md" id="video_menu1_{Tray}" style="position: absolute; display: none; z-index: 1000;">';
	html_video += '	<div class="topIcon s3"></div>';
	html_video += '	<div class="layerIn">';
	html_video += '		<p class="p1"><a id="video_play_btn_{Tray}" href="javascript:;">\u64ad\u653e</a></p>';
	html_video += '       	<div class="listdot"></div>';
	html_video += '        <p class="p1"><a id="video_clear_btn_{Tray}" href="javascript:;">\u6e05\u7a7a</a></p>';
	html_video += '    </div>';
	html_video += '</div>';
	html_video += '<div class="layerBox layerBox_Md" id="video_menu2_{Tray}" style="position: absolute; display: none; z-index: 1000;">'
	html_video += '	 <div class="topIcon s3"></div>';
	html_video += '	 <div class="layerIn_No"><p>\u6682\u65e0\u89c6\u9891\u3002</p></div>';
	html_video += '</div>';
	var cfg = {
		base_init: false,
		conn_name: "",
		args: {
			type: "",
			uid: "0",
			nick: "\u8bfb\u53d6\u4e2d..."
		},
		// \u6570\u636e
		data: {
			// \u63d0\u9192\u7684\u6570\u636e\u5217\u8868
			msg: {}
		},
		/** \u597d\u53cb\u68c0\u7d22\u7684\u5173\u952e\u5b57 */
		search_keyword: "",
		/** \u597d\u53cb\u68c0\u7d22\u7684\u5b9a\u65f6\u5668 */
		search_timer: null,
		/** \u793e\u533a\u641c\u7d22\u7684\u7c7b\u578b */
		tray_search_type: "",
		/** \u968f\u673aID */
		rnd: parseInt(Math.random() * 10000, 10),
		/** \u57fa\u7840\u4fe1\u606f\u914d\u7f6e,\u5305\u542b\u9ed8\u8ba4\u56fe\u6807URL\u7b49 */
		base: {
			// \u516c\u5171
			icp: {
				logo: "http://simg.sinajs.cn/common/images/sinatopbar/081219_logo_blog.gif",
				href: "http://blog.sina.com.cn",
				key: 0,
				reg: "http://login.sina.com.cn/hd/reg.php?entry=shequ",
				alt: "\u8fd4\u56de\u65b0\u6d6a\u535a\u5ba2\u9996\u9875",
				product: "0x00000001",
				name:"\u4e2a\u4eba\u4e2d\u5fc3",
				operation_second:"",
				helplink:"http://blog.sina.com.cn/lm/help/2009/profile.html"
			},
			// \u535a\u5ba2
			blog: {
				logo: "http://simg.sinajs.cn/common/images/sinatopbar/081219_logo_blog.gif",
				href: "http://blog.sina.com.cn",
				key: 2,
				reg: "http://login.sina.com.cn/hd/reg.php?entry=blog",
				alt: "\u8fd4\u56de\u65b0\u6d6a\u535a\u5ba2\u9996\u9875",
				product: "0x00000001",
				name:"\u535a\u5ba2\u9996\u9875",
				operation_second:"\u6392\u884c\u699c",
				operation_second_href:"http://blog.sina.com.cn/lm/rank/index.html",
				helplink:"http://blog.sina.com.cn/lm/help/2009/index.html"
			},
			// \u76f8\u518c
			photo: {
				logo: "http://simg.sinajs.cn/common/images/sinatopbar/081219_logo_blog.gif",
				href: "http://blog.sina.com.cn",
				key: 3,
				reg: "http://login.sina.com.cn/hd/reg.php?entry=photo",
				alt: "\u8fd4\u56de\u65b0\u6d6a\u535a\u5ba2\u9996\u9875",
				product: "0x00000008",
				name:"\u76f8\u518c\u9996\u9875",
				operation_second:"\u6392\u884c\u699c",
				operation_second_href:"http://photo.blog.sina.com.cn/gallerypub/gaoshou1.html",
				helplink:"http://blog.sina.com.cn/lm/help/2009/photo.html"
			},
			// \u97f3\u4e50
			music: {
				logo: "http://simg.sinajs.cn/common/images/sinatopbar/081219_logo_music.gif",
				href: "http://music.sina.com.cn",
				key: 4,
				reg: "http://login.sina.com.cn/hd/reg.php?entry=shequ",
				alt: "\u8fd4\u56de\u65b0\u6d6a\u97f3\u4e50\u9996\u9875",
				product: "0x00000400",
				name:"\u97f3\u4e50\u9996\u9875",
				operation_second:"\u6392\u884c\u699c",
				operation_second_href:"http://music.sina.com.cn/yueku/rank/newmoreboard.php",
				helplink:"http://blog.sina.com.cn/lm/help/2009/music.html"
			},
			// \u5e16\u5b50
			tiezi: {
				logo: "http://simg.sinajs.cn/common/images/sinatopbar/topbarlogo5.gif",
				href: "http://bbs.sina.com.cn",
				key: 6,
				reg: "http://login.sina.com.cn/hd/reg.php?entry=forum",
				alt: "\u8fd4\u56de\u65b0\u6d6a\u8bba\u575b\u9996\u9875",
				product: "0x00000040",
				helplink:"http://blog.sina.com.cn/lm/help/2009/index.html"
			},
			// \u5708\u5b50
			quanzi: {
				logo: "http://simg.sinajs.cn/common/images/sinatopbar/topbarlogo2.gif",
				href: "http://q.sina.com.cn",
				key: 7,
				reg: "http://login.sina.com.cn/hd/reg.php?entry=quanzi",
				alt: "\u8fd4\u56de\u65b0\u6d6a\u5708\u5b50\u9996\u9875",
				product: "0x00000004",
				helplink:"http://blog.sina.com.cn/lm/help/2009/index.html"
			},
			// \u64ad\u5ba2
			vblog: {
				logo: "http://simg.sinajs.cn/common/images/sinatopbar/081219_logo_video.gif",
				href: "http://v.sina.com.cn",
				key: 8,
				reg: "http://login.sina.com.cn/hd/reg.php?entry=vblog",
				alt: "\u8fd4\u56de\u65b0\u6d6a\u64ad\u5ba2\u9996\u9875",
				product: "0x00000002",
				name:"\u64ad\u5ba2\u9996\u9875",
				operation_second:"<strong>\u70b9\u64ad\u5355</strong><em>(0)<em>",
				operation_second_href:"javascript:;",
				helplink:"http://blog.sina.com.cn/lm/help/2009/video.html"
			},
			// \u641c\u7d22
			search: {
				logo: "http://simg.sinajs.cn/common/images/sinatopbar/081219_logo_search.gif",
				href: "http://uni.sina.com.cn",
				key: 0,
				reg: "http://login.sina.com.cn/hd/reg.php?entry=shequ",
				alt: "\u8fd4\u56de\u65b0\u6d6a\u793e\u533a\u641c\u7d22\u9996\u9875",
				product: "0x00000000",
				helplink:"http://blog.sina.com.cn/lm/help/2009/index.html"
			},
			/** \u4e0b\u62c9\u83dc\u5355\u7684\u914d\u7f6e */
			menu: {
				/** APP\u4e0b\u62c9\u83dc\u5355 */
				app: {
					/** \u6bcf\u9875\u6700\u5927\u6761\u6570 */
					page: 8,
					/** \u5f53\u524d\u663e\u793a\u7684\u9875\u7801 */
					index: -1,
					/** \u6700\u5927\u9875\u7801 */
					max_index: -1,
					/**
					 * \u6570\u636e\u6761\u6570
					 */
					max: -1
				},
				friend: {
					/** \u6bcf\u9875\u6700\u5927\u6761\u6570 */
					page: 15,
					/** \u5f53\u524d\u663e\u793a\u7684\u9875\u7801 */
					index: -1,
					/** \u6700\u5927\u9875\u7801 */
					max_index: -1,
					/**
					 * \u6570\u636e\u6761\u6570
					 */
					max: -1,
					/** \u662f\u5426\u663e\u793a\u7684\u662f\u7b2c\u4e00\u9875\u7684\u597d\u53cb */
					is_first: true
				}
			},
			/** \u97f3\u4e50\u64ad\u653e\u5668 */
			player: {
				status: true
			}
		},
		/** \u53ef\u4e0b\u62c9\u7684\u83dc\u5355\u5217\u8868 */
		menu_list: {},
		/** DOM\u8282\u70b9\u7f13\u5b58 */
		dom: {},
		/** \u6258\u76d8\u7684HTML\u914d\u7f6e */
		html: {
			/** \u672a\u767b\u9646\u7684\u6258\u76d8\u5de5\u5177\u6761 */
			no_login: html_nologin,
			login: html_login,
			/** APP\u5217\u8868\u83dc\u5355 */
			app_menu: html_app,
			/** \u597d\u53cb\u83dc\u5355 */
			friend_menu: html_friend,
			/** \u63d0\u9192\u83dc\u5355 */
			msg_menu: html_msg,
			/** \u641c\u7d22\u4e0b\u62c9\u83dc\u5355 */
			search_menu: html_search,
			/** \u64ad\u5ba2\u4e0b\u62c9\u83dc\u5355*/
			video_menu: html_video,
			/** \u97f3\u4e50\u4e0b\u62c9\u83dc\u5355 */
			music_menu: '\
				<div id="music_menu_{Tray}" style="position: absolute; display: none; width: 230px; height: 357px; z-index: 1000;"></div>'
		}
	};
	//-- \u89c6\u56fe ------------------------------------------------------------------
	var view = {};
	/** \u9020\u906e\u6321\u9634\u5f71 xy**/
	view.createShadow=function(domobj,type){
		trace("\u5236\u9020\u9634\u5f71");
		var shadowparent=document.getElementById('platform_tray_shadow');
		var shadowiframe=document.getElementById('platform_tray_shadow_iframe');
//		trace("height="+domobj.offsetHeight);
		if(typeof shadowparent=="undefined"||shadowparent==null){
			var shadowparent=document.createElement('div');
			var shadowiframe=document.createElement('iframe');
			shadowparent.id="platform_tray_shadow";
			shadowparent.className="platform_tray_shadow";
			shadowparent.style.position="absolute";
			shadowparent.style.zIndex="500";
			shadowiframe.id="platform_tray_shadow_iframe";
			shadowiframe.style.border="0";
			if(type=="music")
				shadowiframe.style.width ="191px";
			else
				shadowiframe.style.width = domobj.offsetWidth+"px";
			shadowiframe.style.height = domobj.offsetHeight+"px";
			shadowparent.style.left=domobj.style.left;
			shadowparent.style.top=parseInt(domobj.style.top)+6+"px";
			shadowparent.appendChild(shadowiframe);
			document.body.appendChild(shadowparent);
		}else{
			if(type=="music")
				shadowiframe.style.width ="191px";
			else
				shadowiframe.style.width = domobj.offsetWidth+"px";
			shadowiframe.style.height = domobj.offsetHeight+"px";
			shadowparent.style.left=domobj.style.left;
			shadowparent.style.top=parseInt(domobj.style.top)+6+"px";
		}
	};
	/** \u6258\u76d8 */
	view.bar = {};
		/** \u8fd4\u56de\u6258\u76d8\u8282\u70b9HTML */
		view.bar.get_html = function (sCharset) {
			var str = "";
			if (control.check_login() == true) {
				str = cfg.html.login.replace(/{Tray}/g, cfg.rnd);
				if(sCharset == "gb") {
					str = str.replace(/{Charset}/g, "").replace(/{Charset2}/g, "");
				}
				else {
					str = str.replace(/{Charset}/g, "utf8").replace(/{Charset2}/g, "utf-8");
				}
				return str;
			}
			else {
				str = cfg.html.no_login.replace(/{Tray}/g, cfg.rnd);
				if(sCharset == "gb") {
					str = str.replace(/{Charset}/g, "").replace(/{Charset2}/g, "");
				}
				else {
					str = str.replace(/{Charset}/g, "utf8").replace(/{Charset2}/g, "utf-8");
				}
				return str;
			}
		};
		/** \u628a\u6258\u76d8\u8282\u70b9\u7684DOM\u8282\u70b9\u5217\u8868\u5b58\u5165\u53d8\u91cf */
		view.bar.dom_init = function () {
			cfg.dom.login_bar = control.get_node("login_bar");
			cfg.dom.login_bar_logo_link = control.get_node("login_bar_logo_link");
//			cfg.dom.login_bar_logo = control.get_node("login_bar_logo");
			cfg.dom.login_help_link = control.get_node("login_help_link");
			// \u641c\u7d22
			cfg.dom.login_bar_search_form = control.get_node("login_bar_search_form");
			cfg.dom.login_bar_search_input = control.get_node("login_bar_search_input");
			cfg.dom.login_bar_search_hide_key_word = control.get_node("login_bar_search_hide_key_word");
			cfg.dom.login_bar_search_hide_k = control.get_node("login_bar_search_hide_k");
			cfg.dom.login_bar_search_hide_key = control.get_node("login_bar_search_hide_key");
//			trace(typeof cfg.dom.login_bar_search_hide_key);
//			trace("'"+cfg.dom.login_bar_search_hide_key.value+"'");
			cfg.dom.login_bar_search_hide_t = control.get_node("login_bar_search_hide_t");
			cfg.dom.login_bar_search_menu_label = control.get_node("login_bar_search_menu_label");
			cfg.dom.login_bar_search_menu_arrow = control.get_node("login_bar_search_menu_arrow");
			cfg.dom.video_number = control.get_node("video_number");
			cfg.dom.login_bar_search_hide_ts = control.get_node("login_bar_search_hide_ts");
			// \u767b\u5f55\u540e
			if (control.check_login() == true) {
				cfg.dom.login_swf_parent = control.get_node('login_swf_parent');
				cfg.dom.login_conn_swf = control.get_node("login_conn_swf");
				cfg.dom.login_music_swf = control.get_node("login_music_swf");
				cfg.dom.login_bar_opt_app = control.get_node("login_bar_opt_app");
				cfg.dom.login_bar_opt_friend = control.get_node("login_bar_opt_friend");
				cfg.dom.login_bar_opt_msg = control.get_node("login_bar_opt_msg");
				// APP
				cfg.dom.login_bar_app_menu_label = control.get_node("login_bar_app_menu_label");
				cfg.dom.login_bar_app_menu_arrow = control.get_node("login_bar_app_menu_arrow");
				// \u804a\u5929\u597d\u53cb
				cfg.dom.login_bar_friend_menu_label = control.get_node("login_bar_friend_menu_label");
				// \u63d0\u9192
				cfg.dom.login_bar_msg_menu_ico = control.get_node("login_bar_msg_menu_ico");
				cfg.dom.login_bar_msg_menu_label = control.get_node("login_bar_msg_menu_label");
				cfg.dom.login_bar_msg_menu_arrow = control.get_node("login_bar_msg_menu_arrow");
				// \u97f3\u4e50\u5217\u8868
				cfg.dom.login_bar_music_menu_control = control.get_node("login_bar_music_menu_control");
				cfg.dom.login_bar_music_menu_label = control.get_node("login_bar_music_menu_label");
				//\u64ad\u5ba2\u70b9\u64ad\u5355 xy
				cfg.dom.login_bar_video_line = control.get_node("login_bar_video_line");
				cfg.dom.login_bar_video_btn = control.get_node("login_bar_video_btn");
				cfg.dom.login_bar_video = control.get_node("login_bar_video");
				// \u9000\u51fa\u767b\u9646
				cfg.dom.login_bar_loginout_label = control.get_node("login_bar_loginout_label");
			}
			else {
				cfg.dom.login_reg_btn = control.get_node("login_reg_btn");
				cfg.dom.login_login_btn = control.get_node("login_login_btn");
				cfg.dom.login_operation_first_btn = control.get_node("login_operation_first_btn");
				cfg.dom.login_operation_second_btn = control.get_node("login_operation_second_btn");
				cfg.dom.login_yunying_span = control.get_node("login_yunying_span");
				//\u64ad\u5ba2\u70b9\u64ad\u5355 xy
				cfg.dom.login_bar_video_btn = control.get_node("login_bar_video_btn");
				cfg.dom.login_bar_video = control.get_node("login_bar_video");
				cfg.dom.login_bar_operation_span=control.get_node("login_bar_operation_span");
				cfg.dom.login_ad_content = control.get_node("login_ad_content");
			}
		};
		//\u5b9e\u73b0\u6258\u76d8\u767b\u5f55\u6309\u94ae\u4e0d\u8981\u8dd1\u5230\u767b\u9646\u9875\uff0c\u5e76\u4e14\u80fd\u968f\u65f6\u70b9\u51fa\u6765\u7684\u529f\u80fd\u3002xy 2008-12-12
//		view.bar.showLoginBtn=function(){
//			if(typeof view.bar.count=='undefined')
//				view.bar.count=0;
//			//\u7531\u4e8e\u6258\u76d8\u90e8\u7f72\u6bd4\u5e73\u53f0\u5927\uff0c\u56e0\u6b64\uff0c\u5982\u679c\u5728\u4e00\u5b9a\u65f6\u95f4\u5185\uff0c\u5e73\u53f0\u767b\u9646
//			//\u7684job\u8fd8\u6ca1\u6709\u6267\u884c\uff0c\u5219\u8fd8\u662f\u663e\u793a\u767b\u9646\u6309\u94ae\uff0c\u4f46\u90a3\u65f6\u70b9\u51fb\u540e\uff0c\u4f1a\u8df3\u5230\u767b\u9646\u9875
//			if(typeof $login=='undefined'&&view.bar.count<20){
//				view.bar.interval=setInterval(view.bar.showLoginBtn,300);
//				view.bar.count++;
//			}else{
//				try {
//					cfg.dom.login_login_btn.parentNode.parentNode.style.display = "";
//					clearInterval(view.bar.interval);
//				}catch(e){}
//			}
//		};
	/** APP\u83dc\u5355 */
	view.app_menu = {};
		/** \u8fd4\u56deAPP\u83dc\u5355HTML */
		view.app_menu.get_html = function (){
			return cfg.html.app_menu.replace(/{Tray}/g, cfg.rnd);
		};
		/** \u628a\u540e\u52a0\u8f7d\u7684DOM\u8282\u70b9\u5b58\u5165\u53d8\u91cf\u5217\u8868 */
		view.app_menu.dom_init = function () {
			cfg.dom.app_menu = control.get_node("app_menu");
			cfg.dom.app_menu_blog_item = control.get_node("app_menu_blog_item");
			cfg.dom.app_menu_photo_item = control.get_node("app_menu_photo_item");
			cfg.dom.app_menu_music_item = control.get_node("app_menu_music_item");
			cfg.dom.app_menu_video_item = control.get_node("app_menu_video_item");
			cfg.dom.app_menu_personal_item = control.get_node("app_menu_personal_item");
			cfg.dom.app_menu_update_base = control.get_node("app_menu_update_base");
			cfg.dom.app_menu_password_base = control.get_node("app_menu_password_base");
			//\u64cd\u4f5c\u63d0\u793a  xy
			cfg.dom.operation_tips = control.get_node("operation_tips");
			cfg.dom.operation_tips_close = control.get_node("operation_tips_close");
			cfg.menu_list["app_menu"] = cfg.dom.app_menu;
			//\u66f4\u65b0\u63d0\u793a xy
			cfg.dom.message_tips = control.get_node("message_tips");
			cfg.dom.message_tips_close = control.get_node("message_tips_close");
			cfg.dom.message_tips_enter = control.get_node("message_tips_enter");
		};
	/** \u63d0\u9192\u83dc\u5355 */
	view.msg_menu = {};
		/** \u8fd4\u56de\u63d0\u9192\u83dc\u5355\u9009\u9879\u7684HTML */
		view.msg_menu.set_item = function (nNum, oNode) {
			var n = 0;
			if(oNode) {
				if(nNum > 0) {
					oNode.innerHTML = "&nbsp;<em>(" + nNum + ")</em>";
					n = nNum;
				}
			}
			return n;
		};
		/** \u8fd4\u56de\u63d0\u9192\u83dc\u5355HTML */
		view.msg_menu.get_html = function () {
			return cfg.html.msg_menu.replace(/{Tray}/g, cfg.rnd);
		};
		/** \u628a\u540e\u52a0\u8f7d\u7684DOM\u8282\u70b9\u5b58\u5165\u53d8\u91cf\u5217\u8868 */
		view.msg_menu.dom_init = function () {
			cfg.dom.msg_menu = control.get_node("msg_menu");
			cfg.dom.msg_menu_notice_item = control.get_node("msg_menu_notice_item");
			cfg.dom.msg_menu_invite_item = control.get_node("msg_menu_invite_item");
			cfg.dom.msg_menu_message_item = control.get_node("msg_menu_message_item");
			cfg.dom.msg_menu_leavemsg_link = control.get_node("msg_menu_leavemsg_link");
			cfg.dom.msg_menu_mail_link = control.get_node("msg_menu_mail_link");
			cfg.dom.msg_menu_blogcomment_item = control.get_node("msg_menu_blogcomment_item");
			cfg.dom.msg_menu_blogrecomment_item = control.get_node("msg_menu_blogrecomment_item");
			cfg.dom.msg_menu_photocomment_item = control.get_node("msg_menu_photocomment_item");
			cfg.dom.msg_menu_videocomment_item = control.get_node("msg_menu_videocomment_item");
			cfg.dom.msg_menu_leavemsg_item = control.get_node("msg_menu_leavemsg_item");
			cfg.dom.msg_menu_mail_item = control.get_node("msg_menu_mail_item");
			cfg.dom.msg_menu_blogcomment_span = control.get_node("msg_menu_blogcomment_span");
			cfg.dom.msg_menu_blogrecomment_span = control.get_node("msg_menu_blogrecomment_span");
			cfg.dom.msg_menu_photocomment_span = control.get_node("msg_menu_photocomment_span");
			cfg.dom.msg_menu_videocomment_span= control.get_node("msg_menu_videocomment_span");
			cfg.dom.msg_menu_leavemsg_span = control.get_node("msg_menu_leavemsg_span");
			cfg.dom.msg_menu_mail_span = control.get_node("msg_menu_mail_span");
			cfg.menu_list["msg_menu"] = cfg.dom.msg_menu;
		};
		/** \u5448\u73b0\u62ff\u5230\u7684\u63d0\u9192\u6570\u636e */
		view.msg_menu.view_list = function () {
			trace("<b>\u63d0\u9192\u5217\u8868\u83dc\u5355 -> \u5199\u63d0\u9192\u6570\u636e</b>", {bgColor: "#333"});
			var n = 0;
			if(cfg.data.msg) {
				n += view.msg_menu.set_item(cfg.data.msg.notice, cfg.dom.msg_menu_notice_item);
				n += view.msg_menu.set_item(cfg.data.msg.invite, cfg.dom.msg_menu_invite_item);
				n += view.msg_menu.set_item(cfg.data.msg.message, cfg.dom.msg_menu_message_item);
				n += view.msg_menu.set_item(cfg.data.msg.blogcomment, cfg.dom.msg_menu_blogcomment_item);
				n += view.msg_menu.set_item(cfg.data.msg.blogrecomment, cfg.dom.msg_menu_blogrecomment_item);
				n += view.msg_menu.set_item(cfg.data.msg.photocomment, cfg.dom.msg_menu_photocomment_item);
				n += view.msg_menu.set_item(cfg.data.msg.vblogcomment, cfg.dom.msg_menu_videocomment_item);
				n += view.msg_menu.set_item(cfg.data.msg.gbook, cfg.dom.msg_menu_leavemsg_item);
			}
			if(n > 0) {
				cfg.dom.login_bar_msg_menu_ico.style.display = "";
				if (typeof window.scope != "undefined" && typeof window.scope.ishiddenmsgmenu == "undefined" || window.scope.ishiddenmsgmenu==true) {
					window.scope.ishiddenmsgmenu=true;
					cfg.dom.message_tips.style.display = "";
					var pos = $getXY(cfg.dom.login_bar_msg_menu_arrow);
					var arrow_pos = [-74, 10];
					cfg.dom.message_tips.style.display = "";
					cfg.dom.message_tips.style.left = ($ie ?pos[0] + arrow_pos[0]-2:pos[0] + arrow_pos[0]) + "px";
					cfg.dom.message_tips.style.top = (pos[1] + arrow_pos[1]+5) + "px";
					setTimeout(function(){view.createShadow(cfg.dom.message_tips,"msg");},5);
					setTimeout(function(){cfg.dom.message_tips.style.display="none";},10000);
				}
			}
			else {
				cfg.dom.login_bar_msg_menu_ico.style.display = "none";
			}
		};
	/** \u641c\u7d22\u83dc\u5355 */
	view.search_menu = {};
		/** \u8fd4\u56de\u641c\u7d22\u83dc\u5355HTML */
		view.search_menu.get_html = function () {
			return cfg.html.search_menu.replace(/{Tray}/g, cfg.rnd);
		};
		/** \u628a\u540e\u52a0\u8f7d\u7684DOM\u8282\u70b9\u5b58\u5165\u53d8\u91cf\u5217\u8868 */
		view.search_menu.dom_init = function () {
			cfg.dom.search_menu = control.get_node("search_menu");
			cfg.menu_list["search_menu"] = cfg.dom.search_menu;
		};
	/** \u64ad\u5ba2\u4e0b\u62c9\u83dc\u5355 xy */
	view.video_menu={};
		/** \u8fd4\u56de\u64ad\u5ba2\u83dc\u5355HTML */
		view.video_menu.get_html = function () {
			return cfg.html.video_menu.replace(/{Tray}/g, cfg.rnd);
		};
		/** \u628a\u540e\u52a0\u8f7d\u7684DOM\u8282\u70b9\u5b58\u5165\u53d8\u91cf\u5217\u8868 */
		view.video_menu.dom_init=function(){
			cfg.dom.video_menu1 = control.get_node("video_menu1");
			cfg.dom.video_menu2 = control.get_node("video_menu2");
			cfg.dom.video_play_btn = control.get_node("video_play_btn");
			cfg.dom.video_clear_btn = control.get_node("video_clear_btn");
			//\u6dfb\u52a0\u5230\u9690\u85cf\u83dc\u5355
			cfg.menu_list["video_menu1"] = cfg.dom.video_menu1;
			cfg.menu_list["video_menu2"] = cfg.dom.video_menu2;
		}
	/** \u97f3\u4e50\u5217\u8868\u83dc\u5355 */
	view.music_menu = {};
		/** \u8fd4\u56de\u97f3\u4e50\u83dc\u5355HTML */
		view.music_menu.get_html = function () {
			return cfg.html.music_menu.replace(/{Tray}/g, cfg.rnd);
		};
		/** \u628a\u540e\u52a0\u8f7d\u7684DOM\u8282\u70b9\u5b58\u5165\u53d8\u91cf\u5217\u8868 */
		view.music_menu.dom_init = function () {
			cfg.dom.music_menu = control.get_node("music_menu");
			cfg.menu_list["music_menu"] = cfg.dom.music_menu;
		};
		view.music_menu.write_swf = function () {
			var swfURL = "http://music.sina.com.cn/shequ/sns/flash/SMC_A.swf";
			var rndID = "music_swf_list_" + cfg.rnd;
			var swfContent = $C("div");
			swfContent.id = rndID;
			cfg.dom.music_menu.appendChild(swfContent);
			Sina.util.Swf.Add(swfURL, rndID, "100%", "100%", "", "", "", {scale: "noscale", allowScriptAccess: "always", wmode: "transparent"}).Init();
		};
	view.player = {
		showList: function () {
			trace("\u663e\u793a\u64ad\u653e\u5217\u8868", {color: "#999"});
			menu_func.show_music_menu();
		},
		hideList: function () {
			trace("\u9690\u85cf\u64ad\u653e\u5217\u8868", {color: "#999"});
			cfg.dom.music_menu.style.display = "none";
		},
		play: function (bAuto) {
			trace("\u97f3\u4e50\u64ad\u653e\u5f00\u59cb", {color: "#999"});
			cfg.dom.login_bar_music_menu_control.src = "http://simg.sinajs.cn/common/images/sinatopbar/stbcen_6_h.gif";
			cfg.dom.login_bar_music_menu_control.title = "\u6682\u505c\u97f3\u4e50";
			cfg.base.player.status = false;
			if (bAuto != true) {
				view.player.open();
				try {
					cfg.dom.login_music_swf.playMusic();
				}
				catch (e) {
					trace("\u64ad\u653e\u63a5\u53e3\u4e0d\u5b58\u5728", {
						color: "red"
					});
				}
			}
		},
		stop: function (bAuto) {
			trace("\u97f3\u4e50\u64ad\u653e\u505c\u6b62", {color: "#999"});
			cfg.dom.login_bar_music_menu_control.src = "http://simg.sinajs.cn/common/images/sinatopbar/stbcen_6.gif";
			cfg.dom.login_bar_music_menu_control.title = "\u64ad\u653e\u97f3\u4e50";
			cfg.base.player.status = true;
			if (bAuto != true) {
				try {
					cfg.dom.login_music_swf.stopMusic();
				}
				catch (e) {
					trace("\u505c\u6b62\u63a5\u53e3\u4e0d\u5b58\u5728", {
						color: "red"
					});
				}
			}
		},
		click: function () {
			if(cfg.base.player.status == true) {
				view.player.play();
			}
			else {
				view.player.stop();
			}
		},
		open: function () {
			var win = function () {
				var width = 257;
				var height = 136;
				var screen_width = window.screen.width;
				var screen_height = window.screen.height;
				window.open('http://music.sina.com.cn/shequ/sns/flash.php',
				'MusicSina',
				'height=' + height + ', width=' + width + ', top=' + (screen_height - height - 20) + ', left=' + (screen_width - width - 20) + ', toolbar=no, menubar=no, scrollbars=no, resizable=no,location=no, status=no');
			};
			try{
				if(cfg.dom.login_music_swf.getState() == false) {
					win();
				}
			}
			catch(e) {
				win();
			};
		},
		get_swf: function (sType) {
			if(sType == "A")return $E("music_swf_list_" + cfg.rnd);
			if(sType == "C")return cfg.dom.login_music_swf;
		}
	};
	//-- \u63a7\u5236\u5668 ----------------------------------------------------------------
	var control = {};
	/**
	 * \u68c0\u67e5\u5f53\u524d\u662f\u5426\u5df2\u7ecf\u767b
	 *     !!!\u5c1a\u672a\u5b9e\u73b0\u771f\u6b63\u8bfb\u53d6Cookie\u68c0\u67e5\u767b\u9646
	 * @return {Boolean} \u767b\u9646\u72b6\u6001
	 * @author FlashSoft | fangchao@staff.sina.com.cn
	 */
	control.check_login = function () {
		if($Cookie.getCookie("SU") == "" || $Cookie.getCookie("SU") == null)return false;
		return true;
	};
	/**
	 * \u8fd4\u56de\u6307\u5b9a\u6a21\u677fID\u7684DOM\u8282\u70b9\u5bf9\u8c61
	 * @return {HTMLElement | Element} DOM\u5bf9\u8c61
	 * @author FlashSoft | fangchao@staff.sina.com.cn
	 */
	control.get_node = function (sID) {
		return $E(sID + "_" + cfg.rnd);
	};
	/**
	 * \u521d\u59cb\u5316\u7ed1\u5b9a\u4e8b\u4ef6
	 * @author FlashSoft | fangchao@staff.sina.com.cn
	 */
	control.event_init = function () {
		if (control.check_login() == true) {
			$addEvent(cfg.dom.login_bar_opt_app, "mouseover", $bind(menu_func.swap_menu_css, this, ["over", cfg.dom.login_bar_opt_app]));
			$addEvent(cfg.dom.login_bar_opt_app, "mouseout", $bind(menu_func.swap_menu_css, this, ["out", cfg.dom.login_bar_opt_app]));
			$addEvent(cfg.dom.login_bar_opt_friend, "mouseover", $bind(menu_func.swap_menu_css, this, ["over", cfg.dom.login_bar_opt_friend]));
			$addEvent(cfg.dom.login_bar_opt_friend, "mouseout", $bind(menu_func.swap_menu_css, this, ["out", cfg.dom.login_bar_opt_friend]));
			$addEvent(cfg.dom.login_bar_opt_msg, "mouseover", $bind(menu_func.swap_menu_css, this, ["over", cfg.dom.login_bar_opt_msg]));
			$addEvent(cfg.dom.login_bar_opt_msg, "mouseout", $bind(menu_func.swap_menu_css, this, ["out", cfg.dom.login_bar_opt_msg]));
			$addEvent(cfg.dom.login_bar_opt_app, "click", menu_func.app_show_menu);
//			$addEvent(cfg.dom.login_bar_app_menu_arrow, "click", menu_func.app_show_menu);
			$addEvent(cfg.dom.login_bar_opt_msg, "click", menu_func.show_msg_menu);
//			$addEvent(cfg.dom.login_bar_msg_menu_arrow, "click", menu_func.show_msg_menu);
			$addEvent(cfg.dom.login_bar_music_menu_label, "click", menu_func.show_music_menu);
			$addEvent(cfg.dom.login_bar_music_menu_control, "click", view.player.click);
			$addEvent(cfg.dom.login_bar_friend_menu_label, "click", function () {
				window.open ( "http://icp.api.sina.com.cn/friend/myfriends.php");
			});
			$addEvent(cfg.dom.operation_tips_close,'click',function(){//\u64cd\u4f5c\u63d0\u793a xy
				if(cfg.dom.operation_tips)
					cfg.dom.operation_tips.style.display="none";
				if ($Cookie.getCookie("platform_tray_tips") == "") {
					$Cookie.setCookie("platform_tray_tips", "true", 5000000,"/",".sina.com.cn");
				}
				$stopEvent();
			});
			$addEvent(cfg.dom.message_tips_enter,"click",menu_func.show_msg_menu);
			$addEvent(cfg.dom.message_tips_close,'click',function(){cfg.dom.message_tips.style.display="none";});
		}
		$addEvent(cfg.dom.login_bar_search_menu_label, "click", menu_func.show_search_menu);
		$addEvent(cfg.dom.login_bar_search_menu_arrow, "click", menu_func.show_search_menu);
		$addEvent(cfg.dom.login_bar_search_form, "submit", menu_func.submit_search_menu);
		$addEvent(cfg.dom.login_bar_video,'click',menu_func.show_video_menu);
		// \u641c\u7d22Item\u7684\u70b9\u51fb
		$addEvent(cfg.dom.search_menu, "click", menu_func.search_item_func);
		// \u83dc\u5355\u663e\u793a\u9690\u85cf\u76f8\u5173
		$addEvent(document, "mouseup", menu_func.hidden_menu);
	};
	control.event_pro_init = function () {
		if (control.check_login() == true) {
		}
	};
	control.init = function (opts) {
		trace("<b>\u521d\u59cb\u5316\u5e03\u7801\u4f20\u5165\u53c2\u6570</b>", {bgColor: "#ff6600"});
		$parseParam(cfg.args, opts);
		cfg.conn_name = "Sina_Connect_Platform_" + cfg.args.uid + "_" + $ie;
		trace("<b>\u4e3b\u521d\u59cb\u5316</b>", {bgColor: "#ff6600"});
		trace("<b>\u6258\u76d8 -> DOM\u521d\u59cb\u5316</b>", {bgColor: "#333"});
		view.bar.dom_init();
		var sType = opts.type;
		// \u8bbe\u7f6e\u56fe\u6807\u70b9\u51fb
		if(sType=="search"){
			cfg.dom.login_bar_logo_link.href=cfg.base[sType].href;
			cfg.dom.login_bar_logo_link.target = "_self";
		}else{
			cfg.dom.login_bar_logo_link.href = cfg.base[sType].href;
			cfg.dom.login_bar_logo_link.target = "_blank";
		}
		cfg.dom.login_help_link.href=cfg.base[sType].helplink;
		// \u8bbe\u7f6eHome\u56fe\u6807
		if (sType != "photo" && sType!="icp" && sType!="music") {
			cfg.dom.login_bar_logo_link.className = "logoPic lp_" + sType;
			cfg.dom.login_bar_logo_link.parentNode.alt = cfg.dom.login_bar_logo_link.parentNode.title = cfg.base[sType].alt;
		}else{
			cfg.dom.login_bar_logo_link.className = "logoPic lp_blog";
			cfg.dom.login_bar_logo_link.parentNode.alt = cfg.dom.login_bar_logo_link.parentNode.title = cfg.base["blog"].alt;
		}
		try {
			setTimeout(function(){
				control.base_init();
			}, 100);
		}catch(e){
//			trace(e.description);
		}
	};
	/**
	 * \u5bf9\u5916\u65b9\u6cd5\u7684\u539f\u578b
	 */
	control.base_init = function () {
		if(cfg.base_init == true)return;
		cfg.base_init = true;
		if(control.check_login() == true) {
			trace("<b>APP\u5217\u8868\u83dc\u5355 -> \u5199\u5165HTML</b>", {bgColor: "#333"});
			$addHTML(cfg.dom.login_bar, view.app_menu.get_html());
			trace("<b>APP\u5217\u8868\u83dc\u5355 -> DOM\u521d\u59cb\u5316(\u5f02\u6b65)</b>", {bgColor: "#333"});
			view.app_menu.dom_init();
			trace("<b>\u6258\u76d8 -> \u6635\u79f0\u8bfb\u53d6</b>", {bgColor: "#333"});
			var uicScriptLoader = new JsLoader();
			uicScriptLoader.onsuccess = function() {
				if(window.platform_nick_tray) {
					cfg.args.nick = platform_nick_tray[cfg.args.uid];
					control.set_base_info(cfg.args);
				}
			};
			uicScriptLoader.onfailure = function () {
				cfg.args.nick = cfg.args.uid;
				control.set_base_info(cfg.args);
			};
			uicScriptLoader.load("http://uic.sinajs.cn/uic?type=nick&uids=" + cfg.args.uid + "&varname=platform_nick_tray", "utf-8");
			// \u8bbe\u7f6e\u57fa\u672c\u4fe1\u606f
			control.set_base_info(cfg.args);
			trace("<b>\u63d0\u9192\u83dc\u5355 -> \u5199\u5165HTML</b>", {bgColor: "#333"});
			$addHTML(cfg.dom.login_bar, view.msg_menu.get_html());
			trace("<b>\u63d0\u9192\u83dc\u5355 -> DOM\u521d\u59cb\u5316</b>", {bgColor: "#333"});
			view.msg_menu.dom_init();
			trace("<b>\u97f3\u4e50\u5217\u8868\u83dc\u5355 -> \u5199\u5165HTML</b>", {bgColor: "#333"});
			$addHTML(cfg.dom.login_bar, view.music_menu.get_html());
			trace("<b>\u97f3\u4e50\u5217\u8868\u83dc\u5355 -> DOM\u521d\u59cb\u5316</b>", {bgColor: "#333"});
			view.music_menu.dom_init();
			trace("<b>\u97f3\u4e50\u5217\u8868\u83dc\u5355 -> \u5199\u5165Swf</b>", {bgColor: "#333"});
			view.music_menu.write_swf();
			trace("<b>\u6258\u76d8 -> \u97f3\u4e50\u64ad\u653e\u5668\u72b6\u6001\u521d\u59cb\u5316</b>", {bgColor: "#333"});
			view.player.stop(true);
			//for (var key in cfg.dom) {trace(key, {color: "yellow"});}
		}
		else {
			// \u8bbe\u7f6e\u57fa\u672c\u4fe1\u606f
			control.set_base_info(cfg.args);
		}
		trace("<b>\u641c\u7d22\u83dc\u5355 -> \u5199\u5165HTML</b>", {bgColor: "#333"});
		$addHTML(cfg.dom.login_bar, view.search_menu.get_html());
		trace("<b>\u641c\u7d22\u83dc\u5355 -> DOM\u521d\u59cb\u5316</b>", {bgColor: "#333"});
		view.search_menu.dom_init();
		if(cfg.args.type=="vblog"){
			trace("<b>\u64ad\u5ba2\u83dc\u5355 -> \u5199\u5165HTML</b>", {bgColor: "#333"});
			$addHTML(cfg.dom.login_bar, view.video_menu.get_html());
			trace("<b>\u64ad\u5ba2\u83dc\u5355 -> DOM\u521d\u59cb\u5316</b>", {bgColor: "#333"});
			view.video_menu.dom_init();
		}
		trace("<b>\u6258\u76d8 -> \u4e8b\u4ef6\u521d\u59cb\u5316</b>", {bgColor: "#333"});
		control.event_init();
	};
	control.pro_init = function () {
		setTimeout(function () {
			if(cfg.base_init != true) {
				control.base_init();
			}
			if (control.check_login() == true) {
				trace("<b>\u6b21\u521d\u59cb\u5316</b>", {
					bgColor: "#ff6600"
				});
				trace("<b>\u4e8b\u4ef6\u521d\u59cb\u5316</b>", {
					bgColor: "#333"
				});
//				setTimeout(function () {
					control.create_connect();
//				}, 3000);
			}
			control.event_pro_init();
		}, 1);
	};
	// \u8bbe\u7f6e\u57fa\u672c\u4fe1\u606f
	control.set_base_info = function (oCFG) {
		var sType = oCFG.type;
		var sNick = oCFG.nick;
		var sUID = oCFG.uid;
		// \u8bbe\u7f6e\u9ed8\u8ba4\u641c\u7d22\u9879
		menu_func.set_search_input(sType);
		if (control.check_login() == true) {
			// \u8bbe\u7f6e\u9000\u51fa\u767b\u9646\u94fe\u63a5
			cfg.dom.login_bar_loginout_label.href = "http://login.sina.com.cn/cgi/login/logout.php";//?url=" + encodeURI(window.location.href);
			// \u5199\u6635\u79f0
			cfg.dom.login_bar_app_menu_label.innerHTML = sNick == null? sUID: sNick;
			//\u64cd\u4f5c\u63d0\u793a xy
//			if ($Cookie.getCookie("platform_tray_tips") == ""&& sType =="icp") {
//				var pos = $getXY(cfg.dom.login_bar_app_menu_label);
//				var arrow_pos = [-18, 19];
//				trace(pos[0] + arrow_pos[0]);
//				trace(cfg.dom.operation_tips.innerHTML);
//				cfg.dom.operation_tips.style.display = "";
//				cfg.dom.operation_tips.style.left = ($ie ?pos[0] + arrow_pos[0]-2:pos[0] + arrow_pos[0]) + "px";
//				cfg.dom.operation_tips.style.top = (pos[1] + arrow_pos[1]) + "px";
//			}
			if(sType=="vblog"){
				cfg.dom.login_bar_video_line.style.display="";
				cfg.dom.login_bar_video_btn.style.display="";
			}
			try {
				// app\u4e2d\u7684\u5404\u4ea7\u54c1\u9009\u9879
				if(cfg.dom.app_menu_blog_item) {
					cfg.dom.app_menu_blog_item.href = "http://blog.sina.com.cn/u/" + sUID;
					cfg.dom.app_menu_photo_item.href = "http://photo.blog.sina.com.cn/u/" + sUID;
					cfg.dom.app_menu_music_item.href = "http://music.sina.com.cn/m/" + sUID;
					cfg.dom.app_menu_video_item.href = "http://you.video.sina.com.cn/m/" + sUID;
					cfg.dom.app_menu_personal_item.href = "http://profile.blog.sina.com.cn/u/" + sUID;
					cfg.dom.app_menu_update_base.href = "http://icp.api.sina.com.cn/person/update_base.php?productid=" + cfg.base[sType].product + "&url=" + escape(window.location.href);
					cfg.dom.app_menu_password_base.href = "http://icp.api.sina.com.cn/person/modify_pass.php?productid=" + cfg.base[sType].product + "&url=" + escape(window.location.href);
				}
			}catch(e){}
		}
		else {
//			if( typeof $login =="undefined"){ //\u5b9e\u73b0\u6258\u76d8\u767b\u5f55\u6309\u94ae\u4e0d\u8981\u8dd1\u5230\u767b\u9646\u9875\uff0c\u5e76\u4e14\u80fd\u968f\u65f6\u70b9\u51fa\u6765\u7684\u529f\u80fd\u3002xy 2008-12-12
//				if(sType =="other" || sType=="search") cfg.dom.login_login_btn.parentNode.parentNode.style.display="";
//				else view.bar.showLoginBtn();
//			}
			cfg.dom.login_reg_btn.href = cfg.base[sType].reg;
			//\u8fd0\u8425\u63a8\u5e7f xy
			if (sType == "blog" ||  sType == "photo" ||sType == "music" ) {
				cfg.dom.login_operation_first_btn.innerHTML = cfg.base[sType].name;
				if(sType == "photo")
					cfg.dom.login_operation_first_btn.href ="http://photo.blog.sina.com.cn";
				else
					cfg.dom.login_operation_first_btn.href = cfg.base[sType].href;
				cfg.dom.login_operation_second_btn.innerHTML = cfg.base[sType].operation_second;
				cfg.dom.login_operation_second_btn.href = cfg.base[sType].operation_second_href;
			}else if(sType == "vblog"){
//				cfg.dom.login_operation_first_btn.innerHTML = cfg.base[sType].name;
//				cfg.dom.login_operation_first_btn.href = cfg.base[sType].href;
				cfg.dom.login_yunying_span.innerHTML='<a href="http://v.sina.com.cn" target="_blank">\u64ad\u5ba2\u9996\u9875</a>&nbsp;&nbsp;<a href="http://video.sina.com.cn" target="_blank">\u89c6\u9891\u9996\u9875</a>';
				cfg.dom.login_bar_video_btn.style.display="";
				cfg.dom.login_bar_operation_span.style.display="none";
				cfg.dom.login_ad_content.style.display="none";
			}
			cfg.dom.login_login_btn.onclick = function () {//\u8be5\u65b9\u6cd5\u7528\u6765\u5bf9\u767b\u9646\u6309\u94ae\u4e8b\u4ef6\u8fdb\u884c\u5904\u7406
				try {
					$login();
				}
				catch(e) {
					setTimeout(function () {
						window.location.href = "http://blog.sina.com.cn/login?r="+window.location.href;
					}, 1);
				}
			};
		}
	};
	//\u64ad\u5ba2\u70b9\u64ad\u5355\u64cd\u4f5c\u51fd\u6570 xy
	control.show_video = function(num,href,callback){
		trace("\u70b9\u64ad\u5355\u4e8b\u4ef6");
		cfg.dom.login_bar_video.innerHTML="<strong>\u70b9\u64ad\u5355</strong><em>("+num+")</em>";
		cfg.dom.video_number.value=num;
		cfg.dom.video_play_btn.href=href;
		cfg.dom.video_play_btn.target="_blank";
		cfg.dom.video_clear_btn["onclick"] = function(){
			callback();
		}
	};
	control.close_video=function(){
		cfg.dom.video_menu1.style.display="none";
		cfg.dom.video_menu2.style.display="none";
	};
	// \u901a\u8baf\u7528Flash\u5b8c\u6210\u540e\u8c03\u7528
	control.init_connect = function () {
		cfg.dom.login_conn_swf.register({
			channel_name: cfg.conn_name,
			callback_function: "SinaSysTray.conn_server"
		});
	};
	// \u5199\u5165\u901a\u8baf\u7528Flash
	control.create_connect = function () {
		//Sina.util.Swf.Add("http://s.app.space.sina.com.cn/swf/public/share_connect.swf", cfg.dom.login_conn_swf.id, "1", "1", "", "", "", {
		Sina.util.Swf.Add("http://sjs.sinajs.cn/common/js/share_connect.swf", cfg.dom.login_conn_swf.id, "1", "1", "", "", "", {
			allowScriptAccess: "always",
			wmode: "transparent"
		});
		Sina.util.Swf.Add("http://music.sina.com.cn/shequ/sns/flash/SMC_C.swf", cfg.dom.login_music_swf.id, "1", "1", "", "", "", {
			allowScriptAccess: "always",
			wmode: "transparent"
		});
		Sina.util.Swf.Init();
		(function () {
			cfg.dom.login_conn_swf = $E(cfg.dom.login_conn_swf.id);
			cfg.dom.login_music_swf = $E(cfg.dom.login_music_swf.id);
			if(typeof cfg.dom.login_conn_swf != "function") {
				setTimeout(arguments.callee, 100);
			}
		})();
		(function () {
//			trace(cfg.dom.login_conn_swf.register);
			if(cfg.dom.login_conn_swf.register != null) {
				control.init_connect();
			}
			else {
				setTimeout(arguments.callee, 1000);
			}
		})();
	};
	control.set_ad = function (oAD) {
		if(cfg.dom.login_ad_content) {
			cfg.dom.login_ad_content.innerHTML = "<a href='" + oAD.link + "' target='" + (oAD.target == null? "_self": oAD.target) + "'>" + oAD.label+ "</a>";
		}
	};
	control.get_msg = function () {
		// \u83b7\u53d6\u6d88\u606f
		cfg.dom.login_conn_swf.webimcall({
			channel_name: cfg.conn_name,
			loader_name: "get_msg",
			url: cfg.args.type=="search"?"http://icp.cws.api.sina.com.cn/unread/unread.php?uid=" + cfg.args.uid + "&product=icp&rnd=" + new Date().valueOf():"http://icp.cws.api.sina.com.cn/unread/unread.php?uid=" + cfg.args.uid + "&product=" + cfg.args.type + "&rnd=" + new Date().valueOf(),
			callback_function: "SinaSysTray.conn_msg"
		});
		//\u8bbe\u7f6e\u7559\u8a00\u5730\u5740 xy
		cfg.dom.msg_menu_leavemsg_link.href="http://profile.blog.sina.com.cn/wall.php?uid="+cfg.args.uid;
	};
	function JsLoader(){
		this.load = function(url, charset){
			var head = document.getElementsByTagName("head")[0];
			var ss = document.getElementsByTagName("script");
			for (var i = 0; i < ss.length; i++) {
				if (ss[i].src && ss[i].src.indexOf(url) != -1) {
					head.removeChild(ss[i]);
				}
			}
			var s = document.createElement("script");
			s.type = "text/javascript";
			s.src = url;
			s.charset = charset ? charset : "utf-8";
			head.appendChild(s);
			var self = this;
			s.onload = s.onreadystatechange = function(){
				if (this.readyState && this.readyState == "loading")
					return;
				self.onsuccess();
			};
			s.onerror = function(){
				head.removeChild(s);
				self.onfailure();
			};
		};
		this.onsuccess = function(){
		};
		this.onfailure = function(){
		};
	}
	//-- \u65b9\u6cd5\u5217\u8868 ----------------------------------------------------------------
	var menu_func = {
		// \u9690\u85cf\u83dc\u5355
		hidden_menu: function (bView) {
			for(var key in cfg.menu_list) {
				if($hitTest(cfg.menu_list[key], $getEvent()) == true) {
					cfg.menu_list[key].style.display = "none";
					if(typeof window.scope != "undefined" && key=="msg_menu" )
						window.scope.ishiddenmsgmenu=true;
				}else{
					if(typeof window.scope != "undefined" && key=="msg_menu")
						window.scope.ishiddenmsgmenu=false;
				}
			}
			var shadow=document.getElementById('platform_tray_shadow');
			if(typeof shadow=="undefined"||shadow==null){}
			else{
				shadow.style.left="-1000px";
				shadow.style.top="0px";
			}
		},
		// APP\u5217\u8868\u83dc\u5355\u7684\u5448\u73b0
		app_show_menu: function () {
			trace("APP\u5217\u8868\u83dc\u5355\u88ab\u70b9\u51fb", {color: "#999"});
			//\u70b9\u51fb\u540e\u8bbe\u7f6e\u64cd\u4f5c\u63d0\u793a\u7684cookie
			if ($Cookie.getCookie("platform_tray_tips") == "") {
				$Cookie.setCookie("platform_tray_tips", "true", 5000000,"/",".sina.com.cn");
			}
			cfg.dom.operation_tips.style.display = "none";
			var pos = $getXY(cfg.dom.login_bar_app_menu_arrow);
			var arrow_pos = [-74, 10];
			menu_func.hidden_menu();
			cfg.dom.app_menu.style.display = "";
			cfg.dom.app_menu.style.left = ($ie ?pos[0] + arrow_pos[0]-2:pos[0] + arrow_pos[0]) + "px";
			cfg.dom.app_menu.style.top = (pos[1] + arrow_pos[1]) + "px";
			view.createShadow(cfg.dom.app_menu,"app");
			$stopEvent();
		},
		// -- \u63d0\u9192 --------------------------------------------------------
		msg_get_data: function () {
			trace("<b>\u63d0\u9192\u5217\u8868\u83dc\u5355 -> \u83b7\u53d6\u63d0\u9192\u6570\u636e</b>", {bgColor: "#333"});
			view.msg_menu.view_list();
		},
		// \u641c\u7d22\u70b9\u51fb
		search_item_func: function () {
			var node = $getTarget($getEvent());
			menu_func.set_search_input(node.getAttribute("b_value"));
			menu_func.show_search_menu(false);
		},
		set_search_input: function (sValue) {
			var action;
			var label;
			var i_name;
			var g_name;
			cfg.dom.login_bar_search_form.target = "_blank";
			switch (sValue) {
				case "blog":
					// k
					action = "http://uni.sina.com.cn/c.php";
					cfg.dom.login_bar_search_hide_k.value = cfg.dom.login_bar_search_input.value;
					cfg.dom.login_bar_search_hide_t.value = "blog";
					cfg.dom.login_bar_search_hide_ts.value = "";
					label = "\u535a\u6587";
					break;
				case "bauthor":
					// k
					action = "http://uni.sina.com.cn/c.php";
					cfg.dom.login_bar_search_hide_k.value = cfg.dom.login_bar_search_input.value;
					cfg.dom.login_bar_search_hide_t.value = "blog";
					cfg.dom.login_bar_search_hide_ts.value = "bauthor";
					label = "\u535a\u4e3b";
					break;
				case "photo":
					// k
					action = "http://uni.sina.com.cn/c.php";
					cfg.dom.login_bar_search_hide_k.value = cfg.dom.login_bar_search_input.value;
					cfg.dom.login_bar_search_hide_t.value = "album";
					cfg.dom.login_bar_search_hide_ts.value = "";
					label = "\u56fe\u7247";
					break;
				case "music":
					// key
					action = "http://music.sina.com.cn/yueku/search/s.php";
					cfg.dom.login_bar_search_hide_key.value = cfg.dom.login_bar_search_input.value;
					cfg.dom.login_bar_search_hide_t.value = "song";
					cfg.dom.login_bar_search_hide_ts.value = "";
					label = "\u97f3\u4e50";
					cfg.dom.login_bar_search_form.target = "_blank";
					break;
				case "tiezi":
					// k
					action = "http://uni.sina.com.cn/c.php";
					cfg.dom.login_bar_search_hide_k.value = cfg.dom.login_bar_search_input.value;
					cfg.dom.login_bar_search_hide_t.value = "forum";
					cfg.dom.login_bar_search_hide_ts.value = "";
					label = "\u8bba\u575b";
					break;
				case "quanzi":
					// k
					action = "http://uni.sina.com.cn/c.php";
					cfg.dom.login_bar_search_hide_k.value = cfg.dom.login_bar_search_input.value;
					cfg.dom.login_bar_search_hide_t.value = "group";
					cfg.dom.login_bar_search_hide_ts.value = "";
					label = "\u5708\u5b50";
					break;
				case "bar":
					// k
					action = "http://uni.sina.com.cn/c.php";
					cfg.dom.login_bar_search_hide_k.value = cfg.dom.login_bar_search_input.value;
					cfg.dom.login_bar_search_hide_t.value = "bar";
					cfg.dom.login_bar_search_hide_ts.value = "";
					label = "\u65b0\u6d6a\u5427";
					break;
				case "vblog":
					// k
					action = "http://uni.sina.com.cn/c.php";
					cfg.dom.login_bar_search_hide_k.value = cfg.dom.login_bar_search_input.value;
					cfg.dom.login_bar_search_hide_t.value = "video";
					cfg.dom.login_bar_search_hide_ts.value = "";
					label = "\u89c6\u9891";
					break;
				case "vauthor":
					// k
					action = "http://uni.sina.com.cn/c.php";
					cfg.dom.login_bar_search_hide_k.value = cfg.dom.login_bar_search_input.value;
					cfg.dom.login_bar_search_hide_t.value = "video";
					cfg.dom.login_bar_search_hide_ts.value = "vauthor";
					label = "\u64ad\u4e3b";
					break;
				default :
					// k
					action = "http://uni.sina.com.cn/c.php";
					cfg.dom.login_bar_search_hide_k.value = cfg.dom.login_bar_search_input.value;
					cfg.dom.login_bar_search_hide_t.value = "";
					cfg.dom.login_bar_search_hide_ts.value = "";
					cfg.dom.login_bar_search_form.target="_blank";
					label = "\u7efc\u5408";
					break;
			}
			cfg.dom.login_bar_search_menu_label.innerHTML = label;
			cfg.dom.login_bar_search_form.action = action;
//			cfg.dom.login_bar_search_input.focus();
			cfg.tray_search_type = sValue;
		},
		submit_search_menu: function () {
			var sValue = cfg.tray_search_type;
			var b_value = cfg.dom.login_bar_search_input.value;
			switch (sValue) {
				case "space":
					cfg.dom.login_bar_search_hide_k.value = b_value;
					break;
				case "blog":
					cfg.dom.login_bar_search_hide_k.value = b_value;
					break;
				case "photo":
					cfg.dom.login_bar_search_hide_k.value = b_value;
					break;
				case "music":
					cfg.dom.login_bar_search_hide_key.value = b_value;
					break;
				case "vblog":
					cfg.dom.login_bar_search_hide_k.value = b_value;
					break;
				case "tiezi":
					cfg.dom.login_bar_search_hide_k.value = b_value;
					break;
				case "bar":
					cfg.dom.login_bar_search_hide_k.value = b_value;
					break;
				case "quanzi":
					cfg.dom.login_bar_search_hide_k.value = b_value;
					break;
				case "bauthor":
					cfg.dom.login_bar_search_hide_k.value = b_value;
					break;
				case "vauthor":
					cfg.dom.login_bar_search_hide_k.value = b_value;
					break;
				default :
					cfg.dom.login_bar_search_hide_k.value = b_value;
					break;
			}
		},
		show_msg_menu: function () {
			if(typeof window.scope != "undefined")
				window.scope.ishiddenmsgmenu=false;
			cfg.dom.message_tips.style.display="none";
			trace("\u63d0\u9192\u83dc\u5355\u88ab\u70b9\u51fb", {color: "#999"});
			$suinclude("http://hint.sinamail.sina.com.cn/mailproxy/mail.php", function(){
			var pattern = /(@sina.com|@vip.sina.com|@sina.cn|@my3ia.sina.com|@2008.sina.com)$/g;
			if(typeof window.sinamailinfo !="undefined" && window.sinamailinfo.result == true && pattern.test(window.sinamailinfo.email)==true){
				var sina_mail_count = window.sinamailinfo.unreadmail || "0";
				cfg.dom.msg_menu_mail_link.href = window.sinamailinfo.url;
				if (sina_mail_count != "0")
					cfg.dom.msg_menu_mail_item.innerHTML = "&nbsp;<em>(" + sina_mail_count + ")</em>";
				else {
					cfg.dom.msg_menu_mail_item.innerHTML = "";
				}
				cfg.dom.msg_menu_mail_span.style.display="";
				cfg.dom.msg_menu_leavemsg_span.className="";
				cfg.dom.msg_menu_mail_span.className="noline";
			}
			});
			var pos = $getXY(cfg.dom.login_bar_msg_menu_arrow);
			var arrow_pos = [-74, 10];
			menu_func.hidden_menu();
			cfg.dom.msg_menu.style.display = "";
			cfg.dom.msg_menu.style.left = ($ie ?pos[0] + arrow_pos[0]-2:pos[0] + arrow_pos[0]) + "px";
			cfg.dom.msg_menu.style.top = (pos[1] + arrow_pos[1]) + "px";
			conn_reload();
			trace("\u8bfb\u53d6\u90ae\u4ef6\u63a5\u53e3",{color:"#888"});
			setTimeout(function(){view.createShadow(cfg.dom.msg_menu,"msg");},5);
			$stopEvent();
		},
		show_search_menu: function (bView) {
			trace("\u641c\u7d22\u83dc\u5355\u88ab\u70b9\u51fb", {color: "#999"});
			var pos = $getXY(cfg.dom.login_bar_search_menu_label);
			var arrow_pos = [0, 22];
			menu_func.hidden_menu();
			if (bView != false) {
				cfg.dom.search_menu.style.display = "";
			}
			else {
				cfg.dom.search_menu.style.display = "none";
			}
			cfg.dom.search_menu.style.left = ($ie ?pos[0] + arrow_pos[0]-2:pos[0] + arrow_pos[0]) + "px";
			cfg.dom.search_menu.style.top = (pos[1] + arrow_pos[1]) + "px";
			$stopEvent();
		},
		show_music_menu: function () {
			trace("\u97f3\u4e50\u5217\u8868\u83dc\u5355\u88ab\u70b9\u51fb", {color: "#999"});
			var pos = $getXY(cfg.dom.login_bar_music_menu_label);
			var arrow_pos = [-40, 36];
			menu_func.hidden_menu();
			cfg.dom.music_menu.style.display = "";
			cfg.dom.music_menu.style.left = ($ie ?pos[0] + arrow_pos[0]-3:pos[0] + arrow_pos[0]) + "px";
			cfg.dom.music_menu.style.top = (pos[1] + arrow_pos[1]-2) + "px";
			view.createShadow(cfg.dom.music_menu,"music");
			$stopEvent();
		},
		show_video_menu:function(){
			if(cfg.dom.video_number.value==0){
				trace("\u64ad\u5ba2\u5217\u8868\u83dc\u5355\u88ab\u70b9\u51fb", {color: "#999"});
				var pos = $getXY(cfg.dom.login_bar_video);
				var arrow_pos = [10, 10];
				menu_func.hidden_menu();
				cfg.dom.video_menu2.style.display = "";
				cfg.dom.video_menu2.style.left = ($ie6 ?pos[0] + arrow_pos[0]-2:pos[0] + arrow_pos[0]) + "px";
				cfg.dom.video_menu2.style.top = (pos[1] + arrow_pos[1]) + "px";
				$stopEvent();
			}else{
				trace("\u64ad\u5ba2\u5217\u8868\u83dc\u5355\u88ab\u70b9\u51fb", {color: "#999"});
				var pos = $getXY(cfg.dom.login_bar_video);
				var arrow_pos = [10,10];
				menu_func.hidden_menu();
				cfg.dom.video_menu1.style.display = "";
				cfg.dom.video_menu1.style.left = ($ie6 ?pos[0] + arrow_pos[0]-2:pos[0] + arrow_pos[0]) + "px";
				cfg.dom.video_menu1.style.top = (pos[1] + arrow_pos[1]) + "px";
				$stopEvent();
			}
		},
		swap_menu_css: function (sActionType, oNode) {
			var clsName = "nbg1";
			if(sActionType == "over")clsName = "nbg1on";
			if ($hitTest(oNode, $getEvent()) == true && sActionType == "over") {
				clsName = "nbg1";
			}
			oNode.className = clsName;
		}
	};
//	var conn_nick = function (sData) {
//		try{
//
//			var oData = $toJson(sData);
//		}
//		catch(e){
//			var oData = {};
//		}
//		var nick = oData[cfg.args.uid];
//		if(nick == null || nick == "") nick = cfg.args.uid;
//		cfg.args.nick = nick;
//
//		control.set_base_info(cfg.args);
//	};
	var conn_msg = function (sData) {
		//var sData = '{"code":"A00006","data":{"notice":1,"invite":0,"message":4,"blogcomment":0,"blogrecomment":0,"photocomment":0}}'
		try{
			var oData = $toJson(sData);
		}
		catch(e){
			var oData = {};
		}
		if(oData.code == "A00006") {
			cfg.data.msg = oData.data;
			menu_func.msg_get_data();
		}
		var type = cfg.dom.login_conn_swf.getType(cfg.conn_name);
		clearTimeout(get_timer);
		if(type == "Server") {
			cfg.dom.login_conn_swf.dispatch(cfg.conn_name, "SinaSysTray.conn_msg", sData);
			get_timer = setTimeout(control.get_msg, 1000 * 60 * 4);
		}
	};
	var conn_product = function (sData) {
		try{
			var oData = $toJson(sData);
		}
		catch(e){
			var oData = {};
		}
		var product = oData[cfg.args.uid];
		var blog_product = ("0x" + product) & 0x00000001;
		var photo_product = ("0x" + product) & 0x00000008;
		var video_product = ("0x"+ product) & 0x00000002;
		if(blog_product != 0) {
			cfg.dom.msg_menu_blogcomment_span.style.display = "";
			cfg.dom.msg_menu_blogrecomment_span.style.display = "";
		}
		else {
			cfg.dom.msg_menu_blogcomment_span.style.display = "none";
			cfg.dom.msg_menu_blogrecomment_span.style.display = "none";
		}
		if(photo_product != 0) {
			cfg.dom.msg_menu_photocomment_span.style.display = "";
		}
		else {
			cfg.dom.msg_menu_photocomment_span.style.display = "none";
		}
		if(video_product != 0) {
			cfg.dom.msg_menu_videocomment_span.style.display = "";
		}
		else {
			cfg.dom.msg_menu_videocomment_span.style.display = "none";
		}
		if(true) {
			cfg.dom.msg_menu_leavemsg_span.style.display = "";
		}
		else {
			cfg.dom.msg_menu_leavemsg_span.style.display = "none";
		}
	};
	var conn_server = function (sID, sType) {
//		if(sType == "Server") {
//			document.title = "Server";
//		}
//		else {
//			document.title = "Client";
//		}
		setTimeout(function () {
//			// \u83b7\u53d6\u6635\u79f0
//			cfg.dom.login_conn_swf.webimcall({
//				channel_name: cfg.conn_name,
//				loader_name: "get_nick",
//				url: "http://uic.sinajs.cn/uic?type=nick&uids=" + cfg.args.uid ,
//				callback_function: "SinaSysTray.conn_nick"
//			});
			// \u83b7\u53d6\u4ea7\u54c1\u72b6\u51b5
			cfg.dom.login_conn_swf.webimcall({
				channel_name: cfg.conn_name,
				loader_name: "get_product",
				url: "http://uic.sinajs.cn/uic?type=service&uids=" + cfg.args.uid ,
				callback_function: "SinaSysTray.conn_product"
			});
			// \u83b7\u53d6\u6d88\u606f
			control.get_msg();
		}, 500);
	};
	var conn_reload = function () {
//		trace("cfg.conn_name="+cfg.conn_name);
		var server_id = cfg.dom.login_conn_swf.getServer(cfg.conn_name);
		var id =  cfg.dom.login_conn_swf.getId(cfg.conn_name);
//		trace("conn_reload flash begin");
		cfg.dom.login_conn_swf.send(cfg.conn_name, server_id, "SinaSysTray.conn_reload_func");
//		trace("conn_reload flash end");
	};
	var conn_reload_func = function () {
		conn_server();
	};
	var refresh = function (sParentID, oArgs) {
		if(typeof cfg.dom.login_swf_parent !="undefined"){
			try{
				cfg.dom.login_swf_parent.innerHTML='<div id="login_conn_swf_{Tray}"></div><div id="login_music_swf_{Tray}"></div>';
				cfg.dom.login_conn_swf = control.get_node("login_conn_swf");
				cfg.dom.login_music_swf = control.get_node("login_music_swf");
			}catch(e){
				trace("\u5220\u9664flash\u7b26\u8282\u70b9\u5931\u8d25");
			}
		}
		cfg.base_init = false;
		$E(sParentID).innerHTML = view.bar.get_html();
		control.init(oArgs? oArgs: cfg.args);
		control.pro_init();
	};
	//-- \u5bf9\u5916\u65b9\u6cd5 --------------------------------------------------------------
	var ancestor = function () {};
	ancestor.prototype.getHTML = view.bar.get_html;
	ancestor.prototype.base_init = control.init;
	ancestor.prototype.pro_init = control.pro_init;
	//\u63d0\u4f9b\u7ed9\u64ad\u5ba2\u7684\u63a5\u53e3 xy
	ancestor.prototype.showVideo = control.show_video;
	ancestor.prototype.closeVideo = control.close_video;
	// \u63d0\u4f9b\u7ed9\u97f3\u4e50\u7684\u51e0\u4e2a\u63a5\u53e3
	ancestor.prototype.player = view.player;
	// \u8bbe\u7f6e\u5e7f\u544a
	ancestor.prototype.setAD = control.set_ad;
//	ancestor.prototype.conn_nick = conn_nick;
	ancestor.prototype.conn_msg = conn_msg;
//	ancestor.prototype.conn_flower = conn_flower;
	ancestor.prototype.conn_product = conn_product;
	ancestor.prototype.conn_server = conn_server;
	ancestor.prototype.conn_reload = conn_reload;
	ancestor.prototype.conn_reload_func = conn_reload_func;
	ancestor.prototype.refresh = refresh;
	window.SinaSysTray = new ancestor();
})();

