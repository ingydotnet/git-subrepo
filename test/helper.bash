test-helper:like() {
  local got=$1 regex=$2 label=$3
  if [[ "$got" =~ "$regex" ]]; then
    Test::Tap:pass "$label"
  else
    Test::Tap:fail "$label"
    Test::Tap:diag "Got: '$got'"
  fi
}
