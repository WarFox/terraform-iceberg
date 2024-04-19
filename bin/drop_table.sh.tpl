echo "Droping table ${table_name} from database ${database_name} in Athena"

aws athena start-query-execution \
      --output json \
      --query-string "DROP TABLE IF EXISTS ${table_name};" \
      --query-execution-context "Database=${database_name}" \
      --result-configuration "OutputLocation=s3://aws-athena-query-results-${account_id}-${region}"
