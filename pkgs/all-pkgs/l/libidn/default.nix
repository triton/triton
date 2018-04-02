{ stdenv
, fetchurl
}:

let
  version = "1.34";

  tarballUrls = version: [
    "mirror://gnu/libidn/libidn-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libidn-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "3719e2975f2fb28605df3479c380af2cf4ab4e919e1506527e4c7670afff6e3c";
  };

  postPatch = ''
    SOURCE_TIME=$(stat -c "%Y" configure)
    sed -i 's,gl_cv_cc_vis_werror=yes,gl_cv_cc_vis_werror=no,g' configure
    touch -d "@$SOURCE_TIME" configure
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      urls = tarballUrls "1.34";
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "9AA9 BDB1 1BB1 B99A 2128  5A33 0664 A769 5426 5E8C";
      inherit (src) outputHashAlgo;
      outputHash = "3719e2975f2fb28605df3479c380af2cf4ab4e919e1506527e4c7670afff6e3c";
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/libidn/;
    description = "Library for internationalized domain names";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
