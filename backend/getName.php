<?php
if(isset($_POST['email'])) {

  $con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
  if (!$con) {
      die('Could not connect: ' . mysql_error());
  }
  mysql_select_db("PH611260_dementiacare");
  //$sql = "SELECT Sender FROM request WHERE Reciever = '$_POST[email]'";
  $sql = "SELECT Name FROM Users WHERE Email = '$_POST[email]'";
  $result = mysql_query($sql, $con);
  $num = mysql_num_rows($result);
  $t_result = mysql_fetch_array($result);

  if($num) {
    //echo "$num";
    echo "$t_result[0]";


  }
}

?>
