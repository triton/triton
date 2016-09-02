{ stdenv
, fetchurl

, python
}:

stdenv.mkDerivation rec {
  name = "libevdev-1.5.4";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libevdev/${name}.tar.xz";
    hashOutput = false;
    multihash = "Qmbe5g3mDVKgTv16kqFLW6n9zX1N7ZLYHRcKBcWSzMpAkU";
    sha256 = "11fe76d62cc76fbc9dbf8e94696a80eee63780139161e5cf54c55ec21a8173a4";
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
