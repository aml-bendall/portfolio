
<%
	/**
	* Purpose:Provides an interface for the customer service team to find product data to more easily obtain a freight quote.
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
	*/
%>

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="fibreApps.Core.DB_util" %>
<%@ page import="fibreApps.Warehouse.GcpHelper" %>
<%@ page import="fibreApps.Warehouse.CutSheetHelper" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>

<jsp:include page="../Includes/header.jsp" />

<%


if(request.getParameterMap().containsKey("error")) {
	%>
	<h1 style="color:red;">Invalid Pin - The Paint or Gel Coat has not been removed!!!</h1>
	<%
}

response.setIntHeader("Refresh", 300);

GcpHelper.getPaints();
boolean gcExists=false;
boolean paintExists=false;
DB_util db = new DB_util();
String sql;

try {
	java.sql.Connection getGcCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
	
	sql="Select top 1 * from GCP where status=0 and StockNo not like 'P%' and StockNo not like '00800-%'";
	java.sql.Statement getGcSt = db.dbStatement(getGcCon);
	
	ResultSet gelCoats = db.dbResult(getGcSt, sql);
	
	while (gelCoats.next()) {
		gcExists=true;
	}
	db.dbClose(getGcCon, getGcSt, gelCoats);
}catch(SQLException e) {
		e.printStackTrace();
		
	}	
try {
	java.sql.Connection paintCheckCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
	
	sql="Select top 1 * from GCP where status=0 and (StockNo like 'P%' or StockNo like '00800-%')";
	java.sql.Statement paintCheckSt = db.dbStatement(paintCheckCon);
	
	ResultSet paints = db.dbResult(paintCheckSt, sql);
	
	while (paints.next()) {
			paintExists=true;
	}
	db.dbClose(paintCheckCon, paintCheckSt, paints);
}catch(SQLException e) {
		e.printStackTrace();
	}		
%>
<link rel="stylesheet" href="CSS/GCP.css" />

<div style="text-align:center;">

	<div style="width:49.9%;border-right:solid 1px;float:left;">
		<h1>Gel Coats</h1>
		<div style="width:100%">
		<% if(gcExists==true) {%>
			<img style="width:95%;height:225px;" src="./Warehouse/Images/red.jpg">
		<%} else { %>
			<img style="width:95%;height:225px;" src="./Warehouse/Images/green.jpg">
		<%} %>
		</div>
		<div style="width:100%;margin-top:20px;">
			<table>
			<tr>
				<th>Order Number</th>
				<th>Stock Number</th>
				<th>Description Line Two</th>
				<th>Custom Information</th>
				<th>Quantity Ordered</th>
			</tr>
			<%
			
			try {
				java.sql.Connection getGcCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
				
				sql="Select * from GCP where status=0 and StockNo not like 'P%' and StockNo not like '00800-%'";
				java.sql.Statement getGcSt = db.dbStatement(getGcCon);
				
				ResultSet gelCoats = db.dbResult(getGcSt, sql);
				
				while (gelCoats.next()) {
					%>
					<tr>
					<td><%=gelCoats.getString("OrderNo") %></td>
					<td><%=gelCoats.getString("StockNo") %></td>
					<td><%=gelCoats.getString("Desc2") %></td>
					<td><%=gelCoats.getString("CustomInfo") %></td>
					<td><%=gelCoats.getInt("qtyord") %></td>
					<td>
					<form action="Warehouse/GelCoatAndPaintAction.jsp">
						<input type="hidden" name="gcpID" value="<%=gelCoats.getString("itemId")%>">
						<input class="smalltext" type="password" name="name" placeholder="Pin" required>
						<input type="hidden" name="FormType" value="finish">
						<input type="submit" value="Finish Gel Coat">
					</form>
					</td>					
					</tr>
					<%
					
				}
				db.dbClose(getGcCon, getGcSt, gelCoats);
				}catch(SQLException e) {
					e.printStackTrace();
				}	
			
			
			%>
			</table>
		</div>
	</div>

	<div style="width:49.9%;float:right;">
				<h1>Paints</h1>
		<div style="width:100%">
		<% System.out.println("Paint Exists: " + paintExists);
		if(paintExists==true) {%>
			<img style="width:95%;height:225px;" src="./Warehouse/Images/red.jpg">
		<%} else { %>
			<img style="width:95%;height:225px;" src="./Warehouse/Images/green.jpg">
		<%} %>
		</div>
		<div style="width:100%;margin-top:20px;">
			<table>
			<tr>
				<th>Order Number</th>
				<th>Stock Number</th>
				<th>Description Line One</th>
				<th>Description Line Two</th>
				<th>Custom Information</th>
				<th>Quantity Ordered</th>
			</tr>
			<%
						try {
				java.sql.Connection getPaintCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
				
				sql="Select * from GCP where status=0 and (StockNo like 'P%' or StockNo like '00800-%')";
				java.sql.Statement getPaintSt = db.dbStatement(getPaintCon);
				
				ResultSet paints = db.dbResult(getPaintSt, sql);
				
				while (paints.next()) {
					%>
					<tr>
					<td><%=paints.getString("OrderNo") %></td>
					<td><%=paints.getString("StockNo") %></td>
					<td><%=paints.getString("Desc1") %></td>
					<td><%=paints.getString("Desc2") %></td>
					<td><%=paints.getString("CustomInfo") %></td>
					<td><%=paints.getInt("qtyord") %></td>
					<td>
					<form action="Warehouse/GelCoatAndPaintAction.jsp">
						<input type="hidden" name="gcpID" value="<%=paints.getString("itemId")%>">
						<input class="smalltext" type="password" name="name" placeholder="Pin" required>
						<input type="hidden" name="FormType" value="finish">
						<input type="submit" value="Finish Paint">
					</form>
					</td>					
					</tr>
					<%
					
				}
				db.dbClose(getPaintCon, getPaintSt, paints);
				}catch(SQLException e) {
					e.printStackTrace();
				}	
			
			
			%>
			
			</table>
		</div>
	</div>
</div>


<jsp:include page="../Includes/footer.jsp" />