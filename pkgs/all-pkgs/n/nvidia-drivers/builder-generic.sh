# Generic builder for the NVIDIA drivers, supports versions 352+

# Notice:
# The generic builder does not always use the exact version changes were made,
# so if you choose to use a version not offically supported, it may require
# additional research into at which version certain changes were made.

source "${stdenv}/setup"

set -o errexit

nvidia_bin_install() {
  # Usage:
  # $1 - Min version (0 = null, for no minimum)
  # $2 - Max version (0 = null, for no maximum)
  # $3 - Executable name w/ relative path

  if ([ ${1} -eq 0 ] || [ ${versionMajor} -ge ${1} ]) && \
     ([ ${2} -eq 0 ] || [ ${versionMajor} -le ${2} ]) ; then
    # Install the executable
    install -D -m755 -v "${3}" "${out}/bin/$(basename "${3}")"
  fi
}

nvidia_header_install() {
  # Usage:
  # $1 - Min version (0 = null, for no minimum)
  # $2 - Max version (0 = null, for no maximum)
  # $3 - Header name w/ relative path & w/o extension (.h)
  # $4 - Install include sub-directory (relative to $out/include/)

  if ([ ${1} -eq 0 ] || [ ${versionMajor} -ge ${1} ]) && \
     ([ ${2} -eq 0 ] || [ ${versionMajor} -le ${2} ]) ; then
    # Install the header
    install -D -m644 -v "${3}.h" "${out}/include${4:+/${4}}/$(basename "${3}").h"
  fi
}

nvidia_lib_install() {
  # Usage:
  # $1 - Min version (0 = null, for no minimum)
  # $2 - Max version (0 = null, for no maximum)
  # $3 - Library name w/ relative path & w/o extension (.so*)
  # $4 - Custom shared object version (symlink *.so.<orig> -> *.so.<custom>)
  # $5 - Source libraries' shared object version (*.so.<version>)
  # $6 - Install library in sub-directory (relative to $out/lib/)

  local libFile
  local outDir
  local soVersion

  if ([ ${1} -eq 0 ] || [ ${versionMajor} -ge ${1} ]) && \
     ([ ${2} -eq 0 ] || [ ${versionMajor} -le ${2} ]) ; then
    # If the source *.so.<version> isn't set use *.so.$version
    if [ -z "${5}" ] ; then
      soVersion="${version}"
    elif [ "${5}" == '-' ] ; then
      unset soVersion
    else
      soVersion="${5}"
    fi

    # Handle cases where the file being installed is in a subdirectory
    # within the source directory
    libFile="$(basename "${3}")"

    # Install the library
    install -D -m755 -v "${3}.so${soVersion:+.${soVersion}}" \
      "${out}/lib${6:+/${6}}/${libFile}.so${soVersion:+.${soVersion}}"

    # Always create a symlink from the library to *.so
    if [ ! -z "${soVersion}" ] ; then
      ln -fnrsv \
        "${out}/lib${6:+/${6}}/${libFile}.so.${soVersion}" \
        "${out}/lib${6:+/${6}}/${libFile}.so"
    fi

    # If $4 is set & does not equal $soVersion, then create a *.so.$4 symlink
    if [ ! -z "${4}" ] && [ "${4}" != '-' ] && [ "${4}" != "${soVersion}" ] ; then
      ln -fnrsv \
        "${out}/lib${6:+/${6}}/${libFile}.so${soVersion:+.${soVersion}}" \
        "${out}/lib${6:+/${6}}/${libFile}.so.${4}"
    fi
  fi
}

nvidia_man_install() {
  # Usage:
  # $1 - Min version (0 = null, for no minimum)
  # $2 - Max version (0 = null, for no maximum)
  # $3 - Man page (w/o extension (.1.gz))

  if ([ ${1} -eq 0 ] || [ ${versionMajor} -ge ${1} ]) && \
     ([ ${2} -eq 0 ] || [ ${versionMajor} -le ${2} ]) ; then
    # Install the manpage
    install -D -m644 -v "${3}.1.gz" \
      "${out}/share/man/man1/$(basename "${3}").1.gz"
  fi
}

genericBuild
