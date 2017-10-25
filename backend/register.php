<?php

$con = mysql_connect("mysql11.namesco.net","dementiacare","3350335012");   //连接数据库
if (!$con) {
    die('Could not connect: ' . mysql_error());
}
mysql_select_db("PH611260_dementiacare", $con);  //选择数据库
$sql = "select email from Users where email = '$_POST[email]'"; //SQL语句
$result = mysql_query($sql, $con);    //执行SQL语句
$num = mysql_num_rows($result); //统计执行结果影响的行数
if($num)    //如果已经存在该用户
{
    echo '{"success":0}';
}
else    //不存在当前注册用户名称
{
    $sql_insert = "INSERT INTO Users (Name, Email, Password, Gender, Age, latitude, longtitude, token, user_type) VALUES ('$_POST[name]','$_POST[email]','$_POST[password]', '$_POST[gender]', '$_POST[age]', '0', '0', '0','$_POST[type]')";
    $res_account = mysql_query($sql_insert, $con);
    $num_insert = mysql_num_rows($res_insert);

    //---------------!!!-------------------这里可以完善！
    //-------------------------------------------------

    if($res_account)
    {
        echo '{"success":1}';
    }
    else
    {
        echo '{"success":2}';
    }
}

?>
