<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%@page import="java.net.InetAddress" %>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="java.util.*" %>

<%@include file="00_constants.jsp"%>
<%@include file="00_utility.jsp"%>

<%
/***************輸入範例********************************************************
http://52.221.26.249:8080/iovserver/BMQ.jsp?m=12345678901234567890&cs=0&i0=1000000000000001&i1=1000000000000002
*******************************************************************************/

/***************輸出範例********************************************************
*******************************************************************************/
%>

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html;charset=utf-8");

out.clear();	//注意，一定要有out.clear();，要不然client端無法解析XML，會認為XML格式有問題

String	sResponse	= "AABBDDA0000001010100";	//沒有待執行的queued job

/*********************開始做事吧*********************/

String masterId		= nullToString(request.getParameter("m"), "");
String currentSlot	= nullToString(request.getParameter("cs"), "");
String[] imsis;
int			i					= 0;
int			j					= 0;

writeLog("debug", "Master Id=" + masterId);
writeLog("debug", "Current Slot=" + currentSlot);
imsis = new String[19];
for (i=0;i<19;i++){
	imsis[i] = nullToString(request.getParameter("i" + String.valueOf(i)), "");
	writeLog("debug", "IMSI" + String.valueOf(i) + "= " + imsis[i]);
}

if (beEmpty(masterId)){
	writeLog("debug", "BIP get message queue parameter not found for Master Id= " + masterId + ", Current Slot=" + currentSlot);
	sResponse = gcResultCodeParametersNotEnough;
	out.print(sResponse);
	//out.flush();
	return;
}else{
	writeLog("debug", "BIP get message queue for masterId= " + masterId + ", currentSlot=" + currentSlot);
}

String sSource = gcDataSourceNameCMSIOT;

Hashtable	ht					= new Hashtable();
String		sResultCode			= gcResultCodeSuccess;
String		sResultText			= gcResultTextSuccess;
String		s[][]				= null;
String		sSQL				= "";
String		sWhere				= "";
String		sDate				= getDateTimeNow(gcDateFormatSlashYMDTime);
String		sUser				= "System";

String		sNewDevice			= "0";
String		sMessage			= "";

List<String> sSQLList	= new ArrayList<String>();

//先看看DB裡有沒有這個Master ID
sSQL = "SELECT Master_Id FROM bip_device";
sSQL += " WHERE Master_Id='" + masterId + "'";

ht = getDBData(sSQL, sSource);

sResultCode = ht.get("ResultCode").toString();
sResultText = ht.get("ResultText").toString();

if (sResultCode.equals(gcResultCodeNoDataFound)){	//沒Master ID資料，建立一筆新的資料
	sNewDevice = "1";
	sSQL = "INSERT INTO bip_device (Create_User, Create_Date, Update_User, Update_Date, Master_Id, Current_Slot, Status) VALUES (";
	sSQL += "'" + sUser + "',";
	sSQL += "'" + sDate + "',";
	sSQL += "'" + sUser + "',";
	sSQL += "'" + sDate + "',";
	sSQL += "'" + masterId + "',";
	sSQL += "'" + currentSlot + "',";
	sSQL += "'" + "Active" + "'";
	sSQL += ")";
	sSQLList.add(sSQL);
}else{	//更新最近keepalive時間
	sSQL = "UPDATE bip_device";
	sSQL += " SET Update_User='" + sUser + "'";
	sSQL += " ,Update_Date='" + sDate + "'";
	sSQL += " WHERE Master_Id='" + masterId + "'";
	sSQLList.add(sSQL);
}	//if (sResultCode.equals(gcResultCodeNoDataFound)){	//沒Master ID資料，建立一筆新的資料

sSQL = "DELETE FROM bip_device_imsis";
sSQL += " WHERE Master_Id='" + masterId + "'";
sSQLList.add(sSQL);

