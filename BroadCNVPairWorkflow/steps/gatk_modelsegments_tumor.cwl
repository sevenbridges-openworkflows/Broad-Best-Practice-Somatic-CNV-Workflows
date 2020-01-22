$namespaces:
  sbg: https://sevenbridges.com
arguments:
- position: 0
  prefix: ''
  shellQuote: false
  valueFrom: '$( inputs.denoised_copy_ratios ? ''/opt/gatk'' : ''echo /opt/gatk'')'
- position: 1
  shellQuote: false
  valueFrom: --java-options
- position: 2
  prefix: ''
  shellQuote: false
  valueFrom: "${\n    if (inputs.memory_per_job) {\n        return '\\\"-Xmx'.concat(inputs.memory_per_job,\
    \ 'M') + '\\\"';\n    }\n    return '\\\"-Xmx2048M\\\"';\n}"
- position: 3
  shellQuote: false
  valueFrom: ModelSegments
- position: 4
  prefix: --output
  shellQuote: false
  valueFrom: .
- position: 5
  prefix: --output-prefix
  shellQuote: false
  valueFrom: "${\n    if (inputs.output_prefix) {\n        return inputs.output_prefix;\n\
    \    } else {\n        if (inputs.denoised_copy_ratios) {\n            return\
    \ inputs.denoised_copy_ratios.nameroot.split('.').slice(0,-1).join('.');\n   \
    \     } else if (inputs.allelic_counts) {\n            return inputs.allelic_counts.nameroot.split('.').slice(0,-1).join('.');\n\
    \        } else {\n            return 'output_ModelSegments';\n        }\n   \
    \ }\n    return 'output_ModelSegments';\n}"
- position: 4
  prefix: --minimum-total-allele-count-case
  shellQuote: false
  valueFrom: "${\n    var default_min_count = inputs.normal_allelic_counts ? 0 : 30;\n\
    \    var min_count = inputs.minimum_total_allele_count_case ? inputs.minimum_total_allele_count_case\
    \ : default_min_count;\n    return min_count;\n}"
