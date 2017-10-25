<?php

$con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");   //连接数据库
if (!$con) {
    die('Could not connect: ' . mysql_error());
}
mysql_select_db("PH611260_dementiacare", $con);  //选择数据库

  $sql_insert = "INSERT INTO request (Sender, Reciever, NewPair) VALUES ('$_POST[account]','$_POST[email]','$_POST[pair]')";
  $res_account = mysql_query($sql_insert, $con);

  //---------------!!!-------------------这里可以完善！
  //-------------------------------------------------

  if($res_account) {
    echo '{"success":1}';
  }
  else {
    echo '{"success":2}';
  }

?>
