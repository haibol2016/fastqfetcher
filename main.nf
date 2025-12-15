/*
 * Complete SRA workflow: Download and convert to FASTQ.gz
 * 
 * Usage:
 *   # Single SRA ID (as string)
 *   nextflow run main.nf --input SRR123456
 * 
 *   # Multiple SRA IDs (comma-separated string)
 *   nextflow run main.nf --input SRR123456,SRR123457,SRR123458
 * 
 *   # From file (one SRA ID per line)
 *   nextflow run main.nf --input sra_ids.txt
 * 
 *   # With custom options
 *   nextflow run main.nf --input SRR123456 --outdir ./results
 */

nextflow.enable.dsl=2

include { FASTQFETCHER } from './workflows/fastqfetcher.nf'
include { PIPELINE_COMPLETION } from './subworkflows/local/utils'
include { UTILS_NFSCHEMA_PLUGIN } from './subworkflows/nf-core/utils_nfschema_plugin'
include { UTILS_NFCORE_PIPELINE } from './subworkflows/nf-core/utils_nfcore_pipeline'
include { UTILS_NEXTFLOW_PIPELINE } from './subworkflows/nf-core/utils_nextflow_pipeline'

workflow {
    
    //
    // PIPELINE INITIALISATION
    // Handles version printing, parameter validation, and config checking
    // Note: We skip samplesheet processing since we use SRA IDs instead
    //
    
    // Print version and exit if required and dump pipeline parameters to JSON file
    UTILS_NEXTFLOW_PIPELINE (
        params.version,
        true,
        params.outdir,
        workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1
    )
    
    // Validate parameters and generate parameter summary to stdout
    UTILS_NFSCHEMA_PLUGIN (
        workflow,
        params.validate_params,
        null
    )
    
    // Check config provided to the pipeline
    UTILS_NFCORE_PIPELINE (
        [] as List  // nextflow_cli_args (empty for now)
    )
    
    // Create SRA IDs channel from params.input
    // Check if params.input is a file or a comma-separated string
    def sra_ids_ch
    
    // Check if params.input contains commas (likely a comma-separated string)
    if (params.input.contains(',')) {
        // Comma-separated string of SRA IDs
        def ids = params.input.tokenize(',').collect { id -> id.trim() }
        sra_ids_ch = channel.of(ids)
    } else {
        // Try to treat as file path (one SRA ID per line)
        def input_path = file(params.input)
        if (input_path.exists()) {
            // File exists - read line by line
            sra_ids_ch = channel.fromPath(params.input)
                .splitText()
                .map { line -> 
                    "${line}".trim()
                }
                .filter { line -> 
                    line && !line.startsWith('#')
                }
        } else {
            // File doesn't exist - treat as single SRA ID string
            // Validate it's a valid SRA ID format using regex
            // Use ==~ for exact match (entire string must match pattern)
            if (!(params.input ==~ /^SRR\d+$/)) {
                exit 1, "ERROR: Invalid SRA ID format: ${params.input}. Expected format: SRR followed by digits (e.g., SRR123456)"
            }
            sra_ids_ch = channel.of(params.input.trim())
        }
    }
    
    //
    // RUN MAIN WORKFLOW
    //
    def fastqfetcher_results = FASTQFETCHER(sra_ids_ch)
    
    //
    // PIPELINE COMPLETION
    // Handles completion emails, summaries, and notifications
    //
    // Collect MultiQC report (PIPELINE_COMPLETION expects a channel)

    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        params.hook_url,
        fastqfetcher_results.multiqc_report
    )
    
    // Print summary
    fastqfetcher_results.fastq_files
        .view { file -> "Downloaded and converted: $file" }
}


