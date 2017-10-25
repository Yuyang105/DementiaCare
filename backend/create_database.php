<?php
$con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
if (!$con) {
	die('Could not connect: ' . mysql_error());
}

if (mysql_query("CREATE DATABASE PH611260_dementiacare", $con)) {
	echo "Database has been created..<br>";
}
else {
	echo "Error creating database: " . mysql_error();
}
mysql_close($con);
?>