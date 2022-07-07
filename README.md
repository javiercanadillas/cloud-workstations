# Cloud Workstations configuration

This set of scripts configure a basic Cloud Workstations cluster and a basic workstation profile to start working with Google Cloud Workstations on a whitelisted project.

To use, edit the `setup.sh` script and have a look at the functions there to have an idea of what they do. Then, call the script with the function name you're interested in running. Example:

```bash
./bootstrap.sh help
./bootstrap.sh list_workstations
```

If running this for the first time, the function `bootstrap` includes all necessary steps to perform an initial bootstrap, from cluster to checking a newly created workstation template.

```bash
./setup.sh bootstrap
```