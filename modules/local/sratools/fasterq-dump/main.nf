/*
 * SRA Toolkit fasterq-dump - Convert SRA files to FASTQ.gz
 * 
 * This module converts SRA files to compressed FASTQ format using fasterq-dump.
 * Supports both single-end and paired-end reads.
 * 
 * Documentation: https://github.com/ncbi/sra-tools/wiki/HowTo:-fasterq-dump
 */

process SRA_FASTERQDUMP {
    tag "${meta.id}"
    label 'process_medium'
    publishDir "${params.outdir}/fastq", mode: 'copy', pattern: '*.fastq.gz'

    // Conda environment or container
    conda "${moduleDir}/environment.yml"
    container "docker.io/nemat1976/sra-tools-pigz:3.2.1"

    input:
    tuple val(meta), path(sra_file)  // Accept meta + sra_file

    output:
    tuple val(meta), path("*.fastq.gz"), emit: fastq_files
    path "versions.yml",  topic: versions

    script:
    def args1 = task.ext.args1 ?: ""
    def args2 = task.ext.args2 ?: ""

    """
    # Get SRA file basename (without .sra extension)
    SRA_BASE=\$(basename "${sra_file}" .sra)
    
    # Convert SRA to FASTQ using fasterq-dump
    # Use TMPDIR if set, otherwise default to /tmp (bash parameter expansion)
    fasterq-dump \\
        ${sra_file} \\
        -e ${task.cpus} \\
        --split-spot \\
        --temp \${TMPDIR:-/tmp} \\
        --outdir . \\
        ${args1}

    COMPRESS_CMD="pigz"
    COMPRESS_ARGS="-p ${task.cpus} ${args2}"
    
    # Compress FASTQ files to .gz using parallel compression
    # Handle both single-end and paired-end reads
    if [ -f "\${SRA_BASE}.fastq" ]; then
        # Single-end reads
        \${COMPRESS_CMD} \${COMPRESS_ARGS} "\${SRA_BASE}.fastq"
    elif [ -f "\${SRA_BASE}_1.fastq" ] && [ -f "\${SRA_BASE}_2.fastq" ]; then
        # Paired-end reads - compress in parallel
        \${COMPRESS_CMD} \${COMPRESS_ARGS} "\${SRA_BASE}_1.fastq" &
        PID1=\$!
        \${COMPRESS_CMD} \${COMPRESS_ARGS} "\${SRA_BASE}_2.fastq" &
        PID2=\$!
        wait \$PID1
        wait \$PID2
    elif [ -f "\${SRA_BASE}_1.fastq" ]; then
        # Only read 1 found (shouldn't happen, but handle it)
        \${COMPRESS_CMD} \${COMPRESS_ARGS} "\${SRA_BASE}_1.fastq"
    else
        echo "ERROR: No FASTQ files generated from ${sra_file}" >&2
        exit 1
    fi
    
    # Verify at least one compressed file exists
    if [ ! -f "\${SRA_BASE}.fastq.gz" ] && [ ! -f "\${SRA_BASE}_1.fastq.gz" ]; then
        echo "ERROR: No compressed FASTQ files found after conversion" >&2
        exit 1
    fi

    # Delete original SRA (not the symlink) file after successful conversion (only runs after fasterq-dump completes successfully)
    # Resolve symlink before deletion
    ACTUAL_SRA_FILE=\$(readlink -f "${sra_file}" 2>/dev/null || realpath "${sra_file}" 2>/dev/null || echo "${sra_file}")
    rm -f "\${ACTUAL_SRA_FILE}"
    
    # Get version information
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
    fasterq-dump: \$( fasterq-dump --version | sed -e "s/fasterq-dump, version //g" )
    pigz: \$( pigz --version | sed -e "s/pigz //g" )
    END_VERSIONS
    """

    stub:
    """
    # Create a minimal valid gzip file for testing
    echo "@test_read" | gzip > "${sra_file.baseName}.fastq.gz" || touch "${sra_file.baseName}.fastq.gz"
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
    fasterq-dump: \$( fasterq-dump --version 2>/dev/null | sed -e "s/fasterq-dump, version //g" || echo "unknown" )
    pigz: \$( pigz --version 2>/dev/null | sed -e "s/pigz //g" || echo "unknown" )
    END_VERSIONS
    """
}

