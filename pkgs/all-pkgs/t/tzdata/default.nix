{ stdenv
, fetchurl
, lzip
}:

let
  version = "2018g";
in
stdenv.mkDerivation rec {
  name = "tzdata-${version}";

  src = fetchurl {
    url = "https://data.iana.org/time-zones/releases/tzdb-${version}.tar.lz";
    multihash = "QmSDQAzKyQJCPHJcMggKMjKKMhDJUYXNzuPR7dSDp6eF96";
    sha256 = "bdbdc46c1927f172d9b9eae01ce38a6e94764324f39be7773daf6d3df94485bb";
  };

  nativeBuildInputs = [
    lzip
  ];

  postPatch = ''
    ls -la
    cat Makefile
  '';

  preBuild = ''
    makeFlagsArray+=(
      "TOPDIR=$out"
      "USRDIR="
    )
  '';

  postInstall = ''
    test -e "$out/share/zoneinfo-posix"
    ln -sv ../zoneinfo-posix "$out"/share/zoneinfo/posix
    test -e "$out/share/zoneinfo-leaps"
    ln -sv ../zoneinfo-leaps "$out"/share/zoneinfo/leaps
    ln -sv ../zoneinfo-leaps "$out"/share/zoneinfo/right
  '';

  meta = with stdenv.lib; {
    homepage = http://www.iana.org/time-zones;
    description = "Database of current and historical time zones";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
