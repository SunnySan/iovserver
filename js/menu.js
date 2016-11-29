$(document).ready(function() {
	var	s = "";
	var	sClass = "";
	var sFile = "";
	var sLink = "";
	var url = window.location.pathname;
	var filename = url.substring(url.lastIndexOf('/')+1);	//目前的檔案名稱
	if (filename=="" || filename=="index.html") sFile = "首頁";
	if (filename=="setting-change-password.html") sFile = "變更密碼";
	
	/*
	if (filename=="case-new.html") sFile = "新增派工單";
	if (filename=="case-query.html") sFile = "派工單查詢";
	if (filename=="case-edit.html") sFile = "派工單修改";
	if (filename=="case-approve.html") sFile = "派工單簽核";
	if (filename=="setting-mydata.html") sFile = "我的基本資料";
	//if (filename=="setting-deputy.html") sFile = "設定代理人";
	*/

	if (sFile.length>0) sFile = "<span style='color:#FFFFFF;'>&nbsp-&nbsp" + sFile + "</span>";
	$('#pageName').append(sFile);

	sClass = (filename=="" || filename.indexOf("index.html")>-1 ? " class='active'" : "");
	s = "<li" + sClass + "><a href='.'>首頁</a>";
	/*
	sLink = "case-new.html";
	sClass = (filename.indexOf(sLink)>-1 ? " class='active'" : "");
	s += "<li" + sClass + "><a href='" + sLink + "'>新增派工單</a>";

	sLink = "case-query.html";
	sClass = (filename.indexOf(sLink)>-1 ? " class='active'" : "");
	s += "<li" + sClass + "><a href='" + sLink + "'>派工單查詢</a>";

	sLink = "case-approve.html";
	sClass = (filename.indexOf(sLink)>-1 ? " class='active'" : "");
	s += "<li" + sClass + "><a href='" + sLink + "'>派工單簽核</a>";
	*/

	s += "<li class='dropdown' id='menu-setting'><a href='' class='dropdown-toggle' data-toggle='dropdown'>設定<b class='caret'></b></a>";
	s += "	<ul class='dropdown-menu'>";
	sLink = "setting-change-password.html";
	sClass = (filename.indexOf(sLink)>-1 ? " class='active'" : "");
	s += "		<li><a href='" + sLink + "'>變更密碼</a></li>";

	s += "	</ul>";
	s += "</li>";

	s += "<li><a id='logoutUrl' href='#' onclick='clearCookie();'>登出</a></li>";
	s += "<input type='hidden' id='myUserID' name='myUserID' value=''>";
	s += "<input type='hidden' id='myUserName' name='myUserName' value=''>";
	s += "<input type='hidden' id='myUserRole' name='myUserRole' value=''>";
	$('#main-menu').html(s);
});
