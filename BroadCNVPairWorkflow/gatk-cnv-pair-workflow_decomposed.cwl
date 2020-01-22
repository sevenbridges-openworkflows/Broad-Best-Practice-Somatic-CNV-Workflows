dct:creator:
  "@id": "sbg"
  foaf:name: SevenBridges
  foaf:mbox: "mailto:support@sbgenomics.com"
$namespaces:
  sbg: https://sevenbridges.com
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
class: Workflow
cwlVersion: v1.0
doc: "GATK CNV Somatic Pair workflow is used for detecting copy number variants (CNVs)\
  \ as well as allelic segments in a single sample.\n\n### Common Use Cases\n\nThe\
  \ workflow denoises case sample alignment data against a panel of normals (PON),\
  \ created by **GATK CNV Panel Workflow**, to obtain copy ratios and models segments\
  \ from the copy ratios and allelic counts. The latter modeling incorporates data\
  \ from a matched control sample. The same workflow steps apply to targeted exome\
  \ and whole genome sequencing data [1].\n\nThe basis of copy number variant detection\
  \ is formed by collecting coverage counts, while the resolution of the analysis\
  \ is defined by the genomic intervals list. In the case of whole genome data, the\
  \ reference genome is divided into equally sized intervals or bins, while for exome\
  \ data, the target regions of the capture kit should be padded. In either case **PreprocessIntervals**\
  \ tool is used for preparing the intervals list which is then used for collecting\
  \ the raw integer counts. For this step **CollectReadCounts** tool is utilized,\
  \ which counts reads that overlap the interval. Read counts are standardized and\
  \ denoised against the PON with **DenoiseReadCounts** tool. Standardized and denoised\
  \ copy ratios are plotted with **PlotDenoisedCopyRatios** tool [2].\n\nNext step\
  \ in the workflow is segmentation, performed by **ModelSegments** tool [3]. In segmentation,\
  \ contiguous copy ratios are grouped together into segments. The tool performs segmentation\
  \ for both copy ratios and for allelic copy ratios, given allelic counts. **CollectAllelicCounts**\
  \ tool will tabulate counts of the reference allele and counts of the dominant alternate\
  \ allele for each site in a given genomic intervals list (**Common sites**). Modeled\
  \ copy ratio and allelic fraction segments are plotted with **PlotModeledSegments**\
  \ tool.\n\n**CallCopyRatioSegments** tool allows for systematic calling of copy-neutral,\
  \ amplified and deleted segments. The parameters **Neutral segment copy ratio lower\
  \ bound** (default 0.9) and **Neutral segment copy ratio upper bound** (default\
  \ 1.1) together set the copy ratio range for copy-neutral segments [4].\n\nSome\
  \ of the common input parameters are listed below:\n* **Input reads - tumor** -\
  \ Tumor BAM/SAM/CRAM file. In case of BAM and CRAM formats index files BAI and CRAI\
  \ are required.\n* **Input reads - normal** - Matched normal BAM/SAM/CRAM file.\
  \ In case of BAM and CRAM formats index files BAI and CRAI are required.\n* **Panel\
  \ of normals** - CNV panel of normals (PON) file in HDF5 format.\n* **Reference**\
  \ - Reference genome in FASTA format along with FAI and DICT secondary files.\n\
  * **Intervals** - Required for both WGS and WES cases. Accepted formats must be\
  \ compatible with the GATK `-L` argument. For WGS, the intervals should simply cover\
  \ the autosomal chromosomes (sex chromosomes may be included, but care should be\
  \ taken to avoid creating panels of mixed sex, and to denoise case samples only\
  \ with panels containing only individuals of the same sex as the case samples) [5].\n\
  * **Bin length** - This argument is used by **PreprocessIntervals** tool and must\
  \ be set to the same value that was used to create PON file. If intervals in PON\
  \ do not match exactly with the ones used to collect read counts for case sample,\
  \ the workflow will produce an error. For WES analysis this parameter should be\
  \ set to 0.\n* **Common sites** - Sites at which allelic counts will be collected,\
  \ used in **CollectAllelicCounts** tool. File must be compatible with GATK -L argument.\
  \ This is usually dbsnp VCF or Mills gold standard (SNPs only) VCF file. In case\
  \ of WES analysis we advise using subset of this file with variants contained in\
  \ target intervals. This would reduce execution time of **CollectAllelicCounts**\
  \ tool and would require less resources (see *Common Issues and Important Notes*).\n\
  \n### Changes Introduced by Seven Bridges\n* Outputs of several tools in the workflow\
  \ are grouped together using **SBG Group Outputs** tool. This does not affect the\
  \ contents of the files nor execution performance, it is introduced with the purpose\
  \ of keeping output files neatly organized.\n\n### Common Issues and Important Notes\n\
  * For WGS and some cases of WES samples **CollectAllelicCounts** will require more\
  \ memory than the default 13000 MB. If the entire set of variants from dbsnp is\
  \ used as input for this tool we advise allocating at least 100000 MB (100GB) of\
  \ memory through **Memory per job** parameter.\n* For WGS analysis **ModelSegments**\
  \ may require more memory than the default 13000 MB. We advise allocating at least\
  \ 32000 MB (32GB) of memory through **Memory per job** parameter.\n\n### Performance\
  \ Benchmarking\n| Input Size | Experimental Strategy | Coverage | Duration | Cost\
  \ (on demand) |\n| --- | --- | --- | --- | --- | --- |\n| 2 x 45GB | WGS | 8x |\
  \ 1h 34min | $3.27 | \n| 2 x 120GB | WGS | 25x | 3h 23min | $7.08 |\n| 2 x 210GB\
  \ | WGS | 40x | 4h 57min | $10.56 |\n| 2 x 420GB | WGS | 80x | 8h 58min | $19.96\
  \ |\n\n\n### API Python Implementation\nThe app's draft task can also be submitted\
  \ via the **API**. In order to learn how to get your **Authentication token** and\
  \ **API endpoint** for corresponding platform visit our [documentation](https://github.com/sbg/sevenbridges-python#authentication-and-configuration).\n\
  \n```python\n# Initialize the SBG Python API\nfrom sevenbridges import Api\napi\
  \ = Api(token=\"enter_your_token\", url=\"enter_api_endpoint\")\n# Get project_id/app_id\
  \ from your address bar. Example: https://igor.sbgenomics.com/u/your_username/project/app\n\
  project_id = \"your_username/project\"\napp_id = \"your_username/project/app\"\n\
  # Replace inputs with appropriate values\ninputs = {\n\t\"intervals\": api.files.query(project=project_id,\
  \ names=[\"enter_filename\"])[0], \n\t\"reference\": api.files.query(project=project_id,\
  \ names=[\"enter_filename\"])[0], \n\t\"sequence_dictionary\": api.files.query(project=project_id,\
  \ names=[\"enter_filename\"])[0], \n\t\"input_alignments_tumor\": api.files.query(project=project_id,\
  \ names=[\"enter_filename\"])[0], \n\t\"common_sites\": api.files.query(project=project_id,\
  \ names=[\"enter_filename\"])[0], \n\t\"count_panel_of_normals\": api.files.query(project=project_id,\
  \ names=[\"enter_filename\"])[0]}\n# Creates draft task\ntask = api.tasks.create(name=\"\
  GATK CNV Somatic Pair Workflow - API Run\", project=project_id, app=app_id, inputs=inputs,\
  \ run=False)\n```\n\nInstructions for installing and configuring the API Python\
  \ client, are provided on [github](https://github.com/sbg/sevenbridges-python#installation).\
  \ For more information about using the API Python client, consult [the client documentation](http://sevenbridges-python.readthedocs.io/en/latest/).\
  \ **More examples** are available [here](https://github.com/sbg/okAPI).\n\nAdditionally,\
  \ [API R](https://github.com/sbg/sevenbridges-r) and [API Java](https://github.com/sbg/sevenbridges-java)\
  \ clients are available. To learn more about using these API clients please refer\
  \ to the [API R client documentation](https://sbg.github.io/sevenbridges-r/), and\
  \ [API Java client documentation](https://docs.sevenbridges.com/docs/java-library-quickstart).\n\
  \n\n### References\n* [1] [https://github.com/gatk-workflows/gatk4-somatic-cnvs/blob/master/cnv_somatic_pair_workflow.wdl](https://github.com/gatk-workflows/gatk4-somatic-cnvs/blob/master/cnv_somatic_pair_workflow.wdl)\n\
  * [2] [https://gatkforums.broadinstitute.org/dsde/discussion/11682](https://gatkforums.broadinstitute.org/dsde/discussion/11682)\n\
  * [3] [https://gatkforums.broadinstitute.org/dsde/discussion/11683#6](https://gatkforums.broadinstitute.org/dsde/discussion/11683#6)\n\
  * [4] [https://gatkforums.broadinstitute.org/dsde/discussion/11683#6](https://gatkforums.broadinstitute.org/dsde/discussion/11683#6)\n\
  * [5] [https://gatkforums.broadinstitute.org/gatk/discussion/11009/intervals-and-interval-lists](https://gatkforums.broadinstitute.org/gatk/discussion/11009/intervals-and-interval-lists)"
