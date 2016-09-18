{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "acpid-2.0.28";

  src = fetchurl {
    url = "mirror://sourceforge/acpid2/${name}.tar.xz";
    sha256 = "980c3a54b0d3f2fd49fd845a0584c5c2abeaab9e9ac09fcbb68686bbb57a7110";
  };

  preBuild = ''
    makeFlagsArray+=(
      "BINDIR=$out/bin"
      "SBINDIR=$out/sbin"
      "MAN8DIR=$out/share/man/man8"
    )
  '';

  meta = with stdenv.lib; {
    description = "A daemon for delivering ACPI events to userspace programs";
    homepage = http://tedfelix.com/linux/acpid-netlink.html;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
