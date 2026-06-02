{
  description = "Halley Wayland compositor flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      overlays.default = final: prev: {
        halley = final.callPackage ./pkgs/halley.nix { };
      };

      nixosModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.programs.halley;
        in {
          options.programs.halley = {
            enable = lib.mkEnableOption "the Halley Wayland compositor";

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.system}.halley;
              defaultText = lib.literalExpression "self.packages.${pkgs.system}.halley";
              description = "The Halley package to use.";
            };

            extraPackages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = with pkgs; [
                fuzzel
                xwayland-satellite
                xdg-desktop-portal-gtk
                xdg-desktop-portal-wlr
              ];
              description = "Extra runtime packages commonly used with Halley.";
            };
          };

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;
            services.displayManager.sessionPackages = [ cfg.package ];
            services.seatd.enable = lib.mkDefault true;
            programs.xwayland.enable = lib.mkDefault true;
          };
        };
    } // flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in {
        packages = {
          halley = pkgs.halley;
          default = pkgs.halley;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ pkgs.halley ];
          nativeBuildInputs = with pkgs; [
            cargo
            rustc
            rust-analyzer
            pkg-config
          ];
        };
      });
}
