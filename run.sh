#!/bin/sh

jq="$WERCKER_STEP_ROOT/bin/jq"

extract_json_value() {
  local filter="$1"
  local file_path="$2"
  local extract=$("$jq" -r "$filter" "$file_path")
  echo "$extract"
}

main() {
  # skip the script on demand...
  if [ "$WERCKER_RUNSCOPE_BUCKET_TRIGGER_SKIP_TRIGGER" = "true" ]; then
    info "Skipping this step entirely."
  else
    # check if required tools are installed
    command -v curl >/dev/null 2>&1 || fail "Please install curl to execute this step."

    # check if runscope authentication token is present
    if [ "$WERCKER_RUNSCOPE_BUCKET_TRIGGER_SKIP_MONITORING" = "false" ]; then
      if [ -z "$WERCKER_RUNSCOPE_BUCKET_TRIGGER_ACCESS_TOKEN" ]; then
        fail "Please provide a Trigger Token for the bucket in order to monitor the execution."
      fi
    fi

    # check if runscope trigger_token is present
    if [ -z "$WERCKER_RUNSCOPE_BUCKET_TRIGGER_TRIGGER_TOKEN" ]; then
      fail "Please provide a Trigger Token for the bucket."
    fi

    # check if runscope environment uuid is present and fall back to default
    if [ -z "$WERCKER_RUNSCOPE_BUCKET_TRIGGER_ENVIRONMENT_UUID" ]; then
      info "No Runscope environment specified. Default environment for bucket will be used"
      RUNSCOPE_TRIGGER_URL="https://api.runscope.com/radar/$WERCKER_RUNSCOPE_BUCKET_TRIGGER_TRIGGER_TOKEN/trigger"
    else
      RUNSCOPE_TRIGGER_URL="https://api.runscope.com/radar/$WERCKER_RUNSCOPE_BUCKET_TRIGGER_TRIGGER_TOKEN/trigger?runscope_environment=$WERCKER_RUNSCOPE_BUCKET_TRIGGER_ENVIRONMENT_UUID"
    fi

    info "Initiating tests via $RUNSCOPE_TRIGGER_URL"
    TRIGGER_TESTS=$(curl -s -S "$RUNSCOPE_TRIGGER_URL" --output "$WERCKER_STEP_TEMP"/result.json -w "%{http_code}")

    if [ "$TRIGGER_TESTS" != "201" ]; then
      "$jq" -r "." "$WERCKER_STEP_TEMP/result.json"
      fail "Failed to start Runscope bucket tests."
    else
      if [ "$WERCKER_RUNSCOPE_BUCKET_TRIGGER_SKIP_MONITORING" = "true" ]; then
        TEST_RUN_URL=$(extract_json_value ".data.runs | .[0] | .test_run_url" "$WERCKER_STEP_TEMP/result.json")
        info "Skip waiting for test to complete."
        info "Please go directly to Runscope to see the results: $TEST_RUN_URL"
      else
        BUCKET_KEY=$(extract_json_value ".data.runs | .[0] | .bucket_key" "$WERCKER_STEP_TEMP/result.json")
        TEST_ID=$(extract_json_value ".data.runs | .[0] | .test_id" "$WERCKER_STEP_TEMP/result.json")
        TEST_RUN_ID=$(extract_json_value ".data.runs | .[0] | .test_run_id" "$WERCKER_STEP_TEMP/result.json")
        RUNSCOPE_TEST_MONTIOR_URL="https://api.runscope.com/buckets/$BUCKET_KEY/tests/$TEST_ID/results/$TEST_RUN_ID"

        info "Monitoring execution - this may take a moment"

        while true; do
          sleep 10
          REQUEST_STATUS=$(curl --header "Authorization: Bearer $WERCKER_RUNSCOPE_BUCKET_TRIGGER_ACCESS_TOKEN" --create-dirs -s -S "$RUNSCOPE_TEST_MONTIOR_URL" --output "$WERCKER_STEP_TEMP/tmp.json" -w "%{http_code}")

          if [ "$REQUEST_STATUS" = "200" ]; then
            RESULT=$(extract_json_value ".data.result" "$WERCKER_STEP_TEMP/tmp.json")
            if [ "$RESULT" = "working" ] || [ "$RESULT" = "queued" ]; then
              printf '.'
            else
              echo ""
              break
            fi
          else
            echo ""
            fail "curl request failed with $REQUEST_STATUS"
          fi
        done

        if [ "$RESULT" = "pass" ]; then
          success "Successfully executed tests on the Runscope bucket."
        else
          "$jq" -r "del(.data.requests)" "$WERCKER_STEP_TEMP/tmp.json"
          fail "Errors occured while executing the Runscope tests."
        fi
      fi
    fi
  fi
}

main;