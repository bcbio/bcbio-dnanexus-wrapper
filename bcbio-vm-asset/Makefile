all:
	# bcbio-vm	
	wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
	bash Miniconda2-latest-Linux-x86_64.sh -b -p /install/bcbio-vm/anaconda
	/install/bcbio-vm/anaconda/bin/conda install --yes -c conda-forge -c bioconda bcbio-nextgen
	/install/bcbio-vm/anaconda/bin/conda install --yes -c conda-forge -c bioconda bcbio-nextgen-vm
	ln -s /install/bcbio-vm/anaconda/bin/bcbio_vm.py /usr/local/bin/bcbio_vm.py
	ln -s /install/bcbio-vm/anaconda/bin/conda /usr/local/bin/bcbiovm_conda
	ln -s /install/bcbio-vm/anaconda/bin/python /usr/local/bin/bcbiovm_python
	# Ignore PYTHONPATH set by DNAnexus instance, which introduces incompatible libraries
	sed -i 's|bcbio-vm/anaconda/bin/python|bcbio-vm/anaconda/bin/python -Es|' /usr/local/bin/bcbio_vm.py
	# yq: version of requests shipping with DNAnexus incompatible with newer conda
	bcbiovm_conda install -y -c conda-forge yq
	ln -s /install/bcbio-vm/anaconda/bin/yq /usr/local/bin/yq
	# dx-cwl: already installed with bcbio-vm	
	ln -s /install/bcbio-vm/anaconda/bin/dx-cwl /usr/local/bin/dx-cwl
