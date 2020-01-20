$namespaces:
  sbg: https://sevenbridges.com
arguments:
- position: 0
  prefix: ''
  shellQuote: false
  valueFrom: '$( inputs.read_counts ? ''/opt/gatk'' : ''echo /opt/gatk'')'
- position: 1
  shellQuote: false
  valueFrom: --java-options
- position: 2
  shellQuote: false
  valueFrom: "${\n    if (inputs.memory_per_job) {\n        return '\\\"-Xmx'.concat(inputs.memory_per_job,\
    \ 'M') + '\\\"'\n    }\n    return '\\\"-Xmx2048M\\\"'\n}"
- position: 3
  shellQuote: false
  valueFrom: DenoiseReadCounts
- position: 4
  prefix: --denoised-copy-ratios
  shellQuote: false
  valueFrom: "${\n    if (inputs.read_counts) {\n        var nameroot = inputs.output_prefix\
    \ ? inputs.output_prefix : inputs.read_counts.nameroot;\n        var nameext =\
    \ '.denoisedCR.tsv';\n        return nameroot + nameext;\n    }\n    return '';\n\
    }"
- position: 5
  prefix: --standardized-copy-ratios
  shellQuote: false
  valueFrom: "${\n    if (inputs.read_counts) {\n        var nameroot = inputs.output_prefix\
    \ ? inputs.output_prefix : inputs.read_counts.nameroot;\n        var nameext =\
    \ '.standardizedCR.tsv';\n        return nameroot + nameext;\n    }\n    return\
    \ '';\n}"
baseCommand: []
class: CommandLineTool
cwlVersion: v1.0
doc: "GATK DenoiseReadCounts denoises read counts to produce denoised and standardized\
  \ copy ratios. \n\n### Common Use Cases\n\nTypically, a panel of normals produced\
  \ by CreateReadCountPanelOfNormals is provided as input. The input counts are then\
  \ standardized by 1) transforming to fractional coverage, 2) performing optional\
  \ explicit GC-bias correction (if the panel contains GC-content annotated intervals),\
  \ 3) filtering intervals to those contained in the panel, 4) dividing by interval\
  \ medians contained in the panel, 5) dividing by the sample median, and 6) transforming\
  \ to log2 copy ratio. The result is then denoised by subtracting the projection\
  \ onto the specified number of principal components from the panel.\n\nIf no panel\
  \ is provided, then the input counts are instead standardized by 1) transforming\
  \ to fractional coverage, 2) performing optional explicit GC-bias correction (if\
  \ GC-content annotated intervals are provided), 3) dividing by the sample median,\
  \ and 4) transforming to log2 copy ratio. No denoising is performed, so the denoised\
  \ result is simply taken to be identical to the standardized result.\n\nIf performed,\
  \ explicit GC-bias correction is done by GCBiasCorrector.\n\nNote that number-of-eigensamples\
  \ principal components from the input panel will be used for denoising; if only\
  \ fewer are available in the panel, then they will all be used. This parameter can\
  \ thus be used to control the amount of denoising, which will ultimately affect\
  \ the sensitivity of the analysis.\n\n*Source: [https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_DenoiseReadCounts.php](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/org_broadinstitute_hellbender_tools_copynumber_DenoiseReadCounts.php)*\n\
  \nSome of the input parameters are listed below:\n* **Read counts** (`--input`)\
  \ - TSV or HDF5 file containing read counts data for a single case sample. Output\
  \ of **CollectReadCounts**.\n* **Panel of normals** (`--count-panel-of-normals`),\
  \ from **CreateReadCountPanelOfNormals**. If provided, it will be used to standardize\
  \ and denoise the input counts. This may include explicit GC-bias correction if\
  \ annotated intervals were used to create the panel.\n* **Annotated intervals**\
  \ (`--annotated-intervals`) - GC annotated intervals from **AnnotateIntervals**.\
  \ This can be provided in place of a panel of normals to perform explicit GC-bias\
  \ correction. \nNote that number-of-eigensamples principal components from the input\
  \ panel will be used for denoising; if only fewer are available in the panel, then\
  \ they will all be used. This parameter can thus be used to control the amount of\
  \ denoising, which will ultimately affect the sensitivity of the analysis.\n* **Output\
  \ prefix** - Prefix for standardized and denoised copy ratio output files.\n\n###\
  \ Changes Introduced by Seven Bridges\n* Some of the non-applicable input parameters\
  \ have been removed.\n* Input parameter **Output prefix** has been added. It will\
  \ be used for naming output files by appending extensions `.denoisedCR.tsv` and\
  \ `.standardizedCR.tsv` to the provided prefix. In case the **Output prefix** is\
  \ not specified, the prefix for the output files will be derived from the base name\
  \ of the **Read counts** file.\n\n### Common Issues and Important Notes\n* *No issues\
  \ have been encountered thus far.*\n\n### Performance Benchmarking\n| Input Size\
  \ | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type |\n| ---\
  \ | --- | --- | --- | --- |\n| 7MB | WES | 3min | $0.01 | c4.2xlarge |\n| 500MB\
  \ | WGS | 3min | $0.01 | c4.2xlarge |"
