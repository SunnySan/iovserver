<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%@page import="java.net.InetAddress" %>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="org.json.simple.parser.JSONParser" %>
<%@page import="org.json.simple.parser.ParseException" %>
<%@page import="org.json.simple.JSONArray" %>
<%@page import="org.apache.commons.io.IOUtils" %>
<%@page import="java.util.*" %>

<%@include file="00_constants.jsp"%>
<%@include file="00_utility.jsp"%>

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html;charset=utf-8");
response.setHeader("Pragma","no-cache"); 
response.setHeader("Cache-Control","no-cache"); 
response.setDateHeader("Expires", 0); 

out.clear();	//注意，一定要有out.clear();，要不然client端無法解析XML，會認為XML格式有問題

/*********************開始做事吧*********************/
JSONObject obj=new JSONObject();

/************************************呼叫範例*******************************
https://www.call-pro.net/CallPro/Event_PCClientSendInstantNotification.jsp?areacode=02&phonenumber1=26585888&accesscode=123456&callerphone=0988123456&callername=hellokitty&callerdetail=great
************************************呼叫範例*******************************/

String sMessage		= nullToString(request.getParameter("message"), "");		//發送訊息內容
String sRecipient	= nullToString(request.getParameter("msisdn"), "");		//發送訊息內容

writeLog("info", "Send OTA, message= " + sMessage + ", MSISDN=" + sRecipient);

if (beEmpty(sMessage) || beEmpty(sRecipient)){
	obj.put("resultCode", gcResultCodeParametersNotEnough);
	obj.put("resultText", gcResultTextParametersNotEnough);
	out.print(obj);
	out.flush();
	return;
}

String sSMSC = "infinite";
if (sRecipient.startsWith("882")) sSMSC = "jt";
String sOTAServerUrl = "http://sms.gslssd.com/smsChannel/" + sSMSC + "/sendMessage";

Hashtable	ht					= new Hashtable();
String		sResultCode			= gcResultCodeSuccess;
String		sResultText			= gcResultTextSuccess;

String		sBody		= "";
String		sResponse	= "";

sBody = "{\"content\":\"" + sMessage + "\",\"receiverMsisdn\":\"" + sRecipient + "\",\"isSmpp\":\"true\",\"drUrl\":\"#\",\"messageId\":\"SMS-123456789012\"}";

	sResponse	= "";
	try
	{
		URL u;
		u = new URL(sOTAServerUrl);
		HttpURLConnection uc = (HttpURLConnection)u.openConnection();
		uc.setRequestProperty ("Content-Type", "application/json");
		uc.setRequestProperty("contentType", "utf-8");
		uc.setRequestMethod("POST");
		uc.setDoOutput(true);
		uc.setDoInput(true);
	
		byte[] postData = sBody.getBytes("UTF-8");	//避免中文亂碼問題
		OutputStream os = uc.getOutputStream();
		os.write(postData);
		os.close();
	
		InputStream in = uc.getInputStream();
		BufferedReader r = new BufferedReader(new InputStreamReader(in));
		StringBuffer buf = new StringBuffer();
		String line;
		while ((line = r.readLine())!=null) {
			buf.append(line);
		}
		in.close();
		sResponse = buf.toString();	//取得回應值
		if (beEmpty(sResponse)){
			sResultCode = gcResultCodeUnknownError;
			sResultText = gcResultTextUnknownError;
			obj.put("resultCode", sResultCode);
			obj.put("resultText", sResultText);
		}else{
			out.print(sResponse);
		}
	}catch (IOException e){
		sResponse = e.toString();
		writeLog("error", "Exception when send OTA: " + e.toString());
		sResultCode = gcResultCodeUnknownError;
		sResultText = sResponse;
		obj.put("resultCode", sResultCode);
		obj.put("resultText", sResultText);
	}
	if (sResultCode.equals(gcResultCodeSuccess)){
		writeLog("info", "Successfully send OTA!"  + "\nrequest body=" + sBody);
		writeLog("info", "Successfully send OTA!"  + "\nResponse=" + sResponse);
	}else{
		writeLog("error", "Failed to send OTA: " + sResponse + "\nrequest body=" + sBody);
	}

%>
