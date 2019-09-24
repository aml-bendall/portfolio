<% /**
 * Purpose:Provides an interface for the sales team to view daily activity. "Sales Dashboard"
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
 */ %>
<jsp:include page="../Includes/header.jsp" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="fibreApps.Core.DB_util" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%
	// Set refresh, autoload time as 15 Minutes
response.setIntHeader("Refresh", 900);

//Initiate Variables & Objects
Integer ArrayIndex=0;
String UserList="";
String NovaList="";
Double SalesGoal=0.00;
String sdate="";
String edate="";
DB_util db = new DB_util();

//Get the total number of users setup in the SalesDashUsers table
java.sql.Connection CountCon =  db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

if (CountCon != null) {
java.sql.Statement CountSt = db.dbStatement(CountCon);


String sql = "SELECT count(MomUserID) as User_Count FROM SalesDashUsers";

ResultSet UserCount = db.dbResult(CountSt, sql);
 
//Set Total Number of Users to the ArrayIndex
while (UserCount.next()) {  
	ArrayIndex=Integer.valueOf(UserCount.getString("User_Count"));
}
db.dbClose(CountCon, CountSt, UserCount);
}

//Initiate the arrays that will store information for later calculations using the ArrayIndex based on the total users.
String[][] sales = new String[ArrayIndex][2];
String[][] minutes = new String[ArrayIndex][2];
String[][] revSort = new String[ArrayIndex][2];


String[][] calls = new String[ArrayIndex][2];
String[][] orders = new String[ArrayIndex][2];
String[][] convSort = new String[ArrayIndex][2];

//This is used to translate doubles to currency format
NumberFormat defaultFormat = NumberFormat.getCurrencyInstance();

//Connect to the SalesDashUsers table to get a list of users that are setup. This will be used later in SQL statements.
java.sql.Connection UserCon =  db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

java.sql.Statement UserSt = db.dbStatement(UserCon);

String sql = "SELECT MomUserId,TapItNovaID FROM SalesDashUsers";

	ResultSet Users = db.dbResult(UserSt, sql);

	if (UserCon != null) {

		while (Users.next()) {
			//Create a list of users. Each user has a MoM ID and a Phone ID. The list used depends on the database. Lists will be used in an "where in" SQL statement later.
			if (Users.getRow() == ArrayIndex) {
				UserList = UserList + "'" + Users.getString("MomUserId") + "'";
				NovaList = NovaList + "'" + Users.getString("TapItNovaID") + "'";
			} else {
				UserList = UserList + "'" + Users.getString("MomUserId") + "',";
				NovaList = NovaList + "'" + Users.getString("TapItNovaID") + "',";
			}
		}

		db.dbClose(UserCon, UserSt, Users);
	}
%>




<%
//Get the Sales Goal for the current quarter
Date today= new Date();
Calendar cal = Calendar.getInstance();
cal.setTime(today);
int month = cal.get(Calendar.MONTH);
int quarter = (month/3) + 1;
int totalOutbound=0;
int totalPhone=0;

SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MM/dd/yyyy");

if (request.getParameterMap().containsKey("startDate")) {
	String sconvert = request.getParameter("startDate");

	DateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
	Date date = originalFormat.parse(sconvert);
	String formattedDate = simpleDateFormat.format(date);

	sdate = formattedDate;
} else {
	
	sdate = simpleDateFormat.format(today);
}

if (request.getParameterMap().containsKey("endDate")) {
	String econvert = request.getParameter("endDate");

	DateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
	Date date = originalFormat.parse(econvert);
	String formattedDate = simpleDateFormat.format(date);

	edate = formattedDate;
} else {
	
	edate = simpleDateFormat.format(today);
}


Calendar c1 = Calendar.getInstance();
c1.setTime(simpleDateFormat.parse(sdate));
int w1 = c1.get(Calendar.DAY_OF_WEEK);
c1.add(Calendar.DAY_OF_WEEK, -w1);

Calendar c2 = Calendar.getInstance();
c2.setTime(simpleDateFormat.parse(edate));
int w2 = c2.get(Calendar.DAY_OF_WEEK);
c2.add(Calendar.DAY_OF_WEEK, -w2);

//end Saturday to start Saturday 
long days = (c2.getTimeInMillis()-c1.getTimeInMillis())/(1000*60*60*24);
long daysWithoutWeekendDays = days-(days*2/7);

