{
    "class": "Workflow",
    "cwlVersion": "v1.0",
    "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-cnv-somatic-pair-workflow/71",
    "doc": "GATK CNV Somatic Pair workflow is used for detecting copy number variants (CNVs) as well as allelic segments in a single sample.\n\n### Common Use Cases\n\nThe workflow denoises case sample alignment data against a panel of normals (PON), created by **GATK CNV Panel Workflow**, to obtain copy ratios and models segments from the copy ratios and allelic counts. The latter modeling incorporates data from a matched control sample. The same workflow steps apply to targeted exome and whole genome sequencing data [1].\n\nThe basis of copy number variant detection is formed by collecting coverage counts, while the resolution of the analysis is defined by the genomic intervals list. In the case of whole genome data, the reference genome is divided into equally sized intervals or bins, while for exome data, the target regions of the capture kit should be padded. In either case **PreprocessIntervals** tool is used for preparing the intervals list which is then used for collecting the raw integer counts. For this step **CollectReadCounts** tool is utilized, which counts reads that overlap the interval. Read counts are standardized and denoised against the PON with **DenoiseReadCounts** tool. Standardized and denoised copy ratios are plotted with **PlotDenoisedCopyRatios** tool [2].\n\nNext step in the workflow is segmentation, performed by **ModelSegments** tool [3]. In segmentation, contiguous copy ratios are grouped together into segments. The tool performs segmentation for both copy ratios and for allelic copy ratios, given allelic counts. **CollectAllelicCounts** tool will tabulate counts of the reference allele and counts of the dominant alternate allele for each site in a given genomic intervals list (**Common sites**). Modeled copy ratio and allelic fraction segments are plotted with **PlotModeledSegments** tool.\n\n**CallCopyRatioSegments** tool allows for systematic calling of copy-neutral, amplified and deleted segments. The parameters **Neutral segment copy ratio lower bound** (default 0.9) and **Neutral segment copy ratio upper bound** (default 1.1) together set the copy ratio range for copy-neutral segments [4].\n\nSome of the common input parameters are listed below:\n* **Input reads - tumor** - Tumor BAM/SAM/CRAM file. In case of BAM and CRAM formats index files BAI and CRAI are required.\n* **Input reads - normal** - Matched normal BAM/SAM/CRAM file. In case of BAM and CRAM formats index files BAI and CRAI are required.\n* **Panel of normals** - CNV panel of normals (PON) file in HDF5 format.\n* **Reference** - Reference genome in FASTA format along with FAI and DICT secondary files.\n* **Intervals** - Required for both WGS and WES cases. Accepted formats must be compatible with the GATK `-L` argument. For WGS, the intervals should simply cover the autosomal chromosomes (sex chromosomes may be included, but care should be taken to avoid creating panels of mixed sex, and to denoise case samples only with panels containing only individuals of the same sex as the case samples) [5].\n* **Bin length** - This argument is used by **PreprocessIntervals** tool and must be set to the same value that was used to create PON file. If intervals in PON do not match exactly with the ones used to collect read counts for case sample, the workflow will produce an error. For WES analysis this parameter should be set to 0.\n* **Common sites** - Sites at which allelic counts will be collected, used in **CollectAllelicCounts** tool. File must be compatible with GATK -L argument. This is usually dbsnp VCF or Mills gold standard (SNPs only) VCF file. In case of WES analysis we advise using subset of this file with variants contained in target intervals. This would reduce execution time of **CollectAllelicCounts** tool and would require less resources (see *Common Issues and Important Notes*).\n\n### Changes Introduced by Seven Bridges\n* Outputs of several tools in the workflow are grouped together using **SBG Group Outputs** tool. This does not affect the contents of the files nor execution performance, it is introduced with the purpose of keeping output files neatly organized.\n\n### Common Issues and Important Notes\n* For WGS and some cases of WES samples **CollectAllelicCounts** will require more memory than the default 13000 MB. If the entire set of variants from dbsnp is used as input for this tool we advise allocating at least 100000 MB (100GB) of memory through **Memory per job** parameter.\n* For WGS analysis **ModelSegments** may require more memory than the default 13000 MB. We advise allocating at least 32000 MB (32GB) of memory through **Memory per job** parameter.\n\n### Performance Benchmarking\n| Input Size | Experimental Strategy | Coverage | Duration | Cost (on demand) |\n| --- | --- | --- | --- | --- | --- |\n| 2 x 45GB | WGS | 8x | 1h 34min | $3.27 | \n| 2 x 120GB | WGS | 25x | 3h 23min | $7.08 |\n| 2 x 210GB | WGS | 40x | 4h 57min | $10.56 |\n| 2 x 420GB | WGS | 80x | 8h 58min | $19.96 |\n\n\n### API Python Implementation\nThe app's draft task can also be submitted via the **API**. In order to learn how to get your **Authentication token** and **API endpoint** for corresponding platform visit our [documentation](https://github.com/sbg/sevenbridges-python#authentication-and-configuration).\n\n```python\n# Initialize the SBG Python API\nfrom sevenbridges import Api\napi = Api(token=\"enter_your_token\", url=\"enter_api_endpoint\")\n# Get project_id/app_id from your address bar. Example: https://igor.sbgenomics.com/u/your_username/project/app\nproject_id = \"your_username/project\"\napp_id = \"your_username/project/app\"\n# Replace inputs with appropriate values\ninputs = {\n\t\"intervals\": api.files.query(project=project_id, names=[\"enter_filename\"])[0], \n\t\"reference\": api.files.query(project=project_id, names=[\"enter_filename\"])[0], \n\t\"sequence_dictionary\": api.files.query(project=project_id, names=[\"enter_filename\"])[0], \n\t\"input_alignments_tumor\": api.files.query(project=project_id, names=[\"enter_filename\"])[0], \n\t\"common_sites\": api.files.query(project=project_id, names=[\"enter_filename\"])[0], \n\t\"count_panel_of_normals\": api.files.query(project=project_id, names=[\"enter_filename\"])[0]}\n# Creates draft task\ntask = api.tasks.create(name=\"GATK CNV Somatic Pair Workflow - API Run\", project=project_id, app=app_id, inputs=inputs, run=False)\n```\n\nInstructions for installing and configuring the API Python client, are provided on [github](https://github.com/sbg/sevenbridges-python#installation). For more information about using the API Python client, consult [the client documentation](http://sevenbridges-python.readthedocs.io/en/latest/). **More examples** are available [here](https://github.com/sbg/okAPI).\n\nAdditionally, [API R](https://github.com/sbg/sevenbridges-r) and [API Java](https://github.com/sbg/sevenbridges-java) clients are available. To learn more about using these API clients please refer to the [API R client documentation](https://sbg.github.io/sevenbridges-r/), and [API Java client documentation](https://docs.sevenbridges.com/docs/java-library-quickstart).\n\n\n### References\n* [1] [https://github.com/gatk-workflows/gatk4-somatic-cnvs/blob/master/cnv_somatic_pair_workflow.wdl](https://github.com/gatk-workflows/gatk4-somatic-cnvs/blob/master/cnv_somatic_pair_workflow.wdl)\n* [2] [https://gatkforums.broadinstitute.org/dsde/discussion/11682](https://gatkforums.broadinstitute.org/dsde/discussion/11682)\n* [3] [https://gatkforums.broadinstitute.org/dsde/discussion/11683#6](https://gatkforums.broadinstitute.org/dsde/discussion/11683#6)\n* [4] [https://gatkforums.broadinstitute.org/dsde/discussion/11683#6](https://gatkforums.broadinstitute.org/dsde/discussion/11683#6)\n* [5] [https://gatkforums.broadinstitute.org/gatk/discussion/11009/intervals-and-interval-lists](https://gatkforums.broadinstitute.org/gatk/discussion/11009/intervals-and-interval-lists)",
    "label": "GATK CNV Somatic Pair Workflow",
    "$namespaces": {
        "sbg": "https://sevenbridges.com"
    },
    "inputs": [
        {
            "id": "exclude_intervals",
            "type": "File?",
            "label": "Blacklisted intervals",
            "doc": "Genomic intervals to exclude from processing.",
            "sbg:x": -766.8736572265625,
            "sbg:y": 262.8729553222656
        },
        {
            "id": "intervals",
            "type": "File",
            "label": "Intervals",
            "doc": "Genomic intervals over which to operate.",
            "sbg:x": -761.341552734375,
            "sbg:y": 104.20606994628906
        },
        {
            "id": "sequence_dictionary",
            "sbg:fileTypes": "DICT",
            "type": "File",
            "label": "Sequence dictionary",
            "doc": "Use the given sequence dictionary as the master/canonical sequence dictionary. Must be a .dict file.",
            "sbg:x": -760.271240234375,
            "sbg:y": -52.12045669555664
        },
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
            "id": "minimum_base_quality",
            "type": "int?",
            "label": "Minimum base quality",
            "doc": "Base calls with lower quality will be filtered out of pileups.",
            "sbg:x": -410.5151672363281,
            "sbg:y": -428.8094482421875
        },
        {
            "id": "number_of_eigensamples",
            "type": "int?",
            "label": "Number of eigensamples",
            "doc": "Number of eigensamples to use for denoising. If not specified or if the number of eigensamples available in the panel of normals is smaller than this, all eigensamples will be used.",
            "sbg:x": 89.68384552001953,
            "sbg:y": 536.1905517578125
        },
        {
            "id": "count_panel_of_normals",
            "sbg:fileTypes": "HDF5",
            "type": "File",
            "label": "Count panel of normals",
            "doc": "Input hdf5 file containing the panel of normals (output of createreadcountpanelofnormals).",
            "sbg:x": 90.80239868164062,
            "sbg:y": 662.96044921875
        },
        {
            "id": "minimum_contig_length",
            "type": "int?",
            "label": "Minimum contig length",
            "doc": "Threshold length (in bp) for contigs to be plotted. Contigs with lengths less than this threshold will not be plotted. This can be used to filter out mitochondrial contigs, unlocalized contigs, etc.",
            "sbg:x": 587.72412109375,
            "sbg:y": 576.8390502929688
        },
        {
            "id": "window_size",
            "type": "int[]?",
            "label": "Window size",
            "doc": "Window sizes to use for calculating local changepoint costs. For each window size, the cost for each data point to be a changepoint will be calculated assuming that the point demarcates two adjacent segments of that size. Including small (large) window sizes will increase sensitivity to small (large) events. Duplicate values will be ignored. Default value:.",
            "sbg:x": 293.54693603515625,
            "sbg:y": -1370.39599609375
        },
        {
            "id": "smoothing_credible_interval_threshold_copy_ratio",
            "type": "float?",
            "label": "Smoothing credible interval threshold copy ratio",
            "doc": "Number of 10.",
            "sbg:x": 197.48780822753906,
            "sbg:y": -1285.74755859375
        },
        {
            "id": "smoothing_credible_interval_threshold_allele_fraction",
            "type": "float?",
            "label": "Smoothing credible interval threshold allele fraction",
            "doc": "Number of 10.",
            "sbg:x": 141.62152099609375,
            "sbg:y": -1200.6685791015625
        },
        {
            "id": "number_of_smoothing_iterations_per_fit",
            "type": "int?",
            "label": "Number of smoothing iterations per fit",
            "doc": "Number of segmentation-smoothing iterations per mcmc model refit. (increasing this will decrease runtime, but the final number of segments may be higher. Setting this to 0 will completely disable model refitting between iterations.).",
            "sbg:x": 71.42814636230469,
            "sbg:y": -1113.1690673828125
        },
        {
            "id": "number_of_samples_copy_ratio",
            "type": "int?",
            "label": "Number of samples copy ratio",
            "doc": "Total number of mcmc samples for copy-ratio model.",
            "sbg:x": 0.8780487775802612,
            "sbg:y": -1017.8292846679688
        },
        {
            "id": "number_of_samples_allele_fraction",
            "type": "int?",
            "label": "Number of samples allele fraction",
            "doc": "Total number of mcmc samples for allele-fraction model.",
            "sbg:x": -23.829267501831055,
            "sbg:y": -917.8414916992188
        },
        {
            "id": "number_of_changepoints_penalty_factor",
            "type": "float?",
            "label": "Number of changepoints penalty factor",
            "doc": "Factor a for the penalty on the number of changepoints per chromosome for segmentation. Adds a penalty of the form a.",
            "sbg:x": -61.646339416503906,
            "sbg:y": -813.9512329101562
        },
        {
            "id": "number_of_burn_in_samples_copy_ratio",
            "type": "int?",
            "label": "Number of burn in samples copy ratio",
            "doc": "Number of burn-in samples to discard for copy-ratio model.",
            "sbg:x": -96.95121765136719,
            "sbg:y": -699.4390258789062
        },
        {
            "id": "number_of_burn_in_samples_allele_fraction",
            "type": "int?",
            "label": "Number of burn in samples allele fraction",
            "doc": "Number of burn-in samples to discard for allele-fraction model.",
            "sbg:x": 453.03509521484375,
            "sbg:y": -1308.385986328125
        },
        {
            "id": "minor_allele_fraction_prior_alpha",
            "type": "float?",
            "label": "Minor allele fraction prior alpha",
            "doc": "Alpha hyperparameter for the 4-parameter beta-distribution prior on segment minor-allele fraction. The prior for the minor-allele fraction f in each segment is assumed to be beta(alpha, 1, 0, 1/2). Increasing this hyperparameter will reduce the effect of reference bias at the expense of sensitivity. 0.",
            "sbg:x": 378.6219787597656,
            "sbg:y": -1192.1463623046875
        },
        {
            "id": "minimum_total_allele_count_normal",
            "type": "int?",
            "label": "Minimum total allele count normal",
            "doc": "Minimum total count for filtering allelic counts in matched-normal sample, if available.",
            "sbg:x": 317.31707763671875,
            "sbg:y": -1067.280517578125
        },
        {
            "id": "minimum_total_allele_count_case",
            "type": "int?",
            "label": "Minimum total allele count case",
            "doc": "Minimum total count for filtering allelic counts in the case sample, if available.  The default value of zero is appropriate for matched-normal mode; increase to an appropriate value for case-only mode.  Default value: 0.",
            "sbg:x": 236.73170471191406,
            "sbg:y": -957.231689453125
        },
        {
            "id": "maximum_number_of_smoothing_iterations",
            "type": "int?",
            "label": "Maximum number of smoothing iterations",
            "doc": "Maximum number of iterations allowed for segmentation smoothing.",
            "sbg:x": 204.80487060546875,
            "sbg:y": -844.7073364257812
        },
        {
            "id": "maximum_number_of_segments_per_chromosome",
            "type": "int?",
            "label": "Maximum number of segments per chromosome",
            "doc": "Maximum number of segments allowed per chromosome.",
            "sbg:x": 168.3902587890625,
            "sbg:y": -731.9024047851562
        },
        {
            "id": "kernel_variance_copy_ratio",
            "type": "float?",
            "label": "Kernel variance copy ratio",
            "doc": "Variance of gaussian kernel for copy-ratio segmentation, if performed. If zero, a linear kernel will be used. 0.",
            "sbg:x": 128.31707763671875,
            "sbg:y": -606.276123046875
        },
        {
            "id": "kernel_variance_allele_fraction",
            "type": "float?",
            "label": "Kernel variance allele fraction",
            "doc": "Variance of gaussian kernel for allele-fraction segmentation, if performed. If zero, a linear kernel will be used. 025.",
            "sbg:x": 615.0853881835938,
            "sbg:y": -1178.48779296875
        },
        {
            "id": "kernel_scaling_allele_fraction",
            "type": "float?",
            "label": "Kernel scaling allele fraction",
            "doc": "Relative scaling s of the kernel k_af for allele-fraction segmentation to the kernel k_cr for copy-ratio segmentation. If multidimensional segmentation is performed, the total kernel used will be k_cr.",
            "sbg:x": 540.5609741210938,
            "sbg:y": -1054.8780517578125
        },
        {
            "id": "kernel_approximation_dimension",
            "type": "int?",
            "label": "Kernel approximation dimension",
            "doc": "Dimension of the kernel approximation. A subsample containing this number of data points will be used to construct the approximation for each chromosome. If the total number of data points in a chromosome is greater than this number, then all data points in the chromosome will be used. Time complexity scales quadratically and space complexity scales linearly with this parameter.",
            "sbg:x": 479.1707458496094,
            "sbg:y": -934.243896484375
        },
        {
            "id": "genotyping_homozygous_log_ratio_threshold",
            "type": "float?",
            "label": "Genotyping homozygous log ratio threshold",
            "doc": "Log-ratio threshold for genotyping and filtering homozygous allelic counts, if available. Increasing this value will increase the number of sites assumed to be heterozygous for modeling. 0.",
            "sbg:x": 435.56097412109375,
            "sbg:y": -816.8170776367188
        },
        {
            "id": "genotyping_base_error_rate",
            "type": "float?",
            "label": "Genotyping base error rate",
            "doc": "Maximum base-error rate for genotyping and filtering homozygous allelic counts, if available. The likelihood for an allelic count to be generated from a homozygous site will be integrated from zero base-error rate up to this value. Decreasing this value will increase the number of sites assumed to be heterozygous for modeling. 05.",
            "sbg:x": 395.6463317871094,
            "sbg:y": -681.1951293945312
        },
        {
            "id": "outlier_neutral_segment_copy_ratio_z_score_threshold",
            "type": "float?",
            "label": "Outlier neutral segment copy ratio Z score threshold",
            "doc": "Threshold on z-score of non-log2 copy ratio used for determining outlier copy-neutral segments. If non-log2 copy ratio z-score is above this threshold for a copy-neutral segment, it is considered an outlier and not used in the calculation of the length-weighted mean and standard deviation used for calling. 0.",
            "sbg:x": 1348.603759765625,
            "sbg:y": 468
        },
        {
            "id": "neutral_segment_copy_ratio_upper_bound",
            "type": "float?",
            "label": "Neutral segment copy ratio upper bound",
            "doc": "Upper bound on non-log2 copy ratio used for determining copy-neutral segments.",
            "sbg:x": 1361.097900390625,
            "sbg:y": 601.6483764648438
        },
        {
            "id": "neutral_segment_copy_ratio_lower_bound",
            "type": "float?",
            "label": "Neutral segment copy ratio lower bound",
            "doc": "Lower bound on non-log2 copy ratio used for determining copy-neutral segments.",
            "sbg:x": 1419.526611328125,
            "sbg:y": 731
        },
        {
            "id": "calling_copy_ratio_z_score_threshold",
            "type": "float?",
            "label": "Calling copy ratio Z score threshold",
            "doc": "Threshold on z-score of non-log2 copy ratio used for calling segments. 0.",
            "sbg:x": 1469.4390869140625,
            "sbg:y": 855.593505859375
        },
        {
            "id": "run_oncotator",
            "type": "boolean?",
            "sbg:exposed": true
        },
        {
            "id": "memory_collectalleliccounts",
            "type": "int?",
            "label": "Momory per job - CollectAllelicCounts",
            "doc": "Default 13000",
            "sbg:x": -402.5231018066406,
            "sbg:y": -558
        },
        {
            "id": "memory_modelsegments",
            "type": "int?",
            "label": "Memory per job - ModelSegments",
            "sbg:x": 692.1048583984375,
            "sbg:y": -1294.2493896484375
        },
        {
            "id": "in_reference",
            "sbg:fileTypes": "FASTA, FA",
            "type": "File",
            "secondaryFiles": [
                ".fai",
                "^.dict"
            ],
            "sbg:x": -760.6112060546875,
            "sbg:y": -202.26959228515625
        },
        {
            "id": "common_sites",
            "sbg:fileTypes": "VCF, BED, INTERVALS, INTERVAL_LIST",
            "type": "File",
            "sbg:x": -410.6506652832031,
            "sbg:y": -301.02398681640625
        },
        {
            "id": "in_alignments_tumor",
            "sbg:fileTypes": "BAM, SAM, CRAM",
            "type": "File",
            "secondaryFiles": [
                ".bai"
            ],
            "sbg:x": -379.5942077636719,
            "sbg:y": 388.74725341796875
        },
        {
            "id": "in_alignments_normal",
            "sbg:fileTypes": "BAM, SAM, CRAM",
            "type": "File?",
            "secondaryFiles": [
                ".bai"
            ],
            "sbg:x": -379.3818664550781,
            "sbg:y": 551
        }
    ],
    "outputs": [
        {
            "id": "out_tumor",
            "outputSource": [
                "sbg_group_outputs_tumor/out_array"
            ],
            "sbg:fileTypes": "TXT, TSV, SEG, PNG, HDF5, PARAM",
            "type": "File[]",
            "sbg:x": 2996.448486328125,
            "sbg:y": -599.614990234375
        },
        {
            "id": "out_normal",
            "outputSource": [
                "sbg_group_outputs_normal/out_array"
            ],
            "sbg:fileTypes": "TXT, TSV, SEG, PNG, HDF5, PARAM",
            "type": "File[]",
            "sbg:x": 2995.782958984375,
            "sbg:y": -396.1174011230469
        },
        {
            "id": "out_oncotator",
            "outputSource": [
                "sbg_group_outputs_oncotator/out_array"
            ],
            "sbg:fileTypes": "TXT, TSV, SEG, PNG, HDF5, PARAM",
            "type": "File[]",
            "sbg:x": 3161.982177734375,
            "sbg:y": 55.87649154663086
        },
        {
            "id": "entity_id",
            "outputSource": [
                "gatk_collectreadcounts_tumor/entity_id"
            ],
            "type": "string?",
            "sbg:x": 590.3333129882812,
            "sbg:y": 787.6666870117188
        },
        {
            "id": "entity_id_1",
            "outputSource": [
                "gatk_collectreadcounts_normal/entity_id"
            ],
            "type": "string?",
            "sbg:x": 599.6666870117188,
            "sbg:y": 964
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
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-preprocessintervals-4-1-0-0/33",
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
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551193525,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551193563,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551194142,
                        "sbg:revisionNotes": "edit description, test changes"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551194522,
                        "sbg:revisionNotes": "edit description, no real change, for testing changes in wf"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551202495,
                        "sbg:revisionNotes": "set --intervals to single file instead of array of files, per best practice wdl; add argument for default --output naming"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551202955,
                        "sbg:revisionNotes": "fix glob expression"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551203323,
                        "sbg:revisionNotes": "remove cwl default value for output argument"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1552650660,
                        "sbg:revisionNotes": "set --intervals to accept array of files"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1552655924,
                        "sbg:revisionNotes": "add \"common issues\" and \"changes introduced by sbg\" to description"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1552658563,
                        "sbg:revisionNotes": "for --intervals input files, cast self to array before iterating"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1552668611,
                        "sbg:revisionNotes": "edit expression for --intervals, keep prefix"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553098331,
                        "sbg:revisionNotes": "fix description according to wrapping spec"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553098400,
                        "sbg:revisionNotes": "fix expression for exclude_intervals"
                    },
                    {
                        "sbg:revision": 13,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553098504,
                        "sbg:revisionNotes": "add file types for input files"
                    },
                    {
                        "sbg:revision": 14,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553102038,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 15,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553102166,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 16,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553119409,
                        "sbg:revisionNotes": "change 'output' input id to 'output_prefix'; change output prefix expression; change 'reference' to 'in_reference'; add out_intervals description and file format"
                    },
                    {
                        "sbg:revision": 17,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553119476,
                        "sbg:revisionNotes": "add descriptions and default values for memory per job, memory overhead and cpu per job"
                    },
                    {
                        "sbg:revision": 18,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553119552,
                        "sbg:revisionNotes": "add output naming description to changes introduced by sbg section"
                    },
                    {
                        "sbg:revision": 19,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553119686,
                        "sbg:revisionNotes": "change glob to *preprocessed.intervals"
                    },
                    {
                        "sbg:revision": 20,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553126262,
                        "sbg:revisionNotes": "fix output prefix expression to allow for single file interval input"
                    },
                    {
                        "sbg:revision": 21,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553169291,
                        "sbg:revisionNotes": "uppercase-ed extensions in description"
                    },
                    {
                        "sbg:revision": 22,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553170107,
                        "sbg:revisionNotes": "add more file types for intervals and interval_exclude inputs; add link to gatk site for supported intervals formats"
                    },
                    {
                        "sbg:revision": 23,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553710453,
                        "sbg:revisionNotes": "fix description; convert bools to enums"
                    },
                    {
                        "sbg:revision": 24,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553711319,
                        "sbg:revisionNotes": "add benchmarking data"
                    },
                    {
                        "sbg:revision": 25,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1554067992,
                        "sbg:revisionNotes": "fix output naming expression to allow for no intervals file (wgs)"
                    },
                    {
                        "sbg:revision": 26,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1554068429,
                        "sbg:revisionNotes": "fix metadata inheritance expression to allow for no intervals file"
                    },
                    {
                        "sbg:revision": 27,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1554068893,
                        "sbg:revisionNotes": "remove metadata inheritance"
                    },
                    {
                        "sbg:revision": 28,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1554068997,
                        "sbg:revisionNotes": "fix metadata inheritance expression"
                    },
                    {
                        "sbg:revision": 29,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1555341415,
                        "sbg:revisionNotes": "change docker image to images.sbgenomics.com/stefan_stojanovic/gatk-4-1-0-0:0"
                    },
                    {
                        "sbg:revision": 30,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1555341956,
                        "sbg:revisionNotes": "change back docker image to images.sbgenomics.com/stefan_stojanovic/gatk:4.1.0.0"
                    },
                    {
                        "sbg:revision": 31,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559300876,
                        "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons, to keep compatible with cwltool"
                    },
                    {
                        "sbg:revision": 32,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559303485,
                        "sbg:revisionNotes": "inherit metadata from reference file if inputs not provided, add bin_length, padding and interval_merging_rule to metadata"
                    },
                    {
                        "sbg:revision": 33,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559304648,
                        "sbg:revisionNotes": "update expression for output naming in case no intervals files had been specified"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-preprocessintervals-4-1-0-0/33",
                "sbg:revision": 33,
                "sbg:revisionNotes": "update expression for output naming in case no intervals files had been specified",
                "sbg:modifiedOn": 1559304648,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1551193525,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 33,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a619783ec492e6c1c671ab2136a3998689f211a572f620600c3d697941fc0ed54"
            },
            "label": "GATK PreprocessIntervals",
            "sbg:x": -313.4742736816406,
            "sbg:y": 11.08277416229248
        },
        {
            "id": "gatk_collectalleliccounts_tumor",
            "in": [
                {
                    "id": "in_alignments",
                    "source": [
                        "in_alignments_tumor"
                    ],
                    "valueFrom": "$(self ? [self] : self)"
                },
                {
                    "id": "common_sites",
                    "source": "common_sites"
                },
                {
                    "id": "memory_overhead_per_job",
                    "default": 100
                },
                {
                    "id": "memory_per_job",
                    "default": 13000,
                    "source": "memory_collectalleliccounts"
                },
                {
                    "id": "minimum_base_quality",
                    "source": "minimum_base_quality"
                },
                {
                    "id": "in_reference",
                    "source": "in_reference"
                }
            ],
            "out": [
                {
                    "id": "allelic_counts"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectalleliccounts-4-1-0-0/25",
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
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self);\n        return self.join(' --disable-read-filter ');\n    }\n    return '';\n}"
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
                        "doc": "or more genomic intervals to exclude from processing.",
                        "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, BED"
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "sbg:toolDefaultValue": "30",
                        "id": "filter_too_short",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--filter-too-short",
                            "shellQuote": false
                        },
                        "label": "Filter too short",
                        "doc": "Minimum number of aligned bases. Valid only if \"OverclippedReadFilter\" is specified."
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
                        "id": "common_sites",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--intervals",
                            "shellQuote": false
                        },
                        "label": "Common sites",
                        "doc": "One or more genomic intervals over which to operate This argument must be specified at least once.",
                        "sbg:fileTypes": "VCF, BED, INTERVALS, INTERVAL_LIST"
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
                        "sbg:altPrefix": "-maxDepthPerSample",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "maxdepthpersample",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--maxDepthPerSample",
                            "shellQuote": false
                        },
                        "label": "Max depth per sample",
                        "doc": "Maximum number of reads to retain per sample per locus. Reads above this threshold will be downsampled. Set to 0 to disable."
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
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "20",
                        "id": "minimum_base_quality",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--minimum-base-quality",
                            "shellQuote": false
                        },
                        "label": "Minimum base quality",
                        "doc": "base quality. Base calls with lower quality will be filtered out of pileups."
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
                        "doc": "Output file for allelic counts."
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
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self);\n        return self.join(' --read-filter ');\n    }\n    return '';\n}"
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
                        "sbg:toolDefaultValue": "1",
                        "id": "cpu_per_job",
                        "type": "int?",
                        "label": "CPU per job",
                        "doc": "Number of CPUs which will be allocated for the job."
                    }
                ],
                "outputs": [
                    {
                        "id": "allelic_counts",
                        "doc": "TSV file containing ref and alt counts at specified positions (common sites).",
                        "label": "Allelic counts",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.tsv",
                            "outputEval": "$( inputs.in_alignments ? inheritMetadata(self, inputs.in_alignments) : self)"
                        },
                        "sbg:fileTypes": "TSV"
                    }
                ],
                "doc": "GATK CollectAllelicCounts collects reference and alternate allele counts at specified sites. \n\n### Common Use Cases\n\nThe alt count is defined as the total count minus the ref count, and the alt nucleotide is defined as the non-ref base with the highest count, with ties broken by the order of the bases in **AllelicCountCollector**#BASES. Only reads that pass the specified read filters and bases that exceed the specified minimum-base-quality will be counted.\nThis app produces allelic-counts file. This is a tab-separated values (TSV) file with a SAM-style header containing a read group sample name, a sequence dictionary, a row specifying the column headers and the corresponding entry rows. The sites over which allelic counts are collected should represent common sites in population where biallelic configurations are expected. This can be either dbsnp VCF file or Mills gold standard file (with SNPs only). For WGS analysis the entire dbsnp should be provided on the input, whereas for WES analysis we suggest subsetting dbsnp to regions where coverage is expected. \nSome of the input parameters are listed below:\n* **Input reads** (`--input`) - SAM format read data in BAM/SAM/CRAM format. In case of BAM and CRAM files the secondary BAI and CRAI index files are required.\n* **Reference** (`--reference`) genome in FASTA format along with secondary FAI and DICT files\n* **Common sites** (`--intervals`) - Sites at which allelic counts will be collected (ex. dbsnp)\n* **Output prefix** (`--output`) - Prefix of the output allelic counts file.\n\n### Changes Introduced by Seven Bridges\n* If **Output prefix** parameter is not specified the prefix of the output file will be derived from the base name of the first **Input reads** file provided.\n\n### Common Issues and Important Notes\n* Input parameter **Interval merging rule** must be set to `OVERLAPPING_ONLY`, otherwise the tool will produce an error.\n* If entire dbsnp or Mills SNPs VCF file is used for allelic counts collection more working memory should be provided through **Memory per job** input. We advise providing at least 100000 Mb (100GB) of working memory.\n\n### Performance Benchmarking\n\n| Input size | Experimental strategy | Number of sites | Memory | Duration | Cost (spot) | AWS Instance Type |\n| --- | ---| --- | --- | --- | --- | --- | \n| 30GB | WES | ~ 5 * 10^6 | 13000 | 49m | $0.14 | r4.large |\n| 70GB | WGS | ~ 5 * 10^7 | 100000 | 2h 20m | $1.12 | r4.4xlarge | \n| 170GB | WGS | ~ 5 * 10^7 | 100000 | 6h 32m | $3.12 | r4.4xlarge |",
                "label": "GATK CollectAllelicCounts",
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
                        "valueFrom": "CollectAllelicCounts"
                    },
                    {
                        "position": 4,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.in_alignments) {\n        var in_alignments_array = [].concat(inputs.in_alignments);\n        var prefix = inputs.output_prefix ? inputs.output_prefix : in_alignments_array[0].path.split('/').pop().split('.').slice(0,-1).join('.');\n        var ext = 'allelicCounts.tsv';\n        return [prefix, ext].join('.');\n    }\n    return '';\n}"
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
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551310936,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551310990,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551311020,
                        "sbg:revisionNotes": "set default memory requirement to 2048m"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551440675,
                        "sbg:revisionNotes": "set instance hint to c4.8xlarge for testing purposes"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551470621,
                        "sbg:revisionNotes": "instance type r3.4xlarge"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551566621,
                        "sbg:revisionNotes": "revert to revision 2"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553094116,
                        "sbg:revisionNotes": "change input id to in_alignments"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553094574,
                        "sbg:revisionNotes": "add description"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553094665,
                        "sbg:revisionNotes": "change 'output' input id to output_prefix"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553094748,
                        "sbg:revisionNotes": "edit description, add link to wdl"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553094957,
                        "sbg:revisionNotes": "add file types for file inputs"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553097218,
                        "sbg:revisionNotes": "add benchmarking table"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553097816,
                        "sbg:revisionNotes": "add categories utilities and coverage analysis"
                    },
                    {
                        "sbg:revision": 13,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553097911,
                        "sbg:revisionNotes": "fix expression for exclude_intervals input"
                    },
                    {
                        "sbg:revision": 14,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553168191,
                        "sbg:revisionNotes": "Update description"
                    },
                    {
                        "sbg:revision": 15,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553603705,
                        "sbg:revisionNotes": "add benchmarking info; change 'reference' id to 'in_reference'"
                    },
                    {
                        "sbg:revision": 16,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553603987,
                        "sbg:revisionNotes": "convert booleans to enums; fix expressions for enums"
                    },
                    {
                        "sbg:revision": 17,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553604613,
                        "sbg:revisionNotes": "add descriptions for inputs memory per job, memory overhead and cpu per job"
                    },
                    {
                        "sbg:revision": 18,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553604984,
                        "sbg:revisionNotes": "add output file description"
                    },
                    {
                        "sbg:revision": 19,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553605199,
                        "sbg:revisionNotes": "add inputs and outputs sections"
                    },
                    {
                        "sbg:revision": 20,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553692887,
                        "sbg:revisionNotes": "fix description formating to match other tools"
                    },
                    {
                        "sbg:revision": 21,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553813856,
                        "sbg:revisionNotes": "change in_alignments file to array of files, which should be default; fix output naming expression; fix description to reflect changes"
                    },
                    {
                        "sbg:revision": 22,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553816486,
                        "sbg:revisionNotes": "fix output naming expression, concat to array before accessing element"
                    },
                    {
                        "sbg:revision": 23,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553817191,
                        "sbg:revisionNotes": "add secondary file requirements for in_alignments"
                    },
                    {
                        "sbg:revision": 24,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559302162,
                        "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons."
                    },
                    {
                        "sbg:revision": 25,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1577369382,
                        "sbg:revisionNotes": "Secondary files expression changed for in_alignments input"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectalleliccounts-4-1-0-0/25",
                "sbg:revision": 25,
                "sbg:revisionNotes": "Secondary files expression changed for in_alignments input",
                "sbg:modifiedOn": 1577369382,
                "sbg:modifiedBy": "milena_stanojevic",
                "sbg:createdOn": 1551310936,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "milena_stanojevic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 25,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a3434d3a5120456a14d9cbee1fd74164f340353257e831480c7eefd0eb6936af0"
            },
            "label": "GATK CollectAllelicCounts Tumor",
            "sbg:x": 108.30455017089844,
            "sbg:y": -361.6609191894531
        },
        {
            "id": "gatk_collectalleliccounts_normal",
            "in": [
                {
                    "id": "in_alignments",
                    "source": [
                        "in_alignments_normal"
                    ],
                    "valueFrom": "$(self ? [self] : self)"
                },
                {
                    "id": "common_sites",
                    "source": "common_sites"
                },
                {
                    "id": "memory_overhead_per_job",
                    "default": 100
                },
                {
                    "id": "memory_per_job",
                    "default": 13000,
                    "source": "memory_collectalleliccounts"
                },
                {
                    "id": "minimum_base_quality",
                    "source": "minimum_base_quality"
                },
                {
                    "id": "in_reference",
                    "source": "in_reference"
                }
            ],
            "out": [
                {
                    "id": "allelic_counts"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectalleliccounts-4-1-0-0/25",
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
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self);\n        return self.join(' --disable-read-filter ');\n    }\n    return '';\n}"
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
                        "doc": "or more genomic intervals to exclude from processing.",
                        "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, BED"
                    },
                    {
                        "sbg:category": "Conditional Arguments",
                        "sbg:toolDefaultValue": "30",
                        "id": "filter_too_short",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--filter-too-short",
                            "shellQuote": false
                        },
                        "label": "Filter too short",
                        "doc": "Minimum number of aligned bases. Valid only if \"OverclippedReadFilter\" is specified."
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
                        "id": "common_sites",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--intervals",
                            "shellQuote": false
                        },
                        "label": "Common sites",
                        "doc": "One or more genomic intervals over which to operate This argument must be specified at least once.",
                        "sbg:fileTypes": "VCF, BED, INTERVALS, INTERVAL_LIST"
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
                        "sbg:altPrefix": "-maxDepthPerSample",
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "maxdepthpersample",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--maxDepthPerSample",
                            "shellQuote": false
                        },
                        "label": "Max depth per sample",
                        "doc": "Maximum number of reads to retain per sample per locus. Reads above this threshold will be downsampled. Set to 0 to disable."
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
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "20",
                        "id": "minimum_base_quality",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--minimum-base-quality",
                            "shellQuote": false
                        },
                        "label": "Minimum base quality",
                        "doc": "base quality. Base calls with lower quality will be filtered out of pileups."
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
                        "doc": "Output file for allelic counts."
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
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self);\n        return self.join(' --read-filter ');\n    }\n    return '';\n}"
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
                        "sbg:toolDefaultValue": "1",
                        "id": "cpu_per_job",
                        "type": "int?",
                        "label": "CPU per job",
                        "doc": "Number of CPUs which will be allocated for the job."
                    }
                ],
                "outputs": [
                    {
                        "id": "allelic_counts",
                        "doc": "TSV file containing ref and alt counts at specified positions (common sites).",
                        "label": "Allelic counts",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.tsv",
                            "outputEval": "$( inputs.in_alignments ? inheritMetadata(self, inputs.in_alignments) : self)"
                        },
                        "sbg:fileTypes": "TSV"
                    }
                ],
                "doc": "GATK CollectAllelicCounts collects reference and alternate allele counts at specified sites. \n\n### Common Use Cases\n\nThe alt count is defined as the total count minus the ref count, and the alt nucleotide is defined as the non-ref base with the highest count, with ties broken by the order of the bases in **AllelicCountCollector**#BASES. Only reads that pass the specified read filters and bases that exceed the specified minimum-base-quality will be counted.\nThis app produces allelic-counts file. This is a tab-separated values (TSV) file with a SAM-style header containing a read group sample name, a sequence dictionary, a row specifying the column headers and the corresponding entry rows. The sites over which allelic counts are collected should represent common sites in population where biallelic configurations are expected. This can be either dbsnp VCF file or Mills gold standard file (with SNPs only). For WGS analysis the entire dbsnp should be provided on the input, whereas for WES analysis we suggest subsetting dbsnp to regions where coverage is expected. \nSome of the input parameters are listed below:\n* **Input reads** (`--input`) - SAM format read data in BAM/SAM/CRAM format. In case of BAM and CRAM files the secondary BAI and CRAI index files are required.\n* **Reference** (`--reference`) genome in FASTA format along with secondary FAI and DICT files\n* **Common sites** (`--intervals`) - Sites at which allelic counts will be collected (ex. dbsnp)\n* **Output prefix** (`--output`) - Prefix of the output allelic counts file.\n\n### Changes Introduced by Seven Bridges\n* If **Output prefix** parameter is not specified the prefix of the output file will be derived from the base name of the first **Input reads** file provided.\n\n### Common Issues and Important Notes\n* Input parameter **Interval merging rule** must be set to `OVERLAPPING_ONLY`, otherwise the tool will produce an error.\n* If entire dbsnp or Mills SNPs VCF file is used for allelic counts collection more working memory should be provided through **Memory per job** input. We advise providing at least 100000 Mb (100GB) of working memory.\n\n### Performance Benchmarking\n\n| Input size | Experimental strategy | Number of sites | Memory | Duration | Cost (spot) | AWS Instance Type |\n| --- | ---| --- | --- | --- | --- | --- | \n| 30GB | WES | ~ 5 * 10^6 | 13000 | 49m | $0.14 | r4.large |\n| 70GB | WGS | ~ 5 * 10^7 | 100000 | 2h 20m | $1.12 | r4.4xlarge | \n| 170GB | WGS | ~ 5 * 10^7 | 100000 | 6h 32m | $3.12 | r4.4xlarge |",
                "label": "GATK CollectAllelicCounts",
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
                        "valueFrom": "CollectAllelicCounts"
                    },
                    {
                        "position": 4,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.in_alignments) {\n        var in_alignments_array = [].concat(inputs.in_alignments);\n        var prefix = inputs.output_prefix ? inputs.output_prefix : in_alignments_array[0].path.split('/').pop().split('.').slice(0,-1).join('.');\n        var ext = 'allelicCounts.tsv';\n        return [prefix, ext].join('.');\n    }\n    return '';\n}"
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
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551310936,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551310990,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551311020,
                        "sbg:revisionNotes": "set default memory requirement to 2048m"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551440675,
                        "sbg:revisionNotes": "set instance hint to c4.8xlarge for testing purposes"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551470621,
                        "sbg:revisionNotes": "instance type r3.4xlarge"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551566621,
                        "sbg:revisionNotes": "revert to revision 2"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553094116,
                        "sbg:revisionNotes": "change input id to in_alignments"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553094574,
                        "sbg:revisionNotes": "add description"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553094665,
                        "sbg:revisionNotes": "change 'output' input id to output_prefix"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553094748,
                        "sbg:revisionNotes": "edit description, add link to wdl"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553094957,
                        "sbg:revisionNotes": "add file types for file inputs"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553097218,
                        "sbg:revisionNotes": "add benchmarking table"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553097816,
                        "sbg:revisionNotes": "add categories utilities and coverage analysis"
                    },
                    {
                        "sbg:revision": 13,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553097911,
                        "sbg:revisionNotes": "fix expression for exclude_intervals input"
                    },
                    {
                        "sbg:revision": 14,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553168191,
                        "sbg:revisionNotes": "Update description"
                    },
                    {
                        "sbg:revision": 15,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553603705,
                        "sbg:revisionNotes": "add benchmarking info; change 'reference' id to 'in_reference'"
                    },
                    {
                        "sbg:revision": 16,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553603987,
                        "sbg:revisionNotes": "convert booleans to enums; fix expressions for enums"
                    },
                    {
                        "sbg:revision": 17,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553604613,
                        "sbg:revisionNotes": "add descriptions for inputs memory per job, memory overhead and cpu per job"
                    },
                    {
                        "sbg:revision": 18,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553604984,
                        "sbg:revisionNotes": "add output file description"
                    },
                    {
                        "sbg:revision": 19,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553605199,
                        "sbg:revisionNotes": "add inputs and outputs sections"
                    },
                    {
                        "sbg:revision": 20,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553692887,
                        "sbg:revisionNotes": "fix description formating to match other tools"
                    },
                    {
                        "sbg:revision": 21,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553813856,
                        "sbg:revisionNotes": "change in_alignments file to array of files, which should be default; fix output naming expression; fix description to reflect changes"
                    },
                    {
                        "sbg:revision": 22,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553816486,
                        "sbg:revisionNotes": "fix output naming expression, concat to array before accessing element"
                    },
                    {
                        "sbg:revision": 23,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553817191,
                        "sbg:revisionNotes": "add secondary file requirements for in_alignments"
                    },
                    {
                        "sbg:revision": 24,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559302162,
                        "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons."
                    },
                    {
                        "sbg:revision": 25,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1577369382,
                        "sbg:revisionNotes": "Secondary files expression changed for in_alignments input"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectalleliccounts-4-1-0-0/25",
                "sbg:revision": 25,
                "sbg:revisionNotes": "Secondary files expression changed for in_alignments input",
                "sbg:modifiedOn": 1577369382,
                "sbg:modifiedBy": "milena_stanojevic",
                "sbg:createdOn": 1551310936,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "milena_stanojevic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 25,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a3434d3a5120456a14d9cbee1fd74164f340353257e831480c7eefd0eb6936af0"
            },
            "label": "GATK CollectAllelicCounts Normal",
            "sbg:x": 108.30455017089844,
            "sbg:y": -178
        },
        {
            "id": "gatk_collectreadcounts_tumor",
            "in": [
                {
                    "id": "in_alignments",
                    "source": [
                        "in_alignments_tumor"
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
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/43",
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
                            "${\n    if(self.nameext == '.bam'){\n        return self.basename + '.bai';\n        return null;\n    }\n}\n"
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
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551193647,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551193664,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551201002,
                        "sbg:revisionNotes": "set default memory to 7000 mb, per best practice wdl"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551275591,
                        "sbg:revisionNotes": "default memory req set to 2048"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1552663151,
                        "sbg:revisionNotes": "add expression for multiple intervals files"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1552663376,
                        "sbg:revisionNotes": "add more description"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1552931554,
                        "sbg:revisionNotes": "Update description"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553084767,
                        "sbg:revisionNotes": "edit description and inputs per wrapping spec"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553085195,
                        "sbg:revisionNotes": "edit description"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553086956,
                        "sbg:revisionNotes": "fix metadata inheritance"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553087167,
                        "sbg:revisionNotes": "edit glob for read_counts"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553087264,
                        "sbg:revisionNotes": "add file types for intervals and exclude_intervals"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553093351,
                        "sbg:revisionNotes": "add benchmarking table"
                    },
                    {
                        "sbg:revision": 13,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553093631,
                        "sbg:revisionNotes": "add file types for file inputs"
                    },
                    {
                        "sbg:revision": 14,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553095242,
                        "sbg:revisionNotes": "fix typos in description"
                    },
                    {
                        "sbg:revision": 15,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553096042,
                        "sbg:revisionNotes": "add benchmarking info to table"
                    },
                    {
                        "sbg:revision": 16,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553097270,
                        "sbg:revisionNotes": "change label in benchmarking table, experimental strategy instead of sequencing data"
                    },
                    {
                        "sbg:revision": 17,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553097565,
                        "sbg:revisionNotes": "add categories: utilities and coverage analysis"
                    },
                    {
                        "sbg:revision": 18,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553105407,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 19,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553116439,
                        "sbg:revisionNotes": "replace booleans with enums"
                    },
                    {
                        "sbg:revision": 20,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553116523,
                        "sbg:revisionNotes": "change reference input id to in_reference"
                    },
                    {
                        "sbg:revision": 21,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553116619,
                        "sbg:revisionNotes": "fix expressions for intervals and exclude intervals"
                    },
                    {
                        "sbg:revision": 22,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553116757,
                        "sbg:revisionNotes": "add descriptions for memory_per_job, memory overhead and cpu per job"
                    },
                    {
                        "sbg:revision": 23,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553170553,
                        "sbg:revisionNotes": "fix extensions in description to be uppercase; add more supported intervals formats"
                    },
                    {
                        "sbg:revision": 24,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553172832,
                        "sbg:revisionNotes": "fix expressions for read_filter and disable_read_filter"
                    },
                    {
                        "sbg:revision": 25,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553699526,
                        "sbg:revisionNotes": "add more info to description"
                    },
                    {
                        "sbg:revision": 26,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553699789,
                        "sbg:revisionNotes": "fix description"
                    },
                    {
                        "sbg:revision": 27,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553700607,
                        "sbg:revisionNotes": "fix description"
                    },
                    {
                        "sbg:revision": 28,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553700856,
                        "sbg:revisionNotes": "fix ambiguous entity id description"
                    },
                    {
                        "sbg:revision": 29,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553811943,
                        "sbg:revisionNotes": "set in_alignments (--input) parameter to required"
                    },
                    {
                        "sbg:revision": 30,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553814181,
                        "sbg:revisionNotes": "change in_alignments input file to array of files, and set to required; fix output naming expression accordingly; fix description to reflect changes"
                    },
                    {
                        "sbg:revision": 31,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553816902,
                        "sbg:revisionNotes": "fix output naming expression, concat to array before accessing element"
                    },
                    {
                        "sbg:revision": 32,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553817230,
                        "sbg:revisionNotes": "add secondary file requirements for in_alignments"
                    },
                    {
                        "sbg:revision": 33,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553946633,
                        "sbg:revisionNotes": "fix choices for output_format enum input"
                    },
                    {
                        "sbg:revision": 34,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553947640,
                        "sbg:revisionNotes": "change back choices for output_format to uppercase; fix glob expressions to catch uppercase extensions"
                    },
                    {
                        "sbg:revision": 35,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1554031355,
                        "sbg:revisionNotes": "add aws info to benchmarking table, fix some typos"
                    },
                    {
                        "sbg:revision": 36,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559301483,
                        "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons"
                    },
                    {
                        "sbg:revision": 37,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559306601,
                        "sbg:revisionNotes": "fix expression for entity_id output eval, allow for list output as well as single entity id string output"
                    },
                    {
                        "sbg:revision": 38,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559307568,
                        "sbg:revisionNotes": "edit entity_id output eval expression, always output array of strings"
                    },
                    {
                        "sbg:revision": 39,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559730513,
                        "sbg:revisionNotes": "revert to revision 37;"
                    },
                    {
                        "sbg:revision": 40,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559730874,
                        "sbg:revisionNotes": "fix entity_id output eval expression, allow for zero length in_alignments case, in case of conditional execution"
                    },
                    {
                        "sbg:revision": 41,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559752112,
                        "sbg:revisionNotes": "update entity_id eval expression"
                    },
                    {
                        "sbg:revision": 42,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1577370292,
                        "sbg:revisionNotes": "Secondary files expression changed for in_alignments input"
                    },
                    {
                        "sbg:revision": 43,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1577370990,
                        "sbg:revisionNotes": "Glob for output read_counts changed to *.hdf5"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/43",
                "sbg:revision": 43,
                "sbg:revisionNotes": "Glob for output read_counts changed to *.hdf5",
                "sbg:modifiedOn": 1577370990,
                "sbg:modifiedBy": "milena_stanojevic",
                "sbg:createdOn": 1551193647,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "milena_stanojevic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 43,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a9994682c1cb8007376ece05b80abf7c1b8886f8d54275b8f9aac52e626e59515"
            },
            "label": "GATK CollectReadCounts Tumor",
            "sbg:x": 95.00000762939453,
            "sbg:y": 137.03176879882812
        },
        {
            "id": "gatk_collectreadcounts_normal",
            "in": [
                {
                    "id": "in_alignments",
                    "source": [
                        "in_alignments_normal"
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
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/43",
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
                            "${\n    if(self.nameext == '.bam'){\n        return self.basename + '.bai';\n        return null;\n    }\n}\n"
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
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551193647,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551193664,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551201002,
                        "sbg:revisionNotes": "set default memory to 7000 mb, per best practice wdl"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551275591,
                        "sbg:revisionNotes": "default memory req set to 2048"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1552663151,
                        "sbg:revisionNotes": "add expression for multiple intervals files"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1552663376,
                        "sbg:revisionNotes": "add more description"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1552931554,
                        "sbg:revisionNotes": "Update description"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553084767,
                        "sbg:revisionNotes": "edit description and inputs per wrapping spec"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553085195,
                        "sbg:revisionNotes": "edit description"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553086956,
                        "sbg:revisionNotes": "fix metadata inheritance"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553087167,
                        "sbg:revisionNotes": "edit glob for read_counts"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553087264,
                        "sbg:revisionNotes": "add file types for intervals and exclude_intervals"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553093351,
                        "sbg:revisionNotes": "add benchmarking table"
                    },
                    {
                        "sbg:revision": 13,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553093631,
                        "sbg:revisionNotes": "add file types for file inputs"
                    },
                    {
                        "sbg:revision": 14,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553095242,
                        "sbg:revisionNotes": "fix typos in description"
                    },
                    {
                        "sbg:revision": 15,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553096042,
                        "sbg:revisionNotes": "add benchmarking info to table"
                    },
                    {
                        "sbg:revision": 16,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553097270,
                        "sbg:revisionNotes": "change label in benchmarking table, experimental strategy instead of sequencing data"
                    },
                    {
                        "sbg:revision": 17,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553097565,
                        "sbg:revisionNotes": "add categories: utilities and coverage analysis"
                    },
                    {
                        "sbg:revision": 18,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553105407,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 19,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553116439,
                        "sbg:revisionNotes": "replace booleans with enums"
                    },
                    {
                        "sbg:revision": 20,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553116523,
                        "sbg:revisionNotes": "change reference input id to in_reference"
                    },
                    {
                        "sbg:revision": 21,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553116619,
                        "sbg:revisionNotes": "fix expressions for intervals and exclude intervals"
                    },
                    {
                        "sbg:revision": 22,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553116757,
                        "sbg:revisionNotes": "add descriptions for memory_per_job, memory overhead and cpu per job"
                    },
                    {
                        "sbg:revision": 23,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553170553,
                        "sbg:revisionNotes": "fix extensions in description to be uppercase; add more supported intervals formats"
                    },
                    {
                        "sbg:revision": 24,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553172832,
                        "sbg:revisionNotes": "fix expressions for read_filter and disable_read_filter"
                    },
                    {
                        "sbg:revision": 25,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553699526,
                        "sbg:revisionNotes": "add more info to description"
                    },
                    {
                        "sbg:revision": 26,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553699789,
                        "sbg:revisionNotes": "fix description"
                    },
                    {
                        "sbg:revision": 27,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553700607,
                        "sbg:revisionNotes": "fix description"
                    },
                    {
                        "sbg:revision": 28,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553700856,
                        "sbg:revisionNotes": "fix ambiguous entity id description"
                    },
                    {
                        "sbg:revision": 29,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553811943,
                        "sbg:revisionNotes": "set in_alignments (--input) parameter to required"
                    },
                    {
                        "sbg:revision": 30,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553814181,
                        "sbg:revisionNotes": "change in_alignments input file to array of files, and set to required; fix output naming expression accordingly; fix description to reflect changes"
                    },
                    {
                        "sbg:revision": 31,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553816902,
                        "sbg:revisionNotes": "fix output naming expression, concat to array before accessing element"
                    },
                    {
                        "sbg:revision": 32,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553817230,
                        "sbg:revisionNotes": "add secondary file requirements for in_alignments"
                    },
                    {
                        "sbg:revision": 33,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553946633,
                        "sbg:revisionNotes": "fix choices for output_format enum input"
                    },
                    {
                        "sbg:revision": 34,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553947640,
                        "sbg:revisionNotes": "change back choices for output_format to uppercase; fix glob expressions to catch uppercase extensions"
                    },
                    {
                        "sbg:revision": 35,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1554031355,
                        "sbg:revisionNotes": "add aws info to benchmarking table, fix some typos"
                    },
                    {
                        "sbg:revision": 36,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559301483,
                        "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons"
                    },
                    {
                        "sbg:revision": 37,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559306601,
                        "sbg:revisionNotes": "fix expression for entity_id output eval, allow for list output as well as single entity id string output"
                    },
                    {
                        "sbg:revision": 38,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559307568,
                        "sbg:revisionNotes": "edit entity_id output eval expression, always output array of strings"
                    },
                    {
                        "sbg:revision": 39,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559730513,
                        "sbg:revisionNotes": "revert to revision 37;"
                    },
                    {
                        "sbg:revision": 40,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559730874,
                        "sbg:revisionNotes": "fix entity_id output eval expression, allow for zero length in_alignments case, in case of conditional execution"
                    },
                    {
                        "sbg:revision": 41,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559752112,
                        "sbg:revisionNotes": "update entity_id eval expression"
                    },
                    {
                        "sbg:revision": 42,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1577370292,
                        "sbg:revisionNotes": "Secondary files expression changed for in_alignments input"
                    },
                    {
                        "sbg:revision": 43,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1577370990,
                        "sbg:revisionNotes": "Glob for output read_counts changed to *.hdf5"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/43",
                "sbg:revision": 43,
                "sbg:revisionNotes": "Glob for output read_counts changed to *.hdf5",
                "sbg:modifiedOn": 1577370990,
                "sbg:modifiedBy": "milena_stanojevic",
                "sbg:createdOn": 1551193647,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "milena_stanojevic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 43,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a9994682c1cb8007376ece05b80abf7c1b8886f8d54275b8f9aac52e626e59515"
            },
            "label": "GATK CollectReadCounts Normal",
            "sbg:x": 96.52572631835938,
            "sbg:y": 341.644287109375
        },
        {
            "id": "gatk_denoisereadcounts_tumor",
            "in": [
                {
                    "id": "count_panel_of_normals",
                    "source": "count_panel_of_normals"
                },
                {
                    "id": "read_counts",
                    "source": "gatk_collectreadcounts_tumor/read_counts"
                },
                {
                    "id": "memory_per_job",
                    "default": 13000
                },
                {
                    "id": "number_of_eigensamples",
                    "source": "number_of_eigensamples"
                },
                {
                    "id": "output_prefix",
                    "source": "gatk_collectreadcounts_tumor/entity_id"
                }
            ],
            "out": [
                {
                    "id": "out_denoised_copy_ratios"
                },
                {
                    "id": "out_standardized_copy_ratios"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-denoisereadcounts-4-1-0-0/12",
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
                        "doc": "Input file containing annotations for gc content in genomic intervals (output of annotateintervals). Intervals must be identical to and in the same order as those in the input read-counts file. If a panel of normals is provided, this input will be ignored.",
                        "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, LIST, BED, TSV"
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "count_panel_of_normals",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--count-panel-of-normals",
                            "shellQuote": false
                        },
                        "label": "Panel of normals",
                        "doc": "Input HDF5 file containing the panel of normals (output of **CreateReadCountPanelOfNormals**).",
                        "sbg:fileTypes": "HDF5"
                    },
                    {
                        "sbg:altPrefix": "-I",
                        "sbg:category": "Required Arguments",
                        "id": "read_counts",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--input",
                            "shellQuote": false
                        },
                        "label": "Read counts",
                        "doc": "Input TSV or HDF5 file containing integer read counts in genomic intervals for a single case sample (output of collectreadcounts).",
                        "sbg:fileTypes": "TSV, HDF5"
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
                        "sbg:toolDefaultValue": "null",
                        "id": "number_of_eigensamples",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-eigensamples",
                            "shellQuote": false
                        },
                        "label": "Number of eigensamples",
                        "doc": "Number of eigensamples to use for denoising. If not specified or if the number of eigensamples available in the panel of normals is smaller than this, all eigensamples will be used."
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
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Prefix for standardized and denoised copy ratio files that will be created by the tool."
                    }
                ],
                "outputs": [
                    {
                        "id": "out_denoised_copy_ratios",
                        "doc": "TSV file containing denoised copy ratios.",
                        "label": "Denoised copy ratios",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.denoisedCR.tsv",
                            "outputEval": "$( inputs.read_counts ? inheritMetadata(self, inputs.read_counts) : self)"
                        },
                        "sbg:fileTypes": "TSV"
                    },
                    {
                        "id": "out_standardized_copy_ratios",
                        "doc": "TSV file containing standardized copy ratios.",
                        "label": "Standardized copy ratios",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.standardizedCR.tsv",
                            "outputEval": "$( inputs.read_counts ? inheritMetadata(self, inputs.read_counts) : self)"
                        },
                        "sbg:fileTypes": "TSV"
                    }
                ],
                "doc": "GATK DenoiseReadCounts denoises read counts to produce denoised and standardized copy ratios. \n\n### Common Use Cases\n\nTypically, a panel of normals produced by CreateReadCountPanelOfNormals is provided as input. The input counts are then standardized by 1) transforming to fractional coverage, 2) performing optional explicit GC-bias correction (if the panel contains GC-content annotated intervals), 3) filtering intervals to those contained in the panel, 4) dividing by interval medians contained in the panel, 5) dividing by the sample median, and 6) transforming to log2 copy ratio. The result is then denoised by subtracting the projection onto the specified number of principal components from the panel.\n\nIf no panel is provided, then the input counts are instead standardized by 1) transforming to fractional coverage, 2) performing optional explicit GC-bias correction (if GC-content annotated intervals are provided), 3) dividing by the sample median, and 4) transforming to log2 copy ratio. No denoising is performed, so the denoised result is simply taken to be identical to the standardized result.\n\nIf performed, explicit GC-bias correction is done by GCBiasCorrector.\n\nNote that number-of-eigensamples principal components from the input panel will be used for denoising; if only fewer are available in the panel, then they will all be used. This parameter can thus be used to control the amount of denoising, which will ultimately affect the sensitivity of the analysis.\n\n*Source: [https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_DenoiseReadCounts.php](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_DenoiseReadCounts.php)*\n\nSome of the input parameters are listed below:\n* **Read counts** (`--input`) - TSV or HDF5 file containing read counts data for a single case sample. Output of **CollectReadCounts**.\n* **Panel of normals** (`--count-panel-of-normals`), from **CreateReadCountPanelOfNormals**. If provided, it will be used to standardize and denoise the input counts. This may include explicit GC-bias correction if annotated intervals were used to create the panel.\n* **Annotated intervals** (`--annotated-intervals`) - GC annotated intervals from **AnnotateIntervals**. This can be provided in place of a panel of normals to perform explicit GC-bias correction. \nNote that number-of-eigensamples principal components from the input panel will be used for denoising; if only fewer are available in the panel, then they will all be used. This parameter can thus be used to control the amount of denoising, which will ultimately affect the sensitivity of the analysis.\n* **Output prefix** - Prefix for standardized and denoised copy ratio output files.\n\n### Changes Introduced by Seven Bridges\n* Some of the non-applicable input parameters have been removed.\n* Input parameter **Output prefix** has been added. It will be used for naming output files by appending extensions `.denoisedCR.tsv` and `.standardizedCR.tsv` to the provided prefix. In case the **Output prefix** is not specified, the prefix for the output files will be derived from the base name of the **Read counts** file.\n\n### Common Issues and Important Notes\n* *No issues have been encountered thus far.*\n\n### Performance Benchmarking\n| Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- |\n| 7MB | WES | 3min | $0.01 | c4.2xlarge |\n| 500MB | WGS | 3min | $0.01 | c4.2xlarge |",
                "label": "GATK DenoiseReadCounts",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$( inputs.read_counts ? '/opt/gatk' : 'echo /opt/gatk')"
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
                        "valueFrom": "DenoiseReadCounts"
                    },
                    {
                        "position": 4,
                        "prefix": "--denoised-copy-ratios",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.read_counts) {\n        var nameroot = inputs.output_prefix ? inputs.output_prefix : inputs.read_counts.nameroot;\n        var nameext = '.denoisedCR.tsv';\n        return nameroot + nameext;\n    }\n    return '';\n}"
                    },
                    {
                        "position": 5,
                        "prefix": "--standardized-copy-ratios",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.read_counts) {\n        var nameroot = inputs.output_prefix ? inputs.output_prefix : inputs.read_counts.nameroot;\n        var nameext = '.standardizedCR.tsv';\n        return nameroot + nameext;\n    }\n    return '';\n}"
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
                    "Genomics",
                    "Copy Number Variant Calling"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551311937,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551311967,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553170000,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553605709,
                        "sbg:revisionNotes": "fix input IDs, labels, descriptions and file types; fix argument expressions to reflect changes in input ids"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553607220,
                        "sbg:revisionNotes": "add descriptions for output files"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553608267,
                        "sbg:revisionNotes": "fix description formatiing"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553693104,
                        "sbg:revisionNotes": "fix description formatting to match other tools; add output prefix naming info"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553696646,
                        "sbg:revisionNotes": "fix conditional execution expression"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553697222,
                        "sbg:revisionNotes": "edit output glob"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553697581,
                        "sbg:revisionNotes": "again, edit glob expressions; fix conditional metadata inheritance"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553770274,
                        "sbg:revisionNotes": "add benchmarking info; fix typos in description"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553814425,
                        "sbg:revisionNotes": "set read_counts (--input) to required; add minor changes to description"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559302328,
                        "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons;"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-denoisereadcounts-4-1-0-0/12",
                "sbg:revision": 12,
                "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons;",
                "sbg:modifiedOn": 1559302328,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1551311937,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 12,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a2555c15d80b1e45416e8bc7282c48aba7e011c21b452bfe3ecb10d378c8ce334"
            },
            "label": "GATK DenoiseReadCounts Tumor",
            "sbg:x": 467.23712158203125,
            "sbg:y": 131.8814239501953
        },
        {
            "id": "gatk_denoisereadcounts_normal",
            "in": [
                {
                    "id": "count_panel_of_normals",
                    "source": "count_panel_of_normals"
                },
                {
                    "id": "read_counts",
                    "source": "gatk_collectreadcounts_normal/read_counts"
                },
                {
                    "id": "memory_per_job",
                    "default": 13000
                },
                {
                    "id": "number_of_eigensamples",
                    "source": "number_of_eigensamples"
                },
                {
                    "id": "output_prefix",
                    "source": "gatk_collectreadcounts_normal/entity_id"
                }
            ],
            "out": [
                {
                    "id": "out_denoised_copy_ratios"
                },
                {
                    "id": "out_standardized_copy_ratios"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-denoisereadcounts-4-1-0-0/12",
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
                        "doc": "Input file containing annotations for gc content in genomic intervals (output of annotateintervals). Intervals must be identical to and in the same order as those in the input read-counts file. If a panel of normals is provided, this input will be ignored.",
                        "sbg:fileTypes": "INTERVALS, INTERVAL_LIST, LIST, BED, TSV"
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "count_panel_of_normals",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--count-panel-of-normals",
                            "shellQuote": false
                        },
                        "label": "Panel of normals",
                        "doc": "Input HDF5 file containing the panel of normals (output of **CreateReadCountPanelOfNormals**).",
                        "sbg:fileTypes": "HDF5"
                    },
                    {
                        "sbg:altPrefix": "-I",
                        "sbg:category": "Required Arguments",
                        "id": "read_counts",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--input",
                            "shellQuote": false
                        },
                        "label": "Read counts",
                        "doc": "Input TSV or HDF5 file containing integer read counts in genomic intervals for a single case sample (output of collectreadcounts).",
                        "sbg:fileTypes": "TSV, HDF5"
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
                        "sbg:toolDefaultValue": "null",
                        "id": "number_of_eigensamples",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-eigensamples",
                            "shellQuote": false
                        },
                        "label": "Number of eigensamples",
                        "doc": "Number of eigensamples to use for denoising. If not specified or if the number of eigensamples available in the panel of normals is smaller than this, all eigensamples will be used."
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
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Prefix for standardized and denoised copy ratio files that will be created by the tool."
                    }
                ],
                "outputs": [
                    {
                        "id": "out_denoised_copy_ratios",
                        "doc": "TSV file containing denoised copy ratios.",
                        "label": "Denoised copy ratios",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.denoisedCR.tsv",
                            "outputEval": "$( inputs.read_counts ? inheritMetadata(self, inputs.read_counts) : self)"
                        },
                        "sbg:fileTypes": "TSV"
                    },
                    {
                        "id": "out_standardized_copy_ratios",
                        "doc": "TSV file containing standardized copy ratios.",
                        "label": "Standardized copy ratios",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.standardizedCR.tsv",
                            "outputEval": "$( inputs.read_counts ? inheritMetadata(self, inputs.read_counts) : self)"
                        },
                        "sbg:fileTypes": "TSV"
                    }
                ],
                "doc": "GATK DenoiseReadCounts denoises read counts to produce denoised and standardized copy ratios. \n\n### Common Use Cases\n\nTypically, a panel of normals produced by CreateReadCountPanelOfNormals is provided as input. The input counts are then standardized by 1) transforming to fractional coverage, 2) performing optional explicit GC-bias correction (if the panel contains GC-content annotated intervals), 3) filtering intervals to those contained in the panel, 4) dividing by interval medians contained in the panel, 5) dividing by the sample median, and 6) transforming to log2 copy ratio. The result is then denoised by subtracting the projection onto the specified number of principal components from the panel.\n\nIf no panel is provided, then the input counts are instead standardized by 1) transforming to fractional coverage, 2) performing optional explicit GC-bias correction (if GC-content annotated intervals are provided), 3) dividing by the sample median, and 4) transforming to log2 copy ratio. No denoising is performed, so the denoised result is simply taken to be identical to the standardized result.\n\nIf performed, explicit GC-bias correction is done by GCBiasCorrector.\n\nNote that number-of-eigensamples principal components from the input panel will be used for denoising; if only fewer are available in the panel, then they will all be used. This parameter can thus be used to control the amount of denoising, which will ultimately affect the sensitivity of the analysis.\n\n*Source: [https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_DenoiseReadCounts.php](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_DenoiseReadCounts.php)*\n\nSome of the input parameters are listed below:\n* **Read counts** (`--input`) - TSV or HDF5 file containing read counts data for a single case sample. Output of **CollectReadCounts**.\n* **Panel of normals** (`--count-panel-of-normals`), from **CreateReadCountPanelOfNormals**. If provided, it will be used to standardize and denoise the input counts. This may include explicit GC-bias correction if annotated intervals were used to create the panel.\n* **Annotated intervals** (`--annotated-intervals`) - GC annotated intervals from **AnnotateIntervals**. This can be provided in place of a panel of normals to perform explicit GC-bias correction. \nNote that number-of-eigensamples principal components from the input panel will be used for denoising; if only fewer are available in the panel, then they will all be used. This parameter can thus be used to control the amount of denoising, which will ultimately affect the sensitivity of the analysis.\n* **Output prefix** - Prefix for standardized and denoised copy ratio output files.\n\n### Changes Introduced by Seven Bridges\n* Some of the non-applicable input parameters have been removed.\n* Input parameter **Output prefix** has been added. It will be used for naming output files by appending extensions `.denoisedCR.tsv` and `.standardizedCR.tsv` to the provided prefix. In case the **Output prefix** is not specified, the prefix for the output files will be derived from the base name of the **Read counts** file.\n\n### Common Issues and Important Notes\n* *No issues have been encountered thus far.*\n\n### Performance Benchmarking\n| Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- |\n| 7MB | WES | 3min | $0.01 | c4.2xlarge |\n| 500MB | WGS | 3min | $0.01 | c4.2xlarge |",
                "label": "GATK DenoiseReadCounts",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$( inputs.read_counts ? '/opt/gatk' : 'echo /opt/gatk')"
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
                        "valueFrom": "DenoiseReadCounts"
                    },
                    {
                        "position": 4,
                        "prefix": "--denoised-copy-ratios",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.read_counts) {\n        var nameroot = inputs.output_prefix ? inputs.output_prefix : inputs.read_counts.nameroot;\n        var nameext = '.denoisedCR.tsv';\n        return nameroot + nameext;\n    }\n    return '';\n}"
                    },
                    {
                        "position": 5,
                        "prefix": "--standardized-copy-ratios",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.read_counts) {\n        var nameroot = inputs.output_prefix ? inputs.output_prefix : inputs.read_counts.nameroot;\n        var nameext = '.standardizedCR.tsv';\n        return nameroot + nameext;\n    }\n    return '';\n}"
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
                    "Genomics",
                    "Copy Number Variant Calling"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551311937,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551311967,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553170000,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553605709,
                        "sbg:revisionNotes": "fix input IDs, labels, descriptions and file types; fix argument expressions to reflect changes in input ids"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553607220,
                        "sbg:revisionNotes": "add descriptions for output files"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553608267,
                        "sbg:revisionNotes": "fix description formatiing"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553693104,
                        "sbg:revisionNotes": "fix description formatting to match other tools; add output prefix naming info"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553696646,
                        "sbg:revisionNotes": "fix conditional execution expression"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553697222,
                        "sbg:revisionNotes": "edit output glob"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553697581,
                        "sbg:revisionNotes": "again, edit glob expressions; fix conditional metadata inheritance"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553770274,
                        "sbg:revisionNotes": "add benchmarking info; fix typos in description"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553814425,
                        "sbg:revisionNotes": "set read_counts (--input) to required; add minor changes to description"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559302328,
                        "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons;"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-denoisereadcounts-4-1-0-0/12",
                "sbg:revision": 12,
                "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons;",
                "sbg:modifiedOn": 1559302328,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1551311937,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 12,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a2555c15d80b1e45416e8bc7282c48aba7e011c21b452bfe3ecb10d378c8ce334"
            },
            "label": "GATK DenoiseReadCounts Normal",
            "sbg:x": 466.94854736328125,
            "sbg:y": 335.88140869140625
        },
        {
            "id": "gatk_plotdenoisedcopyratios_tumor",
            "in": [
                {
                    "id": "denoised_copy_ratios",
                    "source": "gatk_denoisereadcounts_tumor/out_denoised_copy_ratios"
                },
                {
                    "id": "memory_per_job",
                    "default": 7000
                },
                {
                    "id": "minimum_contig_length",
                    "source": "minimum_contig_length"
                },
                {
                    "id": "output_prefix",
                    "source": "gatk_collectreadcounts_tumor/entity_id"
                },
                {
                    "id": "sequence_dictionary",
                    "source": "sequence_dictionary"
                },
                {
                    "id": "standardized_copy_ratios",
                    "source": "gatk_denoisereadcounts_tumor/out_standardized_copy_ratios"
                }
            ],
            "out": [
                {
                    "id": "denoised_plot"
                },
                {
                    "id": "denoised_limit_plot"
                },
                {
                    "id": "delta_mad"
                },
                {
                    "id": "denoised_mad"
                },
                {
                    "id": "scaled_delta_mad"
                },
                {
                    "id": "standardized_mad"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-plotdenoisedcopyratios-4-1-0-0/11",
                "baseCommand": [],
                "inputs": [
                    {
                        "sbg:category": "Required Arguments",
                        "id": "denoised_copy_ratios",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--denoised-copy-ratios",
                            "shellQuote": false
                        },
                        "label": "Denoised copy ratios",
                        "doc": "Input file containing denoised copy ratios (output of denoisereadcounts).",
                        "sbg:fileTypes": "TSV"
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
                        "sbg:toolDefaultValue": "1000000",
                        "id": "minimum_contig_length",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--minimum-contig-length",
                            "shellQuote": false
                        },
                        "label": "Minimum contig length",
                        "doc": "Threshold length (in bp) for contigs to be plotted. Contigs with lengths less than this threshold will not be plotted. This can be used to filter out mitochondrial contigs, unlocalized contigs, etc."
                    },
                    {
                        "sbg:category": "Required Arguments",
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Prefix for output filenames."
                    },
                    {
                        "sbg:altPrefix": "-sequence-dictionary",
                        "sbg:category": "Required Arguments",
                        "id": "sequence_dictionary",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--sequence-dictionary",
                            "shellQuote": false
                        },
                        "label": "Sequence dictionary",
                        "doc": "File containing a sequence dictionary, which specifies the contigs to be plotted and their relative lengths. The sequence dictionary must be a subset of those contained in other input files. Contigs will be plotted in the order given. Contig names should not include the string \"contig_delimiter\". The tool only considers contigs in the given dictionary for plotting, and data for contigs absent in the dictionary generate only a warning. In other words, you may modify a reference dictionary for use with this tool to include only contigs for which plotting is desired, and sort the contigs to the order in which the plots should display the contigs.",
                        "sbg:fileTypes": "DICT"
                    },
                    {
                        "sbg:category": "Required Arguments",
                        "id": "standardized_copy_ratios",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--standardized-copy-ratios",
                            "shellQuote": false
                        },
                        "label": "Standardized copy ratios",
                        "doc": "Input file containing standardized copy ratios (output of denoisereadcounts).",
                        "sbg:fileTypes": "TSV"
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
                        "id": "denoised_plot",
                        "doc": "Plot showing the standardized and denoised copy ratios; covers the entire range of the copy ratios.",
                        "label": "Denoised plot",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.denoised.png",
                            "outputEval": "$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios) : self)"
                        },
                        "sbg:fileTypes": "PNG"
                    },
                    {
                        "id": "denoised_limit_plot",
                        "doc": "Plot showing the standardized and denoised copy ratios limited to copy ratios within [0, 4].",
                        "label": "Denoised limit plot",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.denoisedLimit4.png",
                            "outputEval": "$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios) : self)"
                        },
                        "sbg:fileTypes": "PNG"
                    },
                    {
                        "id": "delta_mad",
                        "doc": "Delta median-absolute-deviation file.",
                        "label": "Delta MAD",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.deltaMAD.txt",
                            "outputEval": "$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios) : self)"
                        },
                        "sbg:fileTypes": "TXT"
                    },
                    {
                        "id": "denoised_mad",
                        "doc": "Denoised median-absolute-deviation file.",
                        "label": "Denoised MAD",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.denoisedMAD.txt",
                            "outputEval": "$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios) : self)"
                        },
                        "sbg:fileTypes": "TXT"
                    },
                    {
                        "id": "scaled_delta_mad",
                        "doc": "Scaled median-absolute-deviation file.",
                        "label": "Scaled delta MAD",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.scaledDeltaMAD.txt",
                            "outputEval": "$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios) : self)"
                        },
                        "sbg:fileTypes": "TXT"
                    },
                    {
                        "id": "standardized_mad",
                        "doc": "Standardized median-absolute-deviation file.",
                        "label": "Standardized MAD",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.standardizedMAD.txt",
                            "outputEval": "$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios) : self)"
                        },
                        "sbg:fileTypes": "TXT"
                    }
                ],
                "doc": "GATK PlotDenoisedCopytRatios creates plots of denoised copy ratios as well as various denoising metrics.\n\n### Common Use Cases\nThis tool plots standardized and denoised copy ratios from **DenoiseReadCounts**. Some of the input parameters are listed below: \n* **Standardized copy ratios** (`--standardized-copy-ratios`)- TSV file with standardized copy ratios, output of **DenoiseReadCounts**.\n* **Denoised copy ratios** (`--denoised-copy-ratios`) - TSV file with denoised copy ratios, output of **DenoiseReadCounts**.\n* **Sequence dictionary** (`--sequence-dictionary`) - This determines the order and representation of contigs in the plot.\n* **Output prefix** (`--output-prefix`) - This is used as the basename for output files.\n\n### Changes Introduced by Seven Bridges\n* If **Output prefix** is not specified, the prefix for the output files will be derived from the base name of  **Denoised copy ratios** input file.\n\n### Common Issues and Important Notes\n* *No issues have been identified thus far.*\n\n### Performance Benchmarking\n\n| Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- |\n| 10MB | WES | 3min | $0.01 | c4.2xlarge |\n| 120MB | WGS | 3min | $0.01 | c4.2xlarge |",
                "label": "GATK PlotDenoisedCopyRatios",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$( inputs.denoised_copy_ratios ? '/opt/gatk' : 'echo /opt/gatk')"
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
                        "valueFrom": "PlotDenoisedCopyRatios"
                    },
                    {
                        "position": 4,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "."
                    },
                    {
                        "position": 5,
                        "prefix": "--output-prefix",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.output_prefix) {\n            return inputs.output_prefix;\n        }\n        return inputs.denoised_copy_ratios.nameroot.split('.').slice(0,-1).join('.');\n    }\n    return '';\n}"
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
                    "Genomics",
                    "Copy Number Variant Calling"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551312245,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551312270,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553172124,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553686104,
                        "sbg:revisionNotes": "fix description input section; add output file descriptions and file formats"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553686304,
                        "sbg:revisionNotes": "fix description, add sections"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553686334,
                        "sbg:revisionNotes": "add input file formats"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553686391,
                        "sbg:revisionNotes": "add descriptions and default values for memory per job, memory overhaed and cpu per job inputs"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553694148,
                        "sbg:revisionNotes": "remove outputs section of the descrition; merge inputs section with common use cases to match formatting of other tools"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553781410,
                        "sbg:revisionNotes": "add benchmarking info"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553814703,
                        "sbg:revisionNotes": "set denoised_copy_ratios, standardized_copy_ratios and sequence_dictionary inputs to required"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553815525,
                        "sbg:revisionNotes": "fix conditional metadata inheritance for all output files"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559310632,
                        "sbg:revisionNotes": "fix js expressions, add vars and semicolons;"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-plotdenoisedcopyratios-4-1-0-0/11",
                "sbg:revision": 11,
                "sbg:revisionNotes": "fix js expressions, add vars and semicolons;",
                "sbg:modifiedOn": 1559310632,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1551312245,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 11,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a403dfb22469adf0a87b544e91de82d0ab1dcbc3063e52ce8b4c0ff084f0df87b"
            },
            "label": "GATK PlotDenoisedCopyRatios Tumor",
            "sbg:x": 949.60400390625,
            "sbg:y": 121.78529357910156
        },
        {
            "id": "gatk_plotdenoisedcopyratios_normal",
            "in": [
                {
                    "id": "denoised_copy_ratios",
                    "source": "gatk_denoisereadcounts_normal/out_denoised_copy_ratios"
                },
                {
                    "id": "memory_per_job",
                    "default": 7000
                },
                {
                    "id": "minimum_contig_length",
                    "source": "minimum_contig_length"
                },
                {
                    "id": "output_prefix",
                    "source": "gatk_collectreadcounts_normal/entity_id"
                },
                {
                    "id": "sequence_dictionary",
                    "source": "sequence_dictionary"
                },
                {
                    "id": "standardized_copy_ratios",
                    "source": "gatk_denoisereadcounts_normal/out_standardized_copy_ratios"
                }
            ],
            "out": [
                {
                    "id": "denoised_plot"
                },
                {
                    "id": "denoised_limit_plot"
                },
                {
                    "id": "delta_mad"
                },
                {
                    "id": "denoised_mad"
                },
                {
                    "id": "scaled_delta_mad"
                },
                {
                    "id": "standardized_mad"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-plotdenoisedcopyratios-4-1-0-0/11",
                "baseCommand": [],
                "inputs": [
                    {
                        "sbg:category": "Required Arguments",
                        "id": "denoised_copy_ratios",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--denoised-copy-ratios",
                            "shellQuote": false
                        },
                        "label": "Denoised copy ratios",
                        "doc": "Input file containing denoised copy ratios (output of denoisereadcounts).",
                        "sbg:fileTypes": "TSV"
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
                        "sbg:toolDefaultValue": "1000000",
                        "id": "minimum_contig_length",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--minimum-contig-length",
                            "shellQuote": false
                        },
                        "label": "Minimum contig length",
                        "doc": "Threshold length (in bp) for contigs to be plotted. Contigs with lengths less than this threshold will not be plotted. This can be used to filter out mitochondrial contigs, unlocalized contigs, etc."
                    },
                    {
                        "sbg:category": "Required Arguments",
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Prefix for output filenames."
                    },
                    {
                        "sbg:altPrefix": "-sequence-dictionary",
                        "sbg:category": "Required Arguments",
                        "id": "sequence_dictionary",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--sequence-dictionary",
                            "shellQuote": false
                        },
                        "label": "Sequence dictionary",
                        "doc": "File containing a sequence dictionary, which specifies the contigs to be plotted and their relative lengths. The sequence dictionary must be a subset of those contained in other input files. Contigs will be plotted in the order given. Contig names should not include the string \"contig_delimiter\". The tool only considers contigs in the given dictionary for plotting, and data for contigs absent in the dictionary generate only a warning. In other words, you may modify a reference dictionary for use with this tool to include only contigs for which plotting is desired, and sort the contigs to the order in which the plots should display the contigs.",
                        "sbg:fileTypes": "DICT"
                    },
                    {
                        "sbg:category": "Required Arguments",
                        "id": "standardized_copy_ratios",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--standardized-copy-ratios",
                            "shellQuote": false
                        },
                        "label": "Standardized copy ratios",
                        "doc": "Input file containing standardized copy ratios (output of denoisereadcounts).",
                        "sbg:fileTypes": "TSV"
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
                        "id": "denoised_plot",
                        "doc": "Plot showing the standardized and denoised copy ratios; covers the entire range of the copy ratios.",
                        "label": "Denoised plot",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.denoised.png",
                            "outputEval": "$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios) : self)"
                        },
                        "sbg:fileTypes": "PNG"
                    },
                    {
                        "id": "denoised_limit_plot",
                        "doc": "Plot showing the standardized and denoised copy ratios limited to copy ratios within [0, 4].",
                        "label": "Denoised limit plot",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.denoisedLimit4.png",
                            "outputEval": "$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios) : self)"
                        },
                        "sbg:fileTypes": "PNG"
                    },
                    {
                        "id": "delta_mad",
                        "doc": "Delta median-absolute-deviation file.",
                        "label": "Delta MAD",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.deltaMAD.txt",
                            "outputEval": "$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios) : self)"
                        },
                        "sbg:fileTypes": "TXT"
                    },
                    {
                        "id": "denoised_mad",
                        "doc": "Denoised median-absolute-deviation file.",
                        "label": "Denoised MAD",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.denoisedMAD.txt",
                            "outputEval": "$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios) : self)"
                        },
                        "sbg:fileTypes": "TXT"
                    },
                    {
                        "id": "scaled_delta_mad",
                        "doc": "Scaled median-absolute-deviation file.",
                        "label": "Scaled delta MAD",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.scaledDeltaMAD.txt",
                            "outputEval": "$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios) : self)"
                        },
                        "sbg:fileTypes": "TXT"
                    },
                    {
                        "id": "standardized_mad",
                        "doc": "Standardized median-absolute-deviation file.",
                        "label": "Standardized MAD",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.standardizedMAD.txt",
                            "outputEval": "$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios) : self)"
                        },
                        "sbg:fileTypes": "TXT"
                    }
                ],
                "doc": "GATK PlotDenoisedCopytRatios creates plots of denoised copy ratios as well as various denoising metrics.\n\n### Common Use Cases\nThis tool plots standardized and denoised copy ratios from **DenoiseReadCounts**. Some of the input parameters are listed below: \n* **Standardized copy ratios** (`--standardized-copy-ratios`)- TSV file with standardized copy ratios, output of **DenoiseReadCounts**.\n* **Denoised copy ratios** (`--denoised-copy-ratios`) - TSV file with denoised copy ratios, output of **DenoiseReadCounts**.\n* **Sequence dictionary** (`--sequence-dictionary`) - This determines the order and representation of contigs in the plot.\n* **Output prefix** (`--output-prefix`) - This is used as the basename for output files.\n\n### Changes Introduced by Seven Bridges\n* If **Output prefix** is not specified, the prefix for the output files will be derived from the base name of  **Denoised copy ratios** input file.\n\n### Common Issues and Important Notes\n* *No issues have been identified thus far.*\n\n### Performance Benchmarking\n\n| Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- |\n| 10MB | WES | 3min | $0.01 | c4.2xlarge |\n| 120MB | WGS | 3min | $0.01 | c4.2xlarge |",
                "label": "GATK PlotDenoisedCopyRatios",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$( inputs.denoised_copy_ratios ? '/opt/gatk' : 'echo /opt/gatk')"
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
                        "valueFrom": "PlotDenoisedCopyRatios"
                    },
                    {
                        "position": 4,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "."
                    },
                    {
                        "position": 5,
                        "prefix": "--output-prefix",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.output_prefix) {\n            return inputs.output_prefix;\n        }\n        return inputs.denoised_copy_ratios.nameroot.split('.').slice(0,-1).join('.');\n    }\n    return '';\n}"
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
                    "Genomics",
                    "Copy Number Variant Calling"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551312245,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551312270,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553172124,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553686104,
                        "sbg:revisionNotes": "fix description input section; add output file descriptions and file formats"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553686304,
                        "sbg:revisionNotes": "fix description, add sections"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553686334,
                        "sbg:revisionNotes": "add input file formats"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553686391,
                        "sbg:revisionNotes": "add descriptions and default values for memory per job, memory overhaed and cpu per job inputs"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553694148,
                        "sbg:revisionNotes": "remove outputs section of the descrition; merge inputs section with common use cases to match formatting of other tools"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553781410,
                        "sbg:revisionNotes": "add benchmarking info"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553814703,
                        "sbg:revisionNotes": "set denoised_copy_ratios, standardized_copy_ratios and sequence_dictionary inputs to required"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553815525,
                        "sbg:revisionNotes": "fix conditional metadata inheritance for all output files"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559310632,
                        "sbg:revisionNotes": "fix js expressions, add vars and semicolons;"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-plotdenoisedcopyratios-4-1-0-0/11",
                "sbg:revision": 11,
                "sbg:revisionNotes": "fix js expressions, add vars and semicolons;",
                "sbg:modifiedOn": 1559310632,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1551312245,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 11,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a403dfb22469adf0a87b544e91de82d0ab1dcbc3063e52ce8b4c0ff084f0df87b"
            },
            "label": "GATK PlotDenoisedCopyRatios Normal",
            "sbg:x": 951.8522338867188,
            "sbg:y": 328.0443420410156
        },
        {
            "id": "gatk_modelsegments_tumor",
            "in": [
                {
                    "id": "allelic_counts",
                    "source": "gatk_collectalleliccounts_tumor/allelic_counts"
                },
                {
                    "id": "denoised_copy_ratios",
                    "source": "gatk_denoisereadcounts_tumor/out_denoised_copy_ratios"
                },
                {
                    "id": "genotyping_base_error_rate",
                    "source": "genotyping_base_error_rate"
                },
                {
                    "id": "genotyping_homozygous_log_ratio_threshold",
                    "source": "genotyping_homozygous_log_ratio_threshold"
                },
                {
                    "id": "kernel_approximation_dimension",
                    "source": "kernel_approximation_dimension"
                },
                {
                    "id": "kernel_scaling_allele_fraction",
                    "source": "kernel_scaling_allele_fraction"
                },
                {
                    "id": "kernel_variance_allele_fraction",
                    "source": "kernel_variance_allele_fraction"
                },
                {
                    "id": "kernel_variance_copy_ratio",
                    "source": "kernel_variance_copy_ratio"
                },
                {
                    "id": "maximum_number_of_segments_per_chromosome",
                    "source": "maximum_number_of_segments_per_chromosome"
                },
                {
                    "id": "maximum_number_of_smoothing_iterations",
                    "source": "maximum_number_of_smoothing_iterations"
                },
                {
                    "id": "memory_per_job",
                    "default": 13000,
                    "source": "memory_modelsegments"
                },
                {
                    "id": "minimum_total_allele_count_normal",
                    "source": "minimum_total_allele_count_normal"
                },
                {
                    "id": "minor_allele_fraction_prior_alpha",
                    "source": "minor_allele_fraction_prior_alpha"
                },
                {
                    "id": "normal_allelic_counts",
                    "source": "gatk_collectalleliccounts_normal/allelic_counts"
                },
                {
                    "id": "number_of_burn_in_samples_allele_fraction",
                    "source": "number_of_burn_in_samples_allele_fraction"
                },
                {
                    "id": "number_of_burn_in_samples_copy_ratio",
                    "source": "number_of_burn_in_samples_copy_ratio"
                },
                {
                    "id": "number_of_changepoints_penalty_factor",
                    "source": "number_of_changepoints_penalty_factor"
                },
                {
                    "id": "number_of_samples_allele_fraction",
                    "source": "number_of_samples_allele_fraction"
                },
                {
                    "id": "number_of_samples_copy_ratio",
                    "source": "number_of_samples_copy_ratio"
                },
                {
                    "id": "number_of_smoothing_iterations_per_fit",
                    "source": "number_of_smoothing_iterations_per_fit"
                },
                {
                    "id": "output_prefix",
                    "source": "gatk_collectreadcounts_tumor/entity_id"
                },
                {
                    "id": "smoothing_credible_interval_threshold_allele_fraction",
                    "source": "smoothing_credible_interval_threshold_allele_fraction"
                },
                {
                    "id": "smoothing_credible_interval_threshold_copy_ratio",
                    "source": "smoothing_credible_interval_threshold_copy_ratio"
                },
                {
                    "id": "window_size",
                    "source": [
                        "window_size"
                    ]
                },
                {
                    "id": "minimum_total_allele_count_case",
                    "source": "minimum_total_allele_count_case"
                }
            ],
            "out": [
                {
                    "id": "het_allelic_counts"
                },
                {
                    "id": "normal_het_allelic_counts"
                },
                {
                    "id": "copy_ratio_only_segments"
                },
                {
                    "id": "copy_ratio_legacy_segments"
                },
                {
                    "id": "allele_fraction_legacy_segments"
                },
                {
                    "id": "modeled_segments_begin"
                },
                {
                    "id": "copy_ratio_parameters_begin"
                },
                {
                    "id": "allele_fraction_parameters_begin"
                },
                {
                    "id": "modeled_segments"
                },
                {
                    "id": "copy_ratio_parameters"
                },
                {
                    "id": "allele_fraction_parameters"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-modelsegments-4-1-0-0/22",
                "baseCommand": [],
                "inputs": [
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "allelic_counts",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--allelic-counts",
                            "shellQuote": false
                        },
                        "label": "Allelic counts",
                        "doc": "Input file containing allelic counts (output of **CollectAllelicCounts**).",
                        "sbg:fileTypes": "TSV"
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "denoised_copy_ratios",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--denoised-copy-ratios",
                            "shellQuote": false
                        },
                        "label": "Denoised copy ratios",
                        "doc": "Input file containing denoised copy ratios (output of denoisereadcounts).",
                        "sbg:fileTypes": "TSV"
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "genotyping_base_error_rate",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--genotyping-base-error-rate",
                            "shellQuote": false
                        },
                        "label": "Genotyping base error rate",
                        "doc": "Maximum base-error rate for genotyping and filtering homozygous allelic counts, if available. The likelihood for an allelic count to be generated from a homozygous site will be integrated from zero base-error rate up to this value. Decreasing this value will increase the number of sites assumed to be heterozygous for modeling. 05."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "-10",
                        "id": "genotyping_homozygous_log_ratio_threshold",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--genotyping-homozygous-log-ratio-threshold",
                            "shellQuote": false
                        },
                        "label": "Genotyping homozygous log ratio threshold",
                        "doc": "Log-ratio threshold for genotyping and filtering homozygous allelic counts, if available. Increasing this value will increase the number of sites assumed to be heterozygous for modeling. 0."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "100",
                        "id": "kernel_approximation_dimension",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--kernel-approximation-dimension",
                            "shellQuote": false
                        },
                        "label": "Kernel approximation dimension",
                        "doc": "Dimension of the kernel approximation. A subsample containing this number of data points will be used to construct the approximation for each chromosome. If the total number of data points in a chromosome is greater than this number, then all data points in the chromosome will be used. Time complexity scales quadratically and space complexity scales linearly with this parameter."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "id": "kernel_scaling_allele_fraction",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--kernel-scaling-allele-fraction",
                            "shellQuote": false
                        },
                        "label": "Kernel scaling allele fraction",
                        "doc": "Relative scaling s of the kernel k_af for allele-fraction segmentation to the kernel k_cr for copy-ratio segmentation. If multidimensional segmentation is performed, the total kernel used will be k_cr."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "kernel_variance_allele_fraction",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--kernel-variance-allele-fraction",
                            "shellQuote": false
                        },
                        "label": "Kernel variance allele fraction",
                        "doc": "Variance of gaussian kernel for allele-fraction segmentation, if performed. If zero, a linear kernel will be used. 025."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "kernel_variance_copy_ratio",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--kernel-variance-copy-ratio",
                            "shellQuote": false
                        },
                        "label": "Kernel variance copy ratio",
                        "doc": "Variance of gaussian kernel for copy-ratio segmentation, if performed. If zero, a linear kernel will be used. 0."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "1000",
                        "id": "maximum_number_of_segments_per_chromosome",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--maximum-number-of-segments-per-chromosome",
                            "shellQuote": false
                        },
                        "label": "Maximum number of segments per chromosome",
                        "doc": "Maximum number of segments allowed per chromosome."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "25",
                        "id": "maximum_number_of_smoothing_iterations",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--maximum-number-of-smoothing-iterations",
                            "shellQuote": false
                        },
                        "label": "Maximum number of smoothing iterations",
                        "doc": "Maximum number of iterations allowed for segmentation smoothing."
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
                        "sbg:toolDefaultValue": "30",
                        "id": "minimum_total_allele_count_normal",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--minimum-total-allele-count-normal",
                            "shellQuote": false
                        },
                        "label": "Minimum total allele count normal",
                        "doc": "Minimum total count for filtering allelic counts in matched-normal sample, if available."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "25",
                        "id": "minor_allele_fraction_prior_alpha",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--minor-allele-fraction-prior-alpha",
                            "shellQuote": false
                        },
                        "label": "Minor allele fraction prior alpha",
                        "doc": "Alpha hyperparameter for the 4-parameter beta-distribution prior on segment minor-allele fraction. The prior for the minor-allele fraction f in each segment is assumed to be beta(alpha, 1, 0, 1/2). Increasing this hyperparameter will reduce the effect of reference bias at the expense of sensitivity. 0."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "normal_allelic_counts",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--normal-allelic-counts",
                            "shellQuote": false
                        },
                        "label": "Normal allelic counts",
                        "doc": "Input file containing allelic counts for a matched normal (output of collectalleliccounts).",
                        "sbg:fileTypes": "TSV"
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "50",
                        "id": "number_of_burn_in_samples_allele_fraction",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-burn-in-samples-allele-fraction",
                            "shellQuote": false
                        },
                        "label": "Number of burn in samples allele fraction",
                        "doc": "Number of burn-in samples to discard for allele-fraction model."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "50",
                        "id": "number_of_burn_in_samples_copy_ratio",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-burn-in-samples-copy-ratio",
                            "shellQuote": false
                        },
                        "label": "Number of burn in samples copy ratio",
                        "doc": "Number of burn-in samples to discard for copy-ratio model."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "id": "number_of_changepoints_penalty_factor",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-changepoints-penalty-factor",
                            "shellQuote": false
                        },
                        "label": "Number of changepoints penalty factor",
                        "doc": "Factor a for the penalty on the number of changepoints per chromosome for segmentation. Adds a penalty of the form a."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "100",
                        "id": "number_of_samples_allele_fraction",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-samples-allele-fraction",
                            "shellQuote": false
                        },
                        "label": "Number of samples allele fraction",
                        "doc": "Total number of mcmc samples for allele-fraction model."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "100",
                        "id": "number_of_samples_copy_ratio",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-samples-copy-ratio",
                            "shellQuote": false
                        },
                        "label": "Number of samples copy ratio",
                        "doc": "Total number of mcmc samples for copy-ratio model."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "number_of_smoothing_iterations_per_fit",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-smoothing-iterations-per-fit",
                            "shellQuote": false
                        },
                        "label": "Number of smoothing iterations per fit",
                        "doc": "Number of segmentation-smoothing iterations per mcmc model refit. (increasing this will decrease runtime, but the final number of segments may be higher. Setting this to 0 will completely disable model refitting between iterations.)."
                    },
                    {
                        "sbg:category": "Required Arguments",
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Prefix for output files."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "id": "smoothing_credible_interval_threshold_allele_fraction",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--smoothing-credible-interval-threshold-allele-fraction",
                            "shellQuote": false
                        },
                        "label": "Smoothing credible interval threshold allele fraction",
                        "doc": "Number of 10."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "id": "smoothing_credible_interval_threshold_copy_ratio",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--smoothing-credible-interval-threshold-copy-ratio",
                            "shellQuote": false
                        },
                        "label": "Smoothing credible interval threshold copy ratio",
                        "doc": "Number of 10."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "id": "window_size",
                        "type": "int[]?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--window-size",
                            "shellQuote": false,
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self);\n        return self.join(' --window-size ');\n    }\n    return '';\n}"
                        },
                        "label": "Window size",
                        "doc": "Window sizes to use for calculating local changepoint costs. For each window size, the cost for each data point to be a changepoint will be calculated assuming that the point demarcates two adjacent segments of that size. Including small (large) window sizes will increase sensitivity to small (large) events. Duplicate values will be ignored. Default value:."
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
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "minimum_total_allele_count_case",
                        "type": "int?",
                        "label": "Minimum total allele count case",
                        "doc": "Minimum total count for filtering allelic counts in the case sample, if available.  The default value of zero is appropriate for matched-normal mode; increase to an appropriate value for case-only mode.  Default value: 0."
                    }
                ],
                "outputs": [
                    {
                        "id": "het_allelic_counts",
                        "doc": "Allelic-counts file containing the counts at sites genotyped as heterozygous in the case sample (.hets.tsv). This is a tab-separated values (TSV) file with a SAM-style header containing a read group sample name, a sequence dictionary, a row specifying the column headers contained in AllelicCountCollection. AllelicCountTableColumn, and the corresponding entry rows. This is only output if normal allelic counts are provided as input.",
                        "label": "Allelic counts",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.hets.tsv",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "TSV"
                    },
                    {
                        "id": "normal_het_allelic_counts",
                        "doc": "Allelic-counts file containing the counts at sites genotyped as heterozygous in the matched-normal sample (.hets.normal.tsv).",
                        "label": "Normal allelic counts",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.hets.normal.tsv",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "TSV"
                    },
                    {
                        "id": "copy_ratio_only_segments",
                        "doc": "This is a tab-separated values (TSV) file with a SAM-style header containing a read group sample name, a sequence dictionary, a row specifying the column headers contained in CopyRatioSegmentCollection.CopyRatioSegmentTableColumn, and the corresponding entry rows. It contains the segments from the .modelFinal.seg file converted to a format suitable for input to CallCopyRatioSegments.",
                        "label": "Copy ratio segments",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.cr.seg",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "TSV, SEG"
                    },
                    {
                        "id": "copy_ratio_legacy_segments",
                        "doc": "TSV file with CBS-format column headers and the corresponding entry rows that can be plotted using IGV.",
                        "label": "Copy ratio legacy segments",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.cr.igv.seg",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "SEG, TSV"
                    },
                    {
                        "id": "allele_fraction_legacy_segments",
                        "doc": "TSV file with CBS-format column headers and the corresponding entry rows that can be plotted using IGV.",
                        "label": "Allele fraction legacy segments",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.af.igv.seg",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "SEG, TSV"
                    },
                    {
                        "id": "modeled_segments_begin",
                        "doc": "TSV file containing modeled segments with the initial results before segmentation smoothing.",
                        "label": "Modeled segments begin",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modelBegin.seg",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "SEG, TSV"
                    },
                    {
                        "id": "copy_ratio_parameters_begin",
                        "doc": "Copy ration parametets file with initial result before segmentation smoothing.",
                        "label": "Copy ratio parameters begin",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modelBegin.cr.param",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "PARAM, TSV"
                    },
                    {
                        "id": "allele_fraction_parameters_begin",
                        "doc": "Allele fraction parameters file with initial result before segmentation smoothing.",
                        "label": "Allele fraction parameters begin",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modelBegin.af.param",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "PARAM, TSV"
                    },
                    {
                        "id": "modeled_segments",
                        "doc": "TSV file containing modeled segments with the final results after segmentation smoothing.",
                        "label": "Modeled segments final",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modelFinal.seg",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "SEG, TSV"
                    },
                    {
                        "id": "copy_ratio_parameters",
                        "doc": "Copy ration parameters file with final result after segmentation smoothing.",
                        "label": "Copy ratio parameters final",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modelFinal.cr.param",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "PARAM, TSV"
                    },
                    {
                        "id": "allele_fraction_parameters",
                        "doc": "Allele fraction parameters file with final result after segmentation smoothing.",
                        "label": "Allele fraction parameters final",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modelFinal.af.param",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "PARAM, TSV"
                    }
                ],
                "doc": "GATK ModelSegmens models segmented copy ratios from denoised read counts and segmented minor-allele fractions from allelic counts.\n\n\n### Common Use Cases\n\nPossible inputs are: 1) denoised copy ratios for the case sample, 2) allelic counts for the case sample, and 3) allelic counts for a matched-normal sample. All available inputs will be used to to perform segmentation and model inference.\nIf allelic counts are available, the first step in the inference process is to genotype heterozygous sites, as the allelic counts at these sites will subsequently be modeled to infer segmented minor-allele fraction. We perform a relatively simple and naive genotyping based on the allele counts (i.e., pileups), which is controlled by a small number of parameters (minimum-total-allele-count, genotyping-homozygous-log-ratio-threshold, and genotyping-homozygous-log-ratio-threshold). If the matched normal is available, its allelic counts will be used to genotype the sites, and we will simply assume these genotypes are the same in the case sample. (This can be critical, for example, for determining sites with loss of heterozygosity in high purity case samples; such sites will be genotyped as homozygous if the matched-normal sample is not available.)\n\nNext, if available, the denoised copy ratios are segmented and the alternate-allele fractions at the genotyped heterozygous sites. This is done using kernel segmentation (see **KernelSegmenter**). Various segmentation parameters control the sensitivity of the segmentation and should be selected appropriately for each analysis.\n\nIf both copy ratios and allele fractions are available, we perform segmentation using a combined kernel that is sensitive to changes that occur not only in either of the two but also in both. However, in this case, we simply discard all allele fractions at sites that lie outside of the available copy-ratio intervals (rather than imputing the missing copy-ratio data); these sites are filtered out during the genotyping step discussed above. This can have implications for analyses involving the sex chromosomes; see comments in **CreateReadCountPanelOfNormals**.\n\nAfter segmentation is complete, we run Markov-chain Monte Carlo (MCMC) to determine posteriors for segmented models for the log2 copy ratio and the minor-allele fraction; see **CopyRatioModeller** and **AlleleFractionModeller**, respectively. After the first run of MCMC is complete, smoothing of the segmented posteriors is performed by merging adjacent segments whose posterior credible intervals sufficiently overlap according to specified segmentation-smoothing parameters. Then, additional rounds of segmentation smoothing (with intermediate MCMC optionally performed in between rounds) are performed until convergence, at which point a final round of MCMC is performed.\n\n*Source: [https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_ModelSegments.php](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_ModelSegments.php)*\n\nSome of the input parameters are listed below:\n* **Denoised copy ratios** (`--denoised-copy-ratios`) - TSV file with denoised copy rations, output of **DenoiseReadCounts**. If allelic counts are not provided, then this is required.\n* **Allelic counts** (`--allelic-counts`) - TSV file containing alt and ref allelic count at specified positions, output of **CollectAllelicCounts**. If denoised copy ratios are not provided, then this is required.\n* **Normal allelic counts** (`--normal-allelic-counts`) - TSV file containing allelic counts of matched normal sample, output of **CollectAllelicCounts**. This can only be provided if allelic counts for the case sample are also provided.\n* **Output prefix** (`--output-prefix`) - This is used as the basename for output files. If not specified output files will be named by either **Denoised copy ratios** or **Allelic counts** (see #Changes Introduced by Seven Bridges).\n\n### Changes Introduced by Seven Bridges\n* If **Output prefix** parameter is not specified, the prefix will be derived from the basename of the **Denoised copy ratios** file. In case this file is not specified, the prefix will be derived from the basename of **Allelic counts** file, as one of those two files are required for the execution.\n\n### Common Issues and Important Notes\n* The default 2048 Mb of memory may not be sufficient for average analysis. We advise using at least 13000 Mb (13GB) of memory for standard WES analysis and in some cases of WES and WGS analyses as much as 32000 Mb (32GB) may be needed. Memory can be allocated through **Memory per job** input parameter.\n\n### Performance Benchmarking\n\n| Input Size | Experimental Strategy | Memory | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- | --- |\n| 0.2GB | WES | 2048MB | 6min | $0.03 | c4.2xlarge |\n| 2.4GB | WGS | 32000MB | 46min | $0.26 | m5.2xlarge |",
                "label": "GATK ModelSegments",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$( inputs.denoised_copy_ratios ? '/opt/gatk' : 'echo /opt/gatk')"
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
                        "valueFrom": "ModelSegments"
                    },
                    {
                        "position": 4,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "."
                    },
                    {
                        "position": 5,
                        "prefix": "--output-prefix",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.output_prefix) {\n        return inputs.output_prefix;\n    } else {\n        if (inputs.denoised_copy_ratios) {\n            return inputs.denoised_copy_ratios.nameroot.split('.').slice(0,-1).join('.');\n        } else if (inputs.allelic_counts) {\n            return inputs.allelic_counts.nameroot.split('.').slice(0,-1).join('.');\n        } else {\n            return 'output_ModelSegments';\n        }\n    }\n    return 'output_ModelSegments';\n}"
                    },
                    {
                        "position": 4,
                        "prefix": "--minimum-total-allele-count-case",
                        "shellQuote": false,
                        "valueFrom": "${\n    var default_min_count = inputs.normal_allelic_counts ? 0 : 30;\n    var min_count = inputs.minimum_total_allele_count_case ? inputs.minimum_total_allele_count_case : default_min_count;\n    return min_count;\n}"
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
                    "Genomics",
                    "Copy Number Variant Calling"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551312575,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551312599,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551652706,
                        "sbg:revisionNotes": "fix memory requirements expression, remove default overhead, set default memory to 2048"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553170547,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553608892,
                        "sbg:revisionNotes": "fix description formatting, add appropriate sections"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553608968,
                        "sbg:revisionNotes": "add descriptions for memory per job, memory overhead and cpu per job input parameters"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553609643,
                        "sbg:revisionNotes": "add descriptions for output files"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553610141,
                        "sbg:revisionNotes": "fix expression for window_size parameter"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553610382,
                        "sbg:revisionNotes": "add changes by sbg and common issues and notes"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553610953,
                        "sbg:revisionNotes": "fix output files section in description"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553611081,
                        "sbg:revisionNotes": "add file formats for file inputs"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553612058,
                        "sbg:revisionNotes": "set output_prefix as required input argument, include in command line"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553612766,
                        "sbg:revisionNotes": "fix output naming, include in description; fix inputs formatting in description"
                    },
                    {
                        "sbg:revision": 13,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553613281,
                        "sbg:revisionNotes": "add metadata inheritance for two output files, for testing"
                    },
                    {
                        "sbg:revision": 14,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553691217,
                        "sbg:revisionNotes": "fix expression typo"
                    },
                    {
                        "sbg:revision": 15,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553694005,
                        "sbg:revisionNotes": "remove outputs section from description; merge input section with common use cases to match format of other tools"
                    },
                    {
                        "sbg:revision": 16,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553769659,
                        "sbg:revisionNotes": "add benchmarking info"
                    },
                    {
                        "sbg:revision": 17,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1554081721,
                        "sbg:revisionNotes": "add expression for min_total_allele_count_case"
                    },
                    {
                        "sbg:revision": 18,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1558970988,
                        "sbg:revisionNotes": "fix metadata inheritance on all output files"
                    },
                    {
                        "sbg:revision": 19,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1558971762,
                        "sbg:revisionNotes": "fix medatada expression"
                    },
                    {
                        "sbg:revision": 20,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1558972446,
                        "sbg:revisionNotes": "fix js expression for metadata"
                    },
                    {
                        "sbg:revision": 21,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559050538,
                        "sbg:revisionNotes": "edit expression for output evals"
                    },
                    {
                        "sbg:revision": 22,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559309194,
                        "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-modelsegments-4-1-0-0/22",
                "sbg:revision": 22,
                "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons",
                "sbg:modifiedOn": 1559309194,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1551312575,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 22,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a8bf865c5a923254e11991e436ebf879b7d72191a759cd51416a779f9d6172555"
            },
            "label": "GATK ModelSegments Tumor",
            "sbg:x": 1283.28076171875,
            "sbg:y": -811.0526123046875
        },
        {
            "id": "gatk_modelsegments_normal",
            "in": [
                {
                    "id": "allelic_counts",
                    "source": "gatk_collectalleliccounts_normal/allelic_counts"
                },
                {
                    "id": "denoised_copy_ratios",
                    "source": "gatk_denoisereadcounts_normal/out_denoised_copy_ratios"
                },
                {
                    "id": "genotyping_base_error_rate",
                    "source": "genotyping_base_error_rate"
                },
                {
                    "id": "genotyping_homozygous_log_ratio_threshold",
                    "source": "genotyping_homozygous_log_ratio_threshold"
                },
                {
                    "id": "kernel_approximation_dimension",
                    "source": "kernel_approximation_dimension"
                },
                {
                    "id": "kernel_scaling_allele_fraction",
                    "source": "kernel_scaling_allele_fraction"
                },
                {
                    "id": "kernel_variance_allele_fraction",
                    "source": "kernel_variance_allele_fraction"
                },
                {
                    "id": "kernel_variance_copy_ratio",
                    "source": "kernel_variance_copy_ratio"
                },
                {
                    "id": "maximum_number_of_segments_per_chromosome",
                    "source": "maximum_number_of_segments_per_chromosome"
                },
                {
                    "id": "maximum_number_of_smoothing_iterations",
                    "source": "maximum_number_of_smoothing_iterations"
                },
                {
                    "id": "memory_per_job",
                    "default": 13000,
                    "source": "memory_modelsegments"
                },
                {
                    "id": "minimum_total_allele_count_normal",
                    "source": "minimum_total_allele_count_normal"
                },
                {
                    "id": "minor_allele_fraction_prior_alpha",
                    "source": "minor_allele_fraction_prior_alpha"
                },
                {
                    "id": "number_of_burn_in_samples_allele_fraction",
                    "source": "number_of_burn_in_samples_allele_fraction"
                },
                {
                    "id": "number_of_burn_in_samples_copy_ratio",
                    "source": "number_of_burn_in_samples_copy_ratio"
                },
                {
                    "id": "number_of_changepoints_penalty_factor",
                    "source": "number_of_changepoints_penalty_factor"
                },
                {
                    "id": "number_of_samples_allele_fraction",
                    "source": "number_of_samples_allele_fraction"
                },
                {
                    "id": "number_of_samples_copy_ratio",
                    "source": "number_of_samples_copy_ratio"
                },
                {
                    "id": "number_of_smoothing_iterations_per_fit",
                    "source": "number_of_smoothing_iterations_per_fit"
                },
                {
                    "id": "output_prefix",
                    "source": "gatk_collectreadcounts_normal/entity_id"
                },
                {
                    "id": "smoothing_credible_interval_threshold_allele_fraction",
                    "source": "smoothing_credible_interval_threshold_allele_fraction"
                },
                {
                    "id": "smoothing_credible_interval_threshold_copy_ratio",
                    "source": "smoothing_credible_interval_threshold_copy_ratio"
                },
                {
                    "id": "window_size",
                    "source": [
                        "window_size"
                    ]
                },
                {
                    "id": "minimum_total_allele_count_case",
                    "source": "minimum_total_allele_count_case"
                }
            ],
            "out": [
                {
                    "id": "het_allelic_counts"
                },
                {
                    "id": "normal_het_allelic_counts"
                },
                {
                    "id": "copy_ratio_only_segments"
                },
                {
                    "id": "copy_ratio_legacy_segments"
                },
                {
                    "id": "allele_fraction_legacy_segments"
                },
                {
                    "id": "modeled_segments_begin"
                },
                {
                    "id": "copy_ratio_parameters_begin"
                },
                {
                    "id": "allele_fraction_parameters_begin"
                },
                {
                    "id": "modeled_segments"
                },
                {
                    "id": "copy_ratio_parameters"
                },
                {
                    "id": "allele_fraction_parameters"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-modelsegments-4-1-0-0/22",
                "baseCommand": [],
                "inputs": [
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "allelic_counts",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--allelic-counts",
                            "shellQuote": false
                        },
                        "label": "Allelic counts",
                        "doc": "Input file containing allelic counts (output of **CollectAllelicCounts**).",
                        "sbg:fileTypes": "TSV"
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "denoised_copy_ratios",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--denoised-copy-ratios",
                            "shellQuote": false
                        },
                        "label": "Denoised copy ratios",
                        "doc": "Input file containing denoised copy ratios (output of denoisereadcounts).",
                        "sbg:fileTypes": "TSV"
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "genotyping_base_error_rate",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--genotyping-base-error-rate",
                            "shellQuote": false
                        },
                        "label": "Genotyping base error rate",
                        "doc": "Maximum base-error rate for genotyping and filtering homozygous allelic counts, if available. The likelihood for an allelic count to be generated from a homozygous site will be integrated from zero base-error rate up to this value. Decreasing this value will increase the number of sites assumed to be heterozygous for modeling. 05."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "-10",
                        "id": "genotyping_homozygous_log_ratio_threshold",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--genotyping-homozygous-log-ratio-threshold",
                            "shellQuote": false
                        },
                        "label": "Genotyping homozygous log ratio threshold",
                        "doc": "Log-ratio threshold for genotyping and filtering homozygous allelic counts, if available. Increasing this value will increase the number of sites assumed to be heterozygous for modeling. 0."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "100",
                        "id": "kernel_approximation_dimension",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--kernel-approximation-dimension",
                            "shellQuote": false
                        },
                        "label": "Kernel approximation dimension",
                        "doc": "Dimension of the kernel approximation. A subsample containing this number of data points will be used to construct the approximation for each chromosome. If the total number of data points in a chromosome is greater than this number, then all data points in the chromosome will be used. Time complexity scales quadratically and space complexity scales linearly with this parameter."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "id": "kernel_scaling_allele_fraction",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--kernel-scaling-allele-fraction",
                            "shellQuote": false
                        },
                        "label": "Kernel scaling allele fraction",
                        "doc": "Relative scaling s of the kernel k_af for allele-fraction segmentation to the kernel k_cr for copy-ratio segmentation. If multidimensional segmentation is performed, the total kernel used will be k_cr."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "kernel_variance_allele_fraction",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--kernel-variance-allele-fraction",
                            "shellQuote": false
                        },
                        "label": "Kernel variance allele fraction",
                        "doc": "Variance of gaussian kernel for allele-fraction segmentation, if performed. If zero, a linear kernel will be used. 025."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "kernel_variance_copy_ratio",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--kernel-variance-copy-ratio",
                            "shellQuote": false
                        },
                        "label": "Kernel variance copy ratio",
                        "doc": "Variance of gaussian kernel for copy-ratio segmentation, if performed. If zero, a linear kernel will be used. 0."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "1000",
                        "id": "maximum_number_of_segments_per_chromosome",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--maximum-number-of-segments-per-chromosome",
                            "shellQuote": false
                        },
                        "label": "Maximum number of segments per chromosome",
                        "doc": "Maximum number of segments allowed per chromosome."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "25",
                        "id": "maximum_number_of_smoothing_iterations",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--maximum-number-of-smoothing-iterations",
                            "shellQuote": false
                        },
                        "label": "Maximum number of smoothing iterations",
                        "doc": "Maximum number of iterations allowed for segmentation smoothing."
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
                        "sbg:toolDefaultValue": "30",
                        "id": "minimum_total_allele_count_normal",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--minimum-total-allele-count-normal",
                            "shellQuote": false
                        },
                        "label": "Minimum total allele count normal",
                        "doc": "Minimum total count for filtering allelic counts in matched-normal sample, if available."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "25",
                        "id": "minor_allele_fraction_prior_alpha",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--minor-allele-fraction-prior-alpha",
                            "shellQuote": false
                        },
                        "label": "Minor allele fraction prior alpha",
                        "doc": "Alpha hyperparameter for the 4-parameter beta-distribution prior on segment minor-allele fraction. The prior for the minor-allele fraction f in each segment is assumed to be beta(alpha, 1, 0, 1/2). Increasing this hyperparameter will reduce the effect of reference bias at the expense of sensitivity. 0."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "normal_allelic_counts",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--normal-allelic-counts",
                            "shellQuote": false
                        },
                        "label": "Normal allelic counts",
                        "doc": "Input file containing allelic counts for a matched normal (output of collectalleliccounts).",
                        "sbg:fileTypes": "TSV"
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "50",
                        "id": "number_of_burn_in_samples_allele_fraction",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-burn-in-samples-allele-fraction",
                            "shellQuote": false
                        },
                        "label": "Number of burn in samples allele fraction",
                        "doc": "Number of burn-in samples to discard for allele-fraction model."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "50",
                        "id": "number_of_burn_in_samples_copy_ratio",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-burn-in-samples-copy-ratio",
                            "shellQuote": false
                        },
                        "label": "Number of burn in samples copy ratio",
                        "doc": "Number of burn-in samples to discard for copy-ratio model."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "id": "number_of_changepoints_penalty_factor",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-changepoints-penalty-factor",
                            "shellQuote": false
                        },
                        "label": "Number of changepoints penalty factor",
                        "doc": "Factor a for the penalty on the number of changepoints per chromosome for segmentation. Adds a penalty of the form a."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "100",
                        "id": "number_of_samples_allele_fraction",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-samples-allele-fraction",
                            "shellQuote": false
                        },
                        "label": "Number of samples allele fraction",
                        "doc": "Total number of mcmc samples for allele-fraction model."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "100",
                        "id": "number_of_samples_copy_ratio",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-samples-copy-ratio",
                            "shellQuote": false
                        },
                        "label": "Number of samples copy ratio",
                        "doc": "Total number of mcmc samples for copy-ratio model."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "number_of_smoothing_iterations_per_fit",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--number-of-smoothing-iterations-per-fit",
                            "shellQuote": false
                        },
                        "label": "Number of smoothing iterations per fit",
                        "doc": "Number of segmentation-smoothing iterations per mcmc model refit. (increasing this will decrease runtime, but the final number of segments may be higher. Setting this to 0 will completely disable model refitting between iterations.)."
                    },
                    {
                        "sbg:category": "Required Arguments",
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Prefix for output files."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "id": "smoothing_credible_interval_threshold_allele_fraction",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--smoothing-credible-interval-threshold-allele-fraction",
                            "shellQuote": false
                        },
                        "label": "Smoothing credible interval threshold allele fraction",
                        "doc": "Number of 10."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "id": "smoothing_credible_interval_threshold_copy_ratio",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--smoothing-credible-interval-threshold-copy-ratio",
                            "shellQuote": false
                        },
                        "label": "Smoothing credible interval threshold copy ratio",
                        "doc": "Number of 10."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "id": "window_size",
                        "type": "int[]?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--window-size",
                            "shellQuote": false,
                            "valueFrom": "${\n    if (self) {\n        self = [].concat(self);\n        return self.join(' --window-size ');\n    }\n    return '';\n}"
                        },
                        "label": "Window size",
                        "doc": "Window sizes to use for calculating local changepoint costs. For each window size, the cost for each data point to be a changepoint will be calculated assuming that the point demarcates two adjacent segments of that size. Including small (large) window sizes will increase sensitivity to small (large) events. Duplicate values will be ignored. Default value:."
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
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "0",
                        "id": "minimum_total_allele_count_case",
                        "type": "int?",
                        "label": "Minimum total allele count case",
                        "doc": "Minimum total count for filtering allelic counts in the case sample, if available.  The default value of zero is appropriate for matched-normal mode; increase to an appropriate value for case-only mode.  Default value: 0."
                    }
                ],
                "outputs": [
                    {
                        "id": "het_allelic_counts",
                        "doc": "Allelic-counts file containing the counts at sites genotyped as heterozygous in the case sample (.hets.tsv). This is a tab-separated values (TSV) file with a SAM-style header containing a read group sample name, a sequence dictionary, a row specifying the column headers contained in AllelicCountCollection. AllelicCountTableColumn, and the corresponding entry rows. This is only output if normal allelic counts are provided as input.",
                        "label": "Allelic counts",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.hets.tsv",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "TSV"
                    },
                    {
                        "id": "normal_het_allelic_counts",
                        "doc": "Allelic-counts file containing the counts at sites genotyped as heterozygous in the matched-normal sample (.hets.normal.tsv).",
                        "label": "Normal allelic counts",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.hets.normal.tsv",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "TSV"
                    },
                    {
                        "id": "copy_ratio_only_segments",
                        "doc": "This is a tab-separated values (TSV) file with a SAM-style header containing a read group sample name, a sequence dictionary, a row specifying the column headers contained in CopyRatioSegmentCollection.CopyRatioSegmentTableColumn, and the corresponding entry rows. It contains the segments from the .modelFinal.seg file converted to a format suitable for input to CallCopyRatioSegments.",
                        "label": "Copy ratio segments",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.cr.seg",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "TSV, SEG"
                    },
                    {
                        "id": "copy_ratio_legacy_segments",
                        "doc": "TSV file with CBS-format column headers and the corresponding entry rows that can be plotted using IGV.",
                        "label": "Copy ratio legacy segments",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.cr.igv.seg",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "SEG, TSV"
                    },
                    {
                        "id": "allele_fraction_legacy_segments",
                        "doc": "TSV file with CBS-format column headers and the corresponding entry rows that can be plotted using IGV.",
                        "label": "Allele fraction legacy segments",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.af.igv.seg",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "SEG, TSV"
                    },
                    {
                        "id": "modeled_segments_begin",
                        "doc": "TSV file containing modeled segments with the initial results before segmentation smoothing.",
                        "label": "Modeled segments begin",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modelBegin.seg",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "SEG, TSV"
                    },
                    {
                        "id": "copy_ratio_parameters_begin",
                        "doc": "Copy ration parametets file with initial result before segmentation smoothing.",
                        "label": "Copy ratio parameters begin",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modelBegin.cr.param",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "PARAM, TSV"
                    },
                    {
                        "id": "allele_fraction_parameters_begin",
                        "doc": "Allele fraction parameters file with initial result before segmentation smoothing.",
                        "label": "Allele fraction parameters begin",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modelBegin.af.param",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "PARAM, TSV"
                    },
                    {
                        "id": "modeled_segments",
                        "doc": "TSV file containing modeled segments with the final results after segmentation smoothing.",
                        "label": "Modeled segments final",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modelFinal.seg",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "SEG, TSV"
                    },
                    {
                        "id": "copy_ratio_parameters",
                        "doc": "Copy ration parameters file with final result after segmentation smoothing.",
                        "label": "Copy ratio parameters final",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modelFinal.cr.param",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "PARAM, TSV"
                    },
                    {
                        "id": "allele_fraction_parameters",
                        "doc": "Allele fraction parameters file with final result after segmentation smoothing.",
                        "label": "Allele fraction parameters final",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modelFinal.af.param",
                            "outputEval": "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out = inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata) {\n            out = inheritMetadata(self, inputs.allelic_counts);\n            return out;\n        }\n    }\n    return self;\n}"
                        },
                        "sbg:fileTypes": "PARAM, TSV"
                    }
                ],
                "doc": "GATK ModelSegmens models segmented copy ratios from denoised read counts and segmented minor-allele fractions from allelic counts.\n\n\n### Common Use Cases\n\nPossible inputs are: 1) denoised copy ratios for the case sample, 2) allelic counts for the case sample, and 3) allelic counts for a matched-normal sample. All available inputs will be used to to perform segmentation and model inference.\nIf allelic counts are available, the first step in the inference process is to genotype heterozygous sites, as the allelic counts at these sites will subsequently be modeled to infer segmented minor-allele fraction. We perform a relatively simple and naive genotyping based on the allele counts (i.e., pileups), which is controlled by a small number of parameters (minimum-total-allele-count, genotyping-homozygous-log-ratio-threshold, and genotyping-homozygous-log-ratio-threshold). If the matched normal is available, its allelic counts will be used to genotype the sites, and we will simply assume these genotypes are the same in the case sample. (This can be critical, for example, for determining sites with loss of heterozygosity in high purity case samples; such sites will be genotyped as homozygous if the matched-normal sample is not available.)\n\nNext, if available, the denoised copy ratios are segmented and the alternate-allele fractions at the genotyped heterozygous sites. This is done using kernel segmentation (see **KernelSegmenter**). Various segmentation parameters control the sensitivity of the segmentation and should be selected appropriately for each analysis.\n\nIf both copy ratios and allele fractions are available, we perform segmentation using a combined kernel that is sensitive to changes that occur not only in either of the two but also in both. However, in this case, we simply discard all allele fractions at sites that lie outside of the available copy-ratio intervals (rather than imputing the missing copy-ratio data); these sites are filtered out during the genotyping step discussed above. This can have implications for analyses involving the sex chromosomes; see comments in **CreateReadCountPanelOfNormals**.\n\nAfter segmentation is complete, we run Markov-chain Monte Carlo (MCMC) to determine posteriors for segmented models for the log2 copy ratio and the minor-allele fraction; see **CopyRatioModeller** and **AlleleFractionModeller**, respectively. After the first run of MCMC is complete, smoothing of the segmented posteriors is performed by merging adjacent segments whose posterior credible intervals sufficiently overlap according to specified segmentation-smoothing parameters. Then, additional rounds of segmentation smoothing (with intermediate MCMC optionally performed in between rounds) are performed until convergence, at which point a final round of MCMC is performed.\n\n*Source: [https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_ModelSegments.php](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_ModelSegments.php)*\n\nSome of the input parameters are listed below:\n* **Denoised copy ratios** (`--denoised-copy-ratios`) - TSV file with denoised copy rations, output of **DenoiseReadCounts**. If allelic counts are not provided, then this is required.\n* **Allelic counts** (`--allelic-counts`) - TSV file containing alt and ref allelic count at specified positions, output of **CollectAllelicCounts**. If denoised copy ratios are not provided, then this is required.\n* **Normal allelic counts** (`--normal-allelic-counts`) - TSV file containing allelic counts of matched normal sample, output of **CollectAllelicCounts**. This can only be provided if allelic counts for the case sample are also provided.\n* **Output prefix** (`--output-prefix`) - This is used as the basename for output files. If not specified output files will be named by either **Denoised copy ratios** or **Allelic counts** (see #Changes Introduced by Seven Bridges).\n\n### Changes Introduced by Seven Bridges\n* If **Output prefix** parameter is not specified, the prefix will be derived from the basename of the **Denoised copy ratios** file. In case this file is not specified, the prefix will be derived from the basename of **Allelic counts** file, as one of those two files are required for the execution.\n\n### Common Issues and Important Notes\n* The default 2048 Mb of memory may not be sufficient for average analysis. We advise using at least 13000 Mb (13GB) of memory for standard WES analysis and in some cases of WES and WGS analyses as much as 32000 Mb (32GB) may be needed. Memory can be allocated through **Memory per job** input parameter.\n\n### Performance Benchmarking\n\n| Input Size | Experimental Strategy | Memory | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- | --- |\n| 0.2GB | WES | 2048MB | 6min | $0.03 | c4.2xlarge |\n| 2.4GB | WGS | 32000MB | 46min | $0.26 | m5.2xlarge |",
                "label": "GATK ModelSegments",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$( inputs.denoised_copy_ratios ? '/opt/gatk' : 'echo /opt/gatk')"
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
                        "valueFrom": "ModelSegments"
                    },
                    {
                        "position": 4,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "."
                    },
                    {
                        "position": 5,
                        "prefix": "--output-prefix",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.output_prefix) {\n        return inputs.output_prefix;\n    } else {\n        if (inputs.denoised_copy_ratios) {\n            return inputs.denoised_copy_ratios.nameroot.split('.').slice(0,-1).join('.');\n        } else if (inputs.allelic_counts) {\n            return inputs.allelic_counts.nameroot.split('.').slice(0,-1).join('.');\n        } else {\n            return 'output_ModelSegments';\n        }\n    }\n    return 'output_ModelSegments';\n}"
                    },
                    {
                        "position": 4,
                        "prefix": "--minimum-total-allele-count-case",
                        "shellQuote": false,
                        "valueFrom": "${\n    var default_min_count = inputs.normal_allelic_counts ? 0 : 30;\n    var min_count = inputs.minimum_total_allele_count_case ? inputs.minimum_total_allele_count_case : default_min_count;\n    return min_count;\n}"
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
                    "Genomics",
                    "Copy Number Variant Calling"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551312575,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551312599,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551652706,
                        "sbg:revisionNotes": "fix memory requirements expression, remove default overhead, set default memory to 2048"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553170547,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553608892,
                        "sbg:revisionNotes": "fix description formatting, add appropriate sections"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553608968,
                        "sbg:revisionNotes": "add descriptions for memory per job, memory overhead and cpu per job input parameters"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553609643,
                        "sbg:revisionNotes": "add descriptions for output files"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553610141,
                        "sbg:revisionNotes": "fix expression for window_size parameter"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553610382,
                        "sbg:revisionNotes": "add changes by sbg and common issues and notes"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553610953,
                        "sbg:revisionNotes": "fix output files section in description"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553611081,
                        "sbg:revisionNotes": "add file formats for file inputs"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553612058,
                        "sbg:revisionNotes": "set output_prefix as required input argument, include in command line"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553612766,
                        "sbg:revisionNotes": "fix output naming, include in description; fix inputs formatting in description"
                    },
                    {
                        "sbg:revision": 13,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553613281,
                        "sbg:revisionNotes": "add metadata inheritance for two output files, for testing"
                    },
                    {
                        "sbg:revision": 14,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553691217,
                        "sbg:revisionNotes": "fix expression typo"
                    },
                    {
                        "sbg:revision": 15,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553694005,
                        "sbg:revisionNotes": "remove outputs section from description; merge input section with common use cases to match format of other tools"
                    },
                    {
                        "sbg:revision": 16,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553769659,
                        "sbg:revisionNotes": "add benchmarking info"
                    },
                    {
                        "sbg:revision": 17,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1554081721,
                        "sbg:revisionNotes": "add expression for min_total_allele_count_case"
                    },
                    {
                        "sbg:revision": 18,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1558970988,
                        "sbg:revisionNotes": "fix metadata inheritance on all output files"
                    },
                    {
                        "sbg:revision": 19,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1558971762,
                        "sbg:revisionNotes": "fix medatada expression"
                    },
                    {
                        "sbg:revision": 20,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1558972446,
                        "sbg:revisionNotes": "fix js expression for metadata"
                    },
                    {
                        "sbg:revision": 21,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559050538,
                        "sbg:revisionNotes": "edit expression for output evals"
                    },
                    {
                        "sbg:revision": 22,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559309194,
                        "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-modelsegments-4-1-0-0/22",
                "sbg:revision": 22,
                "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons",
                "sbg:modifiedOn": 1559309194,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1551312575,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 22,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a8bf865c5a923254e11991e436ebf879b7d72191a759cd51416a779f9d6172555"
            },
            "label": "GATK ModelSegments Normal",
            "sbg:x": 1278.9649658203125,
            "sbg:y": -314
        },
        {
            "id": "gatk_plotmodeledsegments_tumor",
            "in": [
                {
                    "id": "allelic_counts",
                    "source": "gatk_modelsegments_tumor/het_allelic_counts"
                },
                {
                    "id": "denoised_copy_ratios",
                    "source": "gatk_denoisereadcounts_tumor/out_denoised_copy_ratios"
                },
                {
                    "id": "memory_per_job",
                    "default": 7000
                },
                {
                    "id": "minimum_contig_length",
                    "source": "minimum_contig_length"
                },
                {
                    "id": "output_prefix",
                    "source": "gatk_collectreadcounts_tumor/entity_id"
                },
                {
                    "id": "segments",
                    "source": "gatk_modelsegments_tumor/modeled_segments"
                },
                {
                    "id": "sequence_dictionary",
                    "source": "sequence_dictionary"
                }
            ],
            "out": [
                {
                    "id": "output_plot"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-plotmodeledsegments-4-1-0-0/8",
                "baseCommand": [],
                "inputs": [
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "allelic_counts",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--allelic-counts",
                            "shellQuote": false
                        },
                        "label": "Allelic counts",
                        "doc": "Input file containing allelic counts at heterozygous sites (.hets.tsv output of modelsegments).",
                        "sbg:fileTypes": "TSV, HETS.TSV"
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "denoised_copy_ratios",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--denoised-copy-ratios",
                            "shellQuote": false
                        },
                        "label": "Denoised copy ratios",
                        "doc": "Input file containing denoised copy ratios (output of denoisereadcounts).",
                        "sbg:fileTypes": "TSV"
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
                        "sbg:toolDefaultValue": "1000000",
                        "id": "minimum_contig_length",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--minimum-contig-length",
                            "shellQuote": false
                        },
                        "label": "Minimum contig length",
                        "doc": "Threshold length (in bp) for contigs to be plotted. Contigs with lengths less than this threshold will not be plotted. This can be used to filter out mitochondrial contigs, unlocalized contigs, etc."
                    },
                    {
                        "sbg:category": "Required Arguments",
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Prefix for output filenames."
                    },
                    {
                        "sbg:category": "Required Arguments",
                        "id": "segments",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--segments",
                            "shellQuote": false
                        },
                        "label": "Segments",
                        "doc": "Input file containing modeled segments (output of modelsegments).",
                        "sbg:fileTypes": "SEG, TSV"
                    },
                    {
                        "sbg:altPrefix": "-sequence-dictionary",
                        "sbg:category": "Required Arguments",
                        "id": "sequence_dictionary",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--sequence-dictionary",
                            "shellQuote": false
                        },
                        "label": "Sequence dictionary",
                        "doc": "File containing a sequence dictionary, which specifies the contigs to be plotted and their relative lengths. The sequence dictionary must be a subset of those contained in other input files. Contigs will be plotted in the order given. Contig names should not include the string \"contig_delimiter\". The tool only considers contigs in the given dictionary for plotting, and data for contigs absent in the dictionary generate only a warning. In other words, you may modify a reference dictionary for use with this tool to include only contigs for which plotting is desired, and sort the contigs to the order in which the plots should display the contigs.",
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
                        "id": "output_plot",
                        "doc": "This shows the input denoised copy ratios and/or alternate-allele fractions as points, as well as box plots for the available posteriors in each segment. The colors of the points alternate with the segmentation.",
                        "label": "Modeled segments plot",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modeled.png",
                            "outputEval": "$( inputs.segments ? inheritMetadata(self, inputs.segments) : self)"
                        },
                        "sbg:fileTypes": "PNG"
                    }
                ],
                "doc": "GATK PlotModeledSegments creates plots of denoised and segmented copy-ratio and minor-allele-fraction estimates.\n\n### Common Use Cases\nThis tool is used for plotting modeled segments with copy number variants. Some of the input parameters are listed below:\n* **Segments** (`--segments`) - Modeled segments file, output of **ModelSegments**.\n* **Denoised copy ratios** (`--denoised-copy-ratios`) - File containing denoised copy ratios, output of **DenoiseReadCounts**. If allelic counts are not provided, then this is required.\n* **Allelic counts** (`--allelic-counts`) - File containing the counts at sites genotyped as heterozygous (HETS.TSV output of **ModelSegments**). If denoised copy ratios are not provided, then this is required.\n* **Sequence dictionary** (`--sequence-dictionary`) - This determines the order and representation of contigs in the plot.\n* **Output prefix** (`--output-prefix`) - This is used as the basename for output files.\n\n### Changes Introduced by Seven Bridges\n* If **Output prefix** is not specified, prefix of output plot will be derived from the base name of the **Segments** file.\n\n### Common Issues and Important Notes\n* *No issues have been identified thus far.*\n\n### Performance Benchmarking\n\n| Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- |\n| 6MB | WES | 3min | $0.01 | c4.2xlarge |\n| 120MB | WGS | 3min | $0.01 | c4.2xlarge |",
                "label": "GATK PlotModeledSegments",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$( inputs.segments ? '/opt/gatk' : 'echo /opt/gatk')"
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
                        "valueFrom": "PlotModeledSegments"
                    },
                    {
                        "position": 4,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "."
                    },
                    {
                        "position": 5,
                        "prefix": "--output-prefix",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.segments) {\n        var nameroot = inputs.output_prefix ? inputs.output_prefix : inputs.segments.nameroot;\n        return nameroot;\n    }\n    return '';\n}"
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
                    "Genomics",
                    "Copy Number Variant Calling"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551313681,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551313709,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553171728,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553683295,
                        "sbg:revisionNotes": "fix description"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553683381,
                        "sbg:revisionNotes": "add descriptions for memory per job, memory overhead and cpu per job inputs"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553683778,
                        "sbg:revisionNotes": "add input and output file formats"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553693903,
                        "sbg:revisionNotes": "fix description format to match other tools"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553779265,
                        "sbg:revisionNotes": "add benchmarking info"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559311166,
                        "sbg:revisionNotes": "fix js expressions, add vars and semicolons"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-plotmodeledsegments-4-1-0-0/8",
                "sbg:revision": 8,
                "sbg:revisionNotes": "fix js expressions, add vars and semicolons",
                "sbg:modifiedOn": 1559311166,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1551313681,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 8,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a5437b668adfe7b8011f0da8879b04d3bff6674998e7c18fb2234f1c5931bd6d8"
            },
            "label": "GATK PlotModeledSegments Tumor",
            "sbg:x": 2044.4910888671875,
            "sbg:y": -843.1929321289062
        },
        {
            "id": "gatk_plotmodeledsegments_normal",
            "in": [
                {
                    "id": "allelic_counts",
                    "source": "gatk_modelsegments_normal/het_allelic_counts"
                },
                {
                    "id": "denoised_copy_ratios",
                    "source": "gatk_denoisereadcounts_normal/out_denoised_copy_ratios"
                },
                {
                    "id": "memory_per_job",
                    "default": 7000
                },
                {
                    "id": "minimum_contig_length",
                    "source": "minimum_contig_length"
                },
                {
                    "id": "output_prefix",
                    "source": "gatk_collectreadcounts_normal/entity_id"
                },
                {
                    "id": "segments",
                    "source": "gatk_modelsegments_normal/modeled_segments"
                },
                {
                    "id": "sequence_dictionary",
                    "source": "sequence_dictionary"
                }
            ],
            "out": [
                {
                    "id": "output_plot"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-plotmodeledsegments-4-1-0-0/8",
                "baseCommand": [],
                "inputs": [
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "allelic_counts",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--allelic-counts",
                            "shellQuote": false
                        },
                        "label": "Allelic counts",
                        "doc": "Input file containing allelic counts at heterozygous sites (.hets.tsv output of modelsegments).",
                        "sbg:fileTypes": "TSV, HETS.TSV"
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "null",
                        "id": "denoised_copy_ratios",
                        "type": "File?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--denoised-copy-ratios",
                            "shellQuote": false
                        },
                        "label": "Denoised copy ratios",
                        "doc": "Input file containing denoised copy ratios (output of denoisereadcounts).",
                        "sbg:fileTypes": "TSV"
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
                        "sbg:toolDefaultValue": "1000000",
                        "id": "minimum_contig_length",
                        "type": "int?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--minimum-contig-length",
                            "shellQuote": false
                        },
                        "label": "Minimum contig length",
                        "doc": "Threshold length (in bp) for contigs to be plotted. Contigs with lengths less than this threshold will not be plotted. This can be used to filter out mitochondrial contigs, unlocalized contigs, etc."
                    },
                    {
                        "sbg:category": "Required Arguments",
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Prefix for output filenames."
                    },
                    {
                        "sbg:category": "Required Arguments",
                        "id": "segments",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--segments",
                            "shellQuote": false
                        },
                        "label": "Segments",
                        "doc": "Input file containing modeled segments (output of modelsegments).",
                        "sbg:fileTypes": "SEG, TSV"
                    },
                    {
                        "sbg:altPrefix": "-sequence-dictionary",
                        "sbg:category": "Required Arguments",
                        "id": "sequence_dictionary",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--sequence-dictionary",
                            "shellQuote": false
                        },
                        "label": "Sequence dictionary",
                        "doc": "File containing a sequence dictionary, which specifies the contigs to be plotted and their relative lengths. The sequence dictionary must be a subset of those contained in other input files. Contigs will be plotted in the order given. Contig names should not include the string \"contig_delimiter\". The tool only considers contigs in the given dictionary for plotting, and data for contigs absent in the dictionary generate only a warning. In other words, you may modify a reference dictionary for use with this tool to include only contigs for which plotting is desired, and sort the contigs to the order in which the plots should display the contigs.",
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
                        "id": "output_plot",
                        "doc": "This shows the input denoised copy ratios and/or alternate-allele fractions as points, as well as box plots for the available posteriors in each segment. The colors of the points alternate with the segmentation.",
                        "label": "Modeled segments plot",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.modeled.png",
                            "outputEval": "$( inputs.segments ? inheritMetadata(self, inputs.segments) : self)"
                        },
                        "sbg:fileTypes": "PNG"
                    }
                ],
                "doc": "GATK PlotModeledSegments creates plots of denoised and segmented copy-ratio and minor-allele-fraction estimates.\n\n### Common Use Cases\nThis tool is used for plotting modeled segments with copy number variants. Some of the input parameters are listed below:\n* **Segments** (`--segments`) - Modeled segments file, output of **ModelSegments**.\n* **Denoised copy ratios** (`--denoised-copy-ratios`) - File containing denoised copy ratios, output of **DenoiseReadCounts**. If allelic counts are not provided, then this is required.\n* **Allelic counts** (`--allelic-counts`) - File containing the counts at sites genotyped as heterozygous (HETS.TSV output of **ModelSegments**). If denoised copy ratios are not provided, then this is required.\n* **Sequence dictionary** (`--sequence-dictionary`) - This determines the order and representation of contigs in the plot.\n* **Output prefix** (`--output-prefix`) - This is used as the basename for output files.\n\n### Changes Introduced by Seven Bridges\n* If **Output prefix** is not specified, prefix of output plot will be derived from the base name of the **Segments** file.\n\n### Common Issues and Important Notes\n* *No issues have been identified thus far.*\n\n### Performance Benchmarking\n\n| Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- |\n| 6MB | WES | 3min | $0.01 | c4.2xlarge |\n| 120MB | WGS | 3min | $0.01 | c4.2xlarge |",
                "label": "GATK PlotModeledSegments",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$( inputs.segments ? '/opt/gatk' : 'echo /opt/gatk')"
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
                        "valueFrom": "PlotModeledSegments"
                    },
                    {
                        "position": 4,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "."
                    },
                    {
                        "position": 5,
                        "prefix": "--output-prefix",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.segments) {\n        var nameroot = inputs.output_prefix ? inputs.output_prefix : inputs.segments.nameroot;\n        return nameroot;\n    }\n    return '';\n}"
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
                    "Genomics",
                    "Copy Number Variant Calling"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551313681,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551313709,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553171728,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553683295,
                        "sbg:revisionNotes": "fix description"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553683381,
                        "sbg:revisionNotes": "add descriptions for memory per job, memory overhead and cpu per job inputs"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553683778,
                        "sbg:revisionNotes": "add input and output file formats"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553693903,
                        "sbg:revisionNotes": "fix description format to match other tools"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553779265,
                        "sbg:revisionNotes": "add benchmarking info"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559311166,
                        "sbg:revisionNotes": "fix js expressions, add vars and semicolons"
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-plotmodeledsegments-4-1-0-0/8",
                "sbg:revision": 8,
                "sbg:revisionNotes": "fix js expressions, add vars and semicolons",
                "sbg:modifiedOn": 1559311166,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1551313681,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 8,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a5437b668adfe7b8011f0da8879b04d3bff6674998e7c18fb2234f1c5931bd6d8"
            },
            "label": "GATK PlotModeledSegments Normal",
            "sbg:x": 2037.1270751953125,
            "sbg:y": -309
        },
        {
            "id": "gatk_callcopyratiosegments_tumor",
            "in": [
                {
                    "id": "calling_copy_ratio_z_score_threshold",
                    "source": "calling_copy_ratio_z_score_threshold"
                },
                {
                    "id": "copy_ratio_segments",
                    "source": "gatk_modelsegments_tumor/copy_ratio_only_segments"
                },
                {
                    "id": "memory_per_job",
                    "default": 7000
                },
                {
                    "id": "neutral_segment_copy_ratio_lower_bound",
                    "source": "neutral_segment_copy_ratio_lower_bound"
                },
                {
                    "id": "neutral_segment_copy_ratio_upper_bound",
                    "source": "neutral_segment_copy_ratio_upper_bound"
                },
                {
                    "id": "outlier_neutral_segment_copy_ratio_z_score_threshold",
                    "source": "outlier_neutral_segment_copy_ratio_z_score_threshold"
                }
            ],
            "out": [
                {
                    "id": "called_segments"
                },
                {
                    "id": "called_legacy_segments"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-callcopyratiosegments-4-1-0-0/14",
                "baseCommand": [],
                "inputs": [
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "2",
                        "id": "calling_copy_ratio_z_score_threshold",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--calling-copy-ratio-z-score-threshold",
                            "shellQuote": false
                        },
                        "label": "Calling copy ratio Z score threshold",
                        "doc": "Threshold on z-score of non-log2 copy ratio used for calling segments. 0."
                    },
                    {
                        "sbg:altPrefix": "-I",
                        "sbg:category": "Required Arguments",
                        "id": "copy_ratio_segments",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--input",
                            "shellQuote": false
                        },
                        "label": "Copy ratio segments",
                        "doc": "Input file containing copy-ratio segments (.cr.seg output of modelsegments).",
                        "sbg:fileTypes": "SEG, TSV"
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
                        "sbg:toolDefaultValue": "0",
                        "id": "neutral_segment_copy_ratio_lower_bound",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--neutral-segment-copy-ratio-lower-bound",
                            "shellQuote": false
                        },
                        "label": "Neutral segment copy ratio lower bound",
                        "doc": "Lower bound on non-log2 copy ratio used for determining copy-neutral segments. 9."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "1",
                        "id": "neutral_segment_copy_ratio_upper_bound",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--neutral-segment-copy-ratio-upper-bound",
                            "shellQuote": false
                        },
                        "label": "Neutral segment copy ratio upper bound",
                        "doc": "Upper bound on non-log2 copy ratio used for determining copy-neutral segments. 1."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "2",
                        "id": "outlier_neutral_segment_copy_ratio_z_score_threshold",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--outlier-neutral-segment-copy-ratio-z-score-threshold",
                            "shellQuote": false
                        },
                        "label": "Outlier neutral segment copy ratio Z score threshold",
                        "doc": "Threshold on z-score of non-log2 copy ratio used for determining outlier copy-neutral segments. If non-log2 copy ratio z-score is above this threshold for a copy-neutral segment, it is considered an outlier and not used in the calculation of the length-weighted mean and standard deviation used for calling. 0."
                    },
                    {
                        "sbg:altPrefix": "-O",
                        "sbg:category": "Required Arguments",
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Output file for called copy-ratio segments."
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
                        "id": "called_segments",
                        "doc": "Called copy-ratio segments file",
                        "label": "Called copy ratio segments",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.called.seg",
                            "outputEval": "$( inputs.copy_ratio_segments ? inheritMetadata(self, inputs.copy_ratio_segments) : self)"
                        },
                        "sbg:fileTypes": "SEG"
                    },
                    {
                        "id": "called_legacy_segments",
                        "doc": "Called copy-ratio segments file, format for IGV viewer.",
                        "label": "Called legacy segments",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*called.igv.seg",
                            "outputEval": "$( inputs.copy_ratio_segments ? inheritMetadata(self, inputs.copy_ratio_segments) : self)"
                        },
                        "sbg:fileTypes": "SEG"
                    }
                ],
                "doc": "GATK CallCopyRatioSegments calls copy-ratio segments as amplified, deleted, or copy-number neutral.\n\n\n### Common Use Cases\nThis is a relatively naive caller that takes the modeled-segments output of **ModelSegments** and performs a simple statistical test on the segmented log2 copy ratios to call amplifications and deletions, given a specified range for determining copy-number neutral segments. This caller is based on the calling functionality of ReCapSeg. If provided ModelSegments results that incorporate allele-fraction data, i.e. data with presumably improved segmentation, the statistical test performed by CallCopyRatioSegments ignores the modeled minor-allele fractions when making calls.\n\n*Source: [https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_CallCopyRatioSegments.php](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_CallCopyRatioSegments.php)*\n\nSome of the input parameters are listed below:\n* **Copy ratio segments** (`--input`) - Copy ratio segments file, output of **ModelSegments**. This is a tab-separated values (TSV) file with a SAM-style header containing a read group sample name, a sequence dictionary, a row specifying the column headers contained in CopyRatioSegmentCollection.CopyRatioSegmentTableColumn, and the corresponding entry rows.\n* **Output prefix** (`--output`) - Prefix of the output files.\n\n### Changes Introduced by Seven Bridges\n* If **Output prefix** input parameter is not set, the base name of the **Copy ratio segments** input file will be used as output prefix.\n\n### Common Issues and Important Notes\n* *No issues have been identified thus far.*\n\n### Performance Benchmarking\n| Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- |\n| 30KB | WES | 2min | $0.01 | c4.2xlarge |\n| 800KB | WGS | 3min | $0.01 | c4.2xlarge |",
                "label": "GATK CallCopyRatioSegments",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$( inputs.copy_ratio_segments ? '/opt/gatk' : 'echo /opt/gatk')"
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
                        "valueFrom": "CallCopyRatioSegments"
                    },
                    {
                        "position": 4,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.copy_ratio_segments) {\n        var nameroot = inputs.output_prefix ? inputs.output_prefix : inputs.copy_ratio_segments.nameroot;\n        var nameext = '.called.seg';\n        return nameroot + nameext;\n    }\n    return '';\n}"
                    }
                ],
                "requirements": [
                    {
                        "class": "ShellCommandRequirement"
                    },
                    {
                        "class": "ResourceRequirement",
                        "ramMin": "${  \n    var memory = 2000;\n    if (inputs.memory_per_job) {\n        memory = inputs.memory_per_job;\n    }\n    if (inputs.memory_overhead_per_job) {\n        memory += inputs.memory_overhead_per_job;\n    }\n    return memory;\n}",
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
                    "Genomics",
                    "Copy Number Variant Calling"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551314117,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551314140,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553171324,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553615011,
                        "sbg:revisionNotes": "change input id 'input' to 'copy_ratio_segments'; change input id 'output' to 'output_prefix'; fix output prefix argument expression to reflect changes in input IDs."
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553615101,
                        "sbg:revisionNotes": "add description and default values for memory per job, memory overhead and cpu per job input parameters; fix memory requirements expression, remove default overhaed."
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553615251,
                        "sbg:revisionNotes": "fix metadata inheritance expressions, add descriptions for output files"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553615607,
                        "sbg:revisionNotes": "add info to app description, add sections"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553615942,
                        "sbg:revisionNotes": "fix formatting in description"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553615985,
                        "sbg:revisionNotes": "fix input label in description"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553616287,
                        "sbg:revisionNotes": "add output naming to changes introduced by sbg"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553692699,
                        "sbg:revisionNotes": "fix description format to match previous tools"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553770955,
                        "sbg:revisionNotes": "add benchmarking data; fix conditional execution expression"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553773469,
                        "sbg:revisionNotes": "add benchmarking info"
                    },
                    {
                        "sbg:revision": 13,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553814553,
                        "sbg:revisionNotes": "set copy_ratio_segments (--input) input to required"
                    },
                    {
                        "sbg:revision": 14,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559309799,
                        "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons etc."
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-callcopyratiosegments-4-1-0-0/14",
                "sbg:revision": 14,
                "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons etc.",
                "sbg:modifiedOn": 1559309799,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1551314117,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 14,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "ad78c5328d9da6738bda90b8b9c2ee89b60639cfa271f6cb8d4704dfeeff80e85"
            },
            "label": "GATK CallCopyRatioSegments Tumor",
            "sbg:x": 2021.2625732421875,
            "sbg:y": 71.48369598388672
        },
        {
            "id": "gatk_callcopyratiosegments_normal",
            "in": [
                {
                    "id": "calling_copy_ratio_z_score_threshold",
                    "source": "calling_copy_ratio_z_score_threshold"
                },
                {
                    "id": "copy_ratio_segments",
                    "source": "gatk_modelsegments_normal/copy_ratio_only_segments"
                },
                {
                    "id": "memory_per_job",
                    "default": 7000
                },
                {
                    "id": "neutral_segment_copy_ratio_lower_bound",
                    "source": "neutral_segment_copy_ratio_lower_bound"
                },
                {
                    "id": "neutral_segment_copy_ratio_upper_bound",
                    "source": "neutral_segment_copy_ratio_upper_bound"
                },
                {
                    "id": "outlier_neutral_segment_copy_ratio_z_score_threshold",
                    "source": "outlier_neutral_segment_copy_ratio_z_score_threshold"
                }
            ],
            "out": [
                {
                    "id": "called_segments"
                },
                {
                    "id": "called_legacy_segments"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-callcopyratiosegments-4-1-0-0/14",
                "baseCommand": [],
                "inputs": [
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "2",
                        "id": "calling_copy_ratio_z_score_threshold",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--calling-copy-ratio-z-score-threshold",
                            "shellQuote": false
                        },
                        "label": "Calling copy ratio Z score threshold",
                        "doc": "Threshold on z-score of non-log2 copy ratio used for calling segments. 0."
                    },
                    {
                        "sbg:altPrefix": "-I",
                        "sbg:category": "Required Arguments",
                        "id": "copy_ratio_segments",
                        "type": "File",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--input",
                            "shellQuote": false
                        },
                        "label": "Copy ratio segments",
                        "doc": "Input file containing copy-ratio segments (.cr.seg output of modelsegments).",
                        "sbg:fileTypes": "SEG, TSV"
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
                        "sbg:toolDefaultValue": "0",
                        "id": "neutral_segment_copy_ratio_lower_bound",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--neutral-segment-copy-ratio-lower-bound",
                            "shellQuote": false
                        },
                        "label": "Neutral segment copy ratio lower bound",
                        "doc": "Lower bound on non-log2 copy ratio used for determining copy-neutral segments. 9."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "1",
                        "id": "neutral_segment_copy_ratio_upper_bound",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--neutral-segment-copy-ratio-upper-bound",
                            "shellQuote": false
                        },
                        "label": "Neutral segment copy ratio upper bound",
                        "doc": "Upper bound on non-log2 copy ratio used for determining copy-neutral segments. 1."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "2",
                        "id": "outlier_neutral_segment_copy_ratio_z_score_threshold",
                        "type": "float?",
                        "inputBinding": {
                            "position": 4,
                            "prefix": "--outlier-neutral-segment-copy-ratio-z-score-threshold",
                            "shellQuote": false
                        },
                        "label": "Outlier neutral segment copy ratio Z score threshold",
                        "doc": "Threshold on z-score of non-log2 copy ratio used for determining outlier copy-neutral segments. If non-log2 copy ratio z-score is above this threshold for a copy-neutral segment, it is considered an outlier and not used in the calculation of the length-weighted mean and standard deviation used for calling. 0."
                    },
                    {
                        "sbg:altPrefix": "-O",
                        "sbg:category": "Required Arguments",
                        "id": "output_prefix",
                        "type": "string?",
                        "label": "Output prefix",
                        "doc": "Output file for called copy-ratio segments."
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
                        "id": "called_segments",
                        "doc": "Called copy-ratio segments file",
                        "label": "Called copy ratio segments",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*.called.seg",
                            "outputEval": "$( inputs.copy_ratio_segments ? inheritMetadata(self, inputs.copy_ratio_segments) : self)"
                        },
                        "sbg:fileTypes": "SEG"
                    },
                    {
                        "id": "called_legacy_segments",
                        "doc": "Called copy-ratio segments file, format for IGV viewer.",
                        "label": "Called legacy segments",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*called.igv.seg",
                            "outputEval": "$( inputs.copy_ratio_segments ? inheritMetadata(self, inputs.copy_ratio_segments) : self)"
                        },
                        "sbg:fileTypes": "SEG"
                    }
                ],
                "doc": "GATK CallCopyRatioSegments calls copy-ratio segments as amplified, deleted, or copy-number neutral.\n\n\n### Common Use Cases\nThis is a relatively naive caller that takes the modeled-segments output of **ModelSegments** and performs a simple statistical test on the segmented log2 copy ratios to call amplifications and deletions, given a specified range for determining copy-number neutral segments. This caller is based on the calling functionality of ReCapSeg. If provided ModelSegments results that incorporate allele-fraction data, i.e. data with presumably improved segmentation, the statistical test performed by CallCopyRatioSegments ignores the modeled minor-allele fractions when making calls.\n\n*Source: [https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_CallCopyRatioSegments.php](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_CallCopyRatioSegments.php)*\n\nSome of the input parameters are listed below:\n* **Copy ratio segments** (`--input`) - Copy ratio segments file, output of **ModelSegments**. This is a tab-separated values (TSV) file with a SAM-style header containing a read group sample name, a sequence dictionary, a row specifying the column headers contained in CopyRatioSegmentCollection.CopyRatioSegmentTableColumn, and the corresponding entry rows.\n* **Output prefix** (`--output`) - Prefix of the output files.\n\n### Changes Introduced by Seven Bridges\n* If **Output prefix** input parameter is not set, the base name of the **Copy ratio segments** input file will be used as output prefix.\n\n### Common Issues and Important Notes\n* *No issues have been identified thus far.*\n\n### Performance Benchmarking\n| Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- |\n| 30KB | WES | 2min | $0.01 | c4.2xlarge |\n| 800KB | WGS | 3min | $0.01 | c4.2xlarge |",
                "label": "GATK CallCopyRatioSegments",
                "arguments": [
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$( inputs.copy_ratio_segments ? '/opt/gatk' : 'echo /opt/gatk')"
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
                        "valueFrom": "CallCopyRatioSegments"
                    },
                    {
                        "position": 4,
                        "prefix": "--output",
                        "shellQuote": false,
                        "valueFrom": "${\n    if (inputs.copy_ratio_segments) {\n        var nameroot = inputs.output_prefix ? inputs.output_prefix : inputs.copy_ratio_segments.nameroot;\n        var nameext = '.called.seg';\n        return nameroot + nameext;\n    }\n    return '';\n}"
                    }
                ],
                "requirements": [
                    {
                        "class": "ShellCommandRequirement"
                    },
                    {
                        "class": "ResourceRequirement",
                        "ramMin": "${  \n    var memory = 2000;\n    if (inputs.memory_per_job) {\n        memory = inputs.memory_per_job;\n    }\n    if (inputs.memory_overhead_per_job) {\n        memory += inputs.memory_overhead_per_job;\n    }\n    return memory;\n}",
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
                    "Genomics",
                    "Copy Number Variant Calling"
                ],
                "sbg:license": "Open source BSD (3-clause) license",
                "sbg:toolAuthor": "Broad Institute",
                "sbg:toolkit": "GATK",
                "sbg:toolkitVersion": "4.1.0.0",
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551314117,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551314140,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "uros_sipetic",
                        "sbg:modifiedOn": 1553171324,
                        "sbg:revisionNotes": "Update categories"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553615011,
                        "sbg:revisionNotes": "change input id 'input' to 'copy_ratio_segments'; change input id 'output' to 'output_prefix'; fix output prefix argument expression to reflect changes in input IDs."
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553615101,
                        "sbg:revisionNotes": "add description and default values for memory per job, memory overhead and cpu per job input parameters; fix memory requirements expression, remove default overhaed."
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553615251,
                        "sbg:revisionNotes": "fix metadata inheritance expressions, add descriptions for output files"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553615607,
                        "sbg:revisionNotes": "add info to app description, add sections"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553615942,
                        "sbg:revisionNotes": "fix formatting in description"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553615985,
                        "sbg:revisionNotes": "fix input label in description"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553616287,
                        "sbg:revisionNotes": "add output naming to changes introduced by sbg"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553692699,
                        "sbg:revisionNotes": "fix description format to match previous tools"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553770955,
                        "sbg:revisionNotes": "add benchmarking data; fix conditional execution expression"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553773469,
                        "sbg:revisionNotes": "add benchmarking info"
                    },
                    {
                        "sbg:revision": 13,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553814553,
                        "sbg:revisionNotes": "set copy_ratio_segments (--input) input to required"
                    },
                    {
                        "sbg:revision": 14,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1559309799,
                        "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons etc."
                    }
                ],
                "sbg:image_url": null,
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-callcopyratiosegments-4-1-0-0/14",
                "sbg:revision": 14,
                "sbg:revisionNotes": "fix javascript expressions, add vars and semicolons etc.",
                "sbg:modifiedOn": 1559309799,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1551314117,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "uros_sipetic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 14,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "ad78c5328d9da6738bda90b8b9c2ee89b60639cfa271f6cb8d4704dfeeff80e85"
            },
            "label": "GATK CallCopyRatioSegments Normal",
            "sbg:x": 2026.1405029296875,
            "sbg:y": 425.7521057128906
        },
        {
            "id": "gatk_cnv_oncotatesegments",
            "in": [
                {
                    "id": "called_file",
                    "source": "gatk_callcopyratiosegments_tumor/called_segments"
                },
                {
                    "id": "run_oncotator",
                    "source": "run_oncotator"
                }
            ],
            "out": [
                {
                    "id": "oncotated_called_file"
                },
                {
                    "id": "oncotated_gene_list"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-cnv-oncotatesegments/7",
                "baseCommand": [],
                "inputs": [
                    {
                        "sbg:category": "Required Arguments",
                        "id": "called_file",
                        "type": "File",
                        "label": "Segments File",
                        "doc": "Called copy-ratio-segments file. This is a tab-separated values (TSV) file with a SAM-style header containing a read group sample name, a sequence dictionary, a row specifying the column headers and the corresponding entry rows.",
                        "sbg:fileTypes": "SEG, TSV"
                    },
                    {
                        "sbg:category": "Execution",
                        "id": "run_oncotator",
                        "type": "boolean",
                        "label": "Run oncotator",
                        "doc": "This input is added per GATK best practice specification. It has to be set to True in order to execute the command line. If set to False, the command line will just be echoed."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "id": "additional_args",
                        "type": "string?",
                        "label": "Additional arguments",
                        "doc": "Additional arguments passed to Oncotator."
                    },
                    {
                        "sbg:category": "Optional Arguments",
                        "sbg:toolDefaultValue": "2048",
                        "id": "memory_per_job",
                        "type": "int?",
                        "label": "Memory per job",
                        "doc": "Memory which will be allocated for execution."
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
                        "sbg:toolDefaultValue": "1",
                        "id": "cpu_per_job",
                        "type": "int?",
                        "label": "CPU per job",
                        "doc": "Number of CPUs which will be allocated for the job."
                    }
                ],
                "outputs": [
                    {
                        "id": "oncotated_called_file",
                        "label": "Oncotated Called File",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*per_segment.oncotated.txt",
                            "outputEval": "$(inheritMetadata(self, inputs.called_file))"
                        },
                        "sbg:fileTypes": "TXT"
                    },
                    {
                        "id": "oncotated_gene_list",
                        "label": "Oncotated Gene List",
                        "type": "File?",
                        "outputBinding": {
                            "glob": "*gene_list.txt",
                            "outputEval": "$(inheritMetadata(self, inputs.called_file))"
                        },
                        "sbg:fileTypes": "TXT"
                    }
                ],
                "doc": "GATK OncotateSegments is a version of **Oncotator** adapted for **GATK CNV Pair Workflow**. It is used for annotating called segments.\n\n### Common Use Cases\n**Oncotator** is a tool for annotating information onto genomic point mutations (SNPs/SNVs) and indels. It is primarily intended to be used on human genome variant callsets and we only provide data sources that are relevant to cancer researchers. However, the tool can technically be used to annotate any kind of information onto variant callsets from any organism, and we provide instructions on how to prepare custom data sources for inclusion in the process. By default Oncotator is set up to use a simple tsv (a.k.a MAFLITE) as input and produces a TCGA MAF as output. See details below. Some of the input parameters are listed below:\n* **Segments file** - Called copy-ratio-segments file, produced by **CallCopyRatioSegments** tool. This is a tab-separated values (TSV) file with a SAM-style header containing a read group sample name, a sequence dictionary, a row specifying the column headers and the corresponding entry rows.\n* **Run oncotator** - This input is added per GATK best practice specification. It has to be set to True in order to execute the command line. If set to False, the command line will just be echoed.\n\n### Changes Introduced by Seven Bridges\n* Additional **Run oncotator** input parameter is added. This is done to allow optional execution of this app within GATK CNV Pair Workflow, per [GATK best practice specification](https://github.com/gatk-workflows/gatk4-somatic-cnvs/blob/master/cnv_somatic_oncotator_workflow.wdl).\n\n### Common Issues and Important Notes\n* This app only supports **hg19** genome build, and is not intended to be used with other reference genomes.\n\n### Performance Benchmarking\n\n| Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | --- | --- |\n| 30KB | WES | 5min | $0.02 | c4.2xlarge |\n| 800KB | WGS | 5min | $0.02 | c4.2xlarge |",
                "label": "CNV OncotateSegments",
                "arguments": [
                    {
                        "position": 1,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$(inputs.run_oncotator ? \"\" : \"echo\") /root/oncotator_venv/bin/oncotator --db-dir /root/onco_dbdir/ -c /root/tx_exact_uniprot_matches.AKT1_CRLF2_FGFR1.txt -u file:///root/onco_cache/ -r -v ${return inputs.called_file.nameroot+'.seq_dict_removed.seg '} ${return inputs.called_file.nameroot+'.per_segment.oncotated.txt'} hg19 -i SEG_FILE -o SIMPLE_TSV ${if (inputs.additional_args) {return inputs.additional_args} return ''} ;"
                    },
                    {
                        "position": 0,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$(inputs.run_oncotator ? \"\" : \"echo\") egrep -v \"^\\@\" $(inputs.called_file.path) > ${return inputs.called_file.nameroot+'.seq_dict_removed.seg'} ;"
                    },
                    {
                        "position": 2,
                        "prefix": "",
                        "shellQuote": false,
                        "valueFrom": "$(inputs.run_oncotator ? \"\" : \"echo\") /root/oncotator_venv/bin/oncotator --db-dir /root/onco_dbdir/ -c /root/tx_exact_uniprot_matches.AKT1_CRLF2_FGFR1.txt -u file:///root/onco_cache/ -r -v ${return inputs.called_file.nameroot+'.seq_dict_removed.seg'} ${return inputs.called_file.nameroot+'.gene_list.txt'} hg19 -i SEG_FILE -o GENE_LIST ${if (inputs.additional_args) {return inputs.additional_args} return ''}"
                    }
                ],
                "requirements": [
                    {
                        "class": "ShellCommandRequirement"
                    },
                    {
                        "class": "ResourceRequirement",
                        "ramMin": "${\n    var memory = 2048;\n    if (inputs.memory_per_job) {\n        memory = inputs.memory_per_job;\n    }\n    if (inputs.memory_overhead_per_job) {\n        memory += inputs.memory_overhead_per_job;\n    }\n    return memory\n}",
                        "coresMin": "$( inputs.cpu_per_job ? inputs.cpu_per_job : 1)"
                    },
                    {
                        "class": "DockerRequirement",
                        "dockerPull": "images.sbgenomics.com/stefan_stojanovic/oncotator:1.9.5.0-eval-gatk-protected"
                    },
                    {
                        "class": "InlineJavascriptRequirement",
                        "expressionLib": [
                            "\nvar setMetadata = function(file, metadata) {\n    if (!('metadata' in file))\n        file['metadata'] = metadata;\n    else {\n        for (var key in metadata) {\n            file['metadata'][key] = metadata[key];\n        }\n    }\n    return file\n};\n\nvar inheritMetadata = function(o1, o2) {\n    var commonMetadata = {};\n    if (!Array.isArray(o2)) {\n        o2 = [o2]\n    }\n    for (var i = 0; i < o2.length; i++) {\n        var example = o2[i]['metadata'];\n        for (var key in example) {\n            if (i == 0)\n                commonMetadata[key] = example[key];\n            else {\n                if (!(commonMetadata[key] == example[key])) {\n                    delete commonMetadata[key]\n                }\n            }\n        }\n    }\n    if (!Array.isArray(o1)) {\n        o1 = setMetadata(o1, commonMetadata)\n    } else {\n        for (var i = 0; i < o1.length; i++) {\n            o1[i] = setMetadata(o1[i], commonMetadata)\n        }\n    }\n    return o1;\n};"
                        ]
                    }
                ],
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551314584,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551314608,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553183968,
                        "sbg:revisionNotes": "remove redundant inputs, add hardcoded input formats to command line"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553184313,
                        "sbg:revisionNotes": "fix input labels and descriptions; add memory per job, memory overhead and cpu per job inputs; fix memory and cpu requirements expressions"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553184767,
                        "sbg:revisionNotes": "edit description, add useful info"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553185109,
                        "sbg:revisionNotes": "add output file formats"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553185268,
                        "sbg:revisionNotes": "fix app label"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553785352,
                        "sbg:revisionNotes": "add benchmarking info"
                    }
                ],
                "sbg:image_url": null,
                "sbg:toolAuthor": "Ramos et. al.",
                "sbg:toolkit": "Oncotator",
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-cnv-oncotatesegments/7",
                "sbg:revision": 7,
                "sbg:revisionNotes": "add benchmarking info",
                "sbg:modifiedOn": 1553785352,
                "sbg:modifiedBy": "stefan_stojanovic",
                "sbg:createdOn": 1551314584,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 7,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "a4a96780ed1098556731a5b340c42b55bde4c9967e48b0eff37f49c52a27c5bdc"
            },
            "label": "CNV OncotateSegments CWL 1.0",
            "sbg:x": 2472.625732421875,
            "sbg:y": 67.08751678466797
        },
        {
            "id": "sbg_group_outputs_tumor",
            "in": [
                {
                    "id": "in_array",
                    "source": [
                        "gatk_plotmodeledsegments_tumor/output_plot",
                        "gatk_modelsegments_tumor/modeled_segments",
                        "gatk_callcopyratiosegments_tumor/called_segments",
                        "gatk_callcopyratiosegments_tumor/called_legacy_segments",
                        "gatk_modelsegments_tumor/allele_fraction_parameters_begin",
                        "gatk_modelsegments_tumor/allele_fraction_parameters",
                        "gatk_denoisereadcounts_tumor/out_standardized_copy_ratios",
                        "gatk_denoisereadcounts_tumor/out_denoised_copy_ratios",
                        "gatk_plotdenoisedcopyratios_tumor/delta_mad",
                        "gatk_plotdenoisedcopyratios_tumor/denoised_limit_plot",
                        "gatk_plotdenoisedcopyratios_tumor/denoised_mad",
                        "gatk_plotdenoisedcopyratios_tumor/denoised_plot",
                        "gatk_plotdenoisedcopyratios_tumor/scaled_delta_mad",
                        "gatk_plotdenoisedcopyratios_tumor/standardized_mad",
                        "gatk_modelsegments_tumor/normal_het_allelic_counts",
                        "gatk_modelsegments_tumor/modeled_segments_begin",
                        "gatk_modelsegments_tumor/het_allelic_counts",
                        "gatk_modelsegments_tumor/copy_ratio_parameters_begin",
                        "gatk_modelsegments_tumor/copy_ratio_parameters",
                        "gatk_modelsegments_tumor/copy_ratio_only_segments",
                        "gatk_modelsegments_tumor/copy_ratio_legacy_segments",
                        "gatk_modelsegments_tumor/allele_fraction_legacy_segments",
                        "gatk_collectalleliccounts_tumor/allelic_counts"
                    ]
                }
            ],
            "out": [
                {
                    "id": "out_array"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/sbg-group-outputs/12",
                "baseCommand": [
                    "echo",
                    "propagating",
                    "inputs"
                ],
                "inputs": [
                    {
                        "id": "in_array",
                        "type": [
                            "null",
                            {
                                "type": "array",
                                "items": [
                                    "File",
                                    "null"
                                ]
                            }
                        ],
                        "inputBinding": {
                            "position": 0,
                            "shellQuote": false
                        },
                        "label": "Input array",
                        "doc": "Array of input files."
                    }
                ],
                "outputs": [
                    {
                        "id": "out_array",
                        "doc": "Grouped files",
                        "label": "Output array",
                        "type": "File[]",
                        "outputBinding": {
                            "glob": ".txt",
                            "outputEval": "${\n    var out = []\n    for (var i = 0; i < inputs.in_array.length; i++){\n        if (inputs.in_array[i]){\n            out.push(inputs.in_array[i])\n            \n        }\n    }\n    return out\n}"
                        },
                        "sbg:fileTypes": "TXT, TSV, SEG, PNG, HDF5, PARAM"
                    }
                ],
                "doc": "SBG Group Outputs is a simple tool which propagates array of input files to a single output port.",
                "label": "SBG Group Outputs",
                "requirements": [
                    {
                        "class": "ShellCommandRequirement"
                    },
                    {
                        "class": "ResourceRequirement",
                        "coresMin": 1
                    },
                    {
                        "class": "DockerRequirement",
                        "dockerPull": "ubuntu:16.04"
                    },
                    {
                        "class": "InlineJavascriptRequirement"
                    }
                ],
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551355108,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551355145,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553690258,
                        "sbg:revisionNotes": "add basic info, add input and output labels and descriptions"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553783297,
                        "sbg:revisionNotes": "add file formats; add toolkit"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1577462831,
                        "sbg:revisionNotes": "File types -> file type HDF5"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1577462877,
                        "sbg:revisionNotes": "inputs -> in_array -> file type -> hdf5"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578496948,
                        "sbg:revisionNotes": "in_array no file types"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578498130,
                        "sbg:revisionNotes": "test glob -> .txt"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578655474,
                        "sbg:revisionNotes": "no base command"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578655566,
                        "sbg:revisionNotes": "input removed from command line"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578657168,
                        "sbg:revisionNotes": "cwl copy/paste from SBGGroupOutputs test tool"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578662116,
                        "sbg:revisionNotes": "base command broken into lines"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578663492,
                        "sbg:revisionNotes": "File? -> [File, null], null"
                    }
                ],
                "sbg:image_url": null,
                "sbg:toolkit": "SBGTools",
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/sbg-group-outputs/12",
                "sbg:revision": 12,
                "sbg:revisionNotes": "File? -> [File, null], null",
                "sbg:modifiedOn": 1578663492,
                "sbg:modifiedBy": "milena_stanojevic",
                "sbg:createdOn": 1551355108,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "milena_stanojevic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 12,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "ad3e4e1c72bc85fa87f0752ab063457bf68560cb368f873ae2618d13369f8b32f"
            },
            "label": "SBG Group Outputs Tumor",
            "sbg:x": 2659.38427734375,
            "sbg:y": -595.4244384765625
        },
        {
            "id": "sbg_group_outputs_normal",
            "in": [
                {
                    "id": "in_array",
                    "source": [
                        "gatk_callcopyratiosegments_normal/called_segments",
                        "gatk_callcopyratiosegments_normal/called_legacy_segments",
                        "gatk_plotmodeledsegments_normal/output_plot",
                        "gatk_collectalleliccounts_normal/allelic_counts",
                        "gatk_collectreadcounts_normal/read_counts",
                        "gatk_denoisereadcounts_normal/out_denoised_copy_ratios",
                        "gatk_denoisereadcounts_normal/out_standardized_copy_ratios",
                        "gatk_plotdenoisedcopyratios_normal/delta_mad",
                        "gatk_plotdenoisedcopyratios_normal/denoised_limit_plot",
                        "gatk_plotdenoisedcopyratios_normal/denoised_mad",
                        "gatk_plotdenoisedcopyratios_normal/denoised_plot",
                        "gatk_plotdenoisedcopyratios_normal/scaled_delta_mad",
                        "gatk_plotdenoisedcopyratios_normal/standardized_mad",
                        "gatk_modelsegments_normal/normal_het_allelic_counts",
                        "gatk_modelsegments_normal/modeled_segments_begin",
                        "gatk_modelsegments_normal/modeled_segments",
                        "gatk_modelsegments_normal/het_allelic_counts",
                        "gatk_modelsegments_normal/copy_ratio_parameters_begin",
                        "gatk_modelsegments_normal/copy_ratio_parameters",
                        "gatk_modelsegments_normal/copy_ratio_only_segments",
                        "gatk_modelsegments_normal/copy_ratio_legacy_segments",
                        "gatk_modelsegments_normal/allele_fraction_parameters_begin",
                        "gatk_modelsegments_normal/allele_fraction_parameters",
                        "gatk_modelsegments_normal/allele_fraction_legacy_segments"
                    ]
                }
            ],
            "out": [
                {
                    "id": "out_array"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/sbg-group-outputs/12",
                "baseCommand": [
                    "echo",
                    "propagating",
                    "inputs"
                ],
                "inputs": [
                    {
                        "id": "in_array",
                        "type": [
                            "null",
                            {
                                "type": "array",
                                "items": [
                                    "File",
                                    "null"
                                ]
                            }
                        ],
                        "inputBinding": {
                            "position": 0,
                            "shellQuote": false
                        },
                        "label": "Input array",
                        "doc": "Array of input files."
                    }
                ],
                "outputs": [
                    {
                        "id": "out_array",
                        "doc": "Grouped files",
                        "label": "Output array",
                        "type": "File[]",
                        "outputBinding": {
                            "glob": ".txt",
                            "outputEval": "${\n    var out = []\n    for (var i = 0; i < inputs.in_array.length; i++){\n        if (inputs.in_array[i]){\n            out.push(inputs.in_array[i])\n            \n        }\n    }\n    return out\n}"
                        },
                        "sbg:fileTypes": "TXT, TSV, SEG, PNG, HDF5, PARAM"
                    }
                ],
                "doc": "SBG Group Outputs is a simple tool which propagates array of input files to a single output port.",
                "label": "SBG Group Outputs",
                "requirements": [
                    {
                        "class": "ShellCommandRequirement"
                    },
                    {
                        "class": "ResourceRequirement",
                        "coresMin": 1
                    },
                    {
                        "class": "DockerRequirement",
                        "dockerPull": "ubuntu:16.04"
                    },
                    {
                        "class": "InlineJavascriptRequirement"
                    }
                ],
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551355108,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551355145,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553690258,
                        "sbg:revisionNotes": "add basic info, add input and output labels and descriptions"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553783297,
                        "sbg:revisionNotes": "add file formats; add toolkit"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1577462831,
                        "sbg:revisionNotes": "File types -> file type HDF5"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1577462877,
                        "sbg:revisionNotes": "inputs -> in_array -> file type -> hdf5"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578496948,
                        "sbg:revisionNotes": "in_array no file types"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578498130,
                        "sbg:revisionNotes": "test glob -> .txt"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578655474,
                        "sbg:revisionNotes": "no base command"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578655566,
                        "sbg:revisionNotes": "input removed from command line"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578657168,
                        "sbg:revisionNotes": "cwl copy/paste from SBGGroupOutputs test tool"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578662116,
                        "sbg:revisionNotes": "base command broken into lines"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578663492,
                        "sbg:revisionNotes": "File? -> [File, null], null"
                    }
                ],
                "sbg:image_url": null,
                "sbg:toolkit": "SBGTools",
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/sbg-group-outputs/12",
                "sbg:revision": 12,
                "sbg:revisionNotes": "File? -> [File, null], null",
                "sbg:modifiedOn": 1578663492,
                "sbg:modifiedBy": "milena_stanojevic",
                "sbg:createdOn": 1551355108,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "milena_stanojevic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 12,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "ad3e4e1c72bc85fa87f0752ab063457bf68560cb368f873ae2618d13369f8b32f"
            },
            "label": "SBG Group Outputs Normal",
            "sbg:x": 2660.078125,
            "sbg:y": -393.1075744628906
        },
        {
            "id": "sbg_group_outputs_oncotator",
            "in": [
                {
                    "id": "in_array",
                    "source": [
                        "gatk_cnv_oncotatesegments/oncotated_gene_list",
                        "gatk_cnv_oncotatesegments/oncotated_called_file"
                    ]
                }
            ],
            "out": [
                {
                    "id": "out_array"
                }
            ],
            "run": {
                "class": "CommandLineTool",
                "cwlVersion": "v1.0",
                "$namespaces": {
                    "sbg": "https://sevenbridges.com"
                },
                "id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/sbg-group-outputs/12",
                "baseCommand": [
                    "echo",
                    "propagating",
                    "inputs"
                ],
                "inputs": [
                    {
                        "id": "in_array",
                        "type": [
                            "null",
                            {
                                "type": "array",
                                "items": [
                                    "File",
                                    "null"
                                ]
                            }
                        ],
                        "inputBinding": {
                            "position": 0,
                            "shellQuote": false
                        },
                        "label": "Input array",
                        "doc": "Array of input files."
                    }
                ],
                "outputs": [
                    {
                        "id": "out_array",
                        "doc": "Grouped files",
                        "label": "Output array",
                        "type": "File[]",
                        "outputBinding": {
                            "glob": ".txt",
                            "outputEval": "${\n    var out = []\n    for (var i = 0; i < inputs.in_array.length; i++){\n        if (inputs.in_array[i]){\n            out.push(inputs.in_array[i])\n            \n        }\n    }\n    return out\n}"
                        },
                        "sbg:fileTypes": "TXT, TSV, SEG, PNG, HDF5, PARAM"
                    }
                ],
                "doc": "SBG Group Outputs is a simple tool which propagates array of input files to a single output port.",
                "label": "SBG Group Outputs",
                "requirements": [
                    {
                        "class": "ShellCommandRequirement"
                    },
                    {
                        "class": "ResourceRequirement",
                        "coresMin": 1
                    },
                    {
                        "class": "DockerRequirement",
                        "dockerPull": "ubuntu:16.04"
                    },
                    {
                        "class": "InlineJavascriptRequirement"
                    }
                ],
                "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
                "sbg:revisionsInfo": [
                    {
                        "sbg:revision": 0,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551355108,
                        "sbg:revisionNotes": null
                    },
                    {
                        "sbg:revision": 1,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1551355145,
                        "sbg:revisionNotes": "init"
                    },
                    {
                        "sbg:revision": 2,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553690258,
                        "sbg:revisionNotes": "add basic info, add input and output labels and descriptions"
                    },
                    {
                        "sbg:revision": 3,
                        "sbg:modifiedBy": "stefan_stojanovic",
                        "sbg:modifiedOn": 1553783297,
                        "sbg:revisionNotes": "add file formats; add toolkit"
                    },
                    {
                        "sbg:revision": 4,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1577462831,
                        "sbg:revisionNotes": "File types -> file type HDF5"
                    },
                    {
                        "sbg:revision": 5,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1577462877,
                        "sbg:revisionNotes": "inputs -> in_array -> file type -> hdf5"
                    },
                    {
                        "sbg:revision": 6,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578496948,
                        "sbg:revisionNotes": "in_array no file types"
                    },
                    {
                        "sbg:revision": 7,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578498130,
                        "sbg:revisionNotes": "test glob -> .txt"
                    },
                    {
                        "sbg:revision": 8,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578655474,
                        "sbg:revisionNotes": "no base command"
                    },
                    {
                        "sbg:revision": 9,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578655566,
                        "sbg:revisionNotes": "input removed from command line"
                    },
                    {
                        "sbg:revision": 10,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578657168,
                        "sbg:revisionNotes": "cwl copy/paste from SBGGroupOutputs test tool"
                    },
                    {
                        "sbg:revision": 11,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578662116,
                        "sbg:revisionNotes": "base command broken into lines"
                    },
                    {
                        "sbg:revision": 12,
                        "sbg:modifiedBy": "milena_stanojevic",
                        "sbg:modifiedOn": 1578663492,
                        "sbg:revisionNotes": "File? -> [File, null], null"
                    }
                ],
                "sbg:image_url": null,
                "sbg:toolkit": "SBGTools",
                "sbg:appVersion": [
                    "v1.0"
                ],
                "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/sbg-group-outputs/12",
                "sbg:revision": 12,
                "sbg:revisionNotes": "File? -> [File, null], null",
                "sbg:modifiedOn": 1578663492,
                "sbg:modifiedBy": "milena_stanojevic",
                "sbg:createdOn": 1551355108,
                "sbg:createdBy": "stefan_stojanovic",
                "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
                "sbg:sbgMaintained": false,
                "sbg:validationErrors": [],
                "sbg:contributors": [
                    "milena_stanojevic",
                    "stefan_stojanovic"
                ],
                "sbg:latestRevision": 12,
                "sbg:publisher": "sbg",
                "sbg:content_hash": "ad3e4e1c72bc85fa87f0752ab063457bf68560cb368f873ae2618d13369f8b32f"
            },
            "label": "SBG Group Outputs Oncotator",
            "sbg:x": 2842.666748046875,
            "sbg:y": 54
        }
    ],
    "hints": [
        {
            "class": "sbg:maxNumberOfParallelInstances",
            "value": "2"
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
            "class": "MultipleInputFeatureRequirement"
        }
    ],
    "sbg:projectName": "GATK 4.1.0.0 Toolkit DEV",
    "sbg:revisionsInfo": [
        {
            "sbg:revision": 0,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551311053,
            "sbg:revisionNotes": null
        },
        {
            "sbg:revision": 1,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551311143,
            "sbg:revisionNotes": "add PreprocessIntervals, expose ports and parameters"
        },
        {
            "sbg:revision": 2,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551311578,
            "sbg:revisionNotes": "add CollectAllelicCounts for tumor and normal, connect ports, expose inputs, set default memory_per_job to 13000mb"
        },
        {
            "sbg:revision": 3,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551311839,
            "sbg:revisionNotes": "add CollectReadCounts for tumor and normal sample, connect ports, expose input parameters, set default values and set memory_per_job to 7000"
        },
        {
            "sbg:revision": 4,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551312187,
            "sbg:revisionNotes": "add DenoiseReadCounts, connect ports, set default memory_per_job to 13000"
        },
        {
            "sbg:revision": 5,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551312508,
            "sbg:revisionNotes": "add PlotDenoisedCopyRatios, connect ports, set default memory_per_job to 7000"
        },
        {
            "sbg:revision": 6,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551313172,
            "sbg:revisionNotes": "add ModelSegments tumor, expose all ports, set default memory_per_job to 13000"
        },
        {
            "sbg:revision": 7,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551313599,
            "sbg:revisionNotes": "add ModelSegments normal, expose all ports, set default memory_per_job to 13000"
        },
        {
            "sbg:revision": 8,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551314054,
            "sbg:revisionNotes": "add PlotModeledSegments for tumor and normal, connect ports, set default memory_per_job to 7000"
        },
        {
            "sbg:revision": 9,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551314454,
            "sbg:revisionNotes": "add CallCopyRatioSegments for tumor and normal, connect ports, set default memory_per_job to 7000"
        },
        {
            "sbg:revision": 10,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551314758,
            "sbg:revisionNotes": "add OncotateSegments, connect ports, set input parameters to default values"
        },
        {
            "sbg:revision": 11,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551314863,
            "sbg:revisionNotes": "expose few outputs"
        },
        {
            "sbg:revision": 12,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551315867,
            "sbg:revisionNotes": "PreprocessIntervals: interval_merging_rule set to overlapping_only"
        },
        {
            "sbg:revision": 13,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551315933,
            "sbg:revisionNotes": "set instance hint to c4.4xlarge"
        },
        {
            "sbg:revision": 14,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551354125,
            "sbg:revisionNotes": "add description"
        },
        {
            "sbg:revision": 15,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551354347,
            "sbg:revisionNotes": "edit typos in description"
        },
        {
            "sbg:revision": 16,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551354636,
            "sbg:revisionNotes": "edit references"
        },
        {
            "sbg:revision": 17,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551354878,
            "sbg:revisionNotes": "edit description"
        },
        {
            "sbg:revision": 18,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551355928,
            "sbg:revisionNotes": "add sbg_group_outputs for tumor and normal files"
        },
        {
            "sbg:revision": 19,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551356121,
            "sbg:revisionNotes": "add output ports for preprocessed intervals and entity IDs; add sbg_group_outputs for oncotator; remove redundant output ports"
        },
        {
            "sbg:revision": 20,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551356469,
            "sbg:revisionNotes": "set required inputs"
        },
        {
            "sbg:revision": 21,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551356777,
            "sbg:revisionNotes": "edit benchmarking table"
        },
        {
            "sbg:revision": 22,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551385474,
            "sbg:revisionNotes": "expose memory_per_job for CollectAllelicCounts step as ports, leave default value at 13000"
        },
        {
            "sbg:revision": 23,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551385527,
            "sbg:revisionNotes": "set instance hint to c4.8xlarge, to allow for more memory if needed"
        },
        {
            "sbg:revision": 24,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551386858,
            "sbg:revisionNotes": "add common issues and notes section to description"
        },
        {
            "sbg:revision": 25,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551392959,
            "sbg:revisionNotes": "set c4.8xlarge instance type"
        },
        {
            "sbg:revision": 26,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551398227,
            "sbg:revisionNotes": "CollectAllelicCounts: memory_overhead set to 100 for both tumor and normal"
        },
        {
            "sbg:revision": 27,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551566666,
            "sbg:revisionNotes": "CollectAllelicCounts: revert to revision 2; remove instance hint on wf level"
        },
        {
            "sbg:revision": 28,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551598381,
            "sbg:revisionNotes": "expose memory_per_job for modelSegments steps, connect to single input port"
        },
        {
            "sbg:revision": 29,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551693548,
            "sbg:revisionNotes": "ModelSegments: update memory requirement expression, set default 2048, remove default overhead; set sbg:maxNumberOfParallelInstances hint to 2"
        },
        {
            "sbg:revision": 30,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551705063,
            "sbg:revisionNotes": "add api python implementation"
        },
        {
            "sbg:revision": 31,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551708732,
            "sbg:revisionNotes": "update description, common issues and important notes"
        },
        {
            "sbg:revision": 32,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551708858,
            "sbg:revisionNotes": "fix description formatting"
        },
        {
            "sbg:revision": 33,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551780522,
            "sbg:revisionNotes": "add benchmarking data"
        },
        {
            "sbg:revision": 34,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1551781919,
            "sbg:revisionNotes": "change labels and add description for input files"
        },
        {
            "sbg:revision": 35,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552564041,
            "sbg:revisionNotes": "add input parameter labels and descriptions for most of tools"
        },
        {
            "sbg:revision": 36,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1552564587,
            "sbg:revisionNotes": "add input parameter labels and descriptions for ModelSegments"
        },
        {
            "sbg:revision": 37,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553786058,
            "sbg:revisionNotes": "update apps, reconnect ports, output couple of files for testing purposes"
        },
        {
            "sbg:revision": 38,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553792279,
            "sbg:revisionNotes": "connect unconnected ports"
        },
        {
            "sbg:revision": 39,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553793292,
            "sbg:revisionNotes": "connect allelic counts to reads port"
        },
        {
            "sbg:revision": 40,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553795445,
            "sbg:revisionNotes": "connect CallCopyRatioSegments with ModelSegments"
        },
        {
            "sbg:revision": 41,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553807947,
            "sbg:revisionNotes": "fix description per review notes"
        },
        {
            "sbg:revision": 42,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553808193,
            "sbg:revisionNotes": "fix typos in description"
        },
        {
            "sbg:revision": 43,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553808745,
            "sbg:revisionNotes": "fix minor typos in description"
        },
        {
            "sbg:revision": 44,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553812004,
            "sbg:revisionNotes": "CollectReadCounts: set in_alignments (--input) parameter to required"
        },
        {
            "sbg:revision": 45,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553815328,
            "sbg:revisionNotes": "connect all ports, set required inputs, output all files"
        },
        {
            "sbg:revision": 46,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553815593,
            "sbg:revisionNotes": "PlotDenoisedCopyRatios: fix conditional metadata inheritance for all output files"
        },
        {
            "sbg:revision": 47,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553816060,
            "sbg:revisionNotes": "re-expose input reads ports"
        },
        {
            "sbg:revision": 48,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553816521,
            "sbg:revisionNotes": "CollectAllelicCounts: fix output naming expression, concat to array before accessing element"
        },
        {
            "sbg:revision": 49,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553816957,
            "sbg:revisionNotes": "set in_aligments_normal to not required; CollectReadCounts: fix output naming expression, concat to array before accessing element"
        },
        {
            "sbg:revision": 50,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553817275,
            "sbg:revisionNotes": "CollectAllelicCounts and CollectReadCounts: add secondary file requirements for in_alignments"
        },
        {
            "sbg:revision": 51,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553854217,
            "sbg:revisionNotes": "add new benchmarking info"
        },
        {
            "sbg:revision": 52,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553950129,
            "sbg:revisionNotes": "minor fixes in description"
        },
        {
            "sbg:revision": 53,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553950205,
            "sbg:revisionNotes": "CollectReadCounts: change back choices for output_format to uppercase; fix glob expressions to catch uppercase extensions; add secondary file requirements for in_reference on wf level"
        },
        {
            "sbg:revision": 54,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553952707,
            "sbg:revisionNotes": "test secondary file requirement {.bai,^.bai} on wf level"
        },
        {
            "sbg:revision": 55,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1553954954,
            "sbg:revisionNotes": "remove secondary file requirement for in_alignments_tumor on wf level"
        },
        {
            "sbg:revision": 56,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1554027328,
            "sbg:revisionNotes": "add coverage info to benchmarking table"
        },
        {
            "sbg:revision": 57,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1559751443,
            "sbg:revisionNotes": "update all apps"
        },
        {
            "sbg:revision": 58,
            "sbg:modifiedBy": "stefan_stojanovic",
            "sbg:modifiedOn": 1559752163,
            "sbg:revisionNotes": "update CollectReadCounts: edit entity_id eval expression"
        },
        {
            "sbg:revision": 59,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1577365806,
            "sbg:revisionNotes": "CWL validation - adapting connections between tools - File→[ File ]"
        },
        {
            "sbg:revision": 60,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1577369637,
            "sbg:revisionNotes": "Secondary files for CollectAllelicCounts tumor/normal updated"
        },
        {
            "sbg:revision": 61,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1577370537,
            "sbg:revisionNotes": "Secondary files for CollectReadCounts tumor/normal updated (tool itself is updated)"
        },
        {
            "sbg:revision": 62,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1577462159,
            "sbg:revisionNotes": "Glob change for CollectReadCounts -> only *hdf5"
        },
        {
            "sbg:revision": 63,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1578492867,
            "sbg:revisionNotes": "SBG Group Outputs update - only HDF5"
        },
        {
            "sbg:revision": 64,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1578492929,
            "sbg:revisionNotes": "InlineJavaScript"
        },
        {
            "sbg:revision": 65,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1578497030,
            "sbg:revisionNotes": "SBG group outputs tool update - in array input -> no file types"
        },
        {
            "sbg:revision": 66,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1578508184,
            "sbg:revisionNotes": "SBG group output tool update"
        },
        {
            "sbg:revision": 67,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1578656276,
            "sbg:revisionNotes": "SBG Group Outputs tool update - removed base command \"echo\""
        },
        {
            "sbg:revision": 68,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1578657286,
            "sbg:revisionNotes": "SBG Group Outputs tool update - test tool"
        },
        {
            "sbg:revision": 69,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1578658141,
            "sbg:revisionNotes": "No SBG Group Outputs for Oncotator"
        },
        {
            "sbg:revision": 70,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1578662244,
            "sbg:revisionNotes": "update sbg group outputs tool - command line broken into lines"
        },
        {
            "sbg:revision": 71,
            "sbg:modifiedBy": "milena_stanojevic",
            "sbg:modifiedOn": 1578663620,
            "sbg:revisionNotes": "sbg group outputs tool update ->  File? -> [File, null], null (inputs)"
        }
    ],
    "sbg:image_url": "https://igor.sbgenomics.com/ns/brood/images/veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-cnv-somatic-pair-workflow/71.png",
    "sbg:appVersion": [
        "v1.0"
    ],
    "sbg:id": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-cnv-somatic-pair-workflow/71",
    "sbg:revision": 71,
    "sbg:revisionNotes": "sbg group outputs tool update ->  File? -> [File, null], null (inputs)",
    "sbg:modifiedOn": 1578663620,
    "sbg:modifiedBy": "milena_stanojevic",
    "sbg:createdOn": 1551311053,
    "sbg:createdBy": "stefan_stojanovic",
    "sbg:project": "veliborka_josipovic/gatk-4-1-0-0-toolkit-dev",
    "sbg:sbgMaintained": false,
    "sbg:validationErrors": [],
    "sbg:contributors": [
        "milena_stanojevic",
        "stefan_stojanovic"
    ],
    "sbg:latestRevision": 71,
    "sbg:publisher": "sbg",
    "sbg:content_hash": "a0575096aaac4108eff7240802c121c3be5beb929d0c46546d95610fac1929029"
}