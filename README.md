# oot-ice

This is a repo to build Out Of Tree Intel ice driver and load it on a OCP cluster

It builds the driver inside the Driver Toolkit image and pushes and image containing the kernel module to a registry.

### Prereq
- Set `KUBECONFIG` in your env
- Copy your pullsecret in $PWD/pull-secret.txt.
- Change the `LOCAL_REGISTRY` in `build.sh` to point to a registry that is reachable from your cluster and that your pull secret has credentials for.

### Build

```bash
./build.sh <ice-driver-version>  <ocp-version>
```

### Deploy

A 'MachineConfig' is suplied to deploy the driver container to the cluster.

```bash
oc apply -f mc-oot-ice.yaml
```
