Espresso Canister Deployment Platform
Overview
Espresso is a platform that allows users to deploy canisters on the Internet Computer by providing Wasm modules through a web interface. The platform provides both free-tier deployments with cooldown periods and user-funded deployments for immediate access.

Project Structure
Backend Structure
main.mo - Main canister entry point with complete public API implementation
types.mo - Type definitions for DeployLog, Donation, deployment records, and system state
utils.mo - Utility functions for canister operations and data processing
validation.mo - Complete Wasm module validation with security checks and SHA256 hashing
pool.mo - Cycle management, free-tier configuration, and cooldown enforcement
donations.mo - Donation tracking with record_donation, get_donations, and get_totals methods using simple sum logic
errors.mo - Structured error mapping for deployment stages with code, stage, detail, and hint fields
config.mo - Centralized configuration for size limits, cooldown periods, and cycle thresholds
Frontend Structure
UploadCard.tsx - Component with drag-and-drop for .wasm and optional .zip files, client-side validation, SHA-256 hash computation, and stepper UI for deployment stages
Logs.tsx - Component with Public and My Deployments tabs, infinite scroll, row expansion, and copy-to-clipboard functionality
Donate.tsx - Component with ICP and Cycles tabs, QR codes, donation recording, totals display, and donor leaderboard
TemplatePicker.tsx - Component with bundled Link Shortener template deployment and post-deploy app linking
StorageMap.tsx - Static component with Tailwind-styled table and info cards explaining where user data is stored, using badge logic for "on-chain", "partial", and "not stored" states
UseCases.tsx - Static component with four cards describing key Espresso use cases, styled with Tailwind and no external dependencies
state/logs.ts - State management for deployment logs
lib/hash.ts - Utility functions for Wasm hash generation
templates/ - Bundled Link Shortener template with Motoko backend and minimal frontend
Testing Structure
validation.test.mo - Tests for Wasm validation functionality
pool.test.mo - Tests for balance and cycle management
main.test.mo - Integration tests for main canister functions
CI/CD Structure
.github/workflows/ci.yml - Continuous integration pipeline with dfx/moc setup, Motoko builds, frontend typechecking, and test execution
Core Features
Frontend Interface
Prominent description section explaining Espresso's importance and benefits for developers
Concise "How to Use" guide outlining the deployment steps
Donation Usage Breakdown section displaying financial transparency data
StorageMap component displaying where user data is stored with badge indicators
UseCases component showcasing four key use cases for the platform
Drag-and-drop interface for .wasm files (required) and .zip files (optional assets)
Client-side file validation matching backend limits
SHA-256 hash computation and display before deployment
Stepper UI showing deployment stages: Validate → Create → Fund (if user-funded) → Install → Logged
Per-step error handling with retry functionality
Support for both free-tier and user-funded deployment flows
Top-up instructions and backend polling for user-funded deployments
Tabbed logs interface with Public and My Deployments views
Infinite scroll with newest-first ordering for all lists
Row expansion for viewing full hashes and JSON data
Copy-to-clipboard functionality for principals and hashes
Donation interface with ICP and Cycles tabs
QR code display for ICP donations and Espresso principal for cycles
"I sent" buttons to record donations via backend API
Display of donation totals and donor leaderboard
Template selection with bundled Link Shortener deployment
Post-deployment linking to deployed applications
Loading skeletons for all async operations
Empty states for lists and data views
Error toast notifications
Polling of logs after deployment to confirm append
Homepage Layout
The homepage renders components in the following order:

Hero section with description and benefits
StorageMap component explaining data storage locations
UseCases component showcasing platform use cases
Main CTA section with upload and template functionality
Additional sections for logs, donations, and usage breakdown
Public API Implementation
The backend exposes a complete public API with the following methods:

deploy_install - Free-tier deployment with cooldown enforcement
deploy_install_user_funded - Immediate deployment funded by user cycles
get_logs - Paginated public deployment history (newest first)
get_my_history - User's personal deployment history with pagination
get_pool_status - Current cycle pool balance and system status
record_donation - Record ICP and cycle donations
get_donations - Paginated donation history
get_totals - Summary statistics for donations and deployments using simple sum logic
Wasm Validation System
Complete validation module implementing strict security checks:

Maximum Wasm module size enforcement
Magic number and version validation
Memory page limits verification
Custom section size restrictions
SHA256 hash generation for deployment logging
Clear error messages for validation failures
Client-side validation matching backend limits
Deployment Process
Two deployment flows with identical validation and creation steps:

Free-Tier Flow:

