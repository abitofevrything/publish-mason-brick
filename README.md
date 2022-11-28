# Publish Mason Brick Action

This action automatically publishes [Mason](https://pub.dev/packages/mason_cli) bricks to https://brickhub.dev if a version change is detected.

## Inputs
#### `path`

Optional, defaults to the repository root.

The path, relative to the repository root, of the brick to publish. This is the path to the directory containing the `brick.yaml` file, not the `brick.yaml` file itself.

#### `email`

Required.

The email to use when logging in to https://brickhub.dev.

#### `password`

Required.

The password to use when logging in to https://brickhub.dev.

#### `dryRun`

Optional, defaults to `false`.

Whether a dry run should be done. No bricks will be uploaded if this is set to true.

## Outputs
#### `name`

The name of the brick being uploaded.

#### `version`

The local version of the brick being uploaded.

#### `oldVersion`

The version of the brick on https://brickhub.dev prior to uploading it.
