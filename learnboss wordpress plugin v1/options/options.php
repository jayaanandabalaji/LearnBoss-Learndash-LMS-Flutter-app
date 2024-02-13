<?php
add_filter('wpcfto_options_page_setup', function ($setups)
{
    $catsArr = array();
    $categories = get_terms(['taxonomy' => 'ld_course_category', 'hide_empty' => false, ]);

    foreach ($categories as $category)
    {
        array_push($catsArr, array(
            'label' => $category->name,
        ));
    }
    $setups[] = array(

        'option_name' => 'learndash_app_options',

        'title' => esc_html__('LearnBoss', 'learndash_app_options') ,
        'sub_title' => esc_html__('by LearnGun', 'learndash_app_options') ,
        'logo' => 'https://ec2-54-174-22-163.compute-1.amazonaws.com/wp-content/uploads/2023/02/logo.png',

        'page' => array(
            'page_title' => 'Learndash App Options',
            'menu_title' => 'Learndash App Options',
            'menu_slug' => 'learndash_app_options',
            'icon' => 'fa-solid',
            'position' => 40,
        ) ,

        'fields' => array(
            'purchase_code' => array(
                'name' => esc_html__('Purchase code', 'learndash_app_options') ,
                'fields' => array(
                    'purchase_code' => array(
                        'type' => 'text',
                        'label' => esc_html__('Purchase code', 'learndash_app_options') ,
                    ) ,
                )
            ) ,
            'home_page' => array(
                'name' => esc_html__('Home Page', 'learndash_app_options') ,
                'fields' => array(

                    'featured_category' => array(
                        'type' => 'multiselect',
                        'label' => esc_html__('Home Screen Categories', 'learndash_app_options') ,
                        'options' => $catsArr
                    ) ,

                    'banner' => array(
                        'type' => 'repeater',
                        'label' => esc_html__('Home Banner', 'learndash_app_options') ,
                        'fields' => array(
                            'field_1' => array(
                                'type' => 'text',
                                'label' => esc_html__('Title', 'learndash_app_options') ,
                            ) ,
                            'field_2' => array(
                                'type' => 'image',
                                'label' => esc_html__('Banner Image', 'learndash_app_options') ,
                            ) ,
                            'field_3' => array(
                                'type' => 'select',
                                'label' => esc_html__('On banner tap, open', 'learndash_app_options') ,
                                'options' => array(
                                    1 => 'Url',
                                    2 => 'Category',
                                    3 => 'Course'
                                )

                            ) ,
                            'field_4' => array(
                                'type' => 'text',
                                'label' => esc_html__('Type value', 'learndash_app_options') ,
                            )
                        )
                    ) ,

                )
            ) ,

        )
    );

    return $setups;
});

