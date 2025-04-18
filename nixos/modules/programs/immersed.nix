{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.immersed;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [
        "programs"
        "immersed-vr"
      ]
      [
        "programs"
        "immersed"
      ]
    )
  ];

  options = {
    programs.immersed = {
      enable = lib.mkEnableOption "immersed";

      openPorts = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open firewall ports for Immersed";
      };

      package = lib.mkPackageOption pkgs "immersed" { };
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      kernelModules = [
        "v4l2loopback"
        "snd-aloop"
      ];
      extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
      extraModprobeConfig = ''
        options v4l2loopback exclusive_caps=1 card_label="v4l2loopback Virtual Camera"
      '';
    };

    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf cfg.openPorts {
      allowedTCPPorts = [ 21000 ];
      allowedUDPPorts = [
        21000
        21010
      ];
    };
  };

  meta.maintainers = pkgs.immersed.meta.maintainers;
}
