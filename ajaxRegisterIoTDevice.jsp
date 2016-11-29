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

String sUUID		= nullToString(request.getParameter("uuid"), "");
String sUserName	= nullToString(request.getParameter("username"), "");

if (beEmpty(sUUID) || beEmpty(sUserName)){
	obj.put("resultCode", gcResultCodeParametersValidationError);
	obj.put("resultText", gcResultTextParametersValidationError);
	out.print(obj);
	out.flush();
	return;
}

Hashtable	ht					= new Hashtable();
String		sResultCode			= gcResultCodeSuccess;
String		sResultText			= gcResultTextSuccess;
String		s[][]				= null;
String		sSQL				= "";
String		sWhere				= "";

String		ss					= "";
int			i					= 0;
int			j					= 0;

String		sNow				= getDateTimeNow(gcDateFormatSlashYMDTime);

List<String> sSQLList	= new ArrayList<String>();

sSQL = "SELECT UUID FROM iot_device WHERE UUID='" + sUUID + "'";

ht = getDBData(sSQL, gcDataSourceNameCMSIOT);

sResultCode = ht.get("ResultCode").toString();
sResultText = ht.get("ResultText").toString();

if (sResultCode.equals(gcResultCodeSuccess)){	//有資料，用 UPDATE 指令
	sSQL = "UPDATE iot_device SET Update_User='" + "System" + "', Update_Date='" + sNow + "', User_Name='" + sUserName + "', UUID='" + sUUID + "' WHERE UUID='" + sUUID + "'";
}else{	//沒資料，用 INSERT 指令
	sSQL = "INSERT INTO iot_device (Create_User, Create_Date, Update_User, Update_Date, Device_Type, User_Name, UUID)";
	sSQL += " VALUES (";
	sSQL += " '" + "System" + "',";
	sSQL += " '" + sNow + "',";
	sSQL += " '" + "System" + "',";
	sSQL += " '" + sNow + "',";
	sSQL += " '" + "IOV" + "',";
	sSQL += " '" + sUserName + "',";
	sSQL += " '" + sUUID + "'";
	sSQL += " )";
}

sSQLList.add(sSQL);
writeLog("debug", "iot_device insert:" + sSQL);

ht = updateDBData(sSQLList, gcDataSourceNameCMSIOT, false);
sResultCode = ht.get("ResultCode").toString();
sResultText = ht.get("ResultText").toString();
if (!ht.get("ResultCode").toString().equals(gcResultCodeSuccess)){
	writeLog("error", "SMSC Update失敗：" + sResultCode + "-" + sSQL);
}

obj.put("resultCode", sResultCode);
obj.put("resultText", sResultText);

out.print(obj);
out.flush();

writeLog("debug", obj.toString());
%>