#!/usr/bin/python
# This script generates the software pack

import os, sys, getopt
from plugins.SalientEvo_Lib_Build.bsl_util import BSL_Util

# ==================================
# Project Params
USAGE = \
  f"Usage: {os.path.basename(__file__)} [OPTION]... [PACK_NAME]\nBuild project and create software pack.\n\n\
  -v, --version                software pack version, docker tag\n\
  -d, --dest                   destination path to store the generated software pack\n\
  -r, --docker_registry_url    docker registry url (generated docker images shall be pushed to the registry)\n\
  \nExamples:\n\
  {os.path.basename(__file__)} -v 20220501 -r http://localhost:5000 swpack-name\n"

# ==================================
# Main
def main(argv):
  
  bsl_util = BSL_Util(__file__)

  # Args
  version = 'latest'
  path_dest = f'{os.path.dirname(os.path.abspath(__file__))}/../swpack-dist'
  docker_registry_url = 'http://localhost:5000'
  pack_name = ''

  # Validage args
  try:
    opts, args = getopt.getopt(argv, "hv:d:r:", ["help", "version=", "dest=", "docker_registry_url="])
  except getopt.GetoptError as e:
    bsl_util.log(USAGE)
    bsl_util.exit(f'GetoptError: {e}', 2)

  if len(args) < 1:
    bsl_util.log(USAGE)
    bsl_util.exit('Bad arguments: pack name missing', 2)

  pack_name = args[0]
  bsl_util.log_prefix = f'{pack_name.upper()}:{version}'

  # Parse args
  for opt, arg in opts:
    if opt in ("-h", "--help"):
        bsl_util.log(USAGE)
        sys.exit()
    elif opt in ("-v", "--version"):
      version = arg
    elif opt in ("-d", "--dest"):
      path_dest = arg
    elif opt in ("-r", "--docker_registry_url"):
      docker_registry_url = arg 
      

  # Check missing args
  if pack_name == '':
    bsl_util.log(USAGE)
    bsl_util.exit('Bad Args: pack_name undefined', 2)


  path_dest = os.path.abspath(path_dest)

  bsl_util.log_info(f"==========================")
  bsl_util.log_info(f"Pack Gen Started")

  bsl_util.log("   Params:")
  bsl_util.log(f"    pack_name :       {pack_name}")
  bsl_util.log(f"    version:          {version}")
  bsl_util.log(f"    path_dest:        {path_dest}")
  bsl_util.log(f"    docker-registry:  {docker_registry_url}")
  bsl_util.log("")

  # =======
  bsl_util.log_task_started("Initialising dist folder...")
  bsl_util.run_sys_cmd(f'rm -rf {path_dest}')
  bsl_util.run_sys_cmd(f'mkdir -p {path_dest}')
  
  # =======
  bsl_util.log_task_started("Copying required files...")
  bsl_util.copy_swpack_files(f'{bsl_util.dir_path}/pack.inf.json', path_dest)
  bsl_util.write_swpack_info(pack_name, version, f"{path_dest}/pack.inf.json", path_dest)

  # =======
  bsl_util.build_docker_images(f'{bsl_util.dir_path}/pack.inf.json', pack_name, version, docker_registry_url, path_dest)

  # ---------------------------------------------------------------------------------
  # >>>> ADD Build Procedure here...


  # =======
  bsl_util.log_info(f"Pack Gen Completed\n")

if __name__ == "__main__":
  main(sys.argv[1:])

