<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>
<%!

//Database連線參數
public static final String	gcDataSourceNameCMSIOT					= "jdbc/cmsiot";

/*****************************************************************************/
//Email相關設定
public static final String	gcDefaultEmailSMTPServer				= "email-smtp.us-east-1.amazonaws.com";	//發送email的郵件主機(OA，可寄送至外部信箱)
public static final int		gcDefaultEmailSMTPServerPort			= 465;	//發送email的郵件主機port
public static final String	gcDefaultEmailSMTPServerUserName		= "AKIAJGVKZSKUYEII5CEQ";	//發送email的郵件主機UserName
public static final String	gcDefaultEmailSMTPServerPassword		= "Aq3hDhmDq0PLo48/UMIp/E/z0SXqlkv9+bJG/gED1+Aw";	//發送email的郵件主機Password
public static final String	gcDefaultEmailFromAddress				= "support@taisys.com";	//發送email的發信人email address
public static final String	gcDefaultEmailFromName					= "太思客服中心";	//發送email的發信人名稱
public static final String	gcDefaultEmailFromAddressVAS			= "support@taisys.com";	//發送內部email的發信人email address
public static final String	gcDefaultEmailFromNameVAS				= "中華SSD專案通知";	//發送內部email的發信人名稱
public static final String	gcDefaultEmailToAddressVAS				= "sunny.sun@taisys.com";	//發送內部email的收信人email address

//ResultCode及ResultText定義
public static final String	gcResultCodeSuccess						= "00000";
public static final String	gcResultTextSuccess						= "Success";
public static final String	gcResultCodeParametersNotEnough			= "00004";
public static final String	gcResultTextParametersNotEnough			= "Parameter not enough!";
public static final String	gcResultCodeParametersValidationError	= "00005";
public static final String	gcResultTextParametersValidationError	= "Parameter is incorrect!";
public static final String	gcResultCodeNoDataFound					= "00006";
public static final String	gcResultTextNoDataFound					= "No data found!";
public static final String	gcResultCodeNoLoginInfoFound			= "00007";
public static final String	gcResultTextNoLoginInfoFound			= "無法取得您的登入帳號，可能為閒置太久，請重新登入!";
public static final String	gcResultCodeNoPriviledge				= "00008";
public static final String	gcResultTextNoPriviledge				= "您無權限執行此作業!";
public static final String	gcResultCodeWrongIdOrPassword			= "00009";
public static final String	gcResultTextWrongIdOrPassword			= "帳號密碼有誤，請重新登入!";
public static final String	gcResultCodeDBTimeout					= "99001";
public static final String	gcResultTextDBTimeout					= "資料庫連線失敗或逾時!";
public static final String	gcResultCodeDBOKButMailBodyFail			= "99002";
public static final String	gcResultTextDBOKButMailBodyFail			= "成功將資料寫入資料庫，但無法產生通知郵件內容!";
public static final String	gcResultCodeDBOKButUserMailFail			= "99003";
public static final String	gcResultTextDBOKButUserMailFail			= "成功將資料寫入資料庫，無法取得下個簽核人員的Email!";
public static final String	gcResultCodeDBOKButMailSendFail			= "99004";
public static final String	gcResultTextDBOKButMailSendFail			= "成功將資料寫入資料庫，但寄送通知信件失敗!";
public static final String	gcResultCodeMailSendFail				= "99005";
public static final String	gcResultTextMailSendFail				= "寄送通知信件失敗!";
public static final String	gcResultCodeUnknownError				= "99999";
public static final String	gcResultTextUnknownError				= "Unknown error!";

//日期格式
public static final String	gcDateFormatDateDashTime				= "yyyyMMdd-HHmmss";
public static final String	gcDateFormatSlashYMDTime				= "yyyy/MM/dd HH:mm:ss";
public static final String	gcDateFormatYMD							= "yyyyMMdd";
public static final String	gcDateFormatSlashYMD					= "yyyy/MM/dd";
public static final String	gcDateFormatdashYMD						= "yyyy-MM-dd";

%>
