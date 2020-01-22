{
    "class": "Workflow",
    "cwlVersion": "v1.0",
    "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-somatic-panel-workflow/89",
    "doc": "BROAD Best Practices Somatic CNV Panel is used for creating a panel of normals (PON) given a set of normal samples.\n\n### Common Use Cases\n\nFor CNV discovery, the PON is created by running the initial coverage collection tools individually on a set of normal samples and combining the resulting copy ratio data using a dedicated PON creation tool [1]. This produces a binary file that can be used as a PON. It is very important to use normal samples that are as technically similar as possible to the tumor samples (same exome or genome preparation methods, sequencing technology etc.) [2].\n \nThe basis of copy number variant detection is formed by collecting coverage counts, while the resolution of the analysis is defined by the genomic intervals list. In the case of whole genome data, the reference genome is divided into equally sized intervals or bins, while for exome data, the target regions of the capture kit should be padded. In either case, the **PreprocessIntervals** tool is used for preparing the intervals list which is then used for collecting raw integer counts. For this step **CollectReadCounts** is utilized, which counts reads that overlap the interval. Finally a CNV panel of normals is generated using the **CreateReadCountPanelOfNormals** tool. \n\nIn creating a PON, **CreateReadCountPanelOfNormals** abstracts the counts data for the samples and the intervals using Singular Value Decomposition (SVD), a type of Principal Component Analysis. The normal samples in the PON should match the sequencing approach of the case sample under scrutiny. This applies especially to targeted exome data because the capture step introduces target-specific noise [3].\n\nSome of the common input parameters are listed below:\n*  **Input reads** (`--input`) - BAM/SAM/CRAM file containing reads. In the case of BAM and CRAM files, secondary BAI and CRAI index files are required.\n* **Intervals** (`--intervals`) - required for both WGS and WES cases. Formats must be compatible with the GATK `-L` argument. For WGS, the intervals should simply cover the autosomal chromosomes (sex chromosomes may be included, but care should be taken to avoid creating panels of mixed sex, and to denoise case samples only with panels containing only individuals of the same sex as the case samples)[4].\n* **Bin length** (`--bin-length`). This parameter is passed to the **PreprocessIntervals** tool. Read counts will be collected per bin and final PON file will contain information on read counts per bin. Thus, when calling CNVs in Tumor samples, **Bin length** parameter has to be set to the same value used when creating the PON file.\n* **Padding** (`--padding`). Also used in the **PreprocessIntervals** tool, defines number of base pairs to pad each bin on each side.\n* **Reference** (`--reference`) - Reference sequence file along with FAI and DICT files.\n* **Blacklisted Intervals** (`--exclude_intervals`) will be excluded from coverage collection and all downstream steps.\n* **Do Explicit GC Correction** - Annotate intervals with GC content using the **AnnotateIntervals** tool.\n\n### Changes Introduced by Seven Bridges\n*The workflow in its entirety is per [best practice](https://github.com/gatk-workflows/gatk4-somatic-cnvs/blob/master/cnv_somatic_panel_workflow.wdl) specification.* \n\n### Performance Benchmarking\n\n| Input Size | Experimental Strategy | Coverage | Duration | Cost (on demand) | AWS Instance Type |\n| --- | --- | --- | --- | --- | --- | --- |\n| 2 x 45GB | WGS | 8x | 33min | $0.59 | c4.4xlarge 2TB EBS |\n| 2 x 120GB | WGS | 25x | 1h 22min | $1.47 | c4.4xlarge 2TB EBS |\n| 2 x 210GB | WGS | 40x | 2h 19min | $2.48 | c4.4xlarge 2TB EBS |\n| 2 x 420GB | WGS | 80x | 4h 15min | $4.54 | c4.4xlarge 2TB EBS |\n\n### API Python Implementation\nThe app's draft task can also be submitted via the **API**. In order to learn how to get your **Authentication token** and **API endpoint** for corresponding platform visit our [documentation](https://github.com/sbg/sevenbridges-python#authentication-and-configuration).\n\n```python\n# Initialize the SBG Python API\nfrom sevenbridges import Api\napi = Api(token=\"enter_your_token\", url=\"enter_api_endpoint\")\n# Get project_id/app_id from your address bar. Example: https://igor.sbgenomics.com/u/your_username/project/app\nproject_id = \"your_username/project\"\napp_id = \"your_username/project/app\"\n# Replace inputs with appropriate values\ninputs = {\n\t\"sequence_dictionary\": api.files.query(project=project_id, names=[\"enter_filename\"])[0], \n\t\"intervals\": api.files.query(project=project_id, names=[\"enter_filename\"])[0], \n\t\"in_alignments\": list(api.files.query(project=project_id, names=[\"enter_filename\", \"enter_filename\"])), \n\t\"in_reference\": api.files.query(project=project_id, names=[\"enter_filename\"])[0], \n\t\"output_prefix\": \"sevenbridges\"}\n# Creates draft task\ntask = api.tasks.create(name=\"GATK CNV Somatic Panel Workflow - API Run\", project=project_id, app=app_id, inputs=inputs, run=False)\n```\n\nInstructions for installing and configuring the API Python client, are provided on [github](https://github.com/sbg/sevenbridges-python#installation). For more information about using the API Python client, consult [the client documentation](http://sevenbridges-python.readthedocs.io/en/latest/). **More examples** are available [here](https://github.com/sbg/okAPI).\n\nAdditionally, [API R](https://github.com/sbg/sevenbridges-r) and [API Java](https://github.com/sbg/sevenbridges-java) clients are available. To learn more about using these API clients please refer to the [API R client documentation](https://sbg.github.io/sevenbridges-r/), and [API Java client documentation](https://docs.sevenbridges.com/docs/java-library-quickstart).\n\n### References\n* [1] [https://github.com/gatk-workflows/gatk4-somatic-cnvs](https://github.com/gatk-workflows/gatk4-somatic-cnvs)\n* [2] [https://gatkforums.broadinstitute.org/gatk/discussion/11053/panel-of-normals-pon](https://gatkforums.broadinstitute.org/gatk/discussion/11053/panel-of-normals-pon)\n* [3] [https://gatkforums.broadinstitute.org/dsde/discussion/11682](https://gatkforums.broadinstitute.org/dsde/discussion/11682)\n* [4] [https://gatkforums.broadinstitute.org/gatk/discussion/11009/intervals-and-interval-lists](https://gatkforums.broadinstitute.org/gatk/discussion/11009/intervals-and-interval-lists)",
    "label": "BROAD Best Practices Somatic CNV Panel Workflow 4.1.0.0",
    "$namespaces": {
        "sbg": "https://sevenbridges.com"
    },
    "inputs": [
        {
            "id": "bin_length",
            "type": "int?",
            "sbg:exposed": true
        },
        {
            "id": "padding",
            "type": "int?",
            "sbg:exposed": true
        },
        {
            "id": "sequence_dictionary",
            "sbg:fileTypes": "DICT",
            "type": "File",
            "label": "Sequence dictionary",
            "doc": "Use the given sequence dictionary as the master/canonical sequence dictionary. Must be a .dict file.",
            "sbg:x": -407.64971923828125,
            "sbg:y": -190
        },
        {
            "id": "intervals",
            "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, BED, VCF, LIST",
            "type": "File",
            "label": "Intervals",
            "doc": "Genomic intervals over which to operate.",
            "sbg:x": -410.2372741699219,
            "sbg:y": -56.824859619140625
        },
        {
            "id": "in_reference",
            "sbg:fileTypes": "FASTA, FA",
            "type": "File",
            "label": "Reference",
            "doc": "Reference sequence file.",
            "secondaryFiles": [
                ".fai",
                "^.dict"
            ],
            "sbg:x": -410.7547607421875,
            "sbg:y": 77.04084777832031
        },
        {
            "id": "exclude_intervals",
            "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, BED, VCF, LIST",
            "type": "File?",
            "label": "Blacklisted intervals",
            "doc": "Genomic intervals to exclude from processing.",
            "sbg:x": -411.5247497558594,
            "sbg:y": 216.38613891601562
        },
        {
            "id": "feature_query_lookahead",
            "type": "int?",
            "sbg:exposed": true
        },
        {
            "id": "mappability_track",
            "sbg:fileTypes": "BED, BED.GZ",
            "type": "File?",
            "label": "Mappability track",
            "doc": "Umap single-read mappability track in .bed or .bed.gz format (see https://bismap.hoffmanlab.org/).",
            "secondaryFiles": [
                ".idx"
            ],
            "sbg:x": -116.23728942871094,
            "sbg:y": -284.6949157714844
        },
        {
            "id": "segmental_duplication_track",
            "sbg:fileTypes": "BED, BED.GZ",
            "type": "File?",
            "label": "Segmental duplication track",
            "doc": "Segmental-duplication track in .bed or .bed.gz format",
            "secondaryFiles": [
                ".idx"
            ],
            "sbg:x": -116.97435760498047,
            "sbg:y": -412.5128173828125
        },
        {
            "id": "in_alignments",
            "sbg:fileTypes": "BAM, SAM, CRAM",
            "type": "File[]",
            "label": "Input reads",
            "doc": "BAM/SAM/CRAM file containing reads This argument must be specified at least once.",
            "secondaryFiles": [
                ".bai"
            ],
            "sbg:x": -118.76271057128906,
            "sbg:y": 218.88136291503906
        },
        {
            "id": "output_format",
            "type": [
                "null",
                {
                    "type": "enum",
                    "symbols": [
                        "TSV",
                        "HDF5"
                    ],
                    "name": "output_format"
                }
            ],
            "sbg:exposed": true
        },
        {
            "id": "do_impute_zeros",
            "type": [
                "null",
                {
                    "type": "enum",
                    "symbols": [
                        "true",
                        "false"
                    ],
                    "name": "do_impute_zeros"
                }
            ],
            "sbg:exposed": true
        },
        {
            "id": "extreme_outlier_truncation_percentile",
            "type": "float?",
            "sbg:exposed": true
        },
        {
            "id": "extreme_sample_median_percentile",
            "type": "float?",
            "sbg:exposed": true
        },
        {
            "id": "maximum_chunk_size",
            "type": "int?",
            "sbg:exposed": true
        },
        {
            "id": "maximum_zeros_in_interval_percentage",
            "type": "float?",
            "sbg:exposed": true
        },
        {
            "id": "maximum_zeros_in_sample_percentage",
            "type": "float?",
            "sbg:exposed": true
        },
        {
            "id": "minimum_interval_median_percentile",
            "type": "float?",
            "sbg:exposed": true
        },
        {
            "id": "number_of_eigensamples",
            "type": "int?",
            "sbg:exposed": true
        },
        {
            "id": "pon_entity_id",
            "type": "string",
            "label": "PON entity id",
            "doc": "PON entity id (output prefix) for the panel of normals.",
            "sbg:x": 219,
            "sbg:y": 349.2994384765625
        },
        {
            "id": "do_explicit_gc_correction",
            "type": "boolean?",
            "label": "Do explicit GC correction",
            "doc": "Choose whether to annotate intervals with GC content.",
            "sbg:x": -114,
            "sbg:y": -146.5162353515625
        }
    ],
    "outputs": [
        {
            "id": "preprocessed_intervals",
            "outputSource": [
                "gatk_preprocessintervals_4_1_0_0/out_intervals"
            ],
            "sbg:fileTypes": "INTERVALS",
            "type": "File?",
            "label": "Preprocessed Intervals",
            "sbg:x": 221.82485961914062,
            "sbg:y": 197.4124298095703
        },
        {
            "id": "read_counts",
            "outputSource": [
                "gatk_collectreadcounts_4_1_0_0/read_counts"
            ],
            "sbg:fileTypes": "HDF5, TSV",
            "type": "File[]?",
            "label": "Read counts",
            "sbg:x": 549.286376953125,
            "sbg:y": -272.713623046875
        },
        {
            "id": "entity_id",
            "outputSource": [
                "gatk_collectreadcounts_4_1_0_0/entity_id"
            ],
            "type": [
                "null",
                "string",
                {
                    "type": "array",
                    "items": "string"
                }
            ],
            "label": "Entity ID",
            "sbg:x": 550.9491577148438,
            "sbg:y": -129.86441040039062
        },
        {
            "id": "panel_of_normals",
            "outputSource": [
                "gatk_createreadcountpanelofnormals_4_1_0_0/panel_of_normals"
            ],
            "sbg:fileTypes": "HDF5",
            "type": "File?",
            "label": "Panel of normals",
            "sbg:x": 822.5875854492188,
            "sbg:y": 35.76271057128906
        }
    ],
    "steps": [
        {
            "id": "gatk_preprocessintervals_4_1_0_0",
            "in": [
                {
                    "id": "bin_length",
                    "source": "bin_length"
                },
                {
                    "id": "exclude_intervals",
                    "source": [
                        "exclude_intervals"
                    ]
                },
                {
                    "id": "interval_merging_rule",
                    "default": "OVERLAPPING_ONLY"
                },
                {
                    "id": "intervals",
                    "source": [
                        "intervals"
                    ],
                    "valueFrom": "$(self ? [self] : self)"
                },
                {
                    "id": "memory_per_job",
                    "default": 2000
                },
                {
                    "id": "padding",
                    "source": "padding"
                },
                {
                    "id": "in_reference",
                    "source": "in_reference"
                },
                {
                    "id": "sequence_dictionary",
                    "source": "sequence_dictionary"
                }
            ],
            "out": [
                {
                    "id": "out_intervals"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "uros_sipetic/gatk-4-1-0-0-demo/gatk-preprocessintervals-4-1-0-0/4",
                "baseCommand": [],
                "inputs": [
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "1000",
                        "id": "bin_length",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--bin-length",
                            "shellQuote": false
                        },
                        "label": "Bin length",
                        "doc": "Length (in bp) of the bins. If zero, no binning will be performed."
                    },
                    {
                        "sbg:altPrefix": "-disable-sequence-dictionary-validation",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "false",
                        "id": "disable_sequence_dictionary_validation",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "true",
                                    "false"
                                ],
                                "name": "disable_sequence_dictionary_validation"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--disable-sequence-dictionary-validation",
                            "shellQuote": false
                        },
                        "label": "Disable sequence dictionary validation",
                        "doc": "If specified, do not check the sequence dictionaries from our inputs for compatibility. Use at your own risk!"
                    },
                    {
                        "sbg:altPrefix": "-XL",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "exclude_intervals",
                        "type": "File[]?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--exclude-intervals",
                            "shellQuote": false,
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self);\n        var paths = [];\n        for (var i=0; i<self.length; i++) {\n            paths.push(self[i].path);\n        }\n        return paths.join(' --exclude-intervals ');\n    }\n    return '';\n}"
                        },
                        "label": "Exclude intervals",
                        "doc": "One or more genomic intervals to exclude from processing.",
                        "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, BED, VCF, LIST"
                    },
                    {
                        "sbg:altPrefix": "-ixp",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "interval_exclusion_padding",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--interval-exclusion-padding",
                            "shellQuote": false
                        },
                        "label": "Interval exclusion padding",
                        "doc": "Amount of padding (in bp) to add to each interval you are excluding."
                    },
                    {
                        "sbg:altPrefix": "-imr",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "ALL",
                        "id": "interval_merging_rule",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "ALL",
                                    "OVERLAPPING_ONLY"
                                ],
                                "name": "interval_merging_rule"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--interval-merging-rule",
                            "shellQuote": false
                        },
                        "label": "Interval merging rule",
                        "doc": "Interval merging rule for abutting intervals."
                    },
                    {
                        "sbg:altPrefix": "-ip",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "interval_padding",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--interval-padding",
                            "shellQuote": false
                        },
                        "label": "Interval padding",
                        "doc": "Ammount of padding (in bp) to add to each interval you are including."
                    },
                    {
                        "sbg:altPrefix": "-isr",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "UNION",
                        "id": "interval_set_rule",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "UNION",
                                    "INTERSECTION"
                                ],
                                "name": "interval_set_rule"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--interval-set-rule",
                            "shellQuote": false
                        },
                        "label": "Interval set rule",
                        "doc": "Set merging approach to use for combining interval inputs."
                    },
                    {
                        "sbg:altPrefix": "-L",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "intervals",
                        "type": "File[]?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--intervals",
                            "itemSeparator": "null",
                            "shellQuote": false,
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self);\n        var paths = [];\n        for (var i=0; i<self.length; i++) {\n            paths.push(self[i].path);\n        }\n        return paths.join(' --intervals ');\n    }\n    return '';\n}"
                        },
                        "label": "Intervals",
                        "doc": "One or more genomic intervals over which to operate.",
                        "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, BED, VCF, LIST"
                    },
                    {
                        "sbg:category": "Execution",
                        "sbg:toolDefaultValue": "0",
                        "id": "memory_overhead_per_job",
                        "type": "int?",
                        "label": "Memory overhead per job",
                        "doc": "Memory overhead which will be allocated for one job."
                    },
                    {
                        "sbg:category": "Execution",
                        "sbg:toolDefaultValue": "2048",
                        "id": "memory_per_job",
                        "type": "int?",
                        "label": "Memory per job",
                        "doc": "Memory which will be allocated for execution."
                    },
                    {
                        "sbg:altPrefix": "-O",
                        "sbg:category": "Required Arguments",
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Output Picard interval-list file containing the preprocessed intervals."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "250",
                        "id": "padding",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--padding",
                            "shellQuote": false
                        },
                        "label": "Padding",
                        "doc": "Length (in bp) of the padding regions on each side of the intervals."
                    },
                    {
                        "sbg:altPrefix": "-R",
                        "sbg:category": "Required Arguments",
                        "id": "in_reference",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--reference",
                            "shellQuote": false
                        },
                        "label": "Reference",
                        "doc": "Reference sequence file.",
                        "sbg:fileTypes": "FASTA, FA",
                        "secondaryFiles": [
                            ".fai",
                            "^.dict"
                        ]
                    },
                    {
                        "sbg:altPrefix": "-seconds-between-progress-updates",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "10",
                        "id": "seconds_between_progress_updates",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--seconds-between-progress-updates",
                            "shellQuote": false
                        },
                        "label": "Seconds between progress updates",
                        "doc": "Output traversal statistics every time this many seconds elapse 0."
                    },
                    {
                        "sbg:altPrefix": "-sequence-dictionary",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "sequence_dictionary",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--sequence-dictionary",
                            "shellQuote": false
                        },
                        "label": "Sequence dictionary",
                        "doc": "Use the given sequence dictionary as the master/canonical sequence dictionary. Must be a .dict file.",
                        "sbg:fileTypes": "DICT"
                    },
                    {
                        "sbg:category": "Execution",
                        "sbg:toolDefaultValue": "1",
                        "id": "cpu_per_job",
                        "type": "int?",
                        "label": "CPU per job",
                        "doc": "Number of CPUs which will be allocated for the job."
                    }
                ],
                "outputs": [
                    {
                        "id": "out_intervals",
                        "doc": "Intervals file with padded and binned intervals.",
                        "label": "Preprocessed intervals",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*preprocessed.intervals",
                            "outputEval": "${\n    var out;\n    if (inputs.intervals) {\n        out = inheritMetadata(self, inputs.intervals);\n        for (var i=0; i < out.length; i++) {\n            out[i].metadata['bin_length'] = inputs.bin_length ? inputs.bin_length : 1000;\n            out[i].metadata['padding'] = inputs.padding ? inputs.padding : 250;\n            out[i].metadata['interval_merging_rule'] = inputs.interval_merging_rule ? inputs.interval_merging_rule : 'ALL';\n        }\n        return out;\n    }\n    out = inheritMetadata(self, inputs.in_reference);\n    for (var i=0; i < out.length; i++) {\n        out[i].metadata['bin_length'] = inputs.bin_length ? inputs.bin_length : 1000;\n        out[i].metadata['padding'] = inputs.padding ? inputs.padding : 250;\n        out[i].metadata['interval_merging_rule'] = inputs.interval_merging_rule ? inputs.interval_merging_rule : 'ALL';\n    }\n    return out;\n}"
                        },
                        "sbg:fileTypes": "INTERVALS"
                    }
                ],
                "doc": "GATK PreprocessIntervals prepares bins for coverage collection by merging overlapping input intervals. Resulting intervals are padded and split into bins.\n\n\n### Common Use Cases\nThis app may be used to prepare intervals for coverage collection, prepare intervals for variant filtration etc. Some of the common input parameters are listed below:\n* **Reference** (`--reference`) - Reference genome in FASTA format. Secondary FAI and DICT files are required.\n* **Intervals** (`--intervals`) to be preprocessed, must be compatible with GATK `-L` argument (more info [https://software.broadinstitute.org/gatk/documentation/article?id=1319](https://software.broadinstitute.org/gatk/documentation/article?id=1319)). The argument **Interval merging rule** must be set to `OVERLAPPING_ONLY` and all other common arguments for interval padding or merging must be set to their defaults. If no intervals are specified, then each contig will be assumed to be a single interval and binned accordingly; this produces bins appropriate for whole genome sequencing analyses.\n* **Padding** (`--padding`) - Use padding to specify the size of each of the regions added to both ends of the intervals that result after overlapping intervals have been merged. Do not use the common **Interval padding** argument. Intervals that would overlap after padding by the specified amount are instead only padded until they are adjacent.\n* **Bin length** (`--bin-length`) - If this length is not commensurate with the length of a padded interval, then the last bin will be of different length than the others in that interval. If zero is specified, then no binning will be performed; this is generally appropriate for targeted analyses.\n\n### Changes Introduced by Seven Bridges\n* Some of the input arguments that are not applicable to this tool have been removed (`--create-output-bam-md5`, `--read-index`, etc.)\n* If **Output prefix** parameter is not specified, prefix for the output file will be derived from the base name of the **Intervals** file. If multiple **Intervals** files have been provided on the input, the prefix will be derived from the first file in the list.\n\n### Common Issues and Important Notes\n* Input parameter **Interval merging rule** must be set to `OVERLAPPING_ONLY`, otherwise the tool will produce an error.\n\n### Performance Benchmarking\n\n| Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- |\n| 10MB | WES | 4min | $0.02 | c4.2xlarge |\n| 0.5MB | WGS | 4min | $0.02 | c4.2xlarge |",
                "label": "GATK PreprocessIntervals",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "/opt/gatk"
                    },
                    {
                        "position": 1,
                        "shellQuote": false,
                        "valueFrom": "--java-options"
                    },
                    {
                        "position": 2,
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.memory_per_job) {\n        return '\\\"-Xmx'.concat(inputs.memory_per_job, 'M') + '\\\"'\n    }\n    return '\\\"-Xmx2048M\\\"'\n}"
                    },
                    {
                        "position": 3,
                        "shellQuote": false,
                        "valueFrom": "PreprocessIntervals"
                    },
                    {
                        "position": 4,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "${\n    var intervals_prefix;\n    if (inputs.intervals) {\n        var intervals = [].concat(inputs.intervals);\n        intervals_prefix = intervals[0].path.split('/').pop().split('.').slice(0,-1).join('.');\n    } else {\n        intervals_prefix = inputs.in_reference.nameroot + \".wgs_intervals\";\n    }\n    var prefix = inputs.output_prefix ? inputs.output_prefix : intervals_prefix;\n    return prefix + '.preprocessed.intervals';\n}"
                    }
                ],
                "requirements": [
                    {
                        "class": "ShellCommandRequirement"
                    },
                    {
                        "class": "ResourceRequirement",
                        "ramMin": "${  \n    var memory = 2048;\n    if (inputs.memory_per_job) {\n        memory = inputs.memory_per_job;\n    }\n    if (inputs.memory_overhead_per_job) {\n        memory += inputs.memory_overhead_per_job;\n    }\n    return memory;\n}",
                        "coresMin": "$(inputs.cpu_per_job ? inputs.cpu_per_job : 1)"
                    },
                    {
                        "class": "DockerRequirement",
                        "dockerPull": "images.sbgenomics.com/stefan_stojanovic/gatk:4.1.0.0"
                    },
                    {
                        "class": "InitialWorkDirRequirement",
                        "listing": []
                    },
                    {
                        "class": "InlineJavascriptRequirement",
                        "expressionLib": [
                            "var updateMetadata = function(file, key, value) {\n    file['metadata'][key] = value;\n    return file;\n};\n\n\nvar setMetadata = function(file, metadata) {\n    if (!('metadata' in file))\n        file['metadata'] = metadata;\n    else {\n        for (var key in metadata) {\n            file['metadata'][key] = metadata[key];\n        }\n    }\n    return file\n};\n\nvar inheritMetadata = function(o1, o2) {\n    var commonMetadata = {};\n    if (!Array.isArray(o2)) {\n        o2 = [o2]\n    }\n    for (var i = 0; i < o2.length; i++) {\n        var example = o2[i]['metadata'];\n        for (var key in example) {\n            if (i == 0)\n                commonMetadata[key] = example[key];\n            else {\n                if (!(commonMetadata[key] == example[key])) {\n                    delete commonMetadata[key]\n                }\n            }\n        }\n    }\n    if (!Array.isArray(o1)) {\n        o1 = setMetadata(o1, commonMetadata)\n    } else {\n        for (var i = 0; i < o1.length; i++) {\n            o1[i] = setMetadata(o1[i], commonMetadata)\n        }\n    }\n    return o1;\n};\n\nvar toArray = function(file) {\n    return [].concat(file);\n};\n\nvar groupBy = function(files, key) {\n    var groupedFiles = [];\n    var tempDict = {};\n    for (var i = 0; i < files.length; i++) {\n        var value = files[i]['metadata'][key];\n        if (value in tempDict)\n            tempDict[value].push(files[i]);\n        else tempDict[value] = [files[i]];\n    }\n    for (var key in tempDict) {\n        groupedFiles.push(tempDict[key]);\n    }\n    return groupedFiles;\n};\n\nvar orderBy = function(files, key, order) {\n    var compareFunction = function(a, b) {\n        if (a['metadata'][key].constructor === Number) {\n            return a['metadata'][key] - b['metadata'][key];\n        } else {\n            var nameA = a['metadata'][key].toUpperCase();\n            var nameB = b['metadata'][key].toUpperCase();\n            if (nameA < nameB) {\n                return -1;\n            }\n            if (nameA > nameB) {\n                return 1;\n            }\n            return 0;\n        }\n    };\n\n    files = files.sort(compareFunction);\n    if (order == undefined || order == \"asc\")\n        return files;\n    else\n        return files.reverse();\n};"
                        ]
                    }
                ],
                "sbg:categories": [
                    "Utilities",
                    "BED Processing"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 - Demo",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553102192,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-preprocessintervals-4-1-0-0/15"
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553864260,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-preprocessintervals-4-1-0-0/24"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1554069406,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-preprocessintervals-4-1-0-0/28"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1556198568,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-preprocessintervals-4-1-0-0/30"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559578959,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-preprocessintervals-4-1-0-0/33"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "uros_sipetic/gatk-4-1-0-0-demo/gatk-preprocessintervals-4-1-0-0/4",
                "sbg:revision": 4,
                "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-preprocessintervals-4-1-0-0/33",
                "sbg:modifiedOn": 1559578959,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1553102192,
                "sbg:createdBy": "uros_sipetic",
                "sbg:project": "uros_sipetic/gatk-4-1-0-0-demo",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 4,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a619783ec492e6c1c671ab2136a3998689f211a572f620600c3d697941fc0ed54",
                "sbg:copyOf": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-preprocessintervals-4-1-0-0/33"
            },
            "label": "GATK PreprocessIntervals",
            "sbg:x": -118.88700866699219,
            "sbg:y": 44.949153900146484
        },
        {
            "id": "gatk_annotateintervals_4_1_0_0",
            "in": [
                {
                    "id": "interval_merging_rule",
                    "default": "OVERLAPPING_ONLY"
                },
                {
                    "id": "intervals",
                    "source": [
                        "gatk_preprocessintervals_4_1_0_0/out_intervals"
                    ],
                    "valueFrom": "$(self ? [self] : self)"
                },
                {
                    "id": "memory_per_job",
                    "default": 2000
                },
                {
                    "id": "in_reference",
                    "source": "in_reference"
                },
                {
                    "id": "segmental_duplication_track",
                    "source": "segmental_duplication_track"
                },
                {
                    "id": "do_explicit_gc_correction",
                    "source": "do_explicit_gc_correction"
                },
                {
                    "id": "mappability_track",
                    "source": "mappability_track"
                },
                {
                    "id": "feature_query_lookahead",
                    "source": "feature_query_lookahead"
                }
            ],
            "out": [
                {
                    "id": "annotated_intervals"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "uros_sipetic/gatk-4-1-0-0-demo/gatk-annotateintervals-4-1-0-0/2",
                "baseCommand": [],
                "inputs": [
                    {
                        "sbg:altPrefix": "-disable-sequence-dictionary-validation",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "false",
                        "id": "disable_sequence_dictionary_validation",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "true",
                                    "false"
                                ],
                                "name": "disable_sequence_dictionary_validation"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--disable-sequence-dictionary-validation",
                            "shellQuote": false
                        },
                        "label": "Disable sequence dictionary validation",
                        "doc": "If specified, do not check the sequence dictionaries from our inputs for compatibility. Use at your own risk!"
                    },
                    {
                        "sbg:altPrefix": "-XL",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "exclude_intervals",
                        "type": "File[]?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--exclude-intervals",
                            "shellQuote": false,
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self);\n        var paths = [];\n        for (var i=0; i<self.length; i++) {\n            paths.push(self[i].path);\n        }\n        return paths.join(' --exclude-intervals ');\n    }\n    return '';\n}"
                        },
                        "label": "Exclude intervals",
                        "doc": "or more genomic intervals to exclude from processing.",
                        "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, BED, VCF, LIST"
                    },
                    {
                        "sbg:altPrefix": "-ixp",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "interval_exclusion_padding",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--interval-exclusion-padding",
                            "shellQuote": false
                        },
                        "label": "Interval exclusion padding",
                        "doc": "Amount of padding (in bp) to add to each interval you are excluding."
                    },
                    {
                        "sbg:altPrefix": "-imr",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "ALL",
                        "id": "interval_merging_rule",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "ALL",
                                    "OVERLAPPING_ONLY"
                                ],
                                "name": "interval_merging_rule"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--interval-merging-rule",
                            "shellQuote": false
                        },
                        "label": "Interval merging rule",
                        "doc": "Interval merging rule for abutting intervals."
                    },
                    {
                        "sbg:altPrefix": "-ip",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "interval_padding",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--interval-padding",
                            "shellQuote": false
                        },
                        "label": "Interval padding",
                        "doc": "of padding (in bp) to add to each interval you are including."
                    },
                    {
                        "sbg:altPrefix": "-isr",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "UNION",
                        "id": "interval_set_rule",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "UNION",
                                    "INTERSECTION"
                                ],
                                "name": "interval_set_rule"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--interval-set-rule",
                            "shellQuote": false
                        },
                        "label": "Interval set rule",
                        "doc": "Set merging approach to use for combining interval inputs."
                    },
                    {
                        "sbg:altPrefix": "-L",
                        "sbg:category": "Required Arguments",
                        "id": "intervals",
                        "type": "File[]",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--intervals",
                            "shellQuote": false,
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self)\n        var paths = [];\n        for (var i=0; i<self.length; i++) {\n            paths.push(self[i].path);\n        }\n        return paths.join(' --intervals ');\n    }\n    return '';\n}"
                        },
                        "label": "Intervals",
                        "doc": "One or more genomic intervals over which to operate This argument must be specified at least once.",
                        "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, BED, VCF, LIST"
                    },
                    {
                        "sbg:category": "Execution",
                        "sbg:toolDefaultValue": "0",
                        "id": "memory_overhead_per_job",
                        "type": "int?",
                        "label": "Memory overhead per job",
                        "doc": "Memory overhead which will be allocated for one job."
                    },
                    {
                        "sbg:category": "Execution",
                        "sbg:toolDefaultValue": "2048",
                        "id": "memory_per_job",
                        "type": "int?",
                        "label": "Memory per job",
                        "doc": "Memory which will be allocated for execution."
                    },
                    {
                        "sbg:altPrefix": "-O",
                        "sbg:category": "Required Arguments",
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Output file for annotated intervals."
                    },
                    {
                        "sbg:altPrefix": "-R",
                        "sbg:category": "Required Arguments",
                        "id": "in_reference",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--reference",
                            "shellQuote": false
                        },
                        "label": "Reference",
                        "doc": "Reference sequence file.",
                        "sbg:fileTypes": "FASTA, FA",
                        "secondaryFiles": [
                            ".fai",
                            "^.dict"
                        ]
                    },
                    {
                        "sbg:altPrefix": "-seconds-between-progress-updates",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "10",
                        "id": "seconds_between_progress_updates",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--seconds-between-progress-updates",
                            "shellQuote": false
                        },
                        "label": "Seconds between progress updates",
                        "doc": "Output traversal statistics every time this many seconds elapse 0."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "segmental_duplication_track",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--segmental-duplication-track",
                            "shellQuote": false
                        },
                        "label": "Segmental duplication track",
                        "doc": "Path to segmental-duplication track in .bed or .bed.gz format. Overlapping intervals must be merged.",
                        "sbg:fileTypes": "BED, BED.GZ",
                        "secondaryFiles": [
                            ".idx"
                        ]
                    },
                    {
                        "sbg:altPrefix": "-sequence-dictionary",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "sequence_dictionary",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--sequence-dictionary",
                            "shellQuote": false
                        },
                        "label": "Sequence dictionary",
                        "doc": "Use the given sequence dictionary as the master/canonical sequence dictionary. Must be a .dict file.",
                        "sbg:fileTypes": "DICT"
                    },
                    {
                        "sbg:category": "Execution",
                        "sbg:toolDefaultValue": "1",
                        "id": "cpu_per_job",
                        "type": "int?",
                        "label": "CPU per job",
                        "doc": "Number of CPUs which will be allocated for the job."
                    },
                    {
                        "sbg:category": "Execution",
                        "id": "do_explicit_gc_correction",
                        "type": "boolean",
                        "label": "Do explicit GC correction",
                        "doc": "Choose whether to execute this app. This argument is GATK CNV Best Practice requirement."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "id": "mappability_track",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--mappability-track",
                            "shellQuote": false
                        },
                        "label": "Mappability track file",
                        "doc": "Path to Umap single-read mappability track in .bed or .bed.gz format (see https://bismap.hoffmanlab.org/). Overlapping intervals must be merged. Default value:  null.",
                        "sbg:fileTypes": "BED, BED.GZ",
                        "secondaryFiles": [
                            ".idx"
                        ]
                    },
                    {
                        "sbg:toolDefaultValue": "1000000",
                        "sbg:category": "Optional Arguments",
                        "id": "feature_query_lookahead",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--feature-query-lookahead",
                            "shellQuote": false
                        },
                        "label": "Feature query lookahead",
                        "doc": "Number of bases to cache when querying feature tracks.  Default value: 1000000."
                    }
                ],
                "outputs": [
                    {
                        "id": "annotated_intervals",
                        "doc": "Intervals annotated with GC content, mappability and segmental-duplication.",
                        "label": "Annotated intervals",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.annotated.tsv",
                            "outputEval": "$(inheritMetadata(self, inputs.intervals))"
                        },
                        "sbg:fileTypes": "TSV"
                    }
                ],
                "doc": "GATK AnnotateIntervals annotates intervals with GC content, and optionally, mappability and segmental-duplication content. \n\n### Common Use Cases\nThe output of this tool may optionally be used as input to **CreateReadCountPanelOfNormals**, **DenoiseReadCounts**, and **GermlineCNVCaller**. Some of the common input parameters are listed below:\n\n* **Reference** (`--reference`) - Reference genome in FASTA format. Secondary FAI and DICT files are required.\n* **Intervals** (`--intervals`) to be annotated. Supported formats are described [here](https://software.broadinstitute.org/gatk/documentation/article?id=1319). The argument **Interval merging rule** must be set to `OVERLAPPING_ONLY` and all other common arguments for interval padding or merging must be set to their defaults.\n* **Mappability track file** (`--mappability-track`) - This is a BED file in BED or BED.GZ format that identifies uniquely mappable regions of the genome. The track should correspond to the appropriate read length and overlapping intervals must be merged. See [https://bismap.hoffmanlab.org/](https://bismap.hoffmanlab.org/). If scores are provided, intervals will be annotated with the length-weighted average; note that NaN scores will be taken as unity. Otherwise, scores for covered and uncovered intervals will be taken as unity and zero, respectively.\n* **Segmental duplication track** (`--segmental-duplication-track`) - This is a BED file in BED or BED.GZ format that identifies segmental-duplication regions of the genome. Overlapping intervals must be merged. If scores are provided, intervals will be annotated with the length-weighted average; note that NaN scores will be taken as unity. Otherwise, scores for covered and uncovered intervals will be taken as unity and zero, respectively.\n\n### Changes Introduced by Seven Bridges\n* Additional input **Do explicit GC correction** is added in accordance with [CNV best practice WDL](https://github.com/gatk-workflows/gatk4-somatic-cnvs/blob/master/cnv_somatic_panel_workflow.wdl) specification. This input is required, and must be set to `true` in order to execute the command line.\n* Some of the input arguments that are not applicable to this tool have been removed (`--create-output-bam-md5`, `--read-index`, etc.)\n* If **Output prefix** parameter is not specified, prefix for the output file will be derived from the base name of the **Intervals** file. If multiple **Intervals** files have been provided on the input, the prefix will be derived from the first file in the list.\n\n### Common Issues and Important Notes\n* Input parameter **Interval merging rule** must be set to `OVERLAPPING_ONLY`, otherwise the tool will produce an error.\n\n### Performance Benchmarking\n\n| Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- |\n| 5.0MB | WES | 3min | $0.02 | c4.2xlarge |\n| 73.8MB | WGS | 3min | $0.02 | c4.2xlarge |",
                "label": "GATK AnnotateIntervals",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$( inputs.do_explicit_gc_correction ? '/opt/gatk' : 'echo /opt/gatk')"
                    },
                    {
                        "position": 1,
                        "shellQuote": false,
                        "valueFrom": "--java-options"
                    },
                    {
                        "position": 2,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.memory_per_job) {\n        return '\\\"-Xmx'.concat(inputs.memory_per_job, 'M') + '\\\"';\n    }\n    return '\\\"-Xmx2048M\\\"';\n}"
                    },
                    {
                        "position": 3,
                        "shellQuote": false,
                        "valueFrom": "AnnotateIntervals"
                    },
                    {
                        "position": 4,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "${\n    var intervals = [].concat(inputs.intervals);\n    var prefix = inputs.output_prefix ? inputs.output_prefix : intervals[0].path.split('/').pop().split('.').slice(0,-1).join('.');\n    return prefix + '.annotated.tsv';\n}"
                    }
                ],
                "requirements": [
                    {
                        "class": "ShellCommandRequirement"
                    },
                    {
                        "class": "ResourceRequirement",
                        "ramMin": "${  \n    var memory = 2048;\n    if (inputs.memory_per_job) {\n        memory = inputs.memory_per_job;\n    }\n    if (inputs.memory_overhead_per_job) {\n        memory += inputs.memory_overhead_per_job;\n    }\n    return memory;\n}",
                        "coresMin": "$(inputs.cpu_per_job ? inputs.cpu_per_job : 1)"
                    },
                    {
                        "class": "DockerRequirement",
                        "dockerPull": "images.sbgenomics.com/stefan_stojanovic/gatk:4.1.0.0"
                    },
                    {
                        "class": "InitialWorkDirRequirement",
                        "listing": []
                    },
                    {
                        "class": "InlineJavascriptRequirement",
                        "expressionLib": [
                            "var updateMetadata = function(file, key, value) {\n    file['metadata'][key] = value;\n    return file;\n};\n\n\nvar setMetadata = function(file, metadata) {\n    if (!('metadata' in file))\n        file['metadata'] = metadata;\n    else {\n        for (var key in metadata) {\n            file['metadata'][key] = metadata[key];\n        }\n    }\n    return file\n};\n\nvar inheritMetadata = function(o1, o2) {\n    var commonMetadata = {};\n    if (!Array.isArray(o2)) {\n        o2 = [o2]\n    }\n    for (var i = 0; i < o2.length; i++) {\n        var example = o2[i]['metadata'];\n        for (var key in example) {\n            if (i == 0)\n                commonMetadata[key] = example[key];\n            else {\n                if (!(commonMetadata[key] == example[key])) {\n                    delete commonMetadata[key]\n                }\n            }\n        }\n    }\n    if (!Array.isArray(o1)) {\n        o1 = setMetadata(o1, commonMetadata)\n    } else {\n        for (var i = 0; i < o1.length; i++) {\n            o1[i] = setMetadata(o1[i], commonMetadata)\n        }\n    }\n    return o1;\n};\n\nvar toArray = function(file) {\n    return [].concat(file);\n};\n\nvar groupBy = function(files, key) {\n    var groupedFiles = [];\n    var tempDict = {};\n    for (var i = 0; i < files.length; i++) {\n        var value = files[i]['metadata'][key];\n        if (value in tempDict)\n            tempDict[value].push(files[i]);\n        else tempDict[value] = [files[i]];\n    }\n    for (var key in tempDict) {\n        groupedFiles.push(tempDict[key]);\n    }\n    return groupedFiles;\n};\n\nvar orderBy = function(files, key, order) {\n    var compareFunction = function(a, b) {\n        if (a['metadata'][key].constructor === Number) {\n            return a['metadata'][key] - b['metadata'][key];\n        } else {\n            var nameA = a['metadata'][key].toUpperCase();\n            var nameB = b['metadata'][key].toUpperCase();\n            if (nameA < nameB) {\n                return -1;\n            }\n            if (nameA > nameB) {\n                return 1;\n            }\n            return 0;\n        }\n    };\n\n    files = files.sort(compareFunction);\n    if (order == undefined || order == \"asc\")\n        return files;\n    else\n        return files.reverse();\n};",
                            "\nvar setMetadata = function(file, metadata) {\n    if (!('metadata' in file))\n        file['metadata'] = metadata;\n    else {\n        for (var key in metadata) {\n            file['metadata'][key] = metadata[key];\n        }\n    }\n    return file\n};\n\nvar inheritMetadata = function(o1, o2) {\n    var commonMetadata = {};\n    if (!Array.isArray(o2)) {\n        o2 = [o2]\n    }\n    for (var i = 0; i < o2.length; i++) {\n        var example = o2[i]['metadata'];\n        for (var key in example) {\n            if (i == 0)\n                commonMetadata[key] = example[key];\n            else {\n                if (!(commonMetadata[key] == example[key])) {\n                    delete commonMetadata[key]\n                }\n            }\n        }\n    }\n    if (!Array.isArray(o1)) {\n        o1 = setMetadata(o1, commonMetadata)\n    } else {\n        for (var i = 0; i < o1.length; i++) {\n            o1[i] = setMetadata(o1[i], commonMetadata)\n        }\n    }\n    return o1;\n};"
                        ]
                    }
                ],
                "sbg:categories": [
                    "Genomics",
                    "Copy Number Variant Calling"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 - Demo",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553098388,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-annotateintervals-4-1-0-0/5"
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553864180,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-annotateintervals-4-1-0-0/21"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559579734,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-annotateintervals-4-1-0-0/22"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "uros_sipetic/gatk-4-1-0-0-demo/gatk-annotateintervals-4-1-0-0/2",
                "sbg:revision": 2,
                "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-annotateintervals-4-1-0-0/22",
                "sbg:modifiedOn": 1559579734,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1553098388,
                "sbg:createdBy": "uros_sipetic",
                "sbg:project": "uros_sipetic/gatk-4-1-0-0-demo",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 2,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a1ea13153de4024a7a76a90a1eab01a4a4c585aee8fdc064a12c47d24d3cedc17",
                "sbg:copyOf": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-annotateintervals-4-1-0-0/22"
            },
            "label": "GATK AnnotateIntervals",
            "sbg:x": 224.23728942871094,
            "sbg:y": -172
        },
        {
            "id": "gatk_collectreadcounts_4_1_0_0",
            "in": [
                {
                    "id": "output_format",
                    "source": "output_format"
                },
                {
                    "id": "in_alignments",
                    "source": [
                        "in_alignments"
                    ],
                    "valueFrom": "$(self ? [self] : self)"
                },
                {
                    "id": "interval_merging_rule",
                    "default": "OVERLAPPING_ONLY"
                },
                {
                    "id": "intervals",
                    "source": [
                        "gatk_preprocessintervals_4_1_0_0/out_intervals"
                    ],
                    "valueFrom": "$(self ? [self] : self)"
                },
                {
                    "id": "memory_per_job",
                    "default": 7000
                },
                {
                    "id": "in_reference",
                    "source": "in_reference"
                }
            ],
            "out": [
                {
                    "id": "read_counts"
                },
                {
                    "id": "entity_id"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "uros_sipetic/gatk-4-1-0-0-demo/gatk-collectreadcounts-4-1-0-0/11",
                "baseCommand": [],
                "inputs": [
                    {
                        "sbg:altPrefix": "-add-output-sam-program-record",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "true",
                        "id": "add_output_sam_program_record",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "true",
                                    "false"
                                ],
                                "name": "add_output_sam_program_record"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--add-output-sam-program-record",
                            "shellQuote": false
                        },
                        "label": "Add output SAM program record",
                        "doc": "If true, adds a PG tag to created SAM/BAM/CRAM files."
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "ambig_filter_bases",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--ambig-filter-bases",
                            "shellQuote": false
                        },
                        "label": "Ambig filter bases",
                        "doc": "Threshold number of ambiguous bases. If null, uses threshold fraction; otherwise, overrides threshold fraction. Cannot be used in conjuction with argument(s) maxAmbiguousBaseFraction. Valid only if \"AmbiguousBaseReadFilter\" is specified."
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "ambig_filter_frac",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--ambig-filter-frac",
                            "shellQuote": false
                        },
                        "label": "Ambig filter fraction",
                        "doc": "Threshold fraction of ambiguous bases 05. Cannot be used in conjuction with argument(s) maxAmbiguousBases. Valid only if \"AmbiguousBaseReadFilter\" is specified."
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "id": "black_listed_lanes",
                        "type": "string?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--black-listed-lanes",
                            "shellQuote": false
                        },
                        "label": "Black listed lanes",
                        "doc": "Platform unit (PU) to filter out This argument must be specified at least once. Valid only if \"PlatformUnitReadFilter\" is specified."
                    },
                    {
                        "sbg:altPrefix": "-DBIC",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "false",
                        "id": "disable_bam_index_caching",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "true",
                                    "false"
                                ],
                                "name": "disable_bam_index_caching"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--disable-bam-index-caching",
                            "shellQuote": false
                        },
                        "label": "Disable BAM index caching",
                        "doc": "If true, don't cache bam indexes, this will reduce memory requirements but may harm performance if many intervals are specified. Caching is automatically disabled if there are no intervals specified."
                    },
                    {
                        "sbg:altPrefix": "-DF",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "disable_read_filter",
                        "type": [
                            "null",
                            {
                                "type": "array",
                                "items": {
                                    "type": "enum",
                                    "name": "disable_read_filter",
                                    "symbols": [
                                        "MappedReadFilter",
                                        "MappingQualityReadFilter",
                                        "NonZeroReferenceLengthAlignmentReadFilter",
                                        "NotDuplicateReadFilter",
                                        "WellformedReadFilter"
                                    ]
                                }
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--disable-read-filter",
                            "shellQuote": false,
                            "valueFrom": "${\n    if (self) {\n        return self.join(' --disable-read-filter ');\n    }\n    return '';\n}"
                        },
                        "label": "Disable read filter",
                        "doc": "Read filters to be disabled before analysis."
                    },
                    {
                        "sbg:altPrefix": "-disable-sequence-dictionary-validation",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "false",
                        "id": "disable_sequence_dictionary_validation",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "true",
                                    "false"
                                ],
                                "name": "disable_sequence_dictionary_validation"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--disable-sequence-dictionary-validation",
                            "shellQuote": false
                        },
                        "label": "Disable sequence dictionary validation",
                        "doc": "If specified, do not check the sequence dictionaries from our inputs for compatibility. Use at your own risk!"
                    },
                    {
                        "sbg:altPrefix": "-disable-tool-default-read-filters",
                        "sbg:category": "Advanced Arguments",
                        "sbg:toolDefaultValue": "false",
                        "id": "disable_tool_default_read_filters",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "true",
                                    "false"
                                ],
                                "name": "disable_tool_default_read_filters"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--disable-tool-default-read-filters",
                            "shellQuote": false
                        },
                        "label": "Disable tool default read filters",
                        "doc": "Disable all tool default read filters (WARNING: many tools will not function correctly without their default read filters on)."
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "sbg:toolDefaultValue": "false",
                        "id": "dont_require_soft_clips_both_ends",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "true",
                                    "false"
                                ],
                                "name": "dont_require_soft_clips_both_ends"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--dont-require-soft-clips-both-ends",
                            "shellQuote": false
                        },
                        "label": "Dont require soft clips both ends",
                        "doc": "Allow a read to be filtered out based on having only 1 soft-clipped block. By default, both ends must have a soft-clipped block, setting this flag requires only 1 soft-clipped block. Valid only if \"OverclippedReadFilter\" is specified."
                    },
                    {
                        "sbg:altPrefix": "-XL",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "exclude_intervals",
                        "type": "File[]?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--exclude-intervals",
                            "shellQuote": false,
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self);\n        var paths = [];\n        for (var i=0; i<self.length; i++) {\n            paths.push(self[i].path);\n        }\n        return paths.join(' --exclude-intervals ');\n    }\n    return '';\n}"
                        },
                        "label": "Exclude intervals",
                        "doc": "One or more genomic intervals to exclude from processing.",
                        "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, BED, VCF, LIST"
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "HDF5",
                        "id": "output_format",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "TSV",
                                    "HDF5"
                                ],
                                "name": "output_format"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--format",
                            "shellQuote": false
                        },
                        "label": "Format",
                        "doc": "Output file format."
                    },
                    {
                        "sbg:altPrefix": "-I",
                        "sbg:category": "Required Arguments",
                        "id": "in_alignments",
                        "type": "File[]",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--input",
                            "shellQuote": false,
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self);\n        var paths = [];\n        for (var i=0; i<self.length; i++) {\n            paths.push(self[i].path);\n        }\n        return paths.join(' --input ');\n    }\n    return '';\n}"
                        },
                        "label": "Input reads",
                        "doc": "BAM/SAM/CRAM file containing reads This argument must be specified at least once.",
                        "sbg:fileTypes": "BAM, SAM, CRAM",
                        "secondaryFiles": [
                            "${\n    if(self.nameext == '.bam'){\n        return self.basename + '.bai';\n        return null;\n    }\n}"
                        ]
                    },
                    {
                        "sbg:altPrefix": "-ixp",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "interval_exclusion_padding",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--interval-exclusion-padding",
                            "shellQuote": false
                        },
                        "label": "Interval exclusion padding",
                        "doc": "Amount of padding (in bp) to add to each interval you are excluding."
                    },
                    {
                        "sbg:altPrefix": "-imr",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "ALL",
                        "id": "interval_merging_rule",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "ALL",
                                    "OVERLAPPING_ONLY"
                                ],
                                "name": "interval_merging_rule"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--interval-merging-rule",
                            "shellQuote": false
                        },
                        "label": "Interval merging rule",
                        "doc": "Interval merging rule for abutting intervals."
                    },
                    {
                        "sbg:altPrefix": "-ip",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "interval_padding",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--interval-padding",
                            "shellQuote": false
                        },
                        "label": "Interval padding",
                        "doc": "of padding (in bp) to add to each interval you are including."
                    },
                    {
                        "sbg:altPrefix": "-isr",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "UNION",
                        "id": "interval_set_rule",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "UNION",
                                    "INTERSECTION"
                                ],
                                "name": "interval_set_rule"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--interval-set-rule",
                            "shellQuote": false
                        },
                        "label": "Interval set rule",
                        "doc": "Set merging approach to use for combining interval inputs."
                    },
                    {
                        "sbg:altPrefix": "-L",
                        "sbg:category": "Required Arguments",
                        "id": "intervals",
                        "type": "File[]",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--intervals",
                            "shellQuote": false,
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self);\n        var paths = [];\n        for (var i=0; i<self.length; i++) {\n            paths.push(self[i].path);\n        }\n        return paths.join(' --intervals ');\n    }\n    return '';\n}"
                        },
                        "label": "Intervals",
                        "doc": "One or more genomic intervals over which to operate This argument must be specified at least once.",
                        "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, BED, VCF, LIST"
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "id": "keep_read_group",
                        "type": "string?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--keep-read-group",
                            "shellQuote": false
                        },
                        "label": "Keep read group",
                        "doc": "The name of the read group to keep. Valid only if \"ReadGroupReadFilter\" is specified."
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "id": "keep_reverse_strand_only",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "true",
                                    "false"
                                ],
                                "name": "keep_reverse_strand_only"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--keep-reverse-strand-only",
                            "shellQuote": false
                        },
                        "label": "Keep reverse strand only",
                        "doc": "Keep only reads on the reverse strand. Valid only if \"ReadStrandFilter\" is specified."
                    },
                    {
                        "sbg:altPrefix": "-library",
                        "sbg:category": "Conditional Arguments",
                        "id": "library",
                        "type": "string?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--library",
                            "shellQuote": false
                        },
                        "label": "Library",
                        "doc": "Name of the library to keep This argument must be specified at least once. Valid only if \"LibraryReadFilter\" is specified."
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "sbg:toolDefaultValue": "1000000",
                        "id": "max_fragment_length",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--max-fragment-length",
                            "shellQuote": false
                        },
                        "label": "Max fragment length",
                        "doc": "Maximum length of fragment (insert size). Valid only if \"FragmentLengthReadFilter\" is specified."
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "id": "max_read_length",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--max-read-length",
                            "shellQuote": false
                        },
                        "label": "Max read length",
                        "doc": "Keep only reads with length at most equal to the specified value. Valid only if \"ReadLengthReadFilter\" is specified."
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "maximum_mapping_quality",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--maximum-mapping-quality",
                            "shellQuote": false
                        },
                        "label": "Maximum mapping quality",
                        "doc": "Maximum mapping quality to keep (inclusive). Valid only if \"MappingQualityReadFilter\" is specified."
                    },
                    {
                        "sbg:category": "Execution",
                        "sbg:toolDefaultValue": "2048",
                        "id": "memory_per_job",
                        "type": "int?",
                        "label": "Memory per job",
                        "doc": "Memory which will be allocated for execution."
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "sbg:toolDefaultValue": "1",
                        "id": "min_read_length",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--min-read-length",
                            "shellQuote": false
                        },
                        "label": "Min read length",
                        "doc": "Keep only reads with length at least equal to the specified value. Valid only if \"ReadLengthReadFilter\" is specified."
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "sbg:toolDefaultValue": "30",
                        "id": "minimum_mapping_quality",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--minimum-mapping-quality",
                            "shellQuote": false
                        },
                        "label": "Minimum mapping quality",
                        "doc": "Minimum mapping quality to keep (inclusive). Valid only if \"MappingQualityReadFilter\" is specified."
                    },
                    {
                        "sbg:altPrefix": "-O",
                        "sbg:category": "Required Arguments",
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Output file for read counts."
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "id": "platform_filter_name",
                        "type": "string?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--platform-filter-name",
                            "shellQuote": false
                        },
                        "label": "Platform filter name",
                        "doc": "Platform attribute (PL) to match This argument must be specified at least once. Valid only if \"PlatformReadFilter\" is specified."
                    },
                    {
                        "sbg:altPrefix": "-RF",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "read_filter",
                        "type": [
                            "null",
                            {
                                "type": "array",
                                "items": {
                                    "type": "enum",
                                    "name": "read_filter",
                                    "symbols": [
                                        "AlignmentAgreesWithHeaderReadFilter",
                                        "AllowAllReadsReadFilter",
                                        "AmbiguousBaseReadFilter",
                                        "CigarContainsNoNOperator",
                                        "FirstOfPairReadFilter",
                                        "FragmentLengthReadFilter",
                                        "GoodCigarReadFilter",
                                        "HasReadGroupReadFilter",
                                        "LibraryReadFilter",
                                        "MappedReadFilter",
                                        "MappingQualityAvailableReadFilter",
                                        "MappingQualityNotZeroReadFilter",
                                        "MappingQualityReadFilter",
                                        "MatchingBasesAndQualsReadFilter",
                                        "MateDifferentStrandReadFilter",
                                        "MateOnSameContigOrNoMappedMateReadFilter",
                                        "MetricsReadFilter",
                                        "NonChimericOriginalAlignmentReadFilter",
                                        "NonZeroFragmentLengthReadFilter",
                                        "NonZeroReferenceLengthAlignmentReadFilter",
                                        "NotDuplicateReadFilter",
                                        "NotOpticalDuplicateReadFilter",
                                        "NotSecondaryAlignmentReadFilter",
                                        "NotSupplementaryAlignmentReadFilter",
                                        "OverclippedReadFilter",
                                        "PairedReadFilter",
                                        "PassesVendorQualityCheckReadFilter",
                                        "PlatformReadFilter",
                                        "PlatformUnitReadFilter",
                                        "PrimaryLineReadFilter",
                                        "ProperlyPairedReadFilter",
                                        "ReadGroupBlackListReadFilter",
                                        "ReadGroupReadFilter",
                                        "ReadLengthEqualsCigarLengthReadFilter",
                                        "ReadLengthReadFilter",
                                        "ReadNameReadFilter",
                                        "ReadStrandFilter",
                                        "SampleReadFilter",
                                        "SecondOfPairReadFilter",
                                        "SeqIsStoredReadFilter",
                                        "ValidAlignmentEndReadFilter",
                                        "ValidAlignmentStartReadFilter",
                                        "WellformedReadFilter"
                                    ]
                                }
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--read-filter",
                            "shellQuote": false,
                            "valueFrom": "${\n    if (self) {\n        return self.join(' --read-filter ');\n    }\n    return '';\n}"
                        },
                        "label": "Read filter",
                        "doc": "Read filters to be applied before analysis."
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "id": "read_group_black_list",
                        "type": "string?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--read-group-black-list",
                            "shellQuote": false
                        },
                        "label": "Read group black list",
                        "doc": "name of the read group to filter out This argument must be specified at least once. Valid only if \"ReadGroupBlackListReadFilter\" is specified."
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "id": "read_name",
                        "type": "string?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--read-name",
                            "shellQuote": false
                        },
                        "label": "Read name",
                        "doc": "Keep only reads with this read name. Valid only if \"ReadNameReadFilter\" is specified."
                    },
                    {
                        "sbg:altPrefix": "-VS",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "SILENT",
                        "id": "read_validation_stringency",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "STRICT",
                                    "LENIENT",
                                    "SILENT"
                                ],
                                "name": "read_validation_stringency"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--read-validation-stringency",
                            "shellQuote": false
                        },
                        "label": "Read validation stringency",
                        "doc": "Validation stringency for all SAM/BAM/CRAM/SRA files read by this program. The default stringency value SILENT can improve performance when processing a BAM file in which variable-length data (read, qualities, tags) do not otherwise need to be decoded."
                    },
                    {
                        "sbg:altPrefix": "-R",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "in_reference",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--reference",
                            "shellQuote": false
                        },
                        "label": "Reference",
                        "doc": "Reference sequence.",
                        "sbg:fileTypes": "FASTA, FA",
                        "secondaryFiles": [
                            ".fai",
                            "^.dict"
                        ]
                    },
                    {
                        "sbg:altPrefix": "-sample",
                        "sbg:category": "Conditional Arguments",
                        "id": "sample",
                        "type": "string?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--sample",
                            "shellQuote": false
                        },
                        "label": "Sample",
                        "doc": "The name of the sample(s) to keep, filtering out all others This argument must be specified at least once. Valid only if \"SampleReadFilter\" is specified."
                    },
                    {
                        "sbg:altPrefix": "-seconds-between-progress-updates",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "10",
                        "id": "seconds_between_progress_updates",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--seconds-between-progress-updates",
                            "shellQuote": false
                        },
                        "label": "Seconds between progress updates",
                        "doc": "Output traversal statistics every time this many seconds elapse 0."
                    },
                    {
                        "sbg:altPrefix": "-sequence-dictionary",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "sequence_dictionary",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--sequence-dictionary",
                            "shellQuote": false
                        },
                        "label": "Sequence dictionary",
                        "doc": "Use the given sequence dictionary as the master/canonical sequence dictionary. Must be a .dict file.",
                        "sbg:fileTypes": "DICT"
                    },
                    {
                        "sbg:category": "Execution",
                        "sbg:toolDefaultValue": "0",
                        "id": "memory_overhead_per_job",
                        "type": "int?",
                        "label": "Memory overhead per job",
                        "doc": "Memory overhead which will be allocated for one job."
                    },
                    {
                        "sbg:category": "Execution",
                        "id": "cpu_per_job",
                        "type": "int?",
                        "label": "CPU per job",
                        "doc": "Number of CPUs which will be allocated for the job."
                    }
                ],
                "outputs": [
                    {
                        "id": "read_counts",
                        "doc": "Read counts file containing counts per bin.",
                        "label": "Read counts",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.hdf5",
                            "outputEval": "$( inputs.in_alignments ? inheritMetadata(self, inputs.in_alignments) : self)"
                        },
                        "sbg:fileTypes": "HDF5, TSV"
                    },
                    {
                        "id": "entity_id",
                        "doc": "Entity id (BAM file nameroot). This output is GATK Best Practice requirement.",
                        "label": "Entity ID",
                        "type": "string?",
                        "outputBinding": {
                            "outputEval": "${\n    if (inputs.in_alignments) {\n        var entity_ids = [];\n        var in_alignments = [].concat(inputs.in_alignments);\n        for (var i=0; i<in_alignments.length; i++) {\n            entity_ids.push(in_alignments[i].path.split('/').pop().split('.').slice(0,-1).join('.'));\n        }\n        if (entity_ids.length == 1) {\n            return entity_ids[0];\n        }\n        return entity_ids;\n    }\n    return '';\n}"
                        }
                    }
                ],
                "doc": "GATK CollectReadCounts collects read counts at specified intervals by counting the number of read starts that lie in the interval. \n\n### Common Use Cases\nBy default, the tool produces HDF5 format results. This can be changed with the **Format** parameter to TSV format. Using HDF5 files with **CreateReadCountPanelOfNormals** can decrease runtime, by reducing time spent on IO, so this is the default output format. HDF5 files may be viewed using **hdfview** or loaded in python using **PyTables** or **h5py**. The TSV format has a SAM-style header containing a read group sample name, a sequence dictionary, a row specifying the column headers and the corresponding entry rows.\n* **Input reads** (`--input`) - SAM format read data in BAM/SAM/CRAM format. In case of BAM and CRAM files the secondary BAI and CRAI index files are required.\n* **Intervals** (`--intervals`) at which counts will be collected. The argument **Interval merging rule** must be set to `OVERLAPPING_ONLY` and all other common arguments for interval padding or merging must be set to their defaults.\n* **Format** (`--format`) - Select TSV or HDF5 format of the output file.\n\n*Source: [https://software.broadinstitute.org/gatk/documentation/tooldocs/current/org_broadinstitute_hellbender_tools_copynumber_CollectReadCounts.php](https://software.broadinstitute.org/gatk/documentation/tooldocs/current/org_broadinstitute_hellbender_tools_copynumber_CollectReadCounts.php)*\n\n### Changes Introduced by Seven Bridges\n* An additional output port called **Entity ID** is added in accordance with [CNV best practice WDL](https://github.com/gatk-workflows/gatk4-somatic-cnvs/blob/master/cnv_common_tasks.wdl) specification. This port outputs a `string` with base name of the **Input reads** file.\n* If **Output prefix** parameter is not specified, the prefix for the output file will be derived from the base name of the **Input reads** file.\n\n### Common Issues and Important Notes\n* Input parameter **Interval merging rule** must be set to `OVERLAPPING_ONLY`, otherwise the tool will produce an error.\n* The default working memory allocated for execution is 2048 (Mb) which may be insufficient for WGS samples or larger WES sample files. In this case please provide more memory through **Memory per job** input parameter. We advise allocating at least 7000 Mb (7GB) of memory in this case.\n\n### Performance Benchmarking\n\n| Input size | Experimental strategy | Duration | Cost (spot) | AWS Instance Type |\n|---|---|---|---| --- |\n| 30GB | WES | 19min | $0.08 | c4.2xlarge |\n| 70GB | WGS | 50min | $0.22 | c4.2xlarge |\n| 170GB | WGS | 2h 14min | $0.58 | c4.2xlarge |",
                "label": "GATK CollectReadCounts",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$( inputs.in_alignments ? '/opt/gatk' : 'echo /opt/gatk')"
                    },
                    {
                        "position": 1,
                        "shellQuote": false,
                        "valueFrom": "--java-options"
                    },
                    {
                        "position": 2,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.memory_per_job) {\n        return '\\\"-Xmx'.concat(inputs.memory_per_job, 'M') + '\\\"';\n    }\n    return '\\\"-Xmx2048M\\\"';\n}"
                    },
                    {
                        "position": 3,
                        "shellQuote": false,
                        "valueFrom": "CollectReadCounts"
                    },
                    {
                        "position": 4,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.in_alignments) {\n        var in_alignments_array = [].concat(inputs.in_alignments);\n        var prefix = inputs.output_prefix ? inputs.output_prefix : in_alignments_array[0].path.split('/').pop().split('.').slice(0,-1).join('.') + '.readCounts';\n        var ext = inputs.output_format ? inputs.output_format : 'hdf5';\n        return [prefix, ext].join('.');\n    }\n    return '';\n}"
                    }
                ],
                "requirements": [
                    {
                        "class": "ShellCommandRequirement"
                    },
                    {
                        "class": "ResourceRequirement",
                        "ramMin": "${  \n    var memory = 2048;\n    if (inputs.memory_per_job) {\n        memory = inputs.memory_per_job;\n    }\n    if (inputs.memory_overhead_per_job) {\n        memory += inputs.memory_overhead_per_job;\n    }\n    return memory;\n}",
                        "coresMin": "$(inputs.cpu_per_job ? inputs.cpu_per_job : 1)"
                    },
                    {
                        "class": "DockerRequirement",
                        "dockerPull": "images.sbgenomics.com/stefan_stojanovic/gatk:4.1.0.0"
                    },
                    {
                        "class": "InitialWorkDirRequirement",
                        "listing": []
                    },
                    {
                        "class": "InlineJavascriptRequirement",
                        "expressionLib": [
                            "var updateMetadata = function(file, key, value) {\n    file['metadata'][key] = value;\n    return file;\n};\n\n\nvar setMetadata = function(file, metadata) {\n    if (!('metadata' in file))\n        file['metadata'] = metadata;\n    else {\n        for (var key in metadata) {\n            file['metadata'][key] = metadata[key];\n        }\n    }\n    return file\n};\n\nvar inheritMetadata = function(o1, o2) {\n    var commonMetadata = {};\n    if (!Array.isArray(o2)) {\n        o2 = [o2]\n    }\n    for (var i = 0; i < o2.length; i++) {\n        var example = o2[i]['metadata'];\n        for (var key in example) {\n            if (i == 0)\n                commonMetadata[key] = example[key];\n            else {\n                if (!(commonMetadata[key] == example[key])) {\n                    delete commonMetadata[key]\n                }\n            }\n        }\n    }\n    if (!Array.isArray(o1)) {\n        o1 = setMetadata(o1, commonMetadata)\n    } else {\n        for (var i = 0; i < o1.length; i++) {\n            o1[i] = setMetadata(o1[i], commonMetadata)\n        }\n    }\n    return o1;\n};\n\nvar toArray = function(file) {\n    return [].concat(file);\n};\n\nvar groupBy = function(files, key) {\n    var groupedFiles = [];\n    var tempDict = {};\n    for (var i = 0; i < files.length; i++) {\n        var value = files[i]['metadata'][key];\n        if (value in tempDict)\n            tempDict[value].push(files[i]);\n        else tempDict[value] = [files[i]];\n    }\n    for (var key in tempDict) {\n        groupedFiles.push(tempDict[key]);\n    }\n    return groupedFiles;\n};\n\nvar orderBy = function(files, key, order) {\n    var compareFunction = function(a, b) {\n        if (a['metadata'][key].constructor === Number) {\n            return a['metadata'][key] - b['metadata'][key];\n        } else {\n            var nameA = a['metadata'][key].toUpperCase();\n            var nameB = b['metadata'][key].toUpperCase();\n            if (nameA < nameB) {\n                return -1;\n            }\n            if (nameA > nameB) {\n                return 1;\n            }\n            return 0;\n        }\n    };\n\n    files = files.sort(compareFunction);\n    if (order == undefined || order == \"asc\")\n        return files;\n    else\n        return files.reverse();\n};"
                        ]
                    }
                ],
                "sbg:categories": [
                    "Utilities",
                    "Coverage Analysis"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 - Demo",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1552931572,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/5"
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553105621,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/18"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553864205,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/32"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1554032599,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/35"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559581527,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/38"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559731779,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/40"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1560264039,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/41"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1575479139,
                        "sbg:revisionNotes": ""
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1575550516,
                        "sbg:revisionNotes": "Secondary files argument changed for in alignments"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1575643769,
                        "sbg:revisionNotes": "output read counts changed glob"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1575644014,
                        "sbg:revisionNotes": "glob for read counts output changed again, removed \\"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1575644227,
                        "sbg:revisionNotes": "read_counts output glob fix - only hdf5"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "uros_sipetic/gatk-4-1-0-0-demo/gatk-collectreadcounts-4-1-0-0/11",
                "sbg:revision": 11,
                "sbg:revisionNotes": "read_counts output glob fix - only hdf5",
                "sbg:modifiedOn": 1575644227,
                "sbg:modifiedBy": "milena_stanojevic",
                "sbg:createdOn": 1552931572,
                "sbg:createdBy": "uros_sipetic",
                "sbg:project": "uros_sipetic/gatk-4-1-0-0-demo",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "stefan_stojanovic",
                    "milena_stanojevic",
                    "uros_sipetic"
                ],
                "sbg:latestRevision": 11,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a6119dad2f450071878896081ba5591830b250a1123cf53b58a69cfdc8286b9c4"
            },
            "label": "GATK CollectReadCounts",
            "scatter": [
                "in_alignments"
            ],
            "sbg:x": 225,
            "sbg:y": 37.0621452331543
        },
        {
            "id": "gatk_createreadcountpanelofnormals_4_1_0_0",
            "in": [
                {
                    "id": "annotated_intervals",
                    "source": "gatk_annotateintervals_4_1_0_0/annotated_intervals"
                },
                {
                    "id": "do_impute_zeros",
                    "source": "do_impute_zeros"
                },
                {
                    "id": "extreme_outlier_truncation_percentile",
                    "source": "extreme_outlier_truncation_percentile"
                },
                {
                    "id": "extreme_sample_median_percentile",
                    "source": "extreme_sample_median_percentile"
                },
                {
                    "id": "read_counts",
                    "source": [
                        "gatk_collectreadcounts_4_1_0_0/read_counts"
                    ]
                },
                {
                    "id": "maximum_chunk_size",
                    "source": "maximum_chunk_size"
                },
                {
                    "id": "maximum_zeros_in_interval_percentage",
                    "source": "maximum_zeros_in_interval_percentage"
                },
                {
                    "id": "maximum_zeros_in_sample_percentage",
                    "source": "maximum_zeros_in_sample_percentage"
                },
                {
                    "id": "memory_per_job",
                    "default": 4000
                },
                {
                    "id": "minimum_interval_median_percentile",
                    "source": "minimum_interval_median_percentile"
                },
                {
                    "id": "number_of_eigensamples",
                    "source": "number_of_eigensamples"
                },
                {
                    "id": "output_prefix",
                    "source": "pon_entity_id"
                }
            ],
            "out": [
                {
                    "id": "panel_of_normals"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "uros_sipetic/gatk-4-1-0-0-demo/gatk-createreadcountpanelofnormals-4-1-0-0/2",
                "baseCommand": [],
                "inputs": [
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "annotated_intervals",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--annotated-intervals",
                            "shellQuote": false
                        },
                        "label": "Annotated intervals",
                        "doc": "Input file containing annotations for gc content in genomic intervals (output of annotateintervals). If provided, explicit gc correction will be performed before performing svd. Intervals must be identical to and in the same order as those in the input read-counts files.",
                        "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, BED, TSV"
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "true",
                        "id": "do_impute_zeros",
                        "type": [
                            "null",
                            {
                                "type": "enum",
                                "symbols": [
                                    "true",
                                    "false"
                                ],
                                "name": "do_impute_zeros"
                            }
                        ],
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--do-impute-zeros",
                            "shellQuote": false
                        },
                        "label": "Do impute zeros",
                        "doc": "If true, impute zero-coverage values as the median of the non-zero values in the corresponding interval. (this is applied after all filters.)."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "extreme_outlier_truncation_percentile",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--extreme-outlier-truncation-percentile",
                            "shellQuote": false
                        },
                        "label": "Extreme outlier truncation percentile",
                        "doc": "Fractional coverages normalized by genomic-interval medians that are below this percentile or above the complementary percentile are set to the corresponding percentile value. (this is applied after all filters and imputation.) 1."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "2",
                        "id": "extreme_sample_median_percentile",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--extreme-sample-median-percentile",
                            "shellQuote": false
                        },
                        "label": "Extreme sample median percentile",
                        "doc": "Samples with a median (across genomic intervals) of fractional coverage normalized by genomic-interval medians below this percentile or above the complementary percentile are filtered out. (this is the fourth filter applied.) 5."
                    },
                    {
                        "sbg:altPrefix": "-I",
                        "sbg:category": "Required Arguments",
                        "id": "read_counts",
                        "type": "File[]",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--input",
                            "shellQuote": false,
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self);\n        var paths = [];\n        for (var i=0; i<self.length; i++) {\n            paths.push(self[i].path);\n        }\n        return paths.join(' --input ');\n    }\n    return '';\n}\n"
                        },
                        "label": "Input read counts",
                        "doc": "Input tsv or hdf5 files containing integer read counts in genomic intervals for all samples in the panel of normals (output of collectreadcounts). Intervals must be identical and in the same order for all samples. This argument must be specified at least once.",
                        "sbg:fileTypes": "HDF5, TSV"
                    },
                    {
                        "sbg:category": "Advanced Arguments",
                        "sbg:toolDefaultValue": "16777215",
                        "id": "maximum_chunk_size",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--maximum-chunk-size",
                            "shellQuote": false
                        },
                        "label": "Maximum chunk size",
                        "doc": "Maximum hdf5 matrix chunk size. Large matrices written to hdf5 are chunked into equally sized subsets of rows (plus a subset containing the remainder, if necessary) to avoid a hard limit in java hdf5 on the number of elements in a matrix. However, since a single row is not allowed to be split across multiple chunks, the number of columns must be less than the maximum number of values in each chunk. Decreasing this number will reduce heap usage when writing chunks."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "5",
                        "id": "maximum_zeros_in_interval_percentage",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--maximum-zeros-in-interval-percentage",
                            "shellQuote": false
                        },
                        "label": "Maximum zeros in interval percentage",
                        "doc": "Genomic intervals with a fraction of zero-coverage samples above this percentage are filtered out. (this is the third filter applied.) 0."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "5",
                        "id": "maximum_zeros_in_sample_percentage",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--maximum-zeros-in-sample-percentage",
                            "shellQuote": false
                        },
                        "label": "Maximum zeros in sample percentage",
                        "doc": "Samples with a fraction of zero-coverage genomic intervals above this percentage are filtered out. (this is the second filter applied.) 0."
                    },
                    {
                        "sbg:category": "Execution",
                        "sbg:toolDefaultValue": "0",
                        "id": "memory_overhead_per_job",
                        "type": "int?",
                        "label": "Memory overhead per job",
                        "doc": "Memory overhead which will be allocated for one job."
                    },
                    {
                        "sbg:category": "Execution",
                        "sbg:toolDefaultValue": "2048",
                        "id": "memory_per_job",
                        "type": "int?",
                        "label": "Memory per job",
                        "doc": "Memory which will be allocated for execution."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "10",
                        "id": "minimum_interval_median_percentile",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--minimum-interval-median-percentile",
                            "shellQuote": false
                        },
                        "label": "Minimum interval median percentile",
                        "doc": "Genomic intervals with a median (across samples) of fractional coverage (optionally corrected for gc bias) less than or equal to this percentile are filtered out. (this is the first filter applied.) 0."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "20",
                        "id": "number_of_eigensamples",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-eigensamples",
                            "shellQuote": false
                        },
                        "label": "Number of eigensamples",
                        "doc": "Number of eigensamples to use for truncated svd and to store in the panel of normals. The number of samples retained after filtering will be used instead if it is smaller than this."
                    },
                    {
                        "sbg:altPrefix": "-O",
                        "sbg:category": "Required Arguments",
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Output file for the panel of normals."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "program_name",
                        "type": "string?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--program-name",
                            "shellQuote": false
                        },
                        "label": "Program name",
                        "doc": "Name of the program running."
                    },
                    {
                        "sbg:category": "Execution",
                        "sbg:toolDefaultValue": "1",
                        "id": "cpu_per_job",
                        "type": "int?",
                        "label": "CPU per job",
                        "doc": "Number of CPUs which will be allocated for the job."
                    }
                ],
                "outputs": [
                    {
                        "id": "panel_of_normals",
                        "doc": "Panel-of-normals file. This is an HDF5 file containing the panel data in the paths defined in HDF5SVDReadCountPanelOfNormals",
                        "label": "Panel of normals",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*pon.hdf5",
                            "outputEval": "$(inheritMetadata(self, inputs.read_counts))"
                        },
                        "sbg:fileTypes": "HDF5"
                    }
                ],
                "doc": "This app creates a panel of normals (PoN) for read-count denoising given the read counts for samples in the panel. \n\n\n### Common Use Cases\n\nThis app produces panel of normals file which can be used with **DenoiseReadCounts** to denoise other samples. The input read counts are first transformed to log2 fractional coverages and preprocessed according to specified filtering and imputation parameters. Singular value decomposition (SVD) is then performed to find the first number-of-eigensamples principal components, which are stored in the PoN. Some or all of these principal components can then be used for denoising case samples with **DenoiseReadCounts**; it is assumed that the principal components used represent systematic sequencing biases (rather than statistical noise). Examining the singular values, which are also stored in the PoN, may be useful in determining the appropriate number of principal components to use for denoising.\n\nIf annotated intervals are provided, explicit GC-bias correction will be performed by **GCBiasCorrector** before filtering and SVD. GC-content information for the intervals will be stored in the PoN and used to perform explicit GC-bias correction identically in **DenoiseReadCounts**. Note that if annotated intervals are not provided, it is still likely that GC-bias correction is implicitly performed by the SVD denoising process (i.e., some of the principal components arise from GC bias).\n\nNote that such SVD denoising cannot distinguish between variance due to systematic sequencing biases and that due to true common germline CNVs present in the panel; signal from the latter may thus be inadvertently denoised away. Furthermore, variance arising from coverage on the sex chromosomes may also significantly contribute to the principal components if the panel contains samples of mixed sex. Therefore, if sex chromosomes are not excluded from coverage collection, it is strongly recommended that users avoid creating panels of mixed sex and take care to denoise case samples only with panels containing only individuals of the same sex as the case samples. (See **GermlineCNVCaller**, which avoids these issues by simultaneously learning a probabilistic model for systematic bias and calling rare and common germline CNVs for samples in the panel.)\n\n*Source: [https://software.broadinstitute.org/gatk/documentation/tooldocs/current/org_broadinstitute_hellbender_tools_copynumber_CreateReadCountPanelOfNormals.php](https://software.broadinstitute.org/gatk/documentation/tooldocs/current/org_broadinstitute_hellbender_tools_copynumber_CreateReadCountPanelOfNormals.php)*\n\nSome of the input parameters are listed below:\n* **Input read counts** (`--input`)  - TSV or HDF5 files containing read count data. These files are output of **CollectReadCounts** tool.\n* **Annotated intervals** (`--annotated-intervals`) file from **AnnotateIntervals**. Explicit GC-bias correction will be performed on the panel samples and identically for subsequent case samples.\n* **Output prefix** (`--output`) - Also known as *PoN entity ID* (per [CNV best practice WDL](https://github.com/gatk-workflows/gatk4-somatic-cnvs/blob/master/cnv_somatic_panel_workflow.wdl) specification)\n\n### Changes Introduced by Seven Bridges\n* Some of the input arguments which are not applicable to this tool have been removed (`--use-jdk-deflater`, `--gcs-max-retries`, etc.)\n* Output panel of normals will be named by adding extension `.pon.hdf5` to the output prefix provided through **Output prefix** parameter. If this parameter is not set the output name will be generated by taking base name of the first read counts file and appending the extension  `.pon.hdf5` to it.\n\n### Common Issues and Important Notes\n* Default memory allocated for execution is 2048 (Mb) which may be insufficient for processing larger number of read count files. In this case please allocate more memory through **Memory per job** input parameter.\n\n### Performance Benchmarking\n\n| Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- | \n| 4x84MB | WGS | 3min | $0.02 | c4.2xlarge |\n| 8x84MB | WGS | 4min | $0.02 | c4.2xlarge |\n| 16x84MB | WGS | 5min | $0.02 | c4.2xlarge |",
                "label": "GATK CreateReadCountPanelOfNormals",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "/opt/gatk"
                    },
                    {
                        "position": 1,
                        "shellQuote": false,
                        "valueFrom": "--java-options"
                    },
                    {
                        "position": 2,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.memory_per_job) {\n        return '\\\"-Xmx'.concat(inputs.memory_per_job, 'M') + '\\\"';\n    }\n    return '\\\"-Xmx2048M\\\"';\n}"
                    },
                    {
                        "position": 3,
                        "shellQuote": false,
                        "valueFrom": "CreateReadCountPanelOfNormals"
                    },
                    {
                        "position": 5,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "${\n    var read_counts = [].concat(inputs.read_counts);\n    var prefix = inputs.output_prefix ? inputs.output_prefix : read_counts[0].path.split('/').pop().split('.').slice(0,-1).join('.');\n    return prefix + '.pon.hdf5';\n}"
                    }
                ],
                "requirements": [
                    {
                        "class": "ShellCommandRequirement"
                    },
                    {
                        "class": "ResourceRequirement",
                        "ramMin": "${  \n    var memory = 2048;\n    if (inputs.memory_per_job) {\n        memory = inputs.memory_per_job;\n    }\n    if (inputs.memory_overhead_per_job) {\n        memory += inputs.memory_overhead_per_job;\n    }\n    return memory;\n}",
                        "coresMin": "$(inputs.cpu_per_job ? inputs.cpu_per_job : 1)"
                    },
                    {
                        "class": "DockerRequirement",
                        "dockerPull": "images.sbgenomics.com/stefan_stojanovic/gatk:4.1.0.0"
                    },
                    {
                        "class": "InitialWorkDirRequirement",
                        "listing": []
                    },
                    {
                        "class": "InlineJavascriptRequirement",
                        "expressionLib": [
                            "var updateMetadata = function(file, key, value) {\n    file['metadata'][key] = value;\n    return file;\n};\n\n\nvar setMetadata = function(file, metadata) {\n    if (!('metadata' in file))\n        file['metadata'] = metadata;\n    else {\n        for (var key in metadata) {\n            file['metadata'][key] = metadata[key];\n        }\n    }\n    return file\n};\n\nvar inheritMetadata = function(o1, o2) {\n    var commonMetadata = {};\n    if (!Array.isArray(o2)) {\n        o2 = [o2]\n    }\n    for (var i = 0; i < o2.length; i++) {\n        var example = o2[i]['metadata'];\n        for (var key in example) {\n            if (i == 0)\n                commonMetadata[key] = example[key];\n            else {\n                if (!(commonMetadata[key] == example[key])) {\n                    delete commonMetadata[key]\n                }\n            }\n        }\n    }\n    if (!Array.isArray(o1)) {\n        o1 = setMetadata(o1, commonMetadata)\n    } else {\n        for (var i = 0; i < o1.length; i++) {\n            o1[i] = setMetadata(o1[i], commonMetadata)\n        }\n    }\n    return o1;\n};\n\nvar toArray = function(file) {\n    return [].concat(file);\n};\n\nvar groupBy = function(files, key) {\n    var groupedFiles = [];\n    var tempDict = {};\n    for (var i = 0; i < files.length; i++) {\n        var value = files[i]['metadata'][key];\n        if (value in tempDict)\n            tempDict[value].push(files[i]);\n        else tempDict[value] = [files[i]];\n    }\n    for (var key in tempDict) {\n        groupedFiles.push(tempDict[key]);\n    }\n    return groupedFiles;\n};\n\nvar orderBy = function(files, key, order) {\n    var compareFunction = function(a, b) {\n        if (a['metadata'][key].constructor === Number) {\n            return a['metadata'][key] - b['metadata'][key];\n        } else {\n            var nameA = a['metadata'][key].toUpperCase();\n            var nameB = b['metadata'][key].toUpperCase();\n            if (nameA < nameB) {\n                return -1;\n            }\n            if (nameA > nameB) {\n                return 1;\n            }\n            return 0;\n        }\n    };\n\n    files = files.sort(compareFunction);\n    if (order == undefined || order == \"asc\")\n        return files;\n    else\n        return files.reverse();\n};",
                            "\nvar setMetadata = function(file, metadata) {\n    if (!('metadata' in file))\n        file['metadata'] = metadata;\n    else {\n        for (var key in metadata) {\n            file['metadata'][key] = metadata[key];\n        }\n    }\n    return file\n};\n\nvar inheritMetadata = function(o1, o2) {\n    var commonMetadata = {};\n    if (!Array.isArray(o2)) {\n        o2 = [o2]\n    }\n    for (var i = 0; i < o2.length; i++) {\n        var example = o2[i]['metadata'];\n        for (var key in example) {\n            if (i == 0)\n                commonMetadata[key] = example[key];\n            else {\n                if (!(commonMetadata[key] == example[key])) {\n                    delete commonMetadata[key]\n                }\n            }\n        }\n    }\n    if (!Array.isArray(o1)) {\n        o1 = setMetadata(o1, commonMetadata)\n    } else {\n        for (var i = 0; i < o1.length; i++) {\n            o1[i] = setMetadata(o1[i], commonMetadata)\n        }\n    }\n    return o1;\n};"
                        ]
                    }
                ],
                "sbg:categories": [
                    "Genomics",
                    "Copy Number Variant Calling"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 - Demo",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553104145,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-createreadcountpanelofnormals-4-1-0-0/9"
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553864213,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-createreadcountpanelofnormals-4-1-0-0/18"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559645270,
                        "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-createreadcountpanelofnormals-4-1-0-0/19"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "uros_sipetic/gatk-4-1-0-0-demo/gatk-createreadcountpanelofnormals-4-1-0-0/2",
                "sbg:revision": 2,
                "sbg:revisionNotes": "Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-createreadcountpanelofnormals-4-1-0-0/19",
                "sbg:modifiedOn": 1559645270,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1553104145,
                "sbg:createdBy": "uros_sipetic",
                "sbg:project": "uros_sipetic/gatk-4-1-0-0-demo",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 2,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a8fa1402a4f277d183dc881323c7d175a62dc05bae4186725747f3ec9aecfb8b2",
                "sbg:copyOf": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-createreadcountpanelofnormals-4-1-0-0/19"
            },
            "label": "GATK CreateReadCountPanelOfNormals",
            "sbg:x": 549,
            "sbg:y": 34.35028076171875
        }
    ],
    "hints": [
        {
            "class": "sbg:AWSInstanceType",
            "value": "c4.4xlarge;ebs-gp2;2000"
        },
        {
            "class": "sbg:GoogleInstanceType",
            "value": "n1-standard-16;pd-ssd;2000"
        }
    ],
    "requirements": [
        {
            "class": "StepInputExpressionRequirement"
        },
        {
            "class": "InlineJavascriptRequirement"
        },
        {
            "class": "ScatterFeatureRequirement"
        }
    ],
    "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
    "sbg:revisionsInfo": [
        {
            "sbg:revision": 0,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551193788,
            "sbg:revisionNotes": null
        },
        {
            "sbg:revision": 1,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551193810,
            "sbg:revisionNotes": "init"
        },
        {
            "sbg:revision": 2,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551194117,
            "sbg:revisionNotes": "replace apps with apps from current project"
        },
        {
            "sbg:revision": 3,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551194192,
            "sbg:revisionNotes": "change toolkit version for preprocess intervals"
        },
        {
            "sbg:revision": 4,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551194495,
            "sbg:revisionNotes": "replace preprocessIntevals app from current project"
        },
        {
            "sbg:revision": 5,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551194544,
            "sbg:revisionNotes": "update preprocessIntervals, no real change, testing"
        },
        {
            "sbg:revision": 6,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551194695,
            "sbg:revisionNotes": "replace collectReadCounts from current project; rename input ports"
        },
        {
            "sbg:revision": 7,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551194758,
            "sbg:revisionNotes": "set input_alignments to array of files, scatter collectReadCounts in --input"
        },
        {
            "sbg:revision": 8,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551194836,
            "sbg:revisionNotes": "replace AnnotateIntervals from current project, expose inputs and parameters"
        },
        {
            "sbg:revision": 9,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551194997,
            "sbg:revisionNotes": "replace createReadCountPanelOfNormals from current project, expose input parameters"
        },
        {
            "sbg:revision": 10,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551195042,
            "sbg:revisionNotes": "AnnotateIntervals: set int_merging_rule to overlapping_only"
        },
        {
            "sbg:revision": 11,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551195110,
            "sbg:revisionNotes": "CollectReadCounts: expose format"
        },
        {
            "sbg:revision": 12,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551195408,
            "sbg:revisionNotes": "set pon_entity_id port to required"
        },
        {
            "sbg:revision": 13,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551195996,
            "sbg:revisionNotes": "expose counts and intervals output ports"
        },
        {
            "sbg:revision": 14,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551198490,
            "sbg:revisionNotes": "add description"
        },
        {
            "sbg:revision": 15,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551200618,
            "sbg:revisionNotes": "add common use case description from gatk tutorial, add reference"
        },
        {
            "sbg:revision": 16,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551200817,
            "sbg:revisionNotes": "changes by seven bridges tbd, so far none;"
        },
        {
            "sbg:revision": 17,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551201020,
            "sbg:revisionNotes": "CollectReadCounts: set default memory to 7000 mb, per best practice wdl"
        },
        {
            "sbg:revision": 18,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551201123,
            "sbg:revisionNotes": "CreateReadCountPON: set default memory to 7000 mb, per best practice wdl; remove default memory overhead;"
        },
        {
            "sbg:revision": 19,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551202521,
            "sbg:revisionNotes": "PreprocessIntervals: set --intervals to single file instead of array of files, per best practice wdl; add argument for default --output naming"
        },
        {
            "sbg:revision": 20,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551202975,
            "sbg:revisionNotes": "PreprocessIntervals: fix glob expression"
        },
        {
            "sbg:revision": 21,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551203345,
            "sbg:revisionNotes": "PreprocessIntervals: remove cwl default value for output argument"
        },
        {
            "sbg:revision": 22,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551203913,
            "sbg:revisionNotes": "set required inputs to required"
        },
        {
            "sbg:revision": 23,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551204015,
            "sbg:revisionNotes": "set intervals to single file instead of array of files"
        },
        {
            "sbg:revision": 24,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551204097,
            "sbg:revisionNotes": "change labels for inputs and outputs"
        },
        {
            "sbg:revision": 25,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551268343,
            "sbg:revisionNotes": "set instance hints: c4.4xlarge and max num parallel instances to 5"
        },
        {
            "sbg:revision": 26,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551268987,
            "sbg:revisionNotes": "add 2tb elastic storage hint"
        },
        {
            "sbg:revision": 27,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551275619,
            "sbg:revisionNotes": "CollectReadCounts: default memory set to 2048m"
        },
        {
            "sbg:revision": 28,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551275721,
            "sbg:revisionNotes": "set memory_per_job to 7000 for CollectReadCounts and CreateReadCountPON"
        },
        {
            "sbg:revision": 29,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551284995,
            "sbg:revisionNotes": "edit description: add benchmarking info"
        },
        {
            "sbg:revision": 30,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552494884,
            "sbg:revisionNotes": "add python api snippet"
        },
        {
            "sbg:revision": 31,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552495576,
            "sbg:revisionNotes": "edit description"
        },
        {
            "sbg:revision": 32,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552496993,
            "sbg:revisionNotes": "fix output labels; add descriptions for input files"
        },
        {
            "sbg:revision": 33,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552652781,
            "sbg:revisionNotes": "PreprocessIntervals: --intervals argument accepts array of files instead of single file"
        },
        {
            "sbg:revision": 34,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552654636,
            "sbg:revisionNotes": "re-expose intervals port, set to single file"
        },
        {
            "sbg:revision": 35,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552655284,
            "sbg:revisionNotes": "set Intervals input port to array of files"
        },
        {
            "sbg:revision": 36,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552656157,
            "sbg:revisionNotes": "update PreprocessIntervals app (now with full descriptio); add note to \"changes introduced by sbg\" regarding array of interval files"
        },
        {
            "sbg:revision": 37,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552658936,
            "sbg:revisionNotes": "PreprocessIntervals: for --intervals input files, cast self to array before iterating; set Intervals port to accept single file, per wdl spec"
        },
        {
            "sbg:revision": 38,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552659916,
            "sbg:revisionNotes": "preprocessIntervals accepts single file once again; description edited accordingly"
        },
        {
            "sbg:revision": 39,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552660130,
            "sbg:revisionNotes": "AnnotateIntervals: --intervals argument accepts array of files; expression set to cast to array before iterating over interval files"
        },
        {
            "sbg:revision": 40,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552662804,
            "sbg:revisionNotes": "AnnotateIntervals: set --intervals to array of files"
        },
        {
            "sbg:revision": 41,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552663458,
            "sbg:revisionNotes": "CollectReadCounts: allow multiple intervals files"
        },
        {
            "sbg:revision": 42,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552664828,
            "sbg:revisionNotes": "edit output labels and ids"
        },
        {
            "sbg:revision": 43,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552665677,
            "sbg:revisionNotes": "CreateReadCountPON: set default memory on tool level to 2048; On wf level memory is 7000"
        },
        {
            "sbg:revision": 44,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552666822,
            "sbg:revisionNotes": "CreateReadCountPanelOfNormals: add description"
        },
        {
            "sbg:revision": 45,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552666838,
            "sbg:revisionNotes": "update label for PON"
        },
        {
            "sbg:revision": 46,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553121401,
            "sbg:revisionNotes": "fix description, fix references and reference links"
        },
        {
            "sbg:revision": 47,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553121964,
            "sbg:revisionNotes": "edit input labels in description, fix formatting, add more info"
        },
        {
            "sbg:revision": 48,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553122620,
            "sbg:revisionNotes": "update apps, reconnect ports"
        },
        {
            "sbg:revision": 49,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553125374,
            "sbg:revisionNotes": "edit input and output labels and descriptions"
        },
        {
            "sbg:revision": 50,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553125623,
            "sbg:revisionNotes": "expose pon entity id input parameter as port, set as required; set other input parameters to required according to best practice wdl"
        },
        {
            "sbg:revision": 51,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553126310,
            "sbg:revisionNotes": "update PreprocessIntervals: fix output prefix expression to allow for single file interval input"
        },
        {
            "sbg:revision": 52,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553127178,
            "sbg:revisionNotes": "update annotateIntervals and createPON, fixed output prefix expression"
        },
        {
            "sbg:revision": 53,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553165919,
            "sbg:revisionNotes": "update AnnotateIntervals and CreatePON: change output format for annotated intervals to TSV"
        },
        {
            "sbg:revision": 54,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553166457,
            "sbg:revisionNotes": "edit labels and descriptions for output pon and preprocessed intervals"
        },
        {
            "sbg:revision": 55,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553166808,
            "sbg:revisionNotes": "edit api python implementation example to reflect changes in input ids"
        },
        {
            "sbg:revision": 56,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553781665,
            "sbg:revisionNotes": "update apps"
        },
        {
            "sbg:revision": 57,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553790351,
            "sbg:revisionNotes": "add coverage column to benchmarking table; add categories"
        },
        {
            "sbg:revision": 58,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553790822,
            "sbg:revisionNotes": "edit common use cases, per review notes"
        },
        {
            "sbg:revision": 59,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553791023,
            "sbg:revisionNotes": "edit references section per review notes"
        },
        {
            "sbg:revision": 60,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553791548,
            "sbg:revisionNotes": "remove parallel instances hint"
        },
        {
            "sbg:revision": 61,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553812408,
            "sbg:revisionNotes": "CollectReadCounts: set in_alignments (--input) parameter to required"
        },
        {
            "sbg:revision": 62,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553812700,
            "sbg:revisionNotes": "update benchmarking info"
        },
        {
            "sbg:revision": 63,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553812749,
            "sbg:revisionNotes": "fix typo in benchmarking table"
        },
        {
            "sbg:revision": 64,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553860615,
            "sbg:revisionNotes": "update CollectReadCounts, fix secondary file requirements; expose disable_default_read_filtering"
        },
        {
            "sbg:revision": 65,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553863266,
            "sbg:revisionNotes": "add secondary file requirement for reference on wf level"
        },
        {
            "sbg:revision": 66,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553863952,
            "sbg:revisionNotes": "Revert to revision 63; Update CollectReadCounts: add secondary file requirements for in_alignments"
        },
        {
            "sbg:revision": 67,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553871765,
            "sbg:revisionNotes": "add secondary files for reference input"
        },
        {
            "sbg:revision": 68,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553945719,
            "sbg:revisionNotes": "CollectReadCounts: expose format and disable_tool_default_read_filters"
        },
        {
            "sbg:revision": 69,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553948178,
            "sbg:revisionNotes": "CollectReadCounts: change back choices for output_format to uppercase; fix glob expressions to catch uppercase extensions"
        },
        {
            "sbg:revision": 70,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553948239,
            "sbg:revisionNotes": "CollectReadCounts: scatter dot product"
        },
        {
            "sbg:revision": 71,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553949809,
            "sbg:revisionNotes": "minor fixes in description"
        },
        {
            "sbg:revision": 72,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1554027257,
            "sbg:revisionNotes": "add coverage info to benchmarking table"
        },
        {
            "sbg:revision": 73,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1559646754,
            "sbg:revisionNotes": "update apps"
        },
        {
            "sbg:revision": 74,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1559731160,
            "sbg:revisionNotes": "update CollectReadCounts: fix entity_id output eval expression, allow for zero length in_alignments case, in case of conditional execution"
        },
        {
            "sbg:revision": 75,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1575040932,
            "sbg:revisionNotes": "Validation CWL"
        },
        {
            "sbg:revision": 76,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1575043647,
            "sbg:revisionNotes": "Validation Update 1"
        },
        {
            "sbg:revision": 77,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1575043689,
            "sbg:revisionNotes": "Read_counts output changed from file to array"
        },
        {
            "sbg:revision": 78,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1575044096,
            "sbg:revisionNotes": "Entry_ID port -> allow array as well as single file"
        },
        {
            "sbg:revision": 79,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1575306370,
            "sbg:revisionNotes": "Secondary files requirement add/ InlineJavascriptRequirement add"
        },
        {
            "sbg:revision": 80,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1575306889,
            "sbg:revisionNotes": "Secondary files argument fixed"
        },
        {
            "sbg:revision": 81,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1575478051,
            "sbg:revisionNotes": ""
        },
        {
            "sbg:revision": 82,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1575479175,
            "sbg:revisionNotes": "updated CollectReadCounts (secondaryFiles)"
        },
        {
            "sbg:revision": 83,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1575542787,
            "sbg:revisionNotes": "Secondary files for input reads set to ^.bai"
        },
        {
            "sbg:revision": 84,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1575549453,
            "sbg:revisionNotes": "Updated secondary files for input read as .bai"
        },
        {
            "sbg:revision": 85,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1575557665,
            "sbg:revisionNotes": "CollectReadCounts tool update(secondary files for in_alignment input fix) + InlineJavascriptRequirement fix"
        },
        {
            "sbg:revision": 86,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1575558003,
            "sbg:revisionNotes": "CollectReadCounts tool update again + InlineJavascriptReq. fix"
        },
        {
            "sbg:revision": 87,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1575907854,
            "sbg:revisionNotes": "CollectReadCounts tool update to *hdf5"
        },
        {
            "sbg:revision": 88,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1576083799,
            "sbg:revisionNotes": "Memory per job - 4000 CreateReadCountsPanelOfNormal"
        },
        {
            "sbg:revision": 89,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1576083884,
            "sbg:revisionNotes": "InlineJavascript requirement add"
        }
    ],
    "sbg:image_url": "https://igor.sbgenomics.com/ns/brood/images/veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-somatic-panel-workflow/89.png",
    "sbg:categories": [
        "Genomics",
        "Copy Number Variant Calling",
        "CWL1.0"
    ],
    "sbg:appVersion": [
        "v1.0"
    ],
    "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-somatic-panel-workflow/89",
    "sbg:revision": 89,
    "sbg:revisionNotes": "InlineJavascript requirement add",
    "sbg:modifiedOn": 1576083884,
    "sbg:modifiedBy": "milena_stanojevic",
    "sbg:createdOn": 1551193788,
    "sbg:createdBy": "stefan_stojanovic",
    "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
    "sbg:sbgMaintained": false,
    "sbg:validationErrors": [],
    "sbg:contributors": [
        "milena_stanojevic",
        "stefan_stojanovic"
    ],
    "sbg:latestRevision": 89,
    "sbg:publisher": "sbg",
    "sbg:content_hash": "a1108909a9132edcacc628ae10cb26f6beaed371bf2bf1bafb92b1cccb7f8bd0d"
}