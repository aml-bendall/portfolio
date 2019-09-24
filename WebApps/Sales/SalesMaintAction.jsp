
<%
	/**
	* Purpose: Handles actions from SalesMaint.jsp and then redirects back to SalesMaint.jsp
	* Created On: 10/24/2017
	* Created By: Allan Bendall
	* 
	* Last Modified On: 2/26/2018
	* Last Modified By: 2/26/2018
	* Change Log
	*
	*2/26/18 - Sales Rep goals were made specific to the sales rep. Rep Goal was added to SalesRepUsers table and SalesRepGoals is no longer used.
	*
	*
	*/
%>
<jsp:include page="../Includes/header.jsp" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.util.Date"%>

<%
	DB_util db = new DB_util();
	String sql = "";
%>

<%
	Enumeration<String> params = request.getParameterNames();
	while (params.hasMoreElements()) {
		String paramName = params.nextElement();
		System.out.println("Parameter Name - " + paramName + ", Value - " + request.getParameter(paramName));
	}

	//Handles Add Request
	if (request.getParameterMap().containsKey("Add")) {
		System.out.println("Adding Users");
		java.sql.Connection AddCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

		if (AddCon != null) {
			PreparedStatement AddSt = AddCon
					.prepareStatement("INSERT INTO SalesDashUsers (MomUserID, TapItNovaID, RepGoal, Minutes) values (?,?,?,?)");
			AddSt.setString(1, request.getParameter("MomID"));
			AddSt.setString(2, request.getParameter("TapID"));
			AddSt.setDouble(3, Double.valueOf(request.getParameter("Goal")));
			AddSt.setDouble(4, Integer.valueOf(request.getParameter("Minutes")));
			AddSt.executeUpdate();

			AddCon.close();
		}
	}

	//Handles User Deletes
	if (request.getParameterMap().containsKey("Delete")) {
		System.out.println("Deleting");
		java.sql.Connection DelCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

		if (DelCon != null) {
			PreparedStatement DelSt = DelCon
					.prepareStatement("Delete FROM SalesDashUsers WHERE TapItNovaID = ?");
			DelSt.setString(1, request.getParameter("Delete"));
			DelSt.executeUpdate();

			DelCon.close();
		}
	}
	response.sendRedirect("SalesMaint.jsp");
%>

<jsp:include page="../Includes/footer.jsp" />