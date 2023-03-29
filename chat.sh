#!/bin/bash
. functions.sh
check_and_set_args "$@"
echo "Welcome! This is a simple script using the OpenAI Chat API created by David Hinterndorfer."

while read -p "> " PROMPT
do
  curl_openai_with_context
done