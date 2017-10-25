<?php
if (isset($_POST['delete'])) {
  $con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
  if (!$con) {
      die('Could not connect: ' . mysql_error());
  }
  mysql_select_db("PH611260_dementiacare");
  $sql = "DELETE FROM request WHERE Reciever = '$_POST[user]' AND Sender = '$_POST[email]'";
  $res = mysql_query($sql, $con);
  echo "deleting!!!!!";
  if($res) {
      echo 'Success.';
  }
  else {
      echo 'Failed.';
  }
}

else if (isset($_POST['unpair'])) {
  $con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
  if (!$con) {
      die('Could not connect: ' . mysql_error());
  }
  mysql_select_db("PH611260_dementiacare");
  $sql = "DELETE FROM pair WHERE Patient = '$_POST[user]' AND Caregiver = '$_POST[email]'";
  $res = mysql_query($sql, $con);
  echo "deleting!!!!!";
  if($res) {
      echo 'Success.';
  }
  else {
      echo 'Failed.';
  }
}

else if (isset($_POST['agree'])) {
  $con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
  if (!$con) {
      die('Could not connect: ' . mysql_error());
  }
  mysql_select_db("PH611260_dementiacare");
  $sql = "INSERT INTO pair (Patient, Caregiver) VALUES ('$_POST[user]','$_POST[email]')";
  $res = mysql_query($sql, $con);
  echo "insert!!!!!";
  if($res) {
      echo 'Success.';
  }
  else {
      echo 'Failed.';
  }
  $sql = "DELETE FROM request WHERE Sender = '$_POST[user]' AND Reciever = '$_POST[email]'";
  $res = mysql_query($sql, $con);
  echo "deleting!!!!!";
  if($res) {
      echo 'Success.';
  }
  else {
      echo 'Failed.';
  }
}

else if (isset($_POST['agreed'])) {
  $con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
  if (!$con) {
      die('Could not connect: ' . mysql_error());
  }
  mysql_select_db("PH611260_dementiacare");
  $sql = "INSERT INTO pair (Patient, Caregiver) VALUES ('$_POST[user]','$_POST[email]')";
  $res = mysql_query($sql, $con);
  echo "insert!!!!!";
  if($res) {
      echo 'Success.';
  }
  else {
      echo 'Failed.';
  }
  $sql = "DELETE FROM request WHERE Sender = '$_POST[email]' AND Reciever = '$_POST[user]'";
  $res = mysql_query($sql, $con);
  echo "deleting!!!!!";
  if($res) {
      echo 'Success.';
  }
  else {
      echo 'Failed.';
  }
}

else if (isset($_POST['remove'])) {
  $con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
  if (!$con) {
      die('Could not connect: ' . mysql_error());
  }
  mysql_select_db("PH611260_dementiacare");
  $sql = "DELETE FROM pair WHERE Patient = '$_POST[user]' AND Caregiver = '$_POST[email]'";
  $res = mysql_query($sql, $con);
  echo "insert!!!!!";
  if($res) {
      echo 'Success.';
  }
  else {
      echo 'Failed.';
  }
}
else if(isset($_POST['list'])) {

  $con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
  if (!$con) {
      die('Could not connect: ' . mysql_error());
  }
  mysql_select_db("PH611260_dementiacare");
  //$sql = "SELECT Sender FROM request WHERE Reciever = '$_POST[email]'";
  $sql = "SELECT GROUP_CONCAT(Caregiver SEPARATOR ',') FROM pair WHERE Patient = '$_POST[email]'";
  $result = mysql_query($sql, $con);
  $num = mysql_num_rows($result);
  $t_result = mysql_fetch_array($result);

  if($num) {
    //echo "$num";
    echo "$t_result[0]";


  }
}

else if(isset($_POST['token'])) {

  $con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
  if (!$con) {
      die('Could not connect: ' . mysql_error());
  }
  mysql_select_db("PH611260_dementiacare");
  $sql = "UPDATE Users SET token='$_POST[token]' WHERE Email='$_POST[user]'";
  $res = mysql_query($sql, $con);
  echo "token updating";
  if($res) {
      echo 'Success.';
  }
  else {
      echo 'Failed.';
  }
}


else if(isset($_POST['caregiver'])) {

  $con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
  if (!$con) {
      die('Could not connect: ' . mysql_error());
  }
  mysql_select_db("PH611260_dementiacare");
  //$sql = "SELECT Sender FROM request WHERE Reciever = '$_POST[email]'";
  $sql = "SELECT GROUP_CONCAT(Patient SEPARATOR ',') FROM pair WHERE Caregiver = '$_POST[email]'";
  $result = mysql_query($sql, $con);
  $num = mysql_num_rows($result);
  $t_result = mysql_fetch_array($result);

  if($num) {
    //echo "$num";
    echo "$t_result[0]";


  }
}

else if(isset($_POST['email'])) {

  $con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
  if (!$con) {
      die('Could not connect: ' . mysql_error());
  }
  mysql_select_db("PH611260_dementiacare");
  //$sql = "SELECT Sender FROM request WHERE Reciever = '$_POST[email]'";
  $sql = "SELECT GROUP_CONCAT(Sender SEPARATOR ',') FROM request WHERE Reciever = '$_POST[email]'";
  $result = mysql_query($sql, $con);
  $num = mysql_num_rows($result);
  $t_result = mysql_fetch_array($result);

  if($num) {
    //echo "$num";
    echo "$t_result[0]";


  }
}


?>
