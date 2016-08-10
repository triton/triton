{ stdenv
, autoreconfHook
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "pkgconf-2016-01-21";

  src = fetchurl {
    url = "https://github.com/pkgconf/pkgconf/archive/7e6fa325eb668c3462981a16fb4c36270832e00f.tar.gz";
    sha256 = "0kqxbgfapg5x26308jq5d9qk35acj989skx4xc7nwkgffs948lyl";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  postInstall = ''
    # The install is broken and is missing libpkgconfig/config.h
    cp libpkgconf/config.h $out/include/pkgconf

    # The header files expect themselves to be in libpkgconf
    # however they are installed to pkgconf
    ln -s pkgconf $out/include/libpkgconf

    # We want compatability with pkg-config
    ln -s pkgconf $out/bin/pkg-config
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/pkgconf/pkgconf";
    description = "a tool and framework (libpkgconf) which provides compiler and linker configuration for development frameworks";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
