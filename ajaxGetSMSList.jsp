<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%@page import="java.net.InetAddress" %>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="java.util.*" %>

<%@include file="00_constants.jsp"%>
<%@include file="00_utility.jsp"%>

<%
/***************輸入範例********************************************************
所有資料
http://127.0.0.1:8080/CHT/ajaxGetPaymentOrderList.jsp

單一資料
http://127.0.0.1:8080/CHT/ajaxGetPaymentOrderList.jsp?Payment_Order_ID=TX15011901DA55595D5898AD
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

String sSource		= nullToString(request.getParameter("source"), "");

if (beEmpty(sSource))			sSource = gcDataSourceNameSSD;
if (sSource.equals("global"))	sSource = gcDataSourceNameSSD;
if (sSource.equals("china"))	sSource = gcDataSourceNameSSDCN;
if (sSource.equals("india"))	sSource = gcDataSourceNameSSDIN;

Hashtable	ht					= new Hashtable();
String		sResultCode			= gcResultCodeSuccess;
String		sResultText			= gcResultTextSuccess;
String		s[][]				= null;
String		sSQL				= "";
String		sWhere				= "";

String		ss					= "";
int			i					= 0;
int			j					= 0;


String[] fields1 = {"DATE_FORMAT(Create_Date,'%Y-%m-%d %H:%i:%s')", "SMS_Center_ID", "SMS_ID", "SMSC_Type", "Receiver_MSISDN", "SMS_Content", "Response", "Status"};
String[] fields2 = {"Create_Date", "SMS_Center_ID", "SMS_ID", "SMSC_Type", "Receiver_MSISDN", "SMS_Content", "Response", "Status"};

sSQL = "SELECT " + fields1[0];
for (i=1;i<fields1.length;i++){
	sSQL += ", " + fields1[i]; 
}
sSQL += " FROM sms_order";
sSQL += " WHERE Create_Date>='" + getWeekAgo(gcDateFormatdashYMD) + " 00:00:00'";
//sSQL += " ORDER BY Create_Date DESC LIMIT 100";
sSQL += " ORDER BY Create_Date DESC";

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
			if (j==5){
				if (s[i][2].equals("MT001")){
					m1.put(fields2[j], "密碼簡訊");
				}else{
					m1.put(fields2[j], nullToString(s[i][j], ""));
				}
			}else{
				m1.put(fields2[j], nullToString(s[i][j], ""));
			}
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
obj.put("smss", l1);

out.print(obj);
out.flush();

//writeLog("debug", obj.toString());
%>