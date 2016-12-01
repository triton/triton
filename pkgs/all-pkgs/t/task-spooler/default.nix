{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "ts-1.0";

  src = fetchurl {
    url = "http://vicerveza.homeunix.net/~viric/soft/ts/${name}.tar.gz";
    multihash = "Qma4Agj6wjTszJetfNTPx3Q1o8mrN7sZSJVeGep8jADDhZ";
    sha256 = "4f53e34fff0bb24caaa44cdf7598fd02f3e5fa7cacaea43fa0d081d03ffbb395";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  preFixup = ''
    mv -v "$out/bin/ts" "$out/bin/task-spooler"
    rm -rvf "$out/share"
  '';

  meta = with lib; {
    description = "A comfortable way of running batch jobs";
    homepage = http://vicerveza.homeunix.net/~viric/soft/ts/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
