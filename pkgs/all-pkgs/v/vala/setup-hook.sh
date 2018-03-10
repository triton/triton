# FIXME: Use hack until makeFlags and ninjaFlags are completely separated.
if [ -n "${setVapidirInstallFlag-true}" ]; then
  installFlagsArray+=(
    "vapidir=${out}/share/vala/vapi"
  )
fi
