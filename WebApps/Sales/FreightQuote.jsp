
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
<jsp:include page="../Includes/header.jsp" />

<link rel="stylesheet" href="CSS/FreightQuote.css" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.util.Date"%>

<h1 style="text-align: center">Freight Quote Helper</h1>
<p style="text-align: center;">Enter an Order Number to Find Freight
	Information</p>

<form style="veritcal-align: center; text-align: center;" method="post"
	action="Sales/FreightQuote.jsp">
	<input type="text" name="OrderID" value=""> <input
		type="submit" value="submit" name="oq">
</form>

<%
	DB_util db = new DB_util();
	String sql = "";
	int ErrorState = 0;
	String OrderID = request.getParameter("OrderID");

	if (OrderID == null || OrderID == "") {
		ErrorState = 1;
%>
<%
	} else {
		//Get Item information
		java.sql.Connection OrderCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

		if (OrderCon != null) {
			java.sql.Statement OrderSt = db.dbStatement(OrderCon);

			sql = "SELECT i.item,i.quanto, s.DESC1, s.hazardous, s.blength, s.bwidth, s.bheight, s.unitweight, (i.quanto * s.unitweight) as ExtendedWeight, sc.CDESC as HCode from ITEMS i INNER JOIN STOCK s ON i.item=s.number inner join st_customs sc on s.number=sc.NUMBER where orderno = '" + OrderID + "' and i.item != 'Hazard Charge' order by i.item";

			ResultSet Order = db.dbResult(OrderSt, sql);
	
			//Setup table to display information
%>
<table id="OrderExport" class="responstable">
	<tr>
		<th style="text-align: center" colspan="10">Order ID: <%=OrderID%></th>
	</tr>
	<tr>
		<th>Item Number</th>
		<th>Quantity Ordered</th>
		<th>Item Description</th>
		<th>Hazardous?</th>
		<th>Length</th>
		<th>Width</th>
		<th>Height</th>
		<th>Weight</th>
		<th>Extended Weight</th>
		<th>Harmonized Code</th>
	</tr>
	<%
	//loop through query results
		while (Order.next()) {
	%>

	<tr>
		<td><%=Order.getString("item")%></td>
		<td><%=Order.getString("quanto")%></td>
		<td><%=Order.getString("DESC1")%></td>
		<%
			if (Order.getString("hazardous").equals("1")) {
		%>
		<td>Yes</td>
		<%
			} else {
		%>
		<td>No</td>
		<%
			}
		%>
		<td><%=Order.getString("blength")%></td>
		<td><%=Order.getString("bwidth")%></td>
		<td><%=Order.getString("bheight")%></td>
		<td><%=Order.getString("unitweight")%></td>
		<td><%=Order.getString("ExtendedWeight")%></td>
		<td><%=Order.getString("HCode")%></td>
	</tr>
	<%
		}
				db.dbClose(OrderCon, OrderSt, Order);
			}
	%>
</table>
<script>
	function tableToExcel(x) {
		var tab_text = "<table border='2px'><tr bgcolor='#87AFC6'>";
		var textRange;
		var j = 0;
		tab = document.getElementById(x); // id of table

		for (j = 0; j < tab.rows.length; j++) {
			tab_text = tab_text + tab.rows[j].innerHTML + "</tr>";
			//tab_text=tab_text+"</tr>";
		}

		tab_text = tab_text + "</table>";
		tab_text = tab_text.replace(/<A[^>]*>|<\/A>/g, "");//remove if u want links in your table
		tab_text = tab_text.replace(/<img[^>]*>/gi, ""); // remove if u want images in your table
		tab_text = tab_text.replace(/<input[^>]*>|<\/input>/gi, ""); // reomves input params

		var ua = window.navigator.userAgent;
		var msie = ua.indexOf("MSIE ");

		if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) // If Internet Explorer
		{
			txtArea1.document.open("txt/html", "replace");
			txtArea1.document.write(tab_text);
			txtArea1.document.close();
			txtArea1.focus();
			sa = txtArea1.document.execCommand("SaveAs", true,
					"_FreightQuote.xls");
		} else
			//other browser not tested on IE 11
			sa = window.open('data:application/vnd.ms-excel,'
					+ encodeURIComponent(tab_text));

		return (sa);
	}
</script>
<input style="margin-top: 2em;" type="button" onclick="tableToExcel('OrderExport')"
	value="Export to Excel">
<%
	}
%>

<jsp:include page="../Includes/footer.jsp" />