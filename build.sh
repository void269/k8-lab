#!/usr/bin/env bash

set -o pipefail

PLAN_FILE="plan.out"
TFVARS_FILE="my-variables.tfvars"
USE_TFVARS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --use-tfvars)
            USE_TFVARS=true
            shift
            ;;
        -h|--help)
            echo "Usage: ./build.sh [--use-tfvars]"
            echo
            echo "Options:"
            echo "  --use-tfvars    Use variables from my-variables.tfvars"
            echo "  -h, --help      Display this help message"
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option: $1"
            echo "Run './build.sh --help' for usage."
            exit 1
            ;;
    esac
done

echo "Initializing Terraform..."
terraform init

RETURN_CODE=$?

if [[ $RETURN_CODE -ne 0 ]]; then
    echo "ERROR: Terraform initialization failed."
    exit "$RETURN_CODE"
fi

echo
echo "Creating Terraform plan..."

if [[ "$USE_TFVARS" == true ]]; then
    if [[ ! -f "$TFVARS_FILE" ]]; then
        echo "ERROR: '$TFVARS_FILE' was not found."
        exit 1
    fi

    if [[ ! -s "$TFVARS_FILE" ]]; then
        echo "ERROR: '$TFVARS_FILE' is empty."
        echo "Add variable values to the file or run without --use-tfvars."
        exit 1
    fi

    echo "Using variable file: $TFVARS_FILE"
    echo

    terraform plan \
        -var-file="$TFVARS_FILE" \
        -out="$PLAN_FILE"
else
    echo "Using default values from variables.tf"
    echo

    terraform plan \
        -out="$PLAN_FILE"
fi

RETURN_CODE=$?

if [[ $RETURN_CODE -eq 0 ]]; then
    echo
    echo "Terraform plan created successfully: $PLAN_FILE"
else
    echo
    echo "ERROR: Terraform plan failed."
fi

exit "$RETURN_CODE"
```
