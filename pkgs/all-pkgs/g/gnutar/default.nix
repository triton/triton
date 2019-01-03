{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, acl

, version ? "1.31"
, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  tarballUrls = version: [
    "mirror://gnu/tar/tar-${version}.tar.xz"
  ];

  sha256s = {
    "1.30" = "f1bf92dbb1e1ab27911a861ea8dde8208ee774866c46c0bb6ead41f4d1f4d2d3";
    "1.31" = "37f3ef1ceebd8b7e1ebf5b8cc6c65bb8ebf002c7d049032bf456860f25ec2dc1";
  };
in
stdenv.mkDerivation rec {
  name = "gnutar-${type}-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = sha256s."${version}";
  };

  buildInputs = optionals (type == "full") [
    acl
  ];

  postInstall = optionalString (type != "full") ''
    rm -r "$out"/share
  '';

  allowedReferences = [
    "out"
    stdenv.cc.libc
    stdenv.cc.cc
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.30";
      inherit (src) outputHashAlgo;
      outputHash = "37f3ef1ceebd8b7e1ebf5b8cc6c65bb8ebf002c7d049032bf456860f25ec2dc1";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "325F 650C 4C2B 6AD5 8807  327A 3602 B07F 55D0 C732";
      };
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
