{ stdenv
, fetchzip
}:

stdenv.mkDerivation {
  name = "gnulib-2017-03-17";

  src = fetchzip {
    version = 2;
    url = "https://git.savannah.gnu.org/cgit/gnulib.git/snapshot/gnulib-e30643c2f1dccbd1b7f02e4a3748590d03b4d5dd.tar.xz";
    multihash = "QmbKafqr4L62s3XQNm8bkVgnFJoWnpot973LWMARJX2xN8";
    sha256 = "70708d36b77f73aa0dc59436a59e2d65d3acbcfb530148de9deb99a1d7afde81";
  };

  installPhase = ''
    mkdir -p $out
  '';

  meta = with stdenv.lib; {
    homepage = "http://www.gnu.org/software/gnulib/";
    description = "central location for code to be shared among GNU packages";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
  };
}
