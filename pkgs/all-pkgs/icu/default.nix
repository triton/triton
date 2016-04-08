{ stdenv
, fetchurl
}:

let
  inherit (stdenv.lib)
    replaceChars;
in

stdenv.mkDerivation rec {
  name = "icu4c-${version}";
  version = "57.1";

  src = fetchurl {
    url = "http://download.icu-project.org/files/icu4c/${version}/icu4c-"
      + (replaceChars ["."] ["_"] version) + "-src.tgz";
    #md5Confirm = "http://download.icu-project.org/files/icu4c/${version}/"
    #  + "icu4c-src-" + (replaceChars ["."] ["_"] version) + ".md5";
    sha256 = "ff8c67cb65949b1e7808f2359f2b80f722697048e90e7cfc382ec1fe229e9581";
  };

  postUnpack = ''
    sourceRoot="$sourceRoot/source"
  '';

  configureFlags = [
    "--disable-debug"
    "--enable-release"
    "--disable-strict"
    #"--enable-64bit-libs"
    #"--enable-auto-cleanup"
    "--enable-draft"
    "--enable-renaming"
    "--disable-tracing"
    #"--enable-plugins"
    #"--enable-dynload"
    "--enable-rpath"
    "--disable-weak-threads"
    "--enable-extras"
    "--enable-icuio"
    "--enable-layout"
    #"--enable-layoutex"
    "--enable-tools"
    "--disable-tests"
    "--disable-samples"
    #"--with-library-bits="
  ];

  meta = with stdenv.lib; {
    description = "Unicode and globalization support library";
    homepage = http://site.icu-project.org/;
    license = licenses.icu;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