Client-side file validation and hash computation
Wasm validation with rejection on failure
Free-tier guard checking cooldown periods
Canister creation using management canister
Fixed cycle allocation from platform pool
Wasm code installation with timeout handling
Public deployment logging with assetsHash where applicable
Error handling for pool depletion and cooldown violations
User-Funded Flow:

Client-side file validation and hash computation
Wasm validation with rejection on failure
User-provided cycle verification
Canister creation using management canister
User cycle allocation to new canister
Wasm code installation with timeout handling
Public deployment logging with assetsHash where applicable
Error handling for insufficient cycles and timeouts
Backend Data Storage
Append-only public deployment log with pagination support (newest first)
User deployment history tracking
Cycle pool balance management with stable storage
Free-tier cooldown tracking with stable last_free_deploy map
Donation records with pagination support stored in donations.mo
Platform configuration constants for limits and timeouts
Pool Management
Configuration constants and enforcement centralized in config.mo:

Free-tier cycle allocation amounts
Cooldown periods between free deployments
Operation timeout limits
Maximum Wasm size and memory constraints
Stable storage for user cooldown tracking
Controller Management
Canister controller set to principal: ogfch-ufc3n-wie7u-j3i7t-hcpad-pua6y-k2ejb-eopnu-fje3c-gz4jq-7qe
Administrative functions restricted to controller only
Withdrawal System
Controller can withdraw ICP donations to account ID: 68098bbefaf5917af1b922567b79a8901e7a892637dc1f56d557dc723f6511d8
Simple UI button for controller to trigger withdrawal process
Pagination System
All list endpoints support pagination with offset and limit parameters:

Deployment logs displayed newest first with infinite scroll
User history with chronological ordering
Donation records with timestamp sorting
Configurable page sizes for optimal performance
Template System
Bundled Link Shortener template with Motoko backend and minimal frontend
One-click deployment of template with automatic app linking
Template includes both Wasm and asset files
Post-deployment display of deployed application URL
Donation System
Accept ICP and cycle donations to support platform operations
Cycle donations are handled as on-chain top-ups to the canister
ICP donation confirmation is managed off-chain by the frontend
Track donation amounts and spending for transparency using simple sum logic
Display usage breakdown to users with pagination support
Donor leaderboard showing top contributors
QR code generation for ICP donation addresses
Error Handling System
The backend implements structured error handling with the following stages:

"validate_wasm" - Wasm module validation errors
"create_canister" - Canister creation failures
"fund_canister" - Cycle funding issues
"install_code" - Code installation problems
"log_write" - Logging operation failures
All errors are returned with structured format containing:

code: Numeric error identifier
stage: Text identifier for the deployment stage
detail: Detailed error description
hint: User-friendly guidance for resolution
All backend rejects bubble up meaningful error messages for the UI using this structured error mapping.

Testing and CI/CD
Comprehensive Motoko test suite covering validation, pool management, and main functionality
GitHub Actions workflow for continuous integration
Automated dfx and moc setup in CI environment
Motoko canister building and testing
Frontend TypeScript type checking
Test execution for all backend modules
User Flow
User reads description and usage guide on home page
User views data storage information in StorageMap component
User explores platform use cases in UseCases component
User views donation usage breakdown for transparency
User selects deployment template or drags custom .wasm/.zip files
System computes and displays SHA-256 hash of files
User chooses between free-tier (with cooldown) or user-funded deployment
System shows stepper UI progressing through deployment stages
System validates files client-side and server-side with error handling
System creates canister, allocates cycles, and installs code
System logs deployment publicly and provides confirmation
User can view deployment history with infinite scroll and detailed views
User can copy principals and hashes to clipboard
User can donate ICP or cycles with QR codes and confirmation
Controller can manage donations and withdrawals as needed
Language
All application content is in English
Error Handling
Structured error mapping for all deployment stages
Clear validation error messages for Wasm rejection
Timeout handling for canister operations
Pool depletion notifications for free-tier users
Cooldown period enforcement with clear messaging
Insufficient cycle warnings for user-funded deployments
All backend errors provide meaningful UI feedback through structured error format
Toast notifications for all error states
Per-step retry functionality in deployment stepper
Client-side validation errors with helpful hints
Component Requirements
StorageMap component is static, concise (≤200 lines), responsive, and accessible
UseCases component is static, concise (≤200 lines), responsive, and accessible
Both components use Tailwind styling without external dependencies
Both components do not perform external fetches or use heavy icons
Components are integrated into the homepage between hero section and main CTA
