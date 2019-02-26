<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%@page import="java.net.InetAddress" %>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="java.util.*" %>
<%@page import="java.util.Arrays" %>

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
	writeLog("debug", "New device, response message= " + sResponse + "\n");
	out.print(sResponse);
	return;
}	//if (sNewDevice.equals("1")){	//沒Master ID資料，直接回覆沒有queue job

//看看DB裡有沒有這個Master ID的queued job
sSQL = "SELECT id, Message FROM bip_message_queue";
sSQL += " WHERE Master_Id='" + masterId + "'";
sSQL += " AND Status='Init'";
sSQL += " ORDER BY id";
sSQL += " LIMIT 1";

//writeLog("debug", "SQL= " + sSQL + "\n");

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

writeLog("debug", "Response message= " + sResponse + "\n");
//out.print(hex2String(sResponse));
OutputStream o = response.getOutputStream();
o.write(hex2Byte(sResponse));
o.close();
//writeLog("debug", obj.toString());
%>

<%!
//將 16 進位碼字串還原成原始文字
public static String hex2String(String hexString) {
	StringBuilder str = new StringBuilder();
	for (int i=0 ; i<hexString.length() ; i+=2)
		str.append((char) Integer.parseInt(hexString.substring(i, i + 2), 16));
	return str.toString();
}

//取得 byte array 每個 byte 的 16 進位碼
public static String byte2Hex(byte[] b) {
	String result = "";
	for (int i=0 ; i<b.length ; i++)
		result += Integer.toString( ( b[i] & 0xff ) + 0x100, 16).substring( 1 );
	return result;
}

//將 16 進位碼的字串轉為 byte array
public static byte[] hex2Byte(String hexString) {
	byte[] bytes = new byte[hexString.length() / 2];
	for (int i=0 ; i<bytes.length ; i++)
		bytes[i] = (byte) Integer.parseInt(hexString.substring(2 * i, 2 * i + 2), 16);
	return bytes;
}

%>