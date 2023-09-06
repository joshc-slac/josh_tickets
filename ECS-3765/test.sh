#!/bin/bash

NC_STRING="NC"
SC_STRING="SC"
IOC_PATH_NC="/reg/g/pcds/epics/ioc/fee/GasDetDAQ/R4.0.22"
IOC_PATH_SC="/reg/g/pcds/epics/ioc/fee/GasDetDAQ/R4.0.22-NOTS"
IOC_PATH=0
IS_PROD=0


# User input validation
if [[ -n $1 ]]; then # if the user passed at least one arg
  if [[ $1 != $NC_STRING ]] && [[ $1 != $SC_STRING ]]; then #validate argument is either SC or NC
    echo "Error. Must pass one argument: [NC or SC]"
    exit 1
  else
    echo "User passed argument of: $1"
  fi
fi

if [[ -n $2 ]]; then
  echo "Warning. Must pass strictly one argument, $2 is ignored"
  exit 1
fi

# check current operational state
OP_MODE=$(caget KFE:CAM:TPR:02:MODE | awk '{print $2}')
echo "Current OP_MODE is: $OP_MODE"
if [[ $OP_MODE = $1 ]]; then
  echo "Already in requested mode: $OP_MODE exitting with NOP"
  exit 1
else
  echo "Actuating requested timing change, switching to: $1"
fi

# Do it (un echo ify for realer dealer)
SET_MODE_CMD="caput KFE:CAM:TPR:02:MODE $1"
if [[ IS_PROD ]]; then
  $SET_MODE_CMD
else
  echo "$SET_MODE_CMD"  
fi

# only now discern which mode we want to put it in
if [[ $1 = $NC_STRING ]]; then
  IOC_PATH=$IOC_PATH_NC
else
  IOC_PATH=$IOC_PATH_SC
fi

SET_IOC_PATH_CMD="imgr ioc-lfe-gasdet-daq --upgrade $IOC_PATH"

if [[ IS_PROD ]]; then
  $SET_IOC_PATH_CMD
else
  echo "$SET_IOC_PATH_CMD"  
fi

exit 0