
<% /**
 * Purpose:Provides an interface for Cuts made in the warehouse.
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

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="fibreApps.Core.DB_util" %>
<%@ page import="fibreApps.Warehouse.CutSheetHelper" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%@include file="../Includes/header.jsp"%>

<link rel="stylesheet" href="CSS/CutSheet.css" />
<%
response.setIntHeader("Refresh", 300);

CutSheetHelper.getCuts();

DB_util db = new DB_util();
String sql;

//If an error occured during submission display on screen.
String errorCode = request.getParameter("error");
if(request.getParameter("error")!=null) {
	%>
	<h2 style="color:red;">Invalid Pin</h2>
	<%
}
%>

<!-- Setup table headers -->
<h2>Current Cut List</h2>
<table>
<tr>
<th>Order or Lot #</th>
<th>Item #</th>
<th>Description One</th>
<th>Description Two</th>
<th>Bin Location</th>
<th>Quantity</th>
<th>Roll #<br/>R-</th>
<th>FGDC<br/>P.O. #</th>
<th>Custom Information</th>
<th>Pick Time</th>
</tr>
<%
//Set date for SQL queries
SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM/dd/yyyy hh:mm a");

try {
	//Collect cuts that have not been completed.
	java.sql.Connection checkCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
	
	sql="Select * From CutSheet where (inProgress=0 or inProgress=1) order by orderNo ";
	java.sql.Statement checkSt = db.dbStatement(checkCon);
	
	ResultSet checkCuts = db.dbResult(checkSt, sql);
	
	while (checkCuts.next()) {
		%>
<!-- 		Create form for each cut that allows the fabric cutters to begin and end the cut. -->
		<form action="Warehouse/CutSheetAction.jsp">
			<tr>
				<td><%=checkCuts.getInt("orderno") %></td>
				<td><%=checkCuts.getString("number") %></td>
				<td><%=checkCuts.getString("desc1") %></td>
				<td><%=checkCuts.getString("desc2") %></td>
				<td><%=checkCuts.getString("binLoc") %></td>
				
				<%
				if(checkCuts.getInt("inProgress")==1 && checkCuts.getInt("prePack")==1) {
				%>
				<td><input class="smalltext" type="number" name="quant" value="<%=checkCuts.getInt("quant") %>"required></td>
				<%
				} else {
				%>
				<td><%=checkCuts.getInt("quant") %></td>
				<%
				} 
				
				if(checkCuts.getInt("inProgress")==1) {
				%>
				<td><input class="bigtext" type="text" name="roll" required></td>
				<td><input class="bigtext" type="text" name="fgdc" required></td>
				<%
				} else {
				%>
				<td></td>
				<td></td>
				<%
				} 
				%>
				<td><%=checkCuts.getString("customInfo") %></td>
				<td><%=simpleDateFormat.format(checkCuts.getTimestamp("pickTime")) %></td>
				<% 
				if(checkCuts.getString("startCutTime")!=null) {
				%>
				<td>
				Started on <%=simpleDateFormat.format(checkCuts.getTimestamp("startCutTime")) %><br/> by <%=checkCuts.getString("startUser") %>
				</td>
				<%
				}else{
					%>
					
				<td>
					<form action="Warehouse/CutSheetAction.jsp">
					<input type="hidden" name="cutID" value="<%=checkCuts.getInt("cutID")%>">
					<input class="smalltext" type="password" name="name" placeholder="Pin" required>
					<input type="hidden" name="FormType" value="begin">
					<input type="submit" value="Begin Cut">
						</form>	
				</td>
				
				<%
				}
				%>
				<%
				if(checkCuts.getInt("inProgress")==1) {
				%>
				<td>
					
						<input type="hidden" name="cutID" value="<%=checkCuts.getInt("cutID")%>">
						<input class="smalltext" type="password" name="name" placeholder="Pin" required>
						<input type="hidden" name="FormType" value="finish">
						<input type="submit" value="Finish Cut">
					
				</td>
				<%
				}
				
				if(userRoles.toLowerCase().trim().contains("wm")) {	
					
					%>
				
				<td>
				<form action="Warehouse/CutSheetAction.jsp">
					<input type="hidden" name="cutID" value="<%=checkCuts.getInt("cutID")%>">
					<input type="hidden" name="FormType" value="delete">
					<input type="submit" value="Delete Cut" onclick="return confirm('Are you sure?')">			
				</td>
				</form>
			<%
				}
				%>
				
			</tr>
		</form>
		<%
	}
	db.dbClose(checkCon, checkSt, checkCuts);
	}catch(SQLException e) {
		e.printStackTrace();
	}

%>
</table>
<script>
function clicked(e)
{
    if(!confirm('Are you sure?'))e.preventDefault();
}
</script>
<%
//If the user is a warehouse manager allow them to delete cuts.
if(userRoles.toLowerCase().trim().contains("wm")) {	
%>
		<form action="Warehouse/CutSheetAction.jsp">
		<table>
				<tr>
<th>Order or Lot #</th>
<th>Item #</th>
<th>Description One</th>
<th>Description Two</th>
<th>Bin Location</th>
<th>Quantity</th>
<th>Roll #<br/>R-</th>
<th>FGDC<br/>P.O. #</th>
<th>Custom Information</th>
<th>Pick Time</th>
<th>PrePack?</th>
</tr>
				<tr><td><input type="number" name="OrderNo" value="Enter Order No"></td>
				<td><input type="text" name="itemNum" value="Enter Item No"></td>
				<td><input type="hidden" name="FormType" value="add"></td>
				<td></td>
				<td></td>
				<td><input type="number" name="Qty" value="Enter Qty (Not Yards # of item to be made)"></td>
				<td></td>
				<td></td>
				<td><input type="text" name="info"></td>
				<td></td>
				<td><select name="prePack">
  <option  value="1">Yes</option>
  <option  value="0" selected>No</option>
</select></td>
				<td><input type="submit" value="Add Cut"></td></tr>
		</table>
		</form>
	<%
}
%>

<jsp:include page="../Includes/footer.jsp" />