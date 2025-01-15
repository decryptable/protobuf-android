function BuildProtobuf {
    param(
        [string]$protobufSourcePath,
        [string]$ndkPath = $env:ANDROID_NDK,
        [string]$buildDirBase = "$PWD/build",
        [string]$outputDirBase = "$PWD/output",
        [array]$abis = @("arm64-v8a", "armeabi-v7a", "x86_64", "x86")
    )
    
        try {
        Remove-Item -Recurse -Force $outputDirBase
        } catch {}
    
        try {
        Remove-Item -Recurse -Force "$buildDirBase/*/_deps"
        } catch {}


    foreach ($abi in $abis) {
        $buildDir = "$buildDirBase/$abi"
        $outputDir = "$outputDirBase/$abi"
        
        try {
            Remove-Item -Recurse -Force $buildDir
        } catch {}

        New-Item -Path $buildDir -ItemType Directory
        Set-Location -Path $buildDir

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
            -DCMAKE_INSTALL_PREFIX="$outputDir" `
            -Wno-deprecated `
            "$protobufSourcePath"

        cmake --build .
        cmake --install .

        Write-Host "Protobuf build for ABI $abi is complete."

        # Create a zip file for the output directory
        $zipFile = "$PWD/protobuf_android-$abi.zip"
        Compress-Archive -Path $outputDir\* -DestinationPath $zipFile

        Write-Host "Zipped output for ABI $abi into $zipFile."
    }

    Write-Host "Protobuf build and zipping for all ABIs is complete."
}