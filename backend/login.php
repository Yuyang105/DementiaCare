<?php
if(isset($_POST['email'])) {

  $con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
  if (!$con) {
      die('Could not connect: ' . mysql_error());
  }
  mysql_select_db("PH611260_dementiacare");
  $sql = "SELECT Email FROM Users WHERE Email = '$_POST[email]' and Password = '$_POST[password]'";
  $result = mysql_query($sql, $con);
  $num = mysql_num_rows($result);

  if($num) {   //logged in

    $sql = "SELECT Name, Email, Gender, Age, user_type FROM Users WHERE Email = '$_POST[email]'";
    $result = mysql_query($sql, $con);
    $t_result = mysql_fetch_array($result);

    //echo '{"response":[{"success":"1","name":"$t_result[0]"}]}';
    echo '{"response":[{"success":"1","name":"';
       echo "$t_result[0]";
       echo '","email":"';
       echo "$t_result[1]";
       echo '","gender":"';
       echo "$t_result[2]";
       echo '","age":"';
       echo "$t_result[3]";
       echo '","type":"';
       echo "$t_result[4]";
       echo '"}]}';


  }
  else {
    echo '{"response":[{"success":"0"}]}';
  }
}
else {
  echo '{"response":[{"success":"2"}]}';
}

?>
