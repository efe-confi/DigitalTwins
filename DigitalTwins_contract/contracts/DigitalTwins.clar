
;; title: DigitalTwins
;; version: 1.0.0
;; summary: Synthetic assets smart contract for industrial IoT and digital twin technology exposure
;; description: This contract enables creation and management of synthetic digital twin assets
;;              representing real-world industrial IoT devices and systems

;; traits
;;

;; token definitions
;; Define the synthetic asset token
(define-fungible-token digital-twin-token)

;; constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-INSUFFICIENT-BALANCE (err u103))
(define-constant ERR-DEVICE-NOT-FOUND (err u104))
(define-constant ERR-DEVICE-ALREADY-EXISTS (err u105))
(define-constant ERR-INVALID-DATA (err u106))

;; data vars
(define-data-var total-devices uint u0)
(define-data-var contract-paused bool false)

;; data maps
;; Map to store digital twin device information
(define-map digital-twins
  { device-id: (string-ascii 64) }
  {
    owner: principal,
    device-type: (string-ascii 32),
    location: (string-ascii 64),
    status: (string-ascii 16),
    data-hash: (string-ascii 64),
    last-updated: uint,
    token-balance: uint
  }
)

;; Map to track device permissions
(define-map device-permissions
  { device-id: (string-ascii 64), user: principal }
  { can-read: bool, can-write: bool }
)

;; Map to store IoT sensor data
(define-map sensor-data
  { device-id: (string-ascii 64), timestamp: uint }
  {
    temperature: (optional int),
    humidity: (optional int),
    pressure: (optional int),
    energy-consumption: (optional uint),
    operational-status: (string-ascii 16)
  }
)

;; public functions

;; Initialize a new digital twin device
(define-public (create-digital-twin
    (device-id (string-ascii 64))
    (device-type (string-ascii 32))
    (location (string-ascii 64))
    (initial-tokens uint))
  (let ((device-exists (map-get? digital-twins { device-id: device-id })))
    (asserts! (is-none device-exists) ERR-DEVICE-ALREADY-EXISTS)
    (asserts! (> initial-tokens u0) ERR-INVALID-AMOUNT)
    (asserts! (not (var-get contract-paused)) ERR-NOT-AUTHORIZED)

    (try! (ft-mint? digital-twin-token initial-tokens tx-sender))

    (map-set digital-twins
      { device-id: device-id }
      {
        owner: tx-sender,
        device-type: device-type,
        location: location,
        status: "active",
        data-hash: "",
        last-updated: block-height,
        token-balance: initial-tokens
      }
    )

    (var-set total-devices (+ (var-get total-devices) u1))
    (ok device-id)
  )
)

;; Update sensor data for a digital twin
(define-public (update-sensor-data
    (device-id (string-ascii 64))
    (temperature (optional int))
    (humidity (optional int))
    (pressure (optional int))
    (energy-consumption (optional uint))
    (operational-status (string-ascii 16)))
  (let ((device (unwrap! (map-get? digital-twins { device-id: device-id }) ERR-DEVICE-NOT-FOUND))
        (has-write-permission (default-to false
          (get can-write (map-get? device-permissions { device-id: device-id, user: tx-sender })))))

    (asserts! (or (is-eq (get owner device) tx-sender) has-write-permission) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get contract-paused)) ERR-NOT-AUTHORIZED)

    (map-set sensor-data
      { device-id: device-id, timestamp: block-height }
      {
        temperature: temperature,
        humidity: humidity,
        pressure: pressure,
        energy-consumption: energy-consumption,
        operational-status: operational-status
      }
    )

    (map-set digital-twins
      { device-id: device-id }
      (merge device { last-updated: block-height })
    )

    (ok true)
  )
)

;; Transfer digital twin tokens between users
(define-public (transfer-tokens (amount uint) (recipient principal))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (not (var-get contract-paused)) ERR-NOT-AUTHORIZED)
    (ft-transfer? digital-twin-token amount tx-sender recipient)
  )
)

