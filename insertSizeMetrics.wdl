version 1.0

workflow insertSizeMetrics {
  input {
    File inputBam
    String outputFileNamePrefix = basename(inputBam, '.bam')
  }

  call collectInsertSizeMetrics {
    input:
      inputBam = inputBam,
      outputPrefix = outputFileNamePrefix
  }

  output {
    File insertSizeMetrics = collectInsertSizeMetrics.insertSizeMetrics
    File histogramReport = collectInsertSizeMetrics.histogramReport
  }

  parameter_meta {
    inputBam: "Input file (bam or sam)."
    outputFileNamePrefix: "Output prefix to prefix output file names with."
  }

  meta {
    author: "Michael Laszloffy"
    email: "michael.laszloffy@oicr.on.ca"
    description: "Workflow to run picard InsertSizeMetrics"
    dependencies: [{
      name: "picard/2.21.2",
      url: "https://broadinstitute.github.io/picard/"
    },{
      name: "rstats/3.6",
      url: "https://www.r-project.org/"
    }]
  }
}

task collectInsertSizeMetrics {
  input {
    File inputBam
    String picardJar = "$PICARD_ROOT/picard.jar"
    Float minimumPercent = 0.5
    String outputPrefix = "OUTPUT"
    Int jobMemory = 18
    String modules = "picard/2.21.2 rstats/3.6"
    Int timeout = 12
  }

  parameter_meta {
    picardJar: "The picard jar to use."
    inputBam: "Input file (bam or sam)."
    minimumPercent: "Discard any data categories (out of FR, TANDEM, RF) when generating the histogram (Range: 0 to 1)."
    outputPrefix: "Output prefix to prefix output file names with."
    jobMemory: "Memory (in GB) allocated for job."
    modules: "Environment module names and version to load (space separated) before command execution."
    timeout: "Maximum amount of time (in hours) the task can run for."
  }

  meta {
    output_meta : {
      insertSizeMetrics: "Metrics about the insert size distribution (see https://broadinstitute.github.io/picard/picard-metric-definitions.html#InsertSizeMetrics).",
      histogramReport: "Insert size distribution plot."
    }
  }

  command <<<
    set -eu
    java -Xmx~{jobMemory - 6}G -jar ~{picardJar} \
    CollectInsertSizeMetrics \
    TMP_DIR=picardTmp \
    INPUT=~{inputBam} \
    OUTPUT="~{outputPrefix}.isize.txt" \
    HISTOGRAM_FILE="~{outputPrefix}.histogram.pdf" \
    MINIMUM_PCT=~{minimumPercent}
    test -f "~{outputPrefix}.isize.txt" || cat > "~{outputPrefix}.isize.txt" << 'EOI'
## htsjdk.samtools.metrics.StringHeader
# CollectInsertSizeMetrics HISTOGRAM_FILE=~{outputPrefix}.histogram.pdf MINIMUM_PCT=~{minimumPercent} INPUT=~{inputBam} OUTPUT=~{outputPrefix}.isize.txt TMP_DIR=[picardTmp] BLAH BLAH BLAH
## htsjdk.samtools.metrics.StringHeader
# Picard did not produce a file, so we're faking it.
EOI
    # If the histogram is empty, Picard doesn't write out a file, so we will write out a blank PDF file manually
    test -f "~{outputPrefix}.histogram.pdf" || cat > "~{outputPrefix}.histogram.pdf" << 'EOI'
%PDF-1.4
1 0 obj <</Type /Catalog /Pages 2 0 R>>
endobj
2 0 obj <</Type /Pages /Kids [3 0 R] /Count 1>>
endobj
3 0 obj<</Type /Page /Parent 2 0 R /Resources 4 0 R /MediaBox [0 0 500 800] /Contents 6 0 R>>
endobj
4 0 obj<</Font <</F1 5 0 R>> >>
endobj
5 0 obj<</Type /Font /Subtype /Type1 /BaseFont /Helvetica>>
endobj
6 0 obj
<</Length 59>>
stream
BT /F1 24 Tf 75 720 Td (Picard produced no histogram)Tj ET
endstream
endobj
xref
0 7
0000000000 65535 f
0000000009 00000 n
0000000056 00000 n
0000000111 00000 n
0000000212 00000 n
0000000250 00000 n
0000000317 00000 n
trailer <</Size 7/Root 1 0 R>>
startxref
406
%%EOF
EOI
  >>>

  runtime {
    memory: "~{jobMemory} GB"
    modules: "~{modules}"
    timeout: "~{timeout}"
  }

  output {
    File insertSizeMetrics = "~{outputPrefix}.isize.txt"
    File histogramReport = "~{outputPrefix}.histogram.pdf"
  }
}
