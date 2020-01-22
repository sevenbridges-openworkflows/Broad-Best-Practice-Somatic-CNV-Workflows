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
doc: "BROAD Best Practices Somatic CNV Panel is used for creating a panel of normals\
  \ (PON) given a set of normal samples.\n\n### Common Use Cases\n\nFor CNV discovery,\
  \ the PON is created by running the initial coverage collection tools individually\
  \ on a set of normal samples and combining the resulting copy ratio data using a\
  \ dedicated PON creation tool [1]. This produces a binary file that can be used\
  \ as a PON. It is very important to use normal samples that are as technically similar\
  \ as possible to the tumor samples (same exome or genome preparation methods, sequencing\
  \ technology etc.) [2].\n \nThe basis of copy number variant detection is formed\
  \ by collecting coverage counts, while the resolution of the analysis is defined\
  \ by the genomic intervals list. In the case of whole genome data, the reference\
  \ genome is divided into equally sized intervals or bins, while for exome data,\
  \ the target regions of the capture kit should be padded. In either case, the **PreprocessIntervals**\
  \ tool is used for preparing the intervals list which is then used for collecting\
  \ raw integer counts. For this step **CollectReadCounts** is utilized, which counts\
  \ reads that overlap the interval. Finally a CNV panel of normals is generated using\
  \ the **CreateReadCountPanelOfNormals** tool. \n\nIn creating a PON, **CreateReadCountPanelOfNormals**\
  \ abstracts the counts data for the samples and the intervals using Singular Value\
  \ Decomposition (SVD), a type of Principal Component Analysis. The normal samples\
  \ in the PON should match the sequencing approach of the case sample under scrutiny.\
  \ This applies especially to targeted exome data because the capture step introduces\
  \ target-specific noise [3].\n\nSome of the common input parameters are listed below:\n\
  *  **Input reads** (`--input`) - BAM/SAM/CRAM file containing reads. In the case\
  \ of BAM and CRAM files, secondary BAI and CRAI index files are required.\n* **Intervals**\
  \ (`--intervals`) - required for both WGS and WES cases. Formats must be compatible\
  \ with the GATK `-L` argument. For WGS, the intervals should simply cover the autosomal\
  \ chromosomes (sex chromosomes may be included, but care should be taken to avoid\
  \ creating panels of mixed sex, and to denoise case samples only with panels containing\
  \ only individuals of the same sex as the case samples)[4].\n* **Bin length** (`--bin-length`).\
  \ This parameter is passed to the **PreprocessIntervals** tool. Read counts will\
  \ be collected per bin and final PON file will contain information on read counts\
  \ per bin. Thus, when calling CNVs in Tumor samples, **Bin length** parameter has\
  \ to be set to the same value used when creating the PON file.\n* **Padding** (`--padding`).\
  \ Also used in the **PreprocessIntervals** tool, defines number of base pairs to\
  \ pad each bin on each side.\n* **Reference** (`--reference`) - Reference sequence\
  \ file along with FAI and DICT files.\n* **Blacklisted Intervals** (`--exclude_intervals`)\
  \ will be excluded from coverage collection and all downstream steps.\n* **Do Explicit\
  \ GC Correction** - Annotate intervals with GC content using the **AnnotateIntervals**\
  \ tool.\n\n### Changes Introduced by Seven Bridges\n*The workflow in its entirety\
  \ is per [best practice](https://github.com/gatk-workflows/gatk4-somatic-cnvs/blob/master/cnv_somatic_panel_workflow.wdl)\
  \ specification.* \n\n### Performance Benchmarking\n\n| Input Size | Experimental\
  \ Strategy | Coverage | Duration | Cost (on demand) | AWS Instance Type |\n| ---\
  \ | --- | --- | --- | --- | --- | --- |\n| 2 x 45GB | WGS | 8x | 33min | $0.59 |\
  \ c4.4xlarge 2TB EBS |\n| 2 x 120GB | WGS | 25x | 1h 22min | $1.47 | c4.4xlarge\
  \ 2TB EBS |\n| 2 x 210GB | WGS | 40x | 2h 19min | $2.48 | c4.4xlarge 2TB EBS |\n\
  | 2 x 420GB | WGS | 80x | 4h 15min | $4.54 | c4.4xlarge 2TB EBS |\n\n### API Python\
  \ Implementation\nThe app's draft task can also be submitted via the **API**. In\
  \ order to learn how to get your **Authentication token** and **API endpoint** for\
  \ corresponding platform visit our [documentation](https://github.com/sbg/sevenbridges-python#authentication-and-configuration).\n\
  \n```python\n# Initialize the SBG Python API\nfrom sevenbridges import Api\napi\
  \ = Api(token=\"enter_your_token\", url=\"enter_api_endpoint\")\n# Get project_id/app_id\
  \ from your address bar. Example: https://igor.sbgenomics.com/u/your_username/project/app\n\
  project_id = \"your_username/project\"\napp_id = \"your_username/project/app\"\n\
  # Replace inputs with appropriate values\ninputs = {\n\t\"sequence_dictionary\"\
  : api.files.query(project=project_id, names=[\"enter_filename\"])[0], \n\t\"intervals\"\
  : api.files.query(project=project_id, names=[\"enter_filename\"])[0], \n\t\"in_alignments\"\
  : list(api.files.query(project=project_id, names=[\"enter_filename\", \"enter_filename\"\
  ])), \n\t\"in_reference\": api.files.query(project=project_id, names=[\"enter_filename\"\
  ])[0], \n\t\"output_prefix\": \"sevenbridges\"}\n# Creates draft task\ntask = api.tasks.create(name=\"\
  GATK CNV Somatic Panel Workflow - API Run\", project=project_id, app=app_id, inputs=inputs,\
  \ run=False)\n```\n\nInstructions for installing and configuring the API Python\
  \ client, are provided on [github](https://github.com/sbg/sevenbridges-python#installation).\
  \ For more information about using the API Python client, consult [the client documentation](http://sevenbridges-python.readthedocs.io/en/latest/).\
  \ **More examples** are available [here](https://github.com/sbg/okAPI).\n\nAdditionally,\
  \ [API R](https://github.com/sbg/sevenbridges-r) and [API Java](https://github.com/sbg/sevenbridges-java)\
  \ clients are available. To learn more about using these API clients please refer\
  \ to the [API R client documentation](https://sbg.github.io/sevenbridges-r/), and\
  \ [API Java client documentation](https://docs.sevenbridges.com/docs/java-library-quickstart).\n\
  \n### References\n* [1] [https://github.com/gatk-workflows/gatk4-somatic-cnvs](https://github.com/gatk-workflows/gatk4-somatic-cnvs)\n\
  * [2] [https://gatkforums.broadinstitute.org/gatk/discussion/11053/panel-of-normals-pon](https://gatkforums.broadinstitute.org/gatk/discussion/11053/panel-of-normals-pon)\n\
  * [3] [https://gatkforums.broadinstitute.org/dsde/discussion/11682](https://gatkforums.broadinstitute.org/dsde/discussion/11682)\n\
  * [4] [https://gatkforums.broadinstitute.org/gatk/discussion/11009/intervals-and-interval-lists](https://gatkforums.broadinstitute.org/gatk/discussion/11009/intervals-and-interval-lists)"