hints:
- class: sbg:maxNumberOfParallelInstances
  value: '2'
id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-cnv-somatic-pair-workflow/71
inputs:
- doc: Genomic intervals to exclude from processing.
  id: exclude_intervals
  label: Blacklisted intervals
  sbg:x: -766.8736572265625
  sbg:y: 262.8729553222656
  type: File?
- doc: Genomic intervals over which to operate.
  id: intervals
  label: Intervals
  sbg:x: -761.341552734375
  sbg:y: 104.20606994628906
  type: File
- doc: Use the given sequence dictionary as the master/canonical sequence dictionary.
    Must be a .dict file.
  id: sequence_dictionary
  label: Sequence dictionary
  sbg:fileTypes: DICT
  sbg:x: -760.271240234375
  sbg:y: -52.12045669555664
  type: File
- id: bin_length
  sbg:exposed: true
  type: int?
- id: padding
  sbg:exposed: true
  type: int?
- doc: Base calls with lower quality will be filtered out of pileups.
  id: minimum_base_quality
  label: Minimum base quality
  sbg:x: -410.5151672363281
  sbg:y: -428.8094482421875
  type: int?
- doc: Number of eigensamples to use for denoising. If not specified or if the number
    of eigensamples available in the panel of normals is smaller than this, all eigensamples
    will be used.
  id: number_of_eigensamples
  label: Number of eigensamples
  sbg:x: 89.68384552001953
  sbg:y: 536.1905517578125
  type: int?
- doc: Input hdf5 file containing the panel of normals (output of createreadcountpanelofnormals).
  id: count_panel_of_normals
  label: Count panel of normals
  sbg:fileTypes: HDF5
  sbg:x: 90.80239868164062
  sbg:y: 662.96044921875
  type: File
- doc: Threshold length (in bp) for contigs to be plotted. Contigs with lengths less
    than this threshold will not be plotted. This can be used to filter out mitochondrial
    contigs, unlocalized contigs, etc.
  id: minimum_contig_length
  label: Minimum contig length
  sbg:x: 587.72412109375
  sbg:y: 576.8390502929688
  type: int?
- doc: Window sizes to use for calculating local changepoint costs. For each window
    size, the cost for each data point to be a changepoint will be calculated assuming
    that the point demarcates two adjacent segments of that size. Including small
    (large) window sizes will increase sensitivity to small (large) events. Duplicate
    values will be ignored. Default value:.
  id: window_size
  label: Window size
  sbg:x: 293.54693603515625
  sbg:y: -1370.39599609375
  type: int[]?
- doc: Number of 10.
  id: smoothing_credible_interval_threshold_copy_ratio
  label: Smoothing credible interval threshold copy ratio
  sbg:x: 197.48780822753906
  sbg:y: -1285.74755859375
  type: float?
- doc: Number of 10.
  id: smoothing_credible_interval_threshold_allele_fraction
  label: Smoothing credible interval threshold allele fraction
  sbg:x: 141.62152099609375
  sbg:y: -1200.6685791015625
  type: float?
- doc: Number of segmentation-smoothing iterations per mcmc model refit. (increasing
    this will decrease runtime, but the final number of segments may be higher. Setting
    this to 0 will completely disable model refitting between iterations.).
  id: number_of_smoothing_iterations_per_fit
  label: Number of smoothing iterations per fit
  sbg:x: 71.42814636230469
  sbg:y: -1113.1690673828125
  type: int?
- doc: Total number of mcmc samples for copy-ratio model.
  id: number_of_samples_copy_ratio
  label: Number of samples copy ratio
  sbg:x: 0.8780487775802612
  sbg:y: -1017.8292846679688
  type: int?
- doc: Total number of mcmc samples for allele-fraction model.
  id: number_of_samples_allele_fraction
  label: Number of samples allele fraction
  sbg:x: -23.829267501831055
  sbg:y: -917.8414916992188
  type: int?
- doc: Factor a for the penalty on the number of changepoints per chromosome for segmentation.
    Adds a penalty of the form a.
  id: number_of_changepoints_penalty_factor
  label: Number of changepoints penalty factor
  sbg:x: -61.646339416503906
  sbg:y: -813.9512329101562
  type: float?
