<% /**
 * Purpose:Provides a report for Cuts made in the warehouse.
 * Created On: 12/11/2017
 * Created By: Allan Bendall
 * 
 * Last Modified On:
 * Last Modified By:
 * Change Log
 *
 *
 *
 *
 */ %>
<%@include file="../Includes/header.jsp"%>
<link rel="stylesheet" href="CSS/CutSheetReport.css" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>

<!-- Collect the dates the the user wishes to report on. -->
<div>
	<div class="threeWide">
	<form style="veritcal-align: center; text-align: center;" method="post"
	action="Warehouse/CutSheetReport.jsp">
	<h1 style="text-align:center;margin-bottom:1em;">Report on Date</h1>
		<p>
			From: <input type="date" name="startDate" required> To: <input
				type="date" name="endDate" required>
		</p>
		
		<input type="submit" value="Submit" name="byDate">
	
	</form>
	</div>
	<div class="threeWide">
		<form style="veritcal-align: center; text-align: center;" method="post"
		action="Warehouse/CutSheetReport.jsp">
		<h1 style="text-align:center;margin-bottom:1em;">Report by Item on Date</h1>
			<p>
				From: <input type="date" name="startDate" required> To: <input
					type="date" name="endDate" required>
			</p>
			<p><input type="text" name="item" required>
			<input type="submit" value="Submit" name="byItem">
		</form>
	</div>
	<div class="threeWide">
		<form style="veritcal-align: center; text-align: center;" method="post"
		action="Warehouse/CutSheetReport.jsp">
		<h1 style="text-align:center;margin-bottom:1em;">Report by Order Number</h1>
			<p><input type="text" name="order" required>
			<input type="submit" value="Submit" name="byOrder">
		</form>
	</div>
</div>
<div style="text-align:center;margin-top:22em;">	
<a href="Warehouse/CutSheetReport.jsp?PrePacks=1">Today's Finished Pre-packs</a>
<br/>
<br/>
<h2>Cut List</h2>
</div>
<%
Date startDate;
Date endDate;
String sdate="";
String edate="";


DB_util db = new DB_util();
String sql = "";

//Setup start and end dates for the SQL queries.
DateFormat origFormat = new SimpleDateFormat("yyyy-MM-dd");
SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM/dd/yyyy");
List<String> parameterNames = new ArrayList<String>(request.getParameterMap().keySet());
if (request.getParameterMap().containsKey("startDate")) {
	String sconvert = request.getParameter("startDate");
	startDate = origFormat.parse(sconvert);

	DateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
	Date date = originalFormat.parse(sconvert);
	String formattedDate = simpleDateFormat.format(date);

	sdate = formattedDate;
}

if (request.getParameterMap().containsKey("endDate")) {
	String econvert = request.getParameter("endDate");
	endDate = origFormat.parse(econvert);
	
	DateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
	Date date = originalFormat.parse(econvert);
	String formattedDate = simpleDateFormat.format(date);

 	edate = formattedDate;
}

//Collect the required data based on user input from the SQL server.
if (request.getParameterMap().containsKey("item")) {   
	String item = request.getParameter("item");
	
	
	sql="Select * from CutSheet where (number like'%" + item + "' or number like '" + item + "%' or number like '%" + item + "%' or number='"+ item +"') and endCutTime>='"+sdate+" 00:00:00.000' and endCutTime<='"+edate+" 23:59:59.000'";

} else if (request.getParameterMap().containsKey("order")) {   
	String orderno = request.getParameter("order");
	
	
	sql="Select * from CutSheet where orderno='" + orderno + "'";

} else if (request.getParameterMap().containsKey("endDate") && request.getParameterMap().containsKey("startDate")) {
	sql="Select * from CutSheet where endCutTime>='"+sdate+" 00:00:00.000' and endCutTime<='"+edate+" 23:59:59.000'";
} else if (request.getParameterMap().containsKey("PrePacks")) {
	Date today= new Date();
	Calendar cal = Calendar.getInstance();
	cal.setTime(today);
	
	DateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
	String formattedDate = simpleDateFormat.format(cal.getTime());

	sql="Select * from CutSheet where endCutTime>='"+formattedDate+" 00:00:00.000' and endCutTime<='"+formattedDate+" 23:59:59.000' and PrePack=1";
} else {
	sql="";
}
System.out.println(sql);

