#!/bin/bash

# Puppet Task Name: dist_software
#
# This is where you put the shell code for your task.
#
# You can write Puppet tasks in any language you want and it's easy to
# adapt an existing Python, PowerShell, Ruby, etc. script. Learn more at:
# https://puppet.com/docs/bolt/0.x/writing_tasks.html
#
# Puppet tasks make it easy for you to enable others to use your script. Tasks
# describe what it does, explains parameters and which are required or optional,
# as well as validates parameter type. For examples, if parameter "instances"
# must be an integer and the optional "datacenter" parameter must be one of
# portland, sydney, belfast or singapore then the .json file
# would include:
#   "parameters": {
#     "instances": {
#       "description": "Number of instances to create",
#       "type": "Integer"
#     },
#     "datacenter": {
#       "description": "Datacenter where instances will be created",
#       "type": "Enum[portland, sydney, belfast, singapore]"
#     }
#   }
# Learn more at: https://puppet.com/docs/bolt/0.x/writing_tasks.html#ariaid-title11
#

#variables

export parent_version=$PT_parent_version
export dru_zipfile=$PT_dru_zipfile
export dbr_number=$PT_dbr_number
export patch_number=$PT_patch_number
export oh=$(facter -p oracle_home_version)
export ohv=$(echo $oh | grep $parent_version | cut -d "/" -f6)
export software_share=/mnt/rushmore/oracle/database/Lin64_$parent_version
export local_dir=/u02/patches
export p_dir=$local_dir/$dbr_number
export zfile=${software_share}/${dru_zipfile}

#check version 

if [ -z $ohv ] 
  then 
    echo "-- no oracle home with version: $parent_version on this node"
    exit 0
fi

# check if software available

if [ ! -f "${zfile}" ]
then
  echo "-- Zipfile not available please check for file: ${dru_zipfile} on filesystem: ${software_share}"
  exit 1
fi

#check and create patch directory

if [ -d "${p_dir}" ]
then
  echo "-- Patch directory already exists: ${p_dir}"
else
  sudo -u oracle mkdir -p ${p_dir}
  echo "-- Patch directory created"
fi

# Install binaries

if [ "$(ls -A ${p_dir})" ] 
then
  echo "-- Directory $p_dir is not Empty, not installing"
  exit 1
 else
  unzip -q ${zfile} -d ${p_dir}
  echo "-- Patch software unpacked in ${p_dir}"
  echo "-- Content directory:"
  ls -1 ${p_dir}/${patch_number}
fi

