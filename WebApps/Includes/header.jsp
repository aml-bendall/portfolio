
<%
	/**
	 * Purpose:Header to be included on all pages. Also set the base path to make it easier to call other programs.
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
<%@ page import="fibreApps.Core.DB_util" %>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="req" value="${pageContext.request}" />
<c:set var="url">${req.requestURL}</c:set>
<c:set var="uri" value="${req.requestURI}" />

<%

DB_util db_header = new DB_util();
String sql_header;
String userRoles="";
System.out.println(request.getUserPrincipal().getName());
if(request.getUserPrincipal().getName()!=null) {
	try {
		java.sql.Connection adminCon = db_header.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
		
		sql_header="Select u.user_name,u.email,r.apps_role From users u inner join UsersRoles r on u.user_name=r.user_name where u.user_name='"+request.getUserPrincipal().getName()+"' ";
		java.sql.Statement adminSt = db_header.dbStatement(adminCon);
		
		ResultSet admin = db_header.dbResult(adminSt, sql_header);
		while(admin.next()) {
			if(admin.getString("apps_role")!=null) {
		 	userRoles=admin.getString("apps_role");
			}
		}
		db_header.dbClose(adminCon, adminSt, admin);
		}catch(SQLException e) {
			e.printStackTrace();
		}
}
%>

<!DOCTYPE html>
<html>
<head>
<base href="${fn:substring(url, 0, fn:length(url) - fn:length(uri))}${req.contextPath}/WebApps/" />
<link rel="stylesheet" href="CSS/header.css" />
</head>
<body>
<div class="header">
	<div>
	<h1>
		<a href="Index.jsp"><img src="Includes/Images/fibre.PNG"></a>
	</h1>
	    <ul class="navside">   
        <li><a style="float:right;" href="Index.jsp?status=logout">Logout</a></li>
        <li><a style="float:right;" href="Profile.jsp">My Profile</a></li>	
	</ul>
	</div>
<div>	
<%
String name = request.getUserPrincipal().getName();
%>
	<ul class="nav">
	<%
	if(name.toLowerCase().equals("cutlist") || name.toLowerCase().equals("a")) {
	%>
	<li><a href="Warehouse/WarehouseIndex.jsp" class="inner-link-effect">Warehouse</a></li>
			<% 
	} else {
		%>
		<li><a href="Sales/SalesIndex.jsp" class="inner-link-effect">Sales</a></li>
		<li><a href="Marketing/MarketingIndex.jsp" class="inner-link-effect">Marketing</a></li>
		<li><a href="Warehouse/WarehouseIndex.jsp" class="inner-link-effect">Warehouse</a></li>
			<% 
	}
		%>
		<li>
    </ul>
</div>
</div>	

</div>