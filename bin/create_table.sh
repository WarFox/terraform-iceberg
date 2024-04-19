echo "Creating table ${TABLE_NAME}"

# print the sql
less ../resources/ddl/${TABLE_NAME}.sql

aws athena start-query-execution \
    --output json \
    --query-string file://../resources/ddl/${TABLE_NAME}.sql \
    --query-execution-context "Database=${DATABASE_NAME}" \
    --result-configuration "OutputLocation=s3://aws-athena-query-results-${ACCOUNT_ID}-${REGION}"
