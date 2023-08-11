if [[ -z ${CONDITIONER_MAIN_DIRECTORY} ]]; then
  echo -e "Warning: \$CONDITIONER_MAIN_DIRECTORY not found. Assuming current directory."
  CONDITIONER_MAIN_DIRECTORY=$(pwd)
fi

CONDITIONER_SCRIPTS_DIRECTORY="${CONDITIONER_MAIN_DIRECTORY}/scripts"

conditioner_compress() {
  gzip -9 - | base64 | tr -d $'\n'
}

conditioner_uncompress() {
  base64 -d | gunzip
}

conditioner_concatenate() {
  for fname in "$CONDITIONER_SCRIPTS_DIRECTORY/"*.sh; do
    echo "Adding \"$fname\"" 1>&2
    echo "# $(basename "$fname")"
    cat "$fname"
  done
}

conditioner_compile() {
  conditioner_concatenate | conditioner_compress
}

conditioner_command() {
  local compiled="$(conditioner_compile)"
  printf "echo '%s' | base64 -d | gunzip | bash\n" "$compiled"
}

conditioner_import_dotfile() {
  local dotfile_name="$1"

  if [[ -z "$dotfile_name" ]]; then
    read -p'Dotfile name? ' dotfile_name
  fi

  # expand tilde
  dotfile_name="${dotfile_name/#\~/$HOME}"

  if [[ ! -f $dotfile_name ]]; then
    echo "The file \"$dotfile_name\" doesn't appear to exist."
    echo "Please enter the name of an existing dotfile with path."
    return
  fi

  local dotfile_basename="$(basename "$dotfile_name")"
  local destination_basename="append_to_${dotfile_basename/#\./}.sh"
  local destination_name="${CONDITIONER_SCRIPTS_DIRECTORY}/${destination_basename}"

  echo "cat <<- EOF >> ~/${dotfile_basename}" >> "$destination_name"
  cat "$dotfile_name" | sed 's/\$/\\$/'       >> "$destination_name"
  echo "EOF"                                  >> "$destination_name"

  echo "Created new script \"$destination_name\""
}

echo 'Run "conditioner_command" to generate the command.'
echo 'Run "conditioner_import_dotfile" to import a dotfile.'
