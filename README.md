# Conan Model

## Purpose

Project that can be used as a base for other existing projects using Conan and basic logging

## Setup

In order to get started you will need to satisfy the following requirements:

- Having a C++20 capable build environment
- At least CMake v3.25 (to take advantage of presets when working locally)
- At least Conan v1.51

### Windows with MSYS2 configuration and manual dependencies configuration

> :warning: MSYS/MSYS2 with Conan is not at the moment available, although we hope it can be available in the future.
> So for now its configuration for MSYS/MSYS2 is the same as the manual configuration without using Conan for the dependencies.

Execute the script `install/download_manually_project_prerequisites.sh` to automatically download an unzip the necessary files
or follow the instructions inside the script if you prefer doing a manual download and unzip.

In case of using MSYS/MSYS2 execute the script `install/install_prerequisites_for_MSYS2.sh` to install and autoconfigure
or follow the instructions inside the script if you prefer doing a manual download of the necessary files.

### Windows with MSYS2 UCRT64 configuration

> :warning: before proceeding with this configuration follow the steps for MSYS/MSYS2 configuration previously.

Execute the script `install/install_extra_prerequisites_for_MSYS2-UCRT64.sh` to install and autoconfigure
or follow the instructions inside the script if you prefer doing a manual download of the extra files for MSYS2-UCRT64.

### Windows with MSVC Conan configuration

> :warning: Please set before your Conan parent user folder with `setx CONAN_USER_HOME %USERPROFILE%`.
> It assumes the Conan default configuration is present.
> If you want to reset your Conan user configuration please first remove your user .conan folder with `rmdir /s /q %CONAN_USER_HOME%\.conan`.
> Then you can reinstall it again with `conan config install -t dir %CONAN_USER_HOME%\.conan`.

Execute the script `install/configure_conan_for_windows.bat` to autoconfigure
or follow the instructions inside the script if you prefer doing a manual configuration of Conan with MSVC.

### Linux and Mac Conan Configuration

> :warning: This **must** be done before any usage!
> It assumes the default configuration is present. This can reset yours with `conan config init --force`.
> Old packages in your local conan cache will become invalid. This can be cleared using `conan remove -f '*'`.

Install the extended settings model, setup the custom remote, and configure the necessary settings:

```sh
conan config install -t dir .conan
```

#### Targeting different `C` library implementations

> :information_source: This is only relevant to Linux with GCC and is primarily for the continuous integration and delivery automation

The Conan default `settings.yml` does not take these into account. You will need to sign into the `conan-model-exe` remote that was installed with the configuration to download any pre-compiled binaries.

The settings model can be extended by configuring your default profile (or build settings)

```sh
conan profile update settings.compiler.musl=1.2 default
# or
conan profile update settings.compiler.glibc=2.32 default
```

For more option see [Profiles](https://docs.conan.io/en/latest/reference/profiles.html) documentation.

### Conan Install

Conan takes the "tool integration" approach that CMake offers and no longer supports being called from CMake.
This means you'll need to call `conan install` before you start working.

```sh
# Prepare Conan
conan lock create conanfile.py --version=0.0.0 -pr:b=default --lockfile=conan.lock --lockfile-out=build/conan.lock
conan install conanfile.py --lockfile=build/conan.lock -if build
```

### Configure CMake

```sh
# Configure CMake
cmake --preset release -B build

# Build
cmake --build build/
```

#### Using Ninja

If you would like to improve build times, [Ninja](https://ninja-build.org/manual.html) is a great way to get that with little effort.
Simply use the provided `ninja` profile when preparing Conan.

```sh
conan lock create conanfile.py --version=0.0.0 -pr:h=ninja -pr:b=ninja --lockfile=conan.lock --lockfile-out=build/conan.lock
conan install conanfile.py --lockfile=build/conan.lock -if build
```

### Setting up in Debug

Generate a lockfile with the provided `debug` profile and run the `conan install` command.

```sh
conan lock create conanfile.py --version=0.0.0 -pr:h=debug -pr:b=debug --lockfile=conan.lock --lockfile-out=build/conan.lock
conan install conanfile.py --lockfile=build/conan.lock -if build
```

Select the `debug` preset when configuration CMake

```sh
cmake --preset debug -B build
```

### VS Code and Extensions

The bare minium to work on the Conan Model is

- [C/C++ Extension Pack v1.2.0](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-extension-pack)

For the CMake extension, make sure you have at least version 1.12.3 or greater installed so it can
take advantage of the features Conan offers. You may need to install the [nightly preview](https://github.com/microsoft/vscode-cmake-tools/pull/2544#issuecomment-1164797621).

- [CMake Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools)

:information_source: It's important to note that the opening VS Code before `conan install` may populate a CMake cache that
does not load the toolchain. If the `Using Conan toolchain` does not appear in the logs, delete your `CMakeCache.txt` and try again.

## Development

### CMake configuration and options

Configuring CMake with conan configuration using `cmake --preset release -S . -B build`.
or CMake with manual dependencies configuration using `cmake -S . -B build/out -G "Ninja" --log-level=ERROR -D CONAN_SETUP=OFF`.

You can also add this definitions flags to your CMake command to enable:

- building tests: `-D BUILD_TESTS=ON`
- running linters (checks the code style): `-D RUN_TIDY=ON`

## Conan usage

### Updating dependencies

To update the top level `conan.lock` run:

```sh
conan lock create conanfile.py --version=1.0.0-dev.1 --base --update
```

You'll also need to refresh the Conan lockfile and generated information.
Simply re-run the [`conan install`](#conan-install) command.

### Lock Dependency Graph

```sh
conan lock create conanfile.py --version 1.0.0-dev.1+`git rev-parse --short HEAD` --lockfile=conan.lock --lockfile-out=build/conan.lock -pr:b=default
```

### Package

```sh
conan create conanfile.py 1.0.0-dev.1+`git rev-parse --short HEAD`@ --lockfile build/conan.lock
```

### Install Application

> :notebook: This step requires the [packing](#package) to be completed first

```sh
conan install conan-model-exe/1.0.0-dev.1+`git rev-parse --short HEAD`  --lockfile build/conan.lock
```

## Docker usage

### Build Docker Image

```sh
docker build . -f Dockerfile -t conan-model-exe:1.0.0-dev.1 # Docker does not support SemVer build information
```

## Run Container

```sh
docker run --rm -d -p 8443:8443 -v "$(pwd):/dist" conan-model-exe:1.0.0-dev.1
```

> :notebook: By default the image is setup for HTTPS for unsecure transport use the following

```sh
docker run --rm -d -p 8080:8080 -v "$(pwd):/dist" conan-model-exe:1.0.0-dev.1 dist -a "0.0.0.0" -p 8080 -n 4
```
