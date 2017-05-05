{ stdenv
, fetchurl

, python
}:

stdenv.mkDerivation rec {
  name = "libevdev-1.5.7";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libevdev/${name}.tar.xz";
    multihash = "QmVXqSHSKQgL2UggVGFaC93vDhs8DXhH77wugNH9cWDkpC";
    hashOutput = false;
    sha256 = "a1e59e37a2f0d397ffd7e83b73af0e638db83b8dd08902ef0f651a21cc1dd422";
  };

  buildInputs = [
    python
  ];

  configureFlags = [
    "--disable-silent"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "3C2C 43D9 447D 5938 EF45  51EB E23B 7E70 B467 F0BF";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Wrapper library for evdev devices";
    homepage = http://www.freedesktop.org/software/libevdev/doc/latest/index.html;
    license = licenses.mit;
    maintainers = with stdenv.lib; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
