
<%
	/**
	* Purpose:Provides a dashboard the shows sells by source. (Email, Organic, Paid, Social, ect.)
	*		  The java class gaSourceMedium.class runs daily and collects the source from the 
	*		  Google Analytics API and applies the source to the corresponding transaction in the SQL database.
	* Created On: 3/02/2018
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

<link rel="stylesheet" href="CSS/SourceCodeDash.css" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%
	//Format date for SQL queries.
	String sdate;
	String edate;
	String sdateLastYear;
	String edateLastYear;

	SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM/dd/yyyy");
	
	DB_util db = new DB_util();
	String sql = "";

	int ErrorState = 0;

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

	System.out.println("Start date: " + sdate);
	System.out.println("End date: " + edate);
	
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
	action="Marketing/SourceCodeDash.jsp">
<h1 style="text-align:center;margin-bottom:1em;">Source Code Dashboard</h1>
	<!-- Form to enter date range -->
	<p>
		From: <input type="date" name="startDate" required> To: <input
			type="date" name="endDate" required>
	</p>

	<input type="submit" value="Submit" name="submit">

</form>

	<%if(sdate.trim().equals(edate.trim())){ %>
	<h3 style="text-align: center">Source Code data for
		<%=sdate%></h3>
<%}else{%>
	<h3 style="text-align: center">Source Code data from
		<%=sdate%> to <%=edate%></h3>
<%} %>	

<!-- Setup table and perform SQL queries to display the data -->
<table id="campaignTotals" class="responstable">
	<tr>
		<th>Campaign</th>
		<th>Total Orders</th>
		<th>Merchandise Total</th>
	</tr>
	

	<%
	NumberFormat defaultFormat = NumberFormat.getCurrencyInstance();
    try {
	java.sql.Connection totalCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement totalSt = db.dbStatement(totalCon);

		sql = "select count(i.orderNo) as Total_Orders, sum(i.merch) as Merch_Total from INVOICE i "+
				"Inner Join CMS c on c.orderno=i.orderno "+
				"WHERE i.INV_DATE >= '"+ sdate + "'  "+
				"AND i.INV_DATE <= '" + edate + "' "+
				"AND c.ordertype = 'web'";

		ResultSet totals = db.dbResult(totalSt, sql);

		while (totals.next()) {
			String tableID= "Table_"+totals.getRow();
		%>
		<tr>
			<td style="font-weight:bold"> Totals </td>
			<td style="font-weight:bold"><%=totals.getInt("Total_Orders")%></td>
			<td style="font-weight:bold"><%=defaultFormat.format(totals.getDouble("Merch_Total"))%></td>
		</tr>
		<%
		} 
		db.dbClose(totalCon, totalSt, totals);
    	}catch(SQLException e) {
			e.printStackTrace();
		}
			
		%>
		
		<%

	    try {
		java.sql.Connection campaignCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

			java.sql.Statement campaignSt = db.dbStatement(campaignCon);

			sql = "select s.campaign, count(i.orderNo) as Total_Orders, sum(i.merch) as Merch_Total from INVOICE "+
					"i left Join CMS c on c.orderno=i.orderno "+
					"left join ADCOSTS s "+
					"on c.cl_key=s.adkey "+
					"WHERE i.INV_DATE >= '" + sdate + "' "+
					"AND i.INV_DATE <= '" + edate + "' "+
					"AND c.ordertype = 'web' "+
					"group by s.CAMPAIGN order by Merch_Total desc";

			ResultSet campaigns = db.dbResult(campaignSt, sql);

			while (campaigns.next()) {
				String tableID= "Table_"+campaigns.getRow();
				String showCampaign="";
				if(campaigns.getString("campaign")==null) {
					showCampaign="NO CAMPAIGN";
				} else {
					showCampaign=campaigns.getString("campaign");
				}
			%>
			<tr>
				<td onClick="toggle('<%=tableID%>');" class="clickable"><%=showCampaign%></td>
				<td><%=campaigns.getInt("Total_Orders")%></td>
				<td><%=defaultFormat.format(campaigns.getDouble("Merch_Total"))%></td>
			</tr>
	
	<%		
				    try {
		java.sql.Connection sourceCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

			java.sql.Statement sourceSt = db.dbStatement(sourceCon);

			sql = "select s.adkey,count(i.orderno) as Total_Orders, sum(i.merch) as Merch_Total "+
					"from cms c "+
					"inner join ADCOSTS s "+
					"on c.cl_key=s.adkey "+
					"inner join invoice i "+
					"on i.orderno=c.orderno "+
					"where i.INV_DATE<='" + edate + "' " +
					"and i.INV_DATE>='" + sdate + "' " +
					"and s.campaign='" + campaigns.getString("campaign") + "' "+
					"and c.ORDERTYPE='WEB' "+
					"group by s.adkey "+
					"order by Total_Orders desc";
System.out.println(sql);
			ResultSet sources = db.dbResult(sourceSt, sql);
			while (sources.next()) {
				
				%>
				
			<tr class="Table_<%=campaigns.getRow()%>" style="display:none;">
				<td  style="font-size:.75em;"><%=sources.getString("adkey")%></td>
				<td  style="font-size:.75em;"><%=sources.getInt("Total_Orders")%></td>
				<td  style="font-size:.75em;"><%=defaultFormat.format(sources.getDouble("Merch_Total"))%></td>
			</tr>

			<%
			}
			db.dbClose(sourceCon, sourceSt, sources);
		}catch(SQLException e){
			e.printStackTrace();
		}
			}
			db.dbClose(campaignCon, campaignSt, campaigns);
		
	    }catch(SQLException e){
			e.printStackTrace();
		}
	    %>


</table>


<input style="margin-top: 1em;" type="button" onclick="tableToExcel('campaignTotals')"
	value="Export to Excel">
	
		<%if(sdateLastYear.trim().equals(edateLastYear.trim())){ %>
	<h3 style="text-align: center">Source Code data for
		<%=sdateLastYear%></h3>
<%}else{%>
	<h3 style="text-align: center">Source Code data from
		<%=sdateLastYear%> to <%=edateLastYear%></h3>
<%} %>	

	<table id="campaignTotalsLY" class="responstable">
	<tr>
		<th>Campaign</th>
		<th>Total Orders</th>
		<th>Merchandise Total</th>
	</tr>
	
	
		<%

    try {
	java.sql.Connection totalCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement totalSt = db.dbStatement(totalCon);

		sql = "select count(i.orderNo) as Total_Orders, sum(i.merch) as Merch_Total from INVOICE i "+
				"Inner Join CMS c on c.orderno=i.orderno "+
				"WHERE i.INV_DATE >= '"+ sdateLastYear + "'  "+
				"AND i.INV_DATE <= '" + edateLastYear + "' "+
				"AND c.ordertype = 'web'";

		ResultSet totals = db.dbResult(totalSt, sql);

		while (totals.next()) {
			String tableID= "Table_"+totals.getRow();
		%>
		<tr>
			<td style="font-weight:bold"> Totals </td>
			<td style="font-weight:bold"><%=totals.getInt("Total_Orders")%></td>
			<td style="font-weight:bold"><%=defaultFormat.format(totals.getDouble("Merch_Total"))%></td>
		</tr>
		<%
		} 
		db.dbClose(totalCon, totalSt, totals);
    	}catch(SQLException e) {
			e.printStackTrace();
		}
			
		%>

	<%
	    try {
		java.sql.Connection campaignCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

			java.sql.Statement campaignSt = db.dbStatement(campaignCon);
			
			sql = "select s.campaign, count(i.orderNo) as Total_Orders, sum(i.merch) as Merch_Total from INVOICE "+
					"i left Join CMS c on c.orderno=i.orderno "+
					"left join ADCOSTS s "+
					"on c.cl_key=s.adkey "+
					"WHERE i.INV_DATE >= '" + sdateLastYear + "' "+
					"AND i.INV_DATE <= '" + edateLastYear + "' "+
					"AND c.ordertype = 'web' "+
					"group by s.CAMPAIGN order by Merch_Total desc";

			ResultSet campaigns = db.dbResult(campaignSt, sql);

			while (campaigns.next()) {
				String tableID= "Table_LY"+campaigns.getRow();
				String showCampaign="";
				if(campaigns.getString("campaign")==null) {
					showCampaign="NO CAMPAIGN";
				} else {
					showCampaign=campaigns.getString("campaign");
				}
			%>
			<tr>
				<td onClick="toggle('<%=tableID%>');" class="clickable"><%=showCampaign%></td>
				<td><%=campaigns.getInt("Total_Orders")%></td>
				<td><%=defaultFormat.format(campaigns.getDouble("Merch_Total"))%></td>
			</tr>
	
	<%		
				    try {
		java.sql.Connection sourceCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

			java.sql.Statement sourceSt = db.dbStatement(sourceCon);

			sql = "select s.adkey,count(i.orderno) as Total_Orders, sum(i.merch) as Merch_Total "+
					"from cms c "+
					"inner join ADCOSTS s "+
					"on c.cl_key=s.adkey "+
					"inner join invoice i "+
					"on i.orderno=c.orderno "+
					"where i.INV_DATE<='" + edateLastYear + "' " +
					"and i.INV_DATE>='" + sdateLastYear + "' " +
					"and s.campaign='" + campaigns.getString("campaign") + "' "+
					"and c.ORDERTYPE='WEB' " +
					"group by s.adkey "+
					"order by Total_Orders desc";

			ResultSet sources = db.dbResult(sourceSt, sql);
			while (sources.next()) {
				
				%>
				
			<tr class="Table_LY<%=campaigns.getRow()%>" style="display:none;">
				<td  style="font-size:.75em;"><%=sources.getString("adkey")%></td>
				<td  style="font-size:.75em;"><%=sources.getInt("Total_Orders")%></td>
				<td  style="font-size:.75em;"><%=defaultFormat.format(sources.getDouble("Merch_Total"))%></td>
			</tr>

			<%
			}
			db.dbClose(sourceCon, sourceSt, sources);
		}catch(SQLException e){
			e.printStackTrace();
		}
			}
			db.dbClose(campaignCon, campaignSt, campaigns);
		
	    }catch(SQLException e){
			e.printStackTrace();
		}
	    %>


</table>

<input style="margin-top: 1em;" type="button" onclick="tableToExcel('campaignTotalsLY')"
	value="Export to Excel">
	
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



