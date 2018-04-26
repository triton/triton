{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, acl

, version
}:

let
  tarballUrls = version: [
    "mirror://gnu/tar/tar-${version}.tar.xz"
  ];

  sha256s = {
    "1.30" = "f1bf92dbb1e1ab27911a861ea8dde8208ee774866c46c0bb6ead41f4d1f4d2d3";
  };
in
stdenv.mkDerivation rec {
  name = "gnutar-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = sha256s."${version}";
  };

  buildInputs = [
    acl
  ];

  # Remove this during an stdenv rebuild
  patches = [ ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.30";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "325F 650C 4C2B 6AD5 8807  327A 3602 B07F 55D0 C732";
      inherit (src) outputHashAlgo;
      outputHash = "f1bf92dbb1e1ab27911a861ea8dde8208ee774866c46c0bb6ead41f4d1f4d2d3";
    };
  };

  meta = with lib; {
    homepage = http://www.gnu.org/software/tar/;
    description = "GNU implementation of the `tar' archiver";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux
      ++ i686-linux;
  };
}
