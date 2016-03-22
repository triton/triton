{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "mtools-4.0.18";

  src = fetchurl {
    url = "mirror://gnu/mtools/${name}.tar.bz2";
    sha256 = "119gdfnsxc6hzicnsf718k0fxgy2q14pxn7557rc96aki20czsar";
  };

  # Fails to install correctly in parallel
  parallelInstall = false;

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/mtools/;
    description = "Utilities to access MS-DOS disks";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
