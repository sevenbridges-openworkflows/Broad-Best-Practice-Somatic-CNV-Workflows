$namespaces:
  sbg: https://sevenbridges.com
arguments:
- position: 0
  prefix: ''
  shellQuote: false
  valueFrom: '$( inputs.do_explicit_gc_correction ? ''/opt/gatk'' : ''echo /opt/gatk'')'
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
  valueFrom: AnnotateIntervals
- position: 4
  prefix: --output
  shellQuote: false
  valueFrom: "${\n    var intervals = [].concat(inputs.intervals);\n    var prefix\
    \ = inputs.output_prefix ? inputs.output_prefix : intervals[0].path.split('/').pop().split('.').slice(0,-1).join('.');\n\
    \    return prefix + '.annotated.tsv';\n}"
baseCommand: []
class: CommandLineTool
cwlVersion: v1.0
doc: "GATK AnnotateIntervals annotates intervals with GC content, and optionally,\
  \ mappability and segmental-duplication content. \n\n### Common Use Cases\nThe output\
  \ of this tool may optionally be used as input to **CreateReadCountPanelOfNormals**,\
  \ **DenoiseReadCounts**, and **GermlineCNVCaller**. Some of the common input parameters\
  \ are listed below:\n\n* **Reference** (`--reference`) - Reference genome in FASTA\
  \ format. Secondary FAI and DICT files are required.\n* **Intervals** (`--intervals`)\
  \ to be annotated. Supported formats are described [here](https://software.broadinstitute.org/gatk/documentation/article?id=1319).\
  \ The argument **Interval merging rule** must be set to `OVERLAPPING_ONLY` and all\
  \ other common arguments for interval padding or merging must be set to their defaults.\n\
  * **Mappability track file** (`--mappability-track`) - This is a BED file in BED\
  \ or BED.GZ format that identifies uniquely mappable regions of the genome. The\
  \ track should correspond to the appropriate read length and overlapping intervals\
  \ must be merged. See [https://bismap.hoffmanlab.org/](https://bismap.hoffmanlab.org/).\
  \ If scores are provided, intervals will be annotated with the length-weighted average;\
  \ note that NaN scores will be taken as unity. Otherwise, scores for covered and\
  \ uncovered intervals will be taken as unity and zero, respectively.\n* **Segmental\
  \ duplication track** (`--segmental-duplication-track`) - This is a BED file in\
  \ BED or BED.GZ format that identifies segmental-duplication regions of the genome.\
  \ Overlapping intervals must be merged. If scores are provided, intervals will be\
  \ annotated with the length-weighted average; note that NaN scores will be taken\
  \ as unity. Otherwise, scores for covered and uncovered intervals will be taken\
  \ as unity and zero, respectively.\n\n### Changes Introduced by Seven Bridges\n\
  * Additional input **Do explicit GC correction** is added in accordance with [CNV\
  \ best practice WDL](https://github.com/gatk-workflows/gatk4-somatic-cnvs/blob/master/cnv_somatic_panel_workflow.wdl)\
  \ specification. This input is required, and must be set to `true` in order to execute\
  \ the command line.\n* Some of the input arguments that are not applicable to this\
  \ tool have been removed (`--create-output-bam-md5`, `--read-index`, etc.)\n* If\
  \ **Output prefix** parameter is not specified, prefix for the output file will\
  \ be derived from the base name of the **Intervals** file. If multiple **Intervals**\
  \ files have been provided on the input, the prefix will be derived from the first\
  \ file in the list.\n\n### Common Issues and Important Notes\n* Input parameter\
  \ **Interval merging rule** must be set to `OVERLAPPING_ONLY`, otherwise the tool\
  \ will produce an error.\n\n### Performance Benchmarking\n\n| Input Size | Experimental\
  \ Strategy | Duration | Cost (spot) | AWS Instance Type |\n| --- | --- | --- | ---\
  \ | --- |\n| 5.0MB | WES | 3min | $0.02 | c4.2xlarge |\n| 73.8MB | WGS | 3min |\
  \ $0.02 | c4.2xlarge |"
