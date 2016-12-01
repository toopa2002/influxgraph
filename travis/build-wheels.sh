#!/bin/bash
set -e -x

yum install -y libffi-devel

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    ${PYBIN}/pip install -U pip setuptools wheel
    ${PYBIN}/pip install nose
    ${PYBIN}/pip wheel /io/ -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair $whl -w /io/wheelhouse/ || echo "skipping pure wheel"
done

# Install packages and test
for PYBIN in /opt/python/*/bin/; do
    ${PYBIN}/pip install influxgraph --no-index -f /io/wheelhouse
    (cd $HOME; ${PYBIN}/nosetests influxgraph)
done
