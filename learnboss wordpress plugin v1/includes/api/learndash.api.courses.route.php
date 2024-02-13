<?php
add_action('rest_api_init', function ()
{
    register_rest_route('learndashapp/v1', 'courses', array(
        'methods' => 'GET',
        'callback' => 'get_courses',
    ));

    register_rest_route('learndashapp/v1', 'analytics', array(
        'methods' => 'GET',
        'callback' => 'get_analytics_app_dashboard',
        'permission_callback' => 'validate_token',

    ));

    register_rest_route('learndashapp/v1', 'complete-lesson', array(
        'methods' => 'GET',
        'callback' => 'ld_complete_lesson_app',
        'permission_callback' => 'validate_token',

    ));

    register_rest_route('learndashapp/v1', 'my-profile', array(
        'methods' => 'GET',
        'callback' => 'ld_my_profile_app',
        'permission_callback' => 'validate_token',

    ));

    register_rest_route('learndashapp/v1', 'update-profile', array(
        'methods' => 'POST',
        'callback' => 'ld_update_my_profile_app',
        'permission_callback' => 'validate_token',

    ));

    register_rest_route('learndashapp/v1', 'update-password', array(
        'methods' => 'POST',
        'callback' => 'ld_update_my_password_app',
        'permission_callback' => 'validate_token',

    ));

    register_rest_route('learndashapp/v1', 'get-categories', array(
        'methods' => 'GET',
        'callback' => 'ld_app_get_categories',

    ));

    register_rest_route('learndashapp/v1', 'app-settings', array(
        'methods' => 'GET',
        'callback' => 'ld_app_get_settings',

    ));

    register_rest_route('learndashapp/v1', 'enrolled-courses', array(
        'methods' => 'GET',
        'callback' => 'ld_enrolled_courses_app',
        'permission_callback' => 'validate_token',

    ));

    register_rest_route('learndashapp/v1', 'enroll-course', array(
        'methods' => 'POST',
        'callback' => 'ld_enroll_course_app',
        'permission_callback' => 'ld_app_purchase_code',

    ));

    register_rest_route('learndashapp/v1', 'get-lesson', array(
        'methods' => 'GET',
        'callback' => 'ld_course_get_lesson',
        'permission_callback' => 'ld_app_purchase_code',

    ));

    register_rest_route('learndashapp/v1', 'get-steps', array(
        'methods' => 'GET',
        'callback' => 'ld_course_get_steps',
        'permission_callback' => 'ld_app_purchase_code',

    ));

    register_rest_route('learndashapp/v1', 'get-quizzes', array(
        'methods' => 'GET',
        'callback' => 'ld_course_get_quizzes',
        'permission_callback' => 'ld_app_purchase_code',

    ));

    register_rest_route('learndashapp/v1', 'submit-quiz', array(
        'methods' => 'POST',
        'callback' => 'ld_course_submit_quizzes',
        'permission_callback' => 'validate_token',

    ));

    register_rest_route('learndashapp/v1', 'start-quiz', array(
        'methods' => 'POST',
        'callback' => 'ld_course_start_quiz',
        'permission_callback' => 'validate_token',

    ));

});

function ld_course_start_quiz($request)
{
    $quizId = (int)$request['quizId'];
    $course_id = (int)$request['course_id'];
    $user_id = (int)validate_token() ["data"]["exp"];

    return learndash_activity_start_quiz($user_id, $course_id, $quizId, current_time('timestamp'));

}

function ld_course_submit_quizzes($request)
{

    $quizId = $request['quizId'];
    $quiz = $request['quiz'];
    $course_id = $request['course_id'];
    $user_id = (int)validate_token() ["data"]["exp"];
    $responses = $request['responses'];
    $lesson_id = $request['lesson_id'];
    $user_data = array();

    wp_clear_auth_cookie();
    wp_set_current_user($user_id); // Set the current user detail
    wp_set_auth_cookie($user_id); // Set auth details in cookie
    

    $quiz_nonce = wp_create_nonce('sfwd-quiz-nonce-' . $quiz . '-' . $quizId . '-' . $user_id);

    $objInst = new LD_QuizPro();

    $response = $objInst->checkAnswers(array(
        'quizId' => $quizId,
        'quiz' => $quiz,
        'course_id' => $course_id,
        'quiz_nonce' => $quiz_nonce,
        'responses' => $responses
    ));
    learndash_activity_complete_quiz($user_id, $course_id, $quiz, current_time('timestamp'));

    return $response;

}

