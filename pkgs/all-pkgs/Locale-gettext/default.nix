{ stdenv
, buildPerlPackage
, fetchurl
}:

let
  version = "1.07";
in
buildPerlPackage {
  name = "Locale-gettext-${version}";

  src = fetchurl {
    url = "mirror://cpan/authors/id/P/PV/PVANDRY/gettext-${version}.tar.gz";
    sha256 = "909d47954697e7c04218f972915b787bd1244d75e3bd01620bc167d5bbc49c15";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
