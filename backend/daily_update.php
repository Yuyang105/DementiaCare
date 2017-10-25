<?php

$con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");   //连接数据库
if (!$con) {
    die('Could not connect: ' . mysql_error());
}
mysql_select_db("PH611260_dementiacare", $con);  //

if ($_POST[job] == 'update') {
  $sql = "UPDATE daily SET Title='$_POST[title]', Description='$_POST[description]', sTime='$_POST[stime]', Cycle='$_POST[cycle]', cTime='$_POST[ctime]', State='$_POST[state]' WHERE User='$_POST[user]' AND ID='$_POST[ID]'";
  $res = mysql_query($sql, $con);
  echo "updating!!!!!";
  if($res) {
      echo 'Success.';
  }
  else {
      echo 'Failed.';
  }
}
else if ($_POST[job] == 'create') {
  $sql_insert = "INSERT INTO daily (Title, Description, sTime, Cycle, User, cTime, State, ID) VALUES ('$_POST[title]','$_POST[description]','$_POST[stime]', '$_POST[cycle]', '$_POST[user]', '$_POST[ctime]', '$_POST[state]', '$_POST[ID]')";
  $res = mysql_query($sql_insert, $con);
  echo "inserting!!!!!";
  if($res) {
      echo 'Success.';
  }
  else {
      echo 'Failed.';
  }
}
else if ($_POST[job] == 'delete') {
  $sql = "DELETE FROM daily WHERE User = '$_POST[user]' AND ID = '$_POST[ID]'";
  $res = mysql_query($sql, $con);
  echo "deleting!!!!!";
  if($res) {
      echo 'Success.';
  }
  else {
      echo 'Failed.';
  }
}
else {
  echo "No instruction";
}

?>
