{ stdenv
, fetchzip

, libevent
, liblfds
, nspr
, nss
, talloc
, tevent
}:

stdenv.mkDerivation rec {
  name = "nunc-stans-0.1.8";

  src = fetchzip {
    version = 2;
    url = "https://git.fedorahosted.org/cgit/nunc-stans.git/snapshot/${name}.tar.xz";
    multihash = "Qmba9uk4UXkkujjVki8VQHeSVzMSJVr5C9dcbaksZsyTiQ";
    sha256 = "55bde6a749b899afabd1cae44c333a07b6d3123737aca20d7a0078177d5f36f3";
  };

  buildInputs = [
    libevent
    liblfds
    nspr
    nss
    talloc
    tevent
  ];

  configureFlags = [
    "--with-lfds-inc=${liblfds}/include"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

