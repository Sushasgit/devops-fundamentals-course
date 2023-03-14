#!/bin/bash

function help {
    echo "Usage: $0 [options] <input_file>"
    echo ""
    echo "Options:"
    echo "  --help                                Display this help message"
    echo "  --branch <branch_name>                Set the branch name for the Source stage"
    echo "  --owner <owner_name>                  Set the owner name for the Source stage"
    echo "  --repo <repo_name>                    Set the repository name for the Source stage"
    echo "  --poll-for-source-changes <true/false> Set the PollForSourceChanges parameter for the Source stage"
    echo "  --configuration <configuration_name>  Set the BUILD_CONFIGURATION environment variable for the Build stage"
    echo ""
    echo "Arguments:"
    echo "  <input_file>                           The path to the input JSON file"
}

if [ -z "$1" ]; then
    echo "Error: Please provide a file path as the first argument."
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File does not exist."
    exit 1
fi

INPUT_FILE="$1"

shift

NEW_BRANCH=""
NEW_OWNER=""
NEW_REPO=""
NEW_POLL_FOR_SOURCE_CHANGES=""
NEW_BUILD_CONFIGURATION=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help) help; exit 0 ;;
        --branch) NEW_BRANCH="$2"; shift ;;
        --owner) NEW_OWNER="$2"; shift ;;
        --repo) NEW_REPO="$2"; shift ;;
        --poll-for-source-changes) NEW_POLL_FOR_SOURCE_CHANGES=$(echo "$2" | tr '[:upper:]' '[:lower:]'); shift ;;
        --configuration) NEW_BUILD_CONFIGURATION="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if ! [ -x "$(command -v jq)" ]; then
    echo 'Error: jq is not installed.' >&2
    echo 'Installing jq...' >&2
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install jq
        elif [ -x "$(command -v brew)" ]; then
        brew install jq
    else
        echo 'Error: Package manager not found. Please install jq manually.' >&2
        exit 1
    fi
fi

if [[ -z "$NEW_BRANCH" ]]; then
    echo -n "Enter a GitHub branch name (default: develop): "
    read -r NEW_BRANCH
    if [[ "$NEW_BRANCH" == "" ]]; then
        NEW_BRANCH="develop"
    fi
fi

if [[ -z "$NEW_OWNER" ]]; then
    echo -n "Enter a GitHub owner/account: "
    read -r NEW_OWNER
fi

if [[ -z "$NEW_REPO" ]]; then
    echo -n "Enter a GitHub repository name: "
    read -r NEW_REPO
fi

if [[ -z "$NEW_POLL_FOR_SOURCE_CHANGES" ]]; then
    NEW_POLL_FOR_SOURCE_CHANGES_PROMPT=""
    while [[ "$NEW_POLL_FOR_SOURCE_CHANGES_PROMPT" != "yes" && "$NEW_POLL_FOR_SOURCE_CHANGES_PROMPT" != "no" ]]; do
        echo -n "Do you want the pipeline to poll for changes (yes/no) (default: no)?: "
        read -r NEW_POLL_FOR_SOURCE_CHANGES_PROMPT
    done
    if [[ "$NEW_POLL_FOR_SOURCE_CHANGES_PROMPT" == "yes" ]]; then
        NEW_POLL_FOR_SOURCE_CHANGES="true"
    else
        NEW_POLL_FOR_SOURCE_CHANGES="false"
    fi
fi

if [[ -z "$NEW_BUILD_CONFIGURATION" ]]; then
    echo -n "Which BUILD_CONFIGURATION name are you going to use (default: “”): "
    read -r NEW_BUILD_CONFIGURATION
fi

if ! jq -e '.pipeline.stages[0].actions[0].configuration | has("Branch") and has("Owner")' "$INPUT_FILE" > /dev/null; then
    echo "Error: Branch and Owner fields not found in the first stage."
    exit 1
fi

NEW_BRANCH="${NEW_BRANCH:-main}"

NEW_POLL_FOR_SOURCE_CHANGES="${NEW_POLL_FOR_SOURCE_CHANGES:-false}"
if [[ "$NEW_POLL_FOR_SOURCE_CHANGES" != "true" && "$NEW_POLL_FOR_SOURCE_CHANGES" != "false" ]]; then
    echo "Invalid parameter passed for PollForSourceChanges: $NEW_POLL_FOR_SOURCE_CHANGES"
    exit 1
fi

OUTPUT_FILE="pipeline-$(date +"%Y-%m-%d").json"


jq --arg branch "$NEW_BRANCH" --arg owner "$NEW_OWNER" --arg repo "$NEW_REPO" --argjson poll "$NEW_POLL_FOR_SOURCE_CHANGES" \
'walk(if type == "object" and has("Branch") then .Branch = $branch else . end |
         if ($owner | length) > 0 and type == "object" and has("Owner") then .Owner = $owner else . end |
         if ($repo | length) > 0 and type == "object" and has("Repo") then .Repo = $repo else . end |
         if type == "object" and has("PollForSourceChanges") then .PollForSource = $poll else . end |
if type == "object" and has("version") then .version = (.version | tonumber) + 1 else . end)' "$INPUT_FILE" \
| jq --arg configuration "$NEW_BUILD_CONFIGURATION" '.pipeline.stages[].actions[].configuration |=
        (if has("EnvironmentVariables")
         then (.EnvironmentVariables |=
               (fromjson | map(if .name == "BUILD_CONFIGURATION" then .value = $configuration else . end) | tojson))
         else .
end)' \
| jq 'del(.metadata)' \
> "$OUTPUT_FILE"
