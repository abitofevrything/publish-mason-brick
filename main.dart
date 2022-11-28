#!/usr/bin/env dart

import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart';
import 'package:collection/collection.dart';
import 'package:mason/mason.dart';
import 'package:mason_api/mason_api.dart';
import 'package:path/path.dart' as p;
import 'package:actions_toolkit_dart/core.dart' as core;

void main() async {
  final path = core.getInput(name: 'path');
  final email = core.getInput(name: 'email');
  final password = core.getInput(name: 'password');
  final dryRun = core.getBooleanInput(name: 'dryRun');

  // Validate and load local brick
  final brickDirectory = Directory(path);
  if (!await brickDirectory.exists()) {
    core.setFailed(message: 'path input should be a valid path pointing to a Mason brick');
    return;
  }

  final brickFile = File(p.join(path, BrickYaml.file));
  if (!await brickFile.exists()) {
    core.setFailed(message: "Couldn't find ${BrickYaml.file} in $path");
    return;
  }

  final metadata = checkedYamlDecode(
    await brickFile.readAsString(),
    (yaml) => BrickYaml.fromJson(yaml!),
  ).copyWith(path: brickFile.path);

  core.setOutput(name: 'name', value: metadata.name);
  core.setOutput(name: 'version', value: metadata.version);

  core.info(message: 'Local version of ${metadata.name} is ${metadata.version}');

  // Fetch current uploaded version
  final api = MasonApi();
  await api.login(email: email, password: password);

  final searchResults = await api.search(query: metadata.name);
  final remoteMetadata = searchResults.firstWhereOrNull((result) => result.name == metadata.name);

  if (remoteMetadata == null) {
    core.setFailed(
      message: "Couldn't find brick ${metadata.name} on brickhub.dev.\n"
          "If you're uploading a brick for the first time, please do so manually as to avoid mistakes.",
    );
    return;
  }

  core.setOutput(name: 'oldVersion', value: remoteMetadata.version);

  core.info(message: 'Remote version of ${metadata.name} is ${remoteMetadata.version}');

  // Compare versions
  final version = Version.parse(metadata.version);
  final remoteVersion = Version.parse(remoteMetadata.version);

  if (version == remoteVersion) {
    core.info(
      message: 'Skipping upload of ${metadata.name} as local version (${version})'
          ' matches remote version (${remoteVersion})',
    );
    return;
  }

  if (version < remoteVersion) {
    core.setFailed(
      message: 'Refusing to upload ${metadata.name} as local version (${version})'
          ' is before remote version (${remoteVersion})',
    );
    return;
  }

  // Check for dry run
  if (dryRun) {
    core.info(message: 'Skipping upload because dryRun was set');
    return;
  }

  // Upload brick
  core.info(message: 'Uploading ${metadata.name} ${version} to brickhub.dev...');

  final bundle = await createBundle(Directory(path));
  await api.publish(bundle: await bundle.toUniversalBundle());

  core.info(message: 'Successfully uploaded ${metadata.name} to brickhub.dev');

  api.close();
}
