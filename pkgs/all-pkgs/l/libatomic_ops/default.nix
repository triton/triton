{ stdenv
, fetchurl
}:

let
  version = "7.6.2";
in
stdenv.mkDerivation rec {
  name = "libatomic_ops-${version}";

  src = fetchurl {
    url = "https://github.com/ivmai/libatomic_ops/releases/download/v${version}/${name}.tar.gz";
    # We need the multihash because they delete old releases
    multihash = "QmUHjRG2tEtQGmqknUpTrm8H8rKcNUCLWBEU5dBUCSQwsi";
    sha256 = "219724edad3d580d4d37b22e1d7cb52f0006d282d26a9b8681b560a625142ee6";
  };

  meta = with stdenv.lib; {
    description = ''A library for semi-portable access to hardware-provided atomic memory update operations'';
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
