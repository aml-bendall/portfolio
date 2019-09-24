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

<link rel="stylesheet" href="CSS/QuoteTracker.css" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%
	double totalQuotes = 0;
	double openQuotes = 0;
	double closedQuotes = 0;
	double convertedQuotes = 0;
	double totalAmount = 0.00;
	double amountOpen = 0.00;
	double amountConverted = 0.00;
	double amountCancelled = 0.00;
	double conversionRate = 0.00;
	double convDif = 0.00;
	int ArrayIndex=0;
	String sdate;
	String edate;

	//set Date format for SQL queries
	SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM/dd/yyyy");
	
	DB_util db = new DB_util();
	String sql = "";

	int ErrorState = 0;

	Date endDate = new Date();
	Date startDate = new Date();

	Calendar c = Calendar.getInstance();
	c.setTime(startDate);
	c.add(Calendar.DATE, -30);
	startDate = c.getTime();

	sdate = simpleDateFormat.format(startDate);
	edate = simpleDateFormat.format(endDate);

	
	List<String> parameterNames = new ArrayList<String>(request.getParameterMap().keySet());
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
%>

<form style="veritcal-align: center; text-align: center;" method="post"
	action="Sales/QuoteTracker.jsp">
<h1 style="text-align:center;margin-bottom:1em;">Quote Tracker</h1>
<h3>The Quote Tracker will shows quotes which were created within the date range provided.</h3>
	<p>
		From: <input type="date" name="startDate" required> To: <input
			type="date" name="endDate" required>
	</p>

	<input type="submit" value="Submit" name="submit">

</form>
	<%if(sdate.trim().equals(edate.trim())){ %>
	<h3 style="text-align: center">Total Quote data for
		<%=sdate%></h3>
<%}else{%>
	<h3 style="text-align: center">Total Quote data from
		<%=sdate%> to <%=edate%></h3>
<%} %>	
<table id="quoteTotals" class="responstable">
	<tr>
		<th>Total Quotes</th>
		<th>Open Quotes</th>
		<th>Converted Quotes</th>
		<th>Cancelled Quotes</th>
		<th>Total Amount</th>
		<th>Amount Open</th>
		<th><p>Amount Converted</p><p>(+ or - Actual)</p></th>
		<th>Amount Cancelled</th>
		<th>Conversion Rate</th>
	</tr>

	<%
	//Get the total number of users that have quotes in the system in order to indext the array.
	java.sql.Connection CountCon =  db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

	if (CountCon != null) {
	java.sql.Statement CountSt = db.dbStatement(CountCon);


	sql = "SELECT DISTINCT count(salesRep) as User_Count FROM QuoteTracker";

	ResultSet UserCount = db.dbResult(CountSt, sql);
	 
	//Set Total Number of Users to the ArrayIndex
	while (UserCount.next()) {  
		ArrayIndex=Integer.valueOf(UserCount.getString("User_Count"));
	}
	db.dbClose(CountCon, CountSt, UserCount);
	}
	
	String[][] repArray = new String[ArrayIndex][10];
	
	    //Display information from SQL table based on the given date range.
		java.sql.Connection quoteCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

		if (quoteCon != null) {
			java.sql.Statement quoteSt = db.dbStatement(quoteCon);

			sql = "select * from QuoteTracker where quoteDate>='" + sdate + "' and quoteDate<='" + edate + "' and salesRep!='web'";

			ResultSet quotes = db.dbResult(quoteSt, sql);

			while (quotes.next()) {
				totalQuotes = totalQuotes + 1;
				totalAmount = totalAmount + quotes.getDouble("quoteAmount");

				int MatchFound=0;
                int EmptyIndex=99;
                
				for(int i = 0; i < repArray.length; i++) {
					if(repArray[i][0]==null || repArray[i][0]=="") {
						repArray[i][0] = quotes.getString("salesRep");
						repArray[i][1] ="1";
						repArray[i][5] = String.valueOf(quotes.getDouble("quoteAmount"));
						
						if (quotes.getString("orderStatus").equals("Open")) {
							repArray[i][2] ="1";
							repArray[i][3] ="0";
							repArray[i][4] ="0";
							repArray[i][6] = String.valueOf(quotes.getDouble("quoteAmount"));
							repArray[i][7] = "0.00";
							repArray[i][8] = "0.00";
							repArray[i][9] ="0.00";
						}
						if (quotes.getString("orderStatus").equals("Converted")) {
							repArray[i][3] ="1";
							repArray[i][2] ="0";
							repArray[i][4] ="0";
							repArray[i][7] = String.valueOf(quotes.getDouble("convertAmount"));
							repArray[i][9] = String.valueOf(quotes.getDouble("convertAmount")-quotes.getDouble("quoteAmount"));
							repArray[i][6] = "0.00";
							repArray[i][8] = "0.00";
						}
						if (quotes.getString("orderStatus").equals("Closed")) {
							repArray[i][4] ="1";
							repArray[i][2] ="0";
							repArray[i][3] ="0";
							repArray[i][8] = String.valueOf(quotes.getDouble("quoteAmount"));
							repArray[i][6] = "0.00";
							repArray[i][7] = "0.00";
							repArray[i][9] ="0.00";
						}
						break;
					}
					if(repArray[i][0]!= null && repArray[i][0].trim().equals(quotes.getString("salesRep").trim())){
						MatchFound=1;
							repArray[i][1] = String.valueOf(Integer.valueOf(repArray[i][1])+1);	
							repArray[i][5] = String.valueOf(Double.valueOf(repArray[i][5])+quotes.getDouble("quoteAmount"));
							
							if (quotes.getString("orderStatus").equals("Open")) {
								repArray[i][2] = String.valueOf(Integer.valueOf(repArray[i][2])+1);
								repArray[i][6] = String.valueOf(Double.valueOf(repArray[i][6])+quotes.getDouble("quoteAmount"));
							}
							if (quotes.getString("orderStatus").equals("Converted")) {
								repArray[i][3] = String.valueOf(Integer.valueOf(repArray[i][3])+1);
								repArray[i][7] = String.valueOf(Double.valueOf(repArray[i][7])+quotes.getDouble("convertAmount"));
								repArray[i][9] = String.valueOf(Double.valueOf(repArray[i][9])+(quotes.getDouble("convertAmount")-quotes.getDouble("quoteAmount")));
							}
							if (quotes.getString("orderStatus").equals("Closed")) {
								repArray[i][4] = String.valueOf(Integer.valueOf(repArray[i][4])+1);
								repArray[i][8] = String.valueOf(Double.valueOf(repArray[i][8])+quotes.getDouble("quoteAmount"));
							}
							break;
					}
				}
				
				
				if (quotes.getString("orderStatus").equals("Open")) {
					openQuotes = openQuotes + 1;
					amountOpen = amountOpen + quotes.getDouble("quoteAmount");
				}
				if (quotes.getString("orderStatus").equals("Converted")) {
					convertedQuotes = convertedQuotes + 1;
					amountConverted = amountConverted + quotes.getDouble("convertAmount");
					convDif=convDif+(quotes.getDouble("convertAmount")-quotes.getDouble("quoteAmount"));
				}
				if (quotes.getString("orderStatus").equals("Closed")) {
					closedQuotes = closedQuotes + 1;
					amountCancelled = amountCancelled + quotes.getDouble("quoteAmount");
				}
			}
			db.dbClose(quoteCon, quoteSt, quotes);
		}

		NumberFormat defaultFormat = NumberFormat.getCurrencyInstance();

		Double convRate = (convertedQuotes / totalQuotes) * 100;
		DecimalFormat df = new DecimalFormat("#.00");
		
		//Setup table to display information
	%>
	<tr>
		<td><%=totalQuotes%></td>
		<td><%=openQuotes%></td>
		<td><%=convertedQuotes%></td>
		<td><%=closedQuotes%></td>
		<td><%=defaultFormat.format(totalAmount)%></td>
		<td><%=defaultFormat.format(amountOpen)%></td>
		<td><%=defaultFormat.format(amountConverted)%>
		<%
		if(convDif>0){
			%>
			<p style="color:green;"><%=defaultFormat.format(convDif) %></p>
		
		<% }
		else if(convDif<0){
			%>
			<p style="color:red;"><%=defaultFormat.format(convDif) %></p>
		
		<%
		}
		%>
		</td>
		<td><%=defaultFormat.format(amountCancelled)%></td>
		<td><%=df.format(convRate)%>%</td>
	</tr>