baseCommand: []
class: CommandLineTool
cwlVersion: v1.0
doc: 'GATK ModelSegmens models segmented copy ratios from denoised read counts and
  segmented minor-allele fractions from allelic counts.



  ### Common Use Cases


  Possible inputs are: 1) denoised copy ratios for the case sample, 2) allelic counts
  for the case sample, and 3) allelic counts for a matched-normal sample. All available
  inputs will be used to to perform segmentation and model inference.

  If allelic counts are available, the first step in the inference process is to genotype
  heterozygous sites, as the allelic counts at these sites will subsequently be modeled
  to infer segmented minor-allele fraction. We perform a relatively simple and naive
  genotyping based on the allele counts (i.e., pileups), which is controlled by a
  small number of parameters (minimum-total-allele-count, genotyping-homozygous-log-ratio-threshold,
  and genotyping-homozygous-log-ratio-threshold). If the matched normal is available,
  its allelic counts will be used to genotype the sites, and we will simply assume
  these genotypes are the same in the case sample. (This can be critical, for example,
  for determining sites with loss of heterozygosity in high purity case samples; such
  sites will be genotyped as homozygous if the matched-normal sample is not available.)


  Next, if available, the denoised copy ratios are segmented and the alternate-allele
  fractions at the genotyped heterozygous sites. This is done using kernel segmentation
  (see **KernelSegmenter**). Various segmentation parameters control the sensitivity
  of the segmentation and should be selected appropriately for each analysis.


  If both copy ratios and allele fractions are available, we perform segmentation
  using a combined kernel that is sensitive to changes that occur not only in either
  of the two but also in both. However, in this case, we simply discard all allele
  fractions at sites that lie outside of the available copy-ratio intervals (rather
  than imputing the missing copy-ratio data); these sites are filtered out during
  the genotyping step discussed above. This can have implications for analyses involving
  the sex chromosomes; see comments in **CreateReadCountPanelOfNormals**.


  After segmentation is complete, we run Markov-chain Monte Carlo (MCMC) to determine
  posteriors for segmented models for the log2 copy ratio and the minor-allele fraction;
  see **CopyRatioModeller** and **AlleleFractionModeller**, respectively. After the
  first run of MCMC is complete, smoothing of the segmented posteriors is performed
  by merging adjacent segments whose posterior credible intervals sufficiently overlap
  according to specified segmentation-smoothing parameters. Then, additional rounds
  of segmentation smoothing (with intermediate MCMC optionally performed in between
  rounds) are performed until convergence, at which point a final round of MCMC is
  performed.


  *Source: [https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_ModelSegments.php](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_ModelSegments.php)*


  Some of the input parameters are listed below:

  * **Denoised copy ratios** (`--denoised-copy-ratios`) - TSV file with denoised copy
  rations, output of **DenoiseReadCounts**. If allelic counts are not provided, then
  this is required.

  * **Allelic counts** (`--allelic-counts`) - TSV file containing alt and ref allelic
  count at specified positions, output of **CollectAllelicCounts**. If denoised copy
  ratios are not provided, then this is required.

  * **Normal allelic counts** (`--normal-allelic-counts`) - TSV file containing allelic
  counts of matched normal sample, output of **CollectAllelicCounts**. This can only
  be provided if allelic counts for the case sample are also provided.

  * **Output prefix** (`--output-prefix`) - This is used as the basename for output
  files. If not specified output files will be named by either **Denoised copy ratios**
  or **Allelic counts** (see #Changes Introduced by Seven Bridges).


  ### Changes Introduced by Seven Bridges

  * If **Output prefix** parameter is not specified, the prefix will be derived from
  the basename of the **Denoised copy ratios** file. In case this file is not specified,
  the prefix will be derived from the basename of **Allelic counts** file, as one
  of those two files are required for the execution.


  ### Common Issues and Important Notes

  * The default 2048 Mb of memory may not be sufficient for average analysis. We advise
  using at least 13000 Mb (13GB) of memory for standard WES analysis and in some cases
  of WES and WGS analyses as much as 32000 Mb (32GB) may be needed. Memory can be
  allocated through **Memory per job** input parameter.


  ### Performance Benchmarking


  | Input Size | Experimental Strategy | Memory | Duration | Cost (spot) | AWS Instance
  Type |

  | --- | --- | --- | --- | --- | --- |

  | 0.2GB | WES | 2048MB | 6min | $0.03 | c4.2xlarge |

  | 2.4GB | WGS | 32000MB | 46min | $0.26 | m5.2xlarge |'
id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-modelsegments-4-1-0-0/22
inputs:
- doc: Input file containing allelic counts (output of **CollectAllelicCounts**).
  id: allelic_counts
  inputBinding:
    position: 4
    prefix: --allelic-counts
    shellQuote: false
  label: Allelic counts
  sbg:category: Optional Arguments
  sbg:fileTypes: TSV
  sbg:toolDefaultValue: 'null'
  type: File?
- doc: Input file containing denoised copy ratios (output of denoisereadcounts).
  id: denoised_copy_ratios
  inputBinding:
    position: 4
    prefix: --denoised-copy-ratios
    shellQuote: false
  label: Denoised copy ratios
  sbg:category: Optional Arguments
  sbg:fileTypes: TSV
  sbg:toolDefaultValue: 'null'
  type: File?
- doc: Maximum base-error rate for genotyping and filtering homozygous allelic counts,
    if available. The likelihood for an allelic count to be generated from a homozygous
    site will be integrated from zero base-error rate up to this value. Decreasing
    this value will increase the number of sites assumed to be heterozygous for modeling.
    05.
  id: genotyping_base_error_rate
  inputBinding:
    position: 4
    prefix: --genotyping-base-error-rate
    shellQuote: false
  label: Genotyping base error rate
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: float?
- doc: Log-ratio threshold for genotyping and filtering homozygous allelic counts,
    if available. Increasing this value will increase the number of sites assumed
    to be heterozygous for modeling. 0.
  id: genotyping_homozygous_log_ratio_threshold
  inputBinding:
    position: 4
    prefix: --genotyping-homozygous-log-ratio-threshold
    shellQuote: false
  label: Genotyping homozygous log ratio threshold
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '-10'
  type: float?
- doc: Dimension of the kernel approximation. A subsample containing this number of
    data points will be used to construct the approximation for each chromosome. If
    the total number of data points in a chromosome is greater than this number, then
    all data points in the chromosome will be used. Time complexity scales quadratically
    and space complexity scales linearly with this parameter.
  id: kernel_approximation_dimension
  inputBinding:
    position: 4
    prefix: --kernel-approximation-dimension
    shellQuote: false
  label: Kernel approximation dimension
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '100'
  type: int?
- doc: Relative scaling s of the kernel k_af for allele-fraction segmentation to the
    kernel k_cr for copy-ratio segmentation. If multidimensional segmentation is performed,
    the total kernel used will be k_cr.
  id: kernel_scaling_allele_fraction
  inputBinding:
    position: 4
    prefix: --kernel-scaling-allele-fraction
    shellQuote: false
  label: Kernel scaling allele fraction
  sbg:category: Optional Arguments
  type: float?
- doc: Variance of gaussian kernel for allele-fraction segmentation, if performed.
    If zero, a linear kernel will be used. 025.
  id: kernel_variance_allele_fraction
  inputBinding:
    position: 4
    prefix: --kernel-variance-allele-fraction
    shellQuote: false
  label: Kernel variance allele fraction
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: float?
- doc: Variance of gaussian kernel for copy-ratio segmentation, if performed. If zero,
    a linear kernel will be used. 0.
  id: kernel_variance_copy_ratio
  inputBinding:
    position: 4
    prefix: --kernel-variance-copy-ratio
    shellQuote: false
  label: Kernel variance copy ratio
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: float?
- doc: Maximum number of segments allowed per chromosome.
  id: maximum_number_of_segments_per_chromosome
  inputBinding:
    position: 4
    prefix: --maximum-number-of-segments-per-chromosome
    shellQuote: false
  label: Maximum number of segments per chromosome
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '1000'
  type: int?
- doc: Maximum number of iterations allowed for segmentation smoothing.
  id: maximum_number_of_smoothing_iterations
  inputBinding:
    position: 4
    prefix: --maximum-number-of-smoothing-iterations
    shellQuote: false
  label: Maximum number of smoothing iterations
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '25'
  type: int?
- doc: Memory overhead which will be allocated for one job.
  id: memory_overhead_per_job
  label: Memory overhead per job
  sbg:category: Execution
  sbg:toolDefaultValue: '0'
  type: int?
- doc: Memory which will be allocated for execution.
  id: memory_per_job
  label: Memory per job
  sbg:category: Execution
  sbg:toolDefaultValue: '2048'
  type: int?
- doc: Minimum total count for filtering allelic counts in matched-normal sample,
    if available.
  id: minimum_total_allele_count_normal
  inputBinding:
    position: 4
    prefix: --minimum-total-allele-count-normal
    shellQuote: false
  label: Minimum total allele count normal
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '30'
  type: int?
- doc: Alpha hyperparameter for the 4-parameter beta-distribution prior on segment
    minor-allele fraction. The prior for the minor-allele fraction f in each segment
    is assumed to be beta(alpha, 1, 0, 1/2). Increasing this hyperparameter will reduce
    the effect of reference bias at the expense of sensitivity. 0.
  id: minor_allele_fraction_prior_alpha
  inputBinding:
    position: 4
    prefix: --minor-allele-fraction-prior-alpha
    shellQuote: false
  label: Minor allele fraction prior alpha
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '25'
  type: float?
- doc: Input file containing allelic counts for a matched normal (output of collectalleliccounts).
  id: normal_allelic_counts
  inputBinding:
    position: 4
    prefix: --normal-allelic-counts
    shellQuote: false
  label: Normal allelic counts
  sbg:category: Optional Arguments
  sbg:fileTypes: TSV
  sbg:toolDefaultValue: 'null'
  type: File?
- doc: Number of burn-in samples to discard for allele-fraction model.
  id: number_of_burn_in_samples_allele_fraction
  inputBinding:
    position: 4
    prefix: --number-of-burn-in-samples-allele-fraction
    shellQuote: false
  label: Number of burn in samples allele fraction
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '50'
  type: int?
- doc: Number of burn-in samples to discard for copy-ratio model.
  id: number_of_burn_in_samples_copy_ratio
  inputBinding:
    position: 4
    prefix: --number-of-burn-in-samples-copy-ratio
    shellQuote: false
  label: Number of burn in samples copy ratio
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '50'
  type: int?
- doc: Factor a for the penalty on the number of changepoints per chromosome for segmentation.
    Adds a penalty of the form a.
  id: number_of_changepoints_penalty_factor
  inputBinding:
    position: 4
    prefix: --number-of-changepoints-penalty-factor
    shellQuote: false
  label: Number of changepoints penalty factor
  sbg:category: Optional Arguments
  type: float?
- doc: Total number of mcmc samples for allele-fraction model.
  id: number_of_samples_allele_fraction
  inputBinding:
    position: 4
    prefix: --number-of-samples-allele-fraction
    shellQuote: false
  label: Number of samples allele fraction
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '100'
  type: int?
- doc: Total number of mcmc samples for copy-ratio model.
  id: number_of_samples_copy_ratio
  inputBinding:
    position: 4
    prefix: --number-of-samples-copy-ratio
    shellQuote: false
  label: Number of samples copy ratio
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '100'
  type: int?
- doc: Number of segmentation-smoothing iterations per mcmc model refit. (increasing
    this will decrease runtime, but the final number of segments may be higher. Setting
    this to 0 will completely disable model refitting between iterations.).
  id: number_of_smoothing_iterations_per_fit
  inputBinding:
    position: 4
    prefix: --number-of-smoothing-iterations-per-fit
    shellQuote: false
  label: Number of smoothing iterations per fit
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: int?
- doc: Prefix for output files.
  id: output_prefix
  label: Output prefix
  sbg:category: Required Arguments
  type: string?
- doc: Number of 10.
  id: smoothing_credible_interval_threshold_allele_fraction
  inputBinding:
    position: 4
    prefix: --smoothing-credible-interval-threshold-allele-fraction
    shellQuote: false
  label: Smoothing credible interval threshold allele fraction
  sbg:category: Optional Arguments
  type: float?
- doc: Number of 10.
  id: smoothing_credible_interval_threshold_copy_ratio
  inputBinding:
    position: 4
    prefix: --smoothing-credible-interval-threshold-copy-ratio
    shellQuote: false
  label: Smoothing credible interval threshold copy ratio
  sbg:category: Optional Arguments
  type: float?
- doc: Window sizes to use for calculating local changepoint costs. For each window
    size, the cost for each data point to be a changepoint will be calculated assuming
    that the point demarcates two adjacent segments of that size. Including small
    (large) window sizes will increase sensitivity to small (large) events. Duplicate
    values will be ignored. Default value:.
  id: window_size
  inputBinding:
    position: 4
    prefix: --window-size
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        self = [].concat(self);\n        return\
      \ self.join(' --window-size ');\n    }\n    return '';\n}"
  label: Window size
  sbg:category: Optional Arguments
  type: int[]?
