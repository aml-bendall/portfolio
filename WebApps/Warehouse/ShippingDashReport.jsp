<% /**
 * Purpose:Provides a report for the Warehouse Manager to track metrics and shipping times per box and per order.
 * Created On: 10/20/2017
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

<link rel="stylesheet" href="CSS/ShippingDash.css" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="fibreApps.Core.DB_util" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.time.*"%>
<%@ page import="java.time.format.DateTimeFormatter"%>
<%@ page import="java.text.DecimalFormat"%>

<%		// Set refresh, autoload time as 15 Minutes
response.setIntHeader("Refresh", 900);

DB_util db = new DB_util();

DecimalFormat df = new DecimalFormat("#.00");

//Initialize Variables
int totalBoxes=0;
int totalBoxes2=0;
int totalOrders=0;
int totalOrders2=0;
int totalMinutes=0;
double divideBy=0.0;
int ArrayIndex=0;
int count=0;
int noTime=0;

String sdate="";
String edate="";

//Format user entered dates for SQL queries
Date today= new Date();
Calendar cal = Calendar.getInstance();
cal.setTime(today);

SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM/dd/yyyy");

if (request.getParameterMap().containsKey("startDate")) {
	String sconvert = request.getParameter("startDate");

	DateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
	Date date = originalFormat.parse(sconvert);
	String formattedDate = simpleDateFormat.format(date);

	sdate = formattedDate;
	
	if(simpleDateFormat.parse(sdate).before(simpleDateFormat.parse("02/08/2018"))){
		noTime=1;
	}
} else {
	
	sdate = simpleDateFormat.format(today);
}

if (request.getParameterMap().containsKey("endDate")) {
	String econvert = request.getParameter("endDate");

	DateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
	Date date = originalFormat.parse(econvert);
	String formattedDate = simpleDateFormat.format(date);

	edate = formattedDate;
} else {
	
	edate = simpleDateFormat.format(today);
}


System.out.println(sdate);
System.out.println(edate);
%>

<!-- Post the report back to this page with date ranges. -->
<form style="veritcal-align: center; text-align: center;" method="post"
action="Warehouse/ShippingDashReport.jsp">
	<p>
		From: <input type="date" name="startDate" required> To: <input
			type="date" name="endDate" required>
	</p>
		<input type="submit" value="Submit" name="submit">
</form>

<h2 style="text-align:center;">Showing results from <%=sdate %> to <%=edate %></h2>

<%
if(noTime==1) {
	 %>
	<h3 style="text-align:center;">Times are only accurate if the starting date is after 02/08/2018</h3>
	<%
	}

try {
	//Connect to the boxes table to get a list of boxes that are setup. This will be used later in SQL statements.
	java.sql.Connection boxCon =  db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

	java.sql.Statement boxSt = db.dbStatement(boxCon);

	String sql = "SELECT USER_ID "+
	  		  "FROM WMTRANS "+
			  "where transdate>='" + sdate +" 00:00:00.000' "+
			  "and transdate<='" + edate +" 23:59:59.000' "+
			  "and STATUS='SH' "+
			  "group by user_id";

		ResultSet boxes = db.dbResult(boxSt, sql);
		
		    
			while (boxes.next()) {
				ArrayIndex=ArrayIndex+1;
			}
			db.dbClose(boxCon, boxSt, boxes);
		} catch(SQLException e) {
		
		}

//Intialize array to store Shipper Data.
String[][] perHour = new String[ArrayIndex][5];
%>

<div class="pageContainer">

<%	
	try {
		//Connect to the time log table to get the amount of time the user was logged in shipping.
		java.sql.Connection minCon =  db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

		java.sql.Statement minSt = db.dbStatement(minCon);
		
		String sql ="SELECT userName,initials, SUM(Total_Time) as Total_Time "+ 
					  "From ( "+
								"select "+
									"userName,initials,DATEDIFF(MINUTE, beginTime, endTime) as Total_Time "+ 
								"from "+
									"shippingTime where progress=1 and beginTime>'"+sdate+" 00:00:00' and endTime<'"+edate+" 23:59:59' "+
								"UNION ALL "+
								"select "+
									"userName,initials,DATEDIFF(MINUTE, beginTime, GetDate()) as Total_Time from shippingTime where progress=0  and beginTime>'"+sdate+" 00:00:00' and endTime<'"+edate+" 23:59:59' "+
								") as tbl "+
						  "Group by "+
									"userName,initials";

			ResultSet minutes = db.dbResult(minSt, sql);
			
			//0 id
			//1 name
			//2 boxes
			//3 orders
			//4 minutes shipping
			count=0;
				while (minutes.next()) {
				    perHour[count][0]=minutes.getString("initials");
					perHour[count][1]=minutes.getString("userName");
					perHour[count][4]=String.valueOf(minutes.getInt("Total_Time"));
					count=count+1;
				}
				db.dbClose(minCon, minSt, minutes);
			} catch(SQLException e) {
			
			}
%>
</div>

<div class="pageContainer">
<%
//Logs the Shipper as actively shipping. This allowes us to track time shipping during a day for each shipper.
if(request.getParameter("error")!=null) {
	if (request.getParameter("error").equals("1")) {
	%>
	<h2 style="color:red;">Invalid Pin - Please try again with the correct pin.</h2>
	<%
	}
	if (request.getParameter("error").equals("2")) {
		%>
		<h2 style="color:red;">You must end your current shipping session before beginning another.</h2>
		<%
		}
	if (request.getParameter("error").equals("3")) {
		%>
		<h2 style="color:red;">There is not a current shipping session to end for the Pin entered.</h2>
		<%
		}
}

//Recall URL and validate to the user the session start or end.
if(request.getParameter("msg")!=null) {
	if (request.getParameter("msg").equals("1")) {
	%>
	<h2 style="color:green;">Shipping Session Started.</h2>
	<%
	}
	if (request.getParameter("msg").equals("2")) {
		%>
		<h2 style="color:green;">Shipping Session Ended.</h2>
		<%
		}
}
%>
<!-- Display data in tables based off of data in SQL that is stored in the perHour array. -->
<table class="container" id="ExportAll">
	<tr><td>
		<table class="responstable">
		<tr>
		<th colspan="2">Boxes Shipped</th>
		</tr>
		<tr>
			<td><b>Total Boxes</b></td>
			<td class="totalBox"><b></b></td>
		</tr>
		<%

		try {
		//Connect to the SalesDashboxes table to get a list of boxes that are setup. This will be used later in SQL statements.
		java.sql.Connection boxCon =  db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement boxSt = db.dbStatement(boxCon);

		String sql = "SELECT USER_ID,COUNT(box_id) as total_boxes "+
		  		  "FROM WMTRANS "+
				  "where transdate>='" + sdate +" 00:00:00.000' "+
				  "and transdate<='" + edate +" 23:59:59.000' "+
				  "and STATUS='SH' "+
				  "group by user_id "+
				  "order by total_boxes desc";

			ResultSet boxes = db.dbResult(boxSt, sql);
			
				while (boxes.next()) {
				
					for(int i = 0; i < perHour.length; i++)
					{
						if(perHour[i][0]!=null && perHour[i][0].equals(boxes.getString("user_id").trim())) {
					    perHour[i][2]=String.valueOf(boxes.getInt("total_boxes"));
						}
					}
					totalBoxes2=totalBoxes2+boxes.getInt("total_boxes");
				%>
				<tr>
					<td><%=boxes.getString("USER_ID") %></td>
					<td><%=boxes.getInt("total_boxes") %></td>
				</tr>
				<%
				}
				db.dbClose(boxCon, boxSt, boxes);
			} catch(SQLException e) {
			
			}
		%>
		</table>
	</td>
	<td>
<table class="responstable">
		<tr>
		<th colspan="2"># Orders Shipped</th>
		<tr>
			<td><b>Total Orders</b></td>
			<td class="totalOrder"><b></b></td>
		</tr>
		<%	try {
		//Connect to the SalesDashorders table to get a list of orders that are setup. This will be used later in SQL statements.
		java.sql.Connection ordCon =  db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement ordSt = db.dbStatement(ordCon);

		String sql = "SELECT USER_ID,count(DISTINCT ORDERNO) as total_orders FROM WMTRANS where transdate>='"+ sdate +" 00:00:00.000' and transdate<='"+ edate +" 23:59:59.000' and STATUS='SH' group by user_id order by total_orders desc";

			ResultSet orders = db.dbResult(ordSt, sql);
				//0 id
				//1 name
				//2 boxes
				//3 orders
				//4 minutes shipping
				
			    
				while (orders.next()) {
					for(int i = 0; i < perHour.length; i++)
					{
					if(perHour[i][0]!=null && perHour[i][0].equals(orders.getString("user_id").trim())) {
					    perHour[i][3]= String.valueOf(orders.getInt("total_orders"));
						}
					}
				totalOrders2=totalOrders2+orders.getInt("total_orders");
				%>
				
				<tr>
					<td><%=orders.getString("USER_ID") %></td>
					<td><%=orders.getInt("total_orders") %></td>
				</tr>
				<%
				}
				db.dbClose(ordCon, ordSt, orders);
			} catch(SQLException e) {
			
			}
			 %>
		</table>
		<%

		for(int i = 0; i < perHour.length; i++)
		{
			if(perHour[i][2]!=null) {
		totalBoxes=totalBoxes+Integer.valueOf(perHour[i][2]);
			}
		if(perHour[i][3]!=null) {
		totalOrders=totalOrders+Integer.valueOf(perHour[i][3]);
		}
		if(perHour[i][4]!=null) {
		totalMinutes=totalMinutes+Integer.valueOf(perHour[i][4]);
		}
		}
		%>
	</td>
	</tr><tr>
	<td>
		<table class="responstable">
		<tr>
		<th colspan="2">Boxes Per Hour</th>
			<tr>
				<td><b>Total Average</b></td>
				<td><b><%=df.format(Double.valueOf(totalBoxes)/(Double.valueOf(totalMinutes)/60)) %></b></td>
			</tr>
		<%
			for(int i = 0; i < perHour.length; i++)
			{ if(perHour[i][0]!=null) {
			%>
			<tr>
				<td><%=perHour[i][0] %></td>
				<td><%=df.format(Double.valueOf(perHour[i][2])/(Double.valueOf(perHour[i][4])/60)) %></td>
			</tr>
			<%	
			}
			}
		%>
		</table>
	</td>
	<td>
		<table class="responstable">
		<tr>
		<th colspan="2">Shipments Per Hour</th>
			<tr>
				<td><b>Total Average</b></td>
				<td><b><%=df.format(Double.valueOf(totalOrders)/(Double.valueOf(totalMinutes)/60)) %></b></td>
			</tr>
		<%
			for(int i = 0; i < perHour.length; i++)
			{ if(perHour[i][0]!=null) {
			%>
			<tr>
				<td><%=perHour[i][0] %></td>
				<td><%=df.format(Double.valueOf(perHour[i][3])/(Double.valueOf(perHour[i][4])/60)) %></td>
			</tr>
			<%	
			}
			}
		%>
		</table>
	</td>
	</tr><tr >
	<td colspan="2">
		<table class="responstable" style="width:50%; margin: 0 auto;">
		<tr>
		<th colspan="2">Time Spent Shipping in Hours</th>
		<tr>
				<td><b>Total Time in Hours</b></td>
				<td><b><%=df.format(Double.valueOf(totalMinutes)/60) %></b></td>
			</tr>
		<%
			for(int i = 0; i < perHour.length; i++)
			{ if(perHour[i][0]!=null) {

			%>
			<tr>
				<td><%=perHour[i][0] %></td>
				<td><%=df.format(Double.valueOf(perHour[i][4])/60) %></td>
			</tr>
			<%		
			}
			}
		%>
		</table>
	</td>
	</tr>
</table>
</div>

<script>
var y = document.getElementsByClassName('totalBox');
for (i = 0; i < y.length; i++) {
    y[i].innerHTML= <%=totalBoxes2%>;
}
var x = document.getElementsByClassName('totalOrder');
for (i = 0; i < x.length; i++) {
    x[i].innerHTML= <%=totalOrders2%>;
}

</script>

<input class="export" type="button" onclick="tableToExcel('ExportAll')"
	value="Export to Excel">

	
<script>
//Function to allow the table data to be exported to excel
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