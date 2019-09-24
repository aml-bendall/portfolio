<% /**
 * Purpose: A Java routine runs every 15 minutes capting all quotes in the ERP system and snapshotting them  to the database and updating quote information.
 * 			This program displays that information to the user.
 * Created On: 2/11/2018
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

<link rel="stylesheet" href="CSS/QuoteDetails.css" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%
DB_util db = new DB_util();
String sql = "";

NumberFormat defaultFormat = NumberFormat.getCurrencyInstance();

double quoteTotal=0.00;
int quoteCount=0;
String stringTotal="";
String orderStatus="";

//Set date for SQL queries
Date today = new Date();

Calendar c = Calendar.getInstance();

c.setTime(today);
c.set(c.HOUR,8);
c.set(c.MINUTE,0);
c.set(c.SECOND,0);
today = c.getTime();



%>
<form style="veritcal-align: center; text-align: center;" method="post"
	action="Sales/QuoteDetails.jsp">
<h1 style="text-align:center;margin-bottom:1em;">Quote Details</h1>
	<p>
		Choose a Sales Rep to view their open Quotes.</p>
	<p> 
<select name="salesRep">
<%
try {
	//Display users with open quotes for selction.
	java.sql.Connection repCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

		java.sql.Statement repSt = db.dbStatement(repCon);

		sql = "SELECT DISTINCT salesRep FROM QuoteTracker where orderStatus='Open'";

		ResultSet reps = db.dbResult(repSt, sql);

		while (reps.next()) {
			%>
			<option value="<%=reps.getString("salesRep")%>"><%=reps.getString("salesRep") %></option>
		<%
		} 
		db.dbClose(repCon, repSt, reps);
  	}catch(SQLException e) {
			e.printStackTrace();
		}
%>
</select>

	<input type="submit" value="Submit" name="submit">

</form>
<% 
if(request.getParameterMap().containsKey("salesRep")) {
	//If the URL parameter is set, display quotes for that sales rep.
	%>
	<h2 style="text-align:center;font-weight:bold;">
		You are viewing quotes for <%=request.getParameter("salesRep")%>
	</h2>
	<p style="text-align:center;">
		You may click a quote to view the most recent call contact log. Other contact logs may be available in MOM.
	<p>
	<h3 class="total" style="text-align:center;">
		
	</h3>
	
<table id="quoteDetails" class="responstable">
	<tr>
		<th>Order Number</th>
		<th>Quote Origination Date</th>
		<th>Quote Amount</th>
		<th>Last Contact Date</th>
		<th>Scheduled Follow up Date</th>
		<th>Current Order Status</th>
	</tr>
	

	<%
    try {
	java.sql.Connection quoteCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

		java.sql.Statement quoteSt = db.dbStatement(quoteCon);

		sql = "SELECT * FROM QuoteTracker WHERE SalesRep='"+ request.getParameter("salesRep") +"' and orderStatus='Open'";

		ResultSet quotes = db.dbResult(quoteSt, sql);

		while (quotes.next()) {
			
			String lastContactType="";
			Date lastContactDate=null;
			Date nextContactDate=null;
			String Summary="";
			String logMsg="";
			String tableID= "Table_"+quotes.getRow();
			int custNumber=0;
			int shipNumber=0;

			quoteTotal=quoteTotal+quotes.getDouble("quoteAmount");
			quoteCount=quoteCount+1;
			%>
		<tr  onClick="toggle('<%=tableID%>');" class="clickable">
			<td><%=quotes.getString("orderNo") %></td>
			<td><%=quotes.getDate("quoteDate") %></td>
			<td><%=defaultFormat.format(quotes.getDouble("quoteAmount"))%></td>
			
			<%
			try {
				java.sql.Connection custCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

					java.sql.Statement custSt = db.dbStatement(custCon);

					 sql=  "select custnum,shipnum,ORDER_ST2 from cms where orderno='" + quotes.getString("orderNo") + "'";

					ResultSet custNum = db.dbResult(custSt, sql);

					while (custNum.next()) {
						custNumber=custNum.getInt("custnum");
						shipNumber=custNum.getInt("shipnum");
						orderStatus=custNum.getString("ORDER_ST2");
					}
			
		db.dbClose(custCon, custSt, custNum);
    	}catch(SQLException e) {
			e.printStackTrace();
		}
			switch (orderStatus) {
			case "BI":
				orderStatus = "Ready to Invoice";
				break;
			case "BO":
				orderStatus = "Back Order";
				break;
			case "CA":
				orderStatus = "Awaiting Credit Card Approval";
				break;
			case "CD":
				orderStatus = "Credit Card Problems";
				break;
			case "CK":
				orderStatus = "Check Clearing";
				break;
			case "CS":
				orderStatus = "Completed Counter Sale";
				break;
			case "EP":
				orderStatus = "Temporary Hold";
				break;
			case "GC":
				orderStatus = "Gift cert needs printing";
				break;
			case "HD":
				orderStatus = "On Hold";
				break;
			case "HS":
				orderStatus = "Shipment Hold";
				break;
			case "II":
				orderStatus = "Credit Card Problems";
				break;
			case "IN":
				orderStatus = "Ready to Pack";
				break;
			case "NW":
				orderStatus = "Requires Weighing";
				break;
			case "PA":
				orderStatus = "Needs Labels";
				break;
			case "PE":
				orderStatus = "Permanent Hold";
				break;
			case "PI":
				orderStatus = "Ready to Pick";
				break;
			case "PS":
				orderStatus = "Awaiting Shipment";
				break;
			case "QO":
				orderStatus = "Quotation";
				break;
			case "SC":
				orderStatus = "Needs Scanning";
				break;
			case "SH":
				orderStatus = "Shipped Orders";
				break;
			case "UO":
				orderStatus = "Uncompleted Orders on Hold";
				break;
			}

			try {
				java.sql.Connection lastCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

					java.sql.Statement lastSt = db.dbStatement(lastCon);

					 sql=  "select telemark_id as ID, CALL_DATE as Date,custnum as Customer,  CASE "+
								"WHEN CALL_MADE=1 THEN 'Done' "+
								"WHEN CALL_DATE>GETDATE() THEN 'Scheduled' "+
								"ELSE 'Call Now' "+
								"END as status, 'Phone' as Contact_Type from telemark where (custnum='"+ custNumber + "'  or custnum='"+ shipNumber + "') and CALL_MADE=1 "+
					  			"union "+
					  			"select contact_id as ID, dated as Date,custnum as Customer, case "+ 
								"when EMAILSENT=1 then 'Sent' "+
								"else 'Send' "+
								"end as status2,'Email' as Contact_Type from contact where (custnum='"+ custNumber + "'  or custnum='"+ shipNumber + "')  and emailsent=1 order by date desc";

					ResultSet lastContact = db.dbResult(lastSt, sql);

					while (lastContact.next()) {
						if(lastContact.getRow()==1){
							lastContactDate=lastContact.getDate("Date");
							lastContactType=lastContact.getString("Contact_Type");
						}
					}
			if(lastContactDate==null){
				lastContactType="None";
			}
			
		db.dbClose(lastCon, lastSt, lastContact);
    	}catch(SQLException e) {
			e.printStackTrace();
		}
			
			if(lastContactType!=null && lastContactType!="None"){
			%>
			<td><%=lastContactType %> - <%=lastContactDate %></td>
			
			<%
		}
		else {
			%>
			<td>None</td>
			<%
			}
			int callMade=0;%>
			
			
			<%
			try {
				java.sql.Connection nextCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

					java.sql.Statement nextSt = db.dbStatement(nextCon);

					 sql=  "select telemark_id as ID, CALL_DATE as Date,custnum as Customer,call_made,  CASE "+
								"WHEN CALL_MADE=1 THEN 'Done' "+
								"WHEN CALL_DATE>GETDATE() THEN 'Scheduled' "+
								"ELSE 'Call Now' "+
								"END as status, 'Phone' as Contact_Type from telemark where (custnum='"+ custNumber + "'  or custnum='"+ shipNumber + "')  order by Date desc";

					ResultSet nextContact = db.dbResult(nextSt, sql);

					while (nextContact.next()) {
						if(nextContact.getRow()==1){
							nextContactDate=nextContact.getDate("Date");
							callMade=nextContact.getInt("call_made");
						}
					}
			
		db.dbClose(nextCon, nextSt, nextContact);
    	}catch(SQLException e) {
			e.printStackTrace();
		}	
if(nextContactDate!=null) {
			Calendar c2 = Calendar.getInstance();

			c2.setTime(nextContactDate);
			c2.set(c2.HOUR,17);
			c2.set(c2.MINUTE,0);
			c2.set(c2.SECOND,0);
			nextContactDate = c2.getTime();

			System.out.println(nextContactDate);
}
			System.out.println(today);	
			%>
			<%
			if(nextContactDate!=null && nextContactDate.after(today)){
			%>
			<td>Call scheduled for <%=nextContactDate.toString().replace("17:00:00 EDT 2018","")%></td>		
			<%
		}
			else if(nextContactDate!=null && nextContactDate.equals(today) && callMade==0){
				%>
				<td>Call Today</td>
				
				<%
			}
			else if(nextContactDate!=null && nextContactDate.before(today) && callMade==0){
				%>
				<td>Call Past Due</td>
				
				<%
			}
		else {
			%>
			<td>Call Not Scheduled</td>
			<%
			}%>

		<td><%=orderStatus%></td>
		</tr>
		<%
		try {
				java.sql.Connection logCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

					java.sql.Statement logSt = db.dbStatement(logCon);

					 sql=  "select TOP 1 telemark_id, Summary from telemark where (custnum='"+ custNumber + "'  or custnum='"+ shipNumber + "')  and CALL_MADE='1' order by CALL_DATE desc";

					ResultSet logs = db.dbResult(logSt, sql);

					while (logs.next()) {
						if(logs.getRow()==1){
							logMsg=logs.getString("Summary");
						}
					}
			
		db.dbClose(logCon, logSt, logs);
    	}catch(SQLException e) {
			e.printStackTrace();
		}
		%>
		<tr class="<%=tableID%>" style="display:none;">
			<%
			if(logMsg!="") {
			%>
			<td colspan="6"><%=logMsg%></td>
			<%
			}
			else {
			%>
			<td colspan="6">N/A</td>
			<%
			}
			%>
		</tr>
		<%
    }
		db.dbClose(quoteCon, quoteSt, quotes);
    	}catch(SQLException e) {
			e.printStackTrace();
		}
			
		%>
	</table>	
		<%
}
stringTotal=defaultFormat.format(quoteTotal);
%>

<script>
var y = document.getElementsByClassName('total');
for (i = 0; i < y.length; i++) {
	y[i].innerHTML = "<p>Quotes: <%=quoteCount%></p> <p>Total: <%=stringTotal%></p>";
}

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
					"_Quote.xls");
		} else
			//other browser not tested on IE 11
			sa = window.open('data:application/vnd.ms-excel,'
					+ encodeURIComponent(tab_text));

		return (sa);
	}
</script>

				<script>
			function toggle(a) {
			var rows = document.getElementsByClassName(a);
				for(var i = 0; i < rows.length; i++)
				{
					if( rows[i].style.display=='none' ){
					rows[i].style.display = 'table-row';
					}else{
						rows[i].style.display = 'none';
					 }
				}
}
			
			</script>

<jsp:include page="../Includes/footer.jsp" />



