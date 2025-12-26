# Workflow Diagram Specification (Based on Hand-Drawn Diagram)

This document provides a detailed specification for recreating the workflow diagram based on your hand-drawn version.

## Workflow Structure

### Input Section (Top)
Three input formats should be shown:

1. **① SRA Run ID** (Single ID)
   - Example: `"SRRnnnnn"`
   - Format: Single SRA accession ID

2. **② File containing list of SRA run IDs**
   - Format: Text file with one SRA ID per line
   - Example: `srr.accessions.txt`

3. **③ Comma-separated SRA IDs**
   - Format: `"SRRnnnnn, SRRnnnnn"`
   - Multiple IDs separated by commas

### Main Workflow Path (Vertical Flow)

```
Input (SRA IDs)
    ↓
[SRA-PREFETCH]
    ↓
[SRAtools fasterq-dump & Pigz]
    ↓
[FastQC]
    ↓
[MultiQC]
    ↓
Output: MultiQC Report
```

## Detailed Component Specifications

### 1. Input Node
- **Type**: Input component (rectangle or input node from nf-core library)
- **Labels**:
  - Main: "SRA Run IDs"
  - Sub-labels:
    - ① Single ID: `"SRRnnnnn"`
    - ② File: `"file containing list of SRA run IDs"`
    - ③ Comma-separated: `"SRRnnnnn, SRRnnnnn"`

### 2. SRA-PREFETCH Process
- **Type**: Process node (oval/rounded rectangle)
- **Label**: `SRA-PREFETCH`
- **Description**: Downloads SRA files from NCBI
- **Tool**: ncbi/sra-tools prefetch

### 3. SRAtools fasterq-dump & Pigz Process
- **Type**: Process node (oval/rounded rectangle)
- **Label**: `SRAtools fasterq-dump & Pigz`
- **Description**: Converts SRA files to compressed FASTQ format
- **Tools**: 
  - fasterq-dump (from ncbi/sra-tools)
  - pigz (parallel compression)

### 4. FastQC Process
- **Type**: Process node (oval/rounded rectangle)
- **Label**: `FastQC`
- **Description**: Performs quality control on FASTQ files
- **Tool**: FastQC

### 5. MultiQC Process
- **Type**: Process node (oval/rounded rectangle)
- **Label**: `MultiQC`
- **Description**: Aggregates FastQC results into a single report
- **Tool**: MultiQC

### 6. Output Node
- **Type**: Output component (rectangle or output node)
- **Label**: `MultiQC Report`
- **Description**: Final aggregated quality control report

## Visual Layout Guidelines

### Flow Direction
- **Primary flow**: Top to bottom (vertical)
- **Inputs**: Top-left area
- **Main workflow**: Center vertical line
- **Output**: Bottom-right

### Node Shapes
- **Inputs**: Rectangles
- **Processes**: Ovals/rounded rectangles
- **Output**: Small solid rectangle

### Connections
- Use arrows to show data flow
- Sequential flow: Each process connects to the next
- Single main path (no branching shown in hand-drawn version)

## Text Labels

All text should be clear and readable:
- Process names: Bold or emphasized
- Tool names: Include full tool names where relevant
- Examples: Use placeholder format like `SRRnnnnn`

## Color Scheme (nf-core Guidelines)

- Follow nf-core color palette
- Use consistent colors for:
  - Input nodes
  - Process nodes
  - Output nodes
- Ensure good contrast for readability

## Implementation Steps for draw.io

1. **Set up canvas**: Vertical orientation, sufficient height
2. **Add input section**: Top-left, show all three input formats
3. **Create main workflow path**: Center vertical line
4. **Add process nodes**: 
   - SRA-PREFETCH
   - SRAtools fasterq-dump & Pigz
   - FastQC
   - MultiQC
5. **Add output node**: Bottom-right
6. **Connect with arrows**: Sequential flow from top to bottom
7. **Style and align**: Use nf-core components library
8. **Export**: PNG or SVG format

## Notes from Hand-Drawn Diagram

- Simple, linear workflow (no branching)
- Clear sequential steps
- Input variations shown at the top
- Single output at the end
- Clean, easy-to-follow layout

## Additional Outputs (Not Shown in Hand-Drawn, but Available)

While your hand-drawn diagram shows only the MultiQC report as output, the pipeline also produces:
- FASTQ.gz files (from fasterq-dump)
- FastQC HTML reports (individual per sample)
- FastQC ZIP files (data files)

You may want to add these as additional output branches if desired, or keep it simple as shown in your hand-drawn version.


