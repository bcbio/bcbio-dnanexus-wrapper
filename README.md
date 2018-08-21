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

### Building the applet

After modififying the source files above appropriately, to build the applet itself, in the desired project:

```
dx build -a bcbio-dnanexus-wrapper/bcbio-run-workflow
```

### Release the app

After the applet has been tested, to build the app and make it available for a particular organisation, first you need to publish the app in dev mode:

```
dx build --app bcbio-run-workflow --bill-to <replace with you org id>
```

After testing, you can publish the app by running the command below:

```
dx api app-bcbio-run-workflow/<replace with your version id> publish "{\"makeDefault\": true}"
```

### R&D mode and reuse existing workflow results

Generally in an R&D/pre-production mode you want to test a pipeline on a handful up to hundreds of samples. There still may be bugs/issues that would require changes in the underlying bcbio Docker image.   For this case, you'd like to reuse results up to the point of failure but still use a modified Docker image.

Rather than use a cached asset on the platform (as described above), when running the workflow for the first time, provide this option to the app:

```
dx run bcbio-run-workflow -ipull_from_docker_registry=true ...
```

where '...' are the remaining options you would typically supply to the app.  This option ensures that the compiled workflow directly pulls from the Docker registry as opposed to using a cached asset.  This is a little less efficient and robust when compared to using a cached asset, but for tens to hundreds of runs it may be preferable to accellerate iteration for R&D purposes.

Now, if you noticed a bug and subseequently modify the Docker image, you can reuse this workflow instead of compiling a new one:

```
dx run bcbio-run-workflow -ireuse_workflow=workflow-XXXX ...
```

OR

```
dx run bcbio-run-workflow -ireuse_workflow=path/to/workflow-name ...
```

The execution of this app will allow reuse of existing results already computed for the workflow but will use the modified Docker image for any remaining jobs to be executed.



