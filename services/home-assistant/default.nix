{pkgs, ...}: {
  systemd.services.glances = {
    enable = true;
    description = "glances";
    unitConfig = {Type = "simple";};
    serviceConfig = {ExecStart = "${pkgs.glances}/bin/glances -w";};
    wantedBy = ["multi-user.target"];
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = ["hass"];
    ensureUsers = [
      {
        name = "hass";
        ensureDBOwnership = true;
      }
    ];
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
          "webostv"
          "enphase_envoy"
          "roomba"
          "radio_browser"
          "sonos"
          "spotify"
          "homekit"
          "glances"
          "apple_tv"
        ];
        extraPackages = py: with py; [psycopg2 getmac zeroconf];
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
      lovelace = {
        mode = "yaml";
        resources = [
          {
            url = "/local/mini-graph-card-bundle.js";
            type = "module";
          }
          {
            url = "/local/stack-in-card.js";
            type = "module";
          }
          {
            url = "/local/mushroom.js";
            type = "module";
          }
        ];
      };
    };
  };
}
