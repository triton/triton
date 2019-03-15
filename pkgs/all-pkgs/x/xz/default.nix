{ stdenv
, fetchurl

, type ? "full"
, version
}:

let
  inherit (stdenv.lib)
    optionalString;

  tarballUrls = version: [
    "https://tukaani.org/xz/xz-${version}.tar.xz"
  ];

  sources = {
    "5.2.4" = {
      multihash = "QmTvwVoGSrcoHNt7LKZDhnQUarCqFiJbY2ZwN4ctkVhCn1";
      sha256 = "9717ae363760dedf573dad241420c5fea86256b65bc21d2cf71b2b12f0544f4b";
    };
  };
in
stdenv.mkDerivation rec {
  name = "xz-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    inherit (sources."${version}")
      multihash
      sha256;
  };

  # In stdenv-linux, prevent a dependency on bootstrap-tools.
  preConfigure = ''
    unset CONFIG_SHELL
  '';

  postInstall = ''
    rm -r "$out"/share/doc
  '' + optionalString (type != "full") ''
    rm -r "$out"/share
  '';

  disableStatic = false;

  dontPatchShebangs = true;

  allowedReferences = [
    "out"
  ] ++ stdenv.cc.runtimeLibcLibs;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "5.2.4";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "3690 C240 CE51 B467 0D30  AD1C 38EE 757D 6918 4620";
      inherit (src) outputHashAlgo;
      outputHash = "9717ae363760dedf573dad241420c5fea86256b65bc21d2cf71b2b12f0544f4b";
    };
  };

  meta = with stdenv.lib; {
    homepage = http://tukaani.org/xz/;
    description = "XZ, general-purpose data compression software, successor of LZMA";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