// Adjust days to add on (w2) and days to subtract (w1) so that Saturday
// and Sunday are not included
if (w1 == Calendar.SUNDAY && w2 != Calendar.SATURDAY) {
    w1 = Calendar.MONDAY;
} else if (w1 == Calendar.SATURDAY && w2 != Calendar.SUNDAY) {
    w1 = Calendar.FRIDAY;
} 

if (w2 == Calendar.SUNDAY) {
    w2 = Calendar.MONDAY;
} else if (w2 == Calendar.SATURDAY) {
    w2 = Calendar.FRIDAY;
}

long workDays=daysWithoutWeekendDays-w1+w2+1;


System.out.println(sdate);
%>

<form style="veritcal-align: center; text-align: center;" method="post"
action="Sales/SalesDashReport.jsp">
	<p>
		From: <input type="date" name="startDate" required> To: <input
			type="date" name="endDate" required>
	</p>
		<input type="submit" value="Submit" name="submit">
</form>

<link rel="stylesheet" href="CSS/SalesDash.css"/>

<h1 style="margin-top:3.5cm;">Sales Dashboard <%=sdate %> to <%=edate %></h1>

<table class="container" id="ExportAll">
	<tr>
		<td>
			<table style="width: 50%; border-spacing: 0px 5px; margin: auto">
				<tr>
					<td class="holder_whole">
						<%
							//Collect the total sales by users. This only searches for those people who are setup in the SalesDashUsers table.
							java.sql.Connection con2 = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

							if (con2 != null) {
								java.sql.Statement s2 = db.dbStatement(con2);

								sql = "SELECT c.sales_id,u.name,sum(ORD_TOTAL)-sum(tb_ship)-sum(tb_tax)-sum(shipping) as REVENUE "
										+ "FROM CMS c " + "INNER JOIN MOMUSER u " + "ON c.sales_id=u.CODE " + "WHERE c.ODR_DATE >= '"
										+ sdate + "' " +  "AND C.ODR_DATE<='" + edate + "' AND c.ordertype != 'web' " + "AND c.ordertype != '3Party' "
										+ "and c.sales_id in (" + UserList + ") " + "and c.ORDER_ST2 != 'QO' "
										+ "AND c.ORDER_ST2 != 'CN' " 
										+ "group by c.sales_id, u.name " + "order by REVENUE desc";
								ResultSet rs2 = db.dbResult(s2, sql);
						%>
						<table class="responstable">
							<tr>
								<th>Sales Rep</th>
								<th>Sales</th>
								<th>Minutes</th>
							</tr>

							<%
								int count = 0;

									while (rs2.next()) {
										int userMinutes = 0;
										int minutesGoal = 0;
										Double moneyGoal = 0.0;

										//Connect to the SalesDashUsers table to get a list of users that are setup. This will be used later in SQL statements.
										java.sql.Connection UserCon2 = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

										java.sql.Statement UserSt2 = db.dbStatement(UserCon2);

										sql = "SELECT MomUserId,TapItNovaID,RepGoal,Minutes FROM SalesDashUsers where MomUserID='"
												+ rs2.getString("sales_id") + "'";

										ResultSet Users2 = db.dbResult(UserSt2, sql);

										if (UserCon2 != null) {

											while (Users2.next()) {

												minutesGoal = Users2.getInt("Minutes")*(int) workDays;
												moneyGoal = Users2.getDouble("RepGoal")*workDays;

												//Get the minutes the users have been on the phone.
												java.sql.Connection con5 = db
														.dbConnect("jdbc:sqlserver://TAPITNOVA\\TAPITNOVADB;databaseName=TapitDbSQL");

												if (con5 != null) {
													java.sql.Statement s5 = db.dbStatement(con5);

													sql = "SELECT c.userid, u.USERFIRSTNAME, u.USERLASTNAME, (SUM(DATEDIFF(second, 0, (convert(varchar(8), c.CallLength,  108))))/60) as Minutes "
															+ "FROM calls c " + "INNER JOIN users u " + "on c.userid=u.userid "
															+ "where calldate>='" + sdate + "' " + "and calldate<='" + edate + "' and c.userid='"
															+ Users2.getString("TapItNovaID") + "' "
															+ "GROUP BY c.UserID, u.UserFirstName, u.UserLastName "
															+ "ORDER BY Minutes desc";

													ResultSet rs5 = db.dbResult(s5, sql);

													while (rs5.next()) {
														//This array is saving information to get data for calculations later.
														minutes[count][0] = rs5.getString("USERFIRSTNAME").trim() + " "
																+ rs5.getString("USERLASTNAME").trim();
														minutes[count][1] = rs5.getString("Minutes");

														totalPhone = totalPhone + rs5.getInt("Minutes");

														userMinutes = Integer.valueOf(rs5.getString("Minutes"));
													}

													db.dbClose(con5, s5, rs5);
												}
											}

											db.dbClose(UserCon2, UserSt2, Users2);
										}
										//Save these values to an array so that we can use them for calculations later.
										sales[count][0] = rs2.getString("name").trim();
										sales[count][1] = rs2.getString("REVENUE");
							%>
							<tr>
							<tr style="font-size: 18px;">

								<%
									Double rev = 0.00;

											//Check to see Revenue has a value
											if (rs2.getString("Revenue") == null) {
												rev = 0.00;
											} else {
												rev = rs2.getDouble("Revenue");
											}
								%>
							
							<tr style="font-size: 18px;">
								<%
									if (rs2.getRow() == 1) {
								%>

								<td><b><%=rs2.getString("name").trim()%></b></td>
								<%
									//Apply colors based on how close we are to the goal
												if (rev < moneyGoal * .25 || rs2.getString("Revenue") == null) {
								%>
								<td bgcolor="#f85032">
									<%
										}

													else if (rev >= moneyGoal * .25 && rev < moneyGoal) {
									%>
								
								<td bgcolor="#FFFF00">
									<%
										}

													else {
									%>
								
								<td bgcolor="#b4e391">
									<%
										}
									%> <b><%=defaultFormat.format(Double.valueOf(rs2.getString("REVENUE")))%>
										/ <%=defaultFormat.format(moneyGoal)%></b>
								</td>
								<%
									} else {
								%>
								<td><%=rs2.getString("name").trim()%></td>
								<%
									//Apply colors based on how close we are to the goal
												if (rev < moneyGoal * .25 || rs2.getString("Revenue") == null) {
								%>
								<td bgcolor="#f85032">
									<%
										}

													else if (rev >= moneyGoal * .25 && rev < moneyGoal) {
									%>
								
								<td bgcolor="#FFFF00">
									<%
										}

													else {
									%>
								
								<td bgcolor="#b4e391">
									<%
										}
									%> <%=defaultFormat.format(Double.valueOf(rs2.getString("REVENUE")))%>
									/ <%=defaultFormat.format(moneyGoal)%></td>
								<%
									}

											//Apply colors based on how close we are to the goal
											if (userMinutes < (minutesGoal * .25) || userMinutes == 0) {
								%>
								<td bgcolor="#f85032">
									<%
										}

												else if (userMinutes >= (minutesGoal * .25) && userMinutes < minutesGoal) {
									%>
								
								<td bgcolor="#FFFF00">
									<%
										}

												else {
									%>
								
								<td bgcolor="#b4e391">
									<%
										}
									%> <%=userMinutes%> / <%=minutesGoal%>
								</td>
								<%
									count++;
										}
										db.dbClose(con2, s2, rs2);
									}
								%>
							
						</table>
					</td>
				</tr>
			</table>
	<tr>
		<td>
			<table style="width: 100%; border-spacing: 0px 5px;">
				<tr>
					<td class="holder">
						<%
							//Get outbound call information from the Phone database.
							java.sql.Connection con3 = db.dbConnect("jdbc:sqlserver://TAPITNOVA\\TAPITNOVADB;databaseName=TapitDbSQL");

							if (con3 != null) {
								java.sql.Statement s3 = db.dbStatement(con3);

								sql = "SELECT c.userid, u.USERFIRSTNAME, u.USERLASTNAME, count(c.CallID) as calls " + "FROM Calls c "
										+ "INNER JOIN users u " + "on c.userid=u.userid " + "where calldate>= '" + sdate + "' "
										+ " and calldate<= '" + edate + "' and CallDirection='2' " + "AND c.userid in (" + NovaList + ") "
										+ "Group By c.userid,u.USERFIRSTNAME, u.UserLastName " + "order by calls desc";

								ResultSet rs3 = db.dbResult(s3, sql);
						%>
						<table class="responstable">
							<tr>
								<th colspan="2">Outbound Calls</th>
							</tr>

							<%
								while (rs3.next()) {
							%>
							<tr>
								<%
									if (rs3.getRow() == 1) {
								%>
								<td><b><%=rs3.getString("USERFIRSTNAME").trim() + " " + rs3.getString("USERLASTNAME").trim()%></b></td>
								<td><b><%=rs3.getString("calls")%></b></td>
								<%
									} else {
								%>
								<td><%=rs3.getString("USERFIRSTNAME").trim() + " " + rs3.getString("USERLASTNAME").trim()%></td>
								<td><%=rs3.getString("calls")%></td>
								<%
									}
								%>
							</tr>
							<%
								}
									db.dbClose(con3, s3, rs3);
								}
							%>

						</table>
					<td class="holder">
						<%
							//Get Total calls from the database.
							java.sql.Connection con4 = db.dbConnect("jdbc:sqlserver://TAPITNOVA\\TAPITNOVADB;databaseName=TapitDbSQL");

							if (con4 != null) {
								java.sql.Statement s4 = db.dbStatement(con4);

								sql = "SELECT c.userid, u.USERFIRSTNAME, u.USERLASTNAME, count(c.CallID) as calls " + "FROM Calls c "
										+ "INNER JOIN users u " + "on c.userid=u.userid " + "where calldate>= '" + sdate + "' "
										+ "and calldate<= '" + edate + "' and c.userid in (" + NovaList + ") " + "Group By c.userid,u.USERFIRSTNAME, u.UserLastName "
										+ "order by calls desc";

								ResultSet rs4 = db.dbResult(s4, sql);
						%>
						<table class="responstable">
							<tr>
								<th colspan="2">Total Calls</th>
							</tr>

							<%
								int count = 0;

									while (rs4.next()) {
										calls[count][0] = rs4.getString("USERFIRSTNAME").trim() + " "
												+ rs4.getString("USERLASTNAME").trim();
										calls[count][1] = rs4.getString("calls");

										totalOutbound = totalOutbound + rs4.getInt("calls");
										count++;
							%>
							<tr>
								<%
									if (rs4.getRow() == 1) {
								%>
								<td><b><%=rs4.getString("USERFIRSTNAME").trim() + " " + rs4.getString("USERLASTNAME").trim()%></b></td>
								<td><b><%=rs4.getString("calls")%></b></td>
								<%
									} else {
								%>
								<td><%=rs4.getString("USERFIRSTNAME").trim() + " " + rs4.getString("USERLASTNAME").trim()%></td>
								<td><%=rs4.getString("calls")%></td>
								<%
									}
								%>
							</tr>

							<%
								}
									db.dbClose(con4, s4, rs4);
								}
							%>

						</table>

					</td>

					<td class="holder">

						<table class="responstable">
							<tr>
								<th colspan="2">Revenue Per Minute</th>

								<%
									//Make calculations to obtain Revenue per minute using arrays we created earlier. 
									//This nested loop searches for name matches in the 1st dimension of the array. This requires the TapItNovaDB and the MoMDB to have the same name value for user name

									for (int i = 0; i < sales.length; i++) {
										for (int j = 0; j < minutes.length; j++) {
											if (sales[i][0] != null && minutes[j][0] != null && sales[i][0].equals(minutes[j][0])) {
												double Mrev = Double.valueOf(sales[i][1]) / Double.valueOf(minutes[j][1]);
												double roundOff = 0;
												roundOff = Math.round(Mrev * 100.0) / 100.0;

												revSort[i][0] = sales[i][0];
												revSort[i][1] = String.valueOf(roundOff);
											}
										}
									}

									//Sort array for highest to lowest
									for (int i = 0; i < revSort.length; i++) {
										for (int j = 0; j < revSort.length; j++) {
											if (revSort[i][1] != null && revSort[j][1] != null
													&& Double.valueOf(revSort[i][1]) > Double.valueOf(revSort[j][1]) && i > j) {
												String moveDownName = revSort[j][0];
												String moveDownDouble = revSort[j][1];
												String moveUpName = revSort[i][0];
												String moveUpDouble = revSort[i][1];

												revSort[j][0] = moveUpName;
												revSort[j][1] = moveUpDouble;
												revSort[i][0] = moveDownName;
												revSort[i][1] = moveDownDouble;

												System.out.println("Going up: " + moveUpDouble);
												System.out.println("Going down: " + moveDownDouble);
											}
											if (revSort[i][1] != null && revSort[j][1] != null && revSort[i][1] != null
													&& Double.valueOf(revSort[i][1]) < Double.valueOf(revSort[j][1]) && i < j) {
												String moveDownName = revSort[j][0];
												String moveDownDouble = revSort[j][1];
												String moveUpName = revSort[i][0];
												String moveUpDouble = revSort[i][1];

												revSort[i][0] = moveDownName;
												revSort[i][1] = moveDownDouble;
												revSort[j][0] = moveUpName;
												revSort[j][1] = moveUpDouble;

												System.out.println("Going up: " + moveUpDouble);
												System.out.println("Going down: " + moveDownDouble);
											}
										}
									}

									//display sorted informaion
									for (int i = 0; i < revSort.length; i++) {
								%>
							
							<tr>
								<%
									if (revSort[i][1] != null && i == 0) {
								%>
								<td><b><%=revSort[i][0]%></b></td>
								<td><b><%=defaultFormat.format(Double.valueOf(revSort[i][1]))%></b></td>
								<%
									} else if (revSort[i][1] == null) {

										} else {
								%>
								<td><%=revSort[i][0]%></td>
								<td><%=defaultFormat.format(Double.valueOf(revSort[i][1]))%></td>
								<%
									}
								%>
							</tr>
							<%
								}
							%>

						</table>
					</td>
				</tr>
			</table>
	<tr>
		<td>
			<table style="width: 100%; border-spacing: 0px 5px;">
				<tr>
					<td class="holder">
						<%
							//Get total number of orders by user
							java.sql.Connection con7 = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

							if (con7 != null) {
								java.sql.Statement s7 = db.dbStatement(con7);

								sql = "select c.USERID, u.NAME, count(c.ORDERNO) as Orders " + "from CMS c " + "INNER JOIN MOMUSER u "
										+ "on c.userid=u.code " + "where ODR_DATE >= '" + sdate + "' " + "and ODR_DATE <= '" + edate + "' AND c.ordertype != 'web' "
										+ "AND c.ordertype != '3Party' " + "AND c.sales_id in (" + UserList + ") "
										+ "AND c.ORDER_ST2 != 'QO' "
									    + "AND c.ORDER_ST2 != 'CN' "
										+ "GROUP BY userid, U.NAME " + "Order By orders desc";

								ResultSet rs7 = db.dbResult(s7, sql);
						%>

						<table class="responstable">
							<tr>
								<th colspan="2">Total Orders</th>
							</tr>

							<%
								int count = 0;

									while (rs7.next()) {

										orders[count][0] = rs7.getString("NAME").trim();
										orders[count][1] = rs7.getString("Orders");

										count++;
							%>
							<tr>
								<%
									if (rs7.getRow() == 1) {
								%>
								<td><b><%=rs7.getString("NAME").trim()%></b></td>
								<td><b><%=rs7.getString("Orders")%></b></td>
								<%
									} else {
								%>
								<td><%=rs7.getString("NAME").trim()%></td>
								<td><%=rs7.getString("Orders")%></td>
								<%
									}
								%>
							</tr>

							<%
								}
									db.dbClose(con7, s7, rs7);
								}
							%>

						</table>


					</td>
					<td class="holder">
						<%
							//Get total number of new customers by users
							java.sql.Connection con8 = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=MailOrderManager");

							if (con8 != null) {
								java.sql.Statement s8 = db.dbStatement(con8);

								sql = "SELECT o.USERID, u.[NAME], count(c.CUSTNUM) AS NEW_CUST " + "FROM CUST c " + "INNER JOIN CMS o "
										+ "LEFT OUTER JOIN MOMUSER u " + "ON u.CODE=o.USERID " + "ON o.CUSTNUM=c.CUSTNUM "
										+ "WHERE C.ENTRYDATE>='" + sdate + "' " + "and C.ENTRYDATE<='" + edate + "' AND o.ordertype != 'web' "
										+ "AND o.ordertype != '3Party' " + "and o.ORDER_ST2 != 'QO' "
										+ "AND o.ORDER_ST2 != 'CN' "
										+ "and (o.USERID='MB' or o.USERID='GM' or o.USERID='BC') " + "GROUP BY o.USERID, u.[NAME] "
										+ "ORDER BY NEW_CUST DESC";

								ResultSet rs8 = db.dbResult(s8, sql);
						%>
						<table class="responstable">
							<tr>
								<th colspan="2">New Customers</th>
							</tr>

							<%
								while (rs8.next()) {
							%>
							<tr>
								<%
									if (rs8.getRow() == 1) {
								%>
								<td><b><%=rs8.getString("NAME")%></b></td>
								<td><b><%=rs8.getString("NEW_CUST")%></b></td>
								<%
									} else {
								%>
								<td><%=rs8.getString("NAME")%></td>
								<td><%=rs8.getString("NEW_CUST")%></td>
								<%
									}
								%>
							</tr>

							<%
								}
									db.dbClose(con8, s8, rs8);
								}
							%>

						</table>

					</td>
					<td class="holder">

						<table class="responstable">
							<tr>
								<th colspan="2">Conversion Rate</th>

								<%
									//Make calculations to obtain Revenue per minute using arrays we created earlier. 
									//This nested loop searches for name matches in the 1st dimension of the array. This requires the TapItNovaDB and the MoMDB to have the same name value
									for (int i = 0; i < orders.length; i++) {
										for (int j = 0; j < calls.length; j++) {
											if (orders[i][0] != null && calls[j][0] != null && orders[i][0].equals(calls[j][0])) {
												double CR = Double.valueOf(orders[i][1]) / Double.valueOf(calls[j][1]);
												double roundOff = Math.round(CR * 100.0);

												convSort[i][0] = orders[i][0];
												convSort[i][1] = String.valueOf(roundOff);
											}
										}
									}

									//Sort array for highest to lowest
									for (int i = 0; i < convSort.length; i++) {
										for (int j = 0; j < convSort.length; j++) {
											if (convSort[i][1] != null && convSort[j][1] != null && convSort[i][1] != null
													&& Double.valueOf(convSort[i][1]) > Double.valueOf(convSort[j][1]) && i > j) {
												String moveDownName = convSort[j][0];
												String moveDownDouble = convSort[j][1];
												String moveUpName = convSort[i][0];
												String moveUpDouble = convSort[i][1];

												convSort[j][0] = moveUpName;
												convSort[j][1] = moveUpDouble;
												convSort[i][0] = moveDownName;
												convSort[i][1] = moveDownDouble;

												System.out.println("Going up: " + moveUpDouble);
												System.out.println("Going down: " + moveDownDouble);
											}
											if (convSort[i][1] != null && convSort[j][1] != null && convSort[i][1] != null
													&& Double.valueOf(convSort[i][1]) < Double.valueOf(convSort[j][1]) && i < j) {
												String moveUpName = convSort[j][0];
												String moveUpDouble = convSort[j][1];
												String moveDownName = convSort[i][0];
												String moveDownDouble = convSort[i][1];

												convSort[i][0] = moveUpName;
												convSort[i][1] = moveUpDouble;
												convSort[j][0] = moveDownName;
												convSort[j][1] = moveDownDouble;

												System.out.println("Going up: " + moveUpDouble);
												System.out.println("Going down: " + moveDownDouble);
											}
										}
									}

									//display sorted information
									for (int i = 0; i < convSort.length; i++) {
								%>
							
							<tr>
								<%
									if (convSort[i][1] != null && i == 0) {
								%>
								<td><b><%=convSort[i][0]%></b></td>
								<td><b><%=convSort[i][1] + "%"%></b></td>
								<%
									} else if (convSort[i][1] == null) {

										} else {
								%>
								<td><%=convSort[i][0]%></td>
								<td><%=convSort[i][1] + "%"%></td>
								<%
									}
								%>
							</tr>


							<%
								}
							%>

						</table>
			</table>
		</td>
	</tr>
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


<input style="margin-top: 10em;" type="button"
	onclick="tableToExcel('ExportAll')" value="Export to Excel">

<jsp:include page="../Includes/footer.jsp" />