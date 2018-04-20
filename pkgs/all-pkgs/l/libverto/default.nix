{ stdenv
, fetchurl

, glib
, libev
, libevent
, tevent
}:

let
  version = "0.3.0";
in
stdenv.mkDerivation rec {
  name = "libverto-${version}";

  src = fetchurl {
    url = "https://github.com/latchset/libverto/releases/download/${version}/${name}.tar.gz";
    sha256 = "955d3ff4192830c74ce88185f39621c9e490d5a3e7aba04d1e5346d4886f862e";
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
