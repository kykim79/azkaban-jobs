#!/bin/bash -x
  # ${JOB_PROP_FILE} is always defined and exist so this check should always pass
if [ -n ${JOB_PROP_FILE} ] && [ -e ${JOB_PROP_FILE} ]; then
  # variable value can also be parsed by the following statement. It returns the value part of validate_erros=value
  #. ${JOB_{PROP_FILE}
  INPUT_BASE_DIR=$(grep -Po "(?<=^input.base.dir=).*" $JOB_PROP_FILE)
  VALIDATE_ERRORS=$(grep -Po "(?<=^validate_errors=).*" $JOB_PROP_FILE)
  ERRORS_BASE_DIR=$(grep -Po "(?<=^errors.base.dir=).*" $JOB_PROP_FILE)
fi

if [ -z ${INPUT_BASE_DIR} ]; then
  echo "No property called input.base.dir defined. Exiting"
  exit 1
fi

if [ -n "${VALIDATE_ERRORS}" ] && [ "${VALIDATE_ERRORS}" == "true" ]; then 
  echo "Errors found"
  if [ -z ${ERRORS_BASE_DIR} ]; then
    echo "No property called errors.base.dir defined. Exiting"
    exit 1
  fi
  java  -Xms64M -Xmx256M com.hadooparchitecturebook.MoveOutputToErrorsAction \
  ${INPUT_BASE_DIR} ${ERRORS_BASE_DIR}
else
  echo "No errors found"
  java -Xms64M -Xmx256M -Dinput.dir=${INPUT_BASE_DIR}/dataset com.hadooparchitecturebook.ProcessDataRunner \
  wordcount /user/hive/warehouse/table1/data.txt /tmp/wordcount
fi