- doc: Number of burn-in samples to discard for copy-ratio model.
  id: number_of_burn_in_samples_copy_ratio
  label: Number of burn in samples copy ratio
  sbg:x: -96.95121765136719
  sbg:y: -699.4390258789062
  type: int?
- doc: Number of burn-in samples to discard for allele-fraction model.
  id: number_of_burn_in_samples_allele_fraction
  label: Number of burn in samples allele fraction
  sbg:x: 453.03509521484375
  sbg:y: -1308.385986328125
  type: int?
- doc: Alpha hyperparameter for the 4-parameter beta-distribution prior on segment
    minor-allele fraction. The prior for the minor-allele fraction f in each segment
    is assumed to be beta(alpha, 1, 0, 1/2). Increasing this hyperparameter will reduce
    the effect of reference bias at the expense of sensitivity. 0.
  id: minor_allele_fraction_prior_alpha
  label: Minor allele fraction prior alpha
  sbg:x: 378.6219787597656
  sbg:y: -1192.1463623046875
  type: float?
- doc: Minimum total count for filtering allelic counts in matched-normal sample,
    if available.
  id: minimum_total_allele_count_normal
  label: Minimum total allele count normal
  sbg:x: 317.31707763671875
  sbg:y: -1067.280517578125
  type: int?
- doc: 'Minimum total count for filtering allelic counts in the case sample, if available.  The
    default value of zero is appropriate for matched-normal mode; increase to an appropriate
    value for case-only mode.  Default value: 0.'
  id: minimum_total_allele_count_case
  label: Minimum total allele count case
  sbg:x: 236.73170471191406
  sbg:y: -957.231689453125
  type: int?
- doc: Maximum number of iterations allowed for segmentation smoothing.
  id: maximum_number_of_smoothing_iterations
  label: Maximum number of smoothing iterations
  sbg:x: 204.80487060546875
  sbg:y: -844.7073364257812
  type: int?
- doc: Maximum number of segments allowed per chromosome.
  id: maximum_number_of_segments_per_chromosome
  label: Maximum number of segments per chromosome
  sbg:x: 168.3902587890625
  sbg:y: -731.9024047851562
  type: int?
- doc: Variance of gaussian kernel for copy-ratio segmentation, if performed. If zero,
    a linear kernel will be used. 0.
  id: kernel_variance_copy_ratio
  label: Kernel variance copy ratio
  sbg:x: 128.31707763671875
  sbg:y: -606.276123046875
  type: float?
- doc: Variance of gaussian kernel for allele-fraction segmentation, if performed.
    If zero, a linear kernel will be used. 025.
  id: kernel_variance_allele_fraction
  label: Kernel variance allele fraction
  sbg:x: 615.0853881835938
  sbg:y: -1178.48779296875
  type: float?
- doc: Relative scaling s of the kernel k_af for allele-fraction segmentation to the
    kernel k_cr for copy-ratio segmentation. If multidimensional segmentation is performed,
    the total kernel used will be k_cr.
  id: kernel_scaling_allele_fraction
  label: Kernel scaling allele fraction
  sbg:x: 540.5609741210938
  sbg:y: -1054.8780517578125
  type: float?
- doc: Dimension of the kernel approximation. A subsample containing this number of
    data points will be used to construct the approximation for each chromosome. If
    the total number of data points in a chromosome is greater than this number, then
    all data points in the chromosome will be used. Time complexity scales quadratically
    and space complexity scales linearly with this parameter.
  id: kernel_approximation_dimension
  label: Kernel approximation dimension
  sbg:x: 479.1707458496094
  sbg:y: -934.243896484375
  type: int?
- doc: Log-ratio threshold for genotyping and filtering homozygous allelic counts,
    if available. Increasing this value will increase the number of sites assumed
    to be heterozygous for modeling. 0.
  id: genotyping_homozygous_log_ratio_threshold
  label: Genotyping homozygous log ratio threshold
  sbg:x: 435.56097412109375
  sbg:y: -816.8170776367188
  type: float?
- doc: Maximum base-error rate for genotyping and filtering homozygous allelic counts,
    if available. The likelihood for an allelic count to be generated from a homozygous
    site will be integrated from zero base-error rate up to this value. Decreasing
    this value will increase the number of sites assumed to be heterozygous for modeling.
    05.
  id: genotyping_base_error_rate
  label: Genotyping base error rate
  sbg:x: 395.6463317871094
  sbg:y: -681.1951293945312
  type: float?
- doc: Threshold on z-score of non-log2 copy ratio used for determining outlier copy-neutral
    segments. If non-log2 copy ratio z-score is above this threshold for a copy-neutral
    segment, it is considered an outlier and not used in the calculation of the length-weighted
    mean and standard deviation used for calling. 0.
  id: outlier_neutral_segment_copy_ratio_z_score_threshold
  label: Outlier neutral segment copy ratio Z score threshold
  sbg:x: 1348.603759765625
  sbg:y: 468
  type: float?
- doc: Upper bound on non-log2 copy ratio used for determining copy-neutral segments.
  id: neutral_segment_copy_ratio_upper_bound
  label: Neutral segment copy ratio upper bound
  sbg:x: 1361.097900390625
  sbg:y: 601.6483764648438
  type: float?
- doc: Lower bound on non-log2 copy ratio used for determining copy-neutral segments.
  id: neutral_segment_copy_ratio_lower_bound
  label: Neutral segment copy ratio lower bound
  sbg:x: 1419.526611328125
  sbg:y: 731
  type: float?
- doc: Threshold on z-score of non-log2 copy ratio used for calling segments. 0.
  id: calling_copy_ratio_z_score_threshold
  label: Calling copy ratio Z score threshold
  sbg:x: 1469.4390869140625
  sbg:y: 855.593505859375
  type: float?
- id: run_oncotator
  sbg:exposed: true
  type: boolean?
- doc: Default 13000
  id: memory_collectalleliccounts
  label: Momory per job - CollectAllelicCounts
  sbg:x: -402.5231018066406
  sbg:y: -558
  type: int?
- id: memory_modelsegments
  label: Memory per job - ModelSegments
  sbg:x: 692.1048583984375
  sbg:y: -1294.2493896484375
  type: int?
- id: in_reference
  sbg:fileTypes: FASTA, FA
  sbg:x: -760.6112060546875
  sbg:y: -202.26959228515625
  secondaryFiles:
  - .fai
  - ^.dict
  type: File
