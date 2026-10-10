#!/bin/bash
scp skeleton.conf engineer@10.103.68.192:/home/engineer/ && ssh engineer@10.103.68.192 './2-panic.sh && sudo nft -f skeleton.conf && sudo nft list ruleset'