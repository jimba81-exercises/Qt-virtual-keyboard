#!/usr/bin/python
# This script starts the software pack

import getopt
import os, sys
from plugins.SalientEvo_Lib_Build.bsl_util import BSL_Util

# ==================================
# Project Params
USAGE = \
  f"Usage: {os.path.basename(__file__)} [OPTION]...\nStart software pack.\n\n\
  -i, --pack_inf_file_path     pack inf file path, default=./pack.inf.json\n\
  -p, --port                   server port, default=3000\n\
  -k, --pkgs_path              pkgs_path, default=~/pkgs\n\
  -l, --logs_path              logs_path, default=~/logs\n\
  -e, --env_file_path          env file path, default=~/.env/.env\n\
  \nExamples:\n\
  {os.path.basename(__file__)} -i ./pack.inf.json -p 3000\n"

# ==================================
# Main
def main(argv):
  bsl_util = BSL_Util(__file__)

  # Args
  pack_name = ''
  pack_tag = ''
  port = 3000
  pack_inf_file_path = f'{bsl_util.dir_path}/pack.inf.json'
  pkgs_path = '~/pkgs'
  logs_path = '~/logs'
  env_file_path = '~/.env/.env'

  # Validage args
  try:
    opts, args = getopt.getopt(argv, "hi:p:k:p:e:", ["help", "pack_inf_file_path=", "port=", "pkgs_path=", "logs_path=", "env_file_path="])
  except getopt.GetoptError as e:
    bsl_util.log(USAGE)
    bsl_util.exit(f'GetoptError: {e}', 2)
    
  # Parse args
  for opt, arg in opts:
    if opt in ("-h", "--help"):
      bsl_util.log(USAGE)
      sys.exit()
    elif opt in ("-i", "--pack_inf_file_path"):
      pack_inf_file_path = arg
    elif opt in ("-p", "--port"):
      port = arg          
    elif opt in ("-k", "--pkgs_path"):
      pkgs_path = arg
    elif opt in ("-l", "--logs_path"):
      logs_path = arg        
    elif opt in ("-e", "--env_file_path"):
      env_file_path = arg              

  pack_name = bsl_util.get_pack_name_from_swpack_inf(pack_inf_file_path)    
  pack_tag = bsl_util.get_pack_tag_from_swpack_inf(pack_inf_file_path)    
  bsl_util.log_prefix = f'{pack_name.upper()}:{pack_tag}'

  # Check missing args
  if pack_name == '':
    bsl_util.log(USAGE)
    bsl_util.exit('Bad Args: pack_name undefined', 2)

  if pack_tag == '':
    bsl_util.log(USAGE)
    bsl_util.exit('Bad Args: pack_tag undefined', 2)


  bsl_util.log_info(f"==========================")
  bsl_util.log_info(f"Pack Starting")

  bsl_util.log("   Params:")
  bsl_util.log(f"    pack_name:             {pack_name}")
  bsl_util.log(f"    pack_tag:              {pack_tag}")
  bsl_util.log(f"    port:                  {port}")  
  bsl_util.log(f"    pack_inf_file_path:    {pack_inf_file_path}")
  bsl_util.log(f"    pkgs_path:             {pkgs_path}")
  bsl_util.log(f"    env_file_path:         {env_file_path}")
  bsl_util.log("")
    
  # ---------------------------------------------------------------------------------
  # >>>> ADD Procedure here...

  # =======
  bsl_util.log_task_started("Stopping...")
  bsl_util.run_sys_cmd(f'{bsl_util.dir_path}/stop.py', True, None, {}, False)

  # =======
  bsl_util.log_task_started("Starting docker container...")
  bsl_util.run_sys_cmd(f'docker run --rm --detach --network host --pid=host -v {pkgs_path}:/pkgs -v {logs_path}:/home/node/logs --env-file {env_file_path} --name {pack_name} {pack_name}:{pack_tag}')

  # =======
  

if __name__ == "__main__":
  main(sys.argv[1:])