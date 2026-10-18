{
  description = "Dev environment for Steamed (Stonecutter multi-version Fabric/Forge/NeoForge/Quilt mod)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            # Bootstraps ./gradlew; project subprojects pin their own
            # per-Minecraft-version JDKs via Gradle toolchains (foojay
            # auto-provisions those, so this one just needs to run Gradle).
            pkgs.jdk21
          ];

          JAVA_HOME = "${pkgs.jdk21}/lib/openjdk";

          shellHook = ''
            echo "Steamed dev shell: JDK $(java -version 2>&1 | head -n1)"
            echo "Run ./gradlew :versions:<version>-<loader>:build to build a specific target."
          '';
        };
      }
    );
}