;; Grant permissions to access device data
(define-public (grant-device-permission
    (device-id (string-ascii 64))
    (user principal)
    (can-read bool)
    (can-write bool))
  (let ((device (unwrap! (map-get? digital-twins { device-id: device-id }) ERR-DEVICE-NOT-FOUND)))
    (asserts! (is-eq (get owner device) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get contract-paused)) ERR-NOT-AUTHORIZED)

    (map-set device-permissions
      { device-id: device-id, user: user }
      { can-read: can-read, can-write: can-write }
    )
    (ok true)
  )
)

;; Update device status
(define-public (update-device-status
    (device-id (string-ascii 64))
    (new-status (string-ascii 16)))
  (let ((device (unwrap! (map-get? digital-twins { device-id: device-id }) ERR-DEVICE-NOT-FOUND))
        (has-write-permission (default-to false
          (get can-write (map-get? device-permissions { device-id: device-id, user: tx-sender })))))

    (asserts! (or (is-eq (get owner device) tx-sender) has-write-permission) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get contract-paused)) ERR-NOT-AUTHORIZED)

    (map-set digital-twins
      { device-id: device-id }
      (merge device {
        status: new-status,
        last-updated: block-height
      })
    )
    (ok true)
  )
)

;; Mint additional tokens for device performance rewards
(define-public (mint-performance-tokens (device-id (string-ascii 64)) (amount uint))
  (let ((device (unwrap! (map-get? digital-twins { device-id: device-id }) ERR-DEVICE-NOT-FOUND)))
    (asserts! (is-eq CONTRACT-OWNER tx-sender) ERR-OWNER-ONLY)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (not (var-get contract-paused)) ERR-NOT-AUTHORIZED)

    (try! (ft-mint? digital-twin-token amount (get owner device)))

    (map-set digital-twins
      { device-id: device-id }
      (merge device {
        token-balance: (+ (get token-balance device) amount),
        last-updated: block-height
      })
    )
    (ok amount)
  )
)

;; Emergency pause/unpause contract (owner only)
(define-public (toggle-contract-pause)
  (begin
    (asserts! (is-eq CONTRACT-OWNER tx-sender) ERR-OWNER-ONLY)
    (var-set contract-paused (not (var-get contract-paused)))
    (ok (var-get contract-paused))
  )
)

;; read only functions

;; Get digital twin device information
(define-read-only (get-digital-twin (device-id (string-ascii 64)))
  (map-get? digital-twins { device-id: device-id })
)

;; Get latest sensor data for a device
(define-read-only (get-latest-sensor-data (device-id (string-ascii 64)))
  (let ((device (map-get? digital-twins { device-id: device-id })))
    (if (is-some device)
      (map-get? sensor-data { device-id: device-id, timestamp: (get last-updated (unwrap-panic device)) })
      none
    )
  )
)

;; Get user's token balance
(define-read-only (get-balance (user principal))
  (ft-get-balance digital-twin-token user)
)

;; Get total token supply
(define-read-only (get-total-supply)
  (ft-get-supply digital-twin-token)
)

;; Get device permissions for a user
(define-read-only (get-device-permissions (device-id (string-ascii 64)) (user principal))
  (map-get? device-permissions { device-id: device-id, user: user })
)

;; Get total number of devices
(define-read-only (get-total-devices)
  (var-get total-devices)
)

;; Check if contract is paused
(define-read-only (is-contract-paused)
  (var-get contract-paused)
)

;; Get contract owner
(define-read-only (get-contract-owner)
  CONTRACT-OWNER
)

;; private functions

;; Validate device ID format
(define-private (is-valid-device-id (device-id (string-ascii 64)))
  (> (len device-id) u0)
)

;; Calculate device performance score (placeholder for complex logic)
(define-private (calculate-performance-score (device-id (string-ascii 64)))
  (let ((device (map-get? digital-twins { device-id: device-id })))
    (if (is-some device)
      (if (is-eq (get status (unwrap-panic device)) "active")
        u100
        u0
      )
      u0
    )
  )
)
