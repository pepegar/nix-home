# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "marge"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Atlantic/Canary";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.utf8";
    LC_IDENTIFICATION = "es_ES.utf8";
    LC_MEASUREMENT = "es_ES.utf8";
    LC_MONETARY = "es_ES.utf8";
    LC_NAME = "es_ES.utf8";
    LC_NUMERIC = "es_ES.utf8";
    LC_PAPER = "es_ES.utf8";
    LC_TELEPHONE = "es_ES.utf8";
    LC_TIME = "es_ES.utf8";
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Configure keymap in X11
  services.xserver = {
    layout = "es";
    xkbVariant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "es";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pepe = {
    isNormalUser = true;
    description = "pepe";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    tailscale
    htop
    glances
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.tailscale.enable = true;

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
  
    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
  
    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";
  
    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2
  
      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi
  
      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up -authkey tskey-auth-kwwBCe4CNTRL-YGV2GY85vR4VeJ1qM1SDT4VTmnPFSMxVA
    '';
  };

  systemd.services.glances = {
    enable = true;
    description = "glances";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      ExecStart = "${pkgs.glances}/bin/glances -w";
    };
    wantedBy = ["multi-user.target"];
  };

  services.home-assistant = {
    enable = true;
    package = (pkgs.home-assistant.override {
      extraComponents = [
        "default_config"
        "esphome"
        "met"
        "aemet"
        "backup"
        "shelly"
        "enphase_envoy"
        "roomba"
        "radio_browser"
        "sonos"
        "spotify"
        "homekit"
        "glances"
      ];
      extraPackages = py: with py; [
        psycopg2
        getmac
      ];
    }).overrideAttrs (oldAttrs: {
      # Don't run package tests, they take a long time
      doInstallCheck = false;
    });
    config = {
      homeassistant = {
        latitude = 29.051456;
        longitude = -13.644630;
      };
      recorder.db_url = "postgresql://@/hass";
      default_config = {};
      "automation manual" = [];
      "automation ui" = "!include automations.yaml";
      template = [
       { 
         unique_id = "sensor.grid_import_power";
         sensor = {
           name = "Grid Import Power";
           state_class = "measurement";
           icon = "mdi:transmission-tower";
           unit_of_measurement = "W";
           device_class = "power";
           state = "{{ [0, states('sensor.envoy_122203094420_current_power_consumption') | int - states('sensor.envoy_122203094420_current_power_production') | int ] | max }}";
         };
       }
       { 
         unique_id = "sensor.grid_export_power";
         sensor = {
           name = "Grid Export Power";
           state_class = "measurement";
           icon = "mdi:transmission-tower";
           unit_of_measurement = "W";
           device_class = "power";
           state = "{{ [0, states('sensor.envoy_122203094420_current_power_production') | int - states('sensor.envoy_122203094420_current_power_consumption') | int ] | max }}";
         };
       }
      ];
      sensor = [
        {
          platform = "integration";
          name = "Grid Import Energy";
          source = "sensor.grid_import_power";
          unit_prefix = "k";
          unit_time = "h";
          method = "left";
        }
        {
          platform = "integration";
          name = "Grid Export Energy";
          source = "sensor.grid_export_power";
          unit_prefix = "k";
          unit_time = "h";
          method = "left";
        }
      ];
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "hass" ];
    ensureUsers = [{
      name = "hass";
      ensurePermissions = {
        "DATABASE hass" = "ALL PRIVILEGES";
      };
    }];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
