<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>

<%@ page import="java.net.*" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.regex.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.io.*" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="javax.mail.*"%>
<%@ page import="javax.mail.internet.*"%>
<%@ page import="javax.activation.*"%>

<%@page import="org.json.simple.JSONObject" %>

<%
//Oracle connection
	//Class.forName("oracle.jdbc.driver.OracleDriver");
%>

<%!
//注意：因為有些程式使用jxl.jar執行Excel檔案匯出，而jxl.jar有自己的Boolean，所以這裡的Boolean都宣告為java.lang.Boolean，以免compile失敗

/*********************************************************************************************************************/
//檢查字串是否為空值
public java.lang.Boolean beEmpty(String s) {
	return (s==null || s.length()<1);
}	//public java.lang.Boolean beEmpty(String s) {
/*********************************************************************************************************************/

/*********************************************************************************************************************/
//檢查字串是否不為空值
public java.lang.Boolean notEmpty(String s) {
	return (s!=null && s.length()>0);
}	//public java.lang.Boolean notEmpty(String s) {

/*********************************************************************************************************************/

//若字串為null或空值就改為另一字串(例如""或"&nbsp;")
public String nullToString(String sOld, String sReplace){
	return (beEmpty(sOld)?sReplace:sOld);
}
/*********************************************************************************************************************/

//檢查字串是否為數字格式
public java.lang.Boolean isNumber(String str)  
{  
  try  
  {  
    double d = Double.parseDouble(str);  
  }  
  catch(NumberFormatException nfe)  
  {  
    return false;  
  }  
  return true;  
}

/*********************************************************************************************************************/

/**
	* 數字不足部份補零回傳
	* @param str 字串
	* @param lenSize 字串數字最大長度,不足的部份補零
	* @return 回傳補零後字串數字
*/
public String MakesUpZero(String str, int lenSize) {
	String zero = "0000000000";
	String returnValue = zero;
	
	returnValue = zero + str;
	
	return returnValue.substring(returnValue.length() - lenSize);

}

/*********************************************************************************************************************/
//建立資料庫連線
public Connection DBConnection(String dbName){
	try{
		Context initContext = new InitialContext();
		Context envContext  = (Context)initContext.lookup("java:/comp/env");
		DataSource ds = (DataSource)envContext.lookup(dbName);
		Connection conn = ds.getConnection();
		return conn;
	}catch (Exception e){
		writeLog("error", "DBConnection error: " + e.toString(), "utility");
		return null;
	}       //try{
}       //public Connection DBConnection(String dbName){

/*********************************************************************************************************************/
//關閉資料庫連線及相關的ResultSet、Statement
public  void closeDBConnection(ResultSet rs, Statement stmt, Connection dbconn){
	if(rs != null){
		try{
			rs.close();
		}catch (Exception ignored) {}
	}	//if(rs != null){
	if(stmt != null){
		try{
			stmt.close();
		}catch (Exception ignored) {}
	}	//if(stmt != null){
	if(dbconn != null){
		try{
			dbconn.close();
		}catch (Exception ignored) {}
	}	//if(dbconn != null){
}	//public  void String closeDBConnection(ResultSet rs, Statement stmt, Connection dbconn)

/*********************************************************************************************************************/
//檢查日期格式是否正確
public java.lang.Boolean isDate(String date, String DATE_FORMAT){
	try {
		DateFormat df = new SimpleDateFormat(DATE_FORMAT);
		df.setLenient(false);
		df.parse(date);
		return true;
	} catch (Exception e) {
		return false;
	}
}

/*********************************************************************************************************************/
//取得目前系統時間，並依指定的格式產生字串
public String getDateTimeNow(String sDateFormat){
	/************************************
	sDateFormat:	指定的格式，例如"yyyyMMdd-HHmmss"或"yyyyMMdd"
	*************************************/
	String s;
	SimpleDateFormat nowdate = new java.text.SimpleDateFormat(sDateFormat);
	nowdate.setTimeZone(TimeZone.getTimeZone("GMT+8"));
	s = nowdate.format(new java.util.Date());
	return s;
}	//public String getDateTimeNow(String sDateFormat){