id: uros_sipetic/gatk-4-1-0-0-demo/gatk-annotateintervals-4-1-0-0/2
inputs:
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
  sbg:fileTypes: INTERVALS, INTERVAL_LIST, BED, VCF, LIST
  sbg:toolDefaultValue: 'null'
  type: File[]?
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
    valueFrom: "${\n    if (self) {\n        self = [].concat(self)\n        var paths\
      \ = [];\n        for (var i=0; i<self.length; i++) {\n            paths.push(self[i].path);\n\
      \        }\n        return paths.join(' --intervals ');\n    }\n    return '';\n\
      }"
  label: Intervals
  sbg:altPrefix: -L
  sbg:category: Required Arguments
  sbg:fileTypes: INTERVALS, INTERVAL_LIST, BED, VCF, LIST
  type: File[]
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
- doc: Output file for annotated intervals.
  id: output_prefix
  label: Output prefix
  sbg:altPrefix: -O
  sbg:category: Required Arguments
  type: string?
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
- doc: Path to segmental-duplication track in .bed or .bed.gz format. Overlapping
    intervals must be merged.
  id: segmental_duplication_track
  inputBinding:
    position: 4
    prefix: --segmental-duplication-track
    shellQuote: false
  label: Segmental duplication track
  sbg:category: Optional Arguments
  sbg:fileTypes: BED, BED.GZ
  sbg:toolDefaultValue: 'null'
  secondaryFiles:
  - .idx
  type: File?
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
- doc: Choose whether to execute this app. This argument is GATK CNV Best Practice
    requirement.
  id: do_explicit_gc_correction
  label: Do explicit GC correction
  sbg:category: Execution
  type: boolean
- doc: 'Path to Umap single-read mappability track in .bed or .bed.gz format (see
    https://bismap.hoffmanlab.org/). Overlapping intervals must be merged. Default
    value:  null.'
  id: mappability_track
  inputBinding:
    position: 4
    prefix: --mappability-track
    shellQuote: false
  label: Mappability track file
  sbg:category: Optional Arguments
  sbg:fileTypes: BED, BED.GZ
  secondaryFiles:
  - .idx
  type: File?
- doc: 'Number of bases to cache when querying feature tracks.  Default value: 1000000.'
  id: feature_query_lookahead
  inputBinding:
    position: 4
    prefix: --feature-query-lookahead
    shellQuote: false
  label: Feature query lookahead
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '1000000'
  type: int?
label: GATK AnnotateIntervals
outputs:
- doc: Intervals annotated with GC content, mappability and segmental-duplication.
  id: annotated_intervals
  label: Annotated intervals
  outputBinding:
    glob: '*.annotated.tsv'
    outputEval: $(inheritMetadata(self, inputs.intervals))
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
  - "\nvar setMetadata = function(file, metadata) {\n    if (!('metadata' in file))\n\
    \        file['metadata'] = metadata;\n    else {\n        for (var key in metadata)\
    \ {\n            file['metadata'][key] = metadata[key];\n        }\n    }\n  \
    \  return file\n};\n\nvar inheritMetadata = function(o1, o2) {\n    var commonMetadata\
    \ = {};\n    if (!Array.isArray(o2)) {\n        o2 = [o2]\n    }\n    for (var\
    \ i = 0; i < o2.length; i++) {\n        var example = o2[i]['metadata'];\n   \
    \     for (var key in example) {\n            if (i == 0)\n                commonMetadata[key]\
    \ = example[key];\n            else {\n                if (!(commonMetadata[key]\
    \ == example[key])) {\n                    delete commonMetadata[key]\n      \
    \          }\n            }\n        }\n    }\n    if (!Array.isArray(o1)) {\n\
    \        o1 = setMetadata(o1, commonMetadata)\n    } else {\n        for (var\
    \ i = 0; i < o1.length; i++) {\n            o1[i] = setMetadata(o1[i], commonMetadata)\n\
    \        }\n    }\n    return o1;\n};"
sbg:appVersion:
- v1.0
sbg:categories:
- Genomics
- Copy Number Variant Calling
sbg:content_hash: a1ea13153de4024a7a76a90a1eab01a4a4c585aee8fdc064a12c47d24d3cedc17
sbg:contributors:
- uros_sipetic
- stefan_stojanovic
sbg:copyOf: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-annotateintervals-4-1-0-0/22
sbg:createdBy: uros_sipetic
sbg:createdOn: 1553098388
sbg:id: uros_sipetic/gatk-4-1-0-0-demo/gatk-annotateintervals-4-1-0-0/2
sbg:image_url: null
sbg:latestRevision: 2
sbg:license: Open source BSD (3-clause) license
sbg:modifiedBy: stefan_stojanovic
sbg:modifiedOn: 1559579734
sbg:project: uros_sipetic/gatk-4-1-0-0-demo
sbg:projectName: GATK 4.1.0.0 - Demo
sbg:publisher: sbg
sbg:revision: 2
sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-annotateintervals-4-1-0-0/22
sbg:revisionsInfo:
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553098388
  sbg:revision: 0
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-annotateintervals-4-1-0-0/5
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553864180
  sbg:revision: 1
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-annotateintervals-4-1-0-0/21
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559579734
  sbg:revision: 2
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-annotateintervals-4-1-0-0/22
sbg:sbgMaintained: false
sbg:toolAuthor: Broad Institute
sbg:toolkit: GATK
sbg:toolkitVersion: 4.1.0.0
sbg:validationErrors: []
