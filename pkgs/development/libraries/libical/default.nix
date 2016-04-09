{ stdenv, fetchFromGitHub, perl, cmake }:

stdenv.mkDerivation rec {
  name = "libical-${version}";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "libical";
    repo = "libical";
    rev = "v${version}";
    sha256 = "ad43ba94a80501f97f132debca9a232a745a920810b6f51ad060347b6c74f87f";
  };

  nativeBuildInputs = [ perl cmake ];

  patches = [ ./respect-env-tzdir.patch ];

  meta = with stdenv.lib; {
    homepage = https://github.com/libical/libical;
    description = "an Open Source implementation of the iCalendar protocols";
    license = licenses.mpl10;
    platforms = platforms.all;
    maintainers = with maintainers; [ wkennington ];
  };
}
