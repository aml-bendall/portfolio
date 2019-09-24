
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
int cutID=0;
if(request.getParameter("cutID")!=null) {
	cutID=Integer.valueOf(request.getParameter("cutID"));
}

DB_util db = new DB_util();
String sql;

if(request.getParameter("makeChange")!=null) {
	try {
		java.sql.Connection cutUpdateCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

		PreparedStatement cutUpdateSt = cutUpdateCon
				.prepareStatement("Update CutSheet set orderNo = ?, number=?, desc1=?, desc2=?, binloc=?,quant=?,roll=?,fgdc=?,custominfo=? WHERE cutID=? ");
		cutUpdateSt.setInt(1,  Integer.valueOf(request.getParameter("orderNo")));
		cutUpdateSt.setString(2,  request.getParameter("itemNum"));
		cutUpdateSt.setString(3,  request.getParameter("desc1"));
		cutUpdateSt.setString(4,  request.getParameter("desc2"));
		cutUpdateSt.setString(5,  request.getParameter("binloc"));
		cutUpdateSt.setInt(6,  Integer.valueOf(request.getParameter("quant")));
		cutUpdateSt.setString(7,  request.getParameter("roll"));
		cutUpdateSt.setString(8,  request.getParameter("fgdc"));
		cutUpdateSt.setString(9,  request.getParameter("customInfo"));
		System.out.println(cutUpdateSt);
		cutUpdateSt.setInt(10,  cutID);
		cutUpdateSt.executeUpdate();

		cutUpdateCon.close();
		}catch(SQLException e) {
			e.printStackTrace();
		}
	response.sendRedirect("CutSheetReport.jsp");
} else {
try {
	java.sql.Connection getCutCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
	
	sql="Select * from CutSheet where cutID='"+cutID+"'";
	java.sql.Statement getCutSt = db.dbStatement(getCutCon);
	
	ResultSet cut = db.dbResult(getCutSt, sql);
	
	while (cut.next()) {
		
		%>
		<table>
<tr>
<th colspan=3>Order or Lot #</th>
<th>Item #</th>
<th>Description One</th>
<th>Description Two</th>
<th>Bin Location</th>
<th>Quantity</th>
<th>Roll #<br/>R-</th>
<th>FGDC<br/>P.O. #</th>
<th>Custom Information</th>
</tr>
<tr>
	<form action="Warehouse/CutSheetEdit.jsp" style="text-align:center;">
			<td><input type="hidden" name="makeChange" value="Yes"></td>
			<td><input type="hidden" name="cutID" value="<%=cutID%>"></td>
			<td><input type="number" name="orderNo" value="<%=cut.getInt("OrderNo")%>"></td>
			<td><input type="text" name="itemNum" value="<%=cut.getString("number")%>"></td>
			<td><input type="text" name="desc1" value="<%=cut.getString("DESC1")%>"></td>
			<td><input type="text" name="desc2" value="<%=cut.getString("DESC2")%>"></td>
			<td><input type="text" name="binloc" value="<%=cut.getString("binLoc")%>"></td>
			<td><input type="number" name="quant" value="<%=cut.getInt("quant")%>"></td>
			<td><input type="text" name="roll" value="<%=cut.getString("roll")%>"></td>
			<td><input type="text" name="fgdc" value="<%=cut.getString("fgdc")%>"></td>
			<td><input type="text" name="customInfo" value="<%=cut.getString("customInfo")%>"></td>
			<td><input type="submit" value="Save Changes"></td>
		</form>
	</tr>	</table>
		<%

	}
	db.dbClose(getCutCon, getCutSt, cut);
	}catch(SQLException e) {
		e.printStackTrace();
	}
}
%>
<jsp:include page="../Includes/footer.jsp" />