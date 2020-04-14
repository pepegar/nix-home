self: pkgs:

with pkgs;

let

in {
  rofi-vpn = writeShellScriptBin "rofi-vpn" ''
  function show_available_vpns {
    ${pkgs.networkmanager}/bin/nmcli --get type,name connection show | grep '^vpn' | cut -d: -f2
  }


  function shutdown_active_vpns {
    local ACTIVE_VPNS=( ''${(f)"$(${pkgs.networkmanager}/bin/nmcli --get type,name connection show --active | grep '^vpn' | cut -d: -f2)"} )
    local VPN
    for VPN in ''${ACTIVE_VPNS[@]}; do
      ${pkgs.networkmanager}/bin/nmcli connection down $VPN >/dev/null || true
    done
  }


  if [ -z $1 ]; then
    show_available_vpns
    echo Shutdown
  else
    (
      shutdown_active_vpns
      [ "x$1" -eq "xShutdown" ] || ${pkgs.networkmanager}/bin/nmcli connection up "$1" >/dev/null
    ) &
  fi
  '';
}
