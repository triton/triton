{ stdenv
, fetchurl
, fetchTritonPatch

, attr

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  tarballUrls = version: [
    "mirror://gnu/patch/patch-${version}.tar.xz"
  ];

  version = "2.7.6";
in
stdenv.mkDerivation rec {
  name = "gnupatch-${type}-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "ac610bda97abe0d9f6b7c963255a11dcb196c25e337c61f94e4778d632f1d8fd";
  };

  buildInputs = optionals (type == "full") [
    attr
  ];

  patches = [
    (fetchTritonPatch {
      rev = "ba71067ce3694be838da1c42b40d61168334475c";
      file = "g/gnupatch/CVE-2018-6951.patch";
      sha256 = "a1fde199bc091f5a015181903ad34812de474283b83067b5517e9dbd9ba5cce7";
    })
    (fetchTritonPatch {
      rev = "ba71067ce3694be838da1c42b40d61168334475c";
      file = "g/gnupatch/CVE-2018-6952.patch";
      sha256 = "16e3eea6c24c20979b79de27ce8b2211d8d5e15f1534955fbf75dd90f9857c77";
    })
  ];

  postInstall = optionalString (type == "small") ''
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
      urls = tarballUrls "2.7.6";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "259B 3792 B3D6 D319 212C  C4DC D5BF 9FEB 0313 653A";
      inherit (src) outputHashAlgo;
      outputHash = "ac610bda97abe0d9f6b7c963255a11dcb196c25e337c61f94e4778d632f1d8fd";
    };
  };

  meta = with stdenv.lib; {
    description = "GNU Patch, a program to apply differences to files";
    homepage = http://savannah.gnu.org/projects/patch;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
