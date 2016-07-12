{ stdenv
, fetchurl

, python
}:

stdenv.mkDerivation rec {
  name = "libevdev-1.5.2";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libevdev/${name}.tar.xz";
    allowHashOutput = false;
    sha256 = "5ee2163656a61f5703cb5c08a05c9471ffb7b640bfbe2c55194ea50d908f629b";
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
