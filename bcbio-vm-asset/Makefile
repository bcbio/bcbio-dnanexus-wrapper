all:
	wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
	bash Miniconda2-latest-Linux-x86_64.sh -b -p /install/bcbio-vm/anaconda
	/install/bcbio-vm/anaconda/bin/conda install --yes -c conda-forge -c bioconda bcbio-nextgen-vm bcbio-nextgen
	ln -s /install/bcbio-vm/anaconda/bin/bcbio_vm.py /usr/local/bin/bcbio_vm.py
	ln -s /install/bcbio-vm/anaconda/bin/conda /usr/local/bin/bcbiovm_conda
	ln -s /install/bcbio-vm/anaconda/bin/python /usr/local/bin/bcbiovm_python
