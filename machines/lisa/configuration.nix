{pkgs, ...}: let
  customFonts = pkgs.nerdfonts.override {fonts = ["Iosevka"];};

  myfonts = pkgs.callPackage fonts/default.nix {inherit pkgs;};
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    pulseaudio = true;
  };

  fonts.fonts = with pkgs; [customFonts font-awesome myfonts.icomoon-feather];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = ["ntfs"];

  fileSystems."/home/pepe/shared-disk" = {
    device = "/dev/sda2";
    fsType = "ntfs";
    options = ["rw" "uid=1000"];
  };

  networking.hostName = "lisa"; # Define your hostname.
  networking.networkmanager.enable =
    true; # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp5s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [wget vim samba];

  virtualisation.docker.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.tailscale.enable = true;

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = ["network-pre.target" "tailscale.service"];
    wants = ["network-pre.target" "tailscale.service"];
    wantedBy = ["multi-user.target"];

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
      ${tailscale}/bin/tailscale up -authkey tskey-k3VJLq4CNTRL-LHLygagT7dMCnYBe6w6DG
    '';
  };

  services.home-assistant = {
    enable = true;
    package =
      (pkgs.home-assistant.override {
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
        ];
        extraPackages = py:
          with py; [
            # Are you using a database server for your recorder?
            # https://www.home-assistant.io/integrations/recorder/
            #mysqlclient
            psycopg2
            getmac
          ];
      }).overrideAttrs (_: {
        # Don't run package tests, they take a long time
        doInstallCheck = false;
      });
    config = {
      homeassistant = {
        latitude = 29.051456;
        longitude = -13.64463;
      };
      recorder.db_url = "postgresql://@/hass";
      default_config = {};
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
    ensureDatabases = ["hass"];
    ensureUsers = [
      {
        name = "hass";
        ensurePermissions = {"DATABASE hass" = "ALL PRIVILEGES";};
      }
    ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound = {enable = true;};
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us,es";

    displayManager = {
      lightdm = {enable = true;};
      defaultSession = "none+xmonad";
    };

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = hp: [hp.dbus hp.monad-logger];
    };

    videoDrivers = ["nvidia"];
  };

  services.gnome.gnome-keyring.enable = true;
  services.dbus = {
    enable = true;
    packages = [];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pepe = {
    createHome = true;
    home = "/home/pepe";
    isNormalUser = true;
    extraGroups = ["wheel" "video" "audio" "disk" "docker"]; # Enable ‘sudo’ for the user.
    group = "users";
    uid = 1000;
    shell = "/home/pepe/.nix-profile/bin/zsh";
    openssh.authorizedKeys.keys = [
      "AAAAB3NzaC1yc2EAAAADAQABAAABgQCwIT82aKUShHUyT5ksmoYcye2NvMalDt1R5i0fFd7GJM+2PxefU6n1gTwGVSi0L+kto6umHPc3R8StpIj9jMkDN9MQ0NCxJb/NQdMuslg2hbDicA6zalFHNxyU4iWJ90oxqUACf0XE8WiXiuVHWIS7rDsusvL5XKf7t6f51Lket232Jjn7EL5Z9AZx7XnI7zazrmQmdDjqvdDbZLsUR2kYHn80lyvmtvNCVTT/Jur7VIKy/pGCD/qYdPqBA5gQGr/Iw61xgTngWSU3lyXmYowfP2RjXkgHVPKxZX7x5nSb7OQBeCL4jlb6GJV2wzmPthWNohvyHvlXNVgPB2gQNbXvB/jjGqZHlHNbf1Gbs8TAbF0Sxvi+cQS7cen5cO4k2aamqXHfHgtvKbMqe8f69shYeudhTVpK8nxYwffGq53CmPYOOq0l8StW7f+nn8QF6Nt7sL8Hjh2jItsBCKNYiaIZ61FO3N/+offkeWnN8Sxwq75wPqW6VQbDrmjjlrdjIJE="
    ];
  };

  nix = {
    package = pkgs.nixFlakes;
    distributedBuilds = true;
    #settings = {
    #trustedUsers = [ "root" "pepe" ];
    #};
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes
    '';
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.05"; # Did you read the comment?
}
