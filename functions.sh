function usage() {
 echo "Usage: $0 --api_key {API-KEY} [OPTIONS]"
 echo ""
 echo "Options:"
 echo " --system_prompt"
 echo " --model"
 echo " --temperature"
 echo ""
}

function check_and_set_args() {
    while [ $# -gt 0 ]; do
        if [[ $1 == "--"* ]]; then
            name="${1/--/}"
            declare "$name"="$2"
            shift
        fi
        shift
    done

    if [[ -z $api_key ]]; then
        usage
        exit 1
    fi

    API_KEY=$api_key
    SYSTEM_PROMPT=${system_prompt:-"You are a friendly person."}
    MODEL=${model:-"gpt-3.5-turbo"}
    TEMPERATURE=${temperature:-0}
    ENDPOINT="https://api.openai.com/v1/chat/completions"
    MESSAGES=$(echo "[{\"role\": \"system\", \"content\": \"$SYSTEM_PROMPT\"}]")
}

function curl_openai_with_context {
    MESSAGES=$(echo $MESSAGES | jq -r --arg PROMPT "$PROMPT" '. + [{"role": "user", "content": $PROMPT}]')
    echo $MESSAGES
    RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "{ 
    \"model\": \"$MODEL\", 
    \"messages\": $MESSAGES,
    \"temperature\": $TEMPERATURE
    }" $ENDPOINT)
    # echo $RESPONSE

    echo $RESPONSE | jq -r '.choices[0].message.content'

    RESULT=$(echo $RESPONSE | jq -r '.choices[0].message.content')
    NEW_MESSAGE=$(echo $RESPONSE | jq -r '.choices[0].message')
    MESSAGES=$(echo $MESSAGES | jq -r --arg NEW_MESSAGE "$NEW_MESSAGE" '. + [{"role": "user", "content": $NEW_MESSAGE}]')
}