- doc: Number of CPUs which will be allocated for the job.
  id: cpu_per_job
  label: CPU per job
  sbg:category: Execution
  sbg:toolDefaultValue: '1'
  type: int?
- doc: 'Minimum total count for filtering allelic counts in the case sample, if available.  The
    default value of zero is appropriate for matched-normal mode; increase to an appropriate
    value for case-only mode.  Default value: 0.'
  id: minimum_total_allele_count_case
  label: Minimum total allele count case
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: int?
label: GATK ModelSegments
outputs:
- doc: Allelic-counts file containing the counts at sites genotyped as heterozygous
    in the case sample (.hets.tsv). This is a tab-separated values (TSV) file with
    a SAM-style header containing a read group sample name, a sequence dictionary,
    a row specifying the column headers contained in AllelicCountCollection. AllelicCountTableColumn,
    and the corresponding entry rows. This is only output if normal allelic counts
    are provided as input.
  id: het_allelic_counts
  label: Allelic counts
  outputBinding:
    glob: '*.hets.tsv'
    outputEval: "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios)\
      \ {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out =\
      \ inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n\
      \        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata)\
      \ {\n            out = inheritMetadata(self, inputs.allelic_counts);\n     \
      \       return out;\n        }\n    }\n    return self;\n}"
  sbg:fileTypes: TSV
  type: File?
