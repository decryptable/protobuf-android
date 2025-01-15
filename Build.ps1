param(
    [string]$ndkPath,
    [string]$abi
)

# Paths
$protobufSourcePath = "$env:GITHUB_WORKSPACE/protobuf-source"
$buildDirBase = "$env:GITHUB_WORKSPACE/build"
$outputDirBase = "$env:GITHUB_WORKSPACE/output"

# Validate if the NDK path exists
if (-Not (Test-Path $ndkPath)) {
    Write-Host "Error: NDK path does not exist: $ndkPath"
    exit 1
}

# Validate if the protobuf source path exists
if (-Not (Test-Path $protobufSourcePath)) {
    Write-Host "Error: Protobuf source path does not exist: $protobufSourcePath"
    exit 1
}

# Create build and output directories
$buildDir = "$buildDirBase\$abi"
$outputDir = "$outputDirBase\$abi"

if (Test-Path $buildDir) {
    Write-Host "Removing existing build directory: $buildDir"
    Remove-Item -Recurse -Force $buildDir
}
Write-Host "Creating build directory: $buildDir"
New-Item -Path $buildDir -ItemType Directory

# Run cmake with the specified parameters
Write-Host "Running cmake for ABI: $abi"
cmake -G "MinGW Makefiles" `
    -DCMAKE_TOOLCHAIN_FILE="$ndkPath/build/cmake/android.toolchain.cmake" `
    -DANDROID_ABI="$abi" `
    -DANDROID_PLATFORM=21 `
    -DCMAKE_C_COMPILER="$ndkPath/toolchains/llvm/prebuilt/windows-x86_64/bin/clang.exe" `
    -DCMAKE_CXX_COMPILER="$ndkPath/toolchains/llvm/prebuilt/windows-x86_64/bin/clang++.exe" `
    -DCMAKE_MAKE_PROGRAM="$ndkPath/prebuilt/windows-x86_64/bin/make.exe" `
    -Dprotobuf_BUILD_TESTS=OFF `
    -Dprotobuf_BUILD_SHARED_LIBS=OFF `
    -Dprotobuf_ABSL_PROVIDER=package `
    -DCMAKE_INSTALL_PREFIX="$($outputDir)" `
    -Wno-deprecated `
    "$protobufSourcePath"

# Build and install
Write-Host "Building and installing Protobuf for ABI: $abi"
cmake --build .
cmake --install .

# Optional: Compress the output
$zipPath = "$env:GITHUB_WORKSPACE/protobuf-$abi-${GITHUB_REF##*/}.zip"
Write-Host "Compressing build output to: $zipPath"
Compress-Archive -Path "$env:GITHUB_WORKSPACE/output/$abi/*" -DestinationPath $zipPath

Write-Host "Build process for ABI: $abi completed successfully."
