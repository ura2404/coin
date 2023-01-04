#!/bin/bash

# Показывает информацию по видеокартам
# Поля:
# - index
# - gpu temperature
# - current power limit
# - minimum power limit
# - default power limit
# - maximum power limit
# - gpu name

watch -n 0.5 'nvidia-smi --format=csv --query-gpu=index,temperature.gpu,power.limit,power.min_limit,power.default_limit,power.max_limit,name'
