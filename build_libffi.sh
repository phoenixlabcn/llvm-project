export REPO_ROOT=`pwd`

PLATFORM="iphoneos"
LIBFFI_BUILD_DIR=$REPO_ROOT/libffi

echo "Build libffi for $PLATFORM"

cd $REPO_ROOT
cd libffi

case $PLATFORM in
        "iphoneos"|"iphonesimulator")
            SDK_ARG=(-sdk $PLATFORM);;

        "maccatalyst")
            SDK_ARG=();; # Do not set SDK_ARG

        *)
echo "Unknown or missing platform!"
exit 1;;
esac

for r in {1..2}; do
        xcodebuild -scheme libffi-iOS ${SDK_ARG[@]} -configuration Release SYMROOT="$LIBFFI_BUILD_DIR" >/dev/null 2>/dev/null
done

cp Release-iphoneos/libffi.a $REPO_ROOT/xcode_project/llvm/LLVM/libffi.a
