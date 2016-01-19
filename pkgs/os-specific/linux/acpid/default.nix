{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "acpid-2.0.26";

  src = fetchurl {
    url = "mirror://sourceforge/acpid2/${name}.tar.xz";
    sha256 = "0hq35q5pwyq9jbz28sdmkpnnmw6q4fc0681f7qc503r69xzg7143";
  };

  preBuild = ''
    makeFlagsArray+=("BINDIR=$out/bin")
    makeFlagsArray+=("SBINDIR=$out/sbin")
    makeFlagsArray+=("MAN8DIR=$out/share/man/man8")
  '';

  meta = {
    homepage = http://tedfelix.com/linux/acpid-netlink.html;
    description = "A daemon for delivering ACPI events to userspace programs";
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = stdenv.lib.platforms.linux;
  };
}
