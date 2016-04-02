{ fetchFromGitHub, stdenv, autoreconfHook }:

stdenv.mkDerivation rec {
  name = "dotconf-" + version;
  version = "1.3";

  src = fetchFromGitHub {
    owner = "williamh";
    repo = "dotconf";
    rev = "v${version}";
    sha256 = "66f53482d14c1c5402020cdff503bed9d06ac81eed6ec8be3cba64e43478ea27";
  };

  buildInputs = [ autoreconfHook ];

  meta = with stdenv.lib; {
    description = "A configuration parser library";
    maintainers = with maintainers; [ pSub ];
    homepage = http://www.azzit.de/dotconf/;
    license = licenses.lgpl21Plus;
  };
}
