#!/bin/bash
LOG_FILE="cpu_log"
THRESHOLD=60
get_cpu_load() {
top -b -n 
