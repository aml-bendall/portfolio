
<%@page import="fibreApps.Sales.UpsAdjustments"%>
<%
	/**
	* Purpose: Allows the upload of a UPS Invoice. Then compares adjustments to what we charged the customer.
	* Created On: 03/05/2017
	* Created By: Allan Bendall
	* 
	* Last Modified On:
	* Last Modified By:
	* Change Log
	*
	*
	*
	*
	*/
%>
<jsp:include page="../Includes/header.jsp" />

<link rel="stylesheet" href="CSS/FreightQuote.css" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.util.Date"%>
<%
DB_util db = new DB_util();
String sql = "";
int status=0;

//Check to see if the process is already running.
try {
				java.sql.Connection statusCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
				java.sql.Statement statusSt = db.dbStatement(statusCon);

				sql = "SELECT * FROM ProcessStatus";	
				
				ResultSet processStatus = db.dbResult(statusSt, sql);
				
				// Set Total Number of Users to the ArrayIndex
				while (processStatus.next()) {
							 status=processStatus.getInt("Running");
						}
				db.dbClose(statusCon, statusSt, processStatus);
			} catch (SQLException e) {
				e.printStackTrace();
			}
//Process is already running.
if(status==1) {
	%>
	<h1 style="text-align: center">UPS Adjustments Report</h1>
	<p style="text-align: center;">Report Already in Progress. You will recieve an email when it is complete.</p>


<%
} else {
//The process is not running. Allow the user to upload a UPS Invoice.
%>

<h1 style="text-align: center">UPS Adjustments Report</h1>
<p style="text-align: center;">The upload must be in CSV format, have all headers removed, and have all of the original columns from the UPS Invoice.</p>

<p style="text-align: center;">Upload a UPS Invoice to begin. </p>
<br/>
<br/>
<form action="upload" method="post" target="_blank" enctype="multipart/form-data" style="text-align:center;">
    <input type="file" name="file" required onchange="checkfile(this);" accept=".csv"/>
    <input type="hidden" name="redirect" value="/fibreApps/WebApps/UpsAdjustmentReport" />
    <input type="hidden" name="filename" value="UpsAdjustments.csv" />
<br/>
    <input type="submit" style="margin-top:2em;" />
</form>

<%

} %>

<script type="text/javascript">
//Function to verify that the file is a CSV file.
function checkfile(sender) {
    var validExts = new Array(".csv");
    var fileExt = sender.value;
    fileExt = fileExt.substring(fileExt.lastIndexOf('.'));
    if (validExts.indexOf(fileExt) < 0) {
      alert("Invalid file selected, valid files are of " +
               validExts.toString() + " types.");
      return false;
    }
    else return true;
}
</script>

<jsp:include page="../Includes/footer.jsp" />

