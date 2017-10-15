<%@ page language="java" contentType="text/html; charset=EUC-KR"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>



<html>
<head>
    <title>LeaveOut</title>
	
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	
	
	<meta name="generator" content="Bootply" />
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">

	<!-- Bootstrap Core CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet">
	<!--[if lt IE 9]>
		<script src="//html5shim.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->
		
		
	<style>
	  body {
		padding-top : 40px;
      }
	  #map {
        height: 100%;
      }
     </style>
</head>

<body>

	<!-- session check -->
	<%
		String userNumString = request.getParameter("user_num");
		String userNameString = "null";
		
		Connection conn=null;
		PreparedStatement pstmt=null;
		ResultSet rs=null;
	
		try {
			Context init = new InitialContext();
			DataSource ds = (DataSource) init.lookup("java:comp/env/jdbc/mysql");
			conn = ds.getConnection();
  		
			pstmt=conn.prepareStatement("SELECT * FROM user WHERE user_num=?");
			pstmt.setString(1,userNumString);
			rs=pstmt.executeQuery();
  		
			if(rs.next()){
				//sesson-OK
				userNameString = rs.getString("name");
			}
			else {
				out.println("<script>");
				out.println("alert('�������� �ʴ� ȸ���Դϴ�.');");
				out.println("location.href='index.jsp'");
				out.println("</script>");
			}
		}catch(Exception e){
			e.printStackTrace();
		}		
	%>
	
	<!-- create Map marker info -->
	<%
	out.println("<script>");
	out.println("var checklocation = [");
	
	PreparedStatement checkps=null;
	ResultSet checkrs=null;
	int count = 0;
	int checksize;
	
	try {		
	checkps=conn.prepareStatement("select * FROM checks where user_num=?");
	checkps.setString(1,userNumString);
	checkrs=checkps.executeQuery();
	
	while(checkrs.next()){
		if(checkrs.getString("check_image") != "null") {	
			if(count != 0){
				out.print(",");
			}
			
			out.print("{lat: " + checkrs.getString("chk_x") +", lng: " + checkrs.getString("chk_y") + "}");
			count++;
		}
	}
								
	}catch(Exception e){
		e.printStackTrace();
	}
	
	out.println("];");
	out.println("</script>");
	%>
	
	<!-- script references -->
	<script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
	<script src="js/scripts.js"></script>
	<script src="js/bootstrap.min.js"></script>
	<script src="jquery-bootstrap-modal-steps.js"></script>
	<script type="text/javascript">
	// iframe resize
	function autoResize(i)
	{
		var iframeHeight=
		(i).contentWindow.document.body.scrollHeight;
		(i).height=iframeHeight+20;
		var iframeWidth=
		(i).contentWindow.document.body.scrollWidth;
		(i).width=iframeWidth+20;
	}
