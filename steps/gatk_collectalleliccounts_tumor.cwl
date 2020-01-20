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
  valueFrom: CollectAllelicCounts
- position: 4
  prefix: --output
  shellQuote: false
  valueFrom: "${\n    if (inputs.in_alignments) {\n        var in_alignments_array\
    \ = [].concat(inputs.in_alignments);\n        var prefix = inputs.output_prefix\
    \ ? inputs.output_prefix : in_alignments_array[0].path.split('/').pop().split('.').slice(0,-1).join('.');\n\
    \        var ext = 'allelicCounts.tsv';\n        return [prefix, ext].join('.');\n\
    \    }\n    return '';\n}"
baseCommand: []
class: CommandLineTool
cwlVersion: v1.0
doc: "GATK CollectAllelicCounts collects reference and alternate allele counts at\
  \ specified sites. \n\n### Common Use Cases\n\nThe alt count is defined as the total\
  \ count minus the ref count, and the alt nucleotide is defined as the non-ref base\
  \ with the highest count, with ties broken by the order of the bases in **AllelicCountCollector**#BASES.\
  \ Only reads that pass the specified read filters and bases that exceed the specified\
  \ minimum-base-quality will be counted.\nThis app produces allelic-counts file.\
  \ This is a tab-separated values (TSV) file with a SAM-style header containing a\
  \ read group sample name, a sequence dictionary, a row specifying the column headers\
  \ and the corresponding entry rows. The sites over which allelic counts are collected\
  \ should represent common sites in population where biallelic configurations are\
  \ expected. This can be either dbsnp VCF file or Mills gold standard file (with\
  \ SNPs only). For WGS analysis the entire dbsnp should be provided on the input,\
  \ whereas for WES analysis we suggest subsetting dbsnp to regions where coverage\
  \ is expected. \nSome of the input parameters are listed below:\n* **Input reads**\
  \ (`--input`) - SAM format read data in BAM/SAM/CRAM format. In case of BAM and\
  \ CRAM files the secondary BAI and CRAI index files are required.\n* **Reference**\
  \ (`--reference`) genome in FASTA format along with secondary FAI and DICT files\n\
  * **Common sites** (`--intervals`) - Sites at which allelic counts will be collected\
  \ (ex. dbsnp)\n* **Output prefix** (`--output`) - Prefix of the output allelic counts\
  \ file.\n\n### Changes Introduced by Seven Bridges\n* If **Output prefix** parameter\
  \ is not specified the prefix of the output file will be derived from the base name\
  \ of the first **Input reads** file provided.\n\n### Common Issues and Important\
  \ Notes\n* Input parameter **Interval merging rule** must be set to `OVERLAPPING_ONLY`,\
  \ otherwise the tool will produce an error.\n* If entire dbsnp or Mills SNPs VCF\
  \ file is used for allelic counts collection more working memory should be provided\
  \ through **Memory per job** input. We advise providing at least 100000 Mb (100GB)\
  \ of working memory.\n\n### Performance Benchmarking\n\n| Input size | Experimental\
  \ strategy | Number of sites | Memory | Duration | Cost (spot) | AWS Instance Type\
  \ |\n| --- | ---| --- | --- | --- | --- | --- | \n| 30GB | WES | ~ 5 * 10^6 | 13000\
  \ | 49m | $0.14 | r4.large |\n| 70GB | WGS | ~ 5 * 10^7 | 100000 | 2h 20m | $1.12\
  \ | r4.4xlarge | \n| 170GB | WGS | ~ 5 * 10^7 | 100000 | 6h 32m | $3.12 | r4.4xlarge\
  \ |"
id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectalleliccounts-4-1-0-0/25
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
    valueFrom: "${\n    if (self) {\n        self = [].concat(self);\n        return\
      \ self.join(' --disable-read-filter ');\n    }\n    return '';\n}"
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
- doc: or more genomic intervals to exclude from processing.
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
  sbg:fileTypes: INTERVALS, INTERVAL_LIST, BED
  sbg:toolDefaultValue: 'null'
  type: File[]?
- doc: Minimum number of aligned bases. Valid only if "OverclippedReadFilter" is specified.
  id: filter_too_short
  inputBinding:
    position: 4
    prefix: --filter-too-short
    shellQuote: false
  label: Filter too short
  sbg:category: Conditional Arguments
  sbg:toolDefaultValue: '30'
  type: int?
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
  id: common_sites
  inputBinding:
    position: 4
    prefix: --intervals
    shellQuote: false
  label: Common sites
  sbg:altPrefix: -L
  sbg:category: Required Arguments
  sbg:fileTypes: VCF, BED, INTERVALS, INTERVAL_LIST
  type: File
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
- doc: Maximum number of reads to retain per sample per locus. Reads above this threshold
    will be downsampled. Set to 0 to disable.
  id: maxdepthpersample
  inputBinding:
    position: 4
    prefix: --maxDepthPerSample
    shellQuote: false
  label: Max depth per sample
  sbg:altPrefix: -maxDepthPerSample
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
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
- doc: base quality. Base calls with lower quality will be filtered out of pileups.
  id: minimum_base_quality
  inputBinding:
    position: 4
    prefix: --minimum-base-quality
    shellQuote: false
  label: Minimum base quality
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '20'
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
- doc: Output file for allelic counts.
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
    valueFrom: "${\n    if (self) {\n        self = [].concat(self);\n        return\
      \ self.join(' --read-filter ');\n    }\n    return '';\n}"
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
- doc: Reference sequence file.
  id: in_reference
  inputBinding:
    position: 4
    prefix: --reference
    shellQuote: false
  label: Reference
  sbg:altPrefix: -R
  sbg:category: Required Arguments
  sbg:fileTypes: FASTA, FA
  secondaryFiles:
  - .fai
  - ^.dict
  type: File
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
- doc: Number of CPUs which will be allocated for the job.
  id: cpu_per_job
  label: CPU per job
  sbg:category: Execution
  sbg:toolDefaultValue: '1'
  type: int?