/*********************************************************************************************************************/
//取得昨天日期
public String getYesterday(String sDateFormat){
	/************************************
	sDateFormat:	指定的格式，例如"yyyyMMdd-HHmmss"或"yyyyMMdd"
	*************************************/
	TimeZone.setDefault(TimeZone.getTimeZone("Asia/Taipei"));	//將 Timezone 設為 GMT+8
	Calendar cal = Calendar.getInstance();//使用預設時區和語言環境獲得一個日曆。  
	cal.add(Calendar.DAY_OF_MONTH, -1);//取當前日期的前一天.  
	//cal.add(Calendar.DAY_OF_MONTH, +1);//取當前日期的後一天.  
	
	//通過格式化輸出日期  
	java.text.SimpleDateFormat format = new java.text.SimpleDateFormat(sDateFormat);
 
	return format.format(cal.getTime());

}	//public String getDateTimeNow(String sDateFormat){

/*********************************************************************************************************************/
//取得七天前日期
public String getWeekAgo(String sDateFormat){
	/************************************
	sDateFormat:	指定的格式，例如"yyyyMMdd-HHmmss"或"yyyyMMdd"
	*************************************/
	TimeZone.setDefault(TimeZone.getTimeZone("Asia/Taipei"));	//將 Timezone 設為 GMT+8
	Calendar cal = Calendar.getInstance();//使用預設時區和語言環境獲得一個日曆。  
	cal.add(Calendar.DAY_OF_MONTH, -7);//取當前日期的前一天.  
	//cal.add(Calendar.DAY_OF_MONTH, +1);//取當前日期的後一天.  
	
	//通過格式化輸出日期  
	java.text.SimpleDateFormat format = new java.text.SimpleDateFormat(sDateFormat);
 
	return format.format(cal.getTime());

}	//public String getDateTimeNow(String sDateFormat){

/*********************************************************************************************************************/

//產生20碼的RequestId
public String generateRequestId(){
	//以【日期+時間+四位數隨機數】作為送給BSC API的 RequestId，例如【20110816-102153-6221】
	java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat(gcDateFormatDateDashTime);
	java.util.Date currentTime = new java.util.Date();//得到當前系統時間
	String txtRandom = String.valueOf(Math.round(Math.random()*10000));
	txtRandom = MakesUpZero(txtRandom, 4);	//不足4碼的話，將前面補0
	String txtRequestId = formatter.format(currentTime) + "-" + txtRandom; //將日期時間格式化，加上一個隨機數，作為RequestId，格式是yyyyMMdd-HHmmss-xxxx

	return txtRequestId;
}

/*********************************************************************************************************************/
//寫入檔案
public java.lang.Boolean writeToFile(String sFilePath, String content){
	//content是寫入的內容
	java.lang.Boolean bOK = true;
	String s = "";

	if (beEmpty(content)) return false;

	Writer out = null;
	try {
		out = new BufferedWriter(new OutputStreamWriter(
		new FileOutputStream(sFilePath, false), "UTF-8"));	//指定UTF-8
		out.write(content);
		out.close();
	}catch(Exception e){
		s = "Error write to file, filePath=" + sFilePath + "<p>" + e.toString();
		writeLog("error", s);
		bOK = false;
	}

	return bOK;
}	//public java.lang.Boolean writeToFile(String sFilePath, String content){

/*********************************************************************************************************************/
//讀取某個文字檔的內容
public String readFileContent(String sPath){
	//sPath:檔案的路徑及檔名，呼叫此函數前請先以【String fileName=getServletContext().getRealPath("directory/jsp.txt");】取得檔案的徑名，然後以此徑名做為sPath參數送給此函數
	File file = new File(sPath);
	FileInputStream fis = null;
	BufferedInputStream bis = null;
	DataInputStream dis = null;
	String content = "";
	try {
		fis = new FileInputStream(file);
		bis = new BufferedInputStream(fis);
		dis = new DataInputStream(bis);
		while (dis.available() != 0) {
			content += dis.readLine();
		}
		content = new String(content.getBytes("8859_1"),"utf-8");
	} catch (FileNotFoundException e) {
		content = "";
		writeLog("error", "readFileContent error, sPath: " + sPath + ", desc: " + e.toString(), "utility");
	} catch (IOException e) {
		content = "";
		writeLog("error", "readFileContent error, sPath: " + sPath + ", desc: " + e.toString(), "utility");
	}finally{
		if (dis!=null){ try{dis.close();}catch (Exception ignored) {}}
		if (bis!=null){ try{bis.close();}catch (Exception ignored) {}}
		if (fis!=null){ try{fis.close();}catch (Exception ignored) {}}
	}
	return content;
}

