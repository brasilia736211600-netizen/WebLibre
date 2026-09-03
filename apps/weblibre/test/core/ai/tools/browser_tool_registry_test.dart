import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/ai/tools/browser_tool_contract.dart';
import 'package:weblibre/core/ai/tools/browser_tool_registry.dart';

void main() {
  test('AI-1 minimal registry has unique stable tool names', () {
    expect(
      BrowserToolRegistry.definitions.keys,
      containsAll(<String>[
        'get_tabs',
        'get_current_tab',
        'create_tab',
        'switch_tab',
        'close_tab',
        'open_url',
      ]),
    );
    expect(BrowserToolRegistry.definitions, hasLength(6));
    expect(BrowserToolRegistry.byName('get_tabs'), isA<GetTabsTool>());
    expect(BrowserToolRegistry.byName('open_url'), isA<OpenUrlTool>());
  });

  test('read tools and mutation tools have distinct permission boundaries', () {
    final getTabs = BrowserToolRegistry.byName('get_tabs')!;
    final createTab = BrowserToolRegistry.byName('create_tab')!;

    expect(getTabs.sideEffect, BrowserToolSideEffect.none);
    expect(
      getTabs.permissions,
      contains(BrowserToolPermission.readBrowserState),
    );
    expect(createTab.sideEffect, BrowserToolSideEffect.mutateBrowser);
    expect(createTab.permissions, contains(BrowserToolPermission.tabs));
    expect(createTab.permissions, contains(BrowserToolPermission.navigate));
  });

  test('each AI-1 mutating tool keeps its intended minimum permissions', () {
    expect(
      BrowserToolRegistry.byName('switch_tab')!.permissions,
      equals(const {BrowserToolPermission.tabs}),
    );
    expect(
      BrowserToolRegistry.byName('close_tab')!.permissions,
      equals(const {BrowserToolPermission.tabs}),
    );
    expect(
      BrowserToolRegistry.byName('open_url')!.permissions,
      equals(const {BrowserToolPermission.navigate}),
    );
    expect(
      BrowserToolRegistry.byName('create_tab')!.permissions,
      equals(const {
        BrowserToolPermission.tabs,
        BrowserToolPermission.navigate,
      }),
    );

    for (final name in <String>[
      'create_tab',
      'switch_tab',
      'close_tab',
      'open_url',
    ]) {
      expect(
        BrowserToolRegistry.byName(name)!.sideEffect,
        BrowserToolSideEffect.mutateBrowser,
      );
    }
  });
}
