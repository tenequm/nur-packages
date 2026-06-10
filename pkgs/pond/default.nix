{ lib, fetchurl, stdenv, autoPatchelfHook, zlib }:
let
  inherit (stdenv) hostPlatform;
  inherit (hostPlatform) system;
  version = "0.5.1";
  shaMap = {
    x86_64-linux = "1ygknig4ahh3zdmcs1qfvdcnbk715y9bd5rkgnan8b11248pdvfj";
    aarch64-linux = "19cxyf11j433im7kwd60v3n5k45dax18h53ih39nwb3injm54sd3";
    aarch64-darwin = "15m4yc25mlnk65j558k4an284lfxji6dm839s8kx3jszmadxg4b8";
  };
  urlMap = {
    x86_64-linux = "https://github.com/tenequm/homebrew-tap/releases/download/pond-v0.5.1/pond-x86_64-unknown-linux-gnu.tar.xz";
    aarch64-linux = "https://github.com/tenequm/homebrew-tap/releases/download/pond-v0.5.1/pond-aarch64-unknown-linux-gnu.tar.xz";
    aarch64-darwin = "https://github.com/tenequm/homebrew-tap/releases/download/pond-v0.5.1/pond-aarch64-apple-darwin.tar.xz";
  };
in
stdenv.mkDerivation {
  pname = "pond";
  inherit version;

  src = fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = ".";

  # Prebuilt glibc ELF won't run on NixOS until its interpreter and RPATH
  # are rewritten to Nix-store paths; darwin Mach-O needs no patching.
  nativeBuildInputs = lib.optionals hostPlatform.isLinux [ autoPatchelfHook ];

  # The released Linux build is CPU-only candle + vendored onig + rustls,
  # so the sole dynamic deps beyond glibc are libgcc_s/libstdc++.
  buildInputs = lib.optionals hostPlatform.isLinux [ stdenv.cc.cc.lib zlib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 pond $out/bin/pond
    runHook postInstall
  '';

  meta = {
    description = "Lossless storage and hybrid search for sessions from any AI agent client";
    homepage = "https://pond.cascade.fyi/";
    changelog = "https://github.com/tenequm/pond/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "pond";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ];
    maintainers = with lib.maintainers; [ ];
  };
}
