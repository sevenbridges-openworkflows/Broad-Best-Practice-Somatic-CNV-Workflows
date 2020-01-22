# Broad-Best-Practice-Somatic-CNV-Workflows

GATK4 CNV workflows has been wrapped in CWL v1.0 on SevenBridges platforms as part of BROAD best practices effort. It is an adaptation of original BROAD Institute's WDLs.

# Purpose :

BROAD Best Practices Somatic CNV Panel is used for creating a panel of normals (PON) given a set of normal samples.
BROAD Best Practices Somatic CNV Pair is used for detecting copy number variants (CNVs) in a single sample.

The reference used must be the same between PON and case samples.

Common Use Cases

# Somatic CNV Panel Workflow:

For CNV discovery, the PON is created by running the initial coverage collection tools individually on a set of normal samples and combining the resulting copy ratio data using a dedicated PON creation tool. This produces a binary file that can be used as a PON. It is very important to use normal samples that are as technically similar as possible to the tumor samples (same exome or genome preparation methods, sequencing technology etc.).

The basis of copy number variant detection is formed by collecting coverage counts, while the resolution of the analysis is defined by the genomic intervals list. In the case of whole genome data, the reference genome is divided into equally sized intervals or bins, while for exome data, the target regions of the capture kit should be padded. In either case, the PreprocessIntervals tool is used for preparing the intervals list which is then used for collecting raw integer counts. For this step CollectReadCounts is utilized, which counts reads that overlap the interval. Finally a CNV panel of normals is generated using the CreateReadCountPanelOfNormals tool.

In creating a PON, CreateReadCountPanelOfNormals abstracts the counts data for the samples and the intervals using Singular Value Decomposition (SVD), a type of Principal Component Analysis. The normal samples in the PON should match the sequencing approach of the case sample under scrutiny. This applies especially to targeted exome data because the capture step introduces target-specific noise.

# Somatic CNV Pair Workflow:

The workflow denoises case sample alignment data against a panel of normals (PON), created by GATK CNV Panel Workflow, to obtain copy ratios and models segments from the copy ratios and allelic counts. The latter modeling incorporates data from a matched control sample. The same workflow steps apply to targeted exome and whole genome sequencing data.

The basis of copy number variant detection is formed by collecting coverage counts, while the resolution of the analysis is defined by the genomic intervals list. In the case of whole genome data, the reference genome is divided into equally sized intervals or bins, while for exome data, the target regions of the capture kit should be padded. In either case the PreprocessIntervals tool is used for preparing the intervals list which is then used for collecting the raw integer counts. For this step,CollectReadCounts is utilized, which counts reads that overlap the interval. Read counts are standardized and denoised against the PON with the DenoiseReadCounts tool. Standardized and denoised copy ratios are plotted using the PlotDenoisedCopyRatios tool.

Next step in the workflow is segmentation, performed by the ModelSegments tool. In segmentation, contiguous copy ratios are grouped together into segments. The tool performs segmentation for both copy ratios and for allelic copy ratios, given allelic counts. CollectAllelicCounts will tabulate counts of the reference allele and counts of the dominant alternate allele for each site in a given genomic intervals list (Common sites). Modeled copy ratio and allelic fraction segments are plotted using the PlotModeledSegments tool.

The CallCopyRatioSegments tool allows for systematic calling of copy-neutral, amplified and deleted segments. The Neutral segment copy ratio lower bound (default 0.9) and Neutral segment copy ratio upper bound (default 1.1) parameters together set the copy ratio range for copy-neutral segments.

# LICENCING

Copyright Broad Institute, 2019 | BSD-3 This script is released under the WDL open source code license (BSD-3) (full license text at https://github.com/openwdl/wdl/blob/master/LICENSE). Note however that the programs it calls may be subject to different licenses. Users are responsible for checking that they are authorized to run all programs before running this script.
