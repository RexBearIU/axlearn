#!/bin/bash

# Modified from https://paste.googleplex.com/4725192949235712

pod_prefix=jackyf-orbax-head-ici-data-1-20250718-102552   # Example: jobname-slice-job-1-0-
zone=us-east5-a

echo "Starting goodput test script at $(date)"
echo "Pod prefix: $pod_prefix"
echo "Zone: $zone"
echo "Will run for 12 hours, checking every hour"

# Loop for 12 hours.
for i in $(seq 1 12); do
    echo "Hour $i/12 - Sleeping for 1 hour..."
    # Sleep for one hour.
    sleep 3600
    
    echo "Hour $i/12 - Waking up at $(date)"
    echo "Searching for pods with prefix: $pod_prefix"
    
    # Find the node name associated with the first pod matching the prefix.
    # The query is limited to the first result `| head -n 1` to ensure only one node is targeted.
    node=$(kubectl get pods -A -o json | jq -r ".items[] | select(.metadata.name | startswith(\"$pod_prefix\")) | .spec.nodeName" | head -n 1)
    
    if [ -n "$node" ]; then
        # Shutdown the node.
        echo "Timestamp: $(date), shutting down node: $node"
        gcloud compute instances delete "$node" --zone="$zone" --quiet
        echo "Node deletion command executed for: $node"
    else
        echo "Timestamp: $(date), no node found for pod prefix '$pod_prefix'. Skipping shutdown for this hour."
    fi

done

echo "Goodput test script completed at $(date)"
