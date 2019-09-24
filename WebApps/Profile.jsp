
<%
	/**
	* Purpose: Allows user to view and change their profile.
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
<%@ page session="true" %>

<link rel="stylesheet" href="CSS/Profile.css" />

<%
//The Url is recalled at the end of the Action program. If the url parameter status is 1 then the password was just changed.
if(request.getParameter("status") != null) {
if(Integer.parseInt(request.getParameter("status")) == 1) {
%>
<h1 style="text-align:center;color:green">Password Changed!</h1>
<%
}
if(Integer.parseInt(request.getParameter("status")) == 0) {
%>
<h1 style="text-align:center;color:red">Password Change Failed!</h1>
<%
}
}
%>

<!-- Call the Action page in order to perform the necessary changes. -->
  <div class="change">
  <form class="change-pw" action="ProfileAction.jsp" method=post> 
  <input type="password" placeholder="Enter New Password" name="newPass" id="newPass">  
  <input type="password" placeholder="Confirm New Password" name="confPass" id="confPass" oninput="check(this)">
  <script>
  //Method to ensure that the new passwords match.
    function check(input) {
        if (input.value != document.getElementById('newPass').value) {
            input.setCustomValidity('Passwords Must Match.');
        } else {
            // input is valid -- reset the error message
            input.setCustomValidity('');
        }
    }
</script>  

  <input type="submit" value="Change Password" name="cp">

  </form>
</div>
  
<jsp:include page="Includes/footer.jsp" />