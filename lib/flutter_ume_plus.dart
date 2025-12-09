library flutter_ume;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide FlutterLogo;
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';

part 'core/pluggable.dart';
part 'core/pluggable_message_service.dart';
part 'core/plugin_manager.dart';
part 'core/red_dot.dart';
part 'core/store_manager.dart';
part 'core/ui/dragable_widget.dart';
part 'core/ui/global.dart';
part 'core/ui/icon_cache.dart';
part 'core/ui/menu_page.dart';
part 'core/ui/panel_action_define.dart';
part 'core/ui/root_widget.dart';
part 'core/ui/toolbar_widget.dart';
part 'service/inspector/inspector_overlay.dart';
part 'service/vm_service/service_mixin.dart';
part 'service/vm_service/service_wrapper.dart';

part 'util/binding_ambiguate.dart';
part 'util/constants.dart';
part 'util/floating_widget.dart';
part 'util/flutter_logo.dart';
part 'util/json_list_writer_extension.dart';
part 'util/json_map_writer_extension.dart';
part 'util/store_mixin.dart';
