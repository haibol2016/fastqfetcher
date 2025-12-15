/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { SRA2FASTQ            } from '../subworkflows/local/sra2fastq'
include { FASTQ_MULTIQC        } from '../subworkflows/local/fastq_multiqc'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow FASTQFETCHER {

    take:
    sra_ids_ch    // channel: SRA accession IDs (can be single ID, multiple IDs, or file path)
    
    main:    
    //
    // SUBWORKFLOW: Download SRA data and convert to FASTQ
    //
    SRA2FASTQ (
        sra_ids_ch
    )
       
    //
    // SUBWORKFLOW: Quality Control on FASTQ files
    //
    FASTQ_MULTIQC (
        SRA2FASTQ.out.results
    )
    
    // Collect versions from topic channel and filter out empty/null values
    ch_versions = channel.topic('versions')
        .unique()
        .filter { it -> it != null && it.toString().trim().length() > 0 }
    
    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'fastqfetcher_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        )

    emit:
    // sra_files = SRA2FASTQ.out.sra_files // not used in this workflow and not important for the user
    fastq_files = SRA2FASTQ.out.fastq_files
    fastqc_html = FASTQ_MULTIQC.out.fastqc_html
    fastqc_zip = FASTQ_MULTIQC.out.fastqc_zip
    multiqc_report = FASTQ_MULTIQC.out.multiqc_report
    multiqc_data = FASTQ_MULTIQC.out.multiqc_data
    multiqc_plots = FASTQ_MULTIQC.out.multiqc_plots
    versions = ch_versions
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
