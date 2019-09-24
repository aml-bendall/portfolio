<% /**
 * Purpose:Generate a call list for the sales reps.
 * Created On: 5/16/2018
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
<link rel="stylesheet" href="CSS/ListGen.css" />

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

//When report is ready, notify user.
if(request.getParameter("status")!=null && request.getParameter("status").equals("1")){
	%>	
	<H2 style="color:green;text-align:center;">Report is ready for pickup at M:\Document Pickup\Final</H2>
	<% 
}
%>

<!-- Set the information desired to generate a call list for the sales reps -->
<div>

<!-- 	Begin form for a RFM list -->
	<div class="twoWide">
	<form style="veritcal-align: center" method="post"
	action="Sales/ListGenAction.jsp">
	<h1 style="text-align:center;margin-bottom:1em;">Create RFM List</h1>
		<p>
			Number of customers to include on the report: <input type="number" name="totalCount" required>
		</p>
		<p>
			Customer RFM: <input type="number" name="rfm" required>
		</p>
		<p> Who will this list be assigned to?
<select name="salesRep">
<%
//Select Rep for the list to be assigned to
try {
	java.sql.Connection repCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

		java.sql.Statement repSt = db.dbStatement(repCon);

		sql = "SELECT DISTINCT MomUserId FROM SalesDashUsers";

		ResultSet reps = db.dbResult(repSt, sql);
		
		while (reps.next()) {
			%>
			<option value="<%=reps.getString("MomUserId")%>"><%=reps.getString("MomUserId") %></option>
		<%
		} 
		db.dbClose(repCon, repSt, reps);
  	}catch(SQLException e) {
			e.printStackTrace();
		}
%>
</select>
</p>
		<p>
			What will the file name be? <input type="text" name="fileName" required>
		</p>
		<p style="text-align:center;">
		<input type="submit" value="Run rfm Report" name="submit">
	</p>
	</form>
	</div>
	
	
<!-- 	Begin form for a catalog request list -->
	<div class="twoWide">
		<form style="veritcal-align: center; text-align: center;" method="post"
		action="Sales/ListGenAction.jsp">
		<h1 style="text-align:center;margin-bottom:1em;">Catalog Request List</h1>
			<p>Start Date: <input type="date" name="startDate" required></p>
		    <p>End Date: <input type="date" name="endDate" required></p>
		    		<p> Who will this list be assigned to?
<select name="salesRep">
<%
try {
	java.sql.Connection repCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

		java.sql.Statement repSt = db.dbStatement(repCon);

		sql = "SELECT DISTINCT MomUserId FROM SalesDashUsers";

		ResultSet reps = db.dbResult(repSt, sql);
		
		while (reps.next()) {
			%>
			<option value="<%=reps.getString("MomUserId")%>"><%=reps.getString("MomUserId") %></option>
		<%
		} 
		db.dbClose(repCon, repSt, reps);
  	}catch(SQLException e) {
			e.printStackTrace();
		}
%>
</select>
</p>
		<p>
			What will the file name be? <input type="text" name="fileName" required>
		</p>
			<input type="submit" value="Run Cat Report" name="submit">
		</form>
	</div>
</div>
	

<jsp:include page="../Includes/footer.jsp" />