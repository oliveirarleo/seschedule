{ pkgs ? import <nixpkgs> { } }:
# https://ejpcmac.net/blog/using-nix-in-elixir-projects/

with pkgs;

let
  inherit (lib) optional optionals;
  erlang = pkgs.beam.interpreters.erlangR27_odbc_javac;
  elixir = pkgs.beam.packages.erlangR27.elixir_1_17;
in

mkShell {
  buildInputs = [ elixir erlang git fwup squashfsTools file ]
    ++ optional stdenv.isLinux inotify-tools
    ++ optional stdenv.isDarwin coreutils-prefixed # For Nerves on macOS.
    ++ optional stdenv.isLinux x11_ssh_askpass; # For Nerves on Linux.

  # This hook is needed on Linux to make Nerves use the correct ssh_askpass.
  shellHooks = optional stdenv.isLinux ''
    export SUDO_ASKPASS=${x11_ssh_askpass}/libexec/x11-ssh-askpass
  '';
}
