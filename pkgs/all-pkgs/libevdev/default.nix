{ stdenv
, fetchurl

, python
}:

stdenv.mkDerivation rec {
  name = "libevdev-1.5.1";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libevdev/${name}.tar.xz";
    allowHashOutput = false;
    sha256 = "17630821a57e6e3f02e01ade836f24068df9bd530067091152b0d468c3a86f40";
  };

  buildInputs = [
    python
  ];

  configureFlags = [
    "--disable-silent"
  ];

  passthru = {
    srcVerified = fetchurl {
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
