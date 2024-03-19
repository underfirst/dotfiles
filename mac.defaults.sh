defaults write "Apple Global Domain" com.apple.trackpad.scaling 3
defaults write "Apple Global Domain" com.apple.trackpad.forceClick 1

defaults write "com.apple.preference.trackpad" "ForceClickSavedState" '0'
defaults write "com.apple.AppleMultitouchTrackpad" "ActuateDetents" '0'
defaults write "com.apple.AppleMultitouchTrackpad" "ForceSuppressed" '1'
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerTapGesture" '0'
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerTapGesture" '0'

defaults write "Apple Global Domain" "InitialKeyRepeat" '15'
defaults write "Apple Global Domain" "KeyRepeat" '2'

defaults write "Apple Global Domain" "AppleInterfaceStyle" 'Dark'

defaults write com.apple.CrashReporter DialogType -string "none"
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g NSWindowResizeTime -float 0.001
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.TextEdit RichText -int 0
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.finder AppleShowAllFiles -bool YES
defaults write -g AppleShowAllExtensions -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE