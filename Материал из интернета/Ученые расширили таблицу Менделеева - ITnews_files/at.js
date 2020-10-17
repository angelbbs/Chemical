var adpro_max_w = 150;
var adpro_min_l = 5;
var adpro_max_a = 3;

function getEI(idname) {
	if (document.getElementById) { return document.getElementById(idname); }
	else if (document.all) { return document.all[idname]; }
	else { return null; }
}

var adpro_gX = 0;
var adpro_gY = 0;
function gXY() {
	var q = getEI('adpro_context');
	adpro_gX = q.offsetWidth;
	adpro_gY = q.offsetHeight;
	while(q) {
		adpro_gX += q.offsetLeft;
		adpro_gY += q.offsetTop;
		q = q.offsetParent;
	}
}

function showBlock(obj,u,t,d) {
	u = u.replace(/^http:\/\//, "");
	u = u.replace(/\/.*$/, "");
	bl = getEI('adpro_block');
	bl.innerHTML = '<style>.adpro_block td { font-family: Arial, Sans-Serif; } </style>' +
		'<table border="0" cellpadding="0" cellspacing="0">' +
		'<!--<tr><td align="right" style="font-size: 9px; color: #ccccdd; text-decoration: underline;">adPRO.com.ua</td></tr>-->' +
		'<tr><td><b style="font-size: 12px; color: #006699;">' + t + '</b></td></tr>' +
		'<tr><td style="color: #330000; font-size: 11px;">' + d + '</td></tr>' +
		'<tr><td style="color: #cc3300; font-size: 10px;">' + u + '</td></tr>' +
		'</table>';

	var q = obj;
	xoff = q.offsetWidth;
	yoff = q.offsetHeight;
	while(q) {
		xoff += q.offsetLeft;
		yoff += q.offsetTop;
		q = q.offsetParent;
	}
	gXY();
	while (xoff + 165 > adpro_gX) xoff -= 10;
	bl.style.left = xoff  + "px";
	bl.style.top = yoff + "px";
	bl.style.visibility = "visible";
}

function hideBlock() {
	getEI('adpro_block').style.visibility = "hidden";
}

var adpro_init = 0;
var Word = new Array;
var Click = new Array;
var Url = new Array;
var Title = new Array;
var Descr = new Array;

var arr_w = new Array;
var arr_i = new Array;
var content_obj;

var adpro_rep1 = 20;
function _p1() {
	setTimeout("parse();",500);
}

function parse() {
	content_obj = getEI('adpro_context');
	adpro_rep1--;
	while ((adpro_rep1) && (!content_obj)) {
		setTimeout("_p1();",250);
		return;
	}
	var content_txt = new String( ((content_obj) ? content_obj.innerHTML : '') );
	if (!content_txt) return;

	arr_w = content_txt.split(/\s+/);
	idx = 0; cnt_w = 0;
	for (i = 0; i < arr_w.length; i++) {
		if (cnt_w++ > adpro_max_w) break;
		if (arr_w[i].match(/<a/i)) idx++;
		j = (idx > 0) ? 0 : 1;
		if (arr_w[i].length < adpro_min_l) j = 0;
		arr_i[i] = j;
		if (arr_w[i].match(/a>/i)) idx--;
	}
	
	var c = '';
	for (i = 0; i < arr_i.length; i++) {
		if (arr_i[i]) {
			c += arr_w[i].replace(/<.+?>/g, "") + " ";
		}
	}

	var adpro_h='http://at.adpro.com.ua/t.cgi?txt='+unescape(c.replace(/[^a-zà-ÿ¸\s]/gi," "))+'&w='+adpro_max_a+'&d='+document.domain;
	getEI('adpro_at').src=adpro_h;
	_p();
}

var adpro_rep2 = 20;
function _p2() {
	setTimeout("_p();",500);
}

function _p() {
	adpro_rep2--;
	while ((adpro_rep2) && (!adpro_init)) {
		setTimeout("_p2();",250);
		return;
	}
	if ((!adpro_init) || (!content_obj)) return;
	var reS = "\\s\\.\\,\\?\\!\\;\\:\\'\\\"\\-\\(\\)\\<\\>\\]\\[\\&";

	var j = 0;
	while (j < Word.length) {
		var w = Word[j]; j++;
		var re = new RegExp("("+w+"[^"+reS+"]*)", "i");
		for (i = 0; i < arr_i.length; i++) {
			if ((arr_i[i]) && (re.test(arr_w[i]))) {
				var wt = arr_w[i];
				wt = wt.replace(/[^a-zà-ÿ¸\s].+$/gi,"");
				wt = wt.replace(/^.+[^a-zà-ÿ¸\s]/gi,"");
				if (w == wt) {
					var tt = arr_w[i].replace(re, getu("$1", Url[j-1], Click[j-1], Title[j-1], Descr[j-1]));
					arr_w[i] = tt;
					arr_i[i] = 0;
					Word[j-1] = '0';
					break;
				}
			}
		}
	}
	content_txt = arr_w.join(" ");
	content_obj.innerHTML = '<div id="adpro_block" class="adpro_block" style="width:160px;background-color:#ffffee; border:solid 1px #000000; padding:0 5px 5px 5px; z-index:99; left:0px; visibility:hidden; position:absolute; top:0px"></div>'+
		content_txt;
}


function getu(w,u,c,t,d) {
	return '<a href="http://at.adpro.com.ua/c.cgi?d='+adpro_init+'&a='+c+'&u='+escape(u)+'" style="border-bottom: 1px solid; text-decoration: underline;" target="_blank"'+
	" OnMouseOver=\"showBlock(this, '"+u+"','"+t+"', '"+d+"');\" OnMouseOut=\"hideBlock();\">"+
		w+'</a>';
}

setTimeout("parse();",500);
