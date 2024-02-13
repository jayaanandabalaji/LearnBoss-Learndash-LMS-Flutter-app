<?php
if (!defined(ABSPATH))
{
    $pagePath = explode('/wp-content/', dirname(__FILE__));
    include_once (str_replace('wp-content/', '', $pagePath[0] . '/wp-load.php'));
}

use \Firebase\JWT\JWT;
add_action('rest_api_init', function ()
{
    register_rest_route('jwt-auth/v1', 'token', array(
        'methods' => 'POST',
        'callback' => 'generate_token',
    ));

    register_rest_route('jwt-auth/v1', 'register', array(
        'methods' => 'POST',
        'callback' => 'register_api',
    ));

    register_rest_route('jwt-auth/v1', 'reset_password', array(
        'methods' => 'POST',
        'callback' => 'reset_password_app',
    ));

    register_rest_route('jwt-auth/v1', 'validate', array(
        'methods' => 'GET',
        'callback' => 'validate_token',
    ));

    register_rest_route('jwt-auth/v1', 'social-login/', array(
        'methods' => WP_REST_Server::ALLMETHODS,
        'callback' => 'social_login',
        'permission_callback' => 'ld_app_purchase_code',
    ));

});

function reset_password_app($request)
{
    $user_login = $request->get_param('login');
    global $wpdb, $current_site;

    if (empty($user_login))
    {
        return new WP_Error('User not registered', 'User not registered on site', array(
            'status' => 403,
        ));
    }
    else if (strpos($user_login, '@'))
    {
        $user_data = get_user_by('email', trim($user_login));
        if (empty($user_data)) return new WP_Error('User not registered', 'User not registered on site', array(
            'status' => 403,
        ));
    }
    else
    {
        $login = trim($user_login);
        $user_data = get_user_by('login', $login);
    }

    do_action('lostpassword_post');

    if (!$user_data) return new WP_Error('User not registered', 'User not registered on site', array(
        'status' => 403,
    ));

    // redefining user_login ensures we return the right case in the email
    $user_login = $user_data->user_login;
    $user_email = $user_data->user_email;

    do_action('retreive_password', $user_login); // Misspelled and deprecated
    do_action('retrieve_password', $user_login);

    $allow = apply_filters('allow_password_reset', true, $user_data->ID);

    if (!$allow) return new WP_Error('Unknown error', 'Unknown error occured', array(
        'status' => 403,
    ));
    else if (is_wp_error($allow)) return new WP_Error('Unknown error', 'Unknown error occured', array(
        'status' => 403,
    ));

    $key = $wpdb->get_var($wpdb->prepare("SELECT user_activation_key FROM $wpdb->users WHERE user_login = %s", $user_login));
    if (empty($key))
    {
        $key = wp_generate_password(20, false);
        do_action('retrieve_password_key', $user_login, $key);
        $wpdb->update($wpdb->users, array(
            'user_activation_key' => $key
        ) , array(
            'user_login' => $user_login
        ));
    }
    $message = __('Someone requested that the password be reset for the following account:') . "\r\n\r\n";
    $message .= network_home_url('/') . "\r\n\r\n";
    $message .= sprintf(__('Username: %s') , $user_login) . "\r\n\r\n";
    $message .= __('If this was a mistake, just ignore this email and nothing will happen.') . "\r\n\r\n";
    $message .= __('To reset your password, visit the following address:') . "\r\n\r\n";
    $message .= '<' . network_site_url("wp-login.php?action=rp&key=$key&login=" . rawurlencode($user_login) , 'login') . ">\r\n";

    if (is_multisite()) $blogname = $GLOBALS['current_site']->site_name;
    else $blogname = wp_specialchars_decode(get_option('blogname') , ENT_QUOTES);

    $title = sprintf(__('[%s] Password Reset') , $blogname);

    $title = apply_filters('retrieve_password_title', $title);
    $message = apply_filters('retrieve_password_message', $message, $key);

    if ($message && !wp_mail($user_email, $title, $message)) wp_die(__('The e-mail could not be sent.') . "<br />\n" . __('Possible reason: your host may have disabled the mail() function...'));

    return array(
        "message" => "Mail sent successfully",
        "success" => true
    );

}

function social_login($request)
{
    $parameters = $request->get_params();

    $email = $parameters['email'];
    $password = $parameters['accessToken'];
    $user = get_user_by('email', $email);
    $request["username"] = $email;
    $request["password"] = $password;
    if (!$user)
    {
        $user = wp_create_user($email, $password, $email);
        update_user_meta($user, 'loginType', $parameters['loginType']);
        return generate_token($request);
    }
    else
    {
        //wp_set_password($password,$user->ID);
        $request['custom_auth'] = true;
        update_user_meta($user->ID, 'loginType', $parameters['loginType']);
        return generate_token($request);
    }
}

