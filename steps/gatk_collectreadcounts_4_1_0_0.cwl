$namespaces:
  sbg: https://sevenbridges.com
arguments:
- position: 0
  prefix: ''
  shellQuote: false
  valueFrom: '$( inputs.in_alignments ? ''/opt/gatk'' : ''echo /opt/gatk'')'
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
  valueFrom: CollectReadCounts
- position: 4
  prefix: --output
  shellQuote: false
  valueFrom: "${\n    if (inputs.in_alignments) {\n        var in_alignments_array\
    \ = [].concat(inputs.in_alignments);\n        var prefix = inputs.output_prefix\
    \ ? inputs.output_prefix : in_alignments_array[0].path.split('/').pop().split('.').slice(0,-1).join('.')\
    \ + '.readCounts';\n        var ext = inputs.output_format ? inputs.output_format\
    \ : 'hdf5';\n        return [prefix, ext].join('.');\n    }\n    return '';\n}"
baseCommand: []
class: CommandLineTool
cwlVersion: v1.0
doc: "GATK CollectReadCounts collects read counts at specified intervals by counting\
  \ the number of read starts that lie in the interval. \n\n### Common Use Cases\n\
  By default, the tool produces HDF5 format results. This can be changed with the\
  \ **Format** parameter to TSV format. Using HDF5 files with **CreateReadCountPanelOfNormals**\
  \ can decrease runtime, by reducing time spent on IO, so this is the default output\
  \ format. HDF5 files may be viewed using **hdfview** or loaded in python using **PyTables**\
  \ or **h5py**. The TSV format has a SAM-style header containing a read group sample\
  \ name, a sequence dictionary, a row specifying the column headers and the corresponding\
  \ entry rows.\n* **Input reads** (`--input`) - SAM format read data in BAM/SAM/CRAM\
  \ format. In case of BAM and CRAM files the secondary BAI and CRAI index files are\
  \ required.\n* **Intervals** (`--intervals`) at which counts will be collected.\
  \ The argument **Interval merging rule** must be set to `OVERLAPPING_ONLY` and all\
  \ other common arguments for interval padding or merging must be set to their defaults.\n\
  * **Format** (`--format`) - Select TSV or HDF5 format of the output file.\n\n*Source:\
  \ [https://software.broadinstitute.org/gatk/documentation/tooldocs/current/org_broadinstitute_hellbender_tools_copynumber_CollectReadCounts.php](https://software.broadinstitute.org/gatk/documentation/tooldocs/current/org_broadinstitute_hellbender_tools_copynumber_CollectReadCounts.php)*\n\
  \n### Changes Introduced by Seven Bridges\n* An additional output port called **Entity\
  \ ID** is added in accordance with [CNV best practice WDL](https://github.com/gatk-workflows/gatk4-somatic-cnvs/blob/master/cnv_common_tasks.wdl)\
  \ specification. This port outputs a `string` with base name of the **Input reads**\
  \ file.\n* If **Output prefix** parameter is not specified, the prefix for the output\
  \ file will be derived from the base name of the **Input reads** file.\n\n### Common\
  \ Issues and Important Notes\n* Input parameter **Interval merging rule** must be\
  \ set to `OVERLAPPING_ONLY`, otherwise the tool will produce an error.\n* The default\
  \ working memory allocated for execution is 2048 (Mb) which may be insufficient\
  \ for WGS samples or larger WES sample files. In this case please provide more memory\
  \ through **Memory per job** input parameter. We advise allocating at least 7000\
  \ Mb (7GB) of memory in this case.\n\n### Performance Benchmarking\n\n| Input size\
  \ | Experimental strategy | Duration | Cost (spot) | AWS Instance Type |\n|---|---|---|---|\
  \ --- |\n| 30GB | WES | 19min | $0.08 | c4.2xlarge |\n| 70GB | WGS | 50min | $0.22\
  \ | c4.2xlarge |\n| 170GB | WGS | 2h 14min | $0.58 | c4.2xlarge |"
