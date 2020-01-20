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
  valueFrom: PlotDenoisedCopyRatios
- position: 4
  prefix: --output
  shellQuote: false
  valueFrom: .
- position: 5
  prefix: --output-prefix
  shellQuote: false
  valueFrom: "${\n    if (inputs.denoised_copy_ratios) {\n        if (inputs.output_prefix)\
    \ {\n            return inputs.output_prefix;\n        }\n        return inputs.denoised_copy_ratios.nameroot.split('.').slice(0,-1).join('.');\n\
    \    }\n    return '';\n}"
baseCommand: []
class: CommandLineTool
cwlVersion: v1.0
doc: "GATK PlotDenoisedCopytRatios creates plots of denoised copy ratios as well as\
  \ various denoising metrics.\n\n### Common Use Cases\nThis tool plots standardized\
  \ and denoised copy ratios from **DenoiseReadCounts**. Some of the input parameters\
  \ are listed below: \n* **Standardized copy ratios** (`--standardized-copy-ratios`)-\
  \ TSV file with standardized copy ratios, output of **DenoiseReadCounts**.\n* **Denoised\
  \ copy ratios** (`--denoised-copy-ratios`) - TSV file with denoised copy ratios,\
  \ output of **DenoiseReadCounts**.\n* **Sequence dictionary** (`--sequence-dictionary`)\
  \ - This determines the order and representation of contigs in the plot.\n* **Output\
  \ prefix** (`--output-prefix`) - This is used as the basename for output files.\n\
  \n### Changes Introduced by Seven Bridges\n* If **Output prefix** is not specified,\
  \ the prefix for the output files will be derived from the base name of  **Denoised\
  \ copy ratios** input file.\n\n### Common Issues and Important Notes\n* *No issues\
  \ have been identified thus far.*\n\n### Performance Benchmarking\n\n| Input Size\
  \ | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| ---\
  \ | --- | --- | --- | --- |\n| 10MB | WES | 3min | $0.01 | c4.2xlarge |\n| 120MB\
  \ | WGS | 3min | $0.01 | c4.2xlarge |"
id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-plotdenoisedcopyratios-4-1-0-0/11
inputs:
- doc: Input file containing denoised copy ratios (output of denoisereadcounts).
  id: denoised_copy_ratios
  inputBinding:
    position: 4
    prefix: --denoised-copy-ratios
    shellQuote: false
  label: Denoised copy ratios
  sbg:category: Required Arguments
  sbg:fileTypes: TSV
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
- doc: Input file containing standardized copy ratios (output of denoisereadcounts).
  id: standardized_copy_ratios
  inputBinding:
    position: 4
    prefix: --standardized-copy-ratios
    shellQuote: false
  label: Standardized copy ratios
  sbg:category: Required Arguments
  sbg:fileTypes: TSV
  type: File
- doc: Number of CPUs which will be allocated for the job.
  id: cpu_per_job
  label: CPU per job
  sbg:category: Execution
  sbg:toolDefaultValue: '1'
  type: int?
label: GATK PlotDenoisedCopyRatios
outputs:
- doc: Plot showing the standardized and denoised copy ratios; covers the entire range
    of the copy ratios.
  id: denoised_plot
  label: Denoised plot
  outputBinding:
    glob: '*.denoised.png'
    outputEval: '$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios)
      : self)'
  sbg:fileTypes: PNG
  type: File?
- doc: Plot showing the standardized and denoised copy ratios limited to copy ratios
    within [0, 4].
  id: denoised_limit_plot
  label: Denoised limit plot
  outputBinding:
    glob: '*.denoisedLimit4.png'
    outputEval: '$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios)
      : self)'
  sbg:fileTypes: PNG
  type: File?
- doc: Delta median-absolute-deviation file.
  id: delta_mad
  label: Delta MAD
  outputBinding:
    glob: '*.deltaMAD.txt'
    outputEval: '$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios)
      : self)'
  sbg:fileTypes: TXT
  type: File?
- doc: Denoised median-absolute-deviation file.
  id: denoised_mad
  label: Denoised MAD
  outputBinding:
    glob: '*.denoisedMAD.txt'
    outputEval: '$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios)
      : self)'
  sbg:fileTypes: TXT
  type: File?
- doc: Scaled median-absolute-deviation file.
  id: scaled_delta_mad
  label: Scaled delta MAD
  outputBinding:
    glob: '*.scaledDeltaMAD.txt'
    outputEval: '$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios)
      : self)'
  sbg:fileTypes: TXT
  type: File?
- doc: Standardized median-absolute-deviation file.
  id: standardized_mad
  label: Standardized MAD
  outputBinding:
    glob: '*.standardizedMAD.txt'
    outputEval: '$( inputs.denoised_copy_ratios ? inheritMetadata(self, inputs.denoised_copy_ratios)
      : self)'
  sbg:fileTypes: TXT
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
sbg:content_hash: a403dfb22469adf0a87b544e91de82d0ab1dcbc3063e52ce8b4c0ff084f0df87b
sbg:contributors:
- uros_sipetic
- stefan_stojanovic
sbg:createdBy: stefan_stojanovic
sbg:createdOn: 1551312245
sbg:id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-plotdenoisedcopyratios-4-1-0-0/11
sbg:image_url: null
sbg:latestRevision: 11
sbg:license: Open source BSD (3-clause) license
sbg:modifiedBy: stefan_stojanovic
sbg:modifiedOn: 1559310632
sbg:project: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev
sbg:projectName: GATK 4.1.0.0 Toolkit DEV
sbg:publisher: sbg
sbg:revision: 11
sbg:revisionNotes: fix js expressions, add vars and semicolons;
sbg:revisionsInfo:
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551312245
  sbg:revision: 0
  sbg:revisionNotes: null
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551312270
  sbg:revision: 1
  sbg:revisionNotes: init
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553172124
  sbg:revision: 2
  sbg:revisionNotes: Update categories
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553686104
  sbg:revision: 3
  sbg:revisionNotes: fix description input section; add output file descriptions and
    file formats
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553686304
  sbg:revision: 4
  sbg:revisionNotes: fix description, add sections
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553686334
  sbg:revision: 5
  sbg:revisionNotes: add input file formats
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553686391
  sbg:revision: 6
  sbg:revisionNotes: add descriptions and default values for memory per job, memory
    overhaed and cpu per job inputs
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553694148
  sbg:revision: 7
  sbg:revisionNotes: remove outputs section of the descrition; merge inputs section
    with common use cases to match formatting of other tools
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553781410
  sbg:revision: 8
  sbg:revisionNotes: add benchmarking info
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553814703
  sbg:revision: 9
  sbg:revisionNotes: set denoised_copy_ratios, standardized_copy_ratios and sequence_dictionary
    inputs to required
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553815525
  sbg:revision: 10
  sbg:revisionNotes: fix conditional metadata inheritance for all output files
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559310632
  sbg:revision: 11
  sbg:revisionNotes: fix js expressions, add vars and semicolons;
sbg:sbgMaintained: false
sbg:toolAuthor: Broad Institute
sbg:toolkit: GATK
sbg:toolkitVersion: 4.1.0.0
sbg:validationErrors: []
