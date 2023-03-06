#!/bin/bash

FILE="../data/users.db"

is_latin() {
  if [[ "$1" =~ ^[a-zA-Z]+$ ]]; then
    return 0
  else
    return 1
  fi
}

prompt_line() {
  while true; do
    read -p "Enter a line to add to the file (Latin letters only): " LINE
    if is_latin "$LINE"; then
      break
    else
      echo "Line can only contain Latin letters."
    fi
  done
  echo "$LINE"
}

print_file() {
  if [ "$1" == "--inverse" ]; then
    echo "Printing $FILE in reverse:"
    tac "$FILE" | awk '{a[NR]=$0}END{for (i=1;i<=NR;i++) print NR-i+1": "a[i]}'
  else
    echo "Printing $FILE line by line:"
    cat "$FILE" | awk '{print NR": "$0}'
  fi
}

find_line() {
  read -p "Enter a user name to search for: " USER

  if grep -q "^$USER," "$FILE"; then
    grep "^$USER," "$FILE"
  else
    echo "User not found."
  fi
}

help_command () {
  echo "Available options:"
  echo "add: Add two lines of Latin letters to the file"
  echo "help: Display this message"
  echo "list - Print the file with optional --inverse parameter and line numbers."
  echo "restore - replaced users file with latest backup"
  echo "backup - create copy of existing file with date"
  echo "find <username> - Find a user by name"
}

if [ $# -eq 0 ]; then
  help_command
elif [ -f "$FILE" ]; then
  if [[ "$1" == "add" ]]; then
    LINE1=$(prompt_line)
    LINE2=$(prompt_line)
    LINE="$LINE1,$LINE2"
    echo "$LINE" >> "$FILE"
    echo "Lines added to file."
  elif [[ "$1" == "help" ]]; then
    help_command
  elif [[ "$1" == "backup" ]]; then
    cp "$FILE" "../data/$(date +"%Y-%m-%d")_users.db.backup"
    echo "File backed up."
  elif [[ "$1" == "restore" ]]; then
    latest_backup=$(ls -t ../data/*_users.db.backup 2>/dev/null)
    if [ -n "${latest_backup}" ]; then
      cp -f "${latest_backup}" "../data/users.db" 
      echo "Latest backup file '${latest_backup}' has been restored."
    else
      echo "No backup files found."
    fi
  elif [ "$1" == "list" ]; then
    print_file "$2"
  elif [[ "$1" == "find" ]]; then
    find_line
  else
    echo "Unrecognized command."
  fi
else
  read -p "File does not exist. Do you want to create a new file? (y/n) " CHOICE
  if [[ "$CHOICE" == "y" ]]; then
    touch "$FILE"
    echo "New file created."
    LINE1=$(prompt_line)
    LINE2=$(prompt_line)
    LINE="$LINE1,$LINE2"
    echo "$LINE" >> "$FILE"
    echo "Lines added to file."
  else
    echo "File was not created."
  fi
fi


