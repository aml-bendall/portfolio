
<%
	/**
	* Purpose:Interface used to link to Sales tools.
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

<link rel="stylesheet" href="CSS/SalesIndex.css" />

<!-- Index for Sales related tools -->
<div class="row">
	<div class="column">
		<h1>
			<b>Business Tools</b>
		</h1>
		<h3 style="text-decoration: underline">
			<b>Dashboards</b>
		</h3>
		<p>
			<a href="Sales/SalesDash.jsp">Sales Dashboard</a>
		</p>
		<p>
			<a href="Sales/SalesDashReport.jsp">Sales Dashboard Reporting</a>
		</p>
		<p>
			<a href="Sales/OnlineSalesDash.jsp">Online Sales Dashboard</a>
		</p>
		<p>
			<a href="Sales/TransactionTiers.jsp">Transaction Tier Dashboard</a>
		</p>
		<p>
			<a href="Sales/SalesByRep.jsp">Shipped Sales By Rep</a>
		</p>
		<p>
			<a href="Marketing/CatReqDash.jsp">Catalog Request Dashboard</a>
		</p>
		<h3 style="text-decoration: underline">
			<b>Freight</b>
		</h3>
		<p>
			<a href="Sales/FreightQuote.jsp">Freight Quote Helper</a>
		</p>
		<p>
			<a href="Sales/AdjustmentReport.jsp">UPS Dimensions Report</a>
		</p>
		<h3>
			<b>Quotes</b>
		</h3>
		<p>
			<a href="Sales/QuoteTracker.jsp">Sales Quote Tracker</a>
		</p>
		<p>
			<a href="Sales/QuoteDetails.jsp">Quote Details by Rep</a>
		</p>

	</div>
	<div class="column">
		<h1>
			<b>Administration</b>
		</h1>
		<p>
			<a href="Sales/SalesMaint.jsp#">Sales Dashboard Maintenance</a>
		</p>
	</div>
	<div class="column">
		<h1>
			<b>Links</b>
		</h1>
		<p>
			<a href="http://www.fibreglast.com">FibreGlast Website</a>
		</p>

	</div>
</div>
<div>
	<div></div>
</div>


<jsp:include page="../Includes/footer.jsp" />