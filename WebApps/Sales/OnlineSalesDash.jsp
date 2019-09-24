<% /**
 * Purpose:Provides an interface for the daily online sales.
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
<jsp:include page="../Includes/header.jsp" />
<link rel="stylesheet" href="CSS/OnlineSalesDash.css" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%
	// Set refresh, autoload time as 15 Minutes
response.setIntHeader("Refresh", 3600);


//Set Date range for SQL queries.
String sdate;
String edate;
String sdateLastYear;
String edateLastYear;

SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM/dd/yyyy");

DB_util db = new DB_util();
String sql = "";

int Orders=0;
double rev=0.00;
double avgRev=0.00;
double avgLines=0;
int TotalLines=0;

Date endDate = new Date();
Date startDate = new Date();

Calendar c = Calendar.getInstance();

sdate = simpleDateFormat.format(startDate);
edate = simpleDateFormat.format(endDate);

DateFormat origFormat = new SimpleDateFormat("yyyy-MM-dd");
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

System.out.println("sdate: " + sdate);
System.out.println("edate: " + edate);

c.setTime(startDate);
c.add(Calendar.DATE, -365);
startDate = c.getTime();

sdateLastYear = simpleDateFormat.format(startDate);

c.setTime(endDate);
c.add(Calendar.DATE, -365);
endDate = c.getTime();

edateLastYear = simpleDateFormat.format(endDate);
%>

<form style="veritcal-align: center; text-align: center;" method="post"
	action="Sales/OnlineSalesDash.jsp">
<h1 style="text-align:center;margin-bottom:1em;">Online Sales Dashboard</h1>
<!-- 	Form for selecting date ranges -->
	<p>
		From: <input type="date" name="startDate" required> To: <input
			type="date" name="endDate" required>
	</p>
	
	<input type="submit" value="Submit" name="submit">
<p>This dashboard only shows data for orders which have a status of "Shipped"</p>
</form>

<%if(sdate.trim().equals(edate.trim())){ %>
	<h3 style="text-align: center">Web order data for
		<%=sdate%></h3>
<%}else{%>
	<h3 style="text-align: center">Web order data from
		<%=sdate%> to <%=edate%></h3>
<%} %>		
<!-- Create table and collect data from SQL for the entered date range -->
<table id="onlineSales" class="responstable">
<tr>
	<th>Total Orders</th>
	<th>Total Merchandise Amount</th>
	<th>Average Merchandise Amount</th>
	<th>Total Line Items</th>
	<th>Average Line Items Per Order</th>
</tr>

<%
try {
	java.sql.Connection totalCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement totalSt = db.dbStatement(totalCon);

sql="select sum(i.merch) as REVENUE, count(i.orderNo) as Total_Orders from INVOICE i Inner Join CMS c on c.orderno=i.orderno WHERE i.INV_DATE >= '" + sdate + "'  AND i.INV_DATE <= '" + edate + "' AND c.ordertype = 'web'";
		  		 	  		 
ResultSet totals = db.dbResult(totalSt, sql);

while (totals.next()) {

	
	//Check to see Revenue has a value
	if(totals.getString("Revenue") == null) {
	    rev=0.00;
	}
	else {
		rev=totals.getDouble("Revenue");
	}
	
	if(totals.getString("Total_Orders") == null) {
	    Orders=0;
	}
	else {
		rev=totals.getDouble("Revenue");
		Orders=totals.getInt("Total_Orders");	
	}
	
}
db.dbClose(totalCon, totalSt, totals);
}catch(SQLException e) {
	e.printStackTrace();
}
%>


<%
try {
	java.sql.Connection liCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement liSt = db.dbStatement(liCon);

sql = "select count(item) as Total_Items from items where orderno in (select orderno from CMS "+
		  		 "WHERE ODR_DATE >= '" + sdate + "' "+
				 "AND ODR_DATE <= '" + edate + "' "+
		  		 "AND ordertype = 'web' "+
		  		 "AND ORDER_ST2 = 'SH')";

ResultSet items = db.dbResult(liSt, sql);

while (items.next()) {
	
	if(items.getString("Total_Items") == null) {
	    TotalLines=0;
	}
	else {
		TotalLines=items.getInt("Total_Items");
	}
	
}
db.dbClose(liCon, liSt, items);
}catch(SQLException e) {
	e.printStackTrace();
}
%>

<%
avgRev=rev/Orders;
avgLines=Double.valueOf(TotalLines)/Double.valueOf(Orders);

NumberFormat defaultFormat = NumberFormat.getCurrencyInstance();
DecimalFormat df = new DecimalFormat("#.00");

%>

<tr>
	<td><%=Orders %></td>
	<td><%=defaultFormat.format(rev) %></td>
	<td><%=defaultFormat.format(avgRev) %></td>
	<td><%=TotalLines %></td>
	<td><%=df.format(avgLines) %></td>
</tr>

</table>

<input style="margin-top: 1em;" type="button" onclick="tableToExcel('onlineSales')"
	value="Export to Excel">
	
	<%if(sdateLastYear.trim().equals(edateLastYear.trim())){ %>
	<h3 style="text-align: center">Web order data for
		<%=sdateLastYear%></h3>
<%}else{%>
	<h3 style="text-align: center">Web order data from
		<%=sdateLastYear%> to <%=edateLastYear%></h3>
<%} %>		

<!-- Create table and collect data from SQL for the previous year -->
<table id="onlineSalesLY" class="responstable">
<tr>
	<th>Total Orders</th>
	<th>Total Merchandise Amount</th>
	<th>Average Merchandise Amount</th>
	<th>Total Line Items</th>
	<th>Average Line Items Per Order</th>
</tr>

<%
try {
	java.sql.Connection totalCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement totalSt = db.dbStatement(totalCon);

sql="select sum(i.merch) as REVENUE, count(i.orderNo) as Total_Orders from INVOICE i Inner Join CMS c on c.orderno=i.orderno WHERE i.INV_DATE >= '" + sdateLastYear + "'  AND i.INV_DATE <= '" + edateLastYear + "' AND c.ordertype = 'web'";

ResultSet totals = db.dbResult(totalSt, sql);

while (totals.next()) {

	
	//Check to see Revenue has a value
	if(totals.getString("Revenue") == null) {
	    rev=0.00;
	}
	else {
		rev=totals.getDouble("Revenue");
	}
	
	if(totals.getString("Total_Orders") == null) {
	    Orders=0;
	}
	else {
		rev=totals.getDouble("Revenue");
		Orders=totals.getInt("Total_Orders");	
	}
	
}
db.dbClose(totalCon, totalSt, totals);
}catch(SQLException e) {
	e.printStackTrace();
}
%>


<%
try {
	java.sql.Connection liCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement liSt = db.dbStatement(liCon);

sql = "select count(item) as Total_Items from items where orderno in (select orderno from CMS "+
		  		 "WHERE ODR_DATE >= '" + sdateLastYear + "' "+
				 "AND ODR_DATE <= '" + edateLastYear + "' "+
		  		 "AND ordertype = 'web' "+
		  		 "AND ORDER_ST2 = 'SH')";

ResultSet items = db.dbResult(liSt, sql);

while (items.next()) {
	
	if(items.getString("Total_Items") == null) {
	    TotalLines=0;
	}
	else {
		TotalLines=items.getInt("Total_Items");
	}
	
}
db.dbClose(liCon, liSt, items);
}catch(SQLException e) {
	e.printStackTrace();
}
%>

<%
avgRev=rev/Orders;
avgLines=Double.valueOf(TotalLines)/Double.valueOf(Orders);

%>

<tr>
	<td><%=Orders %></td>
	<td><%=defaultFormat.format(rev) %></td>
	<td><%=defaultFormat.format(avgRev) %></td>
	<td><%=TotalLines %></td>
	<td><%=df.format(avgLines) %></td>
</tr>

</table>


<input style="margin-top: 1em;" type="button" onclick="tableToExcel('onlineSalesLY')"
	value="Export to Excel">
	
<script>
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