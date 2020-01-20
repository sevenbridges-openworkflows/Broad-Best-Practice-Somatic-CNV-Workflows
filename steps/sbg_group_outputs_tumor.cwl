$namespaces:
  sbg: https://sevenbridges.com
baseCommand:
- echo
- propagating
- inputs
class: CommandLineTool
cwlVersion: v1.0
doc: SBG Group Outputs is a simple tool which propagates array of input files to a
  single output port.
id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/sbg-group-outputs/12
inputs:
- doc: Array of input files.
  id: in_array
  inputBinding:
    position: 0
    shellQuote: false
  label: Input array
  type:
  - 'null'
  - items:
    - File
    - 'null'
    type: array
label: SBG Group Outputs
outputs:
- doc: Grouped files
  id: out_array
  label: Output array
  outputBinding:
    glob: .txt
    outputEval: "${\n    var out = []\n    for (var i = 0; i < inputs.in_array.length;\
      \ i++){\n        if (inputs.in_array[i]){\n            out.push(inputs.in_array[i])\n\
      \            \n        }\n    }\n    return out\n}"
  sbg:fileTypes: TXT, TSV, SEG, PNG, HDF5, PARAM
  type: File[]
requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: 1
- class: DockerRequirement
  dockerPull: ubuntu:16.04
- class: InlineJavascriptRequirement
sbg:appVersion:
- v1.0
sbg:content_hash: ad3e4e1c72bc85fa87f0752ab063457bf68560cb368f873ae2618d13369f8b32f
sbg:contributors:
- milena_stanojevic
- stefan_stojanovic
sbg:createdBy: stefan_stojanovic
sbg:createdOn: 1551355108
sbg:id: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/sbg-group-outputs/12
sbg:image_url: null
sbg:latestRevision: 12
sbg:modifiedBy: milena_stanojevic
sbg:modifiedOn: 1578663492
sbg:project: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev
sbg:projectName: GATK 4.1.0.0 Toolkit DEV
sbg:publisher: sbg
sbg:revision: 12
sbg:revisionNotes: File? -> [File, null], null
sbg:revisionsInfo:
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551355108
  sbg:revision: 0
  sbg:revisionNotes: null
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1551355145
  sbg:revision: 1
  sbg:revisionNotes: init
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553690258
  sbg:revision: 2
  sbg:revisionNotes: add basic info, add input and output labels and descriptions
- sbg:modifiedBy: stefan_stojanovic
  sbg:modifiedOn: 1553783297
  sbg:revision: 3
  sbg:revisionNotes: add file formats; add toolkit
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1577462831
  sbg:revision: 4
  sbg:revisionNotes: File types -> file type HDF5
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1577462877
  sbg:revision: 5
  sbg:revisionNotes: inputs -> in_array -> file type -> hdf5
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578496948
  sbg:revision: 6
  sbg:revisionNotes: in_array no file types
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578498130
  sbg:revision: 7
  sbg:revisionNotes: test glob -> .txt
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578655474
  sbg:revision: 8
  sbg:revisionNotes: no base command
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578655566
  sbg:revision: 9
  sbg:revisionNotes: input removed from command line
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578657168
  sbg:revision: 10
  sbg:revisionNotes: cwl copy/paste from SBGGroupOutputs test tool
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578662116
  sbg:revision: 11
  sbg:revisionNotes: base command broken into lines
- sbg:modifiedBy: milena_stanojevic
  sbg:modifiedOn: 1578663492
  sbg:revision: 12
  sbg:revisionNotes: File? -> [File, null], null
sbg:sbgMaintained: false
sbg:toolkit: SBGTools
sbg:validationErrors: []
