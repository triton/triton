{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, acl

, version ? "1.32"
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
    "1.32" = "d0d3ae07f103323be809bc3eac0dcc386d52c5262499fe05511ac4788af1fdd8";
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

  postFixup = ''
    mkdir -p "$bin"/share2
  '' + optionalString (type == "full") ''
    mv "$bin"/share/locale "$bin"/share2
  '' + ''
    rm -rv "$bin"/share
    mv "$bin"/share2 "$bin"/share
  '';

  outputs = [
    "bin"
  ] ++ optionals (type == "full") [
    "man"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
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
      x86_64-linux ++
      i686-linux ++
      powerpc64le-linux;
  };
}