function register_api($request)
{
    $username = $request->get_param('username');
    $password = $request->get_param('password');
    $email = $request->get_param('email');
    if (empty($username) || empty($password) || empty($email))
    {
        return new WP_Error('parameters missing', 'username, password and email required', array(
            'status' => 403,
        ));
    }
    $customer_id = wp_create_user($username, $password, $email);

    if (is_wp_error($customer_id))
    {
        return new WP_Error($customer_id->get_error_code() , $customer_id->get_error_message() , array(
            'status' => 403,
        ));
    }

    return generate_token($request);
}

function generate_token($request)
{
    $secret_key = defined('JWT_AUTH_SECRET_KEY') ? JWT_AUTH_SECRET_KEY : false;
    $username = $request->get_param('username');
    $password = $request->get_param('password');
    $custom_auth = $request->get_param('custom_auth');

    if (!$secret_key)
    {
        return new WP_Error('jwt_auth_bad_config', __('JWT is not configurated properly, please contact the admin', 'wp-api-jwt-auth') , array(
            'status' => 403,
        ));
    }

    if ($custom_auth)
    {
        $user = get_user_by('email', $username);
    }
    else
    {
        $user = wp_authenticate($username, $password);

        if (is_wp_error($user))
        {
            $error_code = $user->get_error_code();
            return new WP_Error('[jwt_auth] ' . $error_code, $user->get_error_message($error_code) , array(
                'status' => 403,
            ));
        }

    }
    $issuedAt = time();
    $notBefore = apply_filters('jwt_auth_not_before', $issuedAt, $issuedAt);
    $expire = apply_filters('jwt_auth_expire', $issuedAt + (DAY_IN_SECONDS * 7) , $issuedAt);

    $token = array(
        'iss' => get_bloginfo('url') ,
        'iat' => $issuedAt,
        'nbf' => $notBefore,
        'exp' => $expire,
        'data' => array(
            'user' => array(
                'id' => $user
                    ->data->ID,
            ) ,
        ) ,
    );

    $token = JWT::encode(apply_filters('jwt_auth_token_before_sign', $token, $user) , $secret_key);

    $data = array(
        'token' => $token,
        'user_email' => $user
            ->data->user_email,
        'id' => $user->ID,
        'avatar' => get_avatar_url($user->ID) ,
        'user_display_name' => $user
            ->data->display_name,
    );

    return apply_filters('jwt_auth_token_before_dispatch', $data, $user);
}

function validate_token($output = true)
{
    $auth = isset($_SERVER['HTTP_AUTHORIZATION']) ? sanitize_text_field($_SERVER['HTTP_AUTHORIZATION']) : false;

    if (!$auth)
    {
        $auth = isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION']) ? sanitize_text_field($_SERVER['REDIRECT_HTTP_AUTHORIZATION']) : false;
    }

    if (!$auth)
    {
        return new WP_Error('lp_jwt_auth_no_auth_header', esc_html__('Authorization header not found.', 'learndash') , array(
            'status' => 401,
        ));
    }

    list($token) = sscanf($auth, 'Bearer %s');
    if (!$token)
    {
        return new WP_Error('lp_jwt_auth_bad_auth_header', esc_html__('Authentication token is missing.', 'learndash') , array(
            'status' => 401,
        ));
    }

    $secret_key = JWT_AUTH_SECRET_KEY;

    if (!$secret_key)
    {
        return new WP_Error('lp_jwt_auth_bad_config', esc_html__('learndash JWT is not configurated properly, please contact the admin', 'learndash') , array(
            'status' => 401,
        ));
    }

    try
    {
        $token = JWT::decode($token, $secret_key, array(
            'HS256'
        ));

        if ($token->iss != get_bloginfo('url'))
        {
            return new WP_Error('lp_jwt_auth_bad_iss', esc_html__('The iss do not match with this server', 'learndash') , array(
                'status' => 401,
            ));
        }

        if (!isset($token
            ->data
            ->user
            ->id))
        {
            return new WP_Error('lp_jwt_auth_bad_request', esc_html__('User ID not found in the token', 'learndash') , array(
                'status' => 401,
            ));
        }

        if (!isset($token->exp))
        {
            return new WP_Error('rest_authentication_missing_token_expiration', esc_html__('Token must have an expiration.', 'learndash') , array(
                'status' => 401,
            ));
        }

        if (time() > $token->exp)
        {
            return new WP_Error('rest_authentication_token_expired', esc_html__('Token has expired.', 'learndash') , array(
                'status' => 401,
            ));
        }

        if (!$output)
        {
            return true;
        }

        return array(
            'code' => 'lp_jwt_auth_valid_token',
            'message' => esc_html__('Valid access token.', 'learndash') ,
            'data' => array(
                'status' => 200,
                'exp' => $token
                    ->data
                    ->user->id,
            ) ,
        );
    }
    catch(Exception $e)
    {
        return false;
        return new WP_Error('lp_jwt_auth_invalid_token', $e->getMessage() , array(
            'status' => 401,
        ));
    }
}

define('JWT_AUTH_SECRET_KEY', 'gdhrgfrhehdyuye363egye6w7idfybhe');

