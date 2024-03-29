self: pkgs:

with pkgs;

let
  script = ''
    #!/bin/zsh
    #
    # rofi-mode to connect to a selected VPN connection via nmcli


    function show_available_vpns {
    	nmcli --get type,name connection show | grep '^vpn' | cut -d: -f2
    }

    function shutdown_active_vpns {
    	local ACTIVE_VPNS=$(nmcli --get type,name connection show --active | grep '^vpn' | cut -d: -f2)
    	local VPN
    	for VPN in ''${ACTIVE_VPNS[@]}; do
    		nmcli connection down $VPN >/dev/null || true
    	done
    }


    if [ -z $1 ]; then
    	show_available_vpns
    	echo Shutdown
    else
    	(
    		shutdown_active_vpns
    		[ "x$1" -eq "xShutdown" ] || nmcli connection up "$1" >/dev/null
    	) &
    fi
  '';
in { rofi-vpn = writeShellScriptBin "rofi-vpn" script; }
