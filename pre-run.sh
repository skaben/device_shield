#!/usr/bin/env bash

PYVER='3.7'
trap "exit" INT

help () 
{
  echo "Usage: pre-run.sh [install|reset|manual]"
  exit
}

if [[ -z $1 ]]; then
  help
fi

manual () {
  echo -e "> manual process:\n"\
    "   python3.7 python3.7-venv should be installed\n"\
    "   python3.7 -m venv venv\n"\
    "   source ./venv/bin/activate\n"\
    "   pip install --upgrade pip\n"\
    "   pip install -r requirements.txt\n"\
    "   ./deploy.sh reset\n"
  exit
}

check_uname () {
  if ! [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
    echo -e " > Sorry, only Debian-based distros supported for auto-deploy\n"
    manual
    exit
  fi
}

# deploy

deploy () {

  PYTHON=""
  PYDEV="python$PYVER-dev"
  PYTHON_VENV="python3-venv"
   
  subver=$(python3 -c 'import sys; print(sys.version_info[1])')
  standalone=$(python3.7 --version)
  
  if [[ $standalone == "" ]] && [[ $((subver + 0)) != 7 ]]; then
    echo '[!] application require python'$PYVER
    echo '[!] your version is:' $(python3 --version)
    echo -e "trying to install python"$PYVER
    PYTHON="python$PYVER"
  fi

  

  echo -e "> installing dependencies with apt"
  sudo apt-get install -y --no-install-recommends $PYTHON $PYTHON_VENV $PYDEV

  echo -e "> setting up virtual environment"
  if  [ -d "./venv" ]; then 
    rm -rf "venv"
  fi
  if [ -d "conf" ]; then
    rm -rf "conf"
  fi
  mkdir conf
  python$PYVER -m venv venv
  source "./venv/bin/activate"
  PY=$(which python$PYVER)
  $PY -m pip install --upgrade pip
  pip install -r requirements.txt --no-cache-dir
  echo -e "> virtual environment set, unpacking resources"
  echo -e "... done!\n"
  echo -e "\n  --------"

}

# reset

reset () 
{
  echo -e "[>] resetting __ BOILERPLATE __ device configuration"
  iface=$(ip route | grep "default" | sed -nr 's/.*dev ([^\ ]+).*/\1/p')
  local_path=$(pwd)
  sed -e "s/\${iface}/'$iface'/" \
      -e "s+\${dirpath}+$local_path+" "templates/system_config.yml.template" > "./conf/system.yml"
  touch "./conf/device.yml"  # create empty device config
  echo "[>] done!"
}

# main routine

if [ "$1" = 'install' ]; then
  check_uname
  deploy
  reset 
elif [ "$1" = 'reset' ]; then
  reset
elif [ "$1" = 'manual' ]; then
  manual
else
  help
fi