function ld_course_get_quizzes($request)
{
    $lessonId = $request['lesson_id'];
    $userId = $request['user_id'];
    $courseid = $request['course_id'];
    if ($lessonId == null)
    {
        $quizzes = learndash_get_course_quiz_list($courseid, $userId);
    }
    else
    {
        $quizzes = learndash_get_lesson_quiz_list($lessonId, $userId, $courseid);
    }

    $returnArr = array();
    foreach ($quizzes as $quiz)
    {
        $temp = $quiz;
        $temp['attempts'] = learndash_get_user_quiz_attempts($userId, $temp['id']);
        $questionIds = learndash_get_quiz_questions($temp['id']);
        $temp['quiz_pro_id'] = get_post_meta($temp['id'], 'quiz_pro_id') [0];
        $questions = array();
        foreach ($questionIds as $questionId => $value)
        {
            array_push($questions, ld_app_get_question($questionId, $userId));
        }
        $temp['questions'] = $questions;
        array_push($returnArr, $temp);

    }

    return $returnArr;
}

function datapos_array($question_id, $count, $user_id)
{
    $datapos_array = array();

    for ($i = 0;$i < $count;$i++)
    {
        $datapos_array[$i] = md5($user_id . $question_id . $i);
    }

    return $datapos_array;
}

function ld_app_get_question($questionId, $user_id)
{
    $question_pro_id = (int)get_post_meta($questionId, 'question_pro_id', true);
    $question_mapper = new \WpProQuiz_Model_QuestionMapper();
    $question_model = $question_mapper->fetch($question_pro_id);
    $question_data = $question_model->get_object_as_array();
    $answer_data = array();

    // Get answer data.
    foreach ($question_data['_answerData'] as $answer)
    {
        $answer_data[] = $answer->get_object_as_array();
    }
    $question_data['_answerData'] = $answer_data;

    $question_data['datapos_array'] = datapos_array($question_pro_id, count($answer_data) , $user_id);
    $question_data['question_post_id'] = $questionId;
    return $question_data;

}

function ld_course_get_steps($request)
{
    return learndash_course_get_topics($request['course_id'], $request['lesson_id']);
}

function ld_course_get_lesson($request)
{
    return learndash_get_course_lessons_list($request['course_id'], $request['user_id']);
}

function ld_app_purchase_code($output = true)
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

    $options = stm_wpcfto_get_options('learndash_app_options');
    if ($options["purchase_code"] != $token)
    {
        return new WP_Error('ld_jwt_wrong_purchase_code', esc_html__('Make sure purchase code is set same on website and app.', 'learndash') , array(
            'status' => 401,
        ));
    }
    return $token;

}

function ld_enroll_course_app($request)
{
    $user_id = $request["user_id"];
    $courses = str_getcsv($request['id']);
    foreach ($courses as $course)
    {
        ld_update_course_access($user_id, $course);
    }

    return array(
        "status" => "success",
        "message" => "Course enrolled successfully"
    );
}

function ld_enrolled_courses_app($request)
{
    $user_id = (int)validate_token() ["data"]["exp"];
    $response = array();
    $enrolled = learndash_user_get_enrolled_courses($user_id);

    foreach ($enrolled as $course)
    {
        $course_args = array(
            'course_id' => (int)$course,
            'user_id' => (int)$user_id,
            'post_id' => (int)$course,
            'activity_type' => 'course',
        );
        $course_activity = learndash_get_user_activity($course_args);

        $author_id = get_post_field('post_author', $course);
        $enrollment = learndash_user_get_course_progress($user_id, $course);
        $enrollment['name'] = get_post_field('post_title', $course);
        $enrollment['id'] = $course;
        $enrollment['date'] = get_post_field('post_modified', $course);
        $enrollment['image'] = wp_get_attachment_url(get_post_thumbnail_id($course)) == false ? "" : wp_get_attachment_url(get_post_thumbnail_id($course));
        $enrollment['last_activity'] = $course_activity->activity_updated;
        $enrollment['instructor'] = array(
            'name' => get_the_author_meta('display_name', $author_id) ,
            'avatar' => get_the_author_meta('avatar', $author_id)
        );
        $enrollment['curriculum'] = array(
            'structure' => get_post_meta($course, 'ld_course_steps') [0]['steps'],
            'lesson_details' => array(
                'topics' => array_map('ReturnLesson', learndash_get_course_steps($course)) ,
                'sections' => learndash_30_get_course_sections($course) ,
                'quizzes' => getEnrolledCourseQuizzes($course, $user_id)
            )
        );
        array_push($response, $enrollment);
    }
    return $response;
}

