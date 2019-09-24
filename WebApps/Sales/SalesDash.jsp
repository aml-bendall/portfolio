
<%@page import="fibreApps.Core.apiTest"%>
<%
	/**
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
	*/
%>
<jsp:include page="../Includes/header.jsp" />

<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="fibreApps.Core.DB_util"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="fibreApps.Core.apiTest"%>
<%@ page import="javax.xml.parsers.DocumentBuilder"%>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory"%>
<%@ page import="org.w3c.dom.Document"%>
<%@ page import="org.w3c.dom.Node"%>
<%@ page import="org.w3c.dom.NodeList"%>
<%@ page import="org.w3c.dom.Element"%>
<%

	apiTest.main();
	
	// Set refresh, autoload time as 15 Minutes
	response.setIntHeader("Refresh", 900);

	//Initiate Variables & Objects
	Integer ArrayIndex = 0;
	String UserList = "";
	String NovaList = "";
	Double SalesGoal = 0.00;
	String sdate = "";
	DB_util db = new DB_util();

	//Get the total number of users setup in the SalesDashUsers table
	java.sql.Connection CountCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

	if (CountCon != null) {
		java.sql.Statement CountSt = db.dbStatement(CountCon);

		String sql = "SELECT count(MomUserID) as User_Count FROM SalesDashUsers";

		ResultSet UserCount = db.dbResult(CountSt, sql);

		//Set Total Number of Users to the ArrayIndex
		while (UserCount.next()) {
			ArrayIndex = Integer.valueOf(UserCount.getString("User_Count"));
		}
		db.dbClose(CountCon, CountSt, UserCount);
	}
	
	//Initiate the arrays that will store information for later calculations using the ArrayIndex based on the total users.
	String[][] sales = new String[ArrayIndex][3];
	String[][] minutes = new String[ArrayIndex][2];
	String[][] revSort = new String[ArrayIndex][3];
	String[][] calls = new String[ArrayIndex][2];
	String[][] convSort = new String[ArrayIndex][3];
	
	File fXmlFile = new File("\\\\FIBRE-APP\\FibreApps\\dailyRepSales.xml");
	DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
	DocumentBuilder dBuilder;
	dBuilder = dbFactory.newDocumentBuilder();


	Document doc;

	doc = dBuilder.parse(fXmlFile);


	for (int i = 0; i < ArrayIndex; i++) {
		int rep;
		rep = i+1;
		NodeList nList = doc.getElementsByTagName("ns1:rep"+rep);
	
			for (int x = 0; x < nList.getLength(); x++) {
						
				Node nNode = nList.item(x);
				Element eElement = (Element) nNode;
				
				System.out.println(eElement.getTextContent());
				sales[i][x] = eElement.getTextContent().trim();
			System.out.println("Entry "+i+ " column "+x+" is "+sales[i][x] );
			}

	}
	
	//Sort array for highest to lowest
	for (int i = 0; i < sales.length; i++) {
		for (int j = 0; j < sales.length; j++) {
			if (sales[i][1] != null && sales[j][1] != null
					&& Double.valueOf(sales[i][1]) > Double.valueOf(sales[j][1]) && i > j) {
				String moveDownName = sales[j][0];
				String moveDownDouble = sales[j][1];
				String moveDownMinutes = sales[j][2];
				String moveUpName = sales[i][0];
				String moveUpDouble = sales[i][1];
				String moveUpMinutes = sales[i][2];
				
				sales[j][0] = moveUpName;
				sales[j][1] = moveUpDouble;
				sales[j][2] = moveUpMinutes;
				sales[i][0] = moveDownName;
				sales[i][1] = moveDownDouble;
				sales[i][2] = moveDownMinutes;


				System.out.println("Going up: " + moveUpDouble);
				System.out.println("Going down: " + moveDownDouble);
			}
			if (sales[i][1] != null && sales[j][1] != null && sales[i][1] != null
					&& Double.valueOf(sales[i][1]) < Double.valueOf(sales[j][1]) && i < j) {
				String moveDownName = sales[j][0];
				String moveDownDouble = sales[j][1];
				String moveDownMinutes = sales[j][2];
				String moveUpName = sales[i][0];
				String moveUpDouble = sales[i][1];
				String moveUpMinutes = sales[i][2];

				sales[i][0] = moveDownName;
				sales[i][1] = moveDownDouble;
				sales[i][2] = moveDownMinutes;
				sales[j][0] = moveUpName;
				sales[j][1] = moveUpDouble;
				sales[j][2] = moveUpMinutes;

				System.out.println("Going up: " + moveUpDouble);
				System.out.println("Going down: " + moveDownDouble);
			}
		}
	}

	//This is used to translate doubles to currency format
	NumberFormat defaultFormat = NumberFormat.getCurrencyInstance();

	//Connect to the SalesDashUsers table to get a list of users that are setup. This will be used later in SQL statements.
	java.sql.Connection UserCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

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

	//Get the Sales Goal for the current quarter
	Date today = new Date();
	Calendar cal = Calendar.getInstance();
	cal.setTime(today);
	int month = cal.get(Calendar.MONTH);
	int quarter = (month / 3) + 1;
	int totalOutbound = 0;
	int totalPhone = 0;

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
	System.out.println(sdate);
