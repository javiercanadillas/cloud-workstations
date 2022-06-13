# Cloud Workstations configuration

This set of scripts configure a basic Cloud Workstations cluster and a basic workstation profile to start working with Google Cloud Workstations on a whitelisted project.

To use, edit the `setup.sh` script and have a look at the functions there to have an idea of what they do. Then, use `bootstrap.sh` passing as argument the atomic function you want to run. As an example:

```bash
./bootstrap.sh check_workstation
```

If running this for the first time, `main()` includes all necessary steps to perform an initial bootstrap, from cluster to checking a newly created workstation template.

```bash
./bootstrap.sh main
```