function getEnrolledCourseQuizzes($courseId, $user_id)
{
    $output = array_map('ReturnQuizzes', learndash_get_course_quiz_list($courseId));
    foreach (learndash_get_lesson_list($courseId) as $lesson)
    {
        foreach (learndash_get_lesson_quiz_list($lesson->ID) as $quiz)
        {
            array_push($output, array(
                'id' => $quiz['id'],
                'status' => learndash_is_quiz_notcomplete($user_id, array(
                    $quiz['id']
                )) ,
                'title' => get_the_title($quiz['id'])
            ));
        }
    }
    return $output;
}

function ld_app_get_settings($request)
{
    $response = array();
    $options = stm_wpcfto_get_options('learndash_app_options');
    $featured_cat = array();
    foreach ($options['featured_category'] as $category)
    {
        array_push($featured_cat, get_term_by('name', $category['label'], 'ld_course_category'));
    }
    $response['featured_category'] = $featured_cat;

    $bannersArr = array();
    foreach ($options['banner'] as $banner)
    {
        array_push($bannersArr, array(
            'label' => $banner['field_1'],
            'image' => wp_get_attachment_image_url($banner['field_2'], 'full') ,
            'onTap' => $banner['field_3'],
            'value' => $banner['field_4']
        ));
    }

    $response['banner'] = $bannersArr;
    return $response;
}

function ld_app_get_categories($request)
{
    $terms = get_terms(['taxonomy' => 'ld_course_category', 'hide_empty' => false, ]);

    foreach ($terms as $term)
    {
        $icon = get_term_meta($term->term_id, 'icon', true);
        if ($icon != null && $icon != "")
        {
            $term->icon = wp_get_attachment_image_src($icon, 'full') [0];
        }
        else
        {
            $term->icon = "";
        }

    }

    return $terms;

}

function ld_update_my_password_app($request)
{
    $user_id = (int)validate_token() ["data"]["exp"];
    $userdata = get_user_by('id', $user_id);
    $result = wp_check_password($request['oldPass'], $userdata->user_pass, $userdata->ID);
    if ($result)
    {
        wp_set_password($request['newPass'], $user_id);
        return "Password updated successfully!";
    }
    else
    {
        return "Old password wrong!";
    }

}

function ld_update_my_profile_app($request)
{
    $user_id = (int)validate_token() ["data"]["exp"];
    $metas = array(
        'first_name' => $request['first_name'],
        'last_name' => $request['last_name'],
        'user_phone' => $request['phone'],
        'description' => $request['bio'],
        'twitter' => $request['twitter'],
        'facebook' => $request['facebook'],
        'instagram' => $request['instagram'],
    );

    foreach ($metas as $key => $value)
    {
        update_user_meta($user_id, $key, $value);
    }

    return array(
        "success" => true,
        "message" => "Profile updated successfully"
    );
}

function ld_my_profile_app($request)
{
    $user_id = (int)validate_token() ["data"]["exp"];
    $user_data = get_user_by('id', $user_id);
    $user_data = $user_data->data;
    $user = get_userdata($user_id);
    $phone = get_user_meta($user_id, 'user_phone', true);
    $twitter = get_user_meta($user_id, 'twitter', true);
    $facebook = get_user_meta($user_id, 'facebook', true);
    $instagram = get_user_meta($user_id, 'instagram', true);

    $user_data->first_name = $user->first_name;
    $user_data->last_name = $user->last_name;
    $user_data->bio = $user->description;
    $user_data->phone = $phone ?? "";
    $user_data->twitter = $twitter ?? "";
    $user_data->facebook = $facebook ?? "";
    $user_data->instagram = $instagram ?? "";

    return $user_data;
}

function get_analytics_app_dashboard($request)
{
    $user_id = (int)validate_token() ["data"]["exp"];
    return learndash_get_user_stats($user_id);
}

