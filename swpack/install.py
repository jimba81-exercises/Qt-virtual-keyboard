#!/usr/bin/python
# This script installs the software pack

import getopt
import json
import os, sys
from plugins.SalientEvo_Lib_Build.bsl_util import BSL_Util

# ==================================
# Project Params
USAGE = \
  f"Usage: {os.path.basename(__file__)} [OPTION]...\nInstall software pack.\n\n\
  -i, --pack_inf_file_path        pack inf file path, default=./pack.inf.json\n\
  -r, --docker_registry_url       docker registry url (generated docker images shall be pushed to the registry), default='http://localhost:5000'\n\
  -p, --peer_docker_registry_url  peer docker registry url, default='sw-pkgs-peer.local.com:5000'\n\
  \nExamples:\n\
  {os.path.basename(__file__)} -i ./pack.inf.json -r http://localhost:5000 -p sw-pkgs-peer.local.com:5000\n"

# ==================================
# Main
def main(argv):
  bsl_util = BSL_Util(__file__)

  # Args
  pack_name = ''
  pack_tag = ''
  pack_inf_file_path = f'{bsl_util.dir_path}/pack.inf.json'
  docker_registry_url = 'http://localhost:5000'
  peer_docker_registry_url = 'http://sw-pkgs-peer.local.com:5000'

  # Validage args
  try:
    opts, args = getopt.getopt(argv, "hi:r:p:", ["help", "pack_inf_file_path=", "docker_registry_url=", "peer_docker_registry_url="])
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
    elif opt in ("-r", "--docker_registry_url"):
      docker_registry_url = arg
    elif opt in ("-p", "--peer_docker_registry_url"):
      peer_docker_registry_url = arg        

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
  bsl_util.log_info(f"Pack Install Started")

  bsl_util.log("   Params:")
  bsl_util.log(f"    pack_name:                 {pack_name}")
  bsl_util.log(f"    pack_tag:                  {pack_tag}")
  bsl_util.log(f"    pack_inf_file_path:        {pack_inf_file_path}")
  bsl_util.log(f"    docker-registry:           {docker_registry_url}")
  bsl_util.log(f"    peer_docker_registry_url:  {peer_docker_registry_url}")
  bsl_util.log("")

  bsl_util.install_docker_images(pack_inf_file_path, docker_registry_url, peer_docker_registry_url)

  # ---------------------------------------------------------------------------------
  # >>>> ADD Procedure here...


  # =======
  bsl_util.log_info(f"Pack Install Completed\n")    

if __name__ == "__main__":
  main(sys.argv[1:])
  