{ stdenv
, fetchurl

, libnl
}:

stdenv.mkDerivation rec {
  name = "iw-4.3";

  src = fetchurl {
    url = "https://www.kernel.org/pub/software/network/iw/${name}.tar.xz";
    sha256 = "085jyvrxzarvn5jl0fk618jjxy50nqx7ifngszc4jxk6a4ddibd6";
  };

  buildInputs = [
    libnl
  ];

  makeFlags = [
    "PREFIX=\${out}"
  ];

  meta = {
    description = "Tool to use nl80211";
    homepage = http://wireless.kernel.org/en/users/Documentation/iw;
    license = stdenv.lib.licenses.isc;
    maintainers = with stdenv.lib.maintainers; [viric];
    platforms = with stdenv.lib.platforms; linux;
  };
}
