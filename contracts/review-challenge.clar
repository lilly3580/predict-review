;; PredictReview: Creative Writing Challenge Platform
;; Contract: review-challenge
;;
;; This contract manages creative writing challenges with a focus on community-driven review
;; and reward mechanisms. Users can create challenges, submit works, vote on submissions,
;; and earn rewards based on community engagement.

;; Error Codes for Different Scenarios
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-CHALLENGE-NOT-FOUND (err u101))
(define-constant ERR-CHALLENGE-EXPIRED (err u102))
(define-constant ERR-CHALLENGE-ACTIVE (err u103))
(define-constant ERR-SUBMISSION-NOT-FOUND (err u104))
(define-constant ERR-VOTING-INACTIVE (err u105))
(define-constant ERR-ALREADY-VOTED (err u106))
(define-constant ERR-INSUFFICIENT-FUNDS (err u107))
(define-constant ERR-INVALID-PARAMETERS (err u108))
(define-constant ERR-SELF-VOTE (err u109))
(define-constant ERR-SUBMISSIONS-CLOSED (err u110))
(define-constant ERR-USER-NOT-FOUND (err u111))
(define-constant ERR-REWARDS-ALREADY-CLAIMED (err u112))
(define-constant ERR-NOT-ELIGIBLE-FOR-REWARDS (err u113))
(define-constant ERR-ALREADY-FOLLOWING (err u114))

;; Platform Configuration Constants
(define-constant CHALLENGE-CREATION-FEE u1000000) ;; 1 STX
(define-constant MIN-CHALLENGE-DURATION u43200) ;; Minimum 12 hours
(define-constant MAX-CHALLENGE-DURATION u1051200) ;; Maximum 6 months
(define-constant PLATFORM-FEE-PERCENT u5) ;; 5% platform fee
(define-constant DEFAULT-SUBMISSION-FEE u100000) ;; 0.1 STX

;; PredictReview: Creative Writing Challenge Platform
;; Contract: review-challenge
;;
;; This contract manages creative writing challenges with a focus on community-driven review
;; and reward mechanisms. Users can create challenges, submit works, vote on submissions,
;; and earn rewards based on community engagement.

;; Error Codes for Different Scenarios
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-CHALLENGE-NOT-FOUND (err u101))
(define-constant ERR-CHALLENGE-EXPIRED (err u102))
(define-constant ERR-CHALLENGE-ACTIVE (err u103))
(define-constant ERR-SUBMISSION-NOT-FOUND (err u104))
(define-constant ERR-VOTING-INACTIVE (err u105))
(define-constant ERR-ALREADY-VOTED (err u106))
(define-constant ERR-INSUFFICIENT-FUNDS (err u107))
(define-constant ERR-INVALID-PARAMETERS (err u108))
(define-constant ERR-SELF-VOTE (err u109))
(define-constant ERR-SUBMISSIONS-CLOSED (err u110))
(define-constant ERR-USER-NOT-FOUND (err u111))
(define-constant ERR-REWARDS-ALREADY-CLAIMED (err u112))
(define-constant ERR-NOT-ELIGIBLE-FOR-REWARDS (err u113))
(define-constant ERR-ALREADY-FOLLOWING (err u114))

;; Platform Configuration Constants
(define-constant CHALLENGE-CREATION-FEE u1000000) ;; 1 STX
(define-constant MIN-CHALLENGE-DURATION u43200) ;; Minimum 12 hours
(define-constant MAX-CHALLENGE-DURATION u1051200) ;; Maximum 6 months
(define-constant PLATFORM-FEE-PERCENT u5) ;; 5% platform fee
(define-constant DEFAULT-SUBMISSION-FEE u100000) ;; 0.1 STX

;; Platform Global Variables
(define-data-var platform-admin principal tx-sender)
(define-data-var challenge-counter uint u0)
(define-data-var submission-counter uint u0)

;; Challenge data structure
(define-map challenges
  uint ;; challenge-id
  {
    creator: principal,
    title: (string-ascii 100),
    description: (string-utf8 500),
    genre: (string-ascii 50),
    start-block: uint,
    end-block: uint,
    voting-end-block: uint,
    submission-fee: uint,
    total-stake: uint,
    total-rewards: uint,
    rewards-distributed: bool,
    submission-count: uint,
    vote-count: uint,
    status: (string-ascii 20) ;; "active", "voting", "completed"
  }
)

(define-map submissions
  uint ;; submission-id
  {
    challenge-id: uint,
    author: principal,
    title: (string-ascii 100),
    content-hash: (buff 32), ;; IPFS or content hash
    submission-block: uint,
    vote-count: uint,
    rewards-claimed: bool
  }
)

(define-map challenge-submissions
  uint ;; challenge-id
  (list 100 uint) ;; List of submission IDs, max 100 per challenge
)

(define-map user-votes
  { user: principal, challenge-id: uint }
  (list 100 uint) ;; List of submission IDs user voted for
)

(define-map submission-votes
  uint ;; submission-id
  (list 100 principal) ;; List of users who voted for this submission
)

(define-map user-reputation
  { user: principal, genre: (string-ascii 50) }
  uint ;; Reputation score
)

(define-map user-following
  principal ;; follower
  (list 100 principal) ;; List of users being followed
)

(define-map challenge-rewards
  uint ;; challenge-id
  {
    first-place-reward: uint,    ;; 50% of total rewards
    second-place-reward: uint,   ;; 30% of total rewards
    third-place-reward: uint,    ;; 15% of total rewards
    creator-reward: uint         ;; 5% of total rewards
  }
)

(define-map challenge-results
  uint ;; challenge-id
  {
    first-place: (optional uint),    ;; submission-id
    second-place: (optional uint),   ;; submission-id
    third-place: (optional uint)     ;; submission-id
  }
)

;; Rest of the original contract's implementation