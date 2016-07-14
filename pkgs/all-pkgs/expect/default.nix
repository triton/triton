{ stdenv
, fetchurl
, makeWrapper

, tcl
}:

let
  version = "5.45";
in
stdenv.mkDerivation rec {
  name = "expect-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/expect/Expect/${version}/expect${version}.tar.gz";
    multihash = "QmbQ5LAbpS4feDQaJrxNmLrqFvC8vXE6gBU6Udqpe9eFxt";
    sha256 = "0h60bifxj876afz4im35rmnbnxjx4lbdqp2ja3k30fwa8a8cm3dj";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    tcl
  ];

  patchPhase = ''
    sed -i "s,/bin/stty,$(type -p stty),g" configure
  '';

  configureFlags = [
    "--with-tcl=${tcl}/lib"
    "--with-tclinclude=${tcl}/include"
    "--exec-prefix=\${out}"
  ];

  postInstall = ''
    for i in $out/bin/*; do
      wrapProgram $i \
        --prefix PATH : "${tcl}/bin" \
        --prefix TCLLIBPATH ' ' $out/lib/*
    done
  '';

  meta = with stdenv.lib; {
    description = "A tool for automating interactive applications";
    homepage = http://expect.nist.gov/;
    license = "Expect";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
