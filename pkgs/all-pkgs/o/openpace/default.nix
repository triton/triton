{ stdenv
, fetchurl
, lib

, openssl
}:

let
  version = "1.0.3";
in
stdenv.mkDerivation rec {
  name = "openpace-${version}";

  src = fetchurl {
    url = "https://github.com/frankmorgner/openpace/releases/download/${version}/${name}.tar.gz";
    sha256 = "73d327e35fe717cf7d0a6f80dc99ad38fbc34cbee8e4e263a986293319984012";
  };

  buildInputs = [
    openssl
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    # libeac.pc gets re-written during install with bad paths below
    cp libeac.pc libeac.pc.old

    installFlagsArray+=(
      "X509DIR=$out/etc/eac/x509"
      "CVCDIR=$out/etc/eac/cvc"
    )
  '';

  preFixup = ''
    cp libeac.pc.old "$out"/lib/pkgconfig/libeac.pc
    rm "$out"/bin/{eactest,example}
    rm -r "$out"/share/doc
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
