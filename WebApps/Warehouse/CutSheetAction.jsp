
<% /**
 * Purpose:Performs actions that were entered on CutSheet.JSP
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

<%

//Receives data from CutSheet.JSP and makes the necessary changes to the database. Utilizes the java function CutSheepHelper.
Enumeration<String> params = request.getParameterNames();
while (params.hasMoreElements()) {
	String paramName = params.nextElement();
	System.out.println("Parameter Name - " + paramName + ", Value - " + request.getParameter(paramName));
}

DB_util db = new DB_util();
String sql;
String name="";
int quant;
int cutID=0;

if(request.getParameter("cutID")!=null) {
	cutID=Integer.valueOf(request.getParameter("cutID"));
}

String FormType=String.valueOf(request.getParameter("FormType"));
String pin = request.getParameter("name");
String roll = request.getParameter("roll");
String fgdc = request.getParameter("fgdc");


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

if(name.equals("") && (FormType.equals("begin") || FormType.equals("finish"))) {
	response.sendRedirect("CutSheet.jsp?error=1");
}
else if(FormType.equals("begin")) {
	CutSheetHelper.beginCut(cutID, name);
	response.sendRedirect("CutSheet.jsp");
} 
else if(FormType.equals("finish") && quant>=0) {
	CutSheetHelper.splitCut(cutID, name,roll,fgdc, quant);
	response.sendRedirect("CutSheet.jsp");
}
else if(FormType.equals("add")) {
	CutSheetHelper.addCut(Integer.valueOf(request.getParameter("OrderNo")), request.getParameter("itemNum"),Integer.valueOf(request.getParameter("Qty")),request.getParameter("info"),Integer.valueOf(request.getParameter("prePack")));
	response.sendRedirect("CutSheet.jsp");
} 
else if(FormType.equals("delete")) {
	CutSheetHelper.deleteCut(Integer.valueOf(request.getParameter("cutID")));
	response.sendRedirect("CutSheet.jsp");
} 
else if(FormType.equals("deleteReport")) {
	CutSheetHelper.deleteCut(Integer.valueOf(request.getParameter("cutID")));
	response.sendRedirect("CutSheetReport.jsp");
} 
else if(FormType.equals("finish")) {
	CutSheetHelper.endCut(cutID, name,roll,fgdc);
	response.sendRedirect("CutSheet.jsp");
}



%>