id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-denoisereadcounts-4-1-0-0/12
inputs:
- doc: Input file containing annotations for gc content in genomic intervals (output
    of annotateintervals). Intervals must be identical to and in the same order as
    those in the input read-counts file. If a panel of normals is provided, this input
    will be ignored.
  id: annotated_intervals
  inputBinding:
    position: 4
    prefix: --annotated-intervals
    shellQuote: false
  label: Annotated intervals
  sbg:category: Optional Arguments
  sbg:fileTypes: INTERVALS, INTERVAL_LIST, LIST, BED, TSV
  sbg:toolDefaultValue: 'null'
  type: File?
- doc: Input HDF5 file containing the panel of normals (output of **CreateReadCountPanelOfNormals**).
  id: count_panel_of_normals
  inputBinding:
    position: 4
    prefix: --count-panel-of-normals
    shellQuote: false
  label: Panel of normals
  sbg:category: Optional Arguments
  sbg:fileTypes: HDF5
  sbg:toolDefaultValue: 'null'
  type: File?
- doc: Input TSV or HDF5 file containing integer read counts in genomic intervals
    for a single case sample (output of collectreadcounts).
  id: read_counts
  inputBinding:
    position: 4
    prefix: --input
    shellQuote: false
  label: Read counts
  sbg:altPrefix: -I
  sbg:category: Required Arguments
  sbg:fileTypes: TSV, HDF5
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
- doc: Number of eigensamples to use for denoising. If not specified or if the number
    of eigensamples available in the panel of normals is smaller than this, all eigensamples
    will be used.
  id: number_of_eigensamples
  inputBinding:
    position: 4
    prefix: --number-of-eigensamples
    shellQuote: false
  label: Number of eigensamples
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'null'
  type: int?
- doc: Number of CPUs which will be allocated for the job.
  id: cpu_per_job
  label: CPU per job
  sbg:category: Execution
  sbg:toolDefaultValue: '1'
  type: int?
- doc: Prefix for standardized and denoised copy ratio files that will be created
    by the tool.
  id: output_prefix
  label: Output prefix
  type: string?
label: GATK DenoiseReadCounts
outputs:
- doc: TSV file containing denoised copy ratios.
  id: out_denoised_copy_ratios
  label: Denoised copy ratios
  outputBinding:
    glob: '*.denoisedCR.tsv'
    outputEval: '$( inputs.read_counts ? inheritMetadata(self, inputs.read_counts)
      : self)'
  sbg:fileTypes: TSV
  type: File?
- doc: TSV file containing standardized copy ratios.
  id: out_standardized_copy_ratios
  label: Standardized copy ratios
  outputBinding:
    glob: '*.standardizedCR.tsv'
    outputEval: '$( inputs.read_counts ? inheritMetadata(self, inputs.read_counts)
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
- Genomics
- Copy Number Variant Calling
sbg:content_hash: a2555c15d80b1e45416e8bc7282c48aba7e011c21b452bfe3ecb10d378c8ce334
sbg:contributors:
- uros_sipetic
- stefan_stojanovic
sbg:createdBy: stefan_stojanovic
sbg:createdOn: 1551311937
sbg:id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-denoisereadcounts-4-1-0-0/12
sbg:image_url: null
sbg:latestRevision: 12
sbg:license: Open source BSD (3-clause) license
sbg:modifiedBy: stefan_stojanovic
sbg:modifiedOn: 1559302328
sbg:project: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev
sbg:projectName: GATK 4.1.0.0 Toolkit DEV
sbg:publisher: sbg
sbg:revision: 12
sbg:revisionNotes: fix javascript expressions, add vars and semicolons;
sbg:revisionsInfo:
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551311937
  sbg:revision: 0
  sbg:revisionNotes: null
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551311967
  sbg:revision: 1
  sbg:revisionNotes: init
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553170000
  sbg:revision: 2
  sbg:revisionNotes: Update categories
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553605709
  sbg:revision: 3
  sbg:revisionNotes: fix input IDs, labels, descriptions and file types; fix argument
    expressions to reflect changes in input ids
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553607220
  sbg:revision: 4
  sbg:revisionNotes: add descriptions for output files
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553608267
  sbg:revision: 5
  sbg:revisionNotes: fix description formatiing
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553693104
  sbg:revision: 6
  sbg:revisionNotes: fix description formatting to match other tools; add output prefix
    naming info
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553696646
  sbg:revision: 7
  sbg:revisionNotes: fix conditional execution expression
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553697222
  sbg:revision: 8
  sbg:revisionNotes: edit output glob
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553697581
  sbg:revision: 9
  sbg:revisionNotes: again, edit glob expressions; fix conditional metadata inheritance
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553770274
  sbg:revision: 10
  sbg:revisionNotes: add benchmarking info; fix typos in description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553814425
  sbg:revision: 11
  sbg:revisionNotes: set read_counts (--input) to required; add minor changes to description
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1559302328
  sbg:revision: 12
  sbg:revisionNotes: fix javascript expressions, add vars and semicolons;
sbg:sbgMaintained: false
sbg:toolAuthor: Broad Institute
sbg:toolkit: GATK
sbg:toolkitVersion: 4.1.0.0
sbg:validationErrors: []
