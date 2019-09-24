<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="fibreApps.Core.DB_util" %>
<%@ page import="fibreApps.Warehouse.CutSheetHelper" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%
DB_util db = new DB_util();
String sql;
String actionType="";
String pin;
String action="";
String msg="";
String initials="";
int error=0;
boolean exists=false;
boolean timeExists=false;
String name="";


//Check the URL params. Based on the Paramters provided, and if the pin is accurate, log the shipper in or out of shipping.
Enumeration<String> params = request.getParameterNames();
while (params.hasMoreElements()) {
	String paramName = params.nextElement();
	System.out.println("Parameter Name - " + paramName + ", Value - " + request.getParameter(paramName));
}

if(request.getParameter("pin")!=null) {
	System.out.println("IM HERE pin");
	pin = request.getParameter("pin");
	 try {
	java.sql.Connection pinCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
	
	sql="Select * From warehousePins where pin='" + pin + "'";
	java.sql.Statement pinSt = db.dbStatement(pinCon);
	
	ResultSet pins = db.dbResult(pinSt, sql);
	
	while (pins.next()) {
		exists = true;
		name = pins.getString("names").trim();
		initials=pins.getString("initials");
	}
	db.dbClose(pinCon, pinSt, pins);
	}catch(SQLException e) {
		e.printStackTrace();
	} 
	 
	 try {
	java.sql.Connection pinCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");
	
	sql="Select * From shippingTime where userName='" + name + "' and progress=0";
	java.sql.Statement dupSt = db.dbStatement(pinCon);
	
	ResultSet dups = db.dbResult(dupSt, sql);
	
	while (dups.next()) {
		timeExists = true;
	}
	db.dbClose(pinCon, dupSt, dups);
	}catch(SQLException e) {
		e.printStackTrace();
	} 
	 
	 action=request.getParameter("FormType");
	 
	 if(exists && !timeExists && action.toLowerCase().equals("begin")) {
		 System.out.println("IM HERE BEGIN");
			 try {
					java.sql.Connection insCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

						PreparedStatement insSt = insCon
								.prepareStatement("INSERT INTO shippingTime (userName,beginTime,progress,initials) values (?,?,?,?)");
						insSt.setString(1, name);
						
						Date startDate = new Date();
						Calendar c = Calendar.getInstance();
						c.setTime(startDate);
						
						java.sql.Timestamp timestamp = new Timestamp(c.getTimeInMillis());			
						insSt.setTimestamp(2,  timestamp);
						
						insSt.setInt(3, 0);
						
						insSt.setString(4, initials);
						insSt.executeUpdate();

						insCon.close();
						
						msg="1";
				} catch(SQLException e) {
					e.printStackTrace();
				}
	 } else {
		 if(!exists) {
			 error=1;
		 } else if (timeExists) {
			 error=2;
		 }
	 }
	 
if(exists && timeExists && action.toLowerCase().equals("end"))	 {
	 System.out.println("IM HERE END");
		 try {
				java.sql.Connection endCon = db.dbConnect("jdbc:sqlserver://FIBRE-SQL;databaseName=FibreApps");

				PreparedStatement endSt = endCon
						.prepareStatement("Update shippingTime set endTime = ?, progress=1 WHERE userName='"+ name +"' and progress=0");
				
				Date startDate = new Date();
				Calendar c = Calendar.getInstance();
				c.setTime(startDate);
				
				java.sql.Timestamp timestamp = new Timestamp(c.getTimeInMillis());			
				endSt.setTimestamp(1,  timestamp);
				
				endSt.executeUpdate();

				endSt.close();
				
				error=0;
				
				msg="2";
				
				}catch(SQLException e) {
					e.printStackTrace();
				}
	 } else if (!exists && msg.equals("")) {
		error=1;
	 }
	 else if (!timeExists && msg.equals("")) {
		 error=3;
	 }
		
}

System.out.println(exists);
System.out.println(timeExists);



if(error!=0) {
	response.sendRedirect("ShippingDash.jsp?error="+error);
} else {
response.sendRedirect("ShippingDash.jsp?msg="+msg);
}



%>

