{ stdenv
, fetchurl
}:

let
  inherit (stdenv.lib)
    elem
    optionals
    platforms;
in
stdenv.mkDerivation rec {
  name = "nspr-${version}";
  version = "4.12";

  src = fetchurl {
    url = "http://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v${version}/src/nspr-${version}.tar.gz";
    sha256 = "1pk98bmc5xzbl62q5wf2d6mryf0v95z6rsmxz27nclwiaqg0mcg0";
  };

  prePatch = ''
    cd nspr
  '';

  configureFlags = [
    "--enable-optimize"
    "--disable-debug"
  ] ++ optionals (elem stdenv.targetSystem platforms.bit64) [
    "--enable-64bit"
  ];

  # We don't want to keep any static libraries
  postInstall = ''
    find $out -name "*.a" -delete
  '';

  meta = with stdenv.lib; {
    homepage = http://www.mozilla.org/projects/nspr/;
    description = "Netscape Portable Runtime, a platform-neutral API for system-level and libc-like functions";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
