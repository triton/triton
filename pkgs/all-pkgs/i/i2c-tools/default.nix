{ stdenv
, fetchzip
}:

stdenv.mkDerivation rec {
  name = "i2c-tools-4.0";

  src = fetchzip {
    version = 3;
    url = "https://git.kernel.org/pub/scm/utils/i2c-tools/i2c-tools.git/snapshot/${name}.tar.gz";
    multihash = "Qmba1eHzkV4e3GQ6rjiybNT3y1NsUnCCoATPWY4EqJfPP9";
    sha256 = "4c18fe69e56ac6dc21aaf79244985b991f9f2aa740accea2fa99f0604973fb7e";
  };

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
