{ stdenv, fetchurl }:
stdenv.mkDerivation {
  pname = "rtk";
  version = "0.42.0";

  src = fetchurl {
    url = "https://github.com/rtk-ai/rtk/releases/download/v0.42.0/rtk-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-zdT4esl86Vj3G1OpkYgNatzEHMW8oQRBdaZGMJgBUr4=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/rtk
  '';

  meta.mainProgram = "rtk";
}
