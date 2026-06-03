{ lib, fetchurl, stdenv, autoPatchelfHook, zlib }:
let
  inherit (stdenv) hostPlatform;
  inherit (hostPlatform) system;
  version = "0.3.0";
  shaMap = {
    x86_64-linux = "0s8ggihy2hxpg0a0pa3k372g67a18rz12if452qdawni67nsg1hl";
    aarch64-linux = "1rpymwpzajpp4xdcpl1wg7zfjxzpn43brb97vkxhj8b0yqrr868w";
    aarch64-darwin = "1s7ykd3d4q0pqa0dk5nkgsgyadrh60v4rnl5wgbgk6d0n4wsxq91";
  };
  urlMap = {
    x86_64-linux = "https://github.com/tenequm/homebrew-tap/releases/download/pond-v0.3.0/pond-x86_64-unknown-linux-gnu.tar.xz";
    aarch64-linux = "https://github.com/tenequm/homebrew-tap/releases/download/pond-v0.3.0/pond-aarch64-unknown-linux-gnu.tar.xz";
    aarch64-darwin = "https://github.com/tenequm/homebrew-tap/releases/download/pond-v0.3.0/pond-aarch64-apple-darwin.tar.xz";
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
