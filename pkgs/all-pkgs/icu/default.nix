{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "icu4c-${version}";
  version = "56.1";

  src = fetchurl {
    url = "http://download.icu-project.org/files/icu4c/${version}/icu4c-"
      + (stdenv.lib.replaceChars ["."] ["_"] version) + "-src.tgz";
    sha256 = "05j86714qaj0lvhvyr2s1xncw6sk0h2dcghb3iiwykbkbh8fjr1s";
  };

  prePatch = ''
    cd source
  '';

  configureFlags = [
    "--disable-debug"
  ];

  meta = with stdenv.lib; {
    description = "Unicode and globalization support library";
    homepage = http://site.icu-project.org/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
