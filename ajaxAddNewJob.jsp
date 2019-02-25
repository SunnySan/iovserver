<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%@page import="java.net.InetAddress" %>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="java.util.*" %>

<%@include file="00_constants.jsp"%>
<%@include file="00_utility.jsp"%>

<%
/***************輸入範例********************************************************
http://localhost:8080/iovserver/ajaxRegisterIoTDevice.jsp?uuid=123456&username=sunny
*******************************************************************************/

/***************輸出範例********************************************************
所有資料
{"resultCode":"00000","orders":[{"Create_Date":"2015-01-19 23:08","Update_Date_CS":null,"Last_Name":"hung","Arrive_Date":null,"Update_Date_CHT":null,"PaymentStatus":"Pay Success","Nationality":"Antarctica","Subscriber_ID":"14082511441646962E96","Product_E_Name":"testCHTnameLengthabcdefghijklmno","Queen_MSISDN":"886921139327","SendEmail":"N","Email":"gffjh@ggkbv.com","Product_SC_Name":"中华001","Update_User_ID_CHT":null,"Gender":"Female","First_Name":"popyyyo","Payment_Order_ID":"TX1501192C3162E03BE67313","Update_User_ID_CS":null,"Product_ID":"CHT001","Product_TC_Name":"中華001","MSISDN":"886910543001","DownloadStatus":"Receipt"},{"Create_Date":"2015-01-19 23:03","Update_Date_CS":null,"Last_Name":"hung","Arrive_Date":null,"Update_Date_CHT":null,"PaymentStatus":"Pay Success","Nationality":"Antarctica","Subscriber_ID":"14082511441646962E96","Product_E_Name":"testCHTnameLengthabcdefghijklmno","Queen_MSISDN":"886921139327","SendEmail":"N","Email":"gffjh@ggkbv.com","Product_SC_Name":"中华001","Update_User_ID_CHT":null,"Gender":"Female","First_Name":"popyyyo","Payment_Order_ID":"TX15011901DA55595D5898AD","Update_User_ID_CS":null,"Product_ID":"CHT001","Product_TC_Name":"中華001","MSISDN":"886910543000","DownloadStatus":"Receipt"}],"resultText":"Success"}
單一資料
{"resultCode":"00000","orders":[{"Create_Date":"2015-01-19 23:03","Update_Date_CS":null,"Last_Name":"hung","Arrive_Date":null,"Update_Date_CHT":null,"PaymentStatus":"Pay Success","Nationality":"Antarctica","Subscriber_ID":"14082511441646962E96","Product_E_Name":"testCHTnameLengthabcdefghijklmno","Queen_MSISDN":"886921139327","SendEmail":"N","Email":"gffjh@ggkbv.com","Product_SC_Name":"中华001","Update_User_ID_CHT":null,"Gender":"Female","First_Name":"popyyyo","Payment_Order_ID":"TX15011901DA55595D5898AD","Update_User_ID_CS":null,"Product_ID":"CHT001","Product_TC_Name":"中華001","MSISDN":"886910543000","DownloadStatus":"Receipt"}],"resultText":"Success"}
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
String action		= nullToString(request.getParameter("action"), "");
String rid			= nullToString(request.getParameter("rid"), "");
if (beEmpty(masterId) || beEmpty(action)){
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

String		sCommand			= "";
String		sSlot				= "0";
String		sP2					= "00";
String		sDate				= getDateTimeNow(gcDateFormatSlashYMDTime);
String		sUser				= "System";

List<String> sSQLList	= new ArrayList<String>();

//先看看DB裡有沒有這個Master ID
sSQL = "SELECT Current_Slot FROM bip_device";
sSQL += " WHERE Master_Id='" + masterId + "'";

ht = getDBData(sSQL, sSource);

sResultCode = ht.get("ResultCode").toString();
sResultText = ht.get("ResultText").toString();

if (sResultCode.equals(gcResultCodeNoDataFound)){	//沒Master ID資料
	obj.put("resultCode", gcResultCodeParametersValidationError);
	obj.put("resultText", gcResultTextParametersValidationError);
	out.print(obj);
	out.flush();
	return;
}	//if (sResultCode.equals(gcResultCodeNoDataFound)){	//沒Master ID資料

if (sResultCode.equals(gcResultCodeSuccess)){
	s = (String[][])ht.get("Data");
	sSlot = nullToString(s[0][0], "");
}

if (sSlot.equals("0"))	sP2 = "01";	//切到另一個slot
if (sSlot.equals("1"))	sP2 = "00";	//切到另一個slot
if (action.equals("r"))		sCommand = "AABBDDA4000001010100";
if (action.equals("s"))		sCommand = "AABBDDA500" + sP2 + "01010100";
if (action.equals("sr"))	sCommand = "AABBDDA600" + sP2 + "01010100";

if (action.equals("c")){
	if (notEmpty(rid)){
		sSQL = "UPDATE bip_message_queue";
		sSQL += " SET Update_User='" + sUser + "'";
		sSQL += " ,Update_Date='" + sDate + "'";
		sSQL += " ,Status='Canceled'";
		sSQL += " WHERE id=" + rid;
		sSQLList.add(sSQL);
		
		writeLog("debug", "Cancel job:" + sSQL);
		
		ht = updateDBData(sSQLList, sSource, false);
		
		sResultCode = ht.get("ResultCode").toString();
		sResultText = ht.get("ResultText").toString();
	}
}else if (action.equals("r") || action.equals("s") || action.equals("sr")){
	sSQL = "INSERT INTO bip_message_queue (Create_User, Create_Date, Update_User, Update_Date, Master_Id, Message, Status) VALUES (";
	sSQL += "'" + sUser + "',";
	sSQL += "'" + sDate + "',";
	sSQL += "'" + sUser + "',";
	sSQL += "'" + sDate + "',";
	sSQL += "'" + masterId + "',";
	sSQL += "'" + sCommand + "',";
	sSQL += "'" + "Init" + "'";
	sSQL += ")";
	sSQLList.add(sSQL);
	
	writeLog("debug", "Add new job:" + sSQL);
	
	ht = updateDBData(sSQLList, sSource, false);
	
	sResultCode = ht.get("ResultCode").toString();
	sResultText = ht.get("ResultText").toString();
}

obj.put("resultCode", sResultCode);
obj.put("resultText", sResultText);

out.print(obj);
out.flush();

//writeLog("debug", obj.toString());
%>