for (i=0;i<19;i++){
	if (notEmpty(imsis[i])){
		sSQL = "INSERT INTO bip_device_imsis (Create_User, Create_Date, Update_User, Update_Date, Master_Id, Slot, IMSI, Status) VALUES (";
		sSQL += "'" + sUser + "',";
		sSQL += "'" + sDate + "',";
		sSQL += "'" + sUser + "',";
		sSQL += "'" + sDate + "',";
		sSQL += "'" + masterId + "',";
		sSQL += "'" + String.valueOf(i) + "',";
		sSQL += "'" + imsis[i] + "',";
		sSQL += "'" + "" + "'";
		sSQL += ")";
		sSQLList.add(sSQL);
	}
}

if (notEmpty(currentSlot)){
	sSQL = "UPDATE bip_device_imsis SET Status='Active'";
	sSQL += " WHERE Master_Id='" + masterId + "'";
	sSQL += " AND Slot='" + currentSlot + "'";
	sSQLList.add(sSQL);
}

ht = updateDBData(sSQLList, sSource, false);

sResultCode = ht.get("ResultCode").toString();
sResultText = ht.get("ResultText").toString();

if (!sResultCode.equals(gcResultCodeSuccess)){
	writeLog("error", "Error when add new device, sResultCode= " + sResultCode + ", sResultText= " + sResultText);
}

if (sNewDevice.equals("1")){	//沒Master ID資料，直接回覆沒有queue job
	writeLog("debug", "Response message= " + sResponse + "\n");
	out.print(sResponse);
	return;
}	//if (sNewDevice.equals("1")){	//沒Master ID資料，直接回覆沒有queue job

//看看DB裡有沒有這個Master ID的queued job
sSQL = "SELECT id, Message FROM bip_message_queue";
sSQL += " WHERE Master_Id='" + masterId + "'";
sSQL += " AND Status='Init'";
sSQL += " ORDER BY id";
sSQL += " LIMIT 1";

ht = getDBData(sSQL, sSource);

sResultCode = ht.get("ResultCode").toString();
sResultText = ht.get("ResultText").toString();

if (sResultCode.equals(gcResultCodeSuccess)){	//有資料
	s = (String[][])ht.get("Data");
	sMessage = nullToString(s[0][1], "");
	if (notEmpty(sMessage)){
		sResponse = sMessage;
	}
	sSQL = "UPDATE bip_message_queue";
	sSQL += " SET Update_User='" + sUser + "'";
	sSQL += " ,Update_Date='" + sDate + "'";
	sSQL += " ,Status='Sent' WHERE id=" + s[0][0];
	sSQLList	= new ArrayList<String>();
	sSQLList.add(sSQL);
	ht = updateDBData(sSQLList, sSource, false);
	
	sResultCode = ht.get("ResultCode").toString();
	sResultText = ht.get("ResultText").toString();
	
	if (!sResultCode.equals(gcResultCodeSuccess)){
		writeLog("error", "Error when update bip_message_queue, sResultCode= " + sResultCode + ", sResultText= " + sResultText);
	}
}	//if (sResultCode.equals(gcResultCodeSuccess)){	//有資料








/*
String[] fields1 = {"DATE_FORMAT(Create_Date,'%Y-%m-%d %H:%i:%s')", "DATE_FORMAT(Update_Date,'%Y-%m-%d %H:%i:%s')", "User_Name", "UUID"};
String[] fields2 = {"Create_Date", "Update_Date", "User_Name", "UUID"};

sSQL = "SELECT " + fields1[0];
for (i=1;i<fields1.length;i++){
	sSQL += ", " + fields1[i]; 
}
sSQL += " FROM iot_device";
sSQL += " ORDER BY Update_Date DESC LIMIT 200";

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
obj.put("devices", l1);

out.print(obj);
*/
writeLog("debug", "Response message= " + sResponse + "\n");
out.print(sResponse);
//writeLog("debug", obj.toString());
%>