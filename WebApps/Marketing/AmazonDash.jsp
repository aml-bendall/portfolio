
<%
	/**
	* Purpose:Provides an interface to show products on Amazon that need removed and products that do not exist on Amazon that need added.
	* Created On: 11/14/2017
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
<%@ page import="fibreApps.Sales.AmazonDash"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.util.Date"%>

<h1 style="text-align: center">Amazon Products Dashboard</h1>

<%
	DB_util db = new DB_util();
	AmazonDash amazonHelper = new AmazonDash();
	String sql = "";
	int ErrorState = 0;
	String view = request.getParameter("view");
	NumberFormat defaultFormat = NumberFormat.getCurrencyInstance();
	
	amazonHelper.addItemsExport();
	amazonHelper.removeItemsExport();
	amazonHelper.priceItemsExport();

	
	int addItems=amazonHelper.addItemsCount();
	int removeItems=amazonHelper.removeItemsCount();
	int priceItems=amazonHelper.priceItemsCount();
	
	Date today = new Date();

	Calendar c = Calendar.getInstance();
	c.setTime(today);

	if(addItems>0){
		%>
		<div style="text-align:center;"><h3>Active in MOM - Inactive on Amazon: <b style="color:red;"><%=addItems %></b></h3><a href="./Marketing/addItemsAmazon.txt" download="Active in MOM - Inactive on Amazon.xls">Export</a></div>
		<%
	}
	else{
		%>
		<div style="text-align:center;"><h3>Active in MOM - Inactive on Amazon: <b style="color:green;"><%=addItems %></b></h3><a href="./Marketing/addItemsAmazon.txt" download="Active in MOM - Inactive on Amazon.xls">Export</a></div>
		<%
	}
	if(removeItems>0){
		%>
		<div style="text-align:center;"><h3>Active on Amazon - Inactive in MOM: <b style="color:red;"><%=removeItems %></b></h3><a href="./Marketing/remItemsAmazon.txt" download="Active on Amazon - Inactive in MOM.xls">Export</a></div>
		<%
	}
	else{
		%>
		<div style="text-align:center;"><h3>Active on Amazon - Inactive in MOM: <b style="color:green;"><%=removeItems %></b></h3><a href="./Marketing/remItemsAmazon.txt" download="Active on Amazon - Inactive in MOM.xls">Export</a></div>
		<%
	}
	if(priceItems>0){
		%>
		<div style="text-align:center;"><h3>Amazon price different from MOM price: <b style="color:red;"><%=priceItems %></b></h3><a href="./Marketing/priceItemsAmazon.txt" download="Price Differences - Amazon to Mom.txt.xls">Export</a></div>
		<%
	}
	else{
		%>
		<div style="text-align:center;"><h3>Amazon price different from MOM price: <b style="color:green;"><%=priceItems %></b></h3><a href="./Marketing/priceItemsAmazon.txt" download="Price Differences - Amazon to Mom.xls">Export</a></div>
		<%
	}
	
%>
<jsp:include page="../Includes/footer.jsp" />