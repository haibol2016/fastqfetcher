# Conditional Parameters in nf-core Launch Interface

This guide explains how to make parameters display conditionally in the `nf-core launch` interface using JSON Schema `if-then-else` constructs.

## JSON Schema Conditional Syntax

The `nextflow_schema.json` file uses JSON Schema Draft 2020-12, which supports conditional logic using `if`, `then`, and `else` keywords.

### Basic Structure

```json
{
  "properties": {
    "parameter_name": {
      "type": "string",
      "description": "..."
    }
  },
  "if": {
    "properties": {
      "condition_parameter": {
        "const": "expected_value"
      }
    }
  },
  "then": {
    "properties": {
      "conditional_parameter": {
        "type": "string",
        "description": "This parameter only shows when condition is met"
      }
    }
  }
}
```

## Example 1: Show `ngc_path` only when controlled-access data is needed

Add a boolean parameter `use_controlled_access` and show `ngc_path` conditionally:

```json
{
  "sra_toolkit_options": {
    "title": "SRA Toolkit options",
    "type": "object",
    "properties": {
      "use_controlled_access": {
        "type": "boolean",
        "description": "Download controlled-access SRA data (requires dbGaP key)",
        "default": false,
        "fa_icon": "fas fa-lock"
      },
      "ngc_path": {
        "type": "string",
        "format": "file-path",
        "description": "Path to dbGaP repository key (.ngc file)",
        "fa_icon": "fas fa-key"
      },
      "disk_limit": {
        "type": "string",
        "description": "Disk space limit for fasterq-dump",
        "pattern": "^\\d+(\\.\\d+)?\\s*(K|M|G|T)?B?$"
      }
    },
    "if": {
      "properties": {
        "use_controlled_access": {
          "const": true
        }
      }
    },
    "then": {
      "required": ["ngc_path"],
      "properties": {
        "ngc_path": {
          "type": "string",
          "format": "file-path",
          "description": "Path to dbGaP repository key (.ngc file) - REQUIRED for controlled-access data",
          "fa_icon": "fas fa-key"
        }
      }
    }
  }
}
```

## Example 2: Show MultiQC options only when MultiQC is enabled

```json
{
  "generic_options": {
    "title": "Generic options",
    "type": "object",
    "properties": {
      "run_multiqc": {
        "type": "boolean",
        "description": "Run MultiQC to generate quality control reports",
        "default": true,
        "fa_icon": "fas fa-chart-bar"
      },
      "multiqc_config": {
        "type": "string",
        "format": "file-path",
        "description": "Custom config file to supply to MultiQC",
        "fa_icon": "fas fa-cog"
      },
      "multiqc_logo": {
        "type": "string",
        "format": "file-path",
        "description": "Custom logo file for MultiQC",
        "fa_icon": "fas fa-image"
      }
    },
    "if": {
      "properties": {
        "run_multiqc": {
          "const": true
        }
      }
    },
    "then": {
      "properties": {
        "multiqc_config": {
          "type": "string",
          "format": "file-path",
          "description": "Custom config file to supply to MultiQC",
          "fa_icon": "fas fa-cog"
        },
        "multiqc_logo": {
          "type": "string",
          "format": "file-path",
          "description": "Custom logo file for MultiQC",
          "fa_icon": "fas fa-image"
        },
        "multiqc_title": {
          "type": "string",
          "description": "MultiQC report title",
          "fa_icon": "fas fa-file-signature"
        }
      }
    }
  }
}
```

## Example 3: Multiple conditions with `allOf`

Show parameters based on multiple conditions:

```json
{
  "sra_toolkit_options": {
    "type": "object",
    "properties": {
      "use_controlled_access": {
        "type": "boolean",
        "default": false
      },
      "custom_compression": {
        "type": "boolean",
        "default": false
      },
      "ngc_path": {
        "type": "string",
        "format": "file-path"
      },
      "pgzip_compress_level": {
        "type": "string",
        "pattern": "^[1-9]$",
        "default": "5"
      }
    },
    "allOf": [
      {
        "if": {
          "properties": {
            "use_controlled_access": { "const": true }
          }
        },
        "then": {
          "required": ["ngc_path"],
          "properties": {
            "ngc_path": {
              "type": "string",
              "format": "file-path",
              "description": "REQUIRED: Path to dbGaP repository key"
            }
          }
        }
      },
      {
        "if": {
          "properties": {
            "custom_compression": { "const": true }
          }
        },
        "then": {
          "properties": {
            "pgzip_compress_level": {
              "type": "string",
              "description": "Compression level (1-9). Higher = better compression but slower",
              "pattern": "^[1-9]$"
            }
          }
        }
      }
    ]
  }
}
```

## Example 4: Show `fasta` only when `genome` is not specified

```json
{
  "reference_genome_options": {
    "type": "object",
    "properties": {
      "genome": {
        "type": "string",
        "description": "Name of iGenomes reference"
      },
      "fasta": {
        "type": "string",
        "format": "file-path",
        "description": "Path to FASTA genome file"
      }
    },
    "if": {
      "properties": {
        "genome": {
          "const": null
        }
      }
    },
    "then": {
      "required": ["fasta"],
      "properties": {
        "fasta": {
          "type": "string",
          "format": "file-path",
          "description": "REQUIRED: Path to FASTA genome file (required when genome is not specified)"
        }
      }
    }
  }
}
```

## Example 5: Enum-based conditions

Show different parameters based on enum selection:

```json
{
  "analysis_options": {
    "type": "object",
    "properties": {
      "analysis_type": {
        "type": "string",
        "enum": ["standard", "advanced", "custom"],
        "default": "standard",
        "description": "Type of analysis to perform"
      },
      "custom_args": {
        "type": "string",
        "description": "Custom arguments"
      },
      "advanced_options": {
        "type": "object",
        "properties": {
          "option1": { "type": "string" },
          "option2": { "type": "string" }
        }
      }
    },
    "allOf": [
      {
        "if": {
          "properties": {
            "analysis_type": { "const": "custom" }
          }
        },
        "then": {
          "required": ["custom_args"],
          "properties": {
            "custom_args": {
              "type": "string",
              "description": "REQUIRED: Custom arguments for custom analysis"
            }
          }
        }
      },
      {
        "if": {
          "properties": {
            "analysis_type": { "const": "advanced" }
          }
        },
        "then": {
          "properties": {
            "advanced_options": {
              "type": "object",
              "description": "Advanced analysis options",
              "properties": {
                "option1": { "type": "string" },
                "option2": { "type": "string" }
              }
            }
          }
        }
      }
    ]
  }
}
```

## Key Points

1. **`if`**: Defines the condition (when to show/hide parameters)
2. **`then`**: Defines what happens when condition is true (show these parameters, make them required, etc.)
3. **`else`**: (Optional) Defines what happens when condition is false
4. **`allOf`**: Use when you have multiple independent conditions
5. **`const`**: Use for exact value matching (e.g., `"const": true` for boolean)
6. **`required`**: Can be used in `then` to make parameters mandatory when condition is met

## Testing

After updating your schema:

1. Validate the schema:
   ```bash
   nf-core schema validate nextflow_schema.json
   ```

2. Test the launch interface:
   ```bash
   nf-core launch .
   ```

3. Check that parameters appear/disappear based on your selections in the web interface.

## References

- [JSON Schema Draft 2020-12 - Conditional Schemas](https://json-schema.org/understanding-json-schema/reference/conditionals.html)
- [nf-core Schema Documentation](https://nf-co.re/docs/contributing/adding_pipelines/parameters)
- [nf-core Launch Tool](https://nf-co.re/docs/nf-core-tools/pipelines/launch)

