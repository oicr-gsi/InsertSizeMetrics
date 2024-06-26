# insertSizeMetrics

Workflow to run picard InsertSizeMetrics

## Overview

## Dependencies

* [picard 2.21.2](https://broadinstitute.github.io/picard/)
* [rstats 3.6](https://www.r-project.org/)


## Usage

### Cromwell
```
java -jar cromwell.jar run insertSizeMetrics.wdl --inputs inputs.json
```

### Inputs

#### Required workflow parameters:
Parameter|Value|Description
---|---|---
`inputBam`|File|Input file (bam or sam).


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---
`outputFileNamePrefix`|String|basename(inputBam,'.bam')|Output prefix to prefix output file names with.


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`collectInsertSizeMetrics.picardJar`|String|"$PICARD_ROOT/picard.jar"|The picard jar to use.
`collectInsertSizeMetrics.minimumPercent`|Float|0.5|Discard any data categories (out of FR, TANDEM, RF) when generating the histogram (Range: 0 to 1).
`collectInsertSizeMetrics.jobMemory`|Int|18|Memory (in GB) allocated for job.
`collectInsertSizeMetrics.modules`|String|"picard/2.21.2 rstats/3.6"|Environment module names and version to load (space separated) before command execution.
`collectInsertSizeMetrics.timeout`|Int|12|Maximum amount of time (in hours) the task can run for.


### Outputs

Output | Type | Description | Labels
---|---|---|---
`insertSizeMetrics`|File|Metrics file with insert size data|vidarr_label: insertSizeMetrics
`histogramReport`|File|Histogram Report|vidarr_label: histogramReport


## Commands
 This section lists command(s) run by InsertSizeMetrics workflow
 
 * Running InsertSizeMetrics
 
 ### Running InsertSizeMetrics walker with picard
 
 ```
     java -Xmx~{jobMemory - 6}G -jar ~{picardJar} \
     CollectInsertSizeMetrics \
     TMP_DIR=picardTmp \
     INPUT=~{inputBam} \
     OUTPUT="~{outputPrefix}.isize.txt" \
     HISTOGRAM_FILE="~{outputPrefix}.histogram.pdf" \
     MINIMUM_PCT=~{minimumPercent}
 ```
 ## Support

For support, please file an issue on the [Github project](https://github.com/oicr-gsi) or send an email to gsi@oicr.on.ca .

_Generated with generate-markdown-readme (https://github.com/oicr-gsi/gsi-wdl-tools/)_