- id: common_sites
  sbg:fileTypes: VCF, BED, INTERVALS, INTERVAL_LIST
  sbg:x: -410.6506652832031
  sbg:y: -301.02398681640625
  type: File
- id: in_alignments_tumor
  sbg:fileTypes: BAM, SAM, CRAM
  sbg:x: -379.5942077636719
  sbg:y: 388.74725341796875
  secondaryFiles:
  - .bai
  type: File
- id: in_alignments_normal
  sbg:fileTypes: BAM, SAM, CRAM
  sbg:x: -379.3818664550781
  sbg:y: 551
  secondaryFiles:
  - .bai
  type: File?
label: GATK CNV Somatic Pair Workflow
outputs:
- id: out_tumor
  outputSource:
  - sbg_group_outputs_tumor/out_array
  sbg:fileTypes: TXT, TSV, SEG, PNG, HDF5, PARAM
  sbg:x: 2996.448486328125
  sbg:y: -599.614990234375
  type: File[]
- id: out_normal
  outputSource:
  - sbg_group_outputs_normal/out_array
  sbg:fileTypes: TXT, TSV, SEG, PNG, HDF5, PARAM
  sbg:x: 2995.782958984375
  sbg:y: -396.1174011230469
  type: File[]
- id: out_oncotator
  outputSource:
  - sbg_group_outputs_oncotator/out_array
  sbg:fileTypes: TXT, TSV, SEG, PNG, HDF5, PARAM
  sbg:x: 3161.982177734375
  sbg:y: 55.87649154663086
  type: File[]
- id: entity_id
  outputSource:
  - gatk_collectreadcounts_tumor/entity_id
  sbg:x: 590.3333129882812
  sbg:y: 787.6666870117188
  type: string?
- id: entity_id_1
  outputSource:
  - gatk_collectreadcounts_normal/entity_id
  sbg:x: 599.6666870117188
  sbg:y: 964
  type: string?
