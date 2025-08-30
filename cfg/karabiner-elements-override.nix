{
  config,
  lib,
  ...
}:
with lib; {
  # Override the karabiner-elements service to fix plist file paths for newer versions
  #
  # In Karabiner Elements 15.4.0+, the plist files moved from:
  #   /Library/LaunchAgents/org.pqrs.karabiner.*.plist
  # to:
  #   /Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Non-Privileged Agents.app/Contents/Library/LaunchAgents/org.pqrs.service.agent.*.plist
  #
  # This override fixes the nix-darwin karabiner-elements service to use the correct paths.
  config = mkIf config.services.karabiner-elements.enable {
    # Override the problematic userLaunchAgents from the original module with correct paths
    environment.userLaunchAgents = {
      # Override the old plist files that don't exist in newer versions
      "org.pqrs.karabiner.agent.karabiner_grabber.plist".source =
        mkForce
        "${cfg.package}/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Non-Privileged Agents.app/Contents/Library/LaunchAgents/org.pqrs.service.agent.karabiner_grabber.plist";

      "org.pqrs.karabiner.agent.karabiner_observer.plist".source =
        mkForce
        "${cfg.package}/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Non-Privileged Agents.app/Contents/Library/LaunchAgents/org.pqrs.service.agent.karabiner_session_monitor.plist";

      "org.pqrs.karabiner.karabiner_console_user_server.plist".source =
        mkForce
        "${cfg.package}/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Non-Privileged Agents.app/Contents/Library/LaunchAgents/org.pqrs.service.agent.karabiner_console_user_server.plist";

      "org.pqrs.service.agent.Karabiner-Menu.plist".source = "${cfg.package}/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Non-Privileged Agents.app/Contents/Library/LaunchAgents/org.pqrs.service.agent.Karabiner-Menu.plist";

      "org.pqrs.service.agent.Karabiner-MultitouchExtension.plist".source = "${cfg.package}/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Non-Privileged Agents.app/Contents/Library/LaunchAgents/org.pqrs.service.agent.Karabiner-MultitouchExtension.plist";

      "org.pqrs.service.agent.Karabiner-NotificationWindow.plist".source = "${cfg.package}/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Non-Privileged Agents.app/Contents/Library/LaunchAgents/org.pqrs.service.agent.Karabiner-NotificationWindow.plist";
    };
  };
}
