$namespaces:
  sbg: https://sevenbridges.com
arguments:
- position: 0
  prefix: ''
  shellQuote: false
  valueFrom: /opt/gatk
- position: 1
  shellQuote: false
  valueFrom: --java-options
- position: 2
  shellQuote: false
  valueFrom: "${\n    if (inputs.memory_per_job) {\n        return '\\\"-Xmx'.concat(inputs.memory_per_job,\
    \ 'M') + '\\\"'\n    }\n    return '\\\"-Xmx2048M\\\"'\n}"
- position: 3
  shellQuote: false
  valueFrom: PreprocessIntervals
- position: 4
  prefix: --output
  shellQuote: false
  valueFrom: "${\n    var intervals_prefix;\n    if (inputs.intervals) {\n       \
    \ var intervals = [].concat(inputs.intervals);\n        intervals_prefix = intervals[0].path.split('/').pop().split('.').slice(0,-1).join('.');\n\
    \    } else {\n        intervals_prefix = inputs.in_reference.nameroot + \".wgs_intervals\"\
    ;\n    }\n    var prefix = inputs.output_prefix ? inputs.output_prefix : intervals_prefix;\n\
    \    return prefix + '.preprocessed.intervals';\n}"
baseCommand: []
class: CommandLineTool
cwlVersion: v1.0
doc: 'GATK PreprocessIntervals prepares bins for coverage collection by merging overlapping
  input intervals. Resulting intervals are padded and split into bins.



  ### Common Use Cases

  This app may be used to prepare intervals for coverage collection, prepare intervals
  for variant filtration etc. Some of the common input parameters are listed below:

  * **Reference** (`--reference`) - Reference genome in FASTA format. Secondary FAI
  and DICT files are required.

  * **Intervals** (`--intervals`) to be preprocessed, must be compatible with GATK
  `-L` argument (more info [https://software.broadinstitute.org/gatk/documentation/article?id=1319](https://software.broadinstitute.org/gatk/documentation/article?id=1319)).
  The argument **Interval merging rule** must be set to `OVERLAPPING_ONLY` and all
  other common arguments for interval padding or merging must be set to their defaults.
  If no intervals are specified, then each contig will be assumed to be a single interval
  and binned accordingly; this produces bins appropriate for whole genome sequencing
  analyses.

  * **Padding** (`--padding`) - Use padding to specify the size of each of the regions
  added to both ends of the intervals that result after overlapping intervals have
  been merged. Do not use the common **Interval padding** argument. Intervals that
  would overlap after padding by the specified amount are instead only padded until
  they are adjacent.

  * **Bin length** (`--bin-length`) - If this length is not commensurate with the
  length of a padded interval, then the last bin will be of different length than
  the others in that interval. If zero is specified, then no binning will be performed;
  this is generally appropriate for targeted analyses.


  ### Changes Introduced by Seven Bridges

  * Some of the input arguments that are not applicable to this tool have been removed
  (`--create-output-bam-md5`, `--read-index`, etc.)

  * If **Output prefix** parameter is not specified, prefix for the output file will
  be derived from the base name of the **Intervals** file. If multiple **Intervals**
  files have been provided on the input, the prefix will be derived from the first
  file in the list.


  ### Common Issues and Important Notes

  * Input parameter **Interval merging rule** must be set to `OVERLAPPING_ONLY`, otherwise
  the tool will produce an error.


  ### Performance Benchmarking


  | Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type
  |

  | --- | --- | --- | --- | --- |

  | 10MB | WES | 4min | $0.02 | c4.2xlarge |

  | 0.5MB | WGS | 4min | $0.02 | c4.2xlarge |'
id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-preprocessintervals-4-1-0-0/33
inputs:
- doc: Length (in bp) of the bins. If zero, no binning will be performed.
  id: bin_length
  inputBinding:
    position: 4
    prefix: --bin-length
    shellQuote: false
  label: Bin length
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '1000'
  type: int?
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
- doc: Ammount of padding (in bp) to add to each interval you are including.
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
- doc: One or more genomic intervals over which to operate.
  id: intervals
  inputBinding:
    itemSeparator: 'null'
    position: 4
    prefix: --intervals
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        self = [].concat(self);\n        var\
      \ paths = [];\n        for (var i=0; i<self.length; i++) {\n            paths.push(self[i].path);\n\
      \        }\n        return paths.join(' --intervals ');\n    }\n    return '';\n\
      }"
  label: Intervals
  sbg:altPrefix: -L
  sbg:category: Optional Arguments
  sbg:fileTypes: INTERVALS, INTERVAL_LIST, BED, VCF, LIST
  sbg:toolDefaultValue: 'null'
  type: File[]?
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
- doc: Output Picard interval-list file containing the preprocessed intervals.
  id: output_prefix
  label: Output prefix
  sbg:altPrefix: -O
  sbg:category: Required Arguments
  type: string?
