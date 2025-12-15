/*
 * Nextflow workflow for downloading SRA data and converting to FASTQ
 * 
 * This workflow:
 * 1. Downloads SRA data from NCBI using prefetch
 * 2. Converts SRA files to compressed FASTQ format using fasterq-dump
 * 
 * Supports single SRA IDs, multiple IDs, or a file with SRA IDs (one per line).
 */

nextflow.enable.dsl = 2

include { SRA_PREFETCH }          from '../../modules/local/sratools/prefetch/main.nf'
include { SRA_FASTERQDUMP }       from '../../modules/local/sratools/fasterq-dump/main.nf'

workflow SRA2FASTQ {
    take:
    sra_ids_ch      // channel: SRA accession IDs (can be single ID, multiple IDs, or file path)
    
    main:
    // Process SRA IDs and create metadata
    def sra_input_ch = sra_ids_ch
        .map { sra_id -> 
            def meta = [ id: sra_id, sra_id: sra_id ]
            [ meta, sra_id ]
        }
    
    // Step 1: Run prefetch for each SRA ID
    // SRA_PREFETCH takes: tuple val(meta), val(sra_id)
    // Additional arguments are handled via task.ext.args in modules.config
    SRA_PREFETCH (
        sra_input_ch
    )
    
    // Meta is already included in SRA_PREFETCH output, no need to combine
    def prefetch_results_ch = SRA_PREFETCH.out.sra_files
    
    // Step 2: Convert SRA files to FASTQ.gz
    // SRA_FASTERQDUMP takes: tuple val(meta), path(sra_file)
    // Threads and other arguments are handled via task.ext.args in modules.config
    SRA_FASTERQDUMP (
        prefetch_results_ch
    )
    
    // Meta is already included in SRA_FASTERQDUMP output, no need to combine
    def fastq_results_ch = SRA_FASTERQDUMP.out.fastq_files
    
    emit:
    sra_files = prefetch_results_ch.map { _meta, sra_file -> sra_file }
    fastq_files = fastq_results_ch.map { _meta, fastq_file -> fastq_file }
    results = fastq_results_ch
    versions = channel.topic('versions').unique()
}
