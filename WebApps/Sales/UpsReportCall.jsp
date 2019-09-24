<%@page import="fibreApps.Sales.UpsAdjustments"%>
<%
	/**
	* Purpose: Allows the upload of a UPS Invoice. Then compares adjustments to what we charged the customer.
	* Created On: 03/05/2017
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

<link rel="stylesheet" href="CSS/FreightQuote.css" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.util.Date"%>

<!-- Call the Java method which compares the report to the SQL database -->
<%
UpsAdjustments.main();
%>

<jsp:include page="../Includes/footer.jsp" />
