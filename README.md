# DigitalTwins Smart Contract

A comprehensive Clarity smart contract for creating and managing synthetic digital twin assets representing real-world industrial IoT devices and systems on the Stacks blockchain.

## Description

DigitalTwins is a synthetic assets smart contract that provides exposure to industrial IoT and digital twin technology. The contract enables the creation, management, and monetization of digital representations of physical IoT devices, complete with sensor data tracking, permission management, and token-based incentives.

## Features

### Core Functionality
- **Digital Twin Creation**: Register and initialize new digital twin devices with unique identifiers
- **Fungible Token System**: Mint and transfer digital twin tokens as synthetic assets
- **Sensor Data Management**: Store and update real-time IoT sensor data (temperature, humidity, pressure, energy consumption)
- **Permission System**: Granular read/write access control for device data
- **Device Status Tracking**: Monitor and update operational status of digital twins
- **Performance Rewards**: Mint additional tokens based on device performance
- **Emergency Controls**: Contract pause/unpause functionality for security

### IoT Data Types Supported
- Temperature readings
- Humidity levels
- Pressure measurements
- Energy consumption metrics
- Operational status indicators

## Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity
- **Version**: 1.0.0
- **Clarity Version**: 2
- **Epoch**: 2.5
- **Token Standard**: Fungible Token (FT)

### Contract Architecture
- **Fungible Token**: `digital-twin-token` for synthetic asset representation
- **Data Maps**: Efficient storage for device information, permissions, and sensor data
- **Access Control**: Owner-based permissions with delegated access rights
- **Error Handling**: Comprehensive error codes for all failure scenarios

## Installation

