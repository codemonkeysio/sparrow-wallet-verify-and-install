#!/bin/bash

sparrow_tar_gz=
current_directory=

check_verification() {
  verification=

  while true
  do
    read -r -p "Did you read the README.md file? It's recommended to read the README.md file, verify the integrity of this installation script, and verify the Sparrow Wallet release before continuing. [Y/n] " verification

    case $verification in
      [yY][eE][sS]|[yY]|"")
        printf "\nProceeding with installation...\n\n"
        break
        ;;
      [nN][oO]|[nN])
        printf "\nAlright come back when you have read the README.md file, verified the integrity of this script, and verified the Sparrow Wallet release which you can do by running the verify-sparrow-wallet.sh script.\n"
        exit 1
        ;;
      *)
        printf "\nInvalid input...\n\n"
        ;;
    esac
  done
}

check_for_file() {
  if compgen -G "$1" > /dev/null; then
    if [ "$1" == "sparrow-*.tar.gz" ]; then
      sparrow_tar_gz=$(compgen -G "$1")
      printf "Located the $sparrow_tar_gz file.\n\n"
    fi
  else
    printf "$1 not found.\n"
    printf "Make sure to download the file to the same directory as the installation script.\n"
    exit 1
  fi
}

check_sudo() {
  until $1
  do
    exit 1
    sleep 1
  done
}

set_up_sudo_session() {
  printf "Setting up sudo session...\n"
  check_sudo 'sudo -v'
}

unzip_file() {
  printf "\nExtracting the contents of $sparrow_tar_gz release file.\n\n"
  tar -xvzf $sparrow_tar_gz
  printf "\n"
}

move_icon() {
  printf "Moving the $trezor_suite_icon file to $HOME/.local/share/icons.\n\n"
  if [ ! -d $HOME/.local/share/icons ]; then
    mkdir $HOME/.local/share/icons
  fi
  mv $trezor_suite_icon $HOME/.local/share/icons
}

get_current_directory() {
  current_directory=$(pwd)
}

make_desktop_entry() {
  printf "Making a desktop entry for Sparrow Wallet in /usr/share/applications/sparrow-wallet.desktop with the following contents:\n\n"
  cat <<EOF | sudo tee /usr/share/applications/sparrow-wallet.desktop
[Desktop Entry]
Type=Application
Name=Sparrow Wallet
Comment=Sparrow Wallet
Icon=$current_directory/Sparrow/lib/Sparrow.png
Exec=$current_directory/Sparrow/bin/Sparrow
Terminal=false
Categories=bitcoin;
EOF
}

how_to_run_app() {
  printf "\nSparrow Wallet installation complete!\n\n"
  printf "You can launch Sparrow Wallet from the terminal by navigating to the Sparrow binary file using the following command:\n\n"
  printf "cd Sparrow/bin\n\n"
  printf "Then to launch Sparrow Wallet use the following command:\n\n"
  printf "./Sparrow\n\n"
  printf "You can also launch Sparrow Wallet by clicking on the desktop entry.\n"
  printf "If you move the Sparrow directory, then you'll need to update the paths of the Icon and Exec variables in the sparrow-wallet.desktop file for the desktop entry to work properly.\n"
}

check_verification
check_for_file "sparrow-*.tar.gz"
set_up_sudo_session
unzip_file
get_current_directory
make_desktop_entry
how_to_run_app