/*********************************************************************************************************************/
//刪除某個檔案
public java.lang.Boolean DeleteFile(String sFileName){
	java.lang.Boolean bOK = true;
	if (sFileName==null || sFileName.length()<1)	return false;
	
	File f = new File(sFileName);
	if(f.exists()){//檢查是否存在
		writeLog("info", "delete file: " + sFileName, "utility");
		f.delete();//刪除文件
	} 
	return bOK;
}	//public java.lang.Boolean DeleteFile(String sPath, String sFileName){

/*********************************************************************************************************************/
//依照輸入的SQL statement取得ResultSet，並將ResultSet轉換成String Array回覆給呼叫端
public Hashtable getDBData(String sSQL, String dbName){
	//sSQL是SQL statement
	//iColCount是ResultSet中每個row的column數
	
	Hashtable	htResponse		= new Hashtable();	//儲存回覆資料的 hash table
	String		s[][]			= null;
	String		sResultCode		= gcResultCodeSuccess;
	String		sResultText		= gcResultTextSuccess;
	int			i				= 0;
	int			j				= 0;
	int			iRowCount		= 0;
	int			iColCount		= 0;
	
	if ((sSQL==null || sSQL.length()<1)){
		htResponse.put("ResultCode", gcResultCodeParametersValidationError);
		htResponse.put("ResultText", gcResultTextParametersValidationError);
		return htResponse;
	}

	//找出DB中的資料
	Connection	dbconn	= null;	//連接 Oracle DB 的 Connection 物件
	Statement	stmt	= null;	//SQL statement 物件
	ResultSet	rs		= null;	//Resultset 物件
	
	dbconn = DBConnection(dbName);
	if (dbconn==null){	//資料庫連線失敗
		htResponse.put("ResultCode", gcResultCodeDBTimeout);
		htResponse.put("ResultText", gcResultTextDBTimeout);
		return htResponse;
	}	//if (dbconn==null){	//資料庫連線失敗

	try{	//擷取資料
		stmt = dbconn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,ResultSet.CONCUR_READ_ONLY);
		rs = stmt.executeQuery(sSQL);
		if (rs!=null){
			rs.last();
			iRowCount = rs.getRow();
			rs.beforeFirst();
		}
		if (iRowCount>0){	//有資料
			ResultSetMetaData rsm = rs.getMetaData();
			iColCount = rsm.getColumnCount();
			s = new String[iRowCount][iColCount];
			i = 0;
			while (rs != null && rs.next()) { //有資料則顯示
				for (j=0;j<iColCount;j++){	//產生String Array的值
					s[i][j] = rs.getString(j+1);
				}
				i++;
			}	//while(rs.next()){	//有資料則顯示
		}else{	//無資料
			sResultCode = gcResultCodeNoDataFound;
			sResultText = gcResultTextNoDataFound;
		}	//if (iRowCount>0){	//有資料
		     /***********************************************************************************************************/
	}catch(SQLException e){
		sResultCode = gcResultCodeUnknownError;
		sResultText = e.toString();
		writeLog("error", "getDBData error, sSQL: " + sSQL + ", desc: " + e.toString(), "utility");
	}finally{
		//Clean up resources, close the connection.
		closeDBConnection(rs, stmt, dbconn);
	}	//}finally{
	
	htResponse.put("ResultCode", sResultCode);
	htResponse.put("ResultText", sResultText);
	if (iRowCount>0) htResponse.put("Data", s);
	return htResponse;
}	//public String getDBData(String sSQL, int iColCount){

