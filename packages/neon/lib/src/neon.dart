library neon;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_rx_bloc/flutter_rx_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:intl/intl_standalone.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:neon/l10n/localizations.dart';
import 'package:neon/src/apps/files/app.dart';
import 'package:neon/src/apps/news/app.dart';
import 'package:neon/src/apps/notes/app.dart';
import 'package:neon/src/apps/notifications/app.dart';
import 'package:neon/src/apps/notifications/blocs/notifications.dart';
import 'package:neon/src/blocs/accounts.dart';
import 'package:neon/src/blocs/apps.dart';
import 'package:neon/src/blocs/capabilities.dart';
import 'package:neon/src/blocs/login.dart';
import 'package:neon/src/blocs/user_details.dart';
import 'package:neon/src/blocs/user_status.dart';
import 'package:neon/src/models/account.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:rx_bloc/rx_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sort_box/sort_box.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tray_manager/tray_manager.dart' as tray;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

part 'app.dart';
part 'pages/home/home.dart';
part 'pages/home/widgets/server_status.dart';
part 'pages/login/login.dart';
part 'pages/settings/account_specific_settings.dart';
part 'pages/settings/nextcloud_app_specific_settings.dart';
part 'pages/settings/settings.dart';
part 'pages/settings/widgets/account_settings_tile.dart';
part 'pages/settings/widgets/text_settings_tile.dart';
part 'platform/abstract.dart';
part 'platform/android.dart';
part 'platform/linux.dart';
part 'platform/platform.dart';
part 'utils/account_options.dart';
part 'utils/app_implementation.dart';
part 'utils/confirmation_dialog.dart';
part 'utils/custom_timeago.dart';
part 'utils/env.dart';
part 'utils/global.dart';
part 'utils/global_options.dart';
part 'utils/hex_color.dart';
part 'utils/missing_permission_exception.dart';
part 'utils/nextcloud_app_specific_options.dart';
part 'utils/push_utils.dart';
part 'utils/rename_dialog.dart';
part 'utils/request_manager.dart';
part 'utils/save_file.dart';
part 'utils/settings_export_helper.dart';
part 'utils/sort_box_builder.dart';
part 'utils/sort_box_order_option_values.dart';
part 'utils/storage.dart';
part 'utils/theme.dart';
part 'utils/validators.dart';
part 'widgets/account_avatar.dart';
part 'widgets/account_tile.dart';
part 'widgets/cached_url_image.dart';
part 'widgets/custom_dialog.dart';
part 'widgets/custom_linear_progress_indicator.dart';
part 'widgets/custom_listview.dart';
part 'widgets/exception.dart';
part 'widgets/image_wrapper.dart';
part 'widgets/neon_logo.dart';
part 'widgets/nextcloud_logo.dart';
part 'widgets/no_animation_page_route.dart';
part 'widgets/result_stream_builder.dart';
part 'widgets/standard_rx_result_builder.dart';
