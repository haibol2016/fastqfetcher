process MULTIQC {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "docker.io/nemat1976/multiqc:1.29"

    input:
    path  multiqc_files, stageAs: "?/*"
    path multiqc_config
    path extra_multiqc_config     // optional, use [] as placeholder if not provided
    path multiqc_logo            // optional, use [] as placeholder if not provided
    path replace_names           // optional, use [] as placeholder if not provided
    path sample_names            // optional, use [] as placeholder if not provided

    output:
    path "*multiqc_report.html", emit: report
    path "*_data"              , emit: data
    path "*_plots"             , optional:true, emit: plots
    path "versions.yml"        , topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ? "--filename ${task.ext.prefix}.html" : ''
    def config = multiqc_config ? "--config $multiqc_config" : ''
    def extra_config = extra_multiqc_config ? "--config $extra_multiqc_config" : ''
    def logo = multiqc_logo ? "--cl-config 'custom_logo: \"${multiqc_logo}\"'" : ''
    def replace = replace_names ? "--replace-names ${replace_names}" : ''
    def samples = sample_names ? "--sample-names ${sample_names}" : ''
    """
    multiqc \\
        --force \\
        $args \\
        $config \\
        $prefix \\
        $extra_config \\
        $logo \\
        $replace \\
        $samples \\
        .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$(echo \$(multiqc --version) | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """

    stub:
    """
    mkdir multiqc_data
    mkdir multiqc_plots
    touch multiqc_report.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$(echo \$(multiqc --version) | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """
}
