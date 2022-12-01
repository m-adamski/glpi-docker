<?php
define("GLPI_CONFIG_DIR", "/var/lib/docker-agent/config/glpi/");

if (file_exists(GLPI_CONFIG_DIR . "/local_define.php")) {
    require_once GLPI_CONFIG_DIR . "/local_define.php";
}
