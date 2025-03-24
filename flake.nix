{
  description = "Neovim config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    buildInputs = with pkgs; [
      neovim
    ];
    nvim = "${pkgs.neovim}/bin/nvim";
  in
  rec {
    tasks = {
      hello = {
        buildInputs = with pkgs; [ neofetch ];
        script = ''
          "${pkgs.neofetch}/bin/neofetch"
          echo "Hello Nix Tasks"
        '';
      };
      default = {
        script = ''
          echo "Run tasks with nix run .#taskname"
          echo ""
          echo "List of available tasks"
          echo "${builtins.concatStringsSep "\n" (builtins.attrNames (builtins.removeAttrs self.tasks ["default"]))}"
        '';
      };
    };

    devShell."${system}" = nixpkgs.mkShell {
      inherit buildInputs;
    };

    apps."${system}" = builtins.mapAttrs(name: task: {
      type = "app";
      program = 
      (let script = pkgs.writeShellScriptBin "script" task.script; 
      in "${script}/bin/script");
      buildInputs = task.buildInputs;
    }) self.outputs.tasks;
  };
}
