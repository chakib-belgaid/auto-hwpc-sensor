# Auto HWPC Sensor

This repository contains the Auto HWPC Sensor project, which update the config file to include the proper events of *containers/core* for [hwpc-sensor](https://powerapi.org/reference/sensors/hwpc-sensor/) based on the cpu family 


## Installation

To install the Auto HWPC Sensor, follow these steps:

1. Clone the repository: `git clone https://github.com/your-username/auto-hwpc-sensor.git`


## Usage

To use the Auto HWPC Sensor, follow these steps:
1. install the [hwpc-sensor](https://powerapi.org/reference/sensors/hwpc-sensor/)
2. prepare your config file with all the events except the one that depends on the container/core
3. 
 instead of running the hwpc-sensor with the config file, run the auto-hwpc-sensor with the config file as an argument

```bash
    hwpc-sensor --config-file <path-to-config-file>
```
becomes 

```bash
    auto-hwpc-sensor <path-to-config-file>
```

# Limitaion 
- The auto-hwpc-sensor only works with the cpu family events. If the cpu events are not present in the config file, the auto-hwpc-sensor will not work.
- the auto-hwpc-sensor only works with the config-file and not with the arguments passed to the hwpc-sensor command.

## Contributing

Contributions are welcome! If you would like to contribute to the Auto HWPC Sensor project. 

To add a new cpu family, follow these steps:

1. add the entry in the file cpu_events.json with the cpu family as the key and the events as the value
2. make sure the the cpu family is in ** Lower case ** otherwise it won't work 
3. the events should be the same format as the events present in the [lbpfm4](https://github.com/gfieni/libpfm4)


