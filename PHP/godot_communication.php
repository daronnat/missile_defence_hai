<html>
<body>
<p>Handling of the logging system between Godot clients and Strathclyde's server.</p>

<?php

function getClientIP() {
    $ipaddress = 'UNKNOWN';
    $keys=array('HTTP_CLIENT_IP','HTTP_X_FORWARDED_FOR','HTTP_X_FORWARDED','HTTP_FORWARDED_FOR','HTTP_FORWARDED','REMOTE_ADDR');
    foreach($keys as $k){
        if (isset($_SERVER[$k]) && !empty($_SERVER[$k]) && filter_var($_SERVER[$k], FILTER_VALIDATE_IP)){
            $ipaddress = $_SERVER[$k];
            break;
        }
    }
    // print("IP: ".$ipaddress);
    return $ipaddress;
}

function update_registry($user_folder_path){
	$registry_name = "user_registry.csv";
	$registry_path = "GODOT_LOGS/".$registry_name;

	if (!file_exists($registry_path)) {
		file_put_contents($registry_path,"ID,IP Address\n");
		print("not found");
	}

	$exploded_path = explode("/",$user_folder_path);
	$user_id = $exploded_path[1];
	$user_ip = getClientIP();

	file_put_contents($registry_path,$user_id.",".$user_ip."\n",FILE_APPEND);
}




function create_if_not_found($path) { // create folder + file is doesnt exist
	if (!file_exists($path)) {
		$del = "/";
		$exploded_path = explode($del,$path);
		$folderpath = array_slice($exploded_path, 0, sizeof($exploded_path)-1);
		$folderpath = implode($del,$folderpath);
		if (!is_dir($folderpath)) {
			mkdir($folderpath,0777,true); // create folder recursively, 0777 = highest permission
			file_put_contents($path,''); // create empty file at specified location
			update_registry($folderpath);
		}
	}
}

function save_logs($root_log_path) {
	$headers = getallheaders();
	$log_path = $root_log_path.$headers["Path"];
	create_if_not_found($log_path);
	file_put_contents($log_path, file_get_contents('php://input'),FILE_APPEND);
}

$root_log_path = "GODOT_LOGS/";
save_logs($root_log_path);
// update_registry("GODOT_LOGS/test_id")
?>

</body>
</html>
