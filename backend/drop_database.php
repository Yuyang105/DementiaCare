<?php
$con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
if (!$con) {
	die('Could not connect: ' . mysql_error());
}

if (mysql_query("DROP DATABASE PH611260_dementiacare", $con)) {
	echo "Database deleted";
}
else {
	echo "Error deleting database: " . mysql_error();
}
mysql_close($con);
?>