</script>

		<script language="javascript">
			var count = 1;
 			var addCount;
 
			//���߰�
			function addInputBox() {
 				for(var i=1; i<=count; i++) {
  					if(!document.getElementsByName("test"+i)[0]) {
  						addCount = i;
   						break;
  					}
  					else addCount = count;
 				}
				var addStr = "<tr><td><input type=checkbox name=checkList value="+addCount+">"+addCount+"��° ����</td><td><input type=file name=uploadImgFile"+addCount+" id=uploadImgFile"+addCount+"></td></tr>";
 				var table = document.getElementById("dynamic_table");
 				var newRow = table.insertRow()
 				var newCell = newRow.insertCell();
 				newCell.innerHTML = addStr;
 				count++;
				}
 
				//�����
				function subtractInputBox() {
 				var table = document.getElementById("dynamic_table");
 				//var max = document.gForm.checkList.length;
			 	//alert(max);
 				var rows = dynamic_table.rows.length;
 				var chk = 0;
 				if(rows > 1){
  				for (var i=0; i<document.gForm.checkList.length; i++) {
  					if (document.gForm.checkList[i].checked == true) {
    					table.deleteRow(i);
    					i--;
    					count--;
    					chk++;
   					}
  				}
  				if(chk <= 0){
   					alert("������ ���� üũ�� �ּ���.");
  				}
   			}else{
    			alert("���̻� ������ �� �����ϴ�.");
  				}
		}
 
			function submitbutton() {
 				var gform = document.gForm;
 				gform.count.value = eval(count);
 				//alert(count);
 				gForm.submit();
 				return;
			}
		</script>
		
		
    <% String s = null;%>
	<!-- contents -->
	
	<div class="col-md-8">
	 <h2> <i class='glyphicon glyphicon-file'></i> <%=userNameString%>���� �Խñ��� �ۼ��մϴ�.</h2>
	 <div id="map">
	 <script>
      // Note: This example requires that you consent to location sharing when
      // prompted by your browser. If you see the error "The Geolocation service
      // failed.", it means you probably did not give permission for the browser to
      // locate you.
      function initMap() {
		  var setloc = {lat: 36, lng: 128};
		  var map = new google.maps.Map(document.getElementById('map'), {
          zoom: 8,
          center: setloc
        });
	
        // Create an array of alphabetical characters used to label the markers.
        //var labels = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        var infowindow;
        
        var markers = checklocation.map(function(location, i) {
          var marker = new google.maps.Marker({
            position: location
            //label: labels[i % labels.length]
          });
          
		  google.maps.event.addListener(marker, 'click', function() {
			map.setZoom(16);
			map.setCenter(marker.getPosition());
			
			var geocoder = new google.maps.Geocoder();
			var mylatlng = new google.maps.LatLng(marker.getPosition().lat(), marker.getPosition().lng());
			infowindow = new google.maps.InfoWindow();
			
			geocoder.geocode({'latLng' : mylatlng}, function(results, status) {
				if (status == google.maps.GeocoderStatus.OK) {
					if (results[1]) {
						infowindow.setContent(results[0].formatted_address);
					}
				} else {
					alert("Geocoder failed due to: " + status);
				}
			});
			
			infowindow.open(map, marker);
		  });
		  
		  return marker;
        });
        
        // Add a marker clusterer to manage the markers.
        var markerCluster = new MarkerClusterer(map, markers, 
            {imagePath: 'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m', zoomOnClick: false}
        );
	}
    </script>
	 </div>
	</div>
	 
	 <!-- Google Map Script -->
	<script async defer
        src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDJ0-6wfd7a6AVfTR2HdzA3QQtlXwx51S4&callback=initMap">
    </script>
	<script src="https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/markerclusterer.js"></script>
	 
	 
	 <script>
   function contentsubmit() {
      var selectedcheck = $("#uploadContent").val();
         alert(selectedcheck);
         
       document.href("postingProess.jsp");
   }
   </script>
	 <div class="col-md-4" style="padding-top : 40px">
	 <br>
		<form name="gForm" action="postingProcess.jsp" method="post" enctype="multipart/form-data" accept-charset="euc-kr">
		<input type="hidden" name="user_num" value="<%=userNumString%>"></input> 
  			<div class="form-group">
    			<label for="selectCheck">
    			<i class='glyphicon glyphicon-exclamation-sign'></i> <%=userNameString%>���� üũ ����Ʈ�Դϴ�.<br>
    			�� �Խÿ� ����� üũ�� ����ּ���.s
    			</label><br><br>
    			<div class="radio" style="padding-left : 30px">
    				<script type="text/javascript">
							var c = 0;
							var conAddr = [3];
							function geocode(checkloc) {
								var geocoder = new google.maps.Geocoder();
								//geocoder�� ����ϱ� ���� ������ �����ϰ� ���� �� api���� ��ü�� ��� �ɴϴ�.  
								
								for(var i = 0; i < checkloc.length; i++) {
								var mylatlng = new google.maps.LatLng(checkloc[i].lat, checkloc[i].lng);
								//������ �浵�� ���� �ʽ��� geocoder���� ����� �������� ��ȯ�մϴ�.
								geocoder.geocode({'latLng' : mylatlng}, function(results, status) {
									if (status == google.maps.GeocoderStatus.OK) {
										if (results[1]) {
											c++;
											$("#chline"+c).text(" " + results[0].formatted_address);
											$("#checkLocation"+c).val(results[0].formatted_address);
											conAddr.push(results[0].formatted_address);
										}
									} else {
										alert("Geocoder failed due to: " + status);
									}
								});
								}
							}
						</script>
    			
   			 		<input type="radio" name="selectCheck" value="1"> <i id='chline1' class='glyphicon glyphicon-bookmark'></i></input><br><br>
   			 		<input type="radio" name="selectCheck" value="2"> <i id='chline2' class='glyphicon glyphicon-bookmark'></i></input><br><br>
   			 		<input type="radio" name="selectCheck" value="3"> <i id='chline3' class='glyphicon glyphicon-bookmark'></i></input><br><br>
   			 	</div>
  			</div>
  			<br><br>
  			
  			<input type="hidden" name="checkLocation1" id="checkLocation1" value=""></input>
  			<input type="hidden" name="checkLocation2" id="checkLocation2" value=""></input>
  			<input type="hidden" name="checkLocation3" id="checkLocation3" value=""></input>

 			<div class="form-group">
   				<label for="uploadImgfile">
   				<i class='glyphicon glyphicon-picture'></i> �ش� üũ�� �ø��� ������ ������ �ּ���.<br>
   				</label><br>
   				<input type="button" value="���� �߰�" onclick="javascript:addInputBox();">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" value="���� ����" onclick="javascript:subtractInputBox();"><br>
    			<p class="help-block">���� ������, ������ ������ üũ�Ͻ� �� ������ �����ּ��� ! </p><br>
    			<table cellpadding=0 cellspacing=0 id="dynamic_table" border="1">
				</table>
    			<p class="help-block">���� ���ϸ� �÷��ּ��� ! </p>
  			</div>
  			<br><br>
  			<div class="form-group">
				<label for="uploadContent">
				<i class='glyphicon glyphicon-font'></i> �� ������ �Է����ּ���.<br>
				</label><br><br>
				<textarea class="form-control" id="uploadContent" name="uploadContent" rows="5" placeholder="�� ������ �Է��� �ּ���."></textarea>
			</div>
			<div class="col-md-8"></div>
			<div class="col-md-4">
				<button type="button" class="btn btn-default" onclick="history.back(-1);">�ڷ�</button>
				&nbsp;&nbsp;&nbsp;
				<input type="hidden" name="count">
				<input type="button" class="btn btn-default" value="����" onclick="javascript:submitbutton();">
				
			</div>
			
		</form>
	 </div>  
	
	<%@ include file="./navbarCore.jsp"%>
	
	<script type="text/javascript">
	$(window).load(function() {
		geocode(checklocation);
	})
	</script>
	
	</script>
	</body>
</html>