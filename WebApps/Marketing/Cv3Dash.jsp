
<%
	/**
	* Purpose:Provides an interface which displays items that are not on Cv3 that are in the ERP, items
			  which are on the website which are no longer in the ERP, and price differences between the ERP and Web.
			  The cv3Helper java class performs the logic to gather the data and creates a file.
	* Created On: 4/21/2018
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
<%@ page import="fibreApps.Sales.Cv3Dash"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.util.Date"%>

<h1 style="text-align: center;margin-bottom:3em;">CV3 Products Dashboard</h1>

<%
	DB_util db = new DB_util();
	Cv3Dash cv3Helper = new Cv3Dash();
	String sql = "";
	int ErrorState = 0;
	String view = request.getParameter("view");
	NumberFormat defaultFormat = NumberFormat.getCurrencyInstance();
	

	cv3Helper.addItemsExport();
	cv3Helper.removeItemsExport();
	cv3Helper.priceItemsExport();

	int addItems=cv3Helper.addItemsCount();
	int removeItems=cv3Helper.removeItemsCount();
	int priceItems=cv3Helper.priceItemsCount();
	Date today = new Date();

	Calendar c = Calendar.getInstance();
	c.setTime(today);
	if(addItems>0){
		%>
		<div style="text-align:center;"><h3>Active in MOM - Inactive on CV3: <b style="color:red;"><%=addItems %></b></h3>Report available at M:/Allan Bendall/FibreApps/CV3Compare/addItemsCv3.txt</div>
		<%
	}
	else{
		%>
			<div style="text-align:center;"><h3>Active in MOM - Inactive on CV3: <b style="color:green;"><%=addItems %></b></h3>Report available at M:/Allan Bendall/FibreApps/CV3Compare/addItemsCv3.txt</div>
		<%
	}
	if(removeItems>0){
		%>
			<div style="text-align:center;"><h3>Active on CV3 - Inactive in MOM:  <b style="color:red;"><%=removeItems %></b></h3>Report available at M:/Allan Bendall/FibreApps/CV3Compare/remItemsCv3.txt</div>
		<%
	}
	else{
		%>
		<div style="text-align:center;"><h3>Active on CV3 - Inactive in MOM:  <b style="color:green;"><%=removeItems %></b></h3>Report available at M:/Allan Bendall/FibreApps/CV3Compare/remItemsCv3.txt</div>
		<%
	}
	if(priceItems>0){
		%>
		<div style="text-align:center;"><h3>CV3 price different from MOM price: <b style="color:red;"><%=priceItems %></b></h3>Report Available at M:/Allan Bendall/FibreApps/Cv3Compare/priceItemsCv3.txt</div>
		<%
	}
	else{
		%>
		<div style="text-align:center;"><h3>CV3 price different from MOM price: <b style="color:green;"><%=priceItems %></b></h3>Report Available at M:/Allan Bendall/FibreApps/Cv3Compare/priceItemsCv3.txt</div>
		<%
	}
	%>	

<jsp:include page="../Includes/footer.jsp" />