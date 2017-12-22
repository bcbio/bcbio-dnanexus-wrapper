# bcbio-dnanexus-wrapper
Repository to hold wrapper apps for bcbio CWL on DNAnexus

## TODO:

* Decide whether code should rely on specific asset ID, but name instead

## Use on the platform

This app encodes the steps of creating bcbio CWL and running a bcbio workflow on the platform.  It also makes use of [assets](https://wiki.dnanexus.com/Developer-Tutorials/Asset-Build-Process) for efficient caching of the bcbio Docker image and and software for the VM.

### Build the bcbio asset

On a Linux machine with the [dx-toolkit](https://github.com/dnanexus/dx-toolkit) and Docker installed:

```
$ dx select YOURPROJECT
$ docker pull quay.io/bcbio/bcbio-vc
$ dx-docker create-asset quay.io/bcbio/bcbio-vc
```

### Build the bcbio-vm asset

```
$ dx build_asset bcbio-dnanexus-wrapper/bcbio-vm-asset
```

### Using the assets

The app used to run a bcbio workflow uses the assets in these two ways:

* The [dxapp.json assetDepends](https://github.com/bcbio/bcbio-dnanexus-wrapper/blob/d3ec62276807b8f18b2342d69d02d6673f659eba/bcbio-run-workflow/dxapp.json#L53) includes the bcbio-vm asset ID
* The [app code compiles CWL to DNAnexus with a bcbio asset](https://github.com/bcbio/bcbio-dnanexus-wrapper/blob/d3ec62276807b8f18b2342d69d02d6673f659eba/bcbio-run-workflow/src/bcbio-run-workflow.sh#L36)

For both of these, you can update the IDs based on the asset you built.  An easy way to obtain the IDs for the bcbio-vm or quay.io Docker image is to:

```
dx ls -l
```
in the directory you built the asset.

As an alternative, assets can be referenced by name, and this code could be modified to do that if desired.  See the [dxapp.json](https://wiki.dnanexus.com/dxapp.json) for more information on that.  The issue with that is that an asset's content can change without the name changing so provenance could be affected.  For this reason the code explicitly uses record IDs.

### Building the app

After modififying the source files above appropriately, to build the app itself, in the desired project:

```
dx build -a bcbio-dnanexus-wrapper/bcbio-run-workflow
```
