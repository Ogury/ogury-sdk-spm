#DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData/$TARGET_NAME"
#echo "🔁 Setting DerivedData path to: $DERIVED_DATA_PATH"
#defaults write com.apple.dt.Xcode IDECustomDerivedDataLocation -string "$DERIVED_DATA_PATH"

# uncomment lines above to restore behavior with custom DD folder for each test app
if defaults read com.apple.dt.Xcode IDECustomDerivedDataLocation &>/dev/null; then
  echo "🧹 Resetting DerivedData path to default."
  defaults delete com.apple.dt.Xcode IDECustomDerivedDataLocation
else
  echo "✅ DerivedData path is already set to default."
fi