#!/bin/sh

check_readme() {
  verification=

  while true
  do
    read -r -p "Did you read the README.md file? It's recommended to read the README.md file and verify the integrity of this verification script before continuing. [Y/n] " verification

    case $verification in
      [yY][eE][sS]|[yY]|"")
        printf "\nProceeding with verification...\n\n"
        break
        ;;
      [nN][oO]|[nN])
        printf "\nAlright come back when you have read the README.md file and verified the integrity of this script.\n"
        exit 1
        ;;
      *)
        printf "\nInvalid input...\n\n"
        ;;
    esac
  done
}

initial_instructions() {
  printf "This verfication script only handles the verification for the standalone releases, i.e., the file with the following format: sparrow-*.tar.gz\n"
  printf "To verify Sparrow Wallet you need to download the following files:\n"
  printf "sparrow-*.tar.gz\n"
  printf "sparrow-*-manifest.txt\n"
  printf "sparrow-*-manifest.txt.asc\n\n"
  printf "Here's a link to the Sparrow Wallet Download page where you can download the above files.\n"
  printf "If you prefer to not share your IP address with Sparrow Wallet, then use a trusted VPN or Tor when visiting the website to mask your IP address.\n"
  printf "https://sparrowwallet.com/download/\n\n"
  printf "If you want to download an older release, then take a look at the releases page on GitHub:\n"
  printf "https://github.com/sparrowwallet/sparrow/releases\n\n"
  printf "The *'s in the file names above will be replaced by whatever version of Sparrow Wallet you're verifying.\n"
  printf "Be sure to double check the links are bringing you to Sparrow Wallet's official website!\n"
  printf "Also make sure you download the files to the same directory as the verification script.\n\n"
}

sparrow_tar_gz=
sparrow_manifest_txt=
sparrow_manifest_txt_asc=

check_for_file() {
  if compgen -G "$1" > /dev/null; then
    if [ "$1" == "sparrow-*.tar.gz" ]; then
      sparrow_tar_gz=$(compgen -G "$1")
      printf "The $sparrow_tar_gz is the release that we'll be verifying.\n\n"
    elif [ "$1" == "sparrow-*-manifest.txt" ]; then
      sparrow_manifest_txt=$(compgen -G "$1")
      printf "The $sparrow_manifest_txt file is the manifest file we'll be using.\n\n"
    elif [ "$1" == "sparrow-*-manifest.txt.asc" ]; then
      sparrow_manifest_txt_asc=$(compgen -G "$1")
      printf "The $sparrow_manifest_txt_asc file is the signature of the manifest file.\n\n"
    fi
  else
    printf "$1 not found.\n"
    printf "Make sure to download the file to the same directory as the verification script.\n"
    exit 1
  fi
}

import_signing_key() {
  printf "To verify the authenticity of the release we need to import the public key that signed the manifest file.\n\n"

  curl https://keybase.io/craigraw/pgp_keys.asc | gpg --import

  printf "\nIf you want to be certain you're inputting the correct signing key, then check the code and/or run the commands manually.\n"
  printf "You can find the commands on the Sparrow Wallet Download page.\n"
  printf "https://sparrowwallet.com/download/\n\n"
}

verify_manifest_signature() {
  printf "We're now ready to verify the manifest file.\n\n"

  if gpg --verify $sparrow_manifest_txt_asc;  then
    printf '\nGnuPG returned a positive match on the signing key, i.e., Good signature from "Craig Raw <craigraw@gmail.com>".\n'
    printf "The primary key fingerprint should be: D4D0 D320 2FC0 6849 A257 B38D E946 1833 4C67 4B40\n\n"
    printf "Unless you tell GnuPG to trust the key, you'll see a warning similar to the following:\n\n"
    printf "gpg: WARNING: This key is not certified with a trusted signature!\n"
    printf "gpg:          There is no indication that the signature belongs to the owner.\n\n"
    printf "This warning means that the key is not certified by another third party authority.\n"
    printf "If the downloaded file was a fake, then the signature verification process would fail and you would be warned that the fingerprints don't match.\n\n"
    printf "When you get a warning like this it's also good practice to check the key against other sources, e.g., Craig Raw's Keybase (the developer of the wallet):\n"
    printf "https://keybase.io/craigraw\n\n"
    printf "If you want to be certain the manifest verification was correct, then check the code and/or run the commands manually.\n"
    printf "You can find the commands on the Sparrow Wallet Download page.\n"
    printf "https://sparrowwallet.com/download/\n\n"
  else
    printf "\nThe signature verification failed.\n"
    printf "Double check that you're using the official Sparrow Wallet website and that you downloaded the correct manifest and manifest signature files.\n"
    printf "The manifest file name should be in the following format: sparrow-*-manifest.txt.\n"
    printf "The manifest signature file name should be in the following format: sparrow-*-manifest.txt.asc.\n"
    exit 1
  fi
}

verify_release() {
  printf "We've now verified the signature of the manifest file which ensures the integrity and authenticity of the file but not of the release that we'll be installing.\n"
  printf "To verify the release we'll need to recompute the SHA256 hash of the file, compare it with the corresponding hash in the manifest file, and ensure they match exactly.\n"

  if sha256sum --check $sparrow_manifest_txt --ignore-missing | grep -Fqx "$sparrow_tar_gz: OK"; then
    printf "\nThe hashes matched!\n"
    printf "If you want to be certain the values actually match, then check the code and the hashes manually.\n"
    printf "You can find the commands on the Sparrow Wallet Download page.\n"
    printf "https://sparrowwallet.com/download/\n\n"
  else
    printf "\nThe hashes did not match.\n"
    printf "Double check that you're using the official Sparrow Wallet website and that you downloaded the correct manifest and release files.\n"
    printf "The release file name should be in the following format: sparrow-*.tar.gz.\n"
    exit 1
  fi

  printf "Your Sparrow Wallet release has been successfully verified!\n"
  printf "You're now ready to install Sparrow Wallet!\n"
}

check_readme
initial_instructions
check_for_file "sparrow-*.tar.gz"
check_for_file "sparrow-*-manifest.txt"
check_for_file "sparrow-*-manifest.txt.asc"
import_signing_key
verify_manifest_signature
verify_release
