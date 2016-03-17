{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "acpid-2.0.27";

  src = fetchurl {
    url = "mirror://sourceforge/acpid2/${name}.tar.xz";
    sha256 = "820c223e53cc11d9d7229fb1ffc2c2205f1054082c80f83f5a4ec4df16d3a616";
  };

  preBuild = ''
    makeFlagsArray+=(
      "BINDIR=$out/bin"
      "SBINDIR=$out/sbin"
      "MAN8DIR=$out/share/man/man8"
    )
  '';

  meta = with stdenv.lib; {
    homepage = http://tedfelix.com/linux/acpid-netlink.html;
    description = "A daemon for delivering ACPI events to userspace programs";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
