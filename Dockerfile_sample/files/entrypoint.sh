# Copyright (c) 2025 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

#!/bin/bash

USER_ID=${LOCAL_USER_ID:-9001}
USER_NAME=${LOCAL_USER_NAME:-user}
GROUP_ID=${LOCAL_GROUP_ID} #new item for groups
GROUP_NAME=${LOCAL_GROUP_NAME} #new item for groups
GITCONFIG_USERNAME=${LOCAL_GITCONFIG_USERNAME:-"${USER_NAME}"}
GITCONFIG_EMAIL=${LOCAL_GITCONFIG_EMAIL:-"${USER_NAME}@${GROUP_NAME}"}

echo "Starting container with UID : ${USER_ID}"
groupadd -g $GROUP_ID $GROUP_NAME
groupmod -g $GROUP_ID users
useradd --shell /bin/bash -u ${USER_ID} -o -c "" -m ${USER_NAME}

export HOME=/home/${USER_NAME}
chown ${USER_NAME} /home/${USER_NAME}
usermod -g $GROUP_NAME $USER_NAME

# Set git config user.name & user.email
git config --global user.email ${GITCONFIG_EMAIL}
git config --global user.name ${GITCONFIG_USERNAME}

# Run Docker CMD as specified user
exec gosu ${USER_NAME} "${@}"
