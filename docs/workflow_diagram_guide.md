# Workflow Diagram (Tubemap) Generation Guide

This guide explains how to create a workflow diagram (tubemap/metro map style) for the fastqfetcher pipeline, following nf-core design guidelines.

## Overview

The fastqfetcher pipeline workflow consists of:

1. **Input**: SRA accession IDs (single ID, comma-separated, or file)
2. **SRA2FASTQ subworkflow**:
   - `SRA_PREFETCH`: Downloads SRA files from NCBI
   - `SRA_FASTERQDUMP`: Converts SRA files to compressed FASTQ format
3. **FASTQ_MULTIQC subworkflow**:
   - `FASTQC`: Performs quality control on FASTQ files
   - `MULTIQC`: Aggregates FastQC results into a single report
4. **Output**: FASTQ.gz files, FastQC reports, and MultiQC report

## Method 1: Using draw.io (Recommended)

### Step 1: Open draw.io
1. Go to [https://app.diagrams.net/](https://app.diagrams.net/) (or use the desktop app)
2. Create a new diagram

### Step 2: Import nf-core Components Library
1. In draw.io, go to **File** > **Open Library from** > **URL...**
2. Paste the following URL:
   ```
   https://raw.githubusercontent.com/nf-core/website/refs/heads/main/sites/docs/src/assets/images/graphic_design_assets/workflow_schematics_components/generic/nf-core_components.xml
   ```
3. Click **Open** - this will load the nf-core components into your library panel

### Step 3: Design Your Workflow Diagram
1. **Add Input Node**: Drag an "Input" component from the nf-core library
   - Label: "SRA IDs"
   - Description: "SRR accession IDs"

2. **Add Process Nodes**: 
   - Drag "Process" components for each tool:
     - `SRA_PREFETCH` (downloads SRA files)
     - `SRA_FASTERQDUMP` (converts to FASTQ)
     - `FASTQC` (quality control)
     - `MULTIQC` (aggregate reports)

3. **Add Output Nodes**:
   - Drag "Output" components for:
     - `FASTQ.gz files`
     - `FastQC reports`
     - `MultiQC report`

4. **Connect Nodes**: Use the connector tool to link nodes in sequence:
   - SRA IDs → SRA_PREFETCH → SRA_FASTERQDUMP → FASTQC → MULTIQC
   - Branch outputs from SRA_FASTERQDUMP to FASTQ.gz files
   - Branch outputs from FASTQC to FastQC reports
   - Connect MULTIQC to MultiQC report

5. **Style the Diagram**:
   - Follow nf-core color scheme (see [design guidelines](https://nf-co.re/docs/guidelines/graphic_design/overview))
   - Use consistent spacing and alignment
   - Add labels and descriptions where helpful

### Step 4: Export the Diagram
1. Go to **File** > **Export as** > **PNG** (or **SVG** for vector format)
2. Save to `docs/images/workflow_diagram.png` (or `.svg`)
3. For web use, also export a dark mode version if needed

## Method 2: Using Inkscape

1. Download Inkscape from [https://inkscape.org/](https://inkscape.org/)
2. Download nf-core components from the [nf-core website](https://nf-co.re/docs/guidelines/graphic_design/workflow_diagrams)
3. Import components into Inkscape
4. Follow similar design steps as Method 1
5. Export as PNG or SVG

## Method 3: Using Adobe Illustrator

1. Download nf-core components (PDF format available)
2. Open in Adobe Illustrator
3. Design your workflow following nf-core guidelines
4. Export as PNG or SVG

## Workflow Structure Reference

```
Input (SRA IDs)
    ↓
[SRA_PREFETCH] → Downloads .sra files
    ↓
[SRA_FASTERQDUMP] → Converts to .fastq.gz
    ↓
[FASTQC] → Quality control
    ↓
[MULTIQC] → Aggregate reports
    ↓
Outputs:
  - FASTQ.gz files
  - FastQC HTML reports
  - MultiQC report
```

## Design Guidelines

- Use nf-core color palette (see [design guidelines](https://nf-co.re/docs/guidelines/graphic_design/overview))
- Keep the diagram simple and easy to follow
- Use consistent node shapes and sizes
- Include tool names clearly
- Show data flow direction with arrows
- Consider both light and dark mode versions

## Resources

- [nf-core Workflow Diagrams Documentation](https://nf-co.re/docs/guidelines/graphic_design/workflow_diagrams)
- [nf-core Graphic Design Overview](https://nf-co.re/docs/guidelines/graphic_design/overview)
- [nf-core Components Library](https://raw.githubusercontent.com/nf-core/website/refs/heads/main/sites/docs/src/assets/images/graphic_design_assets/workflow_schematics_components/generic/nf-core_components.xml)

## Example Workflow Diagram Locations

Once created, save your workflow diagram to:
- `docs/images/workflow_diagram.png` (or `.svg`)
- Reference it in the README.md file


