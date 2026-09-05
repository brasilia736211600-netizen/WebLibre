import 'package:meta/meta.dart';

/// Permission scopes consumed by the future AI permission boundary.
enum BrowserToolPermission {
  readBrowserState,
  tabs,
  navigate,
}

enum BrowserToolSideEffect { none, mutateBrowser }

/// Model-independent description of one browser capability.
///
/// This layer deliberately contains no handler, provider, Pigeon object,
/// GeckoView object, database handle, or LLM dependency.
@immutable
abstract base class BrowserToolSpec<I, O> {
  const BrowserToolSpec({
    required this.name,
    required this.description,
    required this.permissions,
    required this.sideEffect,
  });

  final String name;
  final String description;
  final Set<BrowserToolPermission> permissions;
  final BrowserToolSideEffect sideEffect;
}

@immutable
final class EmptyToolInput {
  const EmptyToolInput();
}

@immutable
final class TabIdInput {
  const TabIdInput(this.tabId);

  final String tabId;
}

@immutable
final class OpenUrlInput {
  const OpenUrlInput({required this.url});

  final Uri url;
}

@immutable
final class OpenUrlTabInput {
  const OpenUrlTabInput({required this.tabId, required this.url});

  final String tabId;
  final Uri url;
}

@immutable
final class BrowserTabSummary {
  const BrowserTabSummary({
    required this.tabId,
    required this.url,
    required this.title,
  });

  final String tabId;
  final Uri? url;
  final String? title;
}

@immutable
final class GetTabsOutput {
  const GetTabsOutput(this.tabs);

  final List<BrowserTabSummary> tabs;
}

@immutable
final class CurrentTabOutput {
  const CurrentTabOutput(this.tab);

  final BrowserTabSummary? tab;
}

@immutable
final class TabMutationOutput {
  const TabMutationOutput({required this.tabId});

  final String tabId;
}

@immutable
final class OperationResult {
  const OperationResult({required this.success});

  final bool success;
}

final class GetTabsTool extends BrowserToolSpec<EmptyToolInput, GetTabsOutput> {
  const GetTabsTool()
      : super(
          name: 'get_tabs',
          description: 'Read the currently available browser tabs.',
          permissions: const {BrowserToolPermission.readBrowserState},
          sideEffect: BrowserToolSideEffect.none,
        );
}

final class GetCurrentTabTool
    extends BrowserToolSpec<EmptyToolInput, CurrentTabOutput> {
  const GetCurrentTabTool()
      : super(
          name: 'get_current_tab',
          description: 'Read the currently selected browser tab.',
          permissions: const {BrowserToolPermission.readBrowserState},
          sideEffect: BrowserToolSideEffect.none,
        );
}

final class CreateTabTool
    extends BrowserToolSpec<OpenUrlInput, TabMutationOutput> {
  const CreateTabTool()
      : super(
          name: 'create_tab',
          description: 'Create a browser tab and optionally navigate to a URL.',
          permissions: const {
            BrowserToolPermission.tabs,
            BrowserToolPermission.navigate,
          },
          sideEffect: BrowserToolSideEffect.mutateBrowser,
        );
}

final class SwitchTabTool extends BrowserToolSpec<TabIdInput, OperationResult> {
  const SwitchTabTool()
      : super(
          name: 'switch_tab',
          description: 'Select an existing browser tab.',
          permissions: const {BrowserToolPermission.tabs},
          sideEffect: BrowserToolSideEffect.mutateBrowser,
        );
}

final class CloseTabTool extends BrowserToolSpec<TabIdInput, OperationResult> {
  const CloseTabTool()
      : super(
          name: 'close_tab',
          description: 'Close an existing browser tab.',
          permissions: const {BrowserToolPermission.tabs},
          sideEffect: BrowserToolSideEffect.mutateBrowser,
        );
}

final class OpenUrlTool
    extends BrowserToolSpec<OpenUrlTabInput, OperationResult> {
  const OpenUrlTool()
      : super(
          name: 'open_url',
          description: 'Navigate an existing browser tab to a URL.',
          permissions: const {BrowserToolPermission.navigate},
          sideEffect: BrowserToolSideEffect.mutateBrowser,
        );
}
