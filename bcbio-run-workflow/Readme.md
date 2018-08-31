<!-- dx-header -->
# Run bcbio workflows

[bcbio](https://bcbio-nextgen.readthedocs.io/en/latest/) provides community
built variant calling, RNA-seq and small RNA workflows. You run a wide variety
of analyses with high level control over tools and algorithmic processing
decisions.

Read [the full documentation to setup and run a bcbio
analysis](https://bcbio-nextgen.readthedocs.io/en/latest/contents/cwl.html#running-on-dnanexus-hosted-cloud),
which walks through each step in the process. This details uploading files,
setting up your configuration, and starting the app.

Briefly, this app takes 3 inputs:

- A template YAML file describing the analysis parameters.

- A sample CSV file describing the samples.
  bcbio's [automated sample
  configuration](https://bcbio-nextgen.readthedocs.io/en/latest/contents/configuration.html#automated-sample-configuration)
  describes both this and the template file in more detail.

- A system YAML describing the locations of DNAnexus files and the cloud
  resources (cores and memory).

bcbio finds DNAnexus file references from the names in the input files,
creates a [Common Workflow Language](https://www.commonwl.org/) description of
the workflow, and then uses [DNAnexus' dx-cwl converter](https://github.com/dnanexus/dx-cwl))
to run on the platform.

This app is paired with publicly hosted reference genomes in the
[bcbio_resources project](https://platform.dnanexus.com/projects/F541fX00f5v9vKJjJ34gvgbv/data/).

Development of this application is possible thanks to support from AstraZeneca
[Center for Genomics Research (CGR)](https://www.astrazeneca.com/media-centre/articles/2017/harnessing-the-power-of-genomics-through-global-collaborations-and-scientific-innovation-12012018.html)
and [Translational Oncology](https://www.astrazeneca.com/our-focus-areas/oncology.html).
