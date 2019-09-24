<% /**
 * Purpose:Provides an interface for the fabric cutters to view all MTO cuts and PrePacks that need created. "Fabrics Dashboard"
 * Created On: 02/05/2018
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

<link rel="stylesheet" href="CSS/FabricsDash.css" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="fibreApps.Core.DB_util" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.time.LocalDate"%>
<%@ page import="java.time.LocalDateTime"%>
<%@ page import="java.time.Duration"%>
<%@ page import="java.time.format.DateTimeFormatter"%>
<%@ page import="java.text.DecimalFormat"%>

<h1 style="text-align:center;">Fabrics Dashboard</h1>

<form style="veritcal-align: center; text-align: center;" method="post"
action="Warehouse/FabricsDashReport.jsp">
	<p>
		From: <input type="date" name="startDate" required> To: <input
			type="date" name="endDate" required>
	</p>
		<input type="submit" value="Submit" name="submit">
</form>

<%

String sdate="";
String edate="";
int ArrayIndex=0;
int totalPerHr=0; 
double totalYardsCut=0;
double totalCycles=0;
double totalTime=0;
double pickToStart=0;

DecimalFormat df = new DecimalFormat("#.00");

DB_util db = new DB_util();
String sql="";

Date today= new Date();
Calendar cal = Calendar.getInstance();
cal.setTime(today);

//Set date for SQL queries based on user input
SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM/dd/yyyy");
sdate = simpleDateFormat.format(today);
edate = simpleDateFormat.format(today);

if (request.getParameterMap().containsKey("startDate")) {
	String sconvert = request.getParameter("startDate");

	DateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
	Date date = originalFormat.parse(sconvert);
	String formattedDate = simpleDateFormat.format(date);

	sdate = formattedDate;
}


if (request.getParameterMap().containsKey("endDate")) {
	String econvert = request.getParameter("endDate");

	DateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
	Date date = originalFormat.parse(econvert);
	String formattedDate = simpleDateFormat.format(date);

	edate = formattedDate;
}

try {
	//Connect to the CutSheet table to gather a count of all users who cut fabric in the given date range.
	java.sql.Connection indexCon =  db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

	java.sql.Statement indexSt = db.dbStatement(indexCon);

	sql="select startUser From CutSheet where pickTime>='"+sdate+" 0:00:00' and pickTime<='"+edate+" 23:59:59' and startUser is not null group by startUser";

		ResultSet index = db.dbResult(indexSt, sql);
		
			while (index.next()) {
			ArrayIndex=ArrayIndex+1;
			}
			
			db.dbClose(indexCon, indexSt, index);
		} catch(SQLException e) {
		
		}


		String Cuts[][]= new String[ArrayIndex][4];
		
		try {
			//Connect to the database to get the name of any user who has worked cuts in the given date range.
			java.sql.Connection indexCon =  db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

			java.sql.Statement indexSt = db.dbStatement(indexCon);

			sql="select startUser From CutSheet where pickTime>='"+sdate+" 0:00:00' and pickTime<='"+edate+" 23:59:59' and startUser is not null group by startUser";

				ResultSet index = db.dbResult(indexSt, sql);
				
				//0 Name
				//1 Yards
				//2 Total Cuts Completed
				int count=0;

				while (index.next()) {
					Cuts[count][0]= index.getString("startUser");
					Cuts[count][1]= "0";
					Cuts[count][2]="0";
					count=count+1;
				}
					
					db.dbClose(indexCon, indexSt, index);
				} catch(SQLException e) {
				
				}

		try {
			//Connect to the SQL database to get user specific data and save it to the Cuts array.		java.sql.Connection minCon =  db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
			java.sql.Statement minSt = db.dbStatement(minCon);
			
			sql ="SELECT startUser, SUM(Total_Time) as Total_Time "+ 
					  "From ( "+ 
								"select "+
									"startUser,DATEDIFF(MINUTE, startCutTime, endCutTime) as Total_Time "+
								"from "+
									"CutSheet where inProgress=2 and endCutTime>'"+sdate+" 00:00:00' and endCutTime<'"+edate+" 23:59:59' "+
								"UNION ALL "+
								"select "+
									"startUser,DATEDIFF(MINUTE, startCutTime, GetDate()) as Total_Time from CutSheet where inProgress=1  and startCutTime>'"+sdate+" 23:59:59' and startCutTime<'"+edate+" 23:59:59' "+
								") as tbl "+
						  "Group by "+
									"startUser";

				ResultSet minutes = db.dbResult(minSt, sql);
				
				//0 id
				//1 name
				//2 boxes
				//3 orders
				//4 minutes shipping
					while (minutes.next()) {
	 					for(int i = 0; i < Cuts.length; i++)
						{
						if(Cuts[i][0]!= null && Cuts[i][0].equals(minutes.getString("startUser").trim())) {
							Cuts[i][3]= String.valueOf((minutes.getDouble("Total_Time")/60));
						}
						}

						}
					db.dbClose(minCon, minSt, minutes);
				} catch(SQLException e) {
				
				}
	%>
<div class="pageContainer">
<h2 style="text-align:center;">Showing results from <%=sdate %> to <%=edate %></h2>
<table class="container" id="ExportAll">
	<tr>
	<td>
		<table class="responstable">
		<tr>
		<th colspan="2">Yards Cut Per Hour</th>
		</tr>
		<tr>
			<td><b>Total Yards/Hr</b></td>
			<td class="yph"><b></b></td>
		</tr>
<%
		try {
			//Connect to the SQL Database to gather the yards cut per hour.
			java.sql.Connection yphCon =  db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

			java.sql.Statement yphSt = db.dbStatement(yphCon);

			sql="select endUser, number, quant from CutSheet where pickTime>='"+sdate+" 0:00:00' and pickTime<='"+edate+" 23:59:59' and endUser is not null";

				ResultSet yph = db.dbResult(yphSt, sql);
				double yards=1.00;
				
					while (yph.next()) {
						yards=1.00;
					 try {
					java.sql.Connection checkCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
					
					sql="select * from MailOrderManager.dbo.NEW where prod='"+yph.getString("number").trim()+"'";
					
					java.sql.Statement checkSt = db.dbStatement(checkCon);
					
					ResultSet checkCuts = db.dbResult(checkSt, sql);
					
					
					while (checkCuts.next()) {
						
						yards=checkCuts.getDouble("Q");
					}
					db.dbClose(checkCon, checkSt, checkCuts);
					}catch(SQLException e) {
						e.printStackTrace();
					} 
					Double total_yards=yards*Double.valueOf(yph.getInt("quant"));
					System.out.println("yards: "+yards);
					System.out.println("quant: "+Double.valueOf(yph.getInt("quant")));
					System.out.println("total: "+total_yards);
					
 					for(int i = 0; i < Cuts.length; i++)
					{
					if(Cuts[i][0]!= null && Cuts[i][0].equals(yph.getString("endUser").trim())) {
						Cuts[i][1]= String.valueOf(Double.valueOf(Cuts[i][1])+total_yards);
					}
					}

					}
					db.dbClose(yphCon, yphSt, yph);
				} catch(SQLException e) {
				
				}

		for(int i = 0; i < Cuts.length; i++)
		{
			System.out.println(Cuts[i][0]);
			System.out.println(Cuts[i][1]);
			System.out.println(Cuts[i][2]);
			System.out.println(Cuts[i][3]);
			if(Cuts[i][0]!= null) {
				%>
				<tr>
					<td><%=Cuts[i][0] %></td>
					<td><%=df.format(Double.valueOf(Cuts[i][1])/Double.valueOf(Cuts[i][3])) %></td>
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
		<th colspan="2">Pick to Finish Per Hour</th>
		</tr>
		<tr>
		<td><b>Total Cycles/Hr</b></td>
		<td class="totalPerHr"></td>
		</tr>
		<%
		try {
			//Connect to the SQL database to gather total Cycles per hour.
			java.sql.Connection ptfCon =  db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

			java.sql.Statement ptfSt = db.dbStatement(ptfCon);

			sql="select endUser,count(endUser) as Cuts from CutSheet where inprogress=2 and endCutTime>='"+sdate+" 0:00:00' and endCutTime<='"+edate+" 23:59:59' group by endUser";
System.out.println(sql);
				ResultSet ptf = db.dbResult(ptfSt, sql);
				
					while (ptf.next()) {
						totalPerHr=totalPerHr+ptf.getInt("Cuts");
						
	 					for(int i = 0; i < Cuts.length; i++)
						{
						if(Cuts[i][0]!= null && Cuts[i][0].equals(ptf.getString("endUser").trim())) {
							Cuts[i][2]= String.valueOf(Double.valueOf(Cuts[i][2])+Double.valueOf(ptf.getInt("Cuts")));
							%>
							<tr>
								<td><%=ptf.getString("endUser") %></td>
								<td><%=df.format(Double.valueOf(Cuts[i][2])/(Double.valueOf(Cuts[i][3]))) %></td>
							</tr>
							<%
						}
						}
					}
					db.dbClose(ptfCon, ptfSt, ptf);
				} catch(SQLException e) {
				
				}
			
		%>		
		</table>
	<tr>
	<td>
		<table class="responstable">
		<tr>
		<th colspan="2">Total Yards Cut</th>
		</tr>
		<tr>
			<td><b>Total Yards Cut</b></td>
			<td class="tyc"><b></b></td>
		</tr>
<%
//Use the data in the array to determine total yards cut for each user.
for(int i = 0; i < Cuts.length; i++)
{
	if(Cuts[i][0]!= null) {
		%>
		<tr>
			<td><%=Cuts[i][0] %></td>
			<td><%=df.format(Double.valueOf(Cuts[i][1])) %></td>
		</tr>
<%

totalYardsCut=totalYardsCut+Double.valueOf(Cuts[i][1]);
totalCycles=totalCycles+Double.valueOf(Cuts[i][2]);
totalTime=totalTime+Double.valueOf(Cuts[i][3]);
	}
}
		%>		
		</table>
	</td>
	<td>
		<table class="responstable">
		<tr>
		<th colspan="2">Total Pick to Finish</th>
		</tr>
		<tr>
		<td><b>Total Cycles</b></td>
		<td class="totalCycles"></td>
		</tr>
		<%	
		for(int i = 0; i < Cuts.length; i++)
		{
			if(Cuts[i][0]!= null) {
				%>
				<tr>
					<td><%=Cuts[i][0] %></td>
					<td><%=df.format(Double.valueOf(Cuts[i][2])) %></td>
				</tr>
		<%
			}
		}
		%>		
		</table>
	</td>
	</tr>
	<tr >
	<td>
		<table class="responstable">
		<tr>
		<th colspan="2">Production Queue (Excludes Prepacks)</th>
		</tr>
			<tr>
				<td><b>Average Time From Pick To Start</b></td>
				<td class="atpts"></td>
			</tr>
		<%
		try {
			//Use the data in the array to determine how long it took users to start a cut after an order came in.
			java.sql.Connection timeCon =  db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

			java.sql.Statement timeSt = db.dbStatement(timeCon);

			sql="select startUser,AVG(IIF(picktime<dateadd(day, datediff(day, 0, pickTime), 0) + '8:00',DATEDIFF(MINUTE, dateadd(day, datediff(day, 0, pickTime), 0) + '8:00', startCutTime), DATEDIFF(MINUTE, picktime, startCutTime))) as Prod_Queue "+
				"from CutSheet where pickTime>='"+sdate+ " 0:00:00' and pickTime<='"+edate+ " 23:59:59' and Prepack!=1 and inProgress!=0 group by startUser";
System.out.println(sql);
				ResultSet time = db.dbResult(timeSt, sql);

					while (time.next()) {
						%>
						<tr>
							<td><%=time.getString("startUser") %></td>
							<td><%=time.getInt("Prod_Queue") %> Minutes</td>
						</tr>
						<%
					pickToStart=pickToStart+Double.valueOf(time.getInt("Prod_Queue"));
					}
					db.dbClose(timeCon, timeSt, time);
				} catch(SQLException e) {
				
				}
			
		%>
		</table>
		</td><td>
		<table class="responstable">
		<tr>
		<th colspan="2">Time Spent on Cuts In Hours</th>
		</tr>
		<tr>
			<td><b>Total Time</b></td>
			<td><b><%=df.format(totalTime) %></b></td>
		</tr>
		<%	
		//Use the data in the array to determine how many hours a user spent cutting.
		for(int i = 0; i < Cuts.length; i++)
		{
			if(Cuts[i][0]!= null) {
				%>
				<tr>
					<td><%=Cuts[i][0] %></td>
					<td><%=df.format(Double.valueOf(Cuts[i][3])) %></td>
				</tr>
		<%
			}
		}
		%>	
		</table>
	</td></tr>
</table>
</div>
<script>
//Set total data information to the tables. This information was not available when the table was created and has to be added via JavaScript.
var y = document.getElementsByClassName('totalPerHr');
for (i = 0; i < y.length; i++) {
    y[i].innerHTML= <%=df.format(totalPerHr/totalTime)%>;
}

var y = document.getElementsByClassName('yph');
for (i = 0; i < y.length; i++) {
    y[i].innerHTML= <%=df.format(totalYardsCut/totalTime)%>;
}

var y = document.getElementsByClassName('tyc');
for (i = 0; i < y.length; i++) {
    y[i].innerHTML= <%=totalYardsCut%>;
}

var y = document.getElementsByClassName('totalCycles');
for (i = 0; i < y.length; i++) {
    y[i].innerHTML= <%=totalCycles%>;
}

var y = document.getElementsByClassName('atpts');
for (i = 0; i < y.length; i++) {
    y[i].innerHTML= <%=pickToStart/ArrayIndex%>+ " Minutes";
}
</script>

<input class="export" type="button" onclick="tableToExcel('ExportAll')"
	value="Export to Excel">

	
<script>
	//Function to export to excel
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