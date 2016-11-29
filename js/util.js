/**********這個檔案裡是一些公用的函數**********/

/**********全域變數**********/
var sServerBaseURL = "./";	//Server端接收 request 的 URL 路徑

/**********取得 server API 的 base URL**********/
function getServerBaseURL(){
	return sServerBaseURL;
}	//function getServerBaseURL(){

/**********判斷字串是否為空值**********/
function beEmpty(s){
	return (s==null || s=='undefined' || s.length<1);
}	//function scrollToTop(){

/**********判斷字串是否有值**********/
function notEmpty(s){
	return (s!=null && s!='undefined' && s.length>0);
}	//function scrollToTop(){

/**********將金額字串加上千位的逗點**********/
function toCurrency(s){
	if (beEmpty(s)) return "";	//字串為空
	if (isNaN(s))	return s;	//不是數字，回覆原字串
	
	var i = 0;
	var j = 0;
	var k = 0;
	var l = 0;
	var s2 = "";
	s = trim(s);
	i = s.length;			//i為字串長度
	if (i<4) return s;		//長度太短，不用加逗點，直接回覆原字串
	j = Math.floor(i/3);	//j為字串長度除以3的商數
	k = i % 3;				//k為字串長度除以3的餘數
	s2 = "";
	if (k>0) s2 = s.substring(0, k);
	for (l=0;l<j;l++){
		s2 = s2 + (s2==""?"":",") + s.substring(k+(l*3), k+(l+1)*3);
	}
	return s2;
}

/**********將字串的空白去掉**********/
function trim(stringToTrim){
	return stringToTrim.replace(/^\s+|\s+$/g,"");
}

/**********判斷字串開頭是否為指定的字**********/
String.prototype.startsWith = function(prefix)
{
    return (this.substr(0, prefix.length) === prefix);
}
 
/**********判斷字串結尾是否為指定的字**********/
String.prototype.endsWith = function(suffix)
{
    return (this.substr(this.length - suffix.length) === suffix);
}
 
/**********判斷字串是否包含指定的字**********/
String.prototype.contains = function(txt)
{
    return (this.indexOf(txt) >= 0);
}

/**********取得某個 URL 參數的值，例如 http://target.SchoolID/set?text=abc **********/
function getParameterByName( name ){
	name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
	var regexS = "[\\?&]"+name+"=([^&#]*)";
	var regex = new RegExp( regexS );
	var results = regex.exec( window.location.href );
	if( results == null )
		return "";
	else
		return decodeURIComponent(results[1].replace(/\+/g, " "));
}

/**********檢查email格式是否正確**********/
function isEmail(email) { 
	var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}

/**********顯示loading中的BlockUI**********/
function showBlockUI(){
/*
	$.blockUI({
		message: '<img src="images/loading.gif">資料更新中，請稍候...</img>',
		css: {
			border: 'none',
			background: 'none',
			color: '#00FF00'
		},
		overlayCSS:{
			backgroundColor: '#000000',
			opacity:         0.5,
			cursor:          'wait'
		}
	});
*/
	
	$.blockUI({ 
		message: '<img src="images/loading.gif">資料更新中，請稍候...</img>',
		css:{
			border: 'none',
			padding: '15px',
			backgroundColor: '#000',
			'-webkit-border-radius': '10px',
			'-moz-border-radius': '10px',
			opacity: 0.95,
			color: '#00FF00'
		}
	}); 

	//$('.blockOverlay').attr('title','以滑鼠點擊灰色區域可回到主畫面').click($.unblockUI);	//若加這一行且有使用JQuery UI Tooltip，則這一行字在BlockUI關閉後仍會殘留在IE畫面上(Chrome不會)
	//$('.blockOverlay').click($.unblockUI);	//若加這一行且有使用JQuery UI Tooltip，則這一行字在BlockUI關閉後仍會殘留在IE畫面上(Chrome不會)

}

/**********解除BlockUI**********/
function unBlockUI(){
	$.unblockUI();
}

/**********取得今天日期，格式為：2013/10/3**********/
function getCurrentDate(){
	var currDate = new Date();	//目前時間
	var txtCurrDate = currDate.getFullYear() + "/" + (currDate.getMonth()+1) + "/" + currDate.getDate();	//今天日期，格式為：2013/10/3
	return txtCurrDate;
}

/**********取得今天時分秒，格式為：12:45:13**********/
function getCurrentTime(){
	var currDate = new Date();	//目前時間
	var h = currDate.getHours().toString();
	if (h.length==1) h = "0" + h;
	var m = currDate.getMinutes().toString();
	if (m.length==1) m = "0" + m;
	var s = currDate.getSeconds().toString();
	if (s.length==1) s = "0" + s;
	var txtCurrTime = h + ":" + m + ":" + s;	//今天時分秒，格式為：12:45:13
	return txtCurrTime;
}

/**********取得儲存在client端的變數值(從PC cookie或手機storage取得)**********/
function getLocalValue(key){
	var value = "";
	value = $.cookie(key);	//Browser，使用 cookie for JQuery
	if (beEmpty(value)) value="";
	return value;
}

/**********將變數值儲存在client端(PC cookie或手機storage)**********/
function setLocalValue(key, value){
	if (beEmpty(key)) return;
	$.cookie(key, value, { expires: 30, path: '/' });	//Browser，使用 cookie for JQuery，預設儲存30天
	return;
}

/**********顯示類似alert的message box**********/
function msgBox(msg, callbackClose){
	if ( typeof(dialogMessage) == "undefined"){
		$('body').append('<div id="dialogMessage" title="System Info."></div>');
	}
	$('#dialogMessage').html(msg);
	if (callbackClose==null){
		$( "#dialogMessage" ).dialog({
			modal: true,
			buttons: {
				Ok: function() {
					$( this ).dialog( "close" );
				}
			}
		});
	}else{
		$( "#dialogMessage" ).dialog({
			modal: true,
			buttons: {
				Ok: function() {
					$( this ).dialog( "close" );
					callbackClose
				}
			},
			close: callbackClose
		});
	}
}

/**********從 Server 擷取資料**********/
function getDataFromServer(sProgram, sData, sResponseType, SuccessCallback, bBlockUI){
	/*****************************************************************
	sProgram		server端程式名稱，例如 xxx.jsp
	sData			要post給server的資料
	sResponseType	希望server端回覆的資料類型，可為 json 或 xml
	SuccessCallback	成功從server取得資料時的處理程式(function)
	bBlockUI		是否顯示BlockUI，若未輸入此參數則預設為顯示BlockUI
	*****************************************************************/
	if (beEmpty(bBlockUI)) bBlockUI = true;
	if (beEmpty(sData)) sData = "ResponseType=" + sResponseType; else sData += "&ResponseType=" + sResponseType;
	$.ajax({
		url: sServerBaseURL + sProgram,
		type: 'POST', //根據實際情況，可以是'POST'或者'GET'
		beforeSend : (bBlockUI==true?showBlockUI:null),
		complete   : (bBlockUI==true?unBlockUI:null),
		data: sData,
		dataType: sResponseType, //指定數據類型，注意server要有一行：response.setContentType("text/xml;charset=utf-8");
		timeout: 60000, //設置timeout時間，以千分之一秒為單位，1000 = 1秒
		error: function (){	//錯誤提示
			msgBox('System busy!!');
		},
		success: function (data){ //ajax請求成功後do something with response data
			SuccessCallback(data);
		}	//success: function (data){ //ajax請求成功後do something with response data
	});	//$.ajax({
	return false;
}	//function sServerBaseURL(sProgram, sData, sResponseType, SuccessCallback){




