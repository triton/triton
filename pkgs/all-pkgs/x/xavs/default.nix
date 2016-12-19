{ stdenv
, fetchsvn
, lib
}:

let
  version = "55";
in
stdenv.mkDerivation rec {
  name = "xavs-${version}";

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/xavs/code/trunk";
    rev = "${version}";
    sha256 = "0drw16wm95dqszpl7j33y4gckz0w0107lnz6wkzb66f0dlbv48cf";
  };

  postPatch = ''
    patchShebangs configure
    patchShebangs config.sub
    patchShebangs version.sh
    patchShebangs tools/countquant_xavs.pl
    patchShebangs tools/patcheck
    patchShebangs tools/regression-test.pl
    patchShebangs tools/xavs-format
  '';

  configureFlags = [
    "--enable-pic"
    "--enable-shared"
    "--disable-asm"
  ];

  meta = with lib; {
    description = "AVS encoder and decoder";
    homepage = http://xavs.sourceforge.net/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
