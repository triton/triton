{ stdenv, fetchFromGitHub, perl, cmake }:

stdenv.mkDerivation rec {
  name = "libical-${version}";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "libical";
    repo = "libical";
    rev = "v${version}";
    sha256 = "0681a55473114a7176317d23169235111dd44a21d5adc68d50a13f99476268fe";
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
