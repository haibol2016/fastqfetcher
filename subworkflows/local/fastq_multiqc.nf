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

include { FASTQC }  from '../../modules/nf-core/fastqc/main.nf'
include { MULTIQC } from '../../modules/nf-core/multiqc/main.nf'

workflow FASTQ_MULTIQC {
    take:
    fastq_files_ch    // channel: FASTQ files from SRA2FASTQ workflow
                      // Format: [meta, fastq_file] where meta contains id and sra_id
    
    main:
    
    // Group FASTQ files by sample ID (using meta.sra_id)
    // Detect single-end vs paired-end based on number of files per sample
    fastq_files_ch
        .map { meta, fastq_file ->
            // Use sra_id as the grouping key
            [ meta.sra_id ?: meta.id, meta, fastq_file ]
        }
        .groupTuple(by: [0])  // Group by sample ID
        .map { sampleId, _metas, files ->
            // Detect paired-end: if we have 2 files, it's paired-end
            def isPaired = files.size() >= 2
            
            // Create QC metadata
            def qc_meta = [
                id: sampleId,
                sra_id: sampleId,
                single_end: !isPaired
            ]
            
            // Sort files naturally (ensures _1 comes before _2 for paired-end)
            def sortedFiles = files.sort()
            
            // FASTQC expects: single file for single-end, or list of files for paired-end
            [ qc_meta, isPaired ? sortedFiles : sortedFiles[0] ]
        }
        .set { fastq_grouped_ch }
    
    // Run FastQC on each sample
    FASTQC(fastq_grouped_ch)
    
    // Collect FastQC outputs for MultiQC
    // MultiQC only needs ZIP files (contains fastqc_data.txt), not HTML files
    // FastQC.out.zip are tuples: [meta, file(s)]
    // When glob pattern matches multiple files (paired-end), Nextflow returns them as a List
    // When only one file matches (single-end), Nextflow returns a single Path
    // Extract files from tuples and flatten to handle both cases
    def fastqc_zip_files = FASTQC.out.zip
        .map { it -> it[1] instanceof List ? it[1] : [it[1]] }
        .flatten()
    
    // Collect all ZIP files into a single List for MultiQC
    // MultiQC's stageAs: "?/*" pattern expects a List of files - it stages all files into a subdirectory
    // .collect() gathers all files from the channel into a single List, which MultiQC can process
    def multiqc_input_ch = fastqc_zip_files
        .unique()  // Remove duplicates first
        .collect() // Then collect all files into a single List for MultiQC
    
    // Prepare MultiQC config file (use params.multiqc_config if provided, otherwise check assets)
    def multiqc_config_ch = params.multiqc_config 
        ? channel.fromPath(params.multiqc_config)
        : channel.fromPath("${projectDir}/assets/multiqc_config.yml")

    // Run MultiQC (works with single or multiple samples)
    // MultiQC will process FastQC outputs even with just one sample
    MULTIQC (
        multiqc_input_ch,
        multiqc_config_ch,  // multiqc_config (script checks existence)
        [],  // extra_multiqc_config (script doesn't check existence)
        [],  // multiqc_logo (script doesn't check existence)
        [],  // replace_names (script doesn't check existence)
        []   // sample_names (script doesn't check existence)
    )
    
    emit:
    fastqc_html = FASTQC.out.html
    fastqc_zip = FASTQC.out.zip
    multiqc_report = MULTIQC.out.report
    multiqc_data = MULTIQC.out.data
    multiqc_plots = MULTIQC.out.plots
    versions = channel.topic('versions').unique()
}

