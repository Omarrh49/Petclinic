#!/bin/bash

# Print user and group ID for the current environment
echo "Running as user: $(id -u):$(id -g)"

# Ensure current directory has appropriate permissions for Docker volume binding
chmod 777 $(pwd)

# Run ZAP API scan targeting the specified URL with OpenAPI format
docker run --rm -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-stable zap-api-scan.py \
    -t http://localhost:9099/petclinic/v3/api-docs -f openapi -r zap_report.html

# Capture the exit code from the ZAP scan
exit_code=$?

# Create directory for reports if it doesn't exist
mkdir -p owasp-zap-report

# Move the report to the created directory
mv zap_report.html owasp-zap-report/

# Print the exit code from the ZAP scan
echo "Exit Code: $exit_code"

# Check the exit code to determine if there were any risks reported
if [[ ${exit_code} -ne 0 ]]; then
    echo "OWASP ZAP reported risks. Please check the HTML report located at owasp-zap-report/zap_report.html"
    exit 1
else
    echo "OWASP ZAP did not report any risks."
fi
