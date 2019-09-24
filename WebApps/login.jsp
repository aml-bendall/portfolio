
<%
	/**
	* Purpose:Login page ran through the web.xml and server.xml configuration of Realm which is built in with Tomcat. Utilizes md5 hash.
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

<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="req" value="${pageContext.request}" />
<c:set var="url">${req.requestURL}</c:set>
<c:set var="uri" value="${req.requestURI}" />

<!DOCTYPE html>
<html>
<head>
<base href="${fn:substring(url, 0, fn:length(url) - fn:length(uri))}${req.contextPath}/WebApps/" />

<%-- <%
if(request.getParameter("error") != null || request.getParameter("error") != "" ){
}
%> --%>
<link rel="stylesheet" href="CSS/login.css" />

</head>

<!-- Validate password and log the user in. -->
<body>
	<h1>
		<a href="Index.jsp"><img src="Includes/Images/fibre.PNG"></a>
	</h1>
  <div class="login">
  <form class="form-signin" action="j_security_check" method=post> 
    <input type="text" placeholder="Username" name="j_username" id="username">  
  <input type="password" placeholder="password" name="j_password" id="password">  
  <a href="#" class="forgot">forgot password?</a>
  <%
  try {
  %>
  <input type="submit" value="Sign In">
  <%
  } catch(Exception e){
		  %>
		  <p>Login Failed</p>
		  <%  
	  }
  %>
  </form>
</div>
<div class="shadow"></div>

<jsp:include page="Includes/footer.jsp" />