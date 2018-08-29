set -e -x -o pipefail

#!/bin/bash
main() {

    # This container file is the actual bundled file record-FJ2P25j0f5vJxx3K95BVVx2f is poiting to.
    # bcbio-run-workflow app requires the fileID for dx-cwl to compile the workflow 
    BCBIO_CONTAINER_FILE="file-FK36j2j0f5v81f9X2GXVYBGZ"

    if [ "$pull_from_docker_registry" = "true" ]; then
        BCBIO_ASSETS=""
    elif [ "${BCBIO_CONTAINER_FILE}" != "" ]; then
        BCBIO_ASSETS="--bundled $BCBIO_CONTAINER_FILE"
    fi

    dx download "$yaml_template" -o yaml_template.yml
    dx download "$sample_spec" -o sample_spec.csv
    dx download "$system_configuration" -o system_configuration.yml

    PNAME=`yq -r .dnanexus.project < system_configuration.yml`

    mv sample_spec.csv ${PNAME}.csv

    source /home/dnanexus/environment
    set +x
    export DX_AUTH_TOKEN=`echo $DX_SECURITY_CONTEXT | jq -r .auth_token`
    set -x
    export DX_PROJECT_ID=$DX_PROJECT_CONTEXT_ID

    unset DX_WORKSPACE_ID
    dx cd $DX_PROJECT_ID:/

    export PATH=/usr/local/bin:$PATH
    ls /usr/local/bin

    bcbio_vm.py template --systemconfig system_configuration.yml yaml_template.yml $PNAME.csv
    bcbio_vm.py cwl --systemconfig system_configuration.yml $PNAME/config/$PNAME.yaml
    tar -cvzf $PNAME-generated-cwl.tgz $PNAME-workflow/main-$PNAME.cwl
    
    if [ -n "$reuse_workflow" ]; then
        WF_ID_OR_NAME=$reuse_workflow
    else
        WF_ID_OR_NAME="/$output_folder/main-$PNAME/main-$PNAME"
        set +x
        dx-cwl compile-workflow $PNAME-workflow/main-$PNAME.cwl --project $DX_PROJECT_ID --token $DX_AUTH_TOKEN ${BCBIO_ASSETS} --rootdir $output_folder
        set -x
        generated_cwl=$(dx upload $PNAME-generated-cwl.tgz --brief)
        dx-jobutil-add-output generated_cwl "$generated_cwl" --class=file
        
        dx rm -a $DX_PROJECT_ID:/${output_folder}/main-$PNAME-samples.json || true
        dx upload --verbose --wait -p --path "$DX_PROJECT_ID:/$output_folder/main-$PNAME-samples.json" $PNAME-workflow/main-$PNAME-samples.json
        # Wait for upload to complete and the file to be available
        sleep 5
    fi
    set +x
    dx-cwl run-workflow $WF_ID_OR_NAME /$output_folder/main-$PNAME-samples.json --project $DX_PROJECT_ID --token $DX_AUTH_TOKEN --rootdir $output_folder
    set -x
}
