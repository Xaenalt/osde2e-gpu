#!/bin/sh

export ARTIFACT_DIR="$(mktemp -d)"
pushd "${ARTIFACT_DIR}"
echo "$(pwd)"

TEST_RESULT_DIR='/test-run-results/'

exec 5>&1
RESULTS="$(/usr/bin/time -o ${ARTIFACT_DIR}/runtime -- bash -c '/usr/local/bin/run gpu-operator_test-master-branch 2>/dev/null | tee >(cat - >&5)' )"

SUCCESS_MSG='######################################
# The GPU Operator is up and running #
######################################'
ERROR_MSG='###############################################
# Found multiple errors with the GPU Operator #
###############################################'

RUNTIME="$(cat ${ARTIFACT_DIR}/runtime | egrep -o '[0-9]+:[0-9]+\.[0-9]+elapsed' | sed 's/elapsed//')"

cp "${HOME}/e2e/junit_template.xml" "${TEST_RESULT_DIR}/junit.xml"
sed -i 's/RUNTIME/'"${RUNTIME}"'/' "${TEST_RESULT_DIR}/junit.xml"
sed -i 's/TIMESTAMP/'"$(date -Is)"'/' "${TEST_RESULT_DIR}/junit.xml"
echo "attempting to write output"
echo "${RESULTS}" > "${TEST_RESULT_DIR}/test-log"

if echo "${RESULTS}" | grep "${SUCCESS_MSG}" &>/dev/null; then
  echo "Success"
  sed -i 's/NUM_ERRORS/0/g' "${TEST_RESULT_DIR}/junit.xml"
else
  echo "Failed"
  sed -i 's/NUM_ERRORS/1/g' "${TEST_RESULT_DIR}/junit.xml"
fi

if ls *gpu-operator* &>/dev/null; then
  echo "Copying detailed results to result directory"
  cp -r *gpu-operator* "${TEST_RESULT_DIR}/"
else
  echo "No results found, probably an error"
fi

popd
