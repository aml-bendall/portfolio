
<%
	/**
	* Purpose:Setup sales reps that should appear on the sales dashboard.
	* Created On: 10/20/2017
	* Created By: Allan Bendall
	* 
	* Last Modified On:2/26/2018
	* Last Modified By: Allan Bendall
	* Change Log
	*
	*2/26/18 - Sales Rep goals were made specific to the sales rep. Rep Goal was added to SalesRepUsers table and SalesRepGoals is no longer used.
	*
	*
	*/
%>

<jsp:include page="../Includes/header.jsp" />
<link rel="stylesheet" href="CSS/SalesMaint.css" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.util.Date"%>

<%
	NumberFormat defaultFormat = NumberFormat.getCurrencyInstance();
%>

<!-- Display Current Users and provide a form for additions and removal -->
<div class="row">
	<div class="column">
		<h1>Users</h1>
		<form method="post" action="Sales/SalesMaintAction.jsp">
			<table
				style="text-align: center; align: center; width: 55%; padding-left: 6cm; margin: 0 auto; "
				class="users">
				<tr>
					<th>Mom User ID</th>
					<th>TapItNova User ID</th>
					<th>Sales Rep Goal</th>
					<th>Sales Rep Minutes</th>
					<th></th>
				</tr>
				<%
					DB_util db = new DB_util();

					java.sql.Connection UserCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

					if (UserCon != null) {
						java.sql.Statement UserSt = db.dbStatement(UserCon);

						String sql = "SELECT uid,MomUserID,TapItNovaID,RepGoal,Minutes FROM SalesDashUsers Order by uid";

						ResultSet Users = db.dbResult(UserSt, sql);

						while (Users.next()) {
				%>
				<tr>
					<td><%=Users.getString("MomUserID")%></td>
					<td><%=Users.getString("TapItNovaID")%></td>
					<td><%=defaultFormat.format(Double.valueOf(Users.getString("RepGoal")))%></td>
					<td><%=Double.valueOf(Users.getString("Minutes"))%></td>
					<td><button type="submit" name="Delete"
							value="<%=Users.getString("TapItNovaID")%>"
							style="background-color: #0000A0; font-weight: bold; color: #ffffff;">Delete</button></td>
				</tr>
				<%
					}
						db.dbClose(UserCon, UserSt, Users);
					}
				%>
			</table>
			<table
				style="width: 45%; text-align: center; align: center;padding-left:1.5cm; margin: 0 auto; "
				class="users">
				<tr>
					<td><input type="text" name="MomID" value=""></td>
					<td><input type="text" name="TapID" value=""></td>
					<td><input type="text" onkeypress="return isNumberKey(event)" name="Goal" value=""></td>
					<td><input type="text" onkeypress="return isNumberKey(event)" name="Minutes" value=""></td>
					<th></th>
				</tr>
			</table>

			<p>
				<input type="submit" name="Add" value="Add User"
					style="background-color: #0000A0; font-weight: bold; color: #ffffff;">
			</p>
		</form>
	</div>
			<SCRIPT>
    
       function isNumberKey(evt)
       {
          var charCode = (evt.which) ? evt.which : evt.keyCode;
          if (charCode != 46 && charCode > 31 
            && (charCode < 48 || charCode > 57))
             return false;

          return true;
       }
       
    </SCRIPT>

</div>



<jsp:include page="../Includes/footer.jsp" />