id: uros_sipetic/gatk-4-1-0-0-demo/gatk-collectreadcounts-4-1-0-0/11
inputs:
- doc: If true, adds a PG tag to created SAM/BAM/CRAM files.
  id: add_output_sam_program_record
  inputBinding:
    position: 4
    prefix: --add-output-sam-program-record
    shellQuote: false
  label: Add output SAM program record
  sbg:altPrefix: -add-output-sam-program-record
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'true'
  type:
  - 'null'
  - name: add_output_sam_program_record
    symbols:
    - 'true'
    - 'false'
    type: enum
- doc: Threshold number of ambiguous bases. If null, uses threshold fraction; otherwise,
    overrides threshold fraction. Cannot be used in conjuction with argument(s) maxAmbiguousBaseFraction.
    Valid only if "AmbiguousBaseReadFilter" is specified.
  id: ambig_filter_bases
  inputBinding:
    position: 4
    prefix: --ambig-filter-bases
    shellQuote: false
  label: Ambig filter bases
  sbg:category: Conditional Arguments
  sbg:toolDefaultValue: 'null'
  type: int?
- doc: Threshold fraction of ambiguous bases 05. Cannot be used in conjuction with
    argument(s) maxAmbiguousBases. Valid only if "AmbiguousBaseReadFilter" is specified.
  id: ambig_filter_frac
  inputBinding:
    position: 4
    prefix: --ambig-filter-frac
    shellQuote: false
  label: Ambig filter fraction
  sbg:category: Conditional Arguments
  sbg:toolDefaultValue: '0'
  type: float?
- doc: Platform unit (PU) to filter out This argument must be specified at least once.
    Valid only if "PlatformUnitReadFilter" is specified.
  id: black_listed_lanes
  inputBinding:
    position: 4
    prefix: --black-listed-lanes
    shellQuote: false
  label: Black listed lanes
  sbg:category: Conditional Arguments
  type: string?
- doc: If true, don't cache bam indexes, this will reduce memory requirements but
    may harm performance if many intervals are specified. Caching is automatically
    disabled if there are no intervals specified.
  id: disable_bam_index_caching
  inputBinding:
    position: 4
    prefix: --disable-bam-index-caching
    shellQuote: false
  label: Disable BAM index caching
  sbg:altPrefix: -DBIC
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type:
  - 'null'
  - name: disable_bam_index_caching
    symbols:
    - 'true'
    - 'false'
    type: enum
- doc: Read filters to be disabled before analysis.
  id: disable_read_filter
  inputBinding:
    position: 4
    prefix: --disable-read-filter
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return self.join(' --disable-read-filter\
      \ ');\n    }\n    return '';\n}"
  label: Disable read filter
  sbg:altPrefix: -DF
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'null'
  type:
  - 'null'
  - items:
      name: disable_read_filter
      symbols:
      - MappedReadFilter
      - MappingQualityReadFilter
      - NonZeroReferenceLengthAlignmentReadFilter
      - NotDuplicateReadFilter
      - WellformedReadFilter
      type: enum
    type: array
- doc: If specified, do not check the sequence dictionaries from our inputs for compatibility.
    Use at your own risk!
  id: disable_sequence_dictionary_validation
  inputBinding:
    position: 4
    prefix: --disable-sequence-dictionary-validation
    shellQuote: false
  label: Disable sequence dictionary validation
  sbg:altPrefix: -disable-sequence-dictionary-validation
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type:
  - 'null'
  - name: disable_sequence_dictionary_validation
    symbols:
    - 'true'
    - 'false'
    type: enum
- doc: 'Disable all tool default read filters (WARNING: many tools will not function
    correctly without their default read filters on).'
  id: disable_tool_default_read_filters
  inputBinding:
    position: 4
    prefix: --disable-tool-default-read-filters
    shellQuote: false
  label: Disable tool default read filters
  sbg:altPrefix: -disable-tool-default-read-filters
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type:
  - 'null'
  - name: disable_tool_default_read_filters
    symbols:
    - 'true'
    - 'false'
    type: enum