%>

<form style="veritcal-align: center; text-align: center;" method="post"
	action="Sales/SalesDash.jsp">
	<p>
		Select a date: <input type="date" name="startDate"> <input
			type="submit" value="Submit" name="submit">
	</p>



</form>

		<div class="container2">
			<div class="image-slider-wrapper">
				<ul id="image_slider">
			<li><img src="Includes/Images/June-2018-Vacuum-Pumps.jpg"></li>
            <li><img src="Includes/Images/Instrumentation-Reminder.jpg"></li>
            <li><img src="Includes/Images/May-2018-Infusion-Epoxy-Resin.jpg"></li>
            <li><img src="Includes/Images/RAL-Colors-ChromaGlast-Ready-to-Spray-Kits.jpg"></li>
				</ul>			
				<div class="pager">
				</div>
			</div>
		</div>

<link rel="stylesheet" href="CSS/SalesDash.css" />

<h1 style="margin-top: 3.5cm;">
	Sales Dashboard
	<%=sdate%></h1>


<table class="container" id="ExportAll">
	<tr>
		<td>
			<table style="width: 50%; border-spacing: 0px 5px; margin: auto">
				<tr>
					<td class="holder_whole">
						<table class="responstable">
							<tr>
								<th>Sales Rep</th>
								<th>Sales</th>
								<th>Minutes</th>
							</tr>

							<%
							for (int repCount = 0; repCount < ArrayIndex; repCount++) {
										int userMinutes = 0;
										int minutesGoal = 0;
										Double moneyGoal = 0.0;							

										//Connect to the SalesDashUsers table to get a list of users that are setup. This will be used later in SQL statements.
										java.sql.Connection UserCon2 = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

										java.sql.Statement UserSt2 = db.dbStatement(UserCon2);

										sql = "SELECT MomUserId,TapItNovaID,RepGoal,Minutes FROM SalesDashUsers where MomUserID='"
												+ sales[repCount][0] + "'";

										ResultSet Users2 = db.dbResult(UserSt2, sql);

										if (UserCon2 != null) {

											while (Users2.next()) {

												minutesGoal = Users2.getInt("Minutes");
												moneyGoal = Users2.getDouble("RepGoal");

												//Get the minutes the users have been on the phone.
												java.sql.Connection con5 = db
														.dbConnect("jdbc:sqlserver://TAPITNOVA\\TAPITNOVADB;databaseName=TapitDbSQL");

												if (con5 != null) {
													java.sql.Statement s5 = db.dbStatement(con5);

													sql = "SELECT c.userid, u.USERFIRSTNAME, u.USERLASTNAME,u.userrest1, (SUM(DATEDIFF(second, 0, (convert(varchar(8), c.CallLength,  108))))/60) as Minutes "
															+ "FROM calls c " + "INNER JOIN users u " + "on c.userid=u.userid "
															+ "where calldate='" + sdate + "' " + "and c.userid='"
															+ Users2.getString("TapItNovaID") + "' "
															+ "GROUP BY c.UserID, u.UserFirstName, u.UserLastName,u.userrest1 "
															+ "ORDER BY Minutes desc";

													ResultSet rs5 = db.dbResult(s5, sql);

													while (rs5.next()) {
														//This array is saving information to get data for calculations later.
														minutes[repCount][0] = rs5.getString("userrest1").trim();
														minutes[repCount][1] = rs5.getString("Minutes");

														totalPhone = totalPhone + rs5.getInt("Minutes");

														userMinutes = Integer.valueOf(rs5.getString("Minutes"));
													}

													db.dbClose(con5, s5, rs5);
												}
											}

											db.dbClose(UserCon2, UserSt2, Users2);
										}

							%>
							<tr>
							<tr style="font-size: 18px;">

								<%
									Double rev = 0.00;
									System.out.println("Rep Count: "+repCount);
											//Check to see Revenue has a value
									
									if(sales[repCount][1] != null) {
										rev = Double.valueOf(sales[repCount][1]);
									}
									%>
							
							<tr style="font-size: 18px;">
								<%
									if (repCount== 0) {
								%>

								<td><b><%=sales[repCount][0]%></b></td>
								<%
									//Apply colors based on how close we are to the goal
												if (rev < moneyGoal * .25) {
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
									%> <b><%=defaultFormat.format(Double.valueOf(rev))%>
										/ <%=defaultFormat.format(moneyGoal)%></b>
								</td>
								<%
									} else {
								%>
								<td><%=sales[repCount][0]%></td>
								<%
									//Apply colors based on how close we are to the goal
												if (rev < moneyGoal * .25) {
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
									%> <%=defaultFormat.format(Double.valueOf(rev))%>
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
										+ "INNER JOIN users u " + "on c.userid=u.userid " + "where calldate= '" + sdate + "' "
										+ "and CallDirection='2' " + "AND c.userid in (" + NovaList + ") "
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

								sql = "SELECT c.userid, u.USERFIRSTNAME, u.USERLASTNAME, count(c.CallID) as calls,u.userrest1 " + "FROM Calls c "
										+ "INNER JOIN users u " + "on c.userid=u.userid " + "where calldate= '" + sdate + "' "
										+ "and c.userid in (" + NovaList + ") " + "Group By c.userid,u.USERFIRSTNAME, u.UserLastName,u.userrest1 "
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
										calls[count][0] = rs4.getString("userrest1").trim();
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
											System.out.println("Sales: "+sales[i][0]);
											System.out.println("Minutes: "+calls[j][0]);
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
						<table class="responstable">
							<tr>
								<th colspan="2">Total Orders</th>
							</tr>
					<%
					for (int i = 0; i < ArrayIndex; i++) {
						%>
						<tr>
						<% 
						if(sales[i][0]!=null) {
						%>
							<td><b><%=sales[i][0].trim()%></b></td>
						<%	
						} else {
							%>
							<td><b></b></td>
							<%	
						}
					%>
						
						<%
						if(sales[i][2]!=null) {
						%>
							<td><b><%=sales[i][2].trim()%></b></td>
						<%	
						} else {
							%>
							<td><b></b></td>
							<%	
						}
					%>
						</tr>
 <%}%>
						</table>


					</td>
					<td class="holder">
						<table class="responstable">
							<tr>
								<th colspan="2">Placeholder</th>
							</tr>

						</table>

					</td>
					<td class="holder">

						<table class="responstable">
							<tr>
								<th colspan="2">Conversion Rate</th>

								<%
									//Make calculations to obtain Revenue per minute using arrays we created earlier. 
									//This nested loop searches for name matches in the 1st dimension of the array. This requires the TapItNovaDB and the MoMDB to have the same name value
									System.out.println("Sales Length :"+sales.length);
									System.out.println("Calls Length :"+calls.length);
								
								for (int i = 0; i < sales.length; i++) {
										for (int j = 0; j < calls.length; j++) {
											if (calls[j][0] != null && sales[i][0].equals(calls[j][0])) {
												double CR = Double.valueOf(sales[i][2]) / Double.valueOf(calls[j][1]);
												double roundOff = Math.round(CR * 100.0);

												convSort[i][0] = sales[i][0];
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
												String moveDownMinutes = convSort[j][2];
												String moveUpName = convSort[i][0];
												String moveUpDouble = convSort[i][1];
												String moveUpMinutes = convSort[j][2];
												
												convSort[j][0] = moveUpName;
												convSort[j][1] = moveUpDouble;
												convSort[j][1] = moveUpMinutes;
												convSort[i][0] = moveDownName;
												convSort[i][1] = moveDownDouble;
												convSort[i][1] = moveDownMinutes;
												

												System.out.println("Going up: " + moveUpDouble);
												System.out.println("Going down: " + moveDownDouble);
											}
											if (convSort[i][1] != null && convSort[j][1] != null && convSort[i][1] != null
													&& Double.valueOf(convSort[i][1]) < Double.valueOf(convSort[j][1]) && i < j) {
												String moveUpName = convSort[j][0];
												String moveUpDouble = convSort[j][1];
												String moveUpMinutes = convSort[j][2];
												String moveDownName = convSort[i][0];
												String moveDownDouble = convSort[i][1];
												String moveDownMinutes = convSort[i][2];

												convSort[i][0] = moveUpName;
												convSort[i][1] = moveUpDouble;
												convSort[i][2] = moveUpMinutes;
												convSort[j][0] = moveDownName;
												convSort[j][1] = moveDownDouble;
												convSort[j][2] = moveDownMinutes;

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
	var y = document.getElementsByClassName('totalPhone');
	for (i = 0; i < y.length; i++) {
		y[i].innerHTML =
<%=totalPhone%>
	+ ' Minutes';
		if (
<%=totalPhone%>
	< 180) {
			y[i].bgColor = "#f85032"
		} else if (
<%=totalPhone%>
	>= 180 &&
<%=totalPhone%>
	< 720) {
			y[i].bgColor = "#FFFF00"
		} else {
			y[i].bgColor = "#b4e391"
		}
	}

	var x = document.getElementsByClassName('totalOutbound');
	for (i = 0; i < x.length; i++) {
		x[i].innerHTML =
<%=totalOutbound%>
	+ ' Calls';
		if (
<%=totalOutbound%>
	< 38) {
			x[i].bgColor = "#f85032"
		} else if (
<%=totalOutbound%>
	>= 38 &&
	<%=totalOutbound%>
	< 150) {
			x[i].bgColor = "#FFFF00"
		} else {
			x[i].bgColor = "#b4e391"
		}
	}

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
	
	var ul;
	var li_items; 
	var li_number;
	var image_number = 0;
	var slider_width = 0;
	var image_width;
	var current = 0;
	function init(){	
		ul = document.getElementById('image_slider');
		li_items = ul.children;
		li_number = li_items.length;
		for (i = 0; i < li_number; i++){
			// nodeType == 1 means the node is an element.
			// in this way it's a cross-browser way.
			//if (li_items[i].nodeType == 1){
				//clietWidth and width???
				image_width = li_items[i].childNodes[0].clientWidth;
				slider_width += image_width;
				image_number++;
		}
		
		ul.style.width = parseInt(slider_width) + 'px';
		slider(ul);
	}

	function slider(){		
			animate({
				delay:17,
				duration: 12000,
				delta:function(p){return Math.max(0, -1 + 2 * p)},
				step:function(delta){
						ul.style.left = '-' + parseInt(current * image_width + delta * image_width) + 'px';
					},
				callback:function(){
					current++;
					if(current < li_number-1){
						slider();
					}
					else{
						var left = (li_number - 1) * image_width;					
						setTimeout(function(){goBack(left)},12000); 				
						setTimeout(slider, 12000);
					}
				}
			});
	}
	function goBack(left_limits){
		current = 0;	
		setInterval(function(){
			if(left_limits >= 0){
				ul.style.left = '-' + parseInt(left_limits) + 'px';
				left_limits -= image_width / 10;
			}	
		}, 17);
	}
	function animate(opts){
		var start = new Date;
		var id = setInterval(function(){
			var timePassed = new Date - start;
			var progress = timePassed / opts.duration
			if(progress > 1){
				progress = 1;
			}
			var delta = opts.delta(progress);
			opts.step(delta);
			if (progress == 1){
				clearInterval(id);
				opts.callback();
			}
		}, opts.dalay || 17);
	}
	window.onload = init;

</script>


<input style="margin-top: 10em;" type="button"
	onclick="tableToExcel('ExportAll')" value="Export to Excel">

<jsp:include page="../Includes/footer.jsp" />