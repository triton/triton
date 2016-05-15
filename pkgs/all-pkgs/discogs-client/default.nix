{ stdenv
, buildPythonPackage
, fetchurl

, pythonPackages
}:

buildPythonPackage rec {
  name = "discogs-client-2.2.1";

  src = fetchurl {
    url = "mirror://pypi/d/discogs-client/${name}.tar.gz";
    md5Confirm = "c82be8006e1c02fcfc2bb42a2e312151";
    sha256 = "9e32b5e45cff41af8025891c71aa3025b3e1895de59b37c11fd203a8af687414";
  };

  buildInputs = [
    pythonPackages.oauthlib
    pythonPackages.requests2
    pythonPackages.six
  ];

  meta = with stdenv.lib; {
    description = "Official Python API client for Discogs";
    homepage = https://github.com/discogs/discogs_client/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
