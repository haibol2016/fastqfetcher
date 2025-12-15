/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { SRA2FASTQ            } from '../subworkflows/local/utils_nfcore_fastqfetcher_pipeline/sra2fastq'
include { QC                   } from '../subworkflows/local/utils_nfcore_fastqfetcher_pipeline/qc'
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

    ch_versions = channel.empty()
    
    //
    // SUBWORKFLOW: Download SRA data and convert to FASTQ
    //
    SRA2FASTQ (
        sra_ids_ch
    )
    
    // Collect versions from SRA2FASTQ
    ch_versions = ch_versions.mix(SRA2FASTQ.out.versions.first())
    
    //
    // SUBWORKFLOW: Quality Control on FASTQ files
    //
    QC (
        SRA2FASTQ.out.results
    )
    
    // Collect versions from QC
    ch_versions = ch_versions.mix(QC.out.versions.first())
    
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
    sra_files = SRA2FASTQ.out.sra_files
    fastq_files = SRA2FASTQ.out.fastq_files
    fastqc_html = QC.out.fastqc_html
    fastqc_zip = QC.out.fastqc_zip
    multiqc_report = QC.out.multiqc_report
    multiqc_data = QC.out.multiqc_data
    multiqc_plots = QC.out.multiqc_plots
    versions = ch_versions

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
