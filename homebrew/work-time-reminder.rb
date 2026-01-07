# Homebrew Cask formula for Work Time Reminder
# This file should be placed in your homebrew-tap repository
# Repository: github.com/tungtt22/homebrew-tap
# Path: Casks/work-time-reminder.rb

cask "work-time-reminder" do
  version "1.0.0"
  sha256 "REPLACE_WITH_ACTUAL_SHA256"

  url "https://github.com/tungtt22/WorkTimeReminder/releases/download/v#{version}/WorkTimeReminder-#{version}.zip"
  name "Work Time Reminder"
  desc "macOS menu bar app that reminds you to take regular breaks"
  homepage "https://github.com/tungtt22/WorkTimeReminder"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "WorkTimeReminder.app"

  zap trash: [
    "~/Library/Preferences/com.yourname.WorkTimeReminder.plist",
  ]
end

