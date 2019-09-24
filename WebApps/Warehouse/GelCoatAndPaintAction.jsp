<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="fibreApps.Core.DB_util" %>
<%@ page import="fibreApps.Warehouse.CutSheetHelper" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="fibreApps.Warehouse.GcpHelper" %>

<%
DB_util db = new DB_util();
String sql;
String name="";
int quant;
int gcpID=Integer.valueOf(request.getParameter("gcpID").trim());

String FormType=String.valueOf(request.getParameter("FormType"));
String pin = request.getParameter("name");


if(request.getParameter("quant")!=null) {
quant = Integer.valueOf(request.getParameter("quant"));
System.out.println(quant);
} else {
	quant=-1;
}

try {
	java.sql.Connection pinCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
	
	sql="Select * From warehousePins where pin='" + pin + "'";
	java.sql.Statement pinSt = db.dbStatement(pinCon);
	
	ResultSet pins = db.dbResult(pinSt, sql);
	
	while (pins.next()) {
		name = pins.getString("names");
	}
	db.dbClose(pinCon, pinSt, pins);
	}catch(SQLException e) {
		e.printStackTrace();
	}
System.out.println("This is form type: " + FormType);
if(name.equals("")) {
	response.sendRedirect("GelCoatAndPaintDash.jsp?error=1");
} else if(FormType.equals("finish")) {
	GcpHelper.endPaint(gcpID, name);
	response.sendRedirect("GelCoatAndPaintDash.jsp");
}



%>

