{ stdenv
, autoreconfHook
, fetchFromGitHub
, fetchurl

, ncurses
, openssl
, readline
}:

let
  rev = "c3939dac2c060651361fc71516806f9ab8c38901";
  date = "2020-02-13";

  # Last fetched 2020-02-17
  pen = fetchurl {
    url = "http://www.iana.org/assignments/enterprise-numbers";
    multihash = "QmVhHeJTYXgdzs65GAGJabzNm7uF5qNzxhVo6wwSzuasLy";
    sha256 = "c4b7d075287e69e59ece3754f8fb05cf21ceb2b50f4266612461b8ef2237b348";
  };
in
stdenv.mkDerivation rec {
  name = "ipmitool-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ipmitool";
    repo = "ipmitool";
    inherit rev;
    sha256 = "72f8250e0c88ad2b641380da8bf40a35be6820645119044497b135483cb7c44e";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    ncurses
    openssl
    readline
  ];

  postPatch = ''
    sed -i '/Neither wget nor curl could be found/aAM_CONDITIONAL([DOWNLOAD], [false])' configure.ac
  '';

  # Remove once fixed
  configureFlags = [
    "DEFAULT_INTF=open"
  ];

  postInstall = ''
    mkdir -p "$out"/share/misc
    cp '${pen}' "$out"/share/misc/enterprise-numbers
  '';

  meta = with stdenv.lib; {
    description = "Command-line interface to IPMI-enabled devices";
    homepage = http://ipmitool.sourceforge.net;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
