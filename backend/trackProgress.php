<?php

  $con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
  if (!$con) {
      die('Could not connect: ' . mysql_error());
  }
  mysql_select_db("PH611260_dementiacare");
  $sql = "SELECT Users.Name, daily.Title, daily.Description, daily.sTime, daily.Cycle, daily.cTime, daily.State FROM pair INNER JOIN Users ON pair.Patient = Users.Email INNER JOIN daily ON pair.Patient = daily.User WHERE pair.Caregiver = '$_POST[email]'";
  //$sql = "SELECT daily.Title, daily.Description, daily.sTime, daily.Cycle, daily.cTime, daily.State FROM pair INNER JOIN daily ON pair.Patient = daily.Email WHERE pair.Caregiver = '$_POST[email]'";
  //$sql = "SELECT Users.Name, Users.latitude, Users.longtitude FROM pair INNER JOIN Users ON pair.Patient = Users.Email WHERE pair.Caregiver = '$_POST[email]'";
  $result = mysql_query($sql, $con);

   $row = mysql_fetch_array($result);
   echo '{"response":[{"name":"';
      echo "$row[Name]";
      echo '","title":"';
      echo "$row[Title]";
      echo '","description":"';
      echo "$row[Description]";
      echo '","stime":"';
      echo "$row[sTime]";
      echo '","cycle":"';
      echo "$row[Cycle]";
      echo '","ctime":"';
      echo "$row[cTime]";
      echo '","state":"';
      echo "$row[State]";
      echo '"}]}';

      while ($row = mysql_fetch_array($result)) {
        echo '|{"response":[{"name":"';
          echo "$row[Name]";
          echo '","title":"';
          echo "$row[Title]";
          echo '","description":"';
          echo "$row[Description]";
          echo '","stime":"';
          echo "$row[sTime]";
          echo '","cycle":"';
          echo "$row[Cycle]";
          echo '","ctime":"';
          echo "$row[cTime]";
          echo '","state":"';
          echo "$row[State]";
          echo '"}]}';
      }


?>
