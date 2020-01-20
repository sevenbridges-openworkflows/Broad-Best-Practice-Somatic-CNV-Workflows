$namespaces:
  sbg: https://sevenbridges.com
arguments:
- position: 0
  prefix: ''
  shellQuote: false
  valueFrom: '$( inputs.segments ? ''/opt/gatk'' : ''echo /opt/gatk'')'
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
  valueFrom: PlotModeledSegments
- position: 4
  prefix: --output
  shellQuote: false
  valueFrom: .
- position: 5
  prefix: --output-prefix
  shellQuote: false
  valueFrom: "${\n    if (inputs.segments) {\n        var nameroot = inputs.output_prefix\
    \ ? inputs.output_prefix : inputs.segments.nameroot;\n        return nameroot;\n\
    \    }\n    return '';\n}"
baseCommand: []
class: CommandLineTool
cwlVersion: v1.0
doc: 'GATK PlotModeledSegments creates plots of denoised and segmented copy-ratio
  and minor-allele-fraction estimates.


  ### Common Use Cases

  This tool is used for plotting modeled segments with copy number variants. Some
  of the input parameters are listed below:

  * **Segments** (`--segments`) - Modeled segments file, output of **ModelSegments**.

  * **Denoised copy ratios** (`--denoised-copy-ratios`) - File containing denoised
  copy ratios, output of **DenoiseReadCounts**. If allelic counts are not provided,
  then this is required.

  * **Allelic counts** (`--allelic-counts`) - File containing the counts at sites
  genotyped as heterozygous (HETS.TSV output of **ModelSegments**). If denoised copy
  ratios are not provided, then this is required.

  * **Sequence dictionary** (`--sequence-dictionary`) - This determines the order
  and representation of contigs in the plot.

  * **Output prefix** (`--output-prefix`) - This is used as the basename for output
  files.


  ### Changes Introduced by Seven Bridges

  * If **Output prefix** is not specified, prefix of output plot will be derived from
  the base name of the **Segments** file.


  ### Common Issues and Important Notes

  * *No issues have been identified thus far.*


  ### Performance Benchmarking


  | Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type
  |

  | --- | --- | --- | --- | --- |

  | 6MB | WES | 3min | $0.01 | c4.2xlarge |

  | 120MB | WGS | 3min | $0.01 | c4.2xlarge |'
id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-plotmodeledsegments-4-1-0-0/8
inputs:
- doc: Input file containing allelic counts at heterozygous sites (.hets.tsv output
    of modelsegments).
  id: allelic_counts
  inputBinding:
    position: 4
    prefix: --allelic-counts
    shellQuote: false
  label: Allelic counts
  sbg:category: Optional Arguments
  sbg:fileTypes: TSV, HETS.TSV
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
- doc: Threshold length (in bp) for contigs to be plotted. Contigs with lengths less
    than this threshold will not be plotted. This can be used to filter out mitochondrial
    contigs, unlocalized contigs, etc.
  id: minimum_contig_length
  inputBinding:
    position: 4
    prefix: --minimum-contig-length
    shellQuote: false
  label: Minimum contig length
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '1000000'
  type: int?
- doc: Prefix for output filenames.
  id: output_prefix
  label: Output prefix
  sbg:category: Required Arguments
  type: string?
- doc: Input file containing modeled segments (output of modelsegments).
  id: segments
  inputBinding:
    position: 4
    prefix: --segments
    shellQuote: false
  label: Segments
  sbg:category: Required Arguments
  sbg:fileTypes: SEG, TSV
  type: File
- doc: File containing a sequence dictionary, which specifies the contigs to be plotted
    and their relative lengths. The sequence dictionary must be a subset of those
    contained in other input files. Contigs will be plotted in the order given. Contig
    names should not include the string "contig_delimiter". The tool only considers
    contigs in the given dictionary for plotting, and data for contigs absent in the
    dictionary generate only a warning. In other words, you may modify a reference
    dictionary for use with this tool to include only contigs for which plotting is
    desired, and sort the contigs to the order in which the plots should display the
    contigs.
  id: sequence_dictionary
  inputBinding:
    position: 4
    prefix: --sequence-dictionary
    shellQuote: false
  label: Sequence dictionary
  sbg:altPrefix: -sequence-dictionary
  sbg:category: Required Arguments
  sbg:fileTypes: DICT
  type: File
- doc: Number of CPUs which will be allocated for the job.
  id: cpu_per_job
  label: CPU per job
  sbg:category: Execution
  sbg:toolDefaultValue: '1'
  type: int?
label: GATK PlotModeledSegments
outputs:
- doc: This shows the input denoised copy ratios and/or alternate-allele fractions
    as points, as well as box plots for the available posteriors in each segment.
    The colors of the points alternate with the segmentation.
  id: output_plot
  label: Modeled segments plot
  outputBinding:
    glob: '*.modeled.png'
    outputEval: '$( inputs.segments ? inheritMetadata(self, inputs.segments) : self)'
  sbg:fileTypes: PNG
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
sbg:content_hash: a5437b668adfe7b8011f0da8879b04d3bff6674998e7c18fb2234f1c5931bd6d8
sbg:contributors:
- uros_sipetic
- stefan_stojanovic
sbg:createdBy: stefan_stojanovic
sbg:createdOn: 1551313681
sbg:id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-plotmodeledsegments-4-1-0-0/8
sbg:image_url: null
sbg:latestRevision: 8
sbg:license: Open source BSD (3-clause) license
sbg:modifiedBy: stefan_stojanovic
sbg:modifiedOn: 1559311166
sbg:project: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev
sbg:projectName: GATK 4.1.0.0 Toolkit DEV
sbg:publisher: sbg
sbg:revision: 8
sbg:revisionNotes: fix js expressions, add vars and semicolons
sbg:revisionsInfo:
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551313681
  sbg:revision: 0
  sbg:revisionNotes: null
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551313709
  sbg:revision: 1
  sbg:revisionNotes: init
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553171728
  sbg:revision: 2
  sbg:revisionNotes: Update categories
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553683295
  sbg:revision: 3
  sbg:revisionNotes: fix description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553683381
  sbg:revision: 4
  sbg:revisionNotes: add descriptions for memory per job, memory overhead and cpu
    per job inputs
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553683778
  sbg:revision: 5
  sbg:revisionNotes: add input and output file formats
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553693903
  sbg:revision: 6
  sbg:revisionNotes: fix description format to match other tools
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553779265
  sbg:revision: 7
  sbg:revisionNotes: add benchmarking info
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559311166
  sbg:revision: 8
  sbg:revisionNotes: fix js expressions, add vars and semicolons
sbg:sbgMaintained: false
sbg:toolAuthor: Broad Institute
sbg:toolkit: GATK
sbg:toolkitVersion: 4.1.0.0
sbg:validationErrors: []