/*********************************************************************************************************************/
//依照輸入的SQL statement對DB執行一個或多個insert, update, delete指令(可指定是否需每個指令自動commit)，並將執行結果回覆給呼叫端
public Hashtable updateDBData(String sSQL, String dbName){	//輸入參數為單一 String 型態
	String[] a = {sSQL};
	return updateDBData(a, dbName, true);
}
public Hashtable updateDBData(List<String> sSQLList, String dbName, java.lang.Boolean bAutoCommit){	//輸入參數為 List 型態
	return updateDBData(sSQLList.toArray(new String[0]), dbName, bAutoCommit);
}
public Hashtable updateDBData(String sSQL[], String dbName, java.lang.Boolean bAutoCommit){			//輸入參數為 String array 型態
	//sSQL[]是SQL statement
	
	Hashtable	htResponse		= new Hashtable();	//儲存回覆資料的 hash table
	String		sResultCode		= gcResultCodeSuccess;
	String		sResultText		= gcResultTextSuccess;
	String		s				= "";
	
	if (sSQL==null || sSQL.length<1){
		htResponse.put("ResultCode", gcResultCodeParametersValidationError);
		htResponse.put("ResultText", gcResultTextParametersValidationError);
		return htResponse;
	}

	//對DB執行SQL指令
	Connection	dbconn	= null;	//連接 Oracle DB 的 Connection 物件
	Statement	stmt	= null;	//SQL statement 物件
	int			i		= 0;	//executeUpdate後回覆的row count數
	int			j		= 0;	//sSQL string array的指標
	
	dbconn = DBConnection(dbName);
	if (dbconn==null){	//資料庫連線失敗
		htResponse.put("ResultCode", gcResultCodeDBTimeout);
		htResponse.put("ResultText", gcResultTextDBTimeout);
		return htResponse;
	}	//if (dbconn==null){	//資料庫連線失敗
	/*
	for(j=0;j<sSQL.length;j++){
		writeLog("debug", "execute sSQL: " + s, "utility");
	}
	*/
	try{	//執行SQL指令
		stmt = dbconn.createStatement();
		if (bAutoCommit==false) dbconn.setAutoCommit(false);
		for(j=0;j<sSQL.length;j++){
			if (notEmpty(sSQL[j])){
				s = s + sSQL[j] + ";";
				stmt.addBatch(sSQL[j]);
			}
        }	//for(j=0;j<=sSQL.length;j++){
        stmt.executeBatch();
        if (bAutoCommit==false) dbconn.commit();
	}catch(SQLException e){
		try{
			if (bAutoCommit==false) dbconn.rollback();
		}catch(SQLException e1){
			writeLog("error", "updateDBData error, rollback fail sSQL: " + s + ", desc: " + e1.toString(), "utility");
		};
		sResultCode = gcResultCodeUnknownError;
		sResultText = e.toString();
		writeLog("error", "updateDBData error, fail sSQL: " + s + ", desc: " + e.toString(), "utility");
	}finally{
		try{
			dbconn.setAutoCommit(true);
		}catch(SQLException e2){
			writeLog("error", "updateDBData error, set AutoCommit=true fail sSQL: " + s + ", desc: " + e2.toString(), "utility");
		}
		//Clean up resources, close the connection.
		closeDBConnection(null, stmt, dbconn);
	}	//}finally{
	
	htResponse.put("ResultCode", sResultCode);
	htResponse.put("ResultText", sResultText);
	return htResponse;
}	//public Hashtable updateDBData(String sSQL[], java.lang.Boolean bAutoCommit){

/*********************************************************************************************************************/
//將金額字串加上千位的逗點
public String toCurrency(String s){
	if (beEmpty(s))		return "";	//字串為空
	if (!isNumeric(s))	return s;	//不是數字，回覆原字串
	
	int i = 0;
	int j = 0;
	int k = 0;
	int l = 0;
	String s2 = "";
	//s = trim(s);
	i = s.length();			//i為字串長度
	if (i<4) return s;		//長度太短，不用加逗點，直接回覆原字串
	j = (int)Math.floor(i/3);	//j為字串長度除以3的商數
	k = i % 3;				//k為字串長度除以3的餘數
	s2 = "";
	if (k>0) s2 = s.substring(0, k);
	for (l=0;l<j;l++){
		s2 = s2 + (s2==""?"":",") + s.substring(k+(l*3), k+(l+1)*3);
	}
	return s2;
}

/*********************************************************************************************************************/
//判斷字串內容是否為數字
public java.lang.Boolean isNumeric(String number) { 
	try {
		Integer.parseInt(number);
		return true;
	}catch (NumberFormatException sqo) {
		return false;
	}
}

