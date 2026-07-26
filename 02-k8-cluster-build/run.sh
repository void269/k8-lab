#!/usr/bin/env bash

set -o pipefail

echo "Starting deployment..."


START_TIME=$(date +%s)

terraform apply plan.out
RETURN_CODE=$?

END_TIME=$(date +%s)
ELAPSED_SECONDS=$((END_TIME - START_TIME))

printf -v ELAPSED_TIME "%02d:%02d:%02d" \
    $((ELAPSED_SECONDS / 3600)) \
    $(((ELAPSED_SECONDS % 3600) / 60)) \
    $((ELAPSED_SECONDS % 60))



if [[ $RETURN_CODE -eq 0 ]]; then
    CONTROL_PLANE_IP=$(
        terraform output -raw control_plane_public_ip 2>/dev/null
    )

    CONTROL_PLANE_SSH=$(
        terraform output -raw control_plane_ssh_command 2>/dev/null
    )

    echo "Deployment completed successfully."
    echo

    printf "%-22s %s\n" "Elapsed Time:" "$ELAPSED_TIME"
    printf "%-22s %s\n" "Control Plane IP:" "$CONTROL_PLANE_IP"

    echo
    echo "SSH:"
    echo "$CONTROL_PLANE_SSH"
else
    echo "Deployment failed."
    echo

    printf "%-22s %s\n" "Elapsed Time:" "$ELAPSED_TIME"
    printf "%-22s %s\n" "Exit Code:" "$RETURN_CODE"

    echo
    echo "Review the Terraform output above for details."
fi

exit "$RETURN_CODE"