label: GATK CollectAllelicCounts
outputs:
- doc: TSV file containing ref and alt counts at specified positions (common sites).
  id: allelic_counts
  label: Allelic counts
  outputBinding:
    glob: '*.tsv'
    outputEval: '$( inputs.in_alignments ? inheritMetadata(self, inputs.in_alignments)
      : self)'
  sbg:fileTypes: TSV
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
- Utilities
- Coverage Analysis
sbg:content_hash: a3434d3a5120456a14d9cbee1fd74164f340353257e831480c7eefd0eb6936af0
sbg:contributors:
- uros_sipetic
- milena_stanojevic
- stefan_stojanovic
sbg:createdBy: stefan_stojanovic
sbg:createdOn: 1551310936
sbg:id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-collectalleliccounts-4-1-0-0/25
sbg:image_url: null
sbg:latestRevision: 25
sbg:license: Open source BSD (3-clause) license
sbg:modifiedBy: milena_stanojevic
sbg:modifiedOn: 1577369382
sbg:project: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev
sbg:projectName: GATK 4.1.0.0 Toolkit DEV
sbg:publisher: sbg
sbg:revision: 25
sbg:revisionNotes: Secondary files expression changed for in_alignments input
sbg:revisionsInfo:
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551310936
  sbg:revision: 0
  sbg:revisionNotes: null
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551310990
  sbg:revision: 1
  sbg:revisionNotes: init
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551311020
  sbg:revision: 2
  sbg:revisionNotes: set default memory requirement to 2048m
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551440675
  sbg:revision: 3
  sbg:revisionNotes: set instance hint to c4.8xlarge for testing purposes
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551470621
  sbg:revision: 4
  sbg:revisionNotes: instance type r3.4xlarge
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551566621
  sbg:revision: 5
  sbg:revisionNotes: revert to revision 2
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553094116
  sbg:revision: 6
  sbg:revisionNotes: change input id to in_alignments
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553094574
  sbg:revision: 7
  sbg:revisionNotes: add description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553094665
  sbg:revision: 8
  sbg:revisionNotes: change 'output' input id to output_prefix
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553094748
  sbg:revision: 9
  sbg:revisionNotes: edit description, add link to wdl
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553094957
  sbg:revision: 10
  sbg:revisionNotes: add file types for file inputs
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553097218
  sbg:revision: 11
  sbg:revisionNotes: add benchmarking table
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553097816
  sbg:revision: 12
  sbg:revisionNotes: add categories utilities and coverage analysis
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553097911
  sbg:revision: 13
  sbg:revisionNotes: fix expression for exclude_intervals input
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553168191
  sbg:revision: 14
  sbg:revisionNotes: Update description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553603705
  sbg:revision: 15
  sbg:revisionNotes: add benchmarking info; change 'reference' id to 'in_reference'
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553603987
  sbg:revision: 16
  sbg:revisionNotes: convert booleans to enums; fix expressions for enums
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553604613
  sbg:revision: 17
  sbg:revisionNotes: add descriptions for inputs memory per job, memory overhead and
    cpu per job
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553604984
  sbg:revision: 18
  sbg:revisionNotes: add output file description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553605199
  sbg:revision: 19
  sbg:revisionNotes: add inputs and outputs sections
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553692887
  sbg:revision: 20
  sbg:revisionNotes: fix description formating to match other tools
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553813856
  sbg:revision: 21
  sbg:revisionNotes: change in_alignments file to array of files, which should be
    default; fix output naming expression; fix description to reflect changes
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553816486
  sbg:revision: 22
  sbg:revisionNotes: fix output naming expression, concat to array before accessing
    element
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553817191
  sbg:revision: 23
  sbg:revisionNotes: add secondary file requirements for in_alignments
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559302162
  sbg:revision: 24
  sbg:revisionNotes: fix javascript expressions, add vars and semicolons.
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1577369382
  sbg:revision: 25
  sbg:revisionNotes: Secondary files expression changed for in_alignments input
sbg:sbgMaintained: false
sbg:toolAuthor: Broad Institute
sbg:toolkit: GATK
sbg:toolkitVersion: 4.1.0.0
sbg:validationErrors: []