requirements:
- class: StepInputExpressionRequirement
- class: InlineJavascriptRequirement
- class: MultipleInputFeatureRequirement
sbg:appVersion:
- v1.0
sbg:content_hash: a0575096aaac4108eff7240802c121c3be5beb929d0c46546d95610fac1929029
sbg:contributors:
- milena_stanojevic
- stefan_stojanovic
sbg:createdBy: stefan_stojanovic
sbg:createdOn: 1551311053
sbg:id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-cnv-somatic-pair-workflow/71
sbg:image_url: https://igor.sbgenomics.com/ns/brood/images/veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-cnv-somatic-pair-workflow/71.png
sbg:latestRevision: 71
sbg:modifiedBy: milena_stanojevic
sbg:modifiedOn: 1578663620
sbg:project: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev
sbg:projectName: GATK 4.1.0.0 Toolkit DEV
sbg:publisher: sbg
sbg:revision: 71
sbg:revisionNotes: sbg group outputs tool update ->  File? -> [File, null], null (inputs)
sbg:revisionsInfo:
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551311053
  sbg:revision: 0
  sbg:revisionNotes: null
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551311143
  sbg:revision: 1
  sbg:revisionNotes: add PreprocessIntervals, expose ports and parameters
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551311578
  sbg:revision: 2
  sbg:revisionNotes: add CollectAllelicCounts for tumor and normal, connect ports,
    expose inputs, set default memory_per_job to 13000mb
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551311839
  sbg:revision: 3
  sbg:revisionNotes: add CollectReadCounts for tumor and normal sample, connect ports,
    expose input parameters, set default values and set memory_per_job to 7000
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551312187
  sbg:revision: 4
  sbg:revisionNotes: add DenoiseReadCounts, connect ports, set default memory_per_job
    to 13000
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551312508
  sbg:revision: 5
  sbg:revisionNotes: add PlotDenoisedCopyRatios, connect ports, set default memory_per_job
    to 7000
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551313172
  sbg:revision: 6
  sbg:revisionNotes: add ModelSegments tumor, expose all ports, set default memory_per_job
    to 13000
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551313599
  sbg:revision: 7
  sbg:revisionNotes: add ModelSegments normal, expose all ports, set default memory_per_job
    to 13000
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551314054
  sbg:revision: 8
  sbg:revisionNotes: add PlotModeledSegments for tumor and normal, connect ports,
    set default memory_per_job to 7000
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551314454
  sbg:revision: 9
  sbg:revisionNotes: add CallCopyRatioSegments for tumor and normal, connect ports,
    set default memory_per_job to 7000
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551314758
  sbg:revision: 10
  sbg:revisionNotes: add OncotateSegments, connect ports, set input parameters to
    default values
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551314863
  sbg:revision: 11
  sbg:revisionNotes: expose few outputs
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551315867
  sbg:revision: 12
  sbg:revisionNotes: 'PreprocessIntervals: interval_merging_rule set to overlapping_only'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551315933
  sbg:revision: 13
  sbg:revisionNotes: set instance hint to c4.4xlarge
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551354125
  sbg:revision: 14
  sbg:revisionNotes: add description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551354347
  sbg:revision: 15
  sbg:revisionNotes: edit typos in description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551354636
  sbg:revision: 16
  sbg:revisionNotes: edit references
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551354878
  sbg:revision: 17
  sbg:revisionNotes: edit description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551355928
  sbg:revision: 18
  sbg:revisionNotes: add sbg_group_outputs for tumor and normal files
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551356121
  sbg:revision: 19
  sbg:revisionNotes: add output ports for preprocessed intervals and entity IDs; add
    sbg_group_outputs for oncotator; remove redundant output ports
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551356469
  sbg:revision: 20
  sbg:revisionNotes: set required inputs
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551356777
  sbg:revision: 21
  sbg:revisionNotes: edit benchmarking table
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551385474
  sbg:revision: 22
  sbg:revisionNotes: expose memory_per_job for CollectAllelicCounts step as ports,
    leave default value at 13000
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551385527
  sbg:revision: 23
  sbg:revisionNotes: set instance hint to c4.8xlarge, to allow for more memory if
    needed
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551386858
  sbg:revision: 24
  sbg:revisionNotes: add common issues and notes section to description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551392959
  sbg:revision: 25
  sbg:revisionNotes: set c4.8xlarge instance type
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551398227
  sbg:revision: 26
  sbg:revisionNotes: 'CollectAllelicCounts: memory_overhead set to 100 for both tumor
    and normal'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551566666
  sbg:revision: 27
  sbg:revisionNotes: 'CollectAllelicCounts: revert to revision 2; remove instance
    hint on wf level'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551598381
  sbg:revision: 28
  sbg:revisionNotes: expose memory_per_job for modelSegments steps, connect to single
    input port
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551693548
  sbg:revision: 29
  sbg:revisionNotes: 'ModelSegments: update memory requirement expression, set default
    2048, remove default overhead; set sbg:maxNumberOfParallelInstances hint to 2'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551705063
  sbg:revision: 30
  sbg:revisionNotes: add api python implementation
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551708732
  sbg:revision: 31
  sbg:revisionNotes: update description, common issues and important notes
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551708858
  sbg:revision: 32
  sbg:revisionNotes: fix description formatting
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551780522
  sbg:revision: 33
  sbg:revisionNotes: add benchmarking data
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551781919
  sbg:revision: 34
  sbg:revisionNotes: change labels and add description for input files
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552564041
  sbg:revision: 35
  sbg:revisionNotes: add input parameter labels and descriptions for most of tools
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552564587
  sbg:revision: 36
  sbg:revisionNotes: add input parameter labels and descriptions for ModelSegments
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553786058
  sbg:revision: 37
  sbg:revisionNotes: update apps, reconnect ports, output couple of files for testing
    purposes
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553792279
  sbg:revision: 38
  sbg:revisionNotes: connect unconnected ports
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553793292
  sbg:revision: 39
  sbg:revisionNotes: connect allelic counts to reads port
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553795445
  sbg:revision: 40
  sbg:revisionNotes: connect CallCopyRatioSegments with ModelSegments
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553807947
  sbg:revision: 41
  sbg:revisionNotes: fix description per review notes
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553808193
  sbg:revision: 42
  sbg:revisionNotes: fix typos in description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553808745
  sbg:revision: 43
  sbg:revisionNotes: fix minor typos in description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553812004
  sbg:revision: 44
  sbg:revisionNotes: 'CollectReadCounts: set in_alignments (--input) parameter to
    required'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553815328
  sbg:revision: 45
  sbg:revisionNotes: connect all ports, set required inputs, output all files
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553815593
  sbg:revision: 46
  sbg:revisionNotes: 'PlotDenoisedCopyRatios: fix conditional metadata inheritance
    for all output files'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553816060
  sbg:revision: 47
  sbg:revisionNotes: re-expose input reads ports
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553816521
  sbg:revision: 48
  sbg:revisionNotes: 'CollectAllelicCounts: fix output naming expression, concat to
    array before accessing element'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553816957
  sbg:revision: 49
  sbg:revisionNotes: 'set in_aligments_normal to not required; CollectReadCounts:
    fix output naming expression, concat to array before accessing element'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553817275
  sbg:revision: 50
  sbg:revisionNotes: 'CollectAllelicCounts and CollectReadCounts: add secondary file
    requirements for in_alignments'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553854217
  sbg:revision: 51
  sbg:revisionNotes: add new benchmarking info
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553950129
  sbg:revision: 52
  sbg:revisionNotes: minor fixes in description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553950205
  sbg:revision: 53
  sbg:revisionNotes: 'CollectReadCounts: change back choices for output_format to
    uppercase; fix glob expressions to catch uppercase extensions; add secondary file
    requirements for in_reference on wf level'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553952707
  sbg:revision: 54
  sbg:revisionNotes: test secondary file requirement {.bai,^.bai} on wf level
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553954954
  sbg:revision: 55
  sbg:revisionNotes: remove secondary file requirement for in_alignments_tumor on
    wf level
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1554027328
  sbg:revision: 56
  sbg:revisionNotes: add coverage info to benchmarking table
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559751443
  sbg:revision: 57
  sbg:revisionNotes: update all apps
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559752163
  sbg:revision: 58
  sbg:revisionNotes: 'update CollectReadCounts: edit entity_id eval expression'
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1577365806
  sbg:revision: 59
  sbg:revisionNotes: "CWL validation - adapting connections between tools - File\u2192\
    [ File ]"
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1577369637
  sbg:revision: 60
  sbg:revisionNotes: Secondary files for CollectAllelicCounts tumor/normal updated
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1577370537
  sbg:revision: 61
  sbg:revisionNotes: Secondary files for CollectReadCounts tumor/normal updated (tool
    itself is updated)
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1577462159
  sbg:revision: 62
  sbg:revisionNotes: Glob change for CollectReadCounts -> only *hdf5
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578492867
  sbg:revision: 63
  sbg:revisionNotes: SBG Group Outputs update - only HDF5
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578492929
  sbg:revision: 64
  sbg:revisionNotes: InlineJavaScript
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578497030
  sbg:revision: 65
  sbg:revisionNotes: SBG group outputs tool update - in array input -> no file types
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578508184
  sbg:revision: 66
  sbg:revisionNotes: SBG group output tool update
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578656276
  sbg:revision: 67
  sbg:revisionNotes: SBG Group Outputs tool update - removed base command "echo"
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578657286
  sbg:revision: 68
  sbg:revisionNotes: SBG Group Outputs tool update - test tool
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578658141
  sbg:revision: 69
  sbg:revisionNotes: No SBG Group Outputs for Oncotator
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578662244
  sbg:revision: 70
  sbg:revisionNotes: update sbg group outputs tool - command line broken into lines
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578663620
  sbg:revision: 71
  sbg:revisionNotes: sbg group outputs tool update ->  File? -> [File, null], null
    (inputs)
