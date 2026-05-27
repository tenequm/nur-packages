{ stdenv, fetchurl, autoPatchelfHook, lib }:

let
  version = "0.1.0";
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/tenequm/homebrew-tap/releases/download/pond-v${version}/pond-aarch64-apple-darwin.tar.gz";
      hash = "sha256-HjxP9lbC63DREPXLCj7rHHbyvLeu1Mw9piZTQlGKj+w=";
    };
    "x86_64-linux" = {
      url = "https://github.com/tenequm/homebrew-tap/releases/download/pond-v${version}/pond-x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-xnJd54mUkEJVL1q4uwgn0E2UuQCQFHgsNJp3QhgWEfg=";
    };
  };
  source = sources.${stdenv.hostPlatform.system} or (throw "pond: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "pond";
  inherit version;

  src = fetchurl {
    inherit (source) url hash;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  # autoPatchelfHook needs libgcc_s.so.1 which lives here on Linux
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  unpackPhase = ''
    runHook preUnpack
    tar -xzf $src
    runHook postUnpack
  '';

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 755 pond $out/bin/pond
    runHook postInstall
  '';

  meta = with lib; {
    description = "Local session storage and retrieval for agentic clients";
    homepage = "https://github.com/tenequm/pond";
    license = licenses.asl20;
    platforms = builtins.attrNames sources;
    mainProgram = "pond";
  };
}
