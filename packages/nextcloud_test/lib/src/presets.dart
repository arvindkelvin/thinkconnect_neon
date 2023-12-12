import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_test/nextcloud_test.dart';
import 'package:nextcloud_test/src/extended_version.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

/// Combination of preset `name` and preset `version`.
typedef Preset = ({String name, ExtendedVersion version});

final Map<String, List<ExtendedVersion>> _presets = () {
  final presets = <String, List<ExtendedVersion>>{};

  final presetGroups = Directory('../nextcloud_test/docker/presets')
      .listSync(followLinks: false)
      .whereType<Directory>()
      .map((final d) => PathUri.parse(d.path).name);

  for (final presetGroup in presetGroups) {
    final presetVersions = Directory('../nextcloud_test/docker/presets/$presetGroup')
        .listSync(followLinks: false)
        .whereType<File>()
        .map((final f) => ExtendedVersion.parse(PathUri.parse(f.path).name));

    presets[presetGroup] = presetVersions.toList();
  }

  return presets;
}();

/// All tests for apps that depend on the server version must be wrapped with this method and pass along the preset.
void presets(
  final String presetGroup,
  final String app,
  final dynamic Function(Preset preset) body, {
  final int? retry,
  final Timeout? timeout,
}) {
  if (!_presets.containsKey(presetGroup)) {
    throw Exception('Unknown preset type "$presetGroup"');
  }

  void innerBody() {
    for (final presetVersion in _presets[presetGroup]!) {
      group(presetVersion, () {
        final preset = (name: presetGroup, version: presetVersion);

        tearDown(() {
          validateFixture(preset);
        });

        return body(preset);
      });
    }
  }

  group(
    presetGroup,
    () {
      if (app != presetGroup) {
        group(app, innerBody);
      } else {
        innerBody();
      }
    },
    retry: retry,
    timeout: timeout,
  );
}
