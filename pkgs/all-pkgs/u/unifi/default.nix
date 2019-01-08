{ stdenv
, fetchurl
, unzip
}:

let
  version = "5.6.22";
in
stdenv.mkDerivation rec {
  name = "unifi-controller-${version}";

  src = fetchurl {
    url = "https://dl.ubnt.com/unifi/${version}/UniFi.unix.zip";
    sha256 = "2770d090109d5beb2ced3e30bf16d704302428d2c716aa0e7743e6819acafff7";
  };

  nativeBuildInputs = [
    unzip
  ];

  buildPhase = ''
    rm -rf bin conf readme.txt
    for so in $(find . -name \*.so\*); do
      chmod +x "$so"
      patchelf --set-rpath "${stdenv.cc.cc}/lib:${stdenv.libc}/lib" \
        "$so"
      if ldd "$so" | grep -q 'not found'; then
        echo "Didn't completely patch $so"
        exit 1
      fi
    done
  '';

  installPhase = ''
    mkdir -p $out
    cp -ar * $out
  '';

  meta = with stdenv.lib; {
    homepage = http://www.ubnt.com/;
    description = "Controller for Ubiquiti UniFi accesspoints";
    license = licenses.unfree;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