</table>

<input style="margin-top: 1em;" type="button" onclick="tableToExcel('quoteTotals')"
	value="Export to Excel">
	
		<%if(sdate.trim().equals(edate.trim())){ %>
	<h3 style="text-align: center">Quote data for
		<%=sdate%> by Sales Rep</h3>
<%}else{%>
	<h3 style="text-align: center">Quote data for
		<%=sdate%> to <%=edate%> by Sales Rep</h3>
<%} %>

<!-- Dispaly information	 -->
<table id="quoteByRep" class="responstable">
	<tr>
		<th>Sales Rep</th>
		<th>Total Quotes</th>
		<th>Open Quotes</th>
		<th>Converted Quotes</th>
		<th>Cancelled Quotes</th>
		<th>Total Amount</th>
		<th>Amount Open</th>
		<th><p>Amount Converted</p><p>(+ or - Actual)</p></th>
		<th>Amount Cancelled</th>
		<th>Conversion Rate</th>
	</tr>
	<%
	for(int i = 0; i < repArray.length; i++) {
	if(repArray[i][0] != null && repArray[i][0] != "") {
	%>
	<tr>
		<td><%=repArray[i][0] %></td>
		<td><%=repArray[i][1] %></td>
		<td><%=repArray[i][2] %></td>
		<td><%=repArray[i][3] %></td>
		<td><%=repArray[i][4] %></td>
		<td><%=defaultFormat.format(Double.valueOf(repArray[i][5]))%></td>
		<td><%=defaultFormat.format(Double.valueOf(repArray[i][6]))%></td>
		<td><%=defaultFormat.format(Double.valueOf(repArray[i][7]))%>
				<%
		if(Double.valueOf(repArray[i][9])>0){
			%>
			<p style="color:green;"><%=defaultFormat.format(Double.valueOf(repArray[i][9]))%></p>
		
		<% }
		else if(Double.valueOf(repArray[i][9])<0){
			%>
			<p style="color:red;"><%=defaultFormat.format(Double.valueOf(repArray[i][9]))%></p>
		
		<%
		}
		%>
		</td>
		<td><%=defaultFormat.format(Double.valueOf(repArray[i][8]))%></td>
		<td><%=df.format(Double.valueOf(repArray[i][3])/Double.valueOf(repArray[i][1])*100)%>%</td>
	</tr>
<%
	}
	}
%>
</table>

<script>
	//function to export table to excel
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
<input style="margin-top: 1em;" type="button" onclick="tableToExcel('quoteByRep')"
	value="Export to Excel">

<jsp:include page="../Includes/footer.jsp" />