if(sql.equals("")) {
	
} else {
	//Query database and output results in a table
	%>
	
	<table id="cutSheetReport" class="responstable">
	<tr>
	<th>Order #</th>
	<th>Item #</th>
	<th>Description One</th>
	<th>Description Two</th>
	<th>Bin Location</th>
	<th>Quantity</th>
	<th>Roll #<br/>R-</th>
	<th>FGDC<br/>P.O. #</th>
	<th>Custom Information</th>
	<th>Start User</th>
	<th>Cut Time in Minutes</th>
	<th>Pick to End in Minutes</th>
	<th>End User</th>
	</tr>
	<%
	try {
		java.sql.Connection reportCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
		java.sql.Statement reportSt = db.dbStatement(reportCon);
		
		ResultSet report = db.dbResult(reportSt, sql);
		
		SimpleDateFormat displayDate = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");	
		
		while (report.next()) {
			int orderno;
			String number="";
			String desc1="";
			String desc2="";
			String binLoc="";
			int quant;
			String roll="";
			String fgdc="";
			String customInfo="";
			String pickTime="";
			String cutStart="";
			String startUser="";
			String cutEnd="";
			String endUser="";
			
			orderno = report.getInt("orderno");
			
			if(report.getString("number")!=null) {
				number = report.getString("number"); 
			}
			if(report.getString("desc1")!=null) {
				desc1 = report.getString("desc1"); 
			}
			if(report.getString("desc2")!=null) {
				desc2 = report.getString("desc2"); 
			}					
			if(report.getString("binLoc")!=null) {
				binLoc = report.getString("binLoc"); 
			}
			
			quant = report.getInt("quant");
			
			if(report.getString("roll")!=null) {
				roll = report.getString("roll"); 
			}
			if(report.getString("fgdc")!=null) {
				fgdc = report.getString("fgdc"); 
			}
			if(report.getString("customInfo")!=null) {
				customInfo = report.getString("customInfo"); 
			}
			if(report.getTimestamp("pickTime")!=null) {
				pickTime = displayDate.format(report.getTimestamp("pickTime")); 
			}
			if(report.getTimestamp("startCutTime")!=null) {
				cutStart = displayDate.format(report.getTimestamp("startCutTime")); 
			}
			if(report.getTimestamp("endCutTime")!=null) {
				cutEnd = displayDate.format(report.getTimestamp("endCutTime")); 
			}
			if(report.getString("startUser")!=null) {
				startUser = report.getString("startUser"); 
			}
			if(report.getString("endUser")!=null) {
				endUser = report.getString("endUser"); 
			}

			Date date1 = displayDate.parse(cutStart);
			Date date2 = displayDate.parse(cutEnd);
			Date date3 = displayDate.parse(pickTime);
			long difference = (date2.getTime() - date1.getTime())/(60 * 1000);
			long difference2 = (date2.getTime() - date3.getTime())/(60 * 1000); 

			%>
			<tr>
			<td><%= orderno%></td>
			<td><%= number%></td>
			<td><%= desc1%></td>
			<td><%= desc2%></td>
			<td><%= binLoc%></td>
			<td><%= quant%></td>
			<td><%= roll%></td>
			<td><%= fgdc%></td>
			<td><%= customInfo%></td>
			<td><%= startUser%></td>
			<td><%= difference%></td>
			<td><%= difference2%></td>
			<td><%= endUser%></td>
				<td>
				<%
				if(userRoles.toLowerCase().trim().contains("wm")) {	
				%>
				<form action="Warehouse/CutSheetAction.jsp">
					<input type="hidden" name="cutID" value="<%=report.getInt("cutID")%>">
					<input type="hidden" name="FormType" value="deleteReport">
					<input type="submit" value="Delete Cut" onclick="return confirm('Are you sure?')">			
				</form>
				</td>
				<td>
				<form action="Warehouse/CutSheetEdit.jsp">
					<input type="hidden" name="cutID" value="<%=report.getInt("cutID")%>">
					<input type="submit" name="edit" value="Edit">		
				</form>	
				</td>
				<% } %>
			</tr>
		<%
		}
		db.dbClose(reportCon, reportSt, report);
		}catch(SQLException e) {
			e.printStackTrace();
		}
	%>
</table>

<input class="export" type="button" onclick="tableToExcel('cutSheetReport')"
	value="Export to Excel">
<%}%>
	
<script>
	//Function to export tables to excel.
	function tableToExcel(x) {
		var tab_text = "<table border='2px'><tr bgcolor='#87AFC6'>";
		var textRange;
		var j = 0;
		tab = document.getElementById(x); // id of table

		for (j = 0; j < tab.rows.length; j++) {
			tab_text = tab_text + tab.rows[j].innerHTML + "</tr>";
			//tab_text=tab_text+"</tr>";
		}

		tab_text = tab_text + "</table>";
		tab_text = tab_text.replace(/<A[^>]*>|<\/A>/g, "");//remove if u want links in your table
		tab_text = tab_text.replace(/<img[^>]*>/gi, ""); // remove if u want images in your table
		tab_text = tab_text.replace(/<input[^>]*>|<\/input>/gi, ""); // reomves input params

		var ua = window.navigator.userAgent;
		var msie = ua.indexOf("MSIE ");

		if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) // If Internet Explorer
		{
			txtArea1.document.open("txt/html", "replace");
			txtArea1.document.write(tab_text);
			txtArea1.document.close();
			txtArea1.focus();
			sa = txtArea1.document.execCommand("SaveAs", true,
					"_FreightQuote.xls");
		} else
			//other browser not tested on IE 11
			sa = window.open('data:application/vnd.ms-excel,'
					+ encodeURIComponent(tab_text));

		return (sa);
	}
</script>

<jsp:include page="../Includes/footer.jsp" />