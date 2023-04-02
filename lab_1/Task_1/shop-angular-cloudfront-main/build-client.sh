#!/bin/bash

CONFIGURATION=$1

if ! [ -x "$(command -v ng)" ]; then
    echo 'Error: Angular CLI is not installed.' >&2
    echo 'Installing Angular CLI...' >&2
    npm install -g @angular/cli@latest
fi

npm install

if [ -f "dist/client-app.zip" ]; then
    rm dist/client-app.zip
fi

ng build --configuration $CONFIGURATION

cd dist

zip -r client-app.zip app/*

count=$(find . -type f | wc -l)
echo "The 'dist' directory and its subdirectories contain $count files."

