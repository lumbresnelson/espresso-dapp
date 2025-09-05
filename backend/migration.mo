import OrderedMap "mo:base/OrderedMap";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";

module {
    type OldActor = {
        deploymentLogs : OrderedMap.Map<Text, {
            userPrincipal : Principal;
            canisterId : Text;
            wasmHash : Text;
            timestamp : Int;
        }>;
        icpDonations : OrderedMap.Map<Text, {
            donorPrincipal : Principal;
            amount : Nat;
            timestamp : Int;
        }>;
        cycleDonations : OrderedMap.Map<Text, {
            donorPrincipal : Principal;
            amount : Nat;
            timestamp : Int;
        }>;
        userProfiles : OrderedMap.Map<Principal, { name : Text }>;
        amountSpent : Nat;
    };

    type NewActor = {
        deploymentLogs : OrderedMap.Map<Text, {
            userPrincipal : Principal;
            canisterId : Text;
            wasmHash : Text;
            timestamp : Nat;
        }>;
        icpDonations : OrderedMap.Map<Text, {
            donorPrincipal : Principal;
            amount : Nat;
            timestamp : Nat;
        }>;
        cycleDonations : OrderedMap.Map<Text, {
            donorPrincipal : Principal;
            amount : Nat;
            timestamp : Nat;
        }>;
        userProfiles : OrderedMap.Map<Principal, { name : Text }>;
        amountSpent : Nat;
    };

    public func run(old : OldActor) : NewActor {
        let textMap = OrderedMap.Make<Text>(Text.compare);
        {
            deploymentLogs = textMap.map(
                old.deploymentLogs,
                func(_k, v) {
                    {
                        v with timestamp = Int.abs(v.timestamp)
                    };
                },
            );
            icpDonations = textMap.map(
                old.icpDonations,
                func(_k, v) {
                    {
                        v with timestamp = Int.abs(v.timestamp)
                    };
                },
            );
            cycleDonations = textMap.map(
                old.cycleDonations,
                func(_k, v) {
                    {
                        v with timestamp = Int.abs(v.timestamp)
                    };
                },
            );
            userProfiles = old.userProfiles;
            amountSpent = old.amountSpent;
        };
    };
};
