<%
	/**
	* Purpose:Dashboard which track catalog requests and the conversion rate of the requests.
	* Created On: 08/19/2017
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

<jsp:include page="../Includes/header.jsp" />

<link rel="stylesheet" href="CSS/CatReqDash.css" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%
	String sdate;
	String edate;
	String sdateLastYear;
	String edateLastYear;

	SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM/dd/yyyy");
	
	DB_util db = new DB_util();
	String sql = "";

	int ErrorState = 0;
	int totalConv = 0;
	int totalOrders = 0;
	double totalGross=0.0;

	//Set date range for SQL statements
	Date endDate = new Date();
	Date startDate = new Date();

	Calendar c = Calendar.getInstance();
	c.setTime(startDate);
	c.set(Calendar.DAY_OF_MONTH, 1);
	startDate = c.getTime();

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
	
	c.setTime(startDate);
	c.add(Calendar.DATE, -365);
	startDate = c.getTime();
	
	sdateLastYear = simpleDateFormat.format(startDate);
	
	c.setTime(endDate);
	c.add(Calendar.DATE, -365);
	endDate = c.getTime();
	
	
	edateLastYear = simpleDateFormat.format(endDate);
%>

<!--  Form to allow the user to set the date range -->
<form style="veritcal-align: center; text-align: center;" method="post"
	action="Marketing/CatReqDash.jsp">
<h1 style="text-align:center;margin-bottom:1em;">Catalog Request Dashboard</h1>
	<p>
		From: <input type="date" name="startDate" required> To: <input
			type="date" name="endDate" required>
	</p>
	<input type="submit" value="Submit" name="submit">

	<p>
		An order is considered converted if an order is placed within 30 days of the catalog order. This logic is complex and will increase the load time of the page based on number of days searched. Searching an entire year may take a couple minutes to load.
	</p>
<p>The total merchandise reflects the sum of ALL orders received within 30 days of the catalog order.</p>

</form>

<!-- Create table and perform catalog quest lookup -->
<h2>Catalog Requests from <%=sdate%> to <%=edate%></h2>

<table class="responstable">
	<tr>
		<th>Total Requests</th>
		<th>Total Conversions</th>
		<th>Conversion Rate</th>
		<th>Total Merchandise</th>
	</tr>
	

	<%
	totalOrders=0;
	totalConv=0;
	totalGross=0.0;
	
	NumberFormat defaultFormat = NumberFormat.getCurrencyInstance();
	
    try {
	java.sql.Connection totalCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement totalSt = db.dbStatement(totalCon);

		sql = "select c.custnum  as Total_Requests, c.ODR_DATE "+
				"from cms c "+
				"inner join LOSTORD l "+
				"on l.orderno=c.orderno "+
				"inner join cust cn on cn.custnum=c.CUSTNUM "+
				"where (l.item like '%cat') "+
				"and c.ODR_DATE>='" +sdate+ "' "+
				"and c.ODR_DATE<='" +edate+ "' ";

		ResultSet totals = db.dbResult(totalSt, sql);
		
		while (totals.next()) {
			
			totalOrders=totalOrders+1;
			try {
				java.sql.Connection convCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

					java.sql.Statement convSt = db.dbStatement(convCon);

					Date convStart=totals.getDate("ODR_DATE");
					
					c.setTime(totals.getDate("ODR_DATE"));
					c.add(Calendar.DATE, 30);		
					Date convEnd= c.getTime();
					
					String cStart=simpleDateFormat.format(convStart);
					String cEnd=simpleDateFormat.format(convEnd);
					
					System.out.println("This is the conv sdate: " +cStart );
					System.out.println("This is the conv edate: " +cEnd );
					
					
					sql= "select c.custnum as Total_Conversions,sum(o.ORD_TOTAL)-sum(o.tb_ship)-sum(o.tb_tax)-sum(o.shipping) as Total_Gross "+
							"from cms o "+
							"inner join cust c "+
							"on o.custnum=c.custnum "+
							"and o.odr_date>'" + cStart + "' "+
							"and o.odr_date<='" + cEnd + "' "+
							"and c.custnum='" + totals.getString("Total_Requests") + "' " +
							"group by c.custnum";

					ResultSet conversions = db.dbResult(convSt, sql);
					while (conversions.next()) {
						totalConv=totalConv+1;
						totalGross=totalGross+conversions.getDouble("Total_Gross");
			} 
			db.dbClose(convCon, convSt, conversions);
	    	}catch(SQLException e) {
				e.printStackTrace();
			}
		} 
		db.dbClose(totalCon, totalSt, totals);
    	}catch(SQLException e) {
			e.printStackTrace();
		}
			
		%>
			<tr>
			<td style="font-weight:bold"><%=totalOrders%></td>
			<td style="font-weight:bold"><%=totalConv%></td>
			<td style="font-weight:bold"><%=new DecimalFormat("##.##").format((Double.valueOf(totalConv)/Double.valueOf(totalOrders))*100)%>%</td>
			<td style="font-weight:bold"><%=defaultFormat.format(totalGross)%></td>
</table>

<!-- Setup table and display catalog request information for the previous year -->
<h2>Catalog Requests from <%=sdateLastYear%> to <%=edateLastYear%></h2>

<table class="responstable">
	<tr>
		<th>Total Requests</th>
		<th>Total Conversions</th>
		<th>Conversion Rate</th>
		<th>Total Merchandise</th>
	</tr>
	

	<%
	totalOrders=0;
	totalConv=0;
	totalGross=0.0;
	
    try {
	java.sql.Connection totalCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		java.sql.Statement totalSt = db.dbStatement(totalCon);

		sql = "select c.custnum  as Total_Requests, c.ODR_DATE "+
				"from cms c "+
				"inner join LOSTORD l "+
				"on l.orderno=c.orderno "+
				"inner join cust cn on cn.custnum=c.CUSTNUM "+
				"where (l.item like '%cat') "+
				"and c.ODR_DATE>='" +sdateLastYear+ "' "+
				"and c.ODR_DATE<='" +edateLastYear+ "' ";

		ResultSet totals = db.dbResult(totalSt, sql);

		while (totals.next()) {
			totalOrders=totalOrders+1;
			try {
				java.sql.Connection convCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

					java.sql.Statement convSt = db.dbStatement(convCon);
							
							Date convStart=totals.getDate("ODR_DATE");
							
							c.setTime(totals.getDate("ODR_DATE"));
							c.add(Calendar.DATE, 30);		
							Date convEnd= c.getTime();
							
							String cStart=simpleDateFormat.format(convStart);
							String cEnd=simpleDateFormat.format(convEnd);
							
							System.out.println("This is the conv sdate: " +cStart );
							System.out.println("This is the conv edate: " +cEnd );
							
							sql= "select c.custnum as Total_Conversions,sum(o.ORD_TOTAL)-sum(o.tb_ship)-sum(o.tb_tax)-sum(o.shipping) as Total_Gross "+
									"from cms o "+
									"inner join cust c "+
									"on o.custnum=c.custnum "+
									"and o.odr_date>'" + cStart + "' "+
									"and o.odr_date<='" + cEnd + "' "+
									"and c.custnum='" + totals.getString("Total_Requests") + "' " +
									"group by c.custnum";

					ResultSet conversions = db.dbResult(convSt, sql);
					while (conversions.next()) {
						totalConv=totalConv+1;
						totalGross=totalGross+conversions.getDouble("Total_Gross");
			} 
			db.dbClose(convCon, convSt, conversions);
	    	}catch(SQLException e) {
				e.printStackTrace();
			}

		} 
		db.dbClose(totalCon, totalSt, totals);
    	}catch(SQLException e) {
			e.printStackTrace();
		}
			
		%>
			<tr>
			<td style="font-weight:bold"><%=totalOrders%></td>
			<td style="font-weight:bold"><%=totalConv%></td>
			<td style="font-weight:bold"><%=new DecimalFormat("##.##").format((Double.valueOf(totalConv)/Double.valueOf(totalOrders))*100)%>%</td>
			<td style="font-weight:bold"><%=defaultFormat.format(totalGross)%></td>
</table>

<jsp:include page="../Includes/footer.jsp" />



