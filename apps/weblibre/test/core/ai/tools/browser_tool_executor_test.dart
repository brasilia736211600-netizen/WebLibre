import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/ai/tools/browser_tool_contract.dart';
import 'package:weblibre/core/ai/tools/browser_tool_executor.dart';

final class _FakeBackend implements BrowserToolBackend {
  @override
  Future<GetTabsOutput> getTabs() async => const GetTabsOutput([]);

  @override
  Future<CurrentTabOutput> getCurrentTab() async => const CurrentTabOutput(null);

  @override
  Future<TabMutationOutput> createTab(OpenUrlInput input) async =>
      const TabMutationOutput(tabId: 'created');

  @override
  Future<OperationResult> switchTab(TabIdInput input) async =>
      const OperationResult(success: true);

  @override
  Future<OperationResult> closeTab(TabIdInput input) async =>
      const OperationResult(success: true);

  @override
  Future<OperationResult> openUrl(OpenUrlTabInput input) async =>
      const OperationResult(success: true);
}

final class _ThrowingBackend implements BrowserToolBackend {
  @override
  Future<GetTabsOutput> getTabs() async => throw StateError('backend failed');

  @override
  Future<CurrentTabOutput> getCurrentTab() async => const CurrentTabOutput(null);

  @override
  Future<TabMutationOutput> createTab(OpenUrlInput input) async =>
      const TabMutationOutput(tabId: 'created');

  @override
  Future<OperationResult> switchTab(TabIdInput input) async =>
      const OperationResult(success: true);

  @override
  Future<OperationResult> closeTab(TabIdInput input) async =>
      const OperationResult(success: true);

  @override
  Future<OperationResult> openUrl(OpenUrlTabInput input) async =>
      const OperationResult(success: true);
}

void main() {
  final executor = BrowserToolExecutor(backend: _FakeBackend());

  test('denies execution before backend when permission is missing', () async {
    final result = await executor.execute(
      name: 'get_tabs',
      input: const EmptyToolInput(),
      grantedPermissions: const {},
    );

    expect(result.success, isFalse);
    expect(
      result.error?.code,
      BrowserToolExecutionErrorCode.permissionDenied,
    );
    expect(result.audit.toolName, 'get_tabs');
    expect(result.audit.success, isFalse);
  });

  test('returns deterministic failure for an unknown tool', () async {
    final result = await executor.execute(
      name: 'not_registered',
      input: const EmptyToolInput(),
      grantedPermissions: const {},
    );

    expect(result.success, isFalse);
    expect(result.error?.code, BrowserToolExecutionErrorCode.unknownTool);
    expect(result.audit.toolName, 'not_registered');
    expect(result.audit.success, isFalse);
  });

  test('dispatches typed open_url input through the backend', () async {
    final result = await executor.execute(
      name: 'open_url',
      input: OpenUrlTabInput(
        tabId: 'tab-1',
        url: Uri.parse('https://example.com'),
      ),
      grantedPermissions: const {BrowserToolPermission.navigate},
    );

    expect(result.success, isTrue);
    expect(result.output, isA<OperationResult>());
    expect((result.output! as OperationResult).success, isTrue);
  });

  test('returns deterministic invalid-input failure', () async {
    final result = await executor.execute(
      name: 'close_tab',
      input: const EmptyToolInput(),
      grantedPermissions: const {BrowserToolPermission.tabs},
    );

    expect(result.success, isFalse);
    expect(result.error?.code, BrowserToolExecutionErrorCode.invalidInput);
  });

  test('converts backend exceptions into executionException failures', () async {
    final result = await BrowserToolExecutor(backend: _ThrowingBackend()).execute(
      name: 'get_tabs',
      input: const EmptyToolInput(),
      grantedPermissions: const {BrowserToolPermission.readBrowserState},
    );

    expect(result.success, isFalse);
    expect(result.error?.code, BrowserToolExecutionErrorCode.executionException);
    expect(result.error?.message, contains('backend failed'));
    expect(result.audit.toolName, 'get_tabs');
    expect(result.audit.success, isFalse);
  });
}