### Prerequisites
- [Clarinet CLI](https://github.com/hirosystems/clarinet) installed
- Node.js (for development tooling)
- Stacks wallet for deployment

### Setup
1. Clone the repository:
```bash
git clone <repository-url>
cd DigitalTwins
```

2. Navigate to the contract directory:
```bash
cd DigitalTwins_contract
```

3. Install dependencies:
```bash
npm install
```

4. Check contract syntax:
```bash
clarinet check
```

5. Run tests (if available):
```bash
clarinet test
```

## Usage Examples

### Creating a Digital Twin Device
```clarity
;; Create a new industrial sensor device
(contract-call? .DigitalTwins create-digital-twin
  "SENSOR-001-FACTORY-A"
  "temperature-sensor"
  "Factory Floor A, Section 1"
  u1000)
```

### Updating Sensor Data
```clarity
;; Update sensor readings for a device
(contract-call? .DigitalTwins update-sensor-data
  "SENSOR-001-FACTORY-A"
  (some 2350)    ;; temperature (celsius * 100)
  (some 4500)    ;; humidity (percentage * 100)
  (some 101325)  ;; pressure (pascals)
  (some u150)    ;; energy consumption (watts)
  "operational")
```

### Transferring Tokens
```clarity
;; Transfer digital twin tokens to another user
(contract-call? .DigitalTwins transfer-tokens u100 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### Granting Device Permissions
```clarity
;; Grant read/write access to a device
(contract-call? .DigitalTwins grant-device-permission
  "SENSOR-001-FACTORY-A"
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7
  true   ;; can-read
  false) ;; can-write
```

## Contract Functions Documentation

### Public Functions

#### `create-digital-twin`
Creates a new digital twin device and mints initial tokens.
- **Parameters**: `device-id`, `device-type`, `location`, `initial-tokens`
- **Returns**: Device ID on success
- **Access**: Any user (when contract not paused)

#### `update-sensor-data`
Updates sensor readings for an existing device.
- **Parameters**: `device-id`, `temperature`, `humidity`, `pressure`, `energy-consumption`, `operational-status`
- **Returns**: Boolean success indicator
- **Access**: Device owner or users with write permissions

#### `transfer-tokens`
Transfers digital twin tokens between users.
- **Parameters**: `amount`, `recipient`
- **Returns**: Transfer result
- **Access**: Token holders

#### `grant-device-permission`
Grants read/write permissions for device access.
- **Parameters**: `device-id`, `user`, `can-read`, `can-write`
- **Returns**: Boolean success indicator
- **Access**: Device owner only

#### `update-device-status`
Updates the operational status of a device.
- **Parameters**: `device-id`, `new-status`
- **Returns**: Boolean success indicator
- **Access**: Device owner or users with write permissions

#### `mint-performance-tokens`
Mints additional tokens as performance rewards.
- **Parameters**: `device-id`, `amount`
- **Returns**: Amount minted
- **Access**: Contract owner only

#### `toggle-contract-pause`
Emergency pause/unpause contract operations.
- **Returns**: New pause state
- **Access**: Contract owner only

### Read-Only Functions

#### `get-digital-twin`
Retrieves complete device information.
- **Parameters**: `device-id`
- **Returns**: Device data map or none

#### `get-latest-sensor-data`
Gets the most recent sensor readings for a device.
- **Parameters**: `device-id`
- **Returns**: Sensor data map or none

#### `get-balance`
Returns token balance for a user.
- **Parameters**: `user`
- **Returns**: Token balance (uint)

#### `get-total-supply`
Returns total token supply.
- **Returns**: Total supply (uint)

#### `get-device-permissions`
Retrieves permission settings for a user and device.
- **Parameters**: `device-id`, `user`
- **Returns**: Permission map or none

#### `get-total-devices`
Returns total number of registered devices.
- **Returns**: Device count (uint)

#### `is-contract-paused`
Checks if contract operations are paused.
- **Returns**: Pause state (bool)

#### `get-contract-owner`
Returns the contract owner address.
- **Returns**: Owner principal

## Deployment Guide

### Testnet Deployment
1. Configure your testnet settings in `settings/Testnet.toml`
2. Deploy using Clarinet:
```bash
clarinet deployments generate --testnet
clarinet deployments apply --testnet
```

### Mainnet Deployment
1. Configure mainnet settings in `settings/Mainnet.toml`
2. Ensure thorough testing on testnet
3. Deploy to mainnet:
```bash
clarinet deployments generate --mainnet
clarinet deployments apply --mainnet
```

### Post-Deployment
1. Verify contract deployment on Stacks Explorer
2. Initialize any required contract state
3. Set up monitoring for device registrations and sensor updates

## Security Notes

### Access Controls
- **Contract Owner**: Has exclusive rights to mint performance tokens and pause/unpause contract
- **Device Owners**: Full control over their devices and permission management
- **Permitted Users**: Limited access based on granted read/write permissions

### Security Features
- **Input Validation**: All function parameters are validated for correct types and ranges
- **Permission Checks**: Strict access control for all sensitive operations
- **Emergency Pause**: Contract can be paused to prevent operations during security incidents
- **Error Handling**: Comprehensive error codes prevent undefined behavior

### Best Practices
- Regularly monitor device permissions and remove unnecessary access
- Use unique, descriptive device IDs to prevent collisions
- Validate sensor data ranges in your application layer
- Implement rate limiting for sensor data updates
- Monitor token minting activities for unusual patterns

### Known Limitations
- Device IDs are limited to 64 ASCII characters
- Sensor data is stored on-chain (consider privacy implications)
- No built-in data retention policies (historical data accumulates)
- Token precision is limited to whole numbers (no decimals)

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | ERR-OWNER-ONLY | Operation restricted to contract owner |
| 101 | ERR-NOT-AUTHORIZED | Insufficient permissions for operation |
| 102 | ERR-INVALID-AMOUNT | Invalid token amount (must be > 0) |
| 103 | ERR-INSUFFICIENT-BALANCE | Insufficient token balance |
| 104 | ERR-DEVICE-NOT-FOUND | Device ID does not exist |
| 105 | ERR-DEVICE-ALREADY-EXISTS | Device ID already registered |
| 106 | ERR-INVALID-DATA | Invalid data format or content |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the terms specified in the repository license file.

## Support

For technical support or questions about the DigitalTwins smart contract, please create an issue in the repository or contact the development team.