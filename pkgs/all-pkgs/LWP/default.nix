{ stdenv
, buildPerlPackage
, fetchurl

, Encode-Locale
, HTTP-Date
, HTTP-Message
}:

let
  version = "6.15";
in
buildPerlPackage rec {
  name = "LWP-${version}";

  src = fetchurl {
    url = "mirror://cpan/authors/id/E/ET/ETHER/libwww-perl-${version}.tar.gz";
    sha256 = "6f349d45c21b1ec0501c4437dfcb70570940e6c3d5bff783bd91d4cddead8322";
  };

  propagatedBuildInputs = [
    Encode-Locale
    HTTP-Date
    HTTP-Message
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