/*********************************************************************************************************************/
public void writeLog(String sLevel, String sLog, String sClass){
	if (beEmpty(sClass)) sClass = "NoClass";
	Logger logger = Logger.getLogger(sClass);
	writeToLog(sLevel, sLog, logger);
}
public void writeLog(String sLevel, String sLog){
	Logger logger = Logger.getLogger(this.getClass());
	writeToLog(sLevel, sLog, logger);
}
public void writeToLog(String sLevel, String sLog, Logger logger){
	if (sLevel.equalsIgnoreCase("debug"))	logger.debug(sLog);
	if (sLevel.equalsIgnoreCase("info"))	logger.info(sLog);
	if (sLevel.equalsIgnoreCase("warn"))	logger.warn(sLog);
	if (sLevel.equalsIgnoreCase("error"))	logger.error(sLog);
	if (sLevel.equalsIgnoreCase("fatal"))	logger.fatal(sLog);
	//org.apache.log4j.Layout.DateLayout l = DateLayout();
	//logger.info(l.getTimeZone());
}

/*********************************************************************************************************************/
public String getSequence(String dbName){	//取的新的序號
	Hashtable	ht					= new Hashtable();
	String		sResultCode			= gcResultCodeSuccess;
	String		s[][]				= null;
	String		sSQL				= "";
	String		ss					= "";
	
	sSQL = "SELECT nextval('demoseq')";
	
	ht = getDBData(sSQL, dbName);
	
	sResultCode = ht.get("ResultCode").toString();
	
	if (sResultCode.equals(gcResultCodeSuccess)){	//有資料
		s = (String[][])ht.get("Data");
		ss = s[0][0];
	}

	return ss;
}

/*********************************************************************************************************************/

