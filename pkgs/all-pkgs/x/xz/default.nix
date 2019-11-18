{ stdenv
, fetchurl

, type ? "full"
, version
}:

let
  inherit (stdenv.lib)
    optionals;

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

  configureFlags = [
    "--localedir=${placeholder "bin"}/share/locale"
  ];

  postInstall = ''
    # Move bin files
    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"

    # Move shared libs
    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
  '';

  postFixup = ''
    ln -sv "$lib"/lib/* "$dev"/lib
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ] ++ optionals (type == "full") [
    "man"
  ];

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
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