hints:
- class: sbg:AWSInstanceType
  value: c4.4xlarge;ebs-gp2;2000
- class: sbg:GoogleInstanceType
  value: n1-standard-16;pd-ssd;2000
id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-somatic-panel-workflow/89
inputs:
- id: bin_length
  sbg:exposed: true
  type: int?
- id: padding
  sbg:exposed: true
  type: int?
- doc: Use the given sequence dictionary as the master/canonical sequence dictionary.
    Must be a .dict file.
  id: sequence_dictionary
  label: Sequence dictionary
  sbg:fileTypes: DICT
  sbg:x: -407.64971923828125
  sbg:y: -190
  type: File
- doc: Genomic intervals over which to operate.
  id: intervals
  label: Intervals
  sbg:fileTypes: INTERVALS, INTERVAL_LIST, BED, VCF, LIST
  sbg:x: -410.2372741699219
  sbg:y: -56.824859619140625
  type: File
- doc: Reference sequence file.
  id: in_reference
  label: Reference
  sbg:fileTypes: FASTA, FA
  sbg:x: -410.7547607421875
  sbg:y: 77.04084777832031
  secondaryFiles:
  - .fai
  - ^.dict
  type: File
- doc: Genomic intervals to exclude from processing.
  id: exclude_intervals
  label: Blacklisted intervals
  sbg:fileTypes: INTERVALS, INTERVAL_LIST, BED, VCF, LIST
  sbg:x: -411.5247497558594
  sbg:y: 216.38613891601562
  type: File?
