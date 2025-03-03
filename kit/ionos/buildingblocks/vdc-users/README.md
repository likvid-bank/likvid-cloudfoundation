# IONOS Virtual Data Center User Building Block

WIP

this buildingblock should actually call a bash script and then create users that do not yet exist in IONOS. In principle, we do this similarly in Stackit.
Apparently, however, calling the script is faulty and my recommendation is to run the whole thing via an asynchronous BB via pipeline so that debugging is easier.

take the create_users.sh script for you pipeline, locally i could create new users.