- doc: Allelic-counts file containing the counts at sites genotyped as heterozygous
    in the matched-normal sample (.hets.normal.tsv).
  id: normal_het_allelic_counts
  label: Normal allelic counts
  outputBinding:
    glob: '*.hets.normal.tsv'
    outputEval: "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios)\
      \ {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out =\
      \ inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n\
      \        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata)\
      \ {\n            out = inheritMetadata(self, inputs.allelic_counts);\n     \
      \       return out;\n        }\n    }\n    return self;\n}"
  sbg:fileTypes: TSV
  type: File?
- doc: This is a tab-separated values (TSV) file with a SAM-style header containing
    a read group sample name, a sequence dictionary, a row specifying the column headers
    contained in CopyRatioSegmentCollection.CopyRatioSegmentTableColumn, and the corresponding
    entry rows. It contains the segments from the .modelFinal.seg file converted to
    a format suitable for input to CallCopyRatioSegments.
  id: copy_ratio_only_segments
  label: Copy ratio segments
  outputBinding:
    glob: '*.cr.seg'
    outputEval: "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios)\
      \ {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out =\
      \ inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n\
      \        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata)\
      \ {\n            out = inheritMetadata(self, inputs.allelic_counts);\n     \
      \       return out;\n        }\n    }\n    return self;\n}"
  sbg:fileTypes: TSV, SEG
  type: File?
