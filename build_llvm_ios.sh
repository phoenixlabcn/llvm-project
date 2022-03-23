
# Bail out on error
set -e

PLATFORM="iphoneos"

LLVM_SRCDIR=$(pwd)
OSX_BUILDDIR=$(pwd)/build_osx
IOS_BUILDDIR=$(pwd)/build-iphoneos
SIM_BUILDDIR=$(pwd)/build-iphonesimulator


TOOL_CHAIN=$LLVM_SRCDIR/llvm/cmake/platforms/iOS.cmake
LLVM_INSTALL_DIR=$LLVM_SRCDIR/LLVM-$PLATFORM
LIBFFI_INSTALL_DIR=$LLVM_SRCDIR/libffi/Release-$PLATFORM

OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)


echo "Compiling for iOS:"
rm -rf $IOS_BUILDDIR
rm -rf $LLVM_INSTALL_DIR

if [ ! -d $IOS_BUILDDIR ]; then
  mkdir $IOS_BUILDDIR
fi


rm -rf $LLVM_INSTALL_DIR

ARCH="AArch64"


ARCH="arm64"

pushd $IOS_BUILDDIR
CMAKE_ARGS=(-G  "Ninja" \
-DLLVM_LINK_LLVM_DYLIB=ON \
-DCMAKE_INSTALL_PREFIX=$LLVM_INSTALL_DIR \
-DLLVM_TARGET_ARCH=$ARCH \
-DCMAKE_OSX_ARCHITECTURES=$ARCH \
-DLLVM_TARGETS_TO_BUILD="AArch64" \
-DLLVM_ENABLE_PROJECTS='clang' \
-DLLVM_DEFAULT_TARGET_TRIPLE=arm64-apple-darwin \
-DCMAKE_BUILD_TYPE=Release \
-DLLVM_ENABLE_THREADS=OFF \
-DLLVM_ENABLE_UNWIND_TABLES=OFF \
-DLLVM_ENABLE_EH=OFF \
-DLLVM_ENABLE_RTTI=OFF \
-DLLVM_ENABLE_TERMINFO=OFF \
-DLLVM_ENABLE_BACKTRACES=OFF \
-DLLVM_ENABLE_FFI=ON \
-DFFI_INCLUDE_DIR=$LIBFFI_INSTALL_DIR/include/ffi \
-DFFI_LIBRARY_DIR=$LIBFFI_INSTALL_DIR \
-DCMAKE_CROSSCOMPILING=TRUE \
-DLLVM_OPTIMIZED_TABLEGEN=OFF \
-DCMAKE_OSX_SYSROOT=${IOS_SDKROOT} \
-DLLVM_BUILD_RUNTIME=OFF \
-DLLVM_INCLUDE_TESTS=OFF \
-DHAVE_POSIX_REGEX=0 \
-DHAVE_STEADY_CLOCK=0 \
-DLLVM_INCLUDE_EXAMPLES=OFF \
-DCMAKE_C_COMPILER=$(xcrun --sdk iphoneos -f clang) \
-DCMAKE_CXX_COMPILER=$(xcrun --sdk iphoneos -f clang++) \
-DCMAKE_ASM_COMPILER=$(xcrun --sdk iphoneos -f cc) \
-DCMAKE_LIBRARY_PATH=${IOS_SDKROOT}/lib/ \
-DCMAKE_INCLUDE_PATH=${IOS_SDKROOT}/include/ \
-DCMAKE_TOOLCHAIN_FILE=$TOOL_CHAIN \
)

#-DCMAKE_MODULE_LINKER_FLAGS="-lobjc -lc -lc++ " \
#-DCMAKE_SHARED_LINKER_FLAGS="-lobjc -lc -lc++ " \
#-DCMAKE_EXE_LINKER_FLAGS="-lobjc -lc -lc++ " \


CMAKE_ARGS+=(-DCMAKE_C_FLAGS="-arch arm64 -target arm64-apple-darwin -D_LIBCPP_STRING_H_HAS_CONST_OVERLOADS  -I${LLVM_SRCDIR} ")


CMAKE_ARGS+=(-DCMAKE_CXX_LINK_FLAGS="-arch arm64 -target arm64-apple-darwin -D_LIBCPP_STRING_H_HAS_CONST_OVERLOADS -I${LLVM_SRCDIR}")

pwd
printf 'CMake Argument: %s\n' "${CMAKE_ARGS[@]}"


cmake "${CMAKE_ARGS[@]}" ../llvm

cmake --build .


rm -f lib/libclang_tool.a
rm -f lib/libopt.a
ar -r lib/libclang_tool.a tools/clang/tools/driver/CMakeFiles/clang.dir/driver.cpp.o tools/clang/tools/driver/CMakeFiles/clang.dir/cc1_main.cpp.o tools/clang/tools/driver/CMakeFiles/clang.dir/cc1as_main.cpp.o tools/clang/tools/driver/CMakeFiles/clang.dir/cc1gen_reproducer_main.cpp.o
ar -r lib/libopt.a  tools/opt/CMakeFiles/opt.dir/AnalysisWrappers.cpp.o tools/opt/CMakeFiles/opt.dir/BreakpointPrinter.cpp.o  tools/opt/CMakeFiles/opt.dir/GraphPrinters.cpp.o tools/opt/CMakeFiles/opt.dir/NewPMDriver.cpp.o tools/opt/CMakeFiles/opt.dir/PassPrinters.cpp.o tools/opt/CMakeFiles/opt.dir/PrintSCC.cpp.o tools/opt/CMakeFiles/opt.dir/opt.cpp.o

popd


echo "Build For iOS Done!"
echo
