# Main Pipeline: SRA to FASTQ Conversion

This is the main Nextflow pipeline for downloading SRA data from NCBI, converting it to compressed FASTQ format, and automatically cleaning up SRA files to save disk space.

## Overview

The `main.nf` pipeline performs a complete end-to-end workflow:

1. **Download** - Downloads SRA files from NCBI using `prefetch` (SRA Toolkit)
2. **Convert** - Converts SRA files to compressed FASTQ.gz format using `fasterq-dump`
3. **Cleanup** - Automatically deletes SRA files after successful conversion

## Prerequisites

- **Nextflow** (>= 22.04.0)
- **SRA Toolkit** - Automatically handled via container (Singularity/Docker)
- **Container engine** - Singularity or Docker (for running SRA Toolkit)

## Quick Start

### Basic Usage

```bash
# Download and convert a single SRA ID
nextflow run main.nf --sra_id SRR123456

# Download and convert multiple SRA IDs (comma-separated)
nextflow run main.nf --sra_ids SRR123456,SRR123457,SRR123458

# Download and convert from a file (one SRA ID per line)
nextflow run main.nf --sra_ids_file sra_ids.txt
```

### Example SRA IDs File

Create a text file (`sra_ids.txt`) with one SRA ID per line:

```
SRR123456
SRR123457
SRR123458
# Comments starting with # are ignored
```

## Parameters

### Required Parameters (choose one)

- `--sra_id`: Single SRA accession ID (e.g., `SRR123456`, `SRX123456`, `SRP123456`)
- `--sra_ids`: Comma-separated list of SRA IDs (e.g., `SRR123456,SRR123457`)
- `--sra_ids_file`: Path to a text file containing SRA IDs (one per line)

### Optional Parameters

#### Prefetch Parameters

- `--max_size`: Maximum file size to download (e.g., `50G`, `500M`, `1T`)
  - Default: No limit
  - Example: `--max_size 50G`

- `--sra_output_dir`: Output directory for prefetched SRA files
  - Default: Work directory
  - Example: `--sra_output_dir ./sra_data`

- `--extra_args`: Additional arguments to pass to `prefetch` command
  - Default: Empty
  - Example: `--extra_args "--transport ascp"`

#### Fasterq-dump Parameters

- `--threads`: Number of threads to use for conversion and compression
  - Default: `4`
  - Example: `--threads 8`

- `--split_files`: Split paired-end reads into separate files
  - Default: `true`
  - Options: `true` or `false`
  - When `true`: Creates `*_1.fastq.gz` and `*_2.fastq.gz` for paired-end reads
  - When `false`: Creates single `*.fastq.gz` file

- `--split_spot`: Split spots into separate files
  - Default: `false`
  - Options: `true` or `false`

- `--extra_fasterq_args`: Additional arguments to pass to `fasterq-dump` command
  - Default: Empty
  - Example: `--extra_fasterq_args "--include-technical"`

#### Cleanup Parameters

- `--dry_run`: Preview deletion without actually deleting SRA files
  - Default: `false`
  - Options: `true` or `false`
  - When `true`: Shows what would be deleted but doesn't delete files
  - When `false`: Deletes SRA files after successful conversion

#### General Parameters

- `--outdir`: Output directory for Nextflow results
  - Default: `./results`
  - Example: `--outdir /path/to/results`

## Advanced Examples

### High-Performance Conversion

```bash
# Use 16 threads for faster processing
nextflow run main.nf \
  --sra_ids SRR123456,SRR123457 \
  --threads 16 \
  --max_size 100G
```

### Single-End Reads

```bash
# Don't split paired-end reads (for single-end data)
nextflow run main.nf \
  --sra_id SRR123456 \
  --split_files false
```

### Preview Mode (Dry Run)

```bash
# See what would be deleted without actually deleting
nextflow run main.nf \
  --sra_id SRR123456 \
  --dry_run true
```

### Custom Output Directory

```bash
# Specify custom output directory
nextflow run main.nf \
  --sra_id SRR123456 \
  --outdir /path/to/my/results \
  --sra_output_dir /path/to/sra/files
```

### Large Dataset Processing

```bash
# Process many SRA IDs from a file with custom settings
nextflow run main.nf \
  --sra_ids_file large_dataset.txt \
  --threads 8 \
  --max_size 200G \
  --outdir ./large_dataset_results
```

## Output Structure

The pipeline generates the following output structure:

```
results/
├── fastq/                    # Compressed FASTQ files
│   ├── SRR123456_1.fastq.gz
│   ├── SRR123456_2.fastq.gz
│   └── SRR123457.fastq.gz
├── sra_prefetch/             # SRA files (before deletion)
│   └── SRR123456.sra
└── work/                     # Nextflow work directory
    └── [process-specific directories]
```

**Note**: SRA files in `sra_prefetch/` are automatically deleted after successful conversion (unless `--dry_run true` is used).

## Workflow Details

### Step 1: Prefetch (Download)

- Downloads SRA files from NCBI using the SRA Toolkit `prefetch` command
- Files are downloaded to the work directory or specified `--sra_output_dir`
- Supports size limits via `--max_size` parameter

### Step 2: Fasterq-dump (Conversion)

- Converts SRA files to FASTQ format using `fasterq-dump`
- Automatically compresses output to `.fastq.gz` format
- Uses parallel compression tools (pgzip/pigz) when available for faster processing
- Supports both single-end and paired-end reads

### Step 3: Delete (Cleanup)

- Automatically deletes SRA files after successful FASTQ conversion
- Only deletes if conversion completed successfully
- Generates deletion logs for tracking
- Can be previewed with `--dry_run true` parameter

## Error Handling

- The pipeline will stop if any step fails
- SRA files are **only deleted** after successful FASTQ conversion
- If conversion fails, SRA files are preserved for troubleshooting
- Check Nextflow logs in `work/` directory for detailed error messages

## Container Support

The pipeline uses containers for reproducibility:

- **Singularity**: Automatically pulls from Galaxy Project depot
- **Docker**: Uses Quay.io biocontainers
- Container engine is automatically detected

## Tips

1. **Disk Space**: SRA files can be large. Ensure you have enough disk space before running.
2. **Network**: Downloads can be slow. Consider using `--transport ascp` for faster downloads (requires Aspera Connect).
3. **Threads**: More threads speed up conversion but use more CPU/memory.
4. **Dry Run**: Always test with `--dry_run true` first if you're unsure about deletion behavior.
5. **File Lists**: Use `--sra_ids_file` for processing many samples at once.

## Troubleshooting

### Download Fails

- Check your internet connection
- Verify SRA ID is correct and accessible
- Try increasing `--max_size` if file is larger than expected

### Conversion Fails

- Check that SRA file downloaded successfully
- Verify disk space is available
- Check Nextflow logs for specific error messages

### Deletion Issues

- Use `--dry_run true` to preview what would be deleted
- Check deletion logs in output directory
- Ensure FASTQ conversion completed successfully before deletion

## Version Information

The pipeline automatically tracks software versions and outputs them to `versions.yml` files in the results directory.

## Support

For issues or questions:
- Check Nextflow logs in the `work/` directory
- Review the individual module documentation
- Ensure all prerequisites are installed correctly