- doc: Length (in bp) of the padding regions on each side of the intervals.
  id: padding
  inputBinding:
    position: 4
    prefix: --padding
    shellQuote: false
  label: Padding
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '250'
  type: int?
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
label: GATK PreprocessIntervals
outputs:
- doc: Intervals file with padded and binned intervals.
  id: out_intervals
  label: Preprocessed intervals
  outputBinding:
    glob: '*preprocessed.intervals'
    outputEval: "${\n    var out;\n    if (inputs.intervals) {\n        out = inheritMetadata(self,\
      \ inputs.intervals);\n        for (var i=0; i < out.length; i++) {\n       \
      \     out[i].metadata['bin_length'] = inputs.bin_length ? inputs.bin_length\
      \ : 1000;\n            out[i].metadata['padding'] = inputs.padding ? inputs.padding\
      \ : 250;\n            out[i].metadata['interval_merging_rule'] = inputs.interval_merging_rule\
      \ ? inputs.interval_merging_rule : 'ALL';\n        }\n        return out;\n\
      \    }\n    out = inheritMetadata(self, inputs.in_reference);\n    for (var\
      \ i=0; i < out.length; i++) {\n        out[i].metadata['bin_length'] = inputs.bin_length\
      \ ? inputs.bin_length : 1000;\n        out[i].metadata['padding'] = inputs.padding\
      \ ? inputs.padding : 250;\n        out[i].metadata['interval_merging_rule']\
      \ = inputs.interval_merging_rule ? inputs.interval_merging_rule : 'ALL';\n \
      \   }\n    return out;\n}"
  sbg:fileTypes: INTERVALS
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
- BED Processing
sbg:content_hash: a619783ec492e6c1c671ab2136a3998689f211a572f620600c3d697941fc0ed54
sbg:contributors:
- uros_sipetic
- stefan_stojanovic
sbg:createdBy: stefan_stojanovic
sbg:createdOn: 1551193525
sbg:id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-preprocessintervals-4-1-0-0/33
sbg:image_url: null
sbg:latestRevision: 33
sbg:license: Open source BSD (3-clause) license
sbg:modifiedBy: stefan_stojanovic
sbg:modifiedOn: 1559304648
sbg:project: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev
sbg:projectName: GATK 4.1.0.0 Toolkit DEV
sbg:publisher: sbg
sbg:revision: 33
sbg:revisionNotes: update expression for output naming in case no intervals files
  had been specified
sbg:revisionsInfo:
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551193525
  sbg:revision: 0
  sbg:revisionNotes: null
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551193563
  sbg:revision: 1
  sbg:revisionNotes: init
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551194142
  sbg:revision: 2
  sbg:revisionNotes: edit description, test changes
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551194522
  sbg:revision: 3
  sbg:revisionNotes: edit description, no real change, for testing changes in wf
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551202495
  sbg:revision: 4
  sbg:revisionNotes: set --intervals to single file instead of array of files, per
    best practice wdl; add argument for default --output naming
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551202955
  sbg:revision: 5
  sbg:revisionNotes: fix glob expression
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551203323
  sbg:revision: 6
  sbg:revisionNotes: remove cwl default value for output argument
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552650660
  sbg:revision: 7
  sbg:revisionNotes: set --intervals to accept array of files
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552655924
  sbg:revision: 8
  sbg:revisionNotes: add "common issues" and "changes introduced by sbg" to description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552658563
  sbg:revision: 9
  sbg:revisionNotes: for --intervals input files, cast self to array before iterating
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1552668611
  sbg:revision: 10
  sbg:revisionNotes: edit expression for --intervals, keep prefix
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553098331
  sbg:revision: 11
  sbg:revisionNotes: fix description according to wrapping spec
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553098400
  sbg:revision: 12
  sbg:revisionNotes: fix expression for exclude_intervals
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553098504
  sbg:revision: 13
  sbg:revisionNotes: add file types for input files
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553102038
  sbg:revision: 14
  sbg:revisionNotes: Update categories
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553102166
  sbg:revision: 15
  sbg:revisionNotes: Update categories
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553119409
  sbg:revision: 16
  sbg:revisionNotes: change 'output' input id to 'output_prefix'; change output prefix
    expression; change 'reference' to 'in_reference'; add out_intervals description
    and file format
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553119476
  sbg:revision: 17
  sbg:revisionNotes: add descriptions and default values for memory per job, memory
    overhead and cpu per job
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553119552
  sbg:revision: 18
  sbg:revisionNotes: add output naming description to changes introduced by sbg section
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553119686
  sbg:revision: 19
  sbg:revisionNotes: change glob to *preprocessed.intervals
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553126262
  sbg:revision: 20
  sbg:revisionNotes: fix output prefix expression to allow for single file interval
    input
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553169291
  sbg:revision: 21
  sbg:revisionNotes: uppercase-ed extensions in description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553170107
  sbg:revision: 22
  sbg:revisionNotes: add more file types for intervals and interval_exclude inputs;
    add link to gatk site for supported intervals formats
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553710453
  sbg:revision: 23
  sbg:revisionNotes: fix description; convert bools to enums
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553711319
  sbg:revision: 24
  sbg:revisionNotes: add benchmarking data
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1554067992
  sbg:revision: 25
  sbg:revisionNotes: fix output naming expression to allow for no intervals file (wgs)
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1554068429
  sbg:revision: 26
  sbg:revisionNotes: fix metadata inheritance expression to allow for no intervals
    file
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1554068893
  sbg:revision: 27
  sbg:revisionNotes: remove metadata inheritance
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1554068997
  sbg:revision: 28
  sbg:revisionNotes: fix metadata inheritance expression
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1555341415
  sbg:revision: 29
  sbg:revisionNotes: change docker image to images.sbgenomics.com/stefan_stojanovic/gatk-4-1-0-0:0
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1555341956
  sbg:revision: 30
  sbg:revisionNotes: change back docker image to images.sbgenomics.com/stefan_stojanovic/gatk:4.1.0.0
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559300876
  sbg:revision: 31
  sbg:revisionNotes: fix javascript expressions, add vars and semicolons, to keep
    compatible with cwltool
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559303485
  sbg:revision: 32
  sbg:revisionNotes: inherit metadata from reference file if inputs not provided,
    add bin_length, padding and interval_merging_rule to metadata
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559304648
  sbg:revision: 33
  sbg:revisionNotes: update expression for output naming in case no intervals files
    had been specified
sbg:sbgMaintained: false
sbg:toolAuthor: Broad Institute
sbg:toolkit: GATK
sbg:toolkitVersion: 4.1.0.0
sbg:validationErrors: []