- doc: TSV file with CBS-format column headers and the corresponding entry rows that
    can be plotted using IGV.
  id: copy_ratio_legacy_segments
  label: Copy ratio legacy segments
  outputBinding:
    glob: '*.cr.igv.seg'
    outputEval: "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios)\
      \ {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out =\
      \ inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n\
      \        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata)\
      \ {\n            out = inheritMetadata(self, inputs.allelic_counts);\n     \
      \       return out;\n        }\n    }\n    return self;\n}"
  sbg:fileTypes: SEG, TSV
  type: File?
- doc: TSV file with CBS-format column headers and the corresponding entry rows that
    can be plotted using IGV.
  id: allele_fraction_legacy_segments
  label: Allele fraction legacy segments
  outputBinding:
    glob: '*.af.igv.seg'
    outputEval: "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios)\
      \ {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out =\
      \ inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n\
      \        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata)\
      \ {\n            out = inheritMetadata(self, inputs.allelic_counts);\n     \
      \       return out;\n        }\n    }\n    return self;\n}"
  sbg:fileTypes: SEG, TSV
  type: File?
- doc: TSV file containing modeled segments with the initial results before segmentation
    smoothing.
  id: modeled_segments_begin
  label: Modeled segments begin
  outputBinding:
    glob: '*.modelBegin.seg'
    outputEval: "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios)\
      \ {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out =\
      \ inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n\
      \        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata)\
      \ {\n            out = inheritMetadata(self, inputs.allelic_counts);\n     \
      \       return out;\n        }\n    }\n    return self;\n}"
  sbg:fileTypes: SEG, TSV
  type: File?
- doc: Copy ration parametets file with initial result before segmentation smoothing.
  id: copy_ratio_parameters_begin
  label: Copy ratio parameters begin
  outputBinding:
    glob: '*.modelBegin.cr.param'
    outputEval: "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios)\
      \ {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out =\
      \ inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n\
      \        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata)\
      \ {\n            out = inheritMetadata(self, inputs.allelic_counts);\n     \
      \       return out;\n        }\n    }\n    return self;\n}"
  sbg:fileTypes: PARAM, TSV
  type: File?
- doc: Allele fraction parameters file with initial result before segmentation smoothing.
  id: allele_fraction_parameters_begin
  label: Allele fraction parameters begin
  outputBinding:
    glob: '*.modelBegin.af.param'
    outputEval: "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios)\
      \ {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out =\
      \ inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n\
      \        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata)\
      \ {\n            out = inheritMetadata(self, inputs.allelic_counts);\n     \
      \       return out;\n        }\n    }\n    return self;\n}"
  sbg:fileTypes: PARAM, TSV
  type: File?
- doc: TSV file containing modeled segments with the final results after segmentation
    smoothing.
  id: modeled_segments
  label: Modeled segments final
  outputBinding:
    glob: '*.modelFinal.seg'
    outputEval: "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios)\
      \ {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out =\
      \ inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n\
      \        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata)\
      \ {\n            out = inheritMetadata(self, inputs.allelic_counts);\n     \
      \       return out;\n        }\n    }\n    return self;\n}"
  sbg:fileTypes: SEG, TSV
  type: File?
