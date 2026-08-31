/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/defaults.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';

class AboutDialogScreen extends HookConsumerWidget {
  const AboutDialogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(
      packageInfoProvider.select(
        // During startup we make sure package information is available.
        (value) => value.value!,
      ),
    );

    return AboutDialog(
      applicationIcon: SizedBox.square(
        dimension: IconTheme.of(context).size,
        child: SvgPicture.asset('assets/icon/icon.svg'),
      ),
      applicationName: packageInfo.appName,
      applicationVersion: packageInfo.version,
      applicationLegalese:
          'WebLibre Personal Edition • Maintained by Braziao • AGPL-3.0-or-later',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Gecko Version'),
          subtitle: Consumer(
            builder: (context, ref, child) {
              final geckoVersion = ref.watch(geckoVersionProvider);

              return Text(geckoVersion.value ?? 'N/A');
            },
          ),
        ),
        const Divider(),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(MdiIcons.shieldCheck),
          title: Text('Personal build'),
          subtitle: Text(
            'This build is maintained as a personal project. '
            'Network access is intended to occur only for user-requested '
            'web content or explicitly enabled online features.',
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(MdiIcons.bookOpenPageVariant),
          title: const Text('Open-source license'),
          subtitle: const Text('GNU AGPL-3.0-or-later'),
          onTap: () async {
            await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(
                  url: Uri.parse('https://www.gnu.org/licenses/agpl-3.0.html'),
                  tabMode: TabMode.regular,
                  selectTab: true,
                );
          },
        ),
      ],
    );
  }
}
