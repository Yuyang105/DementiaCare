<?php
if(isset($_POST['email'])) {
	if($_POST['email'] == 'yuyang' && $_POST['password'] == 'password') {
		echo '{"success":1}';
	}
	else {
		echo '{"success":0}';
	}
}
else {
	echo '{"success":0}';
}	
	
?>