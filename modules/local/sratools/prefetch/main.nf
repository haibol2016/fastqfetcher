/*
 * SRA Toolkit prefetch - Download SRA data
 * 
 * This module downloads SRA data using the SRA Toolkit prefetch command.
 * The prefetched data can then be converted to FASTQ using fasterq-dump or fastq-dump.
 * 
 * Documentation: https://github.com/ncbi/sra-tools/wiki/HowTo:-prefetch-and-fasterq-dump
 */

process SRA_PREFETCH {
    tag "${meta.id}"
    label 'process_medium'

    // Conda environment or container
    conda "${moduleDir}/environment.yml"
    container "docker.io/nemat1976/sra-tools-pigz:3.2.1"

    input:
    tuple val(meta), val(sra_id)  // Accept meta + sra_id

    output:
    tuple val(meta), path("*.sra"), emit: sra_files
    path "versions.yml",  topic: versions

    script:
    def args = task.ext.args ?: ""
    
    """
    # Prefetch SRA data
    prefetch \\
        ${sra_id} \\
        ${args}
    
    # Find and move SRA file to work directory
    # Prefetch typically creates: ${sra_id}/${sra_id}.sra or downloads to current directory
    if [ -f "${sra_id}/${sra_id}.sra" ]; then
        mv "${sra_id}/${sra_id}.sra" "./${sra_id}.sra"
    elif [ -f "${sra_id}.sra" ]; then
        # Already in current directory
        :
    else
        # Try to find the file
        find . -name "${sra_id}.sra" -type f -exec mv {} "./${sra_id}.sra" \\;
    fi
    
    # Verify file exists
    if [ ! -f "${sra_id}.sra" ]; then
        echo "ERROR: SRA file ${sra_id}.sra not found after prefetch" >&2
        exit 1
    fi
    
    # Get version information
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        prefetch: \$(echo \$(prefetch --version) | sed -e "s/prefetch : //g" )
    END_VERSIONS
    """

    stub:
    """
    touch "${sra_id}.sra"
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        prefetch: \$(echo \$(prefetch --version) | sed -e "s/prefetch : //g" )
    END_VERSIONS
    """
}

