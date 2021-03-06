#! /bin/bash -e

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${THIS_DIR}/../_common.sh

if [ "$#" -gt 1 ]; then
    echo "FATAL: expected 0 or 1 parameter ... (got $#: '$@')"
    echo "Usage: $0 [matrix-mult GPU]"
    exit 1
elif [ "$#" -eq 1 ]; then
    ANSIBLE_OPTS="${ANSIBLE_OPTS} -e matrix_mult_time=$1"
    echo "Running MLPerf Matrix Multiply for ${1} seconds."
fi

exec ansible-playbook ${ANSIBLE_OPTS} playbooks/gpu_operator_run_matrix-mult.yml