- doc: Allow a read to be filtered out based on having only 1 soft-clipped block.
    By default, both ends must have a soft-clipped block, setting this flag requires
    only 1 soft-clipped block. Valid only if "OverclippedReadFilter" is specified.
  id: dont_require_soft_clips_both_ends
  inputBinding:
    position: 4
    prefix: --dont-require-soft-clips-both-ends
    shellQuote: false
  label: Dont require soft clips both ends
  sbg:category: Conditional Arguments
  sbg:toolDefaultValue: 'false'
  type:
  - 'null'
  - name: dont_require_soft_clips_both_ends
    symbols:
    - 'true'
    - 'false'
    type: enum
- doc: One or more genomic intervals to exclude from processing.
  id: exclude_intervals
  inputBinding:
    position: 4
    prefix: --exclude-intervals
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        self = [].concat(self);\n        var\
      \ paths = [];\n        for (var i=0; i<self.length; i++) {\n            paths.push(self[i].path);\n\
      \        }\n        return paths.join(' --exclude-intervals ');\n    }\n   \
      \ return '';\n}"
  label: Exclude intervals
  sbg:altPrefix: -XL
  sbg:category: Optional Arguments
  sbg:fileTypes: INTERVALS, INTERVAL_LIST, BED, VCF, LIST
  sbg:toolDefaultValue: 'null'
  type: File[]?
- doc: Output file format.
  id: output_format
  inputBinding:
    position: 4
    prefix: --format
    shellQuote: false
  label: Format
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: HDF5
  type:
  - 'null'
  - name: output_format
    symbols:
    - TSV
    - HDF5
    type: enum
- doc: BAM/SAM/CRAM file containing reads This argument must be specified at least
    once.
  id: in_alignments
  inputBinding:
    position: 4
    prefix: --input
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        self = [].concat(self);\n        var\
      \ paths = [];\n        for (var i=0; i<self.length; i++) {\n            paths.push(self[i].path);\n\
      \        }\n        return paths.join(' --input ');\n    }\n    return '';\n\
      }"
  label: Input reads
  sbg:altPrefix: -I
  sbg:category: Required Arguments
  sbg:fileTypes: BAM, SAM, CRAM
  secondaryFiles:
  - "${\n    if(self.nameext == '.bam'){\n        return self.basename + '.bai';\n\
    \        return null;\n    }\n}"
  type: File[]
- doc: Amount of padding (in bp) to add to each interval you are excluding.
  id: interval_exclusion_padding
  inputBinding:
    position: 4
    prefix: --interval-exclusion-padding
    shellQuote: false
  label: Interval exclusion padding
  sbg:altPrefix: -ixp
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: int?
- doc: Interval merging rule for abutting intervals.
  id: interval_merging_rule
  inputBinding:
    position: 4
    prefix: --interval-merging-rule
    shellQuote: false
  label: Interval merging rule
  sbg:altPrefix: -imr
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: ALL
  type:
  - 'null'
  - name: interval_merging_rule
    symbols:
    - ALL
    - OVERLAPPING_ONLY
    type: enum
- doc: of padding (in bp) to add to each interval you are including.
  id: interval_padding
  inputBinding:
    position: 4
    prefix: --interval-padding
    shellQuote: false
  label: Interval padding
  sbg:altPrefix: -ip
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: int?
- doc: Set merging approach to use for combining interval inputs.
  id: interval_set_rule
  inputBinding:
    position: 4
    prefix: --interval-set-rule
    shellQuote: false
  label: Interval set rule
  sbg:altPrefix: -isr
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: UNION
  type:
  - 'null'
  - name: interval_set_rule
    symbols:
    - UNION
    - INTERSECTION
    type: enum
- doc: One or more genomic intervals over which to operate This argument must be specified
    at least once.
  id: intervals
  inputBinding:
    position: 4
    prefix: --intervals
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        self = [].concat(self);\n        var\
      \ paths = [];\n        for (var i=0; i<self.length; i++) {\n            paths.push(self[i].path);\n\
      \        }\n        return paths.join(' --intervals ');\n    }\n    return '';\n\
      }"
  label: Intervals
  sbg:altPrefix: -L
  sbg:category: Required Arguments
  sbg:fileTypes: INTERVALS, INTERVAL_LIST, BED, VCF, LIST
  type: File[]
