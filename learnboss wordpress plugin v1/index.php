<?php
/**
 * Plugin Name: Learndash app options
 * Plugin URI: https://techgun.net/
 * Description: Learndash app options
 * Version: 1.0
 * Author: Techgun
 * Author URI: https://techgun.net/
 **/

require_once(dirname(__FILE__) . '/wpcfto/NUXY.php');
require_once(dirname(__FILE__) . '/options/options.php');

if (!defined('LEARNDASH_APP_DIR_URI')) {
    define('LEARNDASH_APP_DIR_URI', plugin_dir_path(__FILE__));
}

require_once LEARNDASH_APP_DIR_URI . '/includes/api/learndash.api.courses.route.php';
require_once LEARNDASH_APP_DIR_URI . '/includes/api/learndash.api.auth.route.php';
require_once LEARNDASH_APP_DIR_URI . '/includes/app_resources.php';
require_once LEARNDASH_APP_DIR_URI . '/includes/vendor/autoload.php';
require_once LEARNDASH_APP_DIR_URI . '/includes/class-jwt-auth-loader.php';
require_once LEARNDASH_APP_DIR_URI . '/includes/class-jwt-auth-i18n.php';
