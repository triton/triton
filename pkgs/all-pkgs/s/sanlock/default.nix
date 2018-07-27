{ stdenv
, fetchurl
, which

, libaio
, util-linux_lib
}:

let
  version = "3.6.0";

  src = fetchurl {
    url = "https://releases.pagure.org/sanlock/sanlock-${version}.tar.gz";
    multihash = "Qmanb22fXVeq2Am1r5RPDbxs4WX3SHJFuo3KSzW8HXu6jE";
    sha256 = "a05f053c68e873e0f6df6e1c6e667e2eac89f110456b69615906a79e5e01ece2";
  };

  wdmd = stdenv.mkDerivation rec {
    name = "sanlock-wdmd-${version}";

    inherit src;

    nativeBuildInputs = [
      which
    ];

    prePatch = ''
      cd wdmd
    '';

    preBuild = ''
      makeFlagsArray+=(
        "BINDIR=$out/bin"
        "LIBDIR=$out/lib"
        "HEADIR=$out/include"
        "MANDIR=$out/share/man"
      )
    '';
  };
in
stdenv.mkDerivation rec {
  name = "sanlock-3.6.0";

  inherit src;

  nativeBuildInputs = [
    which
  ];

  buildInputs = [
    libaio
    util-linux_lib
    wdmd
  ];

  prePatch = ''
    cd src
  '';

  preBuild = ''
    makeFlagsArray+=(
      "BINDIR=$out/bin"
      "LIBDIR=$out/lib"
      "HEADIR=$out/include"
      "MANDIR=$out/share/man"
    )
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
