# oot-ice

This is a repo to build Out Of Tree Intel ice driver and load it on a OCP cluster

It builds the driver inside the Driver Toolkit image and pushes an image containing the kernel module to a registry.

### Prereq
- Set `KUBECONFIG` in your env
- Copy your pull secret in `$PWD/pull-secret.txt`.
- Change the `LOCAL_REGISTRY` in `build.sh`  to point to a registry that is reachable from your cluster and that your pull secret has credentials for.
- Update the registry in `mc-oot-ice.yaml` to point to the same registry as above

### Build

```bash
./build.sh <ice-driver-version>  <ocp-version>
```

### Deploy

A `MachineConfig` is suplied to deploy the driver container to the cluster.

```bash
oc apply -f mc-oot-ice.yaml
```
