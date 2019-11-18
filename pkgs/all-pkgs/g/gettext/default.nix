{ stdenv
, fetchurl

, libunistring
}:

let
  tarballUrls = version: [
    "mirror://gnu/gettext/gettext-${version}.tar.xz"
  ];

  version = "0.20.1";
in
stdenv.mkDerivation rec {
  name = "gettext-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "53f02fbbec9e798b0faaf7c73272f83608e835c6288dd58be6c9bb54624a3800";
  };

  buildInputs = [
    libunistring
  ];

  postPatch = ''
    sed \
      -i gettext-tools/projects/KDE/trigger \
      -i gettext-tools/projects/GNOME/trigger \
      -i gettext-tools/src/project-id \
      -e 's,/bin/pwd,pwd,g'
  '';

  prefix = placeholder "bin";

  configureFlags = [
    "--datadir=${placeholder "lib"}/share"
    "--without-included-libunistring"
  ];

  postInstall = ''
    rm -rv "$bin"/share/{doc,info}
    mv -v "$lib"/share/aclocal "$bin"/share

    mkdir -p "$dev"
    mv "$bin"/{include,lib} "$dev"
    rm -v "$dev"/lib/preload*

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib*
  '';

  preFixup = ''
    sed -i "$bin/bin/gettext.sh" \
      -e "/^  .\?gettext/ s,envsubst,$bin/bin/\0,g" \
      -e "/^  .\?gettext/ s,^  ,\0$bin/bin/,"
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "man"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.20.1";
      inherit (src) outputHashAlgo;
      outputHash = "53f02fbbec9e798b0faaf7c73272f83608e835c6288dd58be6c9bb54624a3800";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "68D9 4D8A AEEA D48A E7DC  5B90 4F49 4A94 2E46 16C2";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Well integrated set of translation tools and documentation";
    homepage = http://www.gnu.org/software/gettext/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ powerpc64le-linux
      ++ x86_64-linux;
  };
}
