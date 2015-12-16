{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, openssl }:

stdenv.mkDerivation rec {
  name = "notbit-2014-09-10";

  src = fetchFromGitHub {
    owner = "bpeel";
    repo = "notbit";
    rev = "6f1ca5987c7f217c9c3dd27adf6ac995004c29a1";
    sha256 = "1q3a6ph3bx9ayw3lvjxsrw9vn9h9v02ql5kvjqfb926ypqa9xrm1";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ openssl ];

  meta = with stdenv.lib; { 
    homepage = http://busydoingnothing.co.uk/notbit/;
    description = "A minimal bitmessage client";
    license = licenses.mit;

    # This is planned to change when the project officially supports other platforms
    platforms = platforms.linux;
  };
}
