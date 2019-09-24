<% /**
 * Purpose:To show the difference in transactions for different price ranges based on date ranges.
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

String sdate="";
String edate="";
String sdate2 ="";
String edate2 ="";

SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM/dd/yyyy");

DB_util db = new DB_util();
String sql = "";

int Orders=0;

//Set dates to be used in SQL queries.
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
if (request.getParameterMap().containsKey("startDate2")) {
	String sconvert = request.getParameter("startDate2");
	startDate = origFormat.parse(sconvert);

	DateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
	Date date = originalFormat.parse(sconvert);
	String formattedDate = simpleDateFormat.format(date);

	sdate2 = formattedDate;
}

if (request.getParameterMap().containsKey("endDate2")) {
	String econvert = request.getParameter("endDate2");
	endDate = origFormat.parse(econvert);
	
	DateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
	Date date = originalFormat.parse(econvert);
	String formattedDate = simpleDateFormat.format(date);

	edate2 = formattedDate;
}

System.out.println("sdate: " + sdate);
System.out.println("edate: " + edate);
System.out.println("sdate2: " + sdate2);
System.out.println("edate2: " + edate2);
%>


<!-- Form for users to enter date range -->
<form style="veritcal-align: center; text-align: center;" method="post"
	action="Sales/TransactionTiers.jsp">
<h1 style="text-align:center;margin-bottom:1em;">Transaction Tier Dashboard</h1>
	<p>
		From: <input type="date" name="startDate" required> To: <input
			type="date" name="endDate" required>
	</p>
	<p>
		From: <input type="date" name="startDate2" required> To: <input
			type="date" name="endDate2" required>
	</p>
	<input type="submit" value="Submit" name="submit">

</form>

<%if(sdate.trim().equals(edate.trim())){ %>
	<h3 style="text-align: center">Transaction data for
		<%=sdate%></h3>
<%}else{%>
	<h3 style="text-align: center">Transaction data from
		<%=sdate%> to <%=edate%></h3>
<%} %>		


<%
int[] lowTier = new int[]{ 0,50,100,250,375,500,750,1000,1500,3000,5000 }; 
int[] highTier = new int[]{ 50,100,250,375,500,750,1000,1500,3000,5000,9999999 }; 
int[] table1 = new int[11]; 
int[] table2 = new int[11];
int i;

if(sdate2!="") {
	
for (i = 0; i < lowTier.length; i++) { 	  

	//Get total orders for date range 1
try {
	java.sql.Connection totalCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement totalSt = db.dbStatement(totalCon);

sql="select count(i.orderNo) as Total_Orders from INVOICE i Inner Join CMS c on c.orderno=i.orderno WHERE i.INV_DATE >= '" + sdate + "'  AND i.INV_DATE <= '" + edate + "' AND c.ordertype = 'web' "+
    "and i.merch<=" + highTier[i] + " and i.merch>" + lowTier[i];
		  		 	  		 
ResultSet totals = db.dbResult(totalSt, sql);

while (totals.next()) {

	
	//Check to see Revenue has a value

	if(totals.getString("Total_Orders") == null) {
	    table1[i]=0;
	}
	else {
		table1[i]=totals.getInt("Total_Orders");
	}
	%>

	<%
}
db.dbClose(totalCon, totalSt, totals);
}catch(SQLException e) {
	e.printStackTrace();
}

//Get total orders for date range 2
try {
	java.sql.Connection totalCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement totalSt = db.dbStatement(totalCon);

sql="select count(i.orderNo) as Total_Orders from INVOICE i Inner Join CMS c on c.orderno=i.orderno WHERE i.INV_DATE >= '" + sdate2 + "'  AND i.INV_DATE <= '" + edate2 + "' AND c.ordertype = 'web' "+
    "and i.merch<=" + highTier[i] + " and i.merch>" + lowTier[i];
		  		 	  		 
ResultSet totals = db.dbResult(totalSt, sql);

while (totals.next()) {

	
	//Check to see Revenue has a value

	if(totals.getString("Total_Orders") == null) {
	    table2[i]=0;
	}
	else {
		table2[i]=totals.getInt("Total_Orders");;
	}
	%>

	<%
}
db.dbClose(totalCon, totalSt, totals);
}catch(SQLException e) {
	e.printStackTrace();
}

} 

%>

<!-- Display data in a table -->
<h3 style="text-align: center">Date Range 1 (<%=sdate %> to <%=edate %>)</h3>
<table id="tierTable1" class="responstable">
	<tr>
		<th>0-50</th>
		<th>50.01-100</th>
		<th>100.01-250</th>
		<th>250.01-375</th>
		<th>375.01-500</th>
		<th>500.01-750</th>
		<th>750.01-1000</th>
		<th>1000.01-1500</th>
		<th>1500.01-3000</th>
		<th>3000.01-5000</th>
		<th>5000.01+</th>
	</tr>
		<tr>
		<td><%=table1[0] %></td>
		<td><%=table1[1] %></td>
		<td><%=table1[2] %></td>
		<td><%=table1[3] %></td>
		<td><%=table1[4] %></td>
		<td><%=table1[5] %></td>
		<td><%=table1[6] %></td>
		<td><%=table1[7] %></td>
		<td><%=table1[8] %></td>
		<td><%=table1[9] %></td>
		<td><%=table1[10] %></td>
	</tr>
</table>

<h3 style="text-align: center">Date Range 2 (<%=sdate2 %> to <%=edate2 %>)</h3>
<table id="tierTable2" class="responstable">
	<tr>
		<th>0-50</th>
		<th>50.01-100</th>
		<th>100.01-250</th>
		<th>250.01-375</th>
		<th>375.01-500</th>
		<th>500.01-750</th>
		<th>750.01-1000</th>
		<th>1000.01-1500</th>
		<th>1500.01-3000</th>
		<th>3000.01-5000</th>
		<th>5000.01+</th>
	</tr>
	<tr>
		<td><%=table2[0] %></td>
		<td><%=table2[1] %></td>
		<td><%=table2[2] %></td>
		<td><%=table2[3] %></td>
		<td><%=table2[4] %></td>
		<td><%=table2[5] %></td>
		<td><%=table2[6] %></td>
		<td><%=table2[7] %></td>
		<td><%=table2[8] %></td>
		<td><%=table2[9] %></td>
		<td><%=table2[10] %></td>
	</tr>
</table>

<h3 style="text-align: center">Difference</h3>
<table id="difference" class="responstable">
	<tr>
		<th>0-50</th>
		<th>50.01-100</th>
		<th>100.01-250</th>
		<th>250.01-375</th>
		<th>375.01-500</th>
		<th>500.01-750</th>
		<th>750.01-1000</th>
		<th>1000.01-1500</th>
		<th>1500.01-3000</th>
		<th>3000.01-5000</th>
		<th>5000.01+</th>
	</tr>
	<tr>
		<td><%=(table1[0]-table2[0])%></td>
		<td><%=(table1[1]-table2[1])%></td>
		<td><%=(table1[2]-table2[2]) %></td>
		<td><%=(table1[3]-table2[3])%></td>
		<td><%=(table1[4]-table2[4])%></td>
		<td><%=(table1[5]-table2[5])%></td>
		<td><%=(table1[6]-table2[6])%></td>
		<td><%=(table1[7]-table2[7])%></td>
		<td><%=(table1[8]-table2[8])%></td>
		<td><%=(table1[9]-table2[9])%></td>
		<td><%=(table1[10]-table2[10])%></td>
	</tr>
</table>
<%
} 

%>
<jsp:include page="../Includes/footer.jsp" />