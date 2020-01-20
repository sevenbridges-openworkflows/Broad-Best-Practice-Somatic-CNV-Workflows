$namespaces:
  sbg: https://sevenbridges.com
arguments:
- position: 0
  prefix: ''
  shellQuote: false
  valueFrom: '$( inputs.copy_ratio_segments ? ''/opt/gatk'' : ''echo /opt/gatk'')'
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
  valueFrom: CallCopyRatioSegments
- position: 4
  prefix: --output
  shellQuote: false
  valueFrom: "${\n    if (inputs.copy_ratio_segments) {\n        var nameroot = inputs.output_prefix\
    \ ? inputs.output_prefix : inputs.copy_ratio_segments.nameroot;\n        var nameext\
    \ = '.called.seg';\n        return nameroot + nameext;\n    }\n    return '';\n\
    }"
baseCommand: []
class: CommandLineTool
cwlVersion: v1.0
doc: 'GATK CallCopyRatioSegments calls copy-ratio segments as amplified, deleted,
  or copy-number neutral.



  ### Common Use Cases

  This is a relatively naive caller that takes the modeled-segments output of **ModelSegments**
  and performs a simple statistical test on the segmented log2 copy ratios to call
  amplifications and deletions, given a specified range for determining copy-number
  neutral segments. This caller is based on the calling functionality of ReCapSeg.
  If provided ModelSegments results that incorporate allele-fraction data, i.e. data
  with presumably improved segmentation, the statistical test performed by CallCopyRatioSegments
  ignores the modeled minor-allele fractions when making calls.


  *Source: [https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_CallCopyRatioSegments.php](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_CallCopyRatioSegments.php)*


  Some of the input parameters are listed below:

  * **Copy ratio segments** (`--input`) - Copy ratio segments file, output of **ModelSegments**.
  This is a tab-separated values (TSV) file with a SAM-style header containing a read
  group sample name, a sequence dictionary, a row specifying the column headers contained
  in CopyRatioSegmentCollection.CopyRatioSegmentTableColumn, and the corresponding
  entry rows.

  * **Output prefix** (`--output`) - Prefix of the output files.


  ### Changes Introduced by Seven Bridges

  * If **Output prefix** input parameter is not set, the base name of the **Copy ratio
  segments** input file will be used as output prefix.


  ### Common Issues and Important Notes

  * *No issues have been identified thus far.*


  ### Performance Benchmarking

  | Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type
  |

  | --- | --- | --- | --- | --- |

  | 30KB | WES | 2min | $0.01 | c4.2xlarge |

  | 800KB | WGS | 3min | $0.01 | c4.2xlarge |'
id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-callcopyratiosegments-4-1-0-0/14
inputs:
- doc: Threshold on z-score of non-log2 copy ratio used for calling segments. 0.
  id: calling_copy_ratio_z_score_threshold
  inputBinding:
    position: 4
    prefix: --calling-copy-ratio-z-score-threshold
    shellQuote: false
  label: Calling copy ratio Z score threshold
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '2'
  type: float?
- doc: Input file containing copy-ratio segments (.cr.seg output of modelsegments).
  id: copy_ratio_segments
  inputBinding:
    position: 4
    prefix: --input
    shellQuote: false
  label: Copy ratio segments
  sbg:altPrefix: -I
  sbg:category: Required Arguments
  sbg:fileTypes: SEG, TSV
  type: File
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
- doc: Lower bound on non-log2 copy ratio used for determining copy-neutral segments.
    9.
  id: neutral_segment_copy_ratio_lower_bound
  inputBinding:
    position: 4
    prefix: --neutral-segment-copy-ratio-lower-bound
    shellQuote: false
  label: Neutral segment copy ratio lower bound
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: float?
- doc: Upper bound on non-log2 copy ratio used for determining copy-neutral segments.
    1.
  id: neutral_segment_copy_ratio_upper_bound
  inputBinding:
    position: 4
    prefix: --neutral-segment-copy-ratio-upper-bound
    shellQuote: false
  label: Neutral segment copy ratio upper bound
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '1'
  type: float?
- doc: Threshold on z-score of non-log2 copy ratio used for determining outlier copy-neutral
    segments. If non-log2 copy ratio z-score is above this threshold for a copy-neutral
    segment, it is considered an outlier and not used in the calculation of the length-weighted
    mean and standard deviation used for calling. 0.
  id: outlier_neutral_segment_copy_ratio_z_score_threshold
  inputBinding:
    position: 4
    prefix: --outlier-neutral-segment-copy-ratio-z-score-threshold
    shellQuote: false
  label: Outlier neutral segment copy ratio Z score threshold
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '2'
  type: float?
