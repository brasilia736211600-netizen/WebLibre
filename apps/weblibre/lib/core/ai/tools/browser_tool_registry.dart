import 'dart:collection';

import 'browser_tool_contract.dart';

/// Registry for the minimal AI-1 browser surface.
///
/// The registry describes capabilities only. Execution is intentionally kept
/// outside this class so the model cannot obtain unrestricted browser internals.
final class BrowserToolRegistry {
  BrowserToolRegistry._();

  static const List<BrowserToolSpec<dynamic, dynamic>> _definitions = [
    GetTabsTool(),
    GetCurrentTabTool(),
    CreateTabTool(),
    SwitchTabTool(),
    CloseTabTool(),
    OpenUrlTool(),
  ];

  static final UnmodifiableMapView<String, BrowserToolSpec<dynamic, dynamic>>
  definitions = UnmodifiableMapView({
    for (final definition in _definitions) definition.name: definition,
  });

  static BrowserToolSpec<dynamic, dynamic>? byName(String name) =>
      definitions[name];
}
