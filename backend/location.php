<?php

$con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");   //连接数据库
if (!$con) {
    die('Could not connect: ' . mysql_error());
}
mysql_select_db("PH611260_dementiacare", $con);  //


  $sql = "UPDATE Users SET latitude='$_POST[latitude]', longtitude='$_POST[longtitude]' WHERE Email='$_POST[user]'";
  $res = mysql_query($sql, $con);
  echo "location updating";
  if($res) {
      echo 'Success.';
  }
  else {
      echo 'Failed.';
  }

?>
