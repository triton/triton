{ runCommand
, libxslt

, fontconfig
, fontDirectories
, xorg
}:

runCommand "fonts.conf" {
  buildInputs = [
    libxslt
    fontconfig
  ];

  # Add a default font for non-Triton systems.
  fontDirectories = fontDirectories ++ [
    xorg.fontbhttf
  ];
}
''
  xsltproc \
    --stringparam fontDirectories "$fontDirectories" \
    --stringparam fontconfig "${fontconfig}" \
    --stringparam fontconfigConfigVersion "${fontconfig.configVersion}" \
    --path ${fontconfig}/share/xml/fontconfig \
    ${./make-fonts-conf.xsl} ${fontconfig}/etc/fonts/fonts.conf \
    > $out
''
