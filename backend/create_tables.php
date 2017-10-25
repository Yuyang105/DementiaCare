C<?php

// Connect
$con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");
mysql_select_db("PH611260_dementiacare", $con);

// 1 for male and patient, 0 for female and caregiver
$sql = "CREATE TABLE Users
(
Name varchar(255),
Email varchar(255),
Password varchar(255),
Gender int,
Age int,
user_type int,
latitude varchar(255),
longtitude varchar(255),
token varchar(255),
User_id int PRIMARY KEY NOT NULL AUTO_INCREMENT
)";
if (mysql_query($sql, $con)) {
	echo "Users Table has been created..<br>";
}
else {
	echo "Error creating Users Table: " . mysql_error()."<br>";
}

$sql = "CREATE TABLE daily
(
Title varchar(255),
Description varchar(255),
sTime varchar(255),
Cycle int,
User varchar(255),
cTime varchar(255),
State varchar(255),
ID int,
Daily_id int PRIMARY KEY NOT NULL AUTO_INCREMENT
)";
if (mysql_query($sql, $con)) {
	echo "Daily Table has been created..<br>";
}
else {
	echo "Error creating Daily Table: " . mysql_error()."<br>";
}

$sql = "CREATE TABLE request
(
Sender varchar(255),
Reciever varchar(255),
NewPair varchar(255)
)";
if (mysql_query($sql, $con)) {
	echo "Request Table has been created..<br>";
}
else {
	echo "Error creating Request Table: " . mysql_error()."<br>";
}

$sql = "CREATE TABLE pair
(
Patient varchar(255),
Caregiver varchar(255)
)";
if (mysql_query($sql, $con)) {
	echo "Pair Table has been created..<br>";
}
else {
	echo "Error creating Pair Table: " . mysql_error()."<br>";
}


mysql_close($con);
?>
