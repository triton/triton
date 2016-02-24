{ stdenv
, fetchurl

, glib
, libev
, libevent
, talloc
, tevent
}:

stdenv.mkDerivation rec {
  name = "libverto-0.2.6";

  src = fetchurl {
    url = "https://fedorahosted.org/releases/l/i/libverto/${name}.tar.gz";
    sha256 = "17hwr55ga0rkm5cnyfiipyrk9n372x892ph9wzi88j2zhnisdv0p";
  };

  buildInputs = [
    glib
    libev
    libevent
    tevent
    talloc
  ];

  postInstall = ''
    # In v0.2.6 the shipped pkg-config files have an out of order
    # declaration of exec_prefix breaking them. This fixes that issue
    sed -i 's,''${exec_prefix},''${prefix},g' $out/lib/pkgconfig/*.pc
  '';

  meta = with stdenv.lib; {
    homepage = https://fedorahosted.org/libverto/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
