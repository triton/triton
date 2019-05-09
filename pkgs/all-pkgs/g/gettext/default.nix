{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "mirror://gnu/gettext/gettext-${version}.tar.xz"
  ];

  version = "0.20";
in
stdenv.mkDerivation rec {
  name = "gettext-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "a248207fd726ca35c57fe9f01e748c36c60b864bb624b58f9983a0f98b633924";
  };

  postPatch = ''
    sed \
      -i gettext-tools/projects/KDE/trigger \
      -i gettext-tools/projects/GNOME/trigger \
      -i gettext-tools/src/project-id \
      -e 's,/bin/pwd,pwd,g'
  '';

  # Broken in 0.20 for some invocations
  buildParallel = false;

  postInstall = ''
    rm -r "$out"/share/doc
  '';

  preFixup = ''
    sed -i "$out/bin/gettext.sh" \
      -e "/^  .\?gettext/ s,envsubst,$out/bin/\0,g" \
      -e "/^  .\?gettext/ s,^  ,\0$out/bin/,"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.20";
      inherit (src) outputHashAlgo;
      outputHash = "a248207fd726ca35c57fe9f01e748c36c60b864bb624b58f9983a0f98b633924";
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
      ++ x86_64-linux;
  };
}