- doc: Copy ration parameters file with final result after segmentation smoothing.
  id: copy_ratio_parameters
  label: Copy ratio parameters final
  outputBinding:
    glob: '*.modelFinal.cr.param'
    outputEval: "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios)\
      \ {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out =\
      \ inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n\
      \        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata)\
      \ {\n            out = inheritMetadata(self, inputs.allelic_counts);\n     \
      \       return out;\n        }\n    }\n    return self;\n}"
  sbg:fileTypes: PARAM, TSV
  type: File?
- doc: Allele fraction parameters file with final result after segmentation smoothing.
  id: allele_fraction_parameters
  label: Allele fraction parameters final
  outputBinding:
    glob: '*.modelFinal.af.param'
    outputEval: "${\n    self = [].concat(self);\n    var out;\n    if (inputs.denoised_copy_ratios)\
      \ {\n        if (inputs.denoised_copy_ratios.metadata) {\n            out =\
      \ inheritMetadata(self, inputs.denoised_copy_ratios);\n            return out;\n\
      \        }\n    } else if (inputs.allelic_counts) {\n        if (inputs.allelic_counts.metadata)\
      \ {\n            out = inheritMetadata(self, inputs.allelic_counts);\n     \
      \       return out;\n        }\n    }\n    return self;\n}"
  sbg:fileTypes: PARAM, TSV
  type: File?
requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: '$(inputs.cpu_per_job ? inputs.cpu_per_job : 1)'
  ramMin: "${  \n    var memory = 2048;\n    if (inputs.memory_per_job) {\n      \
    \  memory = inputs.memory_per_job;\n    }\n    if (inputs.memory_overhead_per_job)\
    \ {\n        memory += inputs.memory_overhead_per_job;\n    }\n    return memory;\n\
    }"
- class: DockerRequirement
  dockerPull: images.sbgenomics.com/stefan_stojanovic/gatk:4.1.0.0
- class: InitialWorkDirRequirement
  listing: []
- class: InlineJavascriptRequirement
  expressionLib:
  - "var updateMetadata = function(file, key, value) {\n    file['metadata'][key]\
    \ = value;\n    return file;\n};\n\n\nvar setMetadata = function(file, metadata)\
    \ {\n    if (!('metadata' in file))\n        file['metadata'] = metadata;\n  \
    \  else {\n        for (var key in metadata) {\n            file['metadata'][key]\
    \ = metadata[key];\n        }\n    }\n    return file\n};\n\nvar inheritMetadata\
    \ = function(o1, o2) {\n    var commonMetadata = {};\n    if (!Array.isArray(o2))\
    \ {\n        o2 = [o2]\n    }\n    for (var i = 0; i < o2.length; i++) {\n   \
    \     var example = o2[i]['metadata'];\n        for (var key in example) {\n \
    \           if (i == 0)\n                commonMetadata[key] = example[key];\n\
    \            else {\n                if (!(commonMetadata[key] == example[key]))\
    \ {\n                    delete commonMetadata[key]\n                }\n     \
    \       }\n        }\n    }\n    if (!Array.isArray(o1)) {\n        o1 = setMetadata(o1,\
    \ commonMetadata)\n    } else {\n        for (var i = 0; i < o1.length; i++) {\n\
    \            o1[i] = setMetadata(o1[i], commonMetadata)\n        }\n    }\n  \
    \  return o1;\n};\n\nvar toArray = function(file) {\n    return [].concat(file);\n\
    };\n\nvar groupBy = function(files, key) {\n    var groupedFiles = [];\n    var\
    \ tempDict = {};\n    for (var i = 0; i < files.length; i++) {\n        var value\
    \ = files[i]['metadata'][key];\n        if (value in tempDict)\n            tempDict[value].push(files[i]);\n\
    \        else tempDict[value] = [files[i]];\n    }\n    for (var key in tempDict)\
    \ {\n        groupedFiles.push(tempDict[key]);\n    }\n    return groupedFiles;\n\
    };\n\nvar orderBy = function(files, key, order) {\n    var compareFunction = function(a,\
    \ b) {\n        if (a['metadata'][key].constructor === Number) {\n           \
    \ return a['metadata'][key] - b['metadata'][key];\n        } else {\n        \
    \    var nameA = a['metadata'][key].toUpperCase();\n            var nameB = b['metadata'][key].toUpperCase();\n\
    \            if (nameA < nameB) {\n                return -1;\n            }\n\
    \            if (nameA > nameB) {\n                return 1;\n            }\n\
    \            return 0;\n        }\n    };\n\n    files = files.sort(compareFunction);\n\
    \    if (order == undefined || order == \"asc\")\n        return files;\n    else\n\
    \        return files.reverse();\n};"
