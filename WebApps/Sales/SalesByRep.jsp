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
<link rel="stylesheet" href="CSS/SalesByRep.css" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util" %>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%
	// Set refresh, autoload time as 15 Minutes
response.setIntHeader("Refresh", 3600);

String sdate;
String edate;
String sdateLastYear;
String edateLastYear;
Double merchTotal=0.00;
int totalOrders=0;
Double merchTotalLY=0.00;
int totalOrdersLY=0;
		
//Format Start and End Dates
SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM/dd/yyyy");

DB_util db = new DB_util();
String sql = "";

int Orders=0;
double rev=0.00;
int OrdersLY=0;
double revLY=0.00;
String salesRep="";
NumberFormat defaultFormat = NumberFormat.getCurrencyInstance();
DecimalFormat df = new DecimalFormat("#.00");


Date endDate = new Date();
Date startDate = new Date();

Calendar c = Calendar.getInstance();

c.setTime(startDate);
c.set(Calendar.DAY_OF_MONTH, 1);
startDate = c.getTime();

sdate = simpleDateFormat.format(startDate);



c.setTime(endDate);
c.add(Calendar.DATE, -1);
endDate = c.getTime();
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
<!-- Form to allow date entry -->
<form style="veritcal-align: center; text-align: center;" method="post"
	action="Sales/SalesByRep.jsp">
<h1 style="text-align:center;margin-bottom:1em;">Shipped Sales By Rep</h1>
	<p>
		From: <input type="date" name="startDate" required> To: <input
			type="date" name="endDate" required>
	</p>
	
	<input type="submit" value="Submit" name="submit">

</form>
<div>
<%if(sdateLastYear.trim().equals(edateLastYear.trim())){ %>
	<h3 style="text-align: center">Data for
		<%=sdate%></h3>
<%}else{%>
	<h3 style="text-align: center">Data from
		<%=sdate%> to <%=edate%></h3>
<%} %>		

<!-- Create table headers -->
<table id="salesByRep" class="responstable">
<tr>
	<th>Sales Rep</th>
	<th>Number of Orders</th>
	<th>Total Merchandise Amount</th>
</tr>

<%
try {
	java.sql.Connection totalCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement totalSt = db.dbStatement(totalCon);

sql = "select o.sales_id, SUM(i.MERCH) as Merchandise_Total, count(i.orderno) as Total_Orders "+
"from invoice i "+
"inner join cms o "+
"on o.orderno=i.ORDERNO "+
"where i.inv_date>= '" + sdate + "' "+
"and i.inv_date<= '" + edate + "' "+
"and o.ordertype!='WEB' "+
"group by o.SALES_ID";

ResultSet totals = db.dbResult(totalSt, sql);

while (totals.next()) {

	salesRep=totals.getString("sales_id");
	//Check to see Revenue has a value
	if(totals.getString("Merchandise_Total") == null) {
	    rev=0.00;
	}
	else {
		rev=totals.getDouble("Merchandise_Total");
	}
	
	if(totals.getString("Total_Orders") == null) {
	    Orders=0;
	}
	else {
		rev=totals.getDouble("Merchandise_Total");
		Orders=totals.getInt("Total_Orders");	
	}
	merchTotal=merchTotal+rev;
	totalOrders=totalOrders+Orders;
			
	%>	
<tr>
	<td><%=salesRep %></td>
	<td><%=Orders %></td>
	<td><%=defaultFormat.format(rev) %></td>
</tr>
	<%
}
db.dbClose(totalCon, totalSt, totals);
}catch(SQLException e) {
	e.printStackTrace();
}

%>
<!-- Display information from SQL queries -->
<tr class="totals">
	<td>Totals</td>
	<td><%=totalOrders %></td>
	<td><%=defaultFormat.format(merchTotal) %></td>
</tr>

</table>
<div style="text-align:center">
<input class="export" type="button" onclick="tableToExcel('salesByRep')"
	value="Export to Excel">
</div>
</div>
<div>
<%if(sdateLastYear.trim().equals(edateLastYear.trim())){ %>
	<h3 style="text-align: center">Data for
		<%=sdateLastYear%></h3>
<%}else{%>
	<h3 style="text-align: center">Data from
		<%=sdateLastYear%> to <%=edateLastYear%></h3>
<%} %>		

<!-- Display headers for the previous year -->
<table id="salesByRepLY" class="responstable">
<tr>
	<th>Sales Rep</th>
	<th>Number of Orders</th>
	<th>Total Merchandise Amount</th>
</tr>

<%
try {
	java.sql.Connection totalCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement totalSt = db.dbStatement(totalCon);

sql = "select o.sales_id, SUM(i.MERCH) as Merchandise_Total, count(i.orderno) as Total_Orders "+
"from invoice i "+
"inner join cms o "+
"on o.orderno=i.ORDERNO "+
"where i.inv_date>= '" + sdateLastYear + "' "+
"and i.inv_date<= '" + edateLastYear + "' "+
"and o.ordertype!='WEB' "+
"group by o.SALES_ID";

ResultSet totals = db.dbResult(totalSt, sql);

while (totals.next()) {

	salesRep=totals.getString("sales_id");
	//Check to see Revenue has a value
	if(totals.getString("Merchandise_Total") == null) {
	    revLY=0.00;
	}
	else {
		revLY=totals.getDouble("Merchandise_Total");
	}
	
	if(totals.getString("Total_Orders") == null) {
	    OrdersLY=0;
	}
	else {
		revLY=totals.getDouble("Merchandise_Total");
		OrdersLY=totals.getInt("Total_Orders");	
	}
	merchTotalLY=merchTotalLY+revLY;
	totalOrdersLY=totalOrdersLY+OrdersLY;
			
	%>	
<tr>
	<td><%=salesRep %></td>
	<td><%=OrdersLY %></td>
	<td><%=defaultFormat.format(revLY) %></td>
</tr>
	<%
}
db.dbClose(totalCon, totalSt, totals);
}catch(SQLException e) {
	e.printStackTrace();
}

%>
<!-- Display information gathered from SQL queries -->
<tr class="totals">
	<td>Totals</td>
	<td><%=totalOrdersLY %></td>
	<td><%=defaultFormat.format(merchTotalLY) %></td>
</tr>

</table>
<div style="text-align:center">
<input class="export" type="button" onclick="tableToExcel('salesByRepLY')"
	value="Export to Excel">
</div>
</div>
		
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