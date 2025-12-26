<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/haibol2016-fastqfetcher_logo_dark.png">
    <img alt="haibol2016/fastqfetcher" src="docs/images/haibol2016-fastqfetcher_logo_light.png">
  </picture>
</h1>

[![GitHub Actions CI Status](https://github.com/haibol2016/fastqfetcher/actions/workflows/nf-test.yml/badge.svg)](https://github.com/haibol2016/fastqfetcher/actions/workflows/nf-test.yml)
[![GitHub Actions Linting Status](https://github.com/haibol2016/fastqfetcher/actions/workflows/linting.yml/badge.svg)](https://github.com/haibol2016/fastqfetcher/actions/workflows/linting.yml)[![AWS CI](https://img.shields.io/badge/CI%20tests-full%20size-FF9900?labelColor=000000&logo=Amazon%20AWS)](https://github.com/haibol2016/fastqfetcher/results)[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)
[![nf-test](https://img.shields.io/badge/unit_tests-nf--test-337ab7.svg)](https://www.nf-test.com)

[![Nextflow](https://img.shields.io/badge/version-%E2%89%A525.10.2-green?style=flat&logo=nextflow&logoColor=white&color=%230DC09D&link=https%3A%2F%2Fnextflow.io)](https://www.nextflow.io/)
[![nf-core template version](https://img.shields.io/badge/nf--core_template-3.3.2-green?style=flat&logo=nfcore&logoColor=white&color=%2324B064&link=https%3A%2F%2Fnf-co.re)](https://github.com/nf-core/tools/releases/tag/3.3.2)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Seqera Platform](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Seqera%20Platform-%234256e7)](https://cloud.seqera.io/launch?pipeline=https://github.com/haibol2016/fastqfetcher)

[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23fastqfetcher-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/fastqfetcher)[![Follow on Bluesky](https://img.shields.io/badge/bluesky-%40nf__core-1185fe?labelColor=000000&logo=bluesky)](https://bsky.app/profile/nf-co.re)[![Follow on Mastodon](https://img.shields.io/badge/mastodon-nf__core-6364ff?labelColor=FFFFFF&logo=mastodon)](https://mstdn.science/@nf_core)[![Watch on YouTube](http://img.shields.io/badge/youtube-nf--core-FF0000?labelColor=000000&logo=youtube)](https://www.youtube.com/c/nf-core)

## Introduction

**haibol2016/fastqfetcher** is a bioinformatics pipeline that can be used to download NGS fastq files from Short Read Archive (SRA) and perform FastQC/MultiQC. It takes one SRA run accession (such as SRR36455892), multiple comma-separated SRA run accessions, or a text file with one SRA run accession per line as input. It downloads **.sra files**, converts .sra files to **.fastq files**, which are further compressed into **.fastq.gz files**, performs raw read quality control and generates a friendly report using FastQC and MultiQC.

<img src="docs/images/workflow_diagram.svg" alt="Workflow diagram" width="600"/>

The pipeline is built using [Nextflow](https://www.nextflow.io), processes data using the following steps:

1. **SRA Download** - Downloads SRA files from NCBI using `prefetch` of [`ncbi/sra-tools`](https://github.com/ncbi/sra-tools)
2. **SRA to FASTQ Conversion** - Converts SRA files to parallel compressed FASTQ format using `fasterq-dump` of [`ncbi/sra-tools`](https://github.com/ncbi/sra-tools) and [`pigz`](https://zlib.net/pigz/)
3. **Read QC** - Performs quality control using [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
4. **Aggregate QC Reports** - Presents QC results for raw reads using [`MultiQC`](http://multiqc.info/)

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

### Specify input
#### Option 1: provide a file containing SRA run accessions
First, prepare a list of SRA run accessions of interest that looks as follows:

`srr.accessions.txt`:

```txt
SRR13255544
SRR36447178
SRR36432525
SRR33368650
```

Each row represents a single SRA run accession.

Now, you can run the pipeline using:

```bash
nextflow run haibol2016/fastqfetcher \
   -profile <docker/singularity/.../institute> \
   --input srr.accessions.txt \
   --outdir work
```

#### Option 2: Input SRA run accessions from command line

Another way to specify input is to provide SRA run accessions directly through the command line as a string. Multiple run accessions must be separated by commas. For example, you can run the pipeline as follows:

```bash
nextflow run haibol2016/fastqfetcher \
   -profile <docker/singularity/.../institute> \
   --input  SRR13255544,SRR36447178,SRR36432525,SRR33368650 \
   --outdir work
```

or, if you only have one run accession:

```bash
nextflow run haibol2016/fastqfetcher \
   -profile <docker/singularity/.../institute> \
   --input  SRR13255544  \
   --outdir work
```

### Download access controlled data from dbGaP

The pipeline supports downloading controlled-access SRA data from [dbGaP](https://www.ncbi.nlm.nih.gov/gap/) (Database of Genotypes and Phenotypes) using your dbGaP repository key.

#### Step 1: Obtain your dbGaP repository key (.ngc file)

1. **Request access** to the dbGaP dataset you need through the [dbGaP website](https://www.ncbi.nlm.nih.gov/gap/)
2. **Download your repository key**:
   - Log in to your dbGaP account
   - Navigate to your authorized studies
   - Download the repository key file (`.ngc` file)
   - This file contains your authentication credentials for accessing controlled-access data

#### Step 2: Provide the .ngc file path to the pipeline

Use the `--ngc_path` parameter to specify the path to your dbGaP repository key file:

```bash
nextflow run haibol2016/fastqfetcher \
   -profile <docker/singularity/.../institute> \
   --input srr.accessions.txt \
   --ngc_path /path/to/your/prj_XXXXX.ngc \
   --outdir work
```

Or with comma-separated SRA IDs:

```bash
nextflow run haibol2016/fastqfetcher \
   -profile <docker/singularity/.../institute> \
   --input SRR13255544,SRR36447178 \
   --ngc_path /path/to/your/prj_XXXXX.ngc \
   --outdir work
```

#### Important Notes

- The `.ngc` file must be accessible from within the container/environment where the pipeline runs
- For Docker/Singularity profiles, ensure the `.ngc` file path is mounted or accessible within the container
- The repository key is automatically passed to both `prefetch` and `fasterq-dump` commands when `--ngc_path` is specified
- Make sure you have proper authorization for the SRA accessions you're trying to download

#### Example with Docker

```bash
# Mount the directory containing your .ngc file
nextflow run haibol2016/fastqfetcher \
   -profile docker \
   --input srr.accessions.txt \
   --ngc_path /absolute/path/to/prj_XXXXX.ngc \
   --outdir work
```

### Create a pipeline parameters file

Instead of specifying all parameters on the command line, you can create a parameters file (YAML or JSON format) to store your pipeline configuration. This is especially useful for complex runs or when you want to reuse the same parameters across multiple runs.

#### Method 1: Using nf-core launch (Interactive Web Interface)

The easiest way to create a parameters file is using the nf-core launch tool, which provides an interactive web interface:

1. **Install nf-core tools** (if not already installed):

   ```bash
   pip install nf-core
   ```

2. **Launch the interactive parameter interface**:

   ```bash
   nf-core launch haibol2016/fastqfetcher
   ```

   This will:
   - Open an interactive web interface in your browser
   - Show all available parameters with descriptions
   - Allow you to fill in values for each parameter
   - Generate a `params.json` or `params.yaml` file that you can save

3. **Use the generated parameters file**:

   ```bash
   nextflow run haibol2016/fastqfetcher \
      -profile docker \
      -params-file params.yaml \
      --outdir results
   ```

#### Method 2: Using nf-core launch (Web-based)

Alternatively, you can use the web-based launch tool:

1. Visit [https://nf-co.re/launch](https://nf-co.re/launch)
2. Search for `haibol2016/fastqfetcher`
3. Fill in the parameters interactively
4. Download the generated `params.json` or `params.yaml` file
5. Use it with `-params-file params.yaml`

#### Method 3: Manual Creation

You can also create a parameters file manually. Here's an example `params.yaml`:

```yaml
input: 'srr.accessions.txt'
outdir: './results'
ngc_path: '/path/to/prj_XXXXX.ngc'  # Optional: for dbGaP data
max_size: '50G'                      # Optional: max download size
disk_limit: '100G'                   # Optional: disk limit for conversion
pgzip_compress_level: '5'            # Optional: compression level (1-9)
```

Then run the pipeline with:

```bash
nextflow run haibol2016/fastqfetcher \
   -profile docker \
   -params-file params.yaml
```

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_; see [docs](https://nf-co.re/docs/usage/getting_started/configuration#custom-configuration-files).

>[!WARNING]
> The `disk_limit` parameter controls the maximum disk space that fasterq-dump can use during FASTQ conversion. If not specified, it defaults to the memory size allocated to the process. For large SRA files, ensure you set `disk_limit` to a value sufficient to handle the conversion (typically 2-3x the size of the SRA file). Insufficient disk space may cause the conversion to fail. For instance:

```bash
nextflow run haibol2016/fastqfetcher \
   -profile docker \
   --input SRR13255544 \
   --disk_limit 128G \
   --outdir ./results
```

For more details and further functionality, please refer to the [usage documentation](docs/usage.md) and the [parameter documentation](https://github.com/haibol2016/fastqfetcher/blob/main/nextflow_schema.json).

## Pipeline output

For more details about the output files and reports, please refer to the
[output documentation](docs/output.md).

## Credits

haibol2016/fastqfetcher was originally written by Haibo Liu.

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use haibol2016/fastqfetcher for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