//發送HTML格式的信件(含附件)
public java.lang.Boolean sendHTMLMail(String sFromEmail, String sFromName, String sToEmail, String sSubject, String sBody){
	return sendHTMLMail(sFromEmail, sFromName, sToEmail, sSubject, sBody, "", "", "", "");
}
public java.lang.Boolean sendHTMLMail(String sFromEmail, String sFromName, String sToEmail, String sSubject, String sBody, String sFiles){
	return sendHTMLMail(sFromEmail, sFromName, sToEmail, sSubject, sBody, sFiles, "", "", "");
}
public java.lang.Boolean sendHTMLMail(String sFromEmail, String sFromName, String sToEmail, String sSubject, String sBody, String sFiles, String sCc){
	return sendHTMLMail(sFromEmail, sFromName, sToEmail, sSubject, sBody, sFiles, sCc, "", "");
}
public java.lang.Boolean sendHTMLMail(String sFromEmail, String sFromName, String sToEmail, String sSubject, String sBody, String sFiles, String sCc, String sBcc, String sLogo){
	/*************************************************************************
		sFromEmail:		寄件者的 email address
		sFromName:		寄件者名稱，若輸入空字串則設為與 sFromEmail 相同值
		sToEmail:		收件人 email address，若有多個收件人則以【;】區隔
		sSubject:		信件主旨
		sBody:			信件內容 HTML，從<html><head>至</body></html>
		sFiles:			附件
		sCc:			CC的 email address，若有多個BCC收件人則以【;】區隔
		sBcc:			BCC的 email address，若有多個BCC收件人則以【;】區隔
		sLogo:			Logo圖檔的路徑檔名
		回覆值:			執行成功回覆 true，失敗時回覆 false
	*************************************************************************/
	java.lang.Boolean	bOK		= true;
	String[]			aTo		= null;
	String[]			aCc	= null;
	String[]			aBcc	= null;
	String[]			aFile	= null;
	int					i		= 0;
	
	String				sSMTPServer			= gcDefaultEmailSMTPServer;
	int					iSMTPServerPort		= gcDefaultEmailSMTPServerPort;
	String				sSMTPServerUserName	= gcDefaultEmailSMTPServerUserName;
	String				sSMTPServerPassword	= gcDefaultEmailSMTPServerPassword;
	
	if (beEmpty(sFromEmail) || beEmpty(sFromName) || beEmpty(sToEmail) || beEmpty(sSubject) || beEmpty(sBody)){
		return false;
	}
	
	sToEmail = sToEmail.replace(",", ";");
	aTo = sToEmail.split(";");
	if (aTo.length<1){
		return false;
	}
	
	//CC 收件人
	if (notEmpty(sCc)){
		sCc = sCc.replace(",", ";");
		aCc = sCc.split(";");
	}

	//BCC 收件人
	if (notEmpty(sBcc)){
		sBcc = sBcc.replace(",", ";");
		aBcc = sBcc.split(";");
	}

	//附件
	if (notEmpty(sFiles)){
		aFile = sFiles.split(";");
	}
	
	try{
		try{
			Properties props = new Properties();
			//以下是 AWS 設定
			props.put("mail.transport.protocol", "smtp");
			props.put("mail.smtp.port", iSMTPServerPort);
			props.put("mail.smtp.auth", "true");
			props.put("mail.smtp.starttls.enable", "true");
			props.put("mail.smtp.starttls.required", "true");
			
			/*
			props.put("mail.smtp.host", sSMTPServer);
			//props.put("mail.smtp.auth", "true");	//需要認證則為 true，記得在transport.connect的後兩個參數填入 id、pwd
			*/

			Session s = Session.getInstance(props);
			//s.setDebug(true);	//需要 debug 時再打開
			
			javax.mail.internet.MimeMessage message = new MimeMessage(s);
			
			//設定發信人/收信人/主題/發信時間
			if (beEmpty(sFromName)) sFromName = sFromEmail;
			InternetAddress from = new InternetAddress(sFromEmail, sFromName, "utf-8");
			message.setFrom(from);
			//message.setSender(new InternetAddress(sFromEmail));
			/*
			InternetAddress[] replyAddrs = new InternetAddress[1];
			replyAddrs[0] = new InternetAddress(sFromEmail, sFromName, "utf-8");
			message.setReplyTo(replyAddrs);
			*/
			
			InternetAddress[] mailAddrs = new InternetAddress[aTo.length];
			for (i=0;i<aTo.length;i++){
				 mailAddrs[i] = new InternetAddress(aTo[i].toLowerCase(), aTo[i], "utf-8");	//第一個參數是email，第二個參數是收件人名稱，第三個參數是encoding
			}
			message.setRecipients(javax.mail.Message.RecipientType.TO, mailAddrs);
			
			if (aCc!=null && aCc.length>0){	//CC收件人
				InternetAddress[] mailAddrsCc = new InternetAddress[aCc.length];
				for (i=0;i<aCc.length;i++){
					 mailAddrsCc[i] = new InternetAddress(aCc[i].toLowerCase(), aCc[i], "utf-8");	//第一個參數是email，第二個參數是收件人名稱，第三個參數是encoding
				}
				message.setRecipients(javax.mail.Message.RecipientType.CC, mailAddrsCc);
			}	//if (aCc!=null && aCc.length>0){	//CC收件人

			if (aBcc!=null && aBcc.length>0){	//BCC收件人
				InternetAddress[] mailAddrsBcc = new InternetAddress[aBcc.length];
				for (i=0;i<aBcc.length;i++){
					 mailAddrsBcc[i] = new InternetAddress(aBcc[i].toLowerCase(), aBcc[i], "utf-8");	//第一個參數是email，第二個參數是收件人名稱，第三個參數是encoding
				}
				message.setRecipients(javax.mail.Message.RecipientType.BCC, mailAddrsBcc);
			}	//if (aBcc!=null && aBcc.length>0){	//BCC收件人
			
			message.setSubject(sSubject, "utf-8");
			message.setSentDate(new java.util.Date());
			
			//給消息對像設置內容
			BodyPart mdp = new MimeBodyPart();//新建一個存放信件內容的BodyPart對像
			mdp.setContent(sBody, "text/html;charset=utf-8");//給BodyPart對像設置內容和格式/編碼方式
			Multipart mm = new MimeMultipart();//新建一個MimeMultipart對像用來存放BodyPart對象(事實上可以存放多個)
			mm.addBodyPart(mdp);//將BodyPart加入到MimeMultipart對像中(可以加入多個BodyPart)
			
			//設定附件
			if (aFile!=null && aFile.length>0){	//可能有多個附件
				for (i=0;i<aFile.length;i ++ ){
					mdp = new  MimeBodyPart(); 
					FileDataSource fileds = new  FileDataSource (aFile[i]); 
					mdp.setDataHandler( new  DataHandler(fileds)); 
					mdp.setFileName(fileds.getName()); 
					mm.addBodyPart(mdp); 
				} 
			}	//if (aFile!=null && aFile.length>0){	//可能有多個附件

			// 加入公司logo，放在mai body中 <img src="cid:image"> 指定的位置
			if (notEmpty(sLogo)){
				mdp = new MimeBodyPart();
				FileDataSource fds = new FileDataSource(sLogo);
				mdp.setDataHandler(new DataHandler(fds));
				mdp.setHeader("Content-ID", "<image>");
				mm.addBodyPart(mdp);
			}

			message.setContent(mm);//把mm作為消息對象的內容
			
			message.saveChanges();
			Transport transport = s.getTransport("smtp");
			transport.connect(sSMTPServer, sSMTPServerUserName, sSMTPServerPassword);	//AWS
			transport.sendMessage(message, message.getAllRecipients());
			transport.close();
		}catch(UnsupportedEncodingException e){
			bOK = false;
		}
	}catch(javax.mail.MessagingException e){
		writeLog("error", "sendHTMLMail 失敗:" + e.toString());
		bOK = false;
	}
	if (!bOK) writeLog("error", "Send Mail 失敗||To=" + sToEmail + "||CC=" + sCc + "||BCC=" + sBcc + "||Subject=" + sSubject);
	return bOK;
}

