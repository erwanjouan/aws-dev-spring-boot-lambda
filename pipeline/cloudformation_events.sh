#!/bin/bash

cf_stack_status() {
  echo $(aws cloudformation describe-stacks --stack-name $1 --query "Stacks[0].StackStatus" --output text || echo "REVIEW_IN_PROGRESS")
}

dump_cf_events(){
  echo "$(aws cloudformation describe-stack-events --stack-name $1 | jq -r '.StackEvents[] | [.Timestamp, .LogicalResourceId, .ResourceType, .ResourceStatus] | @tsv')"
}

STACK_STATUS=$(cf_stack_status $1)

sleep 5

while [ "${STACK_STATUS}" = "REVIEW_IN_PROGRESS" ] || [ "${STACK_STATUS}" = "CREATE_IN_PROGRESS" ]
do
  CF_EVENTS=$(dump_cf_events $1)
  clear
  echo "${CF_EVENTS}"
  sleep 5
  STACK_STATUS=$(cf_stack_status $1)
done

if [ "${STACK_STATUS}" = "UPDATE_ROLLBACK_COMPLETE" ] ||  [ "${STACK_STATUS}" = "ROLLBACK_COMPLETE" ]
then
  echo "stopping update, stack is in status ${STACK_STATUS}"
  echo "deleting $1"
  aws cloudformation delete-stack --stack-name $1 || true
  exit 1
fi
