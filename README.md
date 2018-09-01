# bcbio-dnanexus-wrapper

Repository to hold wrapper apps for running [bcbio
analyses](https://bcbio-nextgen.readthedocs.io/en/latest/) on
[DNAnexus](https://www.dnanexus.com/) using the [Common Workflow
Language](https://www.commonwl.org/).

This app encodes the steps of creating bcbio CWL and running a bcbio workflow on
the platform.  It also makes use of
[assets](https://wiki.dnanexus.com/Developer-Tutorials/Asset-Build-Process) for
efficient caching of the bcbio software and Docker image.

This documents the process of building the assets and apps. For usage, see the
[high level app
documentation](https://github.com/bcbio/bcbio-dnanexus-wrapper/tree/master/bcbio-run-workflow#run-bcbio-workflows)
and [detailed usage documentation](https://bcbio-nextgen.readthedocs.io/en/latest/contents/cwl.html#running-on-dnanexus-hosted-cloud).

## Building the app

The public
[bcbio_resources](https://platform.dnanexus.com/projects/F541fX00f5v9vKJjJ34gvgbv/data/)
project on DNAnexus contains reference genomes, assets and applets used in bcbio
analysis.

### Setting up environment

```
dx login
dx select bcbio_resources
```

### Build the bcbio Docker asset

On a Linux machine with the [dx-toolkit](https://github.com/dnanexus/dx-toolkit)
and Docker installed:

```
# bcbio_resources
PROJECT=project-F541fX00f5v9vKJjJ34gvgbv

dx select $PROJECT
docker pull quay.io/bcbio/bcbio-vc
dx-docker create-asset quay.io/bcbio/bcbio-vc --output_path $PROJECT:/containers/
dx ls -l /containers | head -6
dx describe `dx ls containers/ | head -1 | cut -d ' ' -f 3`
```
From the last two commands you need to identify the latest docker build file
reference (`record-NNN`) and the docker file reference from this (`file-NNN`).

### Build the bcbio-vm asset

```
dx select bcbio_resources
dx build_asset bcbio-dnanexus-wrapper/bcbio-vm-asset -d bcbio_resources:/bcbio_assets
dx mv bcbio-vm-asset /bcbio_assets
dx ls -l bcbio_resources:/bcbio_assets
```
From the last command note the latest bcbio-vm-asset (`record-NNN`).

### Adding the assets to the app

1. Update the [version in
   dxapp.json](https://github.com/bcbio/bcbio-dnanexus-wrapper/blob/6749f1880a7873f66a30ae833a7d58fc17303bc3/bcbio-run-workflow/dxapp.json#L6)

2. Add the bcbio-vm record asset ID and Docker record asset ID from above to
   [assetDepends in
   dxapp.json](https://github.com/bcbio/bcbio-dnanexus-wrapper/blob/6749f1880a7873f66a30ae833a7d58fc17303bc3/bcbio-run-workflow/dxapp.json#L79)

3. Add the Docker file ID to `BCBIO_CONTAINER_FILE` in [bcbio-run-workflow.sh](https://github.com/bcbio/bcbio-dnanexus-wrapper/blob/6749f1880a7873f66a30ae833a7d58fc17303bc3/bcbio-run-workflow/src/bcbio-run-workflow.sh#L8)


### Building the applet

Build the bcbio applet in `bcbio_resources:/applets` with:
```
dx select bcbio_resources
dx build -a -d bcbio_resources:/applets/ bcbio-dnanexus-wrapper/bcbio-run-workflow
```
You can run this directly for testing in the same way as versioned apps.


### Release the app

To release a new version app, publish and make public:
```
dx build --publish --app bcbio-dnanexus-wrapper/bcbio-run-workflow -b org-az_cgr_services
dx add users app-bcbio-run-workflow PUBLIC
```

## Development notes

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