/*********************************************************************************************************************/
public String getJsonValue(Object obj, String name){
	if (obj==null || name==null) return null;
	String value = "";
	try {
		JSONObject jsonObject = (JSONObject) obj;
		value = (String) jsonObject.get(name);
 
 		/*
		long age = (Long) jsonObject.get("age");
		System.out.println(age);
 
		// loop array
		JSONArray msg = (JSONArray) jsonObject.get("messages");
		Iterator<String> iterator = msg.iterator();
		while (iterator.hasNext()) {
			System.out.println(iterator.next());
		}
		*/
	} catch (Exception e) {
		//e.printStackTrace();
		return null;
	}
	return value;
}

/*********************************************************************************************************************/
//取得目前時間前一小時的時間，格式為 yyyy-MM-dd HH:00:00，只算到小時
public String getOneHoursAgoTime(){
	String oneHoursAgoTime =  "" ;

	TimeZone.setDefault(TimeZone.getTimeZone("Asia/Taipei"));	//將 Timezone 設為 GMT+8
	Calendar cal = Calendar.getInstance();
	cal.add(Calendar.HOUR_OF_DAY, -1);	//目前的前一小時
	oneHoursAgoTime = new SimpleDateFormat( "yyyy-MM-dd HH" ).format(cal.getTime());//取得時間
	return  oneHoursAgoTime + ":00:00";
}

/*********************************************************************************************************************/
//讓單引號等字元可以寫入MySQL DB中，用法為escape(String)
private static final HashMap<String,String> sqlTokens;
private static java.util.regex.Pattern sqlTokenPattern;

static
{           
    //MySQL escape sequences: http://dev.mysql.com/doc/refman/5.1/en/string-syntax.html
    String[][] search_regex_replacement = new String[][]
    {
            {   "\u0000"    ,       "\\x00"     ,       "\\\\0"     },
            {   "'"         ,       "'"         ,       "\\\\'"     },
            {   "\""        ,       "\""        ,       "\\\\\""    },
            {   "\b"        ,       "\\x08"     ,       "\\\\b"     },
            {   "\n"        ,       "\\n"       ,       "\\\\n"     },
            {   "\r"        ,       "\\r"       ,       "\\\\r"     },
            {   "\t"        ,       "\\t"       ,       "\\\\t"     },
            {   "\u001A"    ,       "\\x1A"     ,       "\\\\Z"     },
            {   "\\"        ,       "\\\\"      ,       "\\\\\\\\"  }
    };

    sqlTokens = new HashMap<String,String>();
    String patternStr = "";
    for (String[] srr : search_regex_replacement)
    {
        sqlTokens.put(srr[0], srr[2]);
        patternStr += (patternStr.isEmpty() ? "" : "|") + srr[1];            
    }
    sqlTokenPattern = java.util.regex.Pattern.compile('(' + patternStr + ')');
}


public static String escape(String s)
{
    Matcher matcher = sqlTokenPattern.matcher(s);
    StringBuffer sb = new StringBuffer();
    while(matcher.find())
    {
        matcher.appendReplacement(sb, sqlTokens.get(matcher.group(1)));
    }
    matcher.appendTail(sb);
    return sb.toString();
}

/*********************************************************************************************************************/

%>