- doc: The name of the read group to keep. Valid only if "ReadGroupReadFilter" is
    specified.
  id: keep_read_group
  inputBinding:
    position: 4
    prefix: --keep-read-group
    shellQuote: false
  label: Keep read group
  sbg:category: Conditional Arguments
  type: string?
- doc: Keep only reads on the reverse strand. Valid only if "ReadStrandFilter" is
    specified.
  id: keep_reverse_strand_only
  inputBinding:
    position: 4
    prefix: --keep-reverse-strand-only
    shellQuote: false
  label: Keep reverse strand only
  sbg:category: Conditional Arguments
  type:
  - 'null'
  - name: keep_reverse_strand_only
    symbols:
    - 'true'
    - 'false'
    type: enum
- doc: Name of the library to keep This argument must be specified at least once.
    Valid only if "LibraryReadFilter" is specified.
  id: library
  inputBinding:
    position: 4
    prefix: --library
    shellQuote: false
  label: Library
  sbg:altPrefix: -library
  sbg:category: Conditional Arguments
  type: string?
- doc: Maximum length of fragment (insert size). Valid only if "FragmentLengthReadFilter"
    is specified.
  id: max_fragment_length
  inputBinding:
    position: 4
    prefix: --max-fragment-length
    shellQuote: false
  label: Max fragment length
  sbg:category: Conditional Arguments
  sbg:toolDefaultValue: '1000000'
  type: int?
- doc: Keep only reads with length at most equal to the specified value. Valid only
    if "ReadLengthReadFilter" is specified.
  id: max_read_length
  inputBinding:
    position: 4
    prefix: --max-read-length
    shellQuote: false
  label: Max read length
  sbg:category: Conditional Arguments
  type: int?
- doc: Maximum mapping quality to keep (inclusive). Valid only if "MappingQualityReadFilter"
    is specified.
  id: maximum_mapping_quality
  inputBinding:
    position: 4
    prefix: --maximum-mapping-quality
    shellQuote: false
  label: Maximum mapping quality
  sbg:category: Conditional Arguments
  sbg:toolDefaultValue: 'null'
  type: int?
- doc: Memory which will be allocated for execution.
  id: memory_per_job
  label: Memory per job
  sbg:category: Execution
  sbg:toolDefaultValue: '2048'
  type: int?
- doc: Keep only reads with length at least equal to the specified value. Valid only
    if "ReadLengthReadFilter" is specified.
  id: min_read_length
  inputBinding:
    position: 4
    prefix: --min-read-length
    shellQuote: false
  label: Min read length
  sbg:category: Conditional Arguments
  sbg:toolDefaultValue: '1'
  type: int?
- doc: Minimum mapping quality to keep (inclusive). Valid only if "MappingQualityReadFilter"
    is specified.
  id: minimum_mapping_quality
  inputBinding:
    position: 4
    prefix: --minimum-mapping-quality
    shellQuote: false
  label: Minimum mapping quality
  sbg:category: Conditional Arguments
  sbg:toolDefaultValue: '30'
  type: int?
- doc: Output file for read counts.
  id: output_prefix
  label: Output prefix
  sbg:altPrefix: -O
  sbg:category: Required Arguments
  type: string?
- doc: Platform attribute (PL) to match This argument must be specified at least once.
    Valid only if "PlatformReadFilter" is specified.
  id: platform_filter_name
  inputBinding:
    position: 4
    prefix: --platform-filter-name
    shellQuote: false
  label: Platform filter name
  sbg:category: Conditional Arguments
  type: string?