function ld_complete_lesson_app($request)
{
    $user_id = (int)validate_token() ["data"]["exp"];
    return learndash_process_mark_complete($user_id, $request['id']);
}

function get_courses($request)
{
    $user_id = "";
    $validate_token = validate_token();
    $enrolled = [];
    if (gettype($validate_token) == "array")
    {
        $user_id = (int)validate_token() ["data"]["exp"];
        $enrolled = learndash_user_get_enrolled_courses($user_id);

    }
    $output = [];

    $posts_per_page = (int)$request['posts_per_page'];
    $offset = (int)$request['offset'];

    if ($request['category'] != null && $request['category'] != "")
    {
        $posts = get_posts(array(
            'fields' => 'ids',
            'post_type' => 'sfwd-courses', // Only get post IDs
            'posts_per_page' => $posts_per_page,
            'paged' => $offset,
            'tax_query' => [['taxonomy' => 'ld_course_category',
            'terms' => $request['category'],
            'include_children' => false],
            ],
        ));
    }
    else if ($request['id'] != null && $request['id'] != "")
    {

        $posts = str_getcsv($request['id']);
    }
    else if ($request['search'] != null && $request['search'] != "")
    {
        $posts = get_posts(array(
            'fields' => 'ids',
            'post_type' => 'sfwd-courses',
            'posts_per_page' => $posts_per_page,
            'paged' => $offset,
            's' => $request['search']
        ));

    }
    else
    {
        $posts = get_posts(array(
            'fields' => 'ids',
            'post_type' => 'sfwd-courses', // Only get post IDs
            'posts_per_page' => $posts_per_page,
            'paged' => $offset,
        ));
    }

    for ($i = 0;$i < count($posts);$i++)
    {
        $post_id = $posts[$i];
        $author_id = get_post_field('post_author', $post_id);
        array_push($output, array(
            'id' => (int)$posts[$i],
            'title' => get_post_field('post_title', $post_id) ,
            'enrolled' => in_array($post_id, $enrolled) ,
            'updated' => get_post_field('post_modified', $post_id) ,
            'lectures' => learndash_get_course_steps_count($post_id) ,
            'category' => (get_the_terms($post_id, 'ld_course_category') != false) ? array_map('ReturnCategories', get_the_terms($post_id, 'ld_course_category')) : [],
            'link' => get_post_permalink($post_id) ,
            'image' => wp_get_attachment_url(get_post_thumbnail_id($post_id)) == false ? "" : wp_get_attachment_url(get_post_thumbnail_id($post_id)) ,
            'price_type' => get_post_meta($post_id, '_ld_price_type') [0],
            'price' => get_post_meta($post_id, '_sfwd-courses') [0]['sfwd-courses_course_price'] ?? "",
            'content' => get_post_field('post_content', $post_id) ,
            'instructor' => array(
                'name' => get_the_author_meta('display_name', $author_id) ,
                'avatar' => get_the_author_meta('avatar', $author_id)
            ) ,
            'video' => get_post_meta($post_id, 'ld_intro_video') [0] ?? "",
            'curriculum' => array(
                'structure' => get_post_meta($post_id, 'ld_course_steps') [0]['steps'],
                'lesson_details' => array(
                    'topics' => array_map('ReturnLesson', learndash_get_course_steps($post_id)) ,
                    'sections' => learndash_30_get_course_sections($post_id) ,
                    'quizzes' => getQuizzes($post_id) ,

                )
            )
        ));
    }
    return $output;
}

function getQuizzes($courseId)
{
    $output = array_map('ReturnQuizzes', learndash_get_course_quiz_list($courseId));
    foreach (learndash_get_lesson_list($courseId) as $lesson)
    {
        foreach (learndash_get_lesson_quiz_list($lesson->ID) as $quiz)
        {
            array_push($output, array(
                'id' => $quiz['id'],
                'title' => get_the_title($quiz['id'])
            ));
        }
    }
    return $output;
}

function ReturnCategories($category)
{
    return array(
        'id' => $category->term_id,
        'title' => $category->name
    );
}

function ReturnQuizzes($lesson)
{
    return array(
        'id' => $lesson['id'],
        'title' => get_the_title($lesson['id'])
    );
}

function ReturnLesson($lesson)
{
    return array(
        'id' => $lesson,
        'title' => get_the_title($lesson)
    );
}