
<%
	/**
	* Purpose:Landing page for users after logging into the application.
	* Created On: 10/20/2017
	* Created By: Allan Bendall
	* 
	* Last Modified On: 10/25/2017
	* Last Modified By:Allan Bendall
	* Change Log
	* 10/25/2017 - Added logout functionality through the url param.
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

String status=request.getParameter("status");

if(status == null) {
	status = "";
}
if(status.equals("logout")) {
	
	HttpSession logout=request.getSession();  
    logout.invalidate();
      
    %>

    <h1 style="text-align:center;color:red">You have successfully logged out!</h1>
    <%
}

  %>           
<jsp:include page="Includes/footer.jsp" />