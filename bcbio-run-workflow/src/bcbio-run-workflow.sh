#!/bin/bash
main() {

    BCBIO_CONTAINER="record-FGP9b0j0f5v02G5bG719F3F4"

    if [ "$pull_from_docker_registry" = "true" ]; then
        BCBIO_ASSETS=""
    else
        BCBIO_ASSETS="--assets $BCBIO_CONTAINER"
    fi

    dx download "$yaml_template" -o yaml_template.yml
    dx download "$sample_spec" -o sample_spec.csv
    dx download "$system_configuration" -o system_configuration.yml
 
    bcbiovm_conda install -y -c conda-forge yq
    ln -s /install/bcbio-vm/anaconda/bin/yq /usr/local/bin/yq
    PNAME=`yq -r .dnanexus.project < system_configuration.yml`

    mv sample_spec.csv ${PNAME}.csv

    #wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
    #bash Miniconda2-latest-Linux-x86_64.sh -b -p ~/install/bcbio-vm/anaconda
    #~/install/bcbio-vm/anaconda/bin/conda install --yes -c conda-forge -c bioconda bcbio-nextgen-vm
    #ln -s ~/install/bcbio-vm/anaconda/bin/bcbio_vm.py /usr/local/bin/bcbio_vm.py
    #ln -s ~/install/bcbio-vm/anaconda/bin/conda /usr/local/bin/bcbiovm_conda
    #ln -s ~/install/bcbio-vm/anaconda/bin/python /usr/local/bin/bcbiovm_python


    source /home/dnanexus/environment
    export DX_AUTH_TOKEN=`echo $DX_SECURITY_CONTEXT | jq -r .auth_token`
    export DX_PROJECT_ID=$DX_PROJECT_CONTEXT_ID

    unset DX_WORKSPACE_ID
    dx cd $DX_PROJECT_ID:/

    export PATH=/usr/local/bin:$PATH
    ls /usr/local/bin

    # Ignore PYTHONPATH set by DNAnexus instance, which introduces incompatible libraries
    sed -i 's|bcbio-vm/anaconda/bin/python|bcbio-vm/anaconda/bin/python -Es|' /usr/local/bin/bcbio_vm.py
    bcbio_vm.py template --systemconfig system_configuration.yml yaml_template.yml $PNAME.csv
    bcbio_vm.py cwl --systemconfig system_configuration.yml $PNAME/config/$PNAME.yaml
    tar -cvzf $PNAME-generated-cwl.tgz $PNAME-workflow/main-$PNAME.cwl
    
    git clone https://github.com/dnanexus/dx-cwl.git

    if [ -n "$reuse_workflow" ]; then
        WF_ID_OR_NAME=$reuse_workflow
    else
        WF_ID_OR_NAME="/$output_folder/main-$PNAME/main-$PNAME"
        bcbiovm_python dx-cwl/dx-cwl compile-workflow $PNAME-workflow/main-$PNAME.cwl --project $DX_PROJECT_ID --token $DX_AUTH_TOKEN ${BCBIO_ASSETS} --rootdir $output_folder
        generated_cwl=$(dx upload $PNAME-generated-cwl.tgz --brief)
        dx-jobutil-add-output generated_cwl "$generated_cwl" --class=file
        
        dx rm -a $DX_PROJECT_ID:/${output_folder}/main-$PNAME-samples.json || true
        dx upload --verbose --wait -p --path "$DX_PROJECT_ID:/$output_folder/main-$PNAME-samples.json" $PNAME-workflow/main-$PNAME-samples.json
        # Wait for upload to complete and the file to be available
        sleep 5
    fi
   
    bcbiovm_python dx-cwl/dx-cwl run-workflow $WF_ID_OR_NAME /$output_folder/main-$PNAME-samples.json --project $DX_PROJECT_ID --token $DX_AUTH_TOKEN --rootdir $output_folder
}
