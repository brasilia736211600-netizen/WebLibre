/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/data/database/converters/color.dart';
import 'package:weblibre/data/database/converters/icon_data.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';

part 'container_data.g.dart';

@CopyWith()
@JsonSerializable(constructor: 'withDefaults')
class ContainerMetadata with FastEquatable {
  @IconDataJsonConverter()
  final IconData? iconData;

  final String? contextualIdentity;

  @JsonKey(
    fromJson: _proxyConnectionIdFromJson,
    toJson: _proxyConnectionIdToJson,
  )
  final ProxyConnectionId? proxyConnectionId;

  /// Optional User-Agent override scoped to this container's Gecko sessions.
  /// A null or blank value means use GeckoView's/default configured UA.
  final String? userAgent;

  @JsonKey(defaultValue: false)
  final bool clearDataOnExit;

  @JsonKey(defaultValue: false)
  final bool excludeFromIndex;

  @JsonKey(defaultValue: false)
  final bool excludeFromHistory;

  @JsonKey(defaultValue: false)
  final bool bypassGlobalProxy;

  @JsonKey(defaultValue: false)
  final bool useCustomColor;

  final List<Uri>? assignedSites;

  @JsonKey(defaultValue: false)
  final bool strictMode;

  @JsonKey(defaultValue: false)
  final bool isolatedAppLinkSettings;

  ContainerMetadata({
    required this.iconData,
    required this.contextualIdentity,
    required this.proxyConnectionId,
    required this.userAgent,
    required this.clearDataOnExit,
    required this.excludeFromIndex,
    required this.excludeFromHistory,
    required this.bypassGlobalProxy,
    required this.useCustomColor,
    required this.assignedSites,
    required this.strictMode,
    required this.isolatedAppLinkSettings,
  });

  ContainerMetadata.withDefaults({
    IconData? iconData,
    String? contextualIdentity,
    ProxyConnectionId? proxyConnectionId,
    String? userAgent,
    bool? clearDataOnExit,
    bool? excludeFromIndex,
    bool? excludeFromHistory,
    bool? bypassGlobalProxy,
    bool? useCustomColor,
    List<Uri>? assignedSites,
    bool? strictMode,
    bool? isolatedAppLinkSettings,
  }) : this(
         iconData: iconData,
         contextualIdentity: contextualIdentity,
         proxyConnectionId: proxyConnectionId,
         userAgent: _normalizeUserAgent(userAgent),
         clearDataOnExit: clearDataOnExit ?? false,
         excludeFromIndex: excludeFromIndex ?? false,
         excludeFromHistory: excludeFromHistory ?? false,
         bypassGlobalProxy: bypassGlobalProxy ?? false,
         useCustomColor: useCustomColor ?? false,
         assignedSites: assignedSites,
         strictMode: (strictMode ?? false) && contextualIdentity != null,
         isolatedAppLinkSettings:
             (isolatedAppLinkSettings ?? false) && contextualIdentity != null,
       );

  ContainerMetadata sanitized() {
    var result = this;
    if (result.strictMode && result.contextualIdentity == null) {
      result = result.copyWith(strictMode: false);
    }
    if (result.isolatedAppLinkSettings && result.contextualIdentity == null) {
      result = result.copyWith(isolatedAppLinkSettings: false);
    }
    if (result.contextualIdentity == null &&
        (result.proxyConnectionId != null || result.bypassGlobalProxy)) {
      result = result.copyWith(
        proxyConnectionId: null,
        bypassGlobalProxy: false,
      );
    }
    return result;
  }

  bool get usesTorProxy => proxyConnectionId is TorProxyConnectionId;

  factory ContainerMetadata.fromJson(Map<String, dynamic> json) =>
      _$ContainerMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$ContainerMetadataToJson(this);

  @override
  List<Object?> get hashParameters => [
    iconData,
    contextualIdentity,
    proxyConnectionId,
    userAgent,
    clearDataOnExit,
    excludeFromIndex,
    excludeFromHistory,
    bypassGlobalProxy,
    useCustomColor,
    assignedSites,
    strictMode,
    isolatedAppLinkSettings,
  ];
}

String? _normalizeUserAgent(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

@JsonSerializable()
@CopyWith()
class ContainerData with FastEquatable {
  final String id;
  final String? name;
  @ColorJsonConverter()
  final Color color;

  final String orderKey;

  @JsonKey(defaultValue: false)
  final bool isPinned;

  final ContainerMetadata metadata;

  ContainerData({
    required this.id,
    this.name,
    required this.color,
    required this.orderKey,
    this.isPinned = false,
    ContainerMetadata? metadata,
  }) : metadata = metadata ?? ContainerMetadata.withDefaults();

  factory ContainerData.fromJson(Map<String, dynamic> json) =>
      _$ContainerDataFromJson(json);

  Map<String, dynamic> toJson() => _$ContainerDataToJson(this);

  @override
  List<Object?> get hashParameters => [
    id,
    name,
    color,
    orderKey,
    isPinned,
    metadata,
  ];
}

@JsonSerializable()
class ContainerDataWithCount extends ContainerData {
  final int? tabCount;

  ContainerDataWithCount({
    required super.id,
    super.name,
    required super.color,
    required super.orderKey,
    super.isPinned,
    super.metadata,
    required this.tabCount,
  });

  factory ContainerDataWithCount.fromJson(Map<String, dynamic> json) =>
      _$ContainerDataWithCountFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ContainerDataWithCountToJson(this);

  @override
  List<Object?> get hashParameters => [...super.hashParameters, tabCount];
}

ProxyConnectionId? _proxyConnectionIdFromJson(String? json) =>
    ProxyConnectionId.decode(json);

String? _proxyConnectionIdToJson(ProxyConnectionId? object) => object?.encode();
