# devenv

Personal development environments using [devenv](https://devenv.sh/).

## Attaching a project

A project's `.envrc` is one line naming a config:

```sh
source ~/devenv/_shared/envrc scratch3
source ~/devenv/_shared/envrc scratch3 --profile android
source ~/devenv/_shared/envrc python-ai --profile py310
```

Then run `direnv allow`. Anything after the config name is passed to devenv. Under the hood this is
`devenv --from path:<config>`, so the project needs no `devenv.yaml` or `devenv.nix` of its own and keeps its own
`.devenv/`. If the project has an `.nvmrc`, its major version picks the Node.js package.

A repo without its own `.envrc` (e.g. a checkout nested under `~/scratch`) gets the parent's environment. If that
repo's `.nvmrc` wants a different Node, `node`, `npm` and `npx` refuse to run and print the line to add. Set
`DEVENV_IGNORE_NVMRC=1` to run them anyway.

| Config | What it's for | Profiles |
| --- | --- | --- |
| `scratch3` | Scratch web projects | `android`: Android SDK, emulator, Android Studio |
| `python-ai` | Python with CUDA (3.12) | `py310`: Python 3.10 |
| `rust` | Rust | |
| `bevy` | Rust with Bevy's native libraries | |
| `nix` | Nix (this repo, nixos-config) | |
| `generic` | Common tooling only | |

`_shared/` holds the modules the configs import. `_skeleton/` is a starting point for a new config, with every
formatter and hook listed to prune from.

## Updating

`./update-all.sh` updates every config's `devenv.lock`, builds it and each of its profiles, and commits the locks
that built. A config whose update fails to build keeps its old lock.

Projects pick up the new pins on their next direnv reload. Under `--from`, devenv would otherwise resolve a project's
own pins, so `_shared/envrc` copies the config's lock into the project whenever the config's lock is newer.

## Workarounds worth knowing about

- **Git hooks** (`_shared/common`): hooks install into `.devenv/git-hooks/` through a chainer instead of
  `.git/hooks`. The chainer runs prek, then the repo's own hooks, so husky keeps working. It only runs prek hooks
  belonging to the repo git is in, because the hooks-path override follows the environment into other repos.
- **Android** (`_shared/android`):
  - devenv's "latest" `cmdline-tools` sorts versions as strings, so the config picks the newest one itself.
  - devenv adds build-tools and NDK library paths that crash the emulator, so they're removed again.
  - AVDs and adb keys live in `~/.android`, shared by every project and by Android Studio.
- **treefmt** (`_shared/common`): devenv's treefmt module would format the whole tree on every shell entry. Here it
  only formats at commit, and every enabled formatter is on PATH for editors.
