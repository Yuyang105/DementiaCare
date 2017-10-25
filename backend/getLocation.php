<?php

  $con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
  if (!$con) {
      die('Could not connect: ' . mysql_error());
  }
  mysql_select_db("PH611260_dementiacare");
  $sql = "SELECT Users.Name, Users.latitude, Users.longtitude FROM pair INNER JOIN Users ON pair.Patient = Users.Email WHERE pair.Caregiver = '$_POST[email]'";
  $result = mysql_query($sql, $con);

  $row = mysql_fetch_array($result);
    echo '{"response":[{"name":"';
      echo "$row[Name]";
      echo '","latitude":"';
      echo "$row[latitude]";
      echo '","longtitude":"';
      echo "$row[longtitude]";
      echo '"}]}';

    while ($row = mysql_fetch_array($result)) {
    echo '|{"response":[{"name":"';
      echo "$row[Name]";
      echo '","latitude":"';
      echo "$row[latitude]";
      echo '","longtitude":"';
      echo "$row[longtitude]";
      echo '"}]}';
  }

?>