sbg:sbgMaintained: false
sbg:validationErrors: []
steps:
  gatk_callcopyratiosegments_normal:
    in:
    - id: calling_copy_ratio_z_score_threshold
      source: calling_copy_ratio_z_score_threshold
    - id: copy_ratio_segments
      source: gatk_modelsegments_normal/copy_ratio_only_segments
    - default: 7000
      id: memory_per_job
    - id: neutral_segment_copy_ratio_lower_bound
      source: neutral_segment_copy_ratio_lower_bound
    - id: neutral_segment_copy_ratio_upper_bound
      source: neutral_segment_copy_ratio_upper_bound
    - id: outlier_neutral_segment_copy_ratio_z_score_threshold
      source: outlier_neutral_segment_copy_ratio_z_score_threshold
    label: GATK CallCopyRatioSegments Normal
    out:
    - id: called_segments
    - id: called_legacy_segments
    run: steps/gatk_callcopyratiosegments_tumor.cwl
    sbg:x: 2026.1405029296875
    sbg:y: 425.7521057128906
  gatk_callcopyratiosegments_tumor:
    in:
    - id: calling_copy_ratio_z_score_threshold
      source: calling_copy_ratio_z_score_threshold
    - id: copy_ratio_segments
      source: gatk_modelsegments_tumor/copy_ratio_only_segments
    - default: 7000
      id: memory_per_job
    - id: neutral_segment_copy_ratio_lower_bound
      source: neutral_segment_copy_ratio_lower_bound
    - id: neutral_segment_copy_ratio_upper_bound
      source: neutral_segment_copy_ratio_upper_bound
    - id: outlier_neutral_segment_copy_ratio_z_score_threshold
      source: outlier_neutral_segment_copy_ratio_z_score_threshold
    label: GATK CallCopyRatioSegments Tumor
    out:
    - id: called_segments
    - id: called_legacy_segments
    run: steps/gatk_callcopyratiosegments_tumor.cwl
    sbg:x: 2021.2625732421875
    sbg:y: 71.48369598388672
  gatk_cnv_oncotatesegments:
    in:
    - id: called_file
      source: gatk_callcopyratiosegments_tumor/called_segments
    - id: run_oncotator
      source: run_oncotator
    label: CNV OncotateSegments CWL 1.0
    out:
    - id: oncotated_called_file
    - id: oncotated_gene_list
    run: steps/gatk_cnv_oncotatesegments.cwl
    sbg:x: 2472.625732421875
    sbg:y: 67.08751678466797
  gatk_collectalleliccounts_normal:
    in:
    - id: in_alignments
      source:
      - in_alignments_normal
      valueFrom: '$(self ? [self] : self)'
    - id: common_sites
      source: common_sites
    - default: 100
      id: memory_overhead_per_job
    - default: 13000
      id: memory_per_job
      source: memory_collectalleliccounts
    - id: minimum_base_quality
      source: minimum_base_quality
    - id: in_reference
      source: in_reference
    label: GATK CollectAllelicCounts Normal
    out:
    - id: allelic_counts
    run: steps/gatk_collectalleliccounts_tumor.cwl
    sbg:x: 108.30455017089844
    sbg:y: -178
  gatk_collectalleliccounts_tumor:
    in:
    - id: in_alignments
      source:
      - in_alignments_tumor
      valueFrom: '$(self ? [self] : self)'
    - id: common_sites
      source: common_sites
    - default: 100
      id: memory_overhead_per_job
    - default: 13000
      id: memory_per_job
      source: memory_collectalleliccounts
    - id: minimum_base_quality
      source: minimum_base_quality
    - id: in_reference
      source: in_reference
    label: GATK CollectAllelicCounts Tumor
    out:
    - id: allelic_counts
    run: steps/gatk_collectalleliccounts_tumor.cwl
    sbg:x: 108.30455017089844
    sbg:y: -361.6609191894531
  gatk_collectreadcounts_normal:
    in:
    - id: in_alignments
      source:
      - in_alignments_normal
      valueFrom: '$(self ? [self] : self)'
    - default: OVERLAPPING_ONLY
      id: interval_merging_rule
    - id: intervals
      source:
      - gatk_preprocessintervals_4_1_0_0/out_intervals
      valueFrom: '$(self ? [self] : self)'
    - default: 7000
      id: memory_per_job
    - id: in_reference
      source: in_reference
    label: GATK CollectReadCounts Normal
    out:
    - id: read_counts
    - id: entity_id
    run: steps/gatk_collectreadcounts_tumor.cwl
    sbg:x: 96.52572631835938
    sbg:y: 341.644287109375
  gatk_collectreadcounts_tumor:
    in:
    - id: in_alignments
      source:
      - in_alignments_tumor
      valueFrom: '$(self ? [self] : self)'
    - default: OVERLAPPING_ONLY
      id: interval_merging_rule
    - id: intervals
      source:
      - gatk_preprocessintervals_4_1_0_0/out_intervals
      valueFrom: '$(self ? [self] : self)'
    - default: 7000
      id: memory_per_job
    - id: in_reference
      source: in_reference
    label: GATK CollectReadCounts Tumor
    out:
    - id: read_counts
    - id: entity_id
    run: steps/gatk_collectreadcounts_tumor.cwl
    sbg:x: 95.00000762939453
    sbg:y: 137.03176879882812
  gatk_denoisereadcounts_normal:
    in:
    - id: count_panel_of_normals
      source: count_panel_of_normals
    - id: read_counts
      source: gatk_collectreadcounts_normal/read_counts
    - default: 13000
      id: memory_per_job
    - id: number_of_eigensamples
      source: number_of_eigensamples
    - id: output_prefix
      source: gatk_collectreadcounts_normal/entity_id
    label: GATK DenoiseReadCounts Normal
    out:
    - id: out_denoised_copy_ratios
    - id: out_standardized_copy_ratios
    run: steps/gatk_denoisereadcounts_tumor.cwl
    sbg:x: 466.94854736328125
    sbg:y: 335.88140869140625
  gatk_denoisereadcounts_tumor:
    in:
    - id: count_panel_of_normals
      source: count_panel_of_normals
    - id: read_counts
      source: gatk_collectreadcounts_tumor/read_counts
    - default: 13000
      id: memory_per_job
    - id: number_of_eigensamples
      source: number_of_eigensamples
    - id: output_prefix
      source: gatk_collectreadcounts_tumor/entity_id
    label: GATK DenoiseReadCounts Tumor
    out:
    - id: out_denoised_copy_ratios
    - id: out_standardized_copy_ratios
    run: steps/gatk_denoisereadcounts_tumor.cwl
    sbg:x: 467.23712158203125
    sbg:y: 131.8814239501953
  gatk_modelsegments_normal:
    in:
    - id: allelic_counts
      source: gatk_collectalleliccounts_normal/allelic_counts
    - id: denoised_copy_ratios
      source: gatk_denoisereadcounts_normal/out_denoised_copy_ratios
    - id: genotyping_base_error_rate
      source: genotyping_base_error_rate
    - id: genotyping_homozygous_log_ratio_threshold
      source: genotyping_homozygous_log_ratio_threshold
    - id: kernel_approximation_dimension
      source: kernel_approximation_dimension
    - id: kernel_scaling_allele_fraction
      source: kernel_scaling_allele_fraction
    - id: kernel_variance_allele_fraction
      source: kernel_variance_allele_fraction
    - id: kernel_variance_copy_ratio
      source: kernel_variance_copy_ratio
    - id: maximum_number_of_segments_per_chromosome
      source: maximum_number_of_segments_per_chromosome
    - id: maximum_number_of_smoothing_iterations
      source: maximum_number_of_smoothing_iterations
    - default: 13000
      id: memory_per_job
      source: memory_modelsegments
    - id: minimum_total_allele_count_normal
      source: minimum_total_allele_count_normal
    - id: minor_allele_fraction_prior_alpha
      source: minor_allele_fraction_prior_alpha
    - id: number_of_burn_in_samples_allele_fraction
      source: number_of_burn_in_samples_allele_fraction
    - id: number_of_burn_in_samples_copy_ratio
      source: number_of_burn_in_samples_copy_ratio
    - id: number_of_changepoints_penalty_factor
      source: number_of_changepoints_penalty_factor
    - id: number_of_samples_allele_fraction
      source: number_of_samples_allele_fraction
    - id: number_of_samples_copy_ratio
      source: number_of_samples_copy_ratio
    - id: number_of_smoothing_iterations_per_fit
      source: number_of_smoothing_iterations_per_fit
    - id: output_prefix
      source: gatk_collectreadcounts_normal/entity_id
    - id: smoothing_credible_interval_threshold_allele_fraction
      source: smoothing_credible_interval_threshold_allele_fraction
    - id: smoothing_credible_interval_threshold_copy_ratio
      source: smoothing_credible_interval_threshold_copy_ratio
    - id: window_size
      source:
      - window_size
    - id: minimum_total_allele_count_case
      source: minimum_total_allele_count_case
    label: GATK ModelSegments Normal
    out:
    - id: het_allelic_counts
    - id: normal_het_allelic_counts
    - id: copy_ratio_only_segments
    - id: copy_ratio_legacy_segments
    - id: allele_fraction_legacy_segments
    - id: modeled_segments_begin
    - id: copy_ratio_parameters_begin
    - id: allele_fraction_parameters_begin
    - id: modeled_segments
    - id: copy_ratio_parameters
    - id: allele_fraction_parameters
    run: steps/gatk_modelsegments_tumor.cwl
    sbg:x: 1278.9649658203125
    sbg:y: -314
  gatk_modelsegments_tumor:
    in:
    - id: allelic_counts
      source: gatk_collectalleliccounts_tumor/allelic_counts
    - id: denoised_copy_ratios
      source: gatk_denoisereadcounts_tumor/out_denoised_copy_ratios
    - id: genotyping_base_error_rate
      source: genotyping_base_error_rate
    - id: genotyping_homozygous_log_ratio_threshold
      source: genotyping_homozygous_log_ratio_threshold
    - id: kernel_approximation_dimension
      source: kernel_approximation_dimension
    - id: kernel_scaling_allele_fraction
      source: kernel_scaling_allele_fraction
    - id: kernel_variance_allele_fraction
      source: kernel_variance_allele_fraction
    - id: kernel_variance_copy_ratio
      source: kernel_variance_copy_ratio
    - id: maximum_number_of_segments_per_chromosome
      source: maximum_number_of_segments_per_chromosome
    - id: maximum_number_of_smoothing_iterations
      source: maximum_number_of_smoothing_iterations
    - default: 13000
      id: memory_per_job
      source: memory_modelsegments
    - id: minimum_total_allele_count_normal
      source: minimum_total_allele_count_normal
    - id: minor_allele_fraction_prior_alpha
      source: minor_allele_fraction_prior_alpha
    - id: normal_allelic_counts
      source: gatk_collectalleliccounts_normal/allelic_counts
    - id: number_of_burn_in_samples_allele_fraction
      source: number_of_burn_in_samples_allele_fraction
    - id: number_of_burn_in_samples_copy_ratio
      source: number_of_burn_in_samples_copy_ratio
    - id: number_of_changepoints_penalty_factor
      source: number_of_changepoints_penalty_factor
    - id: number_of_samples_allele_fraction
      source: number_of_samples_allele_fraction
    - id: number_of_samples_copy_ratio
      source: number_of_samples_copy_ratio
    - id: number_of_smoothing_iterations_per_fit
      source: number_of_smoothing_iterations_per_fit
    - id: output_prefix
      source: gatk_collectreadcounts_tumor/entity_id
    - id: smoothing_credible_interval_threshold_allele_fraction
      source: smoothing_credible_interval_threshold_allele_fraction
    - id: smoothing_credible_interval_threshold_copy_ratio
      source: smoothing_credible_interval_threshold_copy_ratio
    - id: window_size
      source:
      - window_size
    - id: minimum_total_allele_count_case
      source: minimum_total_allele_count_case
    label: GATK ModelSegments Tumor
    out:
    - id: het_allelic_counts
    - id: normal_het_allelic_counts
    - id: copy_ratio_only_segments
    - id: copy_ratio_legacy_segments
    - id: allele_fraction_legacy_segments
    - id: modeled_segments_begin
    - id: copy_ratio_parameters_begin
    - id: allele_fraction_parameters_begin
    - id: modeled_segments
    - id: copy_ratio_parameters
    - id: allele_fraction_parameters
    run: steps/gatk_modelsegments_tumor.cwl
    sbg:x: 1283.28076171875
    sbg:y: -811.0526123046875
  gatk_plotdenoisedcopyratios_normal:
    in:
    - id: denoised_copy_ratios
      source: gatk_denoisereadcounts_normal/out_denoised_copy_ratios
    - default: 7000
      id: memory_per_job
    - id: minimum_contig_length
      source: minimum_contig_length
    - id: output_prefix
      source: gatk_collectreadcounts_normal/entity_id
    - id: sequence_dictionary
      source: sequence_dictionary
    - id: standardized_copy_ratios
      source: gatk_denoisereadcounts_normal/out_standardized_copy_ratios
    label: GATK PlotDenoisedCopyRatios Normal
    out:
    - id: denoised_plot
    - id: denoised_limit_plot
    - id: delta_mad
    - id: denoised_mad
    - id: scaled_delta_mad
    - id: standardized_mad
    run: steps/gatk_plotdenoisedcopyratios_tumor.cwl
    sbg:x: 951.8522338867188
    sbg:y: 328.0443420410156
  gatk_plotdenoisedcopyratios_tumor:
    in:
    - id: denoised_copy_ratios
      source: gatk_denoisereadcounts_tumor/out_denoised_copy_ratios
    - default: 7000
      id: memory_per_job
    - id: minimum_contig_length
      source: minimum_contig_length
    - id: output_prefix
      source: gatk_collectreadcounts_tumor/entity_id
    - id: sequence_dictionary
      source: sequence_dictionary
    - id: standardized_copy_ratios
      source: gatk_denoisereadcounts_tumor/out_standardized_copy_ratios
    label: GATK PlotDenoisedCopyRatios Tumor
    out:
    - id: denoised_plot
    - id: denoised_limit_plot
    - id: delta_mad
    - id: denoised_mad
    - id: scaled_delta_mad
    - id: standardized_mad
    run: steps/gatk_plotdenoisedcopyratios_tumor.cwl
    sbg:x: 949.60400390625
    sbg:y: 121.78529357910156
  gatk_plotmodeledsegments_normal:
    in:
    - id: allelic_counts
      source: gatk_modelsegments_normal/het_allelic_counts
    - id: denoised_copy_ratios
      source: gatk_denoisereadcounts_normal/out_denoised_copy_ratios
    - default: 7000
      id: memory_per_job
    - id: minimum_contig_length
      source: minimum_contig_length
    - id: output_prefix
      source: gatk_collectreadcounts_normal/entity_id
    - id: segments
      source: gatk_modelsegments_normal/modeled_segments
    - id: sequence_dictionary
      source: sequence_dictionary
    label: GATK PlotModeledSegments Normal
    out:
    - id: output_plot
    run: steps/gatk_plotmodeledsegments_tumor.cwl
    sbg:x: 2037.1270751953125
    sbg:y: -309
  gatk_plotmodeledsegments_tumor:
    in:
    - id: allelic_counts
      source: gatk_modelsegments_tumor/het_allelic_counts
    - id: denoised_copy_ratios
      source: gatk_denoisereadcounts_tumor/out_denoised_copy_ratios
    - default: 7000
      id: memory_per_job
    - id: minimum_contig_length
      source: minimum_contig_length
    - id: output_prefix
      source: gatk_collectreadcounts_tumor/entity_id
    - id: segments
      source: gatk_modelsegments_tumor/modeled_segments
    - id: sequence_dictionary
      source: sequence_dictionary
    label: GATK PlotModeledSegments Tumor
    out:
    - id: output_plot
    run: steps/gatk_plotmodeledsegments_tumor.cwl
    sbg:x: 2044.4910888671875
    sbg:y: -843.1929321289062
  gatk_preprocessintervals_4_1_0_0:
    in:
    - id: bin_length
      source: bin_length
    - id: exclude_intervals
      source:
      - exclude_intervals
    - default: OVERLAPPING_ONLY
      id: interval_merging_rule
    - id: intervals
      source:
      - intervals
      valueFrom: '$(self ? [self] : self)'
    - id: padding
      source: padding
    - id: in_reference
      source: in_reference
    - id: sequence_dictionary
      source: sequence_dictionary
    label: GATK PreprocessIntervals
    out:
    - id: out_intervals
    run: steps/gatk_preprocessintervals_4_1_0_0.cwl
    sbg:x: -313.4742736816406
    sbg:y: 11.08277416229248
  sbg_group_outputs_normal:
    in:
    - id: in_array
      source:
      - gatk_callcopyratiosegments_normal/called_segments
      - gatk_callcopyratiosegments_normal/called_legacy_segments
      - gatk_plotmodeledsegments_normal/output_plot
      - gatk_collectalleliccounts_normal/allelic_counts
      - gatk_collectreadcounts_normal/read_counts
      - gatk_denoisereadcounts_normal/out_denoised_copy_ratios
      - gatk_denoisereadcounts_normal/out_standardized_copy_ratios
      - gatk_plotdenoisedcopyratios_normal/delta_mad
      - gatk_plotdenoisedcopyratios_normal/denoised_limit_plot
      - gatk_plotdenoisedcopyratios_normal/denoised_mad
      - gatk_plotdenoisedcopyratios_normal/denoised_plot
      - gatk_plotdenoisedcopyratios_normal/scaled_delta_mad
      - gatk_plotdenoisedcopyratios_normal/standardized_mad
      - gatk_modelsegments_normal/normal_het_allelic_counts
      - gatk_modelsegments_normal/modeled_segments_begin
      - gatk_modelsegments_normal/modeled_segments
      - gatk_modelsegments_normal/het_allelic_counts
      - gatk_modelsegments_normal/copy_ratio_parameters_begin
      - gatk_modelsegments_normal/copy_ratio_parameters
      - gatk_modelsegments_normal/copy_ratio_only_segments
      - gatk_modelsegments_normal/copy_ratio_legacy_segments
      - gatk_modelsegments_normal/allele_fraction_parameters_begin
      - gatk_modelsegments_normal/allele_fraction_parameters
      - gatk_modelsegments_normal/allele_fraction_legacy_segments
    label: SBG Group Outputs Normal
    out:
    - id: out_array
    run: steps/sbg_group_outputs_tumor.cwl
    sbg:x: 2660.078125
    sbg:y: -393.1075744628906
  sbg_group_outputs_oncotator:
    in:
    - id: in_array
      source:
      - gatk_cnv_oncotatesegments/oncotated_gene_list
      - gatk_cnv_oncotatesegments/oncotated_called_file
    label: SBG Group Outputs Oncotator
    out:
    - id: out_array
    run: steps/sbg_group_outputs_tumor.cwl
    sbg:x: 2842.666748046875
    sbg:y: 54
  sbg_group_outputs_tumor:
    in:
    - id: in_array
      source:
      - gatk_plotmodeledsegments_tumor/output_plot
      - gatk_modelsegments_tumor/modeled_segments
      - gatk_callcopyratiosegments_tumor/called_segments
      - gatk_callcopyratiosegments_tumor/called_legacy_segments
      - gatk_modelsegments_tumor/allele_fraction_parameters_begin
      - gatk_modelsegments_tumor/allele_fraction_parameters
      - gatk_denoisereadcounts_tumor/out_standardized_copy_ratios
      - gatk_denoisereadcounts_tumor/out_denoised_copy_ratios
      - gatk_plotdenoisedcopyratios_tumor/delta_mad
      - gatk_plotdenoisedcopyratios_tumor/denoised_limit_plot
      - gatk_plotdenoisedcopyratios_tumor/denoised_mad
      - gatk_plotdenoisedcopyratios_tumor/denoised_plot
      - gatk_plotdenoisedcopyratios_tumor/scaled_delta_mad
      - gatk_plotdenoisedcopyratios_tumor/standardized_mad
      - gatk_modelsegments_tumor/normal_het_allelic_counts
      - gatk_modelsegments_tumor/modeled_segments_begin
      - gatk_modelsegments_tumor/het_allelic_counts
      - gatk_modelsegments_tumor/copy_ratio_parameters_begin
      - gatk_modelsegments_tumor/copy_ratio_parameters
      - gatk_modelsegments_tumor/copy_ratio_only_segments
      - gatk_modelsegments_tumor/copy_ratio_legacy_segments
      - gatk_modelsegments_tumor/allele_fraction_legacy_segments
      - gatk_collectalleliccounts_tumor/allelic_counts
    label: SBG Group Outputs Tumor
    out:
    - id: out_array
    run: steps/sbg_group_outputs_tumor.cwl
    sbg:x: 2659.38427734375
    sbg:y: -595.4244384765625
