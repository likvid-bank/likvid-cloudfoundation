#!/usr/bin/env sh

collie foundation deploy likvid-dev --bootstrap -- init
collie foundation deploy likvid-dev --bootstrap -- providers lock -platform=darwin_amd64 -platform=linux_amd64 -platform=darwin_arm64
collie foundation deploy likvid-dev -- init
collie foundation deploy likvid-dev -- providers lock -platform=darwin_amd64 -platform=linux_amd64 -platform=darwin_arm64

collie foundation deploy likvid-prod --bootstrap -- init
collie foundation deploy likvid-prod --bootstrap -- providers lock -platform=darwin_amd64 -platform=linux_amd64 -platform=darwin_arm64
collie foundation deploy likvid-prod -- init
collie foundation deploy likvid-prod -- providers lock -platform=darwin_amd64 -platform=linux_amd64 -platform=darwin_arm64