- doc: Read filters to be applied before analysis.
  id: read_filter
  inputBinding:
    position: 4
    prefix: --read-filter
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return self.join(' --read-filter ');\n\
      \    }\n    return '';\n}"
  label: Read filter
  sbg:altPrefix: -RF
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'null'
  type:
  - 'null'
  - items:
      name: read_filter
      symbols:
      - AlignmentAgreesWithHeaderReadFilter
      - AllowAllReadsReadFilter
      - AmbiguousBaseReadFilter
      - CigarContainsNoNOperator
      - FirstOfPairReadFilter
      - FragmentLengthReadFilter
      - GoodCigarReadFilter
      - HasReadGroupReadFilter
      - LibraryReadFilter
      - MappedReadFilter
      - MappingQualityAvailableReadFilter
      - MappingQualityNotZeroReadFilter
      - MappingQualityReadFilter
      - MatchingBasesAndQualsReadFilter
      - MateDifferentStrandReadFilter
      - MateOnSameContigOrNoMappedMateReadFilter
      - MetricsReadFilter
      - NonChimericOriginalAlignmentReadFilter
      - NonZeroFragmentLengthReadFilter
      - NonZeroReferenceLengthAlignmentReadFilter
      - NotDuplicateReadFilter
      - NotOpticalDuplicateReadFilter
      - NotSecondaryAlignmentReadFilter
      - NotSupplementaryAlignmentReadFilter
      - OverclippedReadFilter
      - PairedReadFilter
      - PassesVendorQualityCheckReadFilter
      - PlatformReadFilter
      - PlatformUnitReadFilter
      - PrimaryLineReadFilter
      - ProperlyPairedReadFilter
      - ReadGroupBlackListReadFilter
      - ReadGroupReadFilter
      - ReadLengthEqualsCigarLengthReadFilter
      - ReadLengthReadFilter
      - ReadNameReadFilter
      - ReadStrandFilter
      - SampleReadFilter
      - SecondOfPairReadFilter
      - SeqIsStoredReadFilter
      - ValidAlignmentEndReadFilter
      - ValidAlignmentStartReadFilter
      - WellformedReadFilter
      type: enum
    type: array
- doc: name of the read group to filter out This argument must be specified at least
    once. Valid only if "ReadGroupBlackListReadFilter" is specified.
  id: read_group_black_list
  inputBinding:
    position: 4
    prefix: --read-group-black-list
    shellQuote: false
  label: Read group black list
  sbg:category: Conditional Arguments
  type: string?
- doc: Keep only reads with this read name. Valid only if "ReadNameReadFilter" is
    specified.
  id: read_name
  inputBinding:
    position: 4
    prefix: --read-name
    shellQuote: false
  label: Read name
  sbg:category: Conditional Arguments
  type: string?
- doc: Validation stringency for all SAM/BAM/CRAM/SRA files read by this program.
    The default stringency value SILENT can improve performance when processing a
    BAM file in which variable-length data (read, qualities, tags) do not otherwise
    need to be decoded.
  id: read_validation_stringency
  inputBinding:
    position: 4
    prefix: --read-validation-stringency
    shellQuote: false
  label: Read validation stringency
  sbg:altPrefix: -VS
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: SILENT
  type:
  - 'null'
  - name: read_validation_stringency
    symbols:
    - STRICT
    - LENIENT
    - SILENT
    type: enum
- doc: Reference sequence.
  id: in_reference
  inputBinding:
    position: 4
    prefix: --reference
    shellQuote: false
  label: Reference
  sbg:altPrefix: -R
  sbg:category: Optional Arguments
  sbg:fileTypes: FASTA, FA
  sbg:toolDefaultValue: 'null'
  secondaryFiles:
  - .fai
  - ^.dict
  type: File?
- doc: The name of the sample(s) to keep, filtering out all others This argument must
    be specified at least once. Valid only if "SampleReadFilter" is specified.
  id: sample
  inputBinding:
    position: 4
    prefix: --sample
    shellQuote: false
  label: Sample
  sbg:altPrefix: -sample
  sbg:category: Conditional Arguments
  type: string?
- doc: Output traversal statistics every time this many seconds elapse 0.
  id: seconds_between_progress_updates
  inputBinding:
    position: 4
    prefix: --seconds-between-progress-updates
    shellQuote: false
  label: Seconds between progress updates
  sbg:altPrefix: -seconds-between-progress-updates
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '10'
  type: float?
