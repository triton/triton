{ stdenv
, fetchurl

, glib
, libev
, libevent
, tevent
}:

let
  version = "0.3.1";
in
stdenv.mkDerivation rec {
  name = "libverto-${version}";

  src = fetchurl {
    url = "https://github.com/latchset/libverto/releases/download/${version}/${name}.tar.gz";
    sha256 = "983817c6bc0af6fa3731da2653e6371f6e1a56b4489ee44b3172e918574c50ea";
  };

  buildInputs = [
    glib
    libev
    libevent
    tevent
  ];

  postInstall = ''
    # In v0.3.0 the shipped pkg-config files have an out of order
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
      x86_64-linux;
  };
}
