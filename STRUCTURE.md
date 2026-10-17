# Struktur Folder Barakah (Flutter, Dart)

```
barakah/
├── assets
│   ├── audio
│   ├── data
│   ├── fonts
│   └── images
├── design_ref
│   └── README.md
├── lib
│   ├── core
│   │   ├── config
│   │   │   ├── app_config.dart
│   │   │   └── env.dart
│   │   ├── constants
│   │   │   ├── api_endpoints.dart
│   │   │   └── app_constants.dart
│   │   ├── database
│   │   │   ├── daos
│   │   │   │   ├── ledger_dao.dart
│   │   │   │   ├── outbox_dao.dart
│   │   │   │   ├── prayer_cache_dao.dart
│   │   │   │   └── settings_dao.dart
│   │   │   ├── tables
│   │   │   │   ├── chat_message_table.dart
│   │   │   │   ├── donation_local_table.dart
│   │   │   │   ├── favorite_mosque_table.dart
│   │   │   │   ├── feedback_local_table.dart
│   │   │   │   ├── ledger_local_table.dart
│   │   │   │   ├── outbox_table.dart
│   │   │   │   ├── prayer_cache_table.dart
│   │   │   │   ├── quiz_attempt_table.dart
│   │   │   │   ├── quiz_question_table.dart
│   │   │   │   ├── rate_cache_table.dart
│   │   │   │   ├── settings_table.dart
│   │   │   │   └── tasbih_log_table.dart
│   │   │   └── app_database.dart
│   │   ├── errors
│   │   │   └── failure.dart
│   │   ├── network
│   │   │   ├── api_client.dart
│   │   │   ├── api_exception.dart
│   │   │   ├── auth_interceptor.dart
│   │   │   └── connectivity_service.dart
│   │   ├── router
│   │   │   ├── app_router.dart
│   │   │   └── route_names.dart
│   │   ├── security
│   │   │   ├── encryption_service.dart
│   │   │   ├── hash_utils.dart
│   │   │   └── secure_storage_service.dart
│   │   ├── sync
│   │   │   ├── outbox_processor.dart
│   │   │   ├── sync_service.dart
│   │   │   └── sync_status.dart
│   │   ├── theme
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_theme.dart
│   │   └── utils
│   │       ├── date_time_utils.dart
│   │       ├── formatters.dart
│   │       ├── geo_utils.dart
│   │       └── validators.dart
│   ├── features
│   │   ├── ai_chat
│   │   │   ├── models
│   │   │   │   └── chat_message.dart
│   │   │   ├── providers
│   │   │   │   └── chat_provider.dart
│   │   │   ├── repository
│   │   │   │   └── chat_repository.dart
│   │   │   ├── screens
│   │   │   │   └── ai_chat_screen.dart
│   │   │   └── widgets
│   │   │       └── chat_bubble.dart
│   │   ├── ai_light
│   │   │   ├── providers
│   │   │   │   └── recommendation_provider.dart
│   │   │   └── services
│   │   │       ├── adaptive_quiz_engine.dart
│   │   │       └── dhikr_target_predictor.dart
│   │   ├── auth
│   │   │   ├── models
│   │   │   │   ├── auth_tokens.dart
│   │   │   │   ├── session.dart
│   │   │   │   └── user.dart
│   │   │   ├── providers
│   │   │   │   ├── auth_provider.dart
│   │   │   │   └── session_provider.dart
│   │   │   ├── repository
│   │   │   │   └── auth_repository.dart
│   │   │   ├── screens
│   │   │   │   ├── biometric_lock_screen.dart
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── splash_screen.dart
│   │   │   ├── services
│   │   │   │   ├── auto_lock_service.dart
│   │   │   │   ├── biometric_service.dart
│   │   │   │   └── session_service.dart
│   │   │   └── widgets
│   │   │       ├── auth_hero.dart
│   │   │       └── logout_dialog.dart
│   │   ├── converter
│   │   │   ├── providers
│   │   │   │   └── converter_provider.dart
│   │   │   ├── repository
│   │   │   │   └── rate_repository.dart
│   │   │   ├── screens
│   │   │   │   └── converter_screen.dart
│   │   │   ├── services
│   │   │   │   ├── currency_service.dart
│   │   │   │   └── timezone_service.dart
│   │   │   └── widgets
│   │   │       ├── currency_converter_tab.dart
│   │   │       └── time_converter_tab.dart
│   │   ├── donation
│   │   │   ├── models
│   │   │   │   ├── campaign.dart
│   │   │   │   ├── donation.dart
│   │   │   │   └── zakat_result.dart
│   │   │   ├── providers
│   │   │   │   ├── donation_provider.dart
│   │   │   │   └── zakat_provider.dart
│   │   │   ├── repository
│   │   │   │   ├── campaign_repository.dart
│   │   │   │   └── donation_repository.dart
│   │   │   ├── screens
│   │   │   │   ├── donation_receipt_screen.dart
│   │   │   │   ├── donation_screen.dart
│   │   │   │   └── zakat_screen.dart
│   │   │   ├── services
│   │   │   │   └── zakat_calculator.dart
│   │   │   └── widgets
│   │   │       ├── amount_input.dart
│   │   │       └── campaign_card.dart
│   │   ├── feedback
│   │   │   ├── models
│   │   │   │   └── feedback_entry.dart
│   │   │   ├── providers
│   │   │   │   └── feedback_provider.dart
│   │   │   ├── repository
│   │   │   │   └── feedback_repository.dart
│   │   │   ├── screens
│   │   │   │   └── feedback_screen.dart
│   │   │   └── widgets
│   │   │       └── star_rating.dart
│   │   ├── games
│   │   │   ├── models
│   │   │   │   ├── quiz_attempt.dart
│   │   │   │   └── quiz_question.dart
│   │   │   ├── providers
│   │   │   │   ├── direction_game_provider.dart
│   │   │   │   └── quiz_provider.dart
│   │   │   ├── repository
│   │   │   │   └── quiz_repository.dart
│   │   │   ├── screens
│   │   │   │   ├── direction_game_screen.dart
│   │   │   │   ├── quiz_category_screen.dart
│   │   │   │   ├── quiz_question_screen.dart
│   │   │   │   └── quiz_result_screen.dart
│   │   │   ├── services
│   │   │   │   ├── direction_game_engine.dart
│   │   │   │   └── quiz_session.dart
│   │   │   └── widgets
│   │   │       └── answer_tile.dart
│   │   ├── home
│   │   │   ├── models
│   │   │   │   └── prayer_times.dart
│   │   │   ├── providers
│   │   │   │   └── home_provider.dart
│   │   │   ├── repository
│   │   │   │   └── prayer_repository.dart
│   │   │   ├── screens
│   │   │   │   └── home_screen.dart
│   │   │   ├── services
│   │   │   │   ├── location_service.dart
│   │   │   │   └── prayer_time_service.dart
│   │   │   └── widgets
│   │   │       ├── next_prayer_card.dart
│   │   │       ├── prayer_row.dart
│   │   │       ├── summary_cards.dart
│   │   │       └── zone_chips.dart
│   │   ├── iot
│   │   │   ├── models
│   │   │   │   └── iot_device.dart
│   │   │   ├── providers
│   │   │   │   └── iot_provider.dart
│   │   │   ├── repository
│   │   │   │   └── iot_repository.dart
│   │   │   └── screens
│   │   │       └── iot_screen.dart
│   │   ├── ledger
│   │   │   ├── models
│   │   │   │   └── block.dart
│   │   │   ├── providers
│   │   │   │   └── ledger_provider.dart
│   │   │   ├── repository
│   │   │   │   └── ledger_repository.dart
│   │   │   ├── screens
│   │   │   │   ├── block_detail_screen.dart
│   │   │   │   └── ledger_screen.dart
│   │   │   ├── services
│   │   │   │   ├── block_hasher.dart
│   │   │   │   ├── chain_verifier.dart
│   │   │   │   └── proof_of_work.dart
│   │   │   └── widgets
│   │   │       ├── block_card.dart
│   │   │       ├── chain_status_badge.dart
│   │   │       └── verification_result_sheet.dart
│   │   ├── mosque
│   │   │   ├── models
│   │   │   │   └── mosque.dart
│   │   │   ├── providers
│   │   │   │   └── mosque_provider.dart
│   │   │   ├── repository
│   │   │   │   └── mosque_repository.dart
│   │   │   ├── screens
│   │   │   │   └── mosque_screen.dart
│   │   │   └── widgets
│   │   │       ├── mosque_map.dart
│   │   │       └── mosque_tile.dart
│   │   ├── notification
│   │   │   ├── providers
│   │   │   │   └── notification_provider.dart
│   │   │   ├── screens
│   │   │   │   └── notification_settings_screen.dart
│   │   │   └── services
│   │   │       ├── geofence_service.dart
│   │   │       ├── notification_service.dart
│   │   │       └── prayer_scheduler.dart
│   │   ├── profile
│   │   │   ├── providers
│   │   │   │   ├── profile_provider.dart
│   │   │   │   └── theme_provider.dart
│   │   │   ├── repository
│   │   │   │   └── profile_repository.dart
│   │   │   ├── screens
│   │   │   │   ├── change_password_screen.dart
│   │   │   │   ├── edit_profile_screen.dart
│   │   │   │   ├── profile_screen.dart
│   │   │   │   ├── security_screen.dart
│   │   │   │   └── settings_screen.dart
│   │   │   └── widgets
│   │   │       └── avatar_picker.dart
│   │   ├── qibla
│   │   │   ├── providers
│   │   │   │   └── qibla_provider.dart
│   │   │   ├── screens
│   │   │   │   └── qibla_screen.dart
│   │   │   ├── services
│   │   │   │   ├── heading_filter.dart
│   │   │   │   ├── qibla_calculator.dart
│   │   │   │   └── qibla_sensor_service.dart
│   │   │   └── widgets
│   │   │       ├── calibration_banner.dart
│   │   │       └── compass_dial.dart
│   │   ├── shell
│   │   │   ├── screens
│   │   │   │   └── main_shell.dart
│   │   │   └── widgets
│   │   │       └── app_bottom_nav.dart
│   │   ├── tasbih
│   │   │   ├── models
│   │   │   │   └── tasbih_log.dart
│   │   │   ├── providers
│   │   │   │   └── tasbih_provider.dart
│   │   │   ├── repository
│   │   │   │   └── tasbih_repository.dart
│   │   │   ├── screens
│   │   │   │   ├── tasbih_history_screen.dart
│   │   │   │   └── tasbih_screen.dart
│   │   │   ├── services
│   │   │   │   └── shake_detector.dart
│   │   │   └── widgets
│   │   │       └── counter_ring.dart
│   │   └── worship
│   │       ├── providers
│   │       │   └── feature_search_provider.dart
│   │       ├── screens
│   │       │   └── worship_hub_screen.dart
│   │       └── widgets
│   │           └── feature_tile.dart
│   ├── shared
│   │   └── widgets
│   │       ├── app_chip.dart
│   │       ├── app_snackbar.dart
│   │       ├── app_text_field.dart
│   │       ├── empty_state.dart
│   │       ├── primary_button.dart
│   │       ├── selection_sheet.dart
│   │       ├── skeleton_box.dart
│   │       ├── status_banner.dart
│   │       └── tonal_button.dart
│   ├── app.dart
│   └── main.dart
├── supabase
│   ├── functions
│   │   ├── _shared
│   │   ├── ai
│   │   ├── auth
│   │   ├── campaigns
│   │   ├── donations
│   │   ├── favorites
│   │   ├── feedback
│   │   ├── games
│   │   ├── iot
│   │   ├── ledger
│   │   ├── mosques
│   │   ├── profile
│   │   ├── quiz
│   │   ├── rates
│   │   ├── sync
│   │   └── zakat
│   └── migrations
├── test
│   ├── core
│   │   ├── security
│   │   │   └── hash_utils_test.dart
│   │   ├── sync
│   │   │   └── outbox_processor_test.dart
│   │   └── utils
│   │       └── validators_test.dart
│   └── features
│       ├── ai_light
│       │   ├── adaptive_quiz_engine_test.dart
│       │   └── dhikr_target_predictor_test.dart
│       ├── auth
│       │   └── session_service_test.dart
│       ├── converter
│       │   ├── currency_service_test.dart
│       │   └── timezone_service_test.dart
│       ├── donation
│       │   └── zakat_calculator_test.dart
│       ├── ledger
│       │   ├── block_hasher_test.dart
│       │   ├── chain_verifier_test.dart
│       │   └── proof_of_work_test.dart
│       ├── qibla
│       │   ├── heading_filter_test.dart
│       │   └── qibla_calculator_test.dart
│       └── tasbih
│           └── shake_detector_test.dart
└── .env.example
```
