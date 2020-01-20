$namespaces:
  sbg: https://sevenbridges.com
arguments:
- position: 1
  prefix: ''
  shellQuote: false
  valueFrom: '$(inputs.run_oncotator ? "" : "echo") /root/oncotator_venv/bin/oncotator
    --db-dir /root/onco_dbdir/ -c /root/tx_exact_uniprot_matches.AKT1_CRLF2_FGFR1.txt
    -u file:///root/onco_cache/ -r -v ${return inputs.called_file.nameroot+''.seq_dict_removed.seg
    ''} ${return inputs.called_file.nameroot+''.per_segment.oncotated.txt''} hg19
    -i SEG_FILE -o SIMPLE_TSV ${if (inputs.additional_args) {return inputs.additional_args}
    return ''''} ;'
- position: 0
  prefix: ''
  shellQuote: false
  valueFrom: '$(inputs.run_oncotator ? "" : "echo") egrep -v "^\@" $(inputs.called_file.path)
    > ${return inputs.called_file.nameroot+''.seq_dict_removed.seg''} ;'
- position: 2
  prefix: ''
  shellQuote: false
  valueFrom: '$(inputs.run_oncotator ? "" : "echo") /root/oncotator_venv/bin/oncotator
    --db-dir /root/onco_dbdir/ -c /root/tx_exact_uniprot_matches.AKT1_CRLF2_FGFR1.txt
    -u file:///root/onco_cache/ -r -v ${return inputs.called_file.nameroot+''.seq_dict_removed.seg''}
    ${return inputs.called_file.nameroot+''.gene_list.txt''} hg19 -i SEG_FILE -o GENE_LIST
    ${if (inputs.additional_args) {return inputs.additional_args} return ''''}'
baseCommand: []
class: CommandLineTool
cwlVersion: v1.0
doc: 'GATK OncotateSegments is a version of **Oncotator** adapted for **GATK CNV Pair
  Workflow**. It is used for annotating called segments.


  ### Common Use Cases

  **Oncotator** is a tool for annotating information onto genomic point mutations
  (SNPs/SNVs) and indels. It is primarily intended to be used on human genome variant
  callsets and we only provide data sources that are relevant to cancer researchers.
  However, the tool can technically be used to annotate any kind of information onto
  variant callsets from any organism, and we provide instructions on how to prepare
  custom data sources for inclusion in the process. By default Oncotator is set up
  to use a simple tsv (a.k.a MAFLITE) as input and produces a TCGA MAF as output.
  See details below. Some of the input parameters are listed below:

  * **Segments file** - Called copy-ratio-segments file, produced by **CallCopyRatioSegments**
  tool. This is a tab-separated values (TSV) file with a SAM-style header containing
  a read group sample name, a sequence dictionary, a row specifying the column headers
  and the corresponding entry rows.

  * **Run oncotator** - This input is added per GATK best practice specification.
  It has to be set to True in order to execute the command line. If set to False,
  the command line will just be echoed.


  ### Changes Introduced by Seven Bridges

  * Additional **Run oncotator** input parameter is added. This is done to allow optional
  execution of this app within GATK CNV Pair Workflow, per [GATK best practice specification](https://github.com/gatk-workflows/gatk4-somatic-cnvs/blob/master/cnv_somatic_oncotator_workflow.wdl).


  ### Common Issues and Important Notes

  * This app only supports **hg19** genome build, and is not intended to be used with
  other reference genomes.


  ### Performance Benchmarking


  | Input Size | Experimental Strategy | Duration | Cost (spot) | AWS Instance Type
  |

  | --- | --- | --- | --- | --- |

  | 30KB | WES | 5min | $0.02 | c4.2xlarge |

  | 800KB | WGS | 5min | $0.02 | c4.2xlarge |'
id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-cnv-oncotatesegments/7
inputs:
- doc: Called copy-ratio-segments file. This is a tab-separated values (TSV) file
    with a SAM-style header containing a read group sample name, a sequence dictionary,
    a row specifying the column headers and the corresponding entry rows.
  id: called_file
  label: Segments File
  sbg:category: Required Arguments
  sbg:fileTypes: SEG, TSV
  type: File
- doc: This input is added per GATK best practice specification. It has to be set
    to True in order to execute the command line. If set to False, the command line
    will just be echoed.
  id: run_oncotator
  label: Run oncotator
  sbg:category: Execution
  type: boolean
- doc: Additional arguments passed to Oncotator.
  id: additional_args
  label: Additional arguments
  sbg:category: Optional Arguments
  type: string?
- doc: Memory which will be allocated for execution.
  id: memory_per_job
  label: Memory per job
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '2048'
  type: int?
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
  sbg:toolDefaultValue: '1'
  type: int?
label: CNV OncotateSegments
outputs:
- id: oncotated_called_file
  label: Oncotated Called File
  outputBinding:
    glob: '*per_segment.oncotated.txt'
    outputEval: $(inheritMetadata(self, inputs.called_file))
  sbg:fileTypes: TXT
  type: File?
- id: oncotated_gene_list
  label: Oncotated Gene List
  outputBinding:
    glob: '*gene_list.txt'
    outputEval: $(inheritMetadata(self, inputs.called_file))
  sbg:fileTypes: TXT
  type: File?
requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: '$( inputs.cpu_per_job ? inputs.cpu_per_job : 1)'
  ramMin: "${\n    var memory = 2048;\n    if (inputs.memory_per_job) {\n        memory\
    \ = inputs.memory_per_job;\n    }\n    if (inputs.memory_overhead_per_job) {\n\
    \        memory += inputs.memory_overhead_per_job;\n    }\n    return memory\n\
    }"
- class: DockerRequirement
  dockerPull: images.sbgenomics.com/stefan_stojanovic/oncotator:1.9.5.0-eval-gatk-protected
- class: InlineJavascriptRequirement
  expressionLib:
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
sbg:content_hash: a4a96780ed1098556731a5b340c42b55bde4c9967e48b0eff37f49c52a27c5bdc
sbg:contributors:
- stefan_stojanovic
sbg:createdBy: stefan_stojanovic
sbg:createdOn: 1551314584
sbg:id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-cnv-oncotatesegments/7
sbg:image_url: null
sbg:latestRevision: 7
sbg:modifiedBy: stefan_stojanovic
sbg:modifiedOn: 1553785352
sbg:project: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev
sbg:projectName: GATK 4.1.0.0 Toolkit DEV
sbg:publisher: sbg
sbg:revision: 7
sbg:revisionNotes: add benchmarking info
sbg:revisionsInfo:
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551314584
  sbg:revision: 0
  sbg:revisionNotes: null
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551314608
  sbg:revision: 1
  sbg:revisionNotes: init
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553183968
  sbg:revision: 2
  sbg:revisionNotes: remove redundant inputs, add hardcoded input formats to command
    line
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553184313
  sbg:revision: 3
  sbg:revisionNotes: fix input labels and descriptions; add memory per job, memory
    overhead and cpu per job inputs; fix memory and cpu requirements expressions
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553184767
  sbg:revision: 4
  sbg:revisionNotes: edit description, add useful info
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553185109
  sbg:revision: 5
  sbg:revisionNotes: add output file formats
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553185268
  sbg:revision: 6
  sbg:revisionNotes: fix app label
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553785352
  sbg:revision: 7
  sbg:revisionNotes: add benchmarking info
sbg:sbgMaintained: false
sbg:toolAuthor: Ramos et. al.
sbg:toolkit: Oncotator
sbg:validationErrors: []
