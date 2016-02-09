{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  name = "unifi-controller-${version}";
  version = "4.8.12";

  src = fetchurl {
    url = "https://www.ubnt.com/downloads/unifi/${version}/UniFi.unix.zip";
    sha256 = "0p5hqdciszgzayv6vwc8z4vzbham1hfwsraskfnn4bj1v6mskzqy";
  };

  buildInputs = [ unzip ];

  doConfigure = false;

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
    platforms = platforms.unix;
    maintainers = with maintainers; [ wkennington ];
  };
}
