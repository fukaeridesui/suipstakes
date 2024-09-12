module suipstakes::raffle;

// === Imports ===

use sui::{
    random::{Random, new_generator},
    vec_set::{Self, VecSet},
    clock::Clock,
};

use std::string::{String};

// === Errors ===

const EDuplicateAddress: u64 = 1;
const EInvalidMinParticipants: u64 = 2;
const EInvalidMaxParticipants: u64 = 3;
const EInvalidParticipantsRange: u64 = 4;
const EParticipantsMaxReached: u64 = 5;
const ENotEnoughParticipants: u64 = 6;
const EInvalidNumberOfWinners: u64 = 7;
const ERaffleNotStarted: u64 = 8;
const ERaffleEnded: u64 = 9;
const ERaffleNotEnded: u64 = 10;
const EInvalidTimestamp: u64 = 11;
const ENotOwner: u64 = 8;

// === Structs ===

public struct RAFFLE has drop {}

public struct Raffle has key {
    id: UID,
    title: String,
    description: String,
    prize_in_sui: u64,
    min_participants: u32,
    max_participants: u32,
    start_timestamp: u64,
    end_timestamp: u64,
    participants: VecSet<address>,
    winners: VecSet<address>,
    number_of_winners: u32,
}

public struct RaffleOwnerCap has key, store {
    id: UID,
    `for`: ID
}

// === Functions ===

entry fun create(
    title: String,
    description: String,
    min_participants: u32,
    max_participants: u32,
    start_timestamp: u64,
    end_timestamp: u64,
    number_of_winners: u32,
    ctx: &mut TxContext
){
    assert!(min_participants > 0, EInvalidMinParticipants);
    assert!(max_participants > 0, EInvalidMaxParticipants);
    assert!(min_participants <= max_participants, EInvalidParticipantsRange);
    assert!(number_of_winners >= min_participants && number_of_winners <= max_participants, EInvalidNumberOfWinners);
    assert!(start_timestamp <= end_timestamp, EInvalidTimestamp);

    let raffle = Raffle {
        id: object::new(ctx),
        title,
        description,
        participants: vec_set::empty(),
        winners: vec_set::empty(),
        min_participants,
        max_participants,
        start_timestamp,
        end_timestamp,
        number_of_winners,
        // [TODO] values are for test and need to be fixed
        prize_in_sui: 100000000,
    };

    let raffle_owner_cap = RaffleOwnerCap {
        id: object::new(ctx),
        `for`: object::id(&raffle)
    };

    transfer::share_object(raffle);
    transfer::public_transfer(raffle_owner_cap, ctx.sender());
}


entry fun participate(
    raffle: &mut Raffle,
    clock: &Clock,
    ctx: & TxContext
){
    assert!(raffle.participants.size() as u32 < raffle.max_participants, EParticipantsMaxReached);
    assert!(raffle.participants.contains(&ctx.sender()) == false, EDuplicateAddress);
    assert!(raffle.start_timestamp <= clock.timestamp_ms(), ERaffleNotStarted);
    assert!(raffle.end_timestamp >= clock.timestamp_ms(), ERaffleEnded);

    raffle.participants.insert(ctx.sender())
}

entry fun run(
    raffle: &mut Raffle,
    cap: &RaffleOwnerCap,
    random: &Random,
    clock: &Clock,
    ctx: &mut TxContext
) {
    assert!(has_access(raffle, cap), ENotOwner);
    assert!(raffle.participants.size() as u32 >= raffle.min_participants, ENotEnoughParticipants);
    assert!(raffle.end_timestamp <= clock.timestamp_ms(), ERaffleNotEnded);

    let mut random_generator = random.new_generator(ctx);
    let mut i = 0;
    while (i < raffle.number_of_winners) {
        let winner_index = random_generator.generate_u64_in_range(
            0, 
            raffle.participants.size() -1
        );
        let address_list = raffle.participants.keys();
        let winner_address = address_list[winner_index];
        raffle.winners.insert(winner_address);
        raffle.participants.remove(&winner_address);

        i = i + 1;
    }
}

// === Raffle fields access ===

/// Check whether the `RaffleOwnerCap` matches the `Raffle`.
public fun has_access(self: &Raffle, cap: &RaffleOwnerCap): bool {
    object::id(self) == cap.`for`
}

// === RaffleOwnerCap fields access ===

/// Get the `for` field of the `RaffleOwnerCap`.
public fun raffle_owner_cap_for(cap: &RaffleOwnerCap): ID {
    cap.`for`
}
