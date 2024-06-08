#!/bin/bash

# Ensure the script has the correct executable permissions
chmod 777 $(pwd)
echo $(id -u):$(id -g)

# Run ZAP API scan with the correct Docker image
docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-stable zap-api-scan.py -t http://localhost:5000/v3/api-docs -f openapi -r zap_report.html

exit_code=$?

# HTML Report
mkdir -p owasp-zap-report
mv zap_report.html owasp-zap-report

echo "Exit Code : $exit_code"

if [[ ${exit_code} -ne 0 ]]; then
    echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
    exit 1
else
    echo "OWASP ZAP did not report any Risk"
fi
