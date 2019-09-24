<%
	/**
	* Purpose: Handles actions from Profile.jsp and then redirects back to Profile.jsp
	* Created On: 10/25/2017
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
<jsp:include page="Includes/header.jsp" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.util.Date"%>

<%
	DB_util db = new DB_util();
	String sql = "";
	int Status=0;
%>


<%

//Password is being changed. Perform encryption of the new password and save it to the database.
if (request.getParameterMap().containsKey("cp")) {
	System.out.println("Updating Profile");
	java.sql.Connection cpCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

	System.out.println(request.getParameter("newPass"));
	
	if (cpCon != null) {
		PreparedStatement cpSt = cpCon.prepareStatement("Update Users set user_pw = CONVERT(VARCHAR(32), HashBytes('MD5', '" +  request.getParameter("newPass") + "'), 2) WHERE user_name = ?");
		cpSt.setString(1, request.getUserPrincipal().getName());
		cpSt.executeUpdate();

		cpCon.close();
	Status=1;
	}
}

//Return to the initial page and give the user a success or error based on result.
response.sendRedirect("Profile.jsp?status="+ Status);
%>