sbg:appVersion:
- v1.0
sbg:categories:
- Genomics
- Copy Number Variant Calling
sbg:content_hash: a8bf865c5a923254e11991e436ebf879b7d72191a759cd51416a779f9d6172555
sbg:contributors:
- uros_sipetic
- stefan_stojanovic
sbg:createdBy: stefan_stojanovic
sbg:createdOn: 1551312575
sbg:id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-modelsegments-4-1-0-0/22
sbg:image_url: null
sbg:latestRevision: 22
sbg:license: Open source BSD (3-clause) license
sbg:modifiedBy: stefan_stojanovic
sbg:modifiedOn: 1559309194
sbg:project: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev
sbg:projectName: GATK 4.1.0.0 Toolkit DEV
sbg:publisher: sbg
sbg:revision: 22
sbg:revisionNotes: fix javascript expressions, add vars and semicolons
sbg:revisionsInfo:
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551312575
  sbg:revision: 0
  sbg:revisionNotes: null
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551312599
  sbg:revision: 1
  sbg:revisionNotes: init
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551652706
  sbg:revision: 2
  sbg:revisionNotes: fix memory requirements expression, remove default overhead,
    set default memory to 2048
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553170547
  sbg:revision: 3
  sbg:revisionNotes: Update categories
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553608892
  sbg:revision: 4
  sbg:revisionNotes: fix description formatting, add appropriate sections
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553608968
  sbg:revision: 5
  sbg:revisionNotes: add descriptions for memory per job, memory overhead and cpu
    per job input parameters
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553609643
  sbg:revision: 6
  sbg:revisionNotes: add descriptions for output files
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553610141
  sbg:revision: 7
  sbg:revisionNotes: fix expression for window_size parameter
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553610382
  sbg:revision: 8
  sbg:revisionNotes: add changes by sbg and common issues and notes
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553610953
  sbg:revision: 9
  sbg:revisionNotes: fix output files section in description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553611081
  sbg:revision: 10
  sbg:revisionNotes: add file formats for file inputs
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553612058
  sbg:revision: 11
  sbg:revisionNotes: set output_prefix as required input argument, include in command
    line
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553612766
  sbg:revision: 12
  sbg:revisionNotes: fix output naming, include in description; fix inputs formatting
    in description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553613281
  sbg:revision: 13
  sbg:revisionNotes: add metadata inheritance for two output files, for testing
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553691217
  sbg:revision: 14
  sbg:revisionNotes: fix expression typo
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553694005
  sbg:revision: 15
  sbg:revisionNotes: remove outputs section from description; merge input section
    with common use cases to match format of other tools
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553769659
  sbg:revision: 16
  sbg:revisionNotes: add benchmarking info
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1554081721
  sbg:revision: 17
  sbg:revisionNotes: add expression for min_total_allele_count_case
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1558970988
  sbg:revision: 18
  sbg:revisionNotes: fix metadata inheritance on all output files
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1558971762
  sbg:revision: 19
  sbg:revisionNotes: fix medatada expression
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1558972446
  sbg:revision: 20
  sbg:revisionNotes: fix js expression for metadata
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559050538
  sbg:revision: 21
  sbg:revisionNotes: edit expression for output evals
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559309194
  sbg:revision: 22
  sbg:revisionNotes: fix javascript expressions, add vars and semicolons
sbg:sbgMaintained: false
sbg:toolAuthor: Broad Institute
sbg:toolkit: GATK
sbg:toolkitVersion: 4.1.0.0
sbg:validationErrors: []
