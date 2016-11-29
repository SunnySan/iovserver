#!/bin/bash
#cron job like this: */30 * * * * /opt/tomcat/webapps/ssdadmin/ShellScript/AlarmSMSOrderFail.sh > /dev/null 2>&1

#call program: ReportSSDDailyReport.jsp
curl -s -o "/dev/null" --connect-timeout 10 localhost:80/CHT/CronImportNewPayment.jsp
if [ "$?" == "0" ]; then
	echo "done!"
	exit 0
else
	echo "connect to server failed, exit..."
	exit 1
fi
exit 0
