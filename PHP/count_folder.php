<?php
$path = "GODOT_LOGS/*";
$folder_nb = count(glob($path, GLOB_ONLYDIR));
print $folder_nb;
?>