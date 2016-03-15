{ fetchurl }:

let
  version = "3.8.0";
  pkgToUrl = pkg: "http://llvm.org/releases/${version}/${pkg}-${version}.src.tar.xz";
in
{
  inherit version;

  cfe = fetchurl {
    url = pkgToUrl "cfe";
    allowHashOutput = false;
    sha256 = "1ybcac8hlr9vl3wg8s4v6cp0c0qgqnwprsv85lihbkq3vqv94504";
  };
  clang-tools-extra = fetchurl {
    url = pkgToUrl "clang-tools-extra";
    allowHashOutput = false;
    sha256 = "1i0yrgj8qrzjjswraz0i55lg92ljpqhvjr619d268vka208aigdg";
  };
  compiler-rt = fetchurl {
    url = pkgToUrl "compiler-rt";
    allowHashOutput = false;
    sha256 = "1c2nkp9563873ffz22qmhc0wakgj428pch8rmhym8agjamz3ily8";
  };
  libcxx = fetchurl {
    url = pkgToUrl "libcxx";
    allowHashOutput = false;
    sha256 = "0yr3fh8vj38289b9cwk37zsy7x98dcd3kjy7xxy8mg20p48lb01n";
  };
  libcxxabi = fetchurl {
    url = pkgToUrl "libcxxabi";
    allowHashOutput = false;
    sha256 = "0175rv2ynkklbg96kpw13iwhnzyrlw3r12f4h09p9v7nmxqhivn5";
  };
  libunwind = fetchurl {
    url = pkgToUrl "libunwind";
    allowHashOutput = false;
    sha256 = "0as2m6378v9r9r7445clgvgcydf1lcd2xdizhs4rwfywxhwsygmg";
  };
  lld = fetchurl {
    url = pkgToUrl "lld";
    allowHashOutput = false;
    sha256 = "034zgxzyds06xqp1k5zc062la2s40580hl9h83s7b7wc4bd4sw4l";
  };
  lldb = fetchurl {
    url = pkgToUrl "lldb";
    allowHashOutput = false;
    sha256 = "0dasg12gf5crrd9pbi5rd1y8vwlgqp8nxgw9g4z47w3x2i28zxp3";
  };
  llvm = fetchurl {
    url = pkgToUrl "llvm";
    allowHashOutput = false;
    sha256 = "0ikfq0gxac8xpvxj23l4hk8f12ydx48fljgrz1gl9xp0ks704nsm";
  };
  openmp = fetchurl {
    url = pkgToUrl "openmp";
    allowHashOutput = false;
    sha256 = "183kyxl5rpazpaf3c0pvj96k9jp1pv70hrqb79g9bpp3c8zhwlcj";
  };
  polly = fetchurl {
    url = pkgToUrl "polly";
    allowHashOutput = false;
    sha256 = "1wnis5s27r34nhxkykphmrhymmamd4djjzchjx3nc2m1nv0apjw4";
  };
}
