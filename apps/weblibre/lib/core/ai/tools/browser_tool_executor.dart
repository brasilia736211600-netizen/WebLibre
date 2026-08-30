import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';

import 'browser_tool_contract.dart';
import 'browser_tool_registry.dart';

enum BrowserToolExecutionErrorCode {
  unknownTool,
  permissionDenied,
  invalidInput,
  operationFailed,
  executionException,
}

final class BrowserToolExecutionError {
  const BrowserToolExecutionError({
    required this.code,
    required this.message,
  });

  final BrowserToolExecutionErrorCode code;
  final String message;
}

final class BrowserToolAuditEvent {
  const BrowserToolAuditEvent({
    required this.toolName,
    required this.success,
  });

  final String toolName;
  final bool success;
}

final class BrowserToolExecutionResult {
  const BrowserToolExecutionResult._({
    required this.success,
    required this.output,
    required this.error,
    required this.audit,
  });

  factory BrowserToolExecutionResult.success({
    required String toolName,
    Object? output,
  }) {
    return BrowserToolExecutionResult._(
      success: true,
      output: output,
      error: null,
      audit: BrowserToolAuditEvent(toolName: toolName, success: true),
    );
  }

  factory BrowserToolExecutionResult.failure({
    required String toolName,
    required BrowserToolExecutionError error,
  }) {
    return BrowserToolExecutionResult._(
      success: false,
      output: null,
      error: error,
      audit: BrowserToolAuditEvent(toolName: toolName, success: false),
    );
  }

  final bool success;
  final Object? output;
  final BrowserToolExecutionError? error;
  final BrowserToolAuditEvent audit;
}

abstract interface class BrowserToolBackend {
  Future<GetTabsOutput> getTabs();
  Future<CurrentTabOutput> getCurrentTab();
  Future<TabMutationOutput> createTab(OpenUrlInput input);
  Future<OperationResult> switchTab(TabIdInput input);
  Future<OperationResult> closeTab(TabIdInput input);
  Future<OperationResult> openUrl(OpenUrlTabInput input);
}

final class RiverpodBrowserToolBackend implements BrowserToolBackend {
  RiverpodBrowserToolBackend(this.ref);

  final Ref ref;

  @override
  Future<GetTabsOutput> getTabs() async {
    final tabIds = ref.read(tabListProvider).value;
    final states = ref.read(tabStatesProvider);

    return GetTabsOutput([
      for (final tabId in tabIds)
        BrowserTabSummary(
          tabId: tabId,
          url: states[tabId]?.url,
          title: states[tabId]?.title,
        ),
    ]);
  }

  @override
  Future<CurrentTabOutput> getCurrentTab() async {
    final tabId = ref.read(selectedTabProvider);
    if (tabId == null) {
      return const CurrentTabOutput(null);
    }

    final state = ref.read(tabStatesProvider)[tabId];
    return CurrentTabOutput(
      BrowserTabSummary(
        tabId: tabId,
        url: state?.url,
        title: state?.title,
      ),
    );
  }

  @override
  Future<TabMutationOutput> createTab(OpenUrlInput input) async {
    final tabId = await ref.read(tabRepositoryProvider.notifier).addTab(
      tabMode: TabMode.regular,
      url: input.url,
      selectTab: true,
    );
    return TabMutationOutput(tabId: tabId);
  }

  @override
  Future<OperationResult> switchTab(TabIdInput input) async {
    if (!ref.read(tabListProvider).value.contains(input.tabId)) {
      return const OperationResult(success: false);
    }

    final selected = await ref
        .read(tabRepositoryProvider.notifier)
        .selectTab(input.tabId);
    return OperationResult(success: selected);
  }

  @override
  Future<OperationResult> closeTab(TabIdInput input) async {
    if (!ref.read(tabListProvider).value.contains(input.tabId)) {
      return const OperationResult(success: false);
    }

    await ref.read(tabRepositoryProvider.notifier).closeTab(input.tabId);
    return const OperationResult(success: true);
  }

  @override
  Future<OperationResult> openUrl(OpenUrlTabInput input) async {
    if (!ref.read(tabListProvider).value.contains(input.tabId)) {
      return const OperationResult(success: false);
    }

    await GeckoSessionService(tabId: input.tabId).loadUrl(url: input.url);
    return const OperationResult(success: true);
  }
}

final class BrowserToolExecutor {
  BrowserToolExecutor({required BrowserToolBackend backend}) : _backend = backend;

  final BrowserToolBackend _backend;

  Future<BrowserToolExecutionResult> execute({
    required String name,
    required Object input,
    required Set<BrowserToolPermission> grantedPermissions,
  }) async {
    final spec = BrowserToolRegistry.byName(name);
    if (spec == null) {
      return BrowserToolExecutionResult.failure(
        toolName: name,
        error: const BrowserToolExecutionError(
          code: BrowserToolExecutionErrorCode.unknownTool,
          message: 'Tool is not registered.',
        ),
      );
    }

    if (!spec.permissions.every(grantedPermissions.contains)) {
      return BrowserToolExecutionResult.failure(
        toolName: name,
        error: const BrowserToolExecutionError(
          code: BrowserToolExecutionErrorCode.permissionDenied,
          message: 'Required browser-tool permission is not granted.',
        ),
      );
    }

    try {
      switch (name) {
        case 'get_tabs':
          if (input is! EmptyToolInput) return _invalid(name);
          return BrowserToolExecutionResult.success(
            toolName: name,
            output: await _backend.getTabs(),
          );
        case 'get_current_tab':
          if (input is! EmptyToolInput) return _invalid(name);
          return BrowserToolExecutionResult.success(
            toolName: name,
            output: await _backend.getCurrentTab(),
          );
        case 'create_tab':
          if (input is! OpenUrlInput) return _invalid(name);
          return BrowserToolExecutionResult.success(
            toolName: name,
            output: await _backend.createTab(input),
          );
        case 'switch_tab':
          if (input is! TabIdInput) return _invalid(name);
          return _operationResult(name, await _backend.switchTab(input));
        case 'close_tab':
          if (input is! TabIdInput) return _invalid(name);
          return _operationResult(name, await _backend.closeTab(input));
        case 'open_url':
          if (input is! OpenUrlTabInput) return _invalid(name);
          return _operationResult(name, await _backend.openUrl(input));
      }

      return BrowserToolExecutionResult.failure(
        toolName: name,
        error: const BrowserToolExecutionError(
          code: BrowserToolExecutionErrorCode.unknownTool,
          message: 'Registered tool has no executor implementation.',
        ),
      );
    } catch (error) {
      return BrowserToolExecutionResult.failure(
        toolName: name,
        error: BrowserToolExecutionError(
          code: BrowserToolExecutionErrorCode.executionException,
          message: error.toString(),
        ),
      );
    }
  }

  BrowserToolExecutionResult _invalid(String name) {
    return BrowserToolExecutionResult.failure(
      toolName: name,
      error: const BrowserToolExecutionError(
        code: BrowserToolExecutionErrorCode.invalidInput,
        message: 'Input does not match the registered tool contract.',
      ),
    );
  }

  BrowserToolExecutionResult _operationResult(
    String name,
    OperationResult result,
  ) {
    if (result.success) {
      return BrowserToolExecutionResult.success(toolName: name, output: result);
    }

    return BrowserToolExecutionResult.failure(
      toolName: name,
      error: const BrowserToolExecutionError(
        code: BrowserToolExecutionErrorCode.operationFailed,
        message: 'Browser operation was not completed.',
      ),
    );
  }
}