- doc: Output file for called copy-ratio segments.
  id: output_prefix
  label: Output prefix
  sbg:altPrefix: -O
  sbg:category: Required Arguments
  type: string?
- doc: Number of CPUs which will be allocated for the job.
  id: cpu_per_job
  label: CPU per job
  sbg:category: Execution
  sbg:toolDefaultValue: '1'
  type: int?
label: GATK CallCopyRatioSegments
outputs:
- doc: Called copy-ratio segments file
  id: called_segments
  label: Called copy ratio segments
  outputBinding:
    glob: '*.called.seg'
    outputEval: '$( inputs.copy_ratio_segments ? inheritMetadata(self, inputs.copy_ratio_segments)
      : self)'
  sbg:fileTypes: SEG
  type: File?
- doc: Called copy-ratio segments file, format for IGV viewer.
  id: called_legacy_segments
  label: Called legacy segments
  outputBinding:
    glob: '*called.igv.seg'
    outputEval: '$( inputs.copy_ratio_segments ? inheritMetadata(self, inputs.copy_ratio_segments)
      : self)'
  sbg:fileTypes: SEG
  type: File?
requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: '$(inputs.cpu_per_job ? inputs.cpu_per_job : 1)'
  ramMin: "${  \n    var memory = 2000;\n    if (inputs.memory_per_job) {\n      \
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
sbg:content_hash: ad78c5328d9da6738bda90b8b9c2ee89b60639cfa271f6cb8d4704dfeeff80e85
sbg:contributors:
- uros_sipetic
- stefan_stojanovic
sbg:createdBy: stefan_stojanovic
sbg:createdOn: 1551314117
sbg:id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-callcopyratiosegments-4-1-0-0/14
sbg:image_url: null
sbg:latestRevision: 14
sbg:license: Open source BSD (3-clause) license
sbg:modifiedBy: stefan_stojanovic
sbg:modifiedOn: 1559309799
sbg:project: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev
sbg:projectName: GATK 4.1.0.0 Toolkit DEV
sbg:publisher: sbg
sbg:revision: 14
sbg:revisionNotes: fix javascript expressions, add vars and semicolons etc.
sbg:revisionsInfo:
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551314117
  sbg:revision: 0
  sbg:revisionNotes: null
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551314140
  sbg:revision: 1
  sbg:revisionNotes: init
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553171324
  sbg:revision: 2
  sbg:revisionNotes: Update categories
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553615011
  sbg:revision: 3
  sbg:revisionNotes: change input id 'input' to 'copy_ratio_segments'; change input
    id 'output' to 'output_prefix'; fix output prefix argument expression to reflect
    changes in input IDs.
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553615101
  sbg:revision: 4
  sbg:revisionNotes: add description and default values for memory per job, memory
    overhead and cpu per job input parameters; fix memory requirements expression,
    remove default overhaed.
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553615251
  sbg:revision: 5
  sbg:revisionNotes: fix metadata inheritance expressions, add descriptions for output
    files
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553615607
  sbg:revision: 6
  sbg:revisionNotes: add info to app description, add sections
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553615942
  sbg:revision: 7
  sbg:revisionNotes: fix formatting in description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553615985
  sbg:revision: 8
  sbg:revisionNotes: fix input label in description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553616287
  sbg:revision: 9
  sbg:revisionNotes: add output naming to changes introduced by sbg
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553692699
  sbg:revision: 10
  sbg:revisionNotes: fix description format to match previous tools
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553770955
  sbg:revision: 11
  sbg:revisionNotes: add benchmarking data; fix conditional execution expression
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553773469
  sbg:revision: 12
  sbg:revisionNotes: add benchmarking info
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553814553
  sbg:revision: 13
  sbg:revisionNotes: set copy_ratio_segments (--input) input to required
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559309799
  sbg:revision: 14
  sbg:revisionNotes: fix javascript expressions, add vars and semicolons etc.
sbg:sbgMaintained: false
sbg:toolAuthor: Broad Institute
sbg:toolkit: GATK
sbg:toolkitVersion: 4.1.0.0
sbg:validationErrors: []
