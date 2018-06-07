{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "mirror://gnu/gettext/gettext-${version}.tar.xz"
  ];

  version = "0.19.8.1";
in
stdenv.mkDerivation rec {
  name = "gettext-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "105556dbc5c3fbbc2aa0edb46d22d055748b6f5c7cd7a8d99f8e7eb84e938be4";
  };

  postPatch = ''
    sed \
      -i gettext-tools/projects/KDE/trigger \
      -i gettext-tools/projects/GNOME/trigger \
      -i gettext-tools/src/project-id \
      -e 's,/bin/pwd,pwd,g'
  '';

  preFixup = ''
    sed -i "$out/bin/gettext.sh" \
      -e "/^  .\?gettext/ s,envsubst,$out/bin/\0,g" \
      -e "/^  .\?gettext/ s,^  ,\0$out/bin/,"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.19.8.1";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "4622 25C3 B46F 3487 9FC8  496C D605 848E D7E6 9871";
      inherit (src) outputHashAlgo;
      outputHash = "105556dbc5c3fbbc2aa0edb46d22d055748b6f5c7cd7a8d99f8e7eb84e938be4";
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