- id: feature_query_lookahead
  sbg:exposed: true
  type: int?
- doc: Umap single-read mappability track in .bed or .bed.gz format (see https://bismap.hoffmanlab.org/).
  id: mappability_track
  label: Mappability track
  sbg:fileTypes: BED, BED.GZ
  sbg:x: -116.23728942871094
  sbg:y: -284.6949157714844
  secondaryFiles:
  - .idx
  type: File?
- doc: Segmental-duplication track in .bed or .bed.gz format
  id: segmental_duplication_track
  label: Segmental duplication track
  sbg:fileTypes: BED, BED.GZ
  sbg:x: -116.97435760498047
  sbg:y: -412.5128173828125
  secondaryFiles:
  - .idx
  type: File?
- doc: BAM/SAM/CRAM file containing reads This argument must be specified at least
    once.
  id: in_alignments
  label: Input reads
  sbg:fileTypes: BAM, SAM, CRAM
  sbg:x: -118.76271057128906
  sbg:y: 218.88136291503906
  secondaryFiles:
  - .bai
  type: File[]
- id: output_format
  sbg:exposed: true
  type:
  - 'null'
  - name: output_format
    symbols:
    - TSV
    - HDF5
    type: enum
- id: do_impute_zeros
  sbg:exposed: true
  type:
  - 'null'
  - name: do_impute_zeros
    symbols:
    - 'true'
    - 'false'
    type: enum
- id: extreme_outlier_truncation_percentile
  sbg:exposed: true
  type: float?
- id: extreme_sample_median_percentile
  sbg:exposed: true
  type: float?
- id: maximum_chunk_size
  sbg:exposed: true
  type: int?
- id: maximum_zeros_in_interval_percentage
  sbg:exposed: true
  type: float?
- id: maximum_zeros_in_sample_percentage
  sbg:exposed: true
  type: float?
- id: minimum_interval_median_percentile
  sbg:exposed: true
  type: float?
- id: number_of_eigensamples
  sbg:exposed: true
  type: int?
- doc: PON entity id (output prefix) for the panel of normals.
  id: pon_entity_id
  label: PON entity id
  sbg:x: 219
  sbg:y: 349.2994384765625
  type: string
- doc: Choose whether to annotate intervals with GC content.
  id: do_explicit_gc_correction
  label: Do explicit GC correction
  sbg:x: -114
  sbg:y: -146.5162353515625
  type: boolean?
label: BROAD Best Practices Somatic CNV Panel Workflow 4.1.0.0
outputs:
- id: preprocessed_intervals
  label: Preprocessed Intervals
  outputSource:
  - gatk_preprocessintervals_4_1_0_0/out_intervals
  sbg:fileTypes: INTERVALS
  sbg:x: 221.82485961914062
  sbg:y: 197.4124298095703
  type: File?
- id: read_counts
  label: Read counts
  outputSource:
  - gatk_collectreadcounts_4_1_0_0/read_counts
  sbg:fileTypes: HDF5, TSV
  sbg:x: 549.286376953125
  sbg:y: -272.713623046875
  type: File[]?
- id: entity_id
  label: Entity ID
  outputSource:
  - gatk_collectreadcounts_4_1_0_0/entity_id
  sbg:x: 550.9491577148438
  sbg:y: -129.86441040039062
  type:
  - 'null'
  - string
  - items: string
    type: array
- id: panel_of_normals
  label: Panel of normals
  outputSource:
  - gatk_createreadcountpanelofnormals_4_1_0_0/panel_of_normals
  sbg:fileTypes: HDF5
  sbg:x: 822.5875854492188
  sbg:y: 35.76271057128906
  type: File?
requirements:
- class: StepInputExpressionRequirement
- class: InlineJavascriptRequirement
- class: ScatterFeatureRequirement
sbg:appVersion:
- v1.0
sbg:categories:
- Genomics
- Copy Number Variant Calling
- CWL1.0
sbg:content_hash: a1108909a9132edcacc628ae10cb26f6beaed371bf2bf1bafb92b1cccb7f8bd0d
sbg:contributors:
- milena_stanojevic
- stefan_stojanovic
sbg:createdBy: stefan_stojanovic
sbg:createdOn: 1551193788
sbg:id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-somatic-panel-workflow/89
sbg:image_url: https://igor.sbgenomics.com/ns/brood/images/veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-somatic-panel-workflow/89.png
sbg:latestRevision: 89
sbg:modifiedBy: milena_stanojevic
sbg:modifiedOn: 1576083884
sbg:project: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev
sbg:projectName: GATK 4.1.0.0 Toolkit DEV
sbg:publisher: sbg
sbg:revision: 89
sbg:revisionNotes: InlineJavascript requirement add
sbg:revisionsInfo:
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551193788
  sbg:revision: 0
  sbg:revisionNotes: null
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551193810
  sbg:revision: 1
  sbg:revisionNotes: init
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551194117
  sbg:revision: 2
  sbg:revisionNotes: replace apps with apps from current project
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551194192
  sbg:revision: 3
  sbg:revisionNotes: change toolkit version for preprocess intervals
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551194495
  sbg:revision: 4
  sbg:revisionNotes: replace preprocessIntevals app from current project
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551194544
  sbg:revision: 5
  sbg:revisionNotes: update preprocessIntervals, no real change, testing
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551194695
  sbg:revision: 6
  sbg:revisionNotes: replace collectReadCounts from current project; rename input
    ports
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551194758
  sbg:revision: 7
  sbg:revisionNotes: set input_alignments to array of files, scatter collectReadCounts
    in --input
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551194836
  sbg:revision: 8
  sbg:revisionNotes: replace AnnotateIntervals from current project, expose inputs
    and parameters
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551194997
  sbg:revision: 9
  sbg:revisionNotes: replace createReadCountPanelOfNormals from current project, expose
    input parameters
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551195042
  sbg:revision: 10
  sbg:revisionNotes: 'AnnotateIntervals: set int_merging_rule to overlapping_only'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551195110
  sbg:revision: 11
  sbg:revisionNotes: 'CollectReadCounts: expose format'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551195408
  sbg:revision: 12
  sbg:revisionNotes: set pon_entity_id port to required
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551195996
  sbg:revision: 13
  sbg:revisionNotes: expose counts and intervals output ports
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551198490
  sbg:revision: 14
  sbg:revisionNotes: add description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551200618
  sbg:revision: 15
  sbg:revisionNotes: add common use case description from gatk tutorial, add reference
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551200817
  sbg:revision: 16
  sbg:revisionNotes: changes by seven bridges tbd, so far none;
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551201020
  sbg:revision: 17
  sbg:revisionNotes: 'CollectReadCounts: set default memory to 7000 mb, per best practice
    wdl'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551201123
  sbg:revision: 18
  sbg:revisionNotes: 'CreateReadCountPON: set default memory to 7000 mb, per best
    practice wdl; remove default memory overhead;'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551202521
  sbg:revision: 19
  sbg:revisionNotes: 'PreprocessIntervals: set --intervals to single file instead
    of array of files, per best practice wdl; add argument for default --output naming'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551202975
  sbg:revision: 20
  sbg:revisionNotes: 'PreprocessIntervals: fix glob expression'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551203345
  sbg:revision: 21
  sbg:revisionNotes: 'PreprocessIntervals: remove cwl default value for output argument'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551203913
  sbg:revision: 22
  sbg:revisionNotes: set required inputs to required
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551204015
  sbg:revision: 23
  sbg:revisionNotes: set intervals to single file instead of array of files
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551204097
  sbg:revision: 24
  sbg:revisionNotes: change labels for inputs and outputs
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551268343
  sbg:revision: 25
  sbg:revisionNotes: 'set instance hints: c4.4xlarge and max num parallel instances
    to 5'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551268987
  sbg:revision: 26
  sbg:revisionNotes: add 2tb elastic storage hint
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551275619
  sbg:revision: 27
  sbg:revisionNotes: 'CollectReadCounts: default memory set to 2048m'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551275721
  sbg:revision: 28
  sbg:revisionNotes: set memory_per_job to 7000 for CollectReadCounts and CreateReadCountPON
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551284995
  sbg:revision: 29
  sbg:revisionNotes: 'edit description: add benchmarking info'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552494884
  sbg:revision: 30
  sbg:revisionNotes: add python api snippet
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552495576
  sbg:revision: 31
  sbg:revisionNotes: edit description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552496993
  sbg:revision: 32
  sbg:revisionNotes: fix output labels; add descriptions for input files
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552652781
  sbg:revision: 33
  sbg:revisionNotes: 'PreprocessIntervals: --intervals argument accepts array of files
    instead of single file'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552654636
  sbg:revision: 34
  sbg:revisionNotes: re-expose intervals port, set to single file
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552655284
  sbg:revision: 35
  sbg:revisionNotes: set Intervals input port to array of files
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552656157
  sbg:revision: 36
  sbg:revisionNotes: update PreprocessIntervals app (now with full descriptio); add
    note to "changes introduced by sbg" regarding array of interval files
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552658936
  sbg:revision: 37
  sbg:revisionNotes: 'PreprocessIntervals: for --intervals input files, cast self
    to array before iterating; set Intervals port to accept single file, per wdl spec'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552659916
  sbg:revision: 38
  sbg:revisionNotes: preprocessIntervals accepts single file once again; description
    edited accordingly
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552660130
  sbg:revision: 39
  sbg:revisionNotes: 'AnnotateIntervals: --intervals argument accepts array of files;
    expression set to cast to array before iterating over interval files'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552662804
  sbg:revision: 40
  sbg:revisionNotes: 'AnnotateIntervals: set --intervals to array of files'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552663458
  sbg:revision: 41
  sbg:revisionNotes: 'CollectReadCounts: allow multiple intervals files'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552664828
  sbg:revision: 42
  sbg:revisionNotes: edit output labels and ids
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552665677
  sbg:revision: 43
  sbg:revisionNotes: 'CreateReadCountPON: set default memory on tool level to 2048;
    On wf level memory is 7000'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552666822
  sbg:revision: 44
  sbg:revisionNotes: 'CreateReadCountPanelOfNormals: add description'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552666838
  sbg:revision: 45
  sbg:revisionNotes: update label for PON
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553121401
  sbg:revision: 46
  sbg:revisionNotes: fix description, fix references and reference links
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553121964
  sbg:revision: 47
  sbg:revisionNotes: edit input labels in description, fix formatting, add more info
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553122620
  sbg:revision: 48
  sbg:revisionNotes: update apps, reconnect ports
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553125374
  sbg:revision: 49
  sbg:revisionNotes: edit input and output labels and descriptions
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553125623
  sbg:revision: 50
  sbg:revisionNotes: expose pon entity id input parameter as port, set as required;
    set other input parameters to required according to best practice wdl
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553126310
  sbg:revision: 51
  sbg:revisionNotes: 'update PreprocessIntervals: fix output prefix expression to
    allow for single file interval input'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553127178
  sbg:revision: 52
  sbg:revisionNotes: update annotateIntervals and createPON, fixed output prefix expression
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553165919
  sbg:revision: 53
  sbg:revisionNotes: 'update AnnotateIntervals and CreatePON: change output format
    for annotated intervals to TSV'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553166457
  sbg:revision: 54
  sbg:revisionNotes: edit labels and descriptions for output pon and preprocessed
    intervals
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553166808
  sbg:revision: 55
  sbg:revisionNotes: edit api python implementation example to reflect changes in
    input ids
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553781665
  sbg:revision: 56
  sbg:revisionNotes: update apps
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553790351
  sbg:revision: 57
  sbg:revisionNotes: add coverage column to benchmarking table; add categories
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553790822
  sbg:revision: 58
  sbg:revisionNotes: edit common use cases, per review notes
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553791023
  sbg:revision: 59
  sbg:revisionNotes: edit references section per review notes
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553791548
  sbg:revision: 60
  sbg:revisionNotes: remove parallel instances hint
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553812408
  sbg:revision: 61
  sbg:revisionNotes: 'CollectReadCounts: set in_alignments (--input) parameter to
    required'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553812700
  sbg:revision: 62
  sbg:revisionNotes: update benchmarking info
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553812749
  sbg:revision: 63
  sbg:revisionNotes: fix typo in benchmarking table
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553860615
  sbg:revision: 64
  sbg:revisionNotes: update CollectReadCounts, fix secondary file requirements; expose
    disable_default_read_filtering
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553863266
  sbg:revision: 65
  sbg:revisionNotes: add secondary file requirement for reference on wf level
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553863952
  sbg:revision: 66
  sbg:revisionNotes: 'Revert to revision 63; Update CollectReadCounts: add secondary
    file requirements for in_alignments'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553871765
  sbg:revision: 67
  sbg:revisionNotes: add secondary files for reference input
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553945719
  sbg:revision: 68
  sbg:revisionNotes: 'CollectReadCounts: expose format and disable_tool_default_read_filters'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553948178
  sbg:revision: 69
  sbg:revisionNotes: 'CollectReadCounts: change back choices for output_format to
    uppercase; fix glob expressions to catch uppercase extensions'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553948239
  sbg:revision: 70
  sbg:revisionNotes: 'CollectReadCounts: scatter dot product'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553949809
  sbg:revision: 71
  sbg:revisionNotes: minor fixes in description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1554027257
  sbg:revision: 72
  sbg:revisionNotes: add coverage info to benchmarking table
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559646754
  sbg:revision: 73
  sbg:revisionNotes: update apps
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559731160
  sbg:revision: 74
  sbg:revisionNotes: 'update CollectReadCounts: fix entity_id output eval expression,
    allow for zero length in_alignments case, in case of conditional execution'
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575040932
  sbg:revision: 75
  sbg:revisionNotes: Validation CWL
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575043647
  sbg:revision: 76
  sbg:revisionNotes: Validation Update 1
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575043689
  sbg:revision: 77
  sbg:revisionNotes: Read_counts output changed from file to array
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575044096
  sbg:revision: 78
  sbg:revisionNotes: Entry_ID port -> allow array as well as single file
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575306370
  sbg:revision: 79
  sbg:revisionNotes: Secondary files requirement add/ InlineJavascriptRequirement
    add
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575306889
  sbg:revision: 80
  sbg:revisionNotes: Secondary files argument fixed
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575478051
  sbg:revision: 81
  sbg:revisionNotes: ''
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575479175
  sbg:revision: 82
  sbg:revisionNotes: updated CollectReadCounts (secondaryFiles)
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575542787
  sbg:revision: 83
  sbg:revisionNotes: Secondary files for input reads set to ^.bai
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575549453
  sbg:revision: 84
  sbg:revisionNotes: Updated secondary files for input read as .bai
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575557665
  sbg:revision: 85
  sbg:revisionNotes: CollectReadCounts tool update(secondary files for in_alignment
    input fix) + InlineJavascriptRequirement fix
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575558003
  sbg:revision: 86
  sbg:revisionNotes: CollectReadCounts tool update again + InlineJavascriptReq. fix
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575907854
  sbg:revision: 87
  sbg:revisionNotes: CollectReadCounts tool update to *hdf5
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1576083799
  sbg:revision: 88
  sbg:revisionNotes: Memory per job - 4000 CreateReadCountsPanelOfNormal
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1576083884
  sbg:revision: 89
  sbg:revisionNotes: InlineJavascript requirement add
sbg:sbgMaintained: false
sbg:validationErrors: []
steps:
  gatk_annotateintervals_4_1_0_0:
    in:
    - default: OVERLAPPING_ONLY
      id: interval_merging_rule
    - id: intervals
      source:
      - gatk_preprocessintervals_4_1_0_0/out_intervals
      valueFrom: '$(self ? [self] : self)'
    - default: 2000
      id: memory_per_job
    - id: in_reference
      source: in_reference
    - id: segmental_duplication_track
      source: segmental_duplication_track
    - id: do_explicit_gc_correction
      source: do_explicit_gc_correction
    - id: mappability_track
      source: mappability_track
    - id: feature_query_lookahead
      source: feature_query_lookahead
    label: GATK AnnotateIntervals
    out:
    - id: annotated_intervals
    run: steps/gatk_annotateintervals_4_1_0_0.cwl
    sbg:x: 224.23728942871094
    sbg:y: -172
  gatk_collectreadcounts_4_1_0_0:
    in:
    - id: output_format
      source: output_format
    - id: in_alignments
      source:
      - in_alignments
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
    label: GATK CollectReadCounts
    out:
    - id: read_counts
    - id: entity_id
    run: steps/gatk_collectreadcounts_4_1_0_0.cwl
    sbg:x: 225
    sbg:y: 37.0621452331543
    scatter:
    - in_alignments
  gatk_createreadcountpanelofnormals_4_1_0_0:
    in:
    - id: annotated_intervals
      source: gatk_annotateintervals_4_1_0_0/annotated_intervals
    - id: do_impute_zeros
      source: do_impute_zeros
    - id: extreme_outlier_truncation_percentile
      source: extreme_outlier_truncation_percentile
    - id: extreme_sample_median_percentile
      source: extreme_sample_median_percentile
    - id: read_counts
      source:
      - gatk_collectreadcounts_4_1_0_0/read_counts
    - id: maximum_chunk_size
      source: maximum_chunk_size
    - id: maximum_zeros_in_interval_percentage
      source: maximum_zeros_in_interval_percentage
    - id: maximum_zeros_in_sample_percentage
      source: maximum_zeros_in_sample_percentage
    - default: 4000
      id: memory_per_job
    - id: minimum_interval_median_percentile
      source: minimum_interval_median_percentile
    - id: number_of_eigensamples
      source: number_of_eigensamples
    - id: output_prefix
      source: pon_entity_id
    label: GATK CreateReadCountPanelOfNormals
    out:
    - id: panel_of_normals
    run: steps/gatk_createreadcountpanelofnormals_4_1_0_0.cwl
    sbg:x: 549
    sbg:y: 34.35028076171875
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
    - default: 2000
      id: memory_per_job
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
    sbg:x: -118.88700866699219
    sbg:y: 44.949153900146484
