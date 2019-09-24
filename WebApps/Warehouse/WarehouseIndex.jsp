
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

<!-- Sales home page. Links to all Sales Related tools -->
<div class="row">
	<div class="column">
		<h1>
			<b>Business Tools</b>
		</h1>
				<p>
			<a href="Sales/FreightQuote.jsp">Freight Quote Helper</a>
		</p>
		<h3 style="text-decoration: underline">
			<b>Cut Sheet</b>
		</h3>
		<p>
			<a href="Warehouse/CutSheet.jsp#">Cut Sheet</a>
		</p>
		<p>
			<a href="Warehouse/CutSheetReport.jsp#">Finished Cuts Report</a>
		</p>
		<h3 style="text-decoration: underline">
			<b>Production</b>
		</h3>
		<p>
			<a href="Warehouse/GelCoatAndPaintDash.jsp#">Gel Coats and Paints Dashboard</a>
		</p>
	</div>
	<div class="column">
		<h1>
			<b>Metrics</b>
		</h1>
		<h3 style="text-decoration: underline">
			<b>Shipping</b>
		</h3>
		<p>
			<a href="Warehouse/ShippingDash.jsp#">Shipping Dashboard</a>
		</p>
		<p>
			<a href="Warehouse/ShippingDashReport.jsp#">Shipping Report</a>
		</p>
		<h3 style="text-decoration: underline">
			<b>Fabrics</b>
		</h3>
		<p>
			<a href="Warehouse/FabricsDash.jsp#">Fabrics Dashboard</a>
		</p> 
		 <p>
			<a href="Warehouse/FabricsDashReport.jsp#">Fabrics Report</a>
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