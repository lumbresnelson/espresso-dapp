import AccessControl "authorization/access-control";
import Registry "blob-storage/registry";
import Principal "mo:base/Principal";
import OrderedMap "mo:base/OrderedMap";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import List "mo:base/List";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import Cycles "mo:base/ExperimentalCycles";
import Nat32 "mo:base/Nat32";
import Migration "migration";

(with migration = Migration.run)
persistent actor {
    // Access control state
    let accessControlState = AccessControl.initState();

    // File registry
    let registry = Registry.new();

    // Deployment log entry type
    public type DeploymentLogEntry = {
        userPrincipal : Principal;
        canisterId : Text;
        wasmHash : Text;
        timestamp : Time.Time;
    };

    // Donation record type
    public type DonationRecord = {
        donorPrincipal : Principal;
        amount : Nat;
        timestamp : Time.Time;
    };

    // User profile type
    public type UserProfile = {
        name : Text;
    };

    // Donation usage breakdown type
    public type DonationUsageBreakdown = {
        totalIcpDonations : Nat;
        totalCycleDonations : Nat;
        amountSpent : Nat;
        remainingIcpBalance : Nat;
        remainingCycleBalance : Nat;
    };

    // Initialize OrderedMap operations
    transient let principalMap = OrderedMap.Make<Principal>(Principal.compare);
    transient let textMap = OrderedMap.Make<Text>(Text.compare);

    // State variables
    var deploymentLogs = textMap.empty<DeploymentLogEntry>();
    var icpDonations = textMap.empty<DonationRecord>();
    var cycleDonations = textMap.empty<DonationRecord>();
    var userProfiles = principalMap.empty<UserProfile>();
    var amountSpent : Nat = 0;

    // Controller principal and withdrawal account
    let controllerPrincipal = Principal.fromText("ogfch-ufc3n-wie7u-j3i7t-hcpad-pua6y-k2ejb-eopnu-fje3c-gz4jq-7qe");
    let withdrawalAccount = "68098bbefaf5917af1b922567b79a8901e7a892637dc1f56d557dc723f6511d8";

    // Initialize access control
    public shared ({ caller }) func initializeAccessControl() : async () {
        AccessControl.initialize(accessControlState, caller);
    };

    // Access control functions
    public query ({ caller }) func getCallerUserRole() : async AccessControl.UserRole {
        AccessControl.getUserRole(accessControlState, caller);
    };

    public shared ({ caller }) func assignCallerUserRole(user : Principal, role : AccessControl.UserRole) : async () {
        AccessControl.assignRole(accessControlState, caller, user, role);
    };

    public query ({ caller }) func isCallerAdmin() : async Bool {
        AccessControl.isAdmin(accessControlState, caller);
    };

    // User profile functions
    public query ({ caller }) func getCallerUserProfile() : async ?UserProfile {
        principalMap.get(userProfiles, caller);
    };

    public shared ({ caller }) func saveCallerUserProfile(profile : UserProfile) : async () {
        userProfiles := principalMap.put(userProfiles, caller, profile);
    };

    public query func getUserProfile(user : Principal) : async ?UserProfile {
        principalMap.get(userProfiles, user);
    };

    // File registry functions
    public func registerFileReference(path : Text, hash : Text) : async () {
        Registry.add(registry, path, hash);
    };

    public query func getFileReference(path : Text) : async Registry.FileReference {
        Registry.get(registry, path);
    };

    public query func listFileReferences() : async [Registry.FileReference] {
        Registry.list(registry);
    };

    public func dropFileReference(path : Text) : async () {
        Registry.remove(registry, path);
    };

    // Deployment log functions
    public shared ({ caller }) func logDeployment(canisterId : Text, wasmHash : Text) : async () {
        let entry : DeploymentLogEntry = {
            userPrincipal = caller;
            canisterId = canisterId;
            wasmHash = wasmHash;
            timestamp = Time.now();
        };
        deploymentLogs := textMap.put(deploymentLogs, canisterId, entry);
    };

    public query func getDeploymentLogs() : async [DeploymentLogEntry] {
        Iter.toArray(textMap.vals(deploymentLogs));
    };

    // Donation functions
    public shared ({ caller }) func recordIcpDonation(amount : Nat) : async () {
        let record : DonationRecord = {
            donorPrincipal = caller;
            amount = amount;
            timestamp = Time.now();
        };
        icpDonations := textMap.put(icpDonations, Principal.toText(caller), record);
    };

    public shared ({ caller }) func recordCycleDonation(amount : Nat) : async () {
        let record : DonationRecord = {
            donorPrincipal = caller;
            amount = amount;
            timestamp = Time.now();
        };
        cycleDonations := textMap.put(cycleDonations, Principal.toText(caller), record);
    };

    public query func getIcpDonations() : async [DonationRecord] {
        Iter.toArray(textMap.vals(icpDonations));
    };

    public query func getCycleDonations() : async [DonationRecord] {
        Iter.toArray(textMap.vals(cycleDonations));
    };

    // Wasm validation function
    public query func validateWasm(wasmModule : Blob) : async Bool {
        let magicNumber = Array.tabulate<Nat8>(4, func(i) { 0x00 });
        let wasmBytes = Blob.toArray(wasmModule);
        if (wasmBytes.size() < 4) {
            return false;
        };
        for (i in Iter.range(0, 3)) {
            if (wasmBytes[i] != magicNumber[i]) {
                return false;
            };
        };
        true;
    };

    // Hash calculation function
    public query func calculateWasmHash(wasmModule : Blob) : async Text {
        let hash = Text.concat("0x", Nat32.toText(Blob.hash(wasmModule)));
        hash;
    };

    // Get cycle balance
    public query func getCycleBalance() : async Nat {
        Int.abs(Cycles.balance());
    };

    // Get canister status
    public query func getCanisterStatus(canisterId : Text) : async {
        cycles : Nat;
        memorySize : Nat;
        moduleHash : ?Text;
    } {
        let entry = textMap.get(deploymentLogs, canisterId);
        switch (entry) {
            case null {
                Debug.trap("Canister not found");
            };
            case (?logEntry) {
                {
                    cycles = 0;
                    memorySize = 0;
                    moduleHash = ?logEntry.wasmHash;
                };
            };
        };
    };

    // Get deployment status
    public query func getDeploymentStatus(canisterId : Text) : async {
        status : Text;
        cycles : Nat;
        memorySize : Nat;
        moduleHash : ?Text;
    } {
        let entry = textMap.get(deploymentLogs, canisterId);
        switch (entry) {
            case null {
                Debug.trap("Canister not found");
            };
            case (?logEntry) {
                {
                    status = "running";
                    cycles = 0;
                    memorySize = 0;
                    moduleHash = ?logEntry.wasmHash;
                };
            };
        };
    };

    // Get all deployed canisters
    public query func getDeployedCanisters() : async [Text] {
        Iter.toArray(textMap.keys(deploymentLogs));
    };

    // Get deployment history for a user
    public query func getUserDeploymentHistory(user : Principal) : async [DeploymentLogEntry] {
        var userLogs = List.nil<DeploymentLogEntry>();
        for ((_, entry) in textMap.entries(deploymentLogs)) {
            if (entry.userPrincipal == user) {
                userLogs := List.push(entry, userLogs);
            };
        };
        List.toArray(userLogs);
    };

    // Get donation usage breakdown
    public query func getDonationUsageBreakdown() : async DonationUsageBreakdown {
        var totalIcpDonations = 0;
        for ((_, record) in textMap.entries(icpDonations)) {
            totalIcpDonations += record.amount;
        };

        var totalCycleDonations = 0;
        for ((_, record) in textMap.entries(cycleDonations)) {
            totalCycleDonations += record.amount;
        };

        {
            totalIcpDonations = totalIcpDonations;
            totalCycleDonations = totalCycleDonations;
            amountSpent = amountSpent;
            remainingIcpBalance = totalIcpDonations - amountSpent;
            remainingCycleBalance = totalCycleDonations - amountSpent;
        };
    };

    // Withdrawal function for controller
    public shared ({ caller }) func withdrawIcp(amount : Nat) : async () {
        if (caller != controllerPrincipal) {
            Debug.trap("Only the controller can withdraw ICP");
        };

        let totalIcpDonations = Array.foldLeft<DonationRecord, Nat>(
            Iter.toArray(textMap.vals(icpDonations)),
            0,
            func(acc, record) { acc + record.amount },
        );

        if (amount > totalIcpDonations - amountSpent) {
            Debug.trap("Insufficient funds");
        };

        // Define the type for the Ledger canister
        type Ledger = actor {
            send : ({ to_account : Text; amount : Nat }) -> async ();
        };

        // Create an instance of the Ledger canister
        let ledger = actor("ryjl3-tyaaa-aaaaa-aaaba-cai") : Ledger;

        // Perform the withdrawal
        await ledger.send({
            to_account = withdrawalAccount;
            amount = amount;
        });

        amountSpent += amount;
    };
};


