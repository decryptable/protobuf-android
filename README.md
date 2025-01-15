




<div align="center">
  <h1> Protobuf Android </h1>
  
  <img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/decryptable/protobuf-android/protobuf-android.yaml?branch=main&label=Build%20Status">
  <img alt="Latest Release" src="https://img.shields.io/github/v/release/decryptable/protobuf-android?label=Release">

  <br>
  <br>
</div>

This repository provides an automated workflow for building and packaging [Protocol Buffers (Protobuf)](https://github.com/protocolbuffers/protobuf) libraries for Android platforms. It includes a PowerShell script and GitHub Actions workflow to streamline the build process across multiple Android ABIs.

## Features

- Automates Protobuf library builds for Android ABIs: `arm64-v8a`, `armeabi-v7a`, `x86_64`, and `x86`.
- Generates output artifacts for each ABI in `.zip` format.
- Includes a CI/CD pipeline for building and uploading artifacts to GitHub Releases.

## Repository Structure

### 1. [Build.ps1](./Build.ps1)

A PowerShell script that:
- Compiles the Protobuf source code using Android NDK.
- Generates separate build outputs for supported ABIs.
- Compresses build outputs into `.zip` files.

**Usage:**
```powershell
BuildProtobuf -protobufSourcePath <Path_to_Protobuf_Source> -ndkPath <Path_to_NDK>
```

**Parameters:**
- `protobufSourcePath`: Path to the Protobuf source directory.
- `ndkPath` (optional): Path to the Android NDK. Defaults to the `ANDROID_NDK` environment variable.
- `buildDirBase` (optional): Base directory for intermediate build files. Defaults to `$PWD/build`.
- `outputDirBase` (optional): Base directory for final outputs. Defaults to `$PWD/output`.
- `abis` (optional): Array of ABIs to build for. Defaults to `@("arm64-v8a", "armeabi-v7a", "x86_64", "x86")`.

---

### 2. .github/workflows/protobuf-android.yaml

A GitHub Actions workflow that:
- Builds the Protobuf library for Android using the `Build.ps1` script.
- Runs on `windows-latest` to ensure compatibility with the NDK and toolchain.
- Uploads the built artifacts as assets in a GitHub Release.

**Triggers:**
- Pushes to any `v*` tag.
- Manual dispatch via the GitHub Actions interface.

**Steps Overview:**
1. Checkout the Protobuf source repository (with submodules).
2. Set up the Android NDK using the `nttld/setup-ndk` action.
3. Execute the `Build.ps1` script for building Protobuf libraries.
4. Upload the `.zip` artifacts to the corresponding GitHub Release.

---

## Getting Started

### Prerequisites

- **Windows** with PowerShell 5.1 or later.
- **Android NDK** (r27c or compatible).
- **Protocol Buffers Source Code**.

### How to Use

1. Clone this repository:
   ```bash
   git clone https://github.com/decryptable/protobuf-android.git
   cd protobuf-android
   ```

2. Run the `Build.ps1` script with appropriate parameters:
   ```powershell
   .\Build.ps1 -protobufSourcePath "path_to_protobuf_source" -ndkPath "path_to_ndk"
   ```

3. Check the `output` directory for generated `.zip` files.

---

## GitHub Actions CI/CD

To trigger the CI/CD pipeline:
1. Create a new tag following the format `v*` (e.g., `v1.0.0`).
2. Push the tag to GitHub:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

The workflow will automatically build and upload the Protobuf libraries to the GitHub Release page.

---

## Contributing

Contributions are welcome! Please feel free to open issues or submit pull requests for bug fixes, new features, or enhancements.

---

## License

This repository is licensed under the [MIT License](LICENSE). Please check the Protobuf repository for its own licensing terms.

---

## Acknowledgments

- [Protocol Buffers](https://github.com/protocolbuffers/protobuf) by Google.
- [Android NDK](https://developer.android.com/ndk).
- GitHub Actions community for providing reusable workflows.