- doc: Use the given sequence dictionary as the master/canonical sequence dictionary.
    Must be a .dict file.
  id: sequence_dictionary
  inputBinding:
    position: 4
    prefix: --sequence-dictionary
    shellQuote: false
  label: Sequence dictionary
  sbg:altPrefix: -sequence-dictionary
  sbg:category: Optional Arguments
  sbg:fileTypes: DICT
  sbg:toolDefaultValue: 'null'
  type: File?
- doc: Memory overhead which will be allocated for one job.
  id: memory_overhead_per_job
  label: Memory overhead per job
  sbg:category: Execution
  sbg:toolDefaultValue: '0'
  type: int?
- doc: Number of CPUs which will be allocated for the job.
  id: cpu_per_job
  label: CPU per job
  sbg:category: Execution
  type: int?
label: GATK CollectReadCounts
outputs:
- doc: Read counts file containing counts per bin.
  id: read_counts
  label: Read counts
  outputBinding:
    glob: '*.hdf5'
    outputEval: '$( inputs.in_alignments ? inheritMetadata(self, inputs.in_alignments)
      : self)'
  sbg:fileTypes: HDF5, TSV
  type: File?
- doc: Entity id (BAM file nameroot). This output is GATK Best Practice requirement.
  id: entity_id
  label: Entity ID
  outputBinding:
    outputEval: "${\n    if (inputs.in_alignments) {\n        var entity_ids = [];\n\
      \        var in_alignments = [].concat(inputs.in_alignments);\n        for (var\
      \ i=0; i<in_alignments.length; i++) {\n            entity_ids.push(in_alignments[i].path.split('/').pop().split('.').slice(0,-1).join('.'));\n\
      \        }\n        if (entity_ids.length == 1) {\n            return entity_ids[0];\n\
      \        }\n        return entity_ids;\n    }\n    return '';\n}"
  type: string?
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
- Utilities
- Coverage Analysis
sbg:content_hash: a6119dad2f450071878896081ba5591830b250a1123cf53b58a69cfdc8286b9c4
sbg:contributors:
- stefan_stojanovic
- milena_stanojevic
- uros_sipetic
sbg:createdBy: uros_sipetic
sbg:createdOn: 1552931572
sbg:id: uros_sipetic/gatk-4-1-0-0-demo/gatk-collectreadcounts-4-1-0-0/11
sbg:image_url: null
sbg:latestRevision: 11
sbg:license: Open source BSD (3-clause) license
sbg:modifiedBy: milena_stanojevic
sbg:modifiedOn: 1575644227
sbg:project: uros_sipetic/gatk-4-1-0-0-demo
sbg:projectName: GATK 4.1.0.0 - Demo
sbg:publisher: sbg
sbg:revision: 11
sbg:revisionNotes: read_counts output glob fix - only hdf5
sbg:revisionsInfo:
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1552931572
  sbg:revision: 0
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/5
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553105621
  sbg:revision: 1
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/18
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553864205
  sbg:revision: 2
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/32
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1554032599
  sbg:revision: 3
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/35
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559581527
  sbg:revision: 4
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/38
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559731779
  sbg:revision: 5
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/40
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1560264039
  sbg:revision: 6
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectreadcounts-4-1-0-0/41
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575479139
  sbg:revision: 7
  sbg:revisionNotes: ''
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575550516
  sbg:revision: 8
  sbg:revisionNotes: Secondary files argument changed for in alignments
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575643769
  sbg:revision: 9
  sbg:revisionNotes: output read counts changed glob
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575644014
  sbg:revision: 10
  sbg:revisionNotes: glob for read counts output changed again, removed \
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1575644227
  sbg:revision: 11
  sbg:revisionNotes: read_counts output glob fix - only hdf5
sbg:sbgMaintained: false
sbg:toolAuthor: Broad Institute
sbg:toolkit: GATK
sbg:toolkitVersion: 4.1.0.0
sbg:validationErrors: []
