/*
 * Quality Control subworkflow for FASTQ files
 * 
 * This workflow:
 * 1. Groups FASTQ files by sample (detecting single-end vs paired-end)
 * 2. Runs FastQC on each sample
 * 3. Aggregates FastQC results using MultiQC
 * 
 * Input: FASTQ files from SRA2FASTQ workflow
 * Output: FastQC reports and MultiQC aggregated report
 */

nextflow.enable.dsl=2

include { FASTQC }  from '../../../modules/nf-core/fastqc/main.nf'
include { MULTIQC } from '../../../modules/nf-core/multiqc/main.nf'

workflow QC {
    take:
    fastq_files_ch    // channel: FASTQ files from SRA2FASTQ workflow
                      // Format: [meta, fastq_file] where meta contains id and sra_id
    
    main:
    
    // Group FASTQ files by sample ID
    // Detect single-end vs paired-end based on filename patterns
    fastq_files_ch
        .map { meta, fastq_file ->
            def filename = fastq_file.getName()
            def baseName = filename.replaceAll(/\.(fastq|fq)\.gz$/, '')
            
            // Detect if this is a paired-end read (ends with _1 or _2)
            def isPaired = filename.matches(/.*_[12]\.(fastq|fq)\.gz$/)
            def readNumber = null
            
            if (isPaired) {
                // Extract read number (1 or 2) and base sample name
                def match = filename =~ /(.+)_([12])\.(fastq|fq)\.gz$/
                if (match) {
                    baseName = match[0][1]  // Base name without _1 or _2
                    readNumber = match[0][2] as Integer
                }
            }
            
            // Use SRA ID from meta if available, otherwise use base name
            def sampleId = meta.sra_id ?: baseName
            
            // Create metadata
            def qc_meta = [
                id: sampleId,
                sra_id: meta.sra_id ?: sampleId,
                single_end: !isPaired
            ]
            
            // Return with sample ID as key for grouping
            [ sampleId, qc_meta, fastq_file, readNumber ]
        }
        .groupTuple(by: [0])  // Group by sample ID
        .map { sampleId, items ->
            // items is a list of [meta, fastq_file, readNumber] tuples
            def meta = items[0][0]  // Get first meta (they should all be the same)
            def readNumbers = items.collect {it -> it[2] }.findAll { it -> it != null }  // Collect read numbers
            
            // Sort FASTQ files: if paired-end, ensure _1 comes before _2
            def fastqFiles = []
            if (readNumbers.size() > 0) {
                // Paired-end: sort by read number
                def fileMap = [:]
                items.each { item ->
                    def readNum = item[2]
                    if (readNum) {
                        fileMap[readNum] = item[1]
                    }
                }
                // Add _1 first, then _2
                if (fileMap[1]) fastqFiles.add(fileMap[1])
                if (fileMap[2]) fastqFiles.add(fileMap[2])
            } else {
                // Single-end: just add the file
                fastqFiles = items.collect {it -> it[1] }
            }
            
            [ meta, fastqFiles ]
        }
        .set { fastq_grouped_ch }
    
    // Run FastQC on each sample
    FASTQC(fastq_grouped_ch)
    
    // Collect FastQC outputs for MultiQC
    // MultiQC needs all FastQC HTML and ZIP files in a single channel
    def fastqc_html_ch = FASTQC.out.html
    def fastqc_zip_ch = FASTQC.out.zip
    
    // Collect all FastQC output files for MultiQC
    fastqc_html_ch
        .map { meta, html_files ->
            // Handle both single files and lists
            def files = html_files instanceof List ? html_files : [html_files]
            files
        }
        .flatten()
        .mix(
            fastqc_zip_ch
                .map { meta, zip_files ->
                    def files = zip_files instanceof List ? zip_files : [zip_files]
                    files
                }
                .flatten()
        )
        .unique()
        .set { multiqc_input_ch }
    
    // Create empty channels for optional MultiQC inputs
    def empty_ch = Channel.empty()
    
    // Run MultiQC
    MULTIQC (
        multiqc_input_ch,
        empty_ch,  // multiqc_config (optional)
        empty_ch,  // extra_multiqc_config (optional)
        empty_ch,  // multiqc_logo (optional)
        empty_ch,  // replace_names (optional)
        empty_ch   // sample_names (optional)
    )
    
    emit:
    fastqc_html = FASTQC.out.html
    fastqc_zip = FASTQC.out.zip
    multiqc_report = MULTIQC.out.report
    multiqc_data = MULTIQC.out.data
    multiqc_plots = MULTIQC.out.plots
    versions = FASTQC.out.versions
        .mix(MULTIQC.out.versions)
}

