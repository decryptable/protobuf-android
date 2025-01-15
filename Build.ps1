function BuildProtobuf {
    param(
        [string]$protobufSourcePath,
        [string]$ndkPath = $env:ANDROID_NDK,
        [string]$buildDirBase = "$PWD/build",
        [string]$outputDirBase = "$PWD/output",
        [array]$abis = @("arm64-v8a")
    )

    
    try {
    Remove-Item -Recurse -Force $outputDirBase -ErrorAction SilentlyContinue
    }
    catch {
    }

    try {
    Remove-Item -Recurse -Force "$buildDirBase/*/_deps" -ErrorAction SilentlyContinue
    }
    catch {}

    foreach ($abi in $abis) {
        $buildDir = "$buildDirBase/$abi"
        $outputDir = "$outputDirBase/$abi"
        
        try {
            Remove-Item -Recurse -Force $buildDir -ErrorAction SilentlyContinue
        } catch {}

        New-Item -Path $buildDir -ItemType Directory -ErrorAction SilentlyContinue
        Set-Location -Path $buildDir

        cmake -G "MinGW Makefiles" `
            -DCMAKE_TOOLCHAIN_FILE="$ndkPath/build/cmake/android.toolchain.cmake" `
            -DANDROID_ABI="$abi" `
            -DANDROID_PLATFORM=21 `
            -DABSL_PROPAGATE_CXX_STD=ON `
            -DCMAKE_C_COMPILER="$ndkPath/toolchains/llvm/prebuilt/windows-x86_64/bin/clang.exe" `
            -DCMAKE_CXX_COMPILER="$ndkPath/toolchains/llvm/prebuilt/windows-x86_64/bin/clang++.exe" `
            -DCMAKE_MAKE_PROGRAM="$ndkPath/prebuilt/windows-x86_64/bin/make.exe" `
            -Dprotobuf_BUILD_TESTS=OFF `
            -Dprotobuf_BUILD_SHARED_LIBS=OFF `
            -Dprotobuf_ABSL_PROVIDER=package `
            -DCMAKE_INSTALL_PREFIX="$outputDir" `
            -Wno-deprecated `
            "$protobufSourcePath"

        cmake --build . --target libprotobuf protobuf-lite --parallel=10 --clean-first --resolve-package-references=on
        cmake --install . --parallel=10

        Write-Host "Protobuf build for ABI $abi is complete."

        # Create a zip file for the output directory
        $zipFile = "$(Get-Location)/protobuf_android-$abi.zip"
        
        if (Test-Path "$outputDir\*") {
            Compress-Archive -Path "$outputDir\*" -DestinationPath $zipFile
            Write-Host "Zipped output for ABI $abi into $zipFile."
        } else {
            Write-Host "Output directory for ABI $abi is empty. Skipping zip."
        }
        
    }

    Write-Host "Protobuf build and zipping for all ABIs is complete."

    Set-Location -Path $protobufSourcePath
}