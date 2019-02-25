<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%@page import="java.net.InetAddress" %>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="java.util.*" %>

<%@include file="00_constants.jsp"%>
<%@include file="00_utility.jsp"%>

<%
/***************輸入範例********************************************************
https://cms.gslssd.com/iovserver/ajaxGetDeviceStatus.jsp?masterId=12345678901234567891
*******************************************************************************/

/***************輸出範例********************************************************
{"resultText":"Success","Update_Date":"2019-02-23 16:01:22","imsis":[{"Status":"","IMSI":"1000000000000001","Slot":"0"},{"Status":"Active","IMSI":"1000000000000002","Slot":"1"}],"resultCode":"00000","messages":[{"Status":"Sent","Update_Date":"2019-02-23 16:01:22","Message":"AABBDDA6000001010100","Create_Date":"2019-02-23 15:58:12","id":"7"},{"Status":"Sent","Update_Date":"2019-02-23 16:01:08","Message":"AABBDDA5000001010100","Create_Date":"2019-02-23 15:58:08","id":"6"},{"Status":"Sent","Update_Date":"2019-02-23 16:01:08","Message":"AABBDDA4000001010100","Create_Date":"2019-02-23 15:57:58","id":"5"},{"Status":"Sent","Update_Date":"2019-02-23 16:01:07","Message":"AABBDDA6000001010100","Create_Date":"2019-02-23 15:56:02","id":"4"},{"Status":"Sent","Update_Date":"2019-02-23 16:01:07","Message":"AABBDDA5000001010100","Create_Date":"2019-02-23 15:55:54","id":"3"},{"Status":"Sent","Update_Date":"2019-02-23 16:00:43","Message":"AABBDDA4000001010100","Create_Date":"2019-02-23 15:55:26","id":"2"},{"Status":"Sent","Update_Date":"2019-02-23 00:00:00","Message":"test","Create_Date":"2019-02-23 00:00:00","id":"1"}],"Current_Slot":"1"}
*******************************************************************************/
%>

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html;charset=utf-8");
response.setHeader("Pragma","no-cache"); 
response.setHeader("Cache-Control","no-cache"); 
response.setDateHeader("Expires", 0); 

out.clear();	//注意，一定要有out.clear();，要不然client端無法解析XML，會認為XML格式有問題

JSONObject	obj=new JSONObject();

/*********************開始做事吧*********************/

String masterId		= nullToString(request.getParameter("masterId"), "");
if (beEmpty(masterId)){
	obj.put("resultCode", gcResultCodeParametersValidationError);
	obj.put("resultText", gcResultTextParametersValidationError);
	out.print(obj);
	out.flush();
	return;
}

String sSource = gcDataSourceNameCMSIOT;

Hashtable	ht					= new Hashtable();
String		sResultCode			= gcResultCodeSuccess;
String		sResultText			= gcResultTextSuccess;
String		s[][]				= null;
String		sSQL				= "";
String		sWhere				= "";

String		ss					= "";
int			i					= 0;
int			j					= 0;


//先看看DB裡有沒有這個Master ID
sSQL = "SELECT DATE_FORMAT(Update_Date,'%Y-%m-%d %H:%i:%s'), Current_Slot FROM bip_device";
sSQL += " WHERE Master_Id='" + masterId + "'";

ht = getDBData(sSQL, sSource);

sResultCode = ht.get("ResultCode").toString();
sResultText = ht.get("ResultText").toString();

if (sResultCode.equals(gcResultCodeSuccess)){	//有資料
	s = (String[][])ht.get("Data");
	obj.put("Update_Date", nullToString(s[0][0], ""));
	obj.put("Current_Slot", nullToString(s[0][1], ""));
}else{
	obj.put("resultCode", sResultCode);
	obj.put("resultText", sResultText);
	out.print(obj);
	out.flush();
	return;
}

//找出 slot 及 IMSI 資料

String[] fields1 = {"Slot", "IMSI", "Status"};
String[] fields2 = {"Slot", "IMSI", "Status"};

sSQL = "SELECT " + fields1[0];
for (i=1;i<fields1.length;i++){
	sSQL += ", " + fields1[i]; 
}
sSQL += " FROM bip_device_imsis";
sSQL += " WHERE Master_Id='" + masterId + "'";
sSQL += " ORDER BY Slot";

ht = getDBData(sSQL, sSource);

sResultCode = ht.get("ResultCode").toString();
sResultText = ht.get("ResultText").toString();

List  l1 = new LinkedList();
Map m1 = null;

if (sResultCode.equals(gcResultCodeSuccess)){	//有資料
	s = (String[][])ht.get("Data");
	for (i=0;i<s.length;i++){
		m1 = new HashMap();
		for (j=0;j<fields2.length;j++){
			m1.put(fields2[j], nullToString(s[i][j], ""));
		}
		l1.add(m1);
	}
}else{
	obj.put("resultCode", sResultCode);
	obj.put("resultText", sResultText);
	out.print(obj);
	out.flush();
	return;
}

obj.put("resultCode", sResultCode);
obj.put("resultText", sResultText);
obj.put("imsis", l1);

//找job紀錄
String[] fields3 = {"id", "DATE_FORMAT(Create_Date,'%Y-%m-%d %H:%i:%s')", "DATE_FORMAT(Update_Date,'%Y-%m-%d %H:%i:%s')", "Message", "Status"};
String[] fields4 = {"id", "Create_Date", "Update_Date", "Message", "Status"};

sSQL = "SELECT " + fields3[0];
for (i=1;i<fields3.length;i++){
	sSQL += ", " + fields3[i]; 
}
sSQL += " FROM bip_message_queue";
sSQL += " WHERE Master_Id='" + masterId + "'";
sSQL += " ORDER BY id DESC";
sSQL += " Limit 10";

ht = getDBData(sSQL, sSource);

sResultCode = ht.get("ResultCode").toString();
sResultText = ht.get("ResultText").toString();

l1 = new LinkedList();
m1 = null;

if (sResultCode.equals(gcResultCodeSuccess)){	//有資料
	s = (String[][])ht.get("Data");
	for (i=0;i<s.length;i++){
		m1 = new HashMap();
		for (j=0;j<fields4.length;j++){
			m1.put(fields4[j], nullToString(s[i][j], ""));
		}
		l1.add(m1);
	}
}

obj.put("messages", l1);


out.print(obj);
out.flush();

//writeLog("debug", obj.toString());
%>