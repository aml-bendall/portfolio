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
 
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="fibreApps.Core.DB_util" %>
<%@ page import="fibreApps.Warehouse.CutSheetHelper" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="fibreApps.Sales.ListGeneration" %>

<%
//Create list that was requested from ListGen.jsp
Enumeration<String> params = request.getParameterNames();
while (params.hasMoreElements()) {
	String paramName = params.nextElement();
	System.out.println("Parameter Name - " + paramName + ", Value - " + request.getParameter(paramName));
}

DB_util db = new DB_util();
String sql;

if(request.getParameter("submit").equals("Run rfm Report")) {
	int count = Integer.valueOf(request.getParameter("totalCount"));
	int rfm = Integer.valueOf(request.getParameter("rfm"));
	String salesRep = request.getParameter("salesRep");
	String fileName = request.getParameter("fileName");
	System.out.println(count);
	System.out.println(rfm);
	System.out.println(salesRep);
	System.out.println(fileName);

	ListGeneration.initRfm(rfm, count, fileName, salesRep);
}

if(request.getParameter("submit").equals("Run Cat Report")) {
	String startDate = request.getParameter("startDate");
	String endDate = request.getParameter("endDate");
	String salesRep = request.getParameter("salesRep");
	String fileName = request.getParameter("fileName");
	System.out.println(startDate);
	System.out.println(endDate);
	System.out.println(salesRep);
	System.out.println(fileName);

	ListGeneration.initCat(startDate, endDate, fileName, salesRep);
}

response.sendRedirect("ListGen.jsp?status=